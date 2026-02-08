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

    // MARK: - Video Rendering

    func renderVideo(
        cardType: ShareCardType,
        data: ShareCardData,
        format: ShareCardFormat,
        background: ShareCardBackground,
        completion: @escaping (URL?) -> Void
    ) {
        // Generate frames alternating sprite frames 1 and 2
        let fps = 4
        let duration: Double = 2.4
        let totalFrames = Int(Double(fps) * duration)

        var frames: [UIImage] = []
        for i in 0..<totalFrames {
            let spriteFrame = (i % 2) + 1
            guard let image = renderImage(
                cardType: cardType,
                data: data,
                format: format,
                background: background,
                spriteFrame: spriteFrame
            ) else {
                completion(nil)
                return
            }
            frames.append(image)
        }

        let outputURL = FileManager.default.temporaryDirectory
            .appendingPathComponent("pixelpal_share_\(UUID().uuidString).mp4")

        let size = format.pixelSize
        composeVideo(frames: frames, outputURL: outputURL, size: size, fps: fps) { success in
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
        }
    }

    // MARK: - Video Composition

    private func composeVideo(
        frames: [UIImage],
        outputURL: URL,
        size: CGSize,
        fps: Int,
        completion: @escaping (Bool) -> Void
    ) {
        // Clean up existing file
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

        writerInput.requestMediaDataWhenReady(on: DispatchQueue(label: "com.pixelpal.videowriter")) {
            var frameIndex = 0

            while writerInput.isReadyForMoreMediaData && frameIndex < frames.count {
                let presentationTime = CMTimeMultiply(frameDuration, multiplier: Int32(frameIndex))

                guard let pixelBuffer = self.pixelBuffer(from: frames[frameIndex], size: size) else {
                    frameIndex += 1
                    continue
                }

                adaptor.append(pixelBuffer, withPresentationTime: presentationTime)
                frameIndex += 1
            }

            if frameIndex >= frames.count {
                writerInput.markAsFinished()
                writer.finishWriting {
                    completion(writer.status == .completed)
                }
            }
        }
    }

    private nonisolated func pixelBuffer(from image: UIImage, size: CGSize) -> CVPixelBuffer? {
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

        guard let cgImage = image.cgImage else { return nil }

        context.draw(cgImage, in: CGRect(origin: .zero, size: size))
        return buffer
    }
}
