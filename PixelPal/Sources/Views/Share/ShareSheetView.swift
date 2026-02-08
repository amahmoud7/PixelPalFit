import SwiftUI

struct ShareSheetView: View {
    let data: ShareCardData

    @State private var cardType: ShareCardType = .dailyProgress
    @State private var format: ShareCardFormat = .story
    @State private var background: ShareCardBackground = .darkGlow

    @Environment(\.dismiss) private var dismiss

    private let renderer = ShareCardRenderer()
    private let destinationManager = ShareDestinationManager()

    var body: some View {
        ZStack {
            Color(red: 0.04, green: 0.04, blue: 0.12)
                .ignoresSafeArea()

            ScrollView(showsIndicators: false) {
                VStack(spacing: 16) {
                    // Header
                    VStack(spacing: 4) {
                        Text("Share My Pixel Pace Stats")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.white)

                        Text("Widget-style share cards with editable backgrounds")
                            .font(.system(size: 13, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    .padding(.top, 20)

                    // Card type tabs
                    HStack(spacing: 8) {
                        ForEach(ShareCardType.allCases, id: \.self) { type in
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    cardType = type
                                }
                            } label: {
                                Text(type.title)
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .padding(.horizontal, 16)
                                    .padding(.vertical, 8)
                                    .background(
                                        cardType == type
                                        ? Color.white.opacity(0.15)
                                        : Color.white.opacity(0.05)
                                    )
                                    .foregroundColor(
                                        cardType == type ? .white : .white.opacity(0.4)
                                    )
                                    .clipShape(Capsule())
                                    .overlay(
                                        cardType == type
                                        ? Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1)
                                        : nil
                                    )
                            }
                        }
                    }

                    // Format toggle
                    HStack(spacing: 8) {
                        ForEach(ShareCardFormat.allCases, id: \.self) { fmt in
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    format = fmt
                                }
                            } label: {
                                Text(fmt.title)
                                    .font(.system(size: 14, weight: .semibold, design: .rounded))
                                    .padding(.horizontal, 20)
                                    .padding(.vertical, 8)
                                    .background(
                                        format == fmt
                                        ? Color.white.opacity(0.15)
                                        : Color.white.opacity(0.05)
                                    )
                                    .foregroundColor(
                                        format == fmt ? .white : .white.opacity(0.4)
                                    )
                                    .clipShape(Capsule())
                                    .overlay(
                                        format == fmt
                                        ? Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1)
                                        : nil
                                    )
                            }
                        }
                    }

                    // Background label
                    Text("BACKGROUND")
                        .font(.system(size: 11, weight: .bold, design: .rounded))
                        .foregroundColor(.white.opacity(0.35))
                        .tracking(1)
                        .padding(.top, 4)

                    // Background picker
                    HStack(spacing: 12) {
                        ForEach(ShareCardBackground.allCases, id: \.self) { bg in
                            Button {
                                withAnimation(.easeInOut(duration: 0.2)) {
                                    background = bg
                                }
                            } label: {
                                backgroundThumbnail(bg)
                            }
                        }
                    }

                    // Card preview
                    cardPreview
                        .padding(.top, 4)

                    // Action buttons
                    VStack(spacing: 12) {
                        // Instagram Story button
                        Button {
                            shareToInstagramStory()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "camera.fill")
                                    .font(.system(size: 15, weight: .semibold))
                                Text("Share to Instagram Story")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(
                                LinearGradient(
                                    colors: [
                                        Color(red: 0.93, green: 0.27, blue: 0.47),
                                        Color(red: 0.6, green: 0.2, blue: 0.8)
                                    ],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                        }

                        // General share button
                        Button {
                            shareGeneral()
                        } label: {
                            HStack(spacing: 8) {
                                Image(systemName: "square.and.arrow.up")
                                    .font(.system(size: 15, weight: .semibold))
                                Text("Share")
                                    .font(.system(size: 16, weight: .semibold, design: .rounded))
                            }
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 15)
                            .background(Color.white.opacity(0.1))
                            .clipShape(RoundedRectangle(cornerRadius: 14))
                            .overlay(
                                RoundedRectangle(cornerRadius: 14)
                                    .stroke(Color.white.opacity(0.15), lineWidth: 1)
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 40)
                }
            }
        }
        .presentationDragIndicator(.visible)
        .preferredColorScheme(.dark)
    }

    // MARK: - Card Preview

    private var cardPreview: some View {
        let previewWidth: CGFloat = 280
        let scale = previewWidth / format.pointSize.width

        return renderer.cardView(
            type: cardType,
            data: data,
            format: format,
            background: background
        )
        .scaleEffect(scale, anchor: .topLeading)
        .frame(
            width: format.pointSize.width * scale,
            height: format.pointSize.height * scale
        )
        .clipShape(RoundedRectangle(cornerRadius: 16))
        .overlay(
            RoundedRectangle(cornerRadius: 16)
                .stroke(Color.white.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.4), radius: 16, y: 6)
    }

    // MARK: - Background Thumbnail

    @ViewBuilder
    private func backgroundThumbnail(_ bg: ShareCardBackground) -> some View {
        let isSelected = background == bg

        VStack(spacing: 4) {
            ZStack {
                if bg == .transparent {
                    checkerboard
                } else {
                    ShareCardBackgroundView(background: bg, format: .square)
                }
            }
            .frame(width: 48, height: 48)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        isSelected ? Color.white : Color.white.opacity(0.1),
                        lineWidth: isSelected ? 2 : 1
                    )
            )

            Text(bg.title)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundColor(isSelected ? .white : .white.opacity(0.4))
        }
    }

    private var checkerboard: some View {
        Canvas { context, size in
            let cellSize: CGFloat = 6
            let rows = Int(size.height / cellSize) + 1
            let cols = Int(size.width / cellSize) + 1

            for row in 0..<rows {
                for col in 0..<cols {
                    let isLight = (row + col) % 2 == 0
                    let rect = CGRect(
                        x: CGFloat(col) * cellSize,
                        y: CGFloat(row) * cellSize,
                        width: cellSize,
                        height: cellSize
                    )
                    context.fill(
                        Path(rect),
                        with: .color(isLight ? Color(white: 0.25) : Color(white: 0.15))
                    )
                }
            }
        }
    }

    // MARK: - Actions

    private func shareToInstagramStory() {
        if background == .transparent {
            // Transparent = sticker mode (user picks their own background in IG)
            guard let sticker = renderer.renderImage(
                cardType: cardType,
                data: data,
                format: format,
                background: .transparent
            ) else { return }

            destinationManager.shareStickerToInstagramStory(stickerImage: sticker)
        } else {
            // Opaque = full background image
            guard let image = renderer.renderImage(
                cardType: cardType,
                data: data,
                format: format,
                background: background
            ) else { return }

            destinationManager.shareBackgroundToInstagramStory(backgroundImage: image)
        }
    }

    private func shareGeneral() {
        guard let image = renderer.renderImage(
            cardType: cardType,
            data: data,
            format: format,
            background: background
        ) else { return }

        destinationManager.presentShareSheet(image: image)
    }
}
