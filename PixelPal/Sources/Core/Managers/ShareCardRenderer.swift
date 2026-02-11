import SwiftUI
import AVFoundation

@MainActor
final class ShareCardRenderer {

    // MARK: - Static Image Rendering

    func renderImage(
        cardType: ShareCardType,
        data: ShareCardData,
        format: ShareCardFormat,
        background: ShareCardBackground,
        spriteFrame: Int = 1
    ) -> UIImage? {
        let view = cardView(type: cardType, data: data, format: format, background: background, spriteFrame: spriteFrame)
        let renderer = ImageRenderer(content: view)
        renderer.scale = 3.0
        renderer.isOpaque = !background.isTransparent
        return renderer.uiImage
    }

    // MARK: - Animated GIF

    func renderGIFData(
        cardType: ShareCardType,
        data: ShareCardData,
        format: ShareCardFormat,
        background: ShareCardBackground
    ) -> Data? {
        guard let frame1 = renderImage(cardType: cardType, data: data, format: format, background: background, spriteFrame: 1),
              let frame2 = renderImage(cardType: cardType, data: data, format: format, background: background, spriteFrame: 2) else { return nil }
        return AnimatedImageEncoder.encodeGIF(frames: [frame1, frame2])
    }

    // MARK: - Animated PNG (APNG)

    func renderAPNGData(
        cardType: ShareCardType,
        data: ShareCardData,
        format: ShareCardFormat,
        background: ShareCardBackground
    ) -> Data? {
        guard let frame1 = renderImage(cardType: cardType, data: data, format: format, background: background, spriteFrame: 1),
              let frame2 = renderImage(cardType: cardType, data: data, format: format, background: background, spriteFrame: 2) else { return nil }
        return AnimatedImageEncoder.encodeAPNG(frames: [frame1, frame2])
    }

    // MARK: - Video Rendering

    func renderVideo(
        cardType: ShareCardType,
        data: ShareCardData,
        format: ShareCardFormat,
        background: ShareCardBackground,
        completion: @escaping (URL?) -> Void
    ) {
        // Render 2 unique frames on main thread, extract CGImages immediately
        guard let cg1 = renderImage(cardType: cardType, data: data, format: format, background: background, spriteFrame: 1)?.cgImage,
              let cg2 = renderImage(cardType: cardType, data: data, format: format, background: background, spriteFrame: 2)?.cgImage else {
            completion(nil)
            return
        }

        // Build alternating CGImage array (thread-safe, no UIImage on background)
        var cgFrames: [CGImage] = []
        for i in 0..<10 {
            cgFrames.append(i % 2 == 0 ? cg1 : cg2)
        }

        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("pixelstepper_share_\(UUID().uuidString).mp4")

        let size = format.pixelSize
        Self.composeVideo(cgFrames: cgFrames, outputURL: outputURL, size: size, fps: 4) { success in
            DispatchQueue.main.async {
                completion(success ? outputURL : nil)
            }
        }
    }

    // MARK: - Card View Factory

    @ViewBuilder
    func cardView(
        type: ShareCardType,
        data: ShareCardData,
        format: ShareCardFormat,
        background: ShareCardBackground,
        spriteFrame: Int = 1
    ) -> some View {
        switch type {
        case .dailyProgress:
            DailyProgressCard(data: data, format: format, background: background, spriteFrame: spriteFrame)
        case .evolutionMilestone:
            EvolutionMilestoneCard(data: data, format: format, background: background, spriteFrame: spriteFrame)
        case .weeklySummary:
            WeeklySummaryCard(data: data, format: format, background: background, spriteFrame: spriteFrame)
        case .streak:
            StreakShareCard(data: data, format: format, background: background, spriteFrame: spriteFrame)
        }
    }

    // MARK: - Video Composition (static — no self capture, no UIImage on background thread)

    private static nonisolated func composeVideo(
        cgFrames: [CGImage],
        outputURL: URL,
        size: CGSize,
        fps: Int,
        completion: @escaping (Bool) -> Void
    ) {
        DispatchQueue(label: "com.pixelstepper.videowriter").async {
            try? FileManager.default.removeItem(at: outputURL)

            guard let writer = try? AVAssetWriter(outputURL: outputURL, fileType: .mp4) else {
                completion(false)
                return
            }

            let settings: [String: Any] = [
                AVVideoCodecKey: AVVideoCodecType.h264,
                AVVideoWidthKey: Int(size.width),
                AVVideoHeightKey: Int(size.height)
            ]

            let writerInput = AVAssetWriterInput(mediaType: .video, outputSettings: settings)
            writerInput.expectsMediaDataInRealTime = false

            let adaptor = AVAssetWriterInputPixelBufferAdaptor(
                assetWriterInput: writerInput,
                sourcePixelBufferAttributes: [
                    kCVPixelBufferPixelFormatTypeKey as String: kCVPixelFormatType_32ARGB,
                    kCVPixelBufferWidthKey as String: Int(size.width),
                    kCVPixelBufferHeightKey as String: Int(size.height)
                ]
            )

            writer.add(writerInput)

            guard writer.startWriting() else {
                completion(false)
                return
            }
            writer.startSession(atSourceTime: .zero)

            let frameDuration = CMTime(value: 1, timescale: CMTimeScale(fps))

            for (i, cgImage) in cgFrames.enumerated() {
                while !writerInput.isReadyForMoreMediaData {
                    Thread.sleep(forTimeInterval: 0.01)
                }

                let presentationTime = CMTimeMultiply(frameDuration, multiplier: Int32(i))
                guard let pixelBuffer = pixelBuffer(from: cgImage, size: size) else { continue }
                adaptor.append(pixelBuffer, withPresentationTime: presentationTime)
            }

            writerInput.markAsFinished()
            writer.finishWriting {
                completion(writer.status == .completed)
            }
        }
    }

    private static nonisolated func pixelBuffer(from cgImage: CGImage, size: CGSize) -> CVPixelBuffer? {
        let attrs: [String: Any] = [
            kCVPixelBufferCGImageCompatibilityKey as String: true,
            kCVPixelBufferCGBitmapContextCompatibilityKey as String: true
        ]

        var pixelBuffer: CVPixelBuffer?
        let status = CVPixelBufferCreate(
            kCFAllocatorDefault,
            Int(size.width),
            Int(size.height),
            kCVPixelFormatType_32ARGB,
            attrs as CFDictionary,
            &pixelBuffer
        )

        guard status == kCVReturnSuccess, let buffer = pixelBuffer else { return nil }

        CVPixelBufferLockBaseAddress(buffer, [])
        defer { CVPixelBufferUnlockBaseAddress(buffer, []) }

        guard let context = CGContext(
            data: CVPixelBufferGetBaseAddress(buffer),
            width: Int(size.width),
            height: Int(size.height),
            bitsPerComponent: 8,
            bytesPerRow: CVPixelBufferGetBytesPerRow(buffer),
            space: CGColorSpaceCreateDeviceRGB(),
            bitmapInfo: CGImageAlphaInfo.noneSkipFirst.rawValue
        ) else { return nil }

        context.draw(cgImage, in: CGRect(origin: .zero, size: size))
        return buffer
    }
}
