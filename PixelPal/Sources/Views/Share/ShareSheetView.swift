import SwiftUI

struct ShareSheetView: View {
    let data: ShareCardData

    @State private var cardType: ShareCardType = .dailyProgress
    @State private var format: ShareCardFormat = .story
    @State private var background: ShareCardBackground = .darkGlow
    @State private var toastMessage: String?
    @State private var spriteFrame: Int = 1
    @State private var showPaywall: Bool = false

    @Environment(\.dismiss) private var dismiss

    private let renderer = ShareCardRenderer()
    private let destinationManager = ShareDestinationManager()

    var body: some View {
        ZStack {
            Color(red: 0.04, green: 0.04, blue: 0.12)
                .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                VStack(spacing: 4) {
                    Text("Share My Pixel Stepper Stats")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("Widget-style share cards with editable backgrounds")
                        .font(.system(size: 12, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.4))
                }
                .padding(.top, 16)
                .padding(.bottom, 12)

                // Card type tabs
                HStack(spacing: 8) {
                    ForEach(ShareCardType.allCases, id: \.self) { type in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) { cardType = type }
                        } label: {
                            Text(type.title)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .padding(.horizontal, 14)
                                .padding(.vertical, 7)
                                .background(cardType == type ? Color.white.opacity(0.15) : Color.white.opacity(0.05))
                                .foregroundColor(cardType == type ? .white : .white.opacity(0.4))
                                .clipShape(Capsule())
                                .overlay(
                                    cardType == type
                                    ? Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    : nil
                                )
                        }
                    }
                }
                .padding(.bottom, 8)

                // Format toggle
                HStack(spacing: 8) {
                    ForEach(ShareCardFormat.allCases, id: \.self) { fmt in
                        Button {
                            withAnimation(.easeInOut(duration: 0.2)) { format = fmt }
                        } label: {
                            Text(fmt.title)
                                .font(.system(size: 13, weight: .semibold, design: .rounded))
                                .padding(.horizontal, 18)
                                .padding(.vertical, 7)
                                .background(format == fmt ? Color.white.opacity(0.15) : Color.white.opacity(0.05))
                                .foregroundColor(format == fmt ? .white : .white.opacity(0.4))
                                .clipShape(Capsule())
                                .overlay(
                                    format == fmt
                                    ? Capsule().stroke(Color.white.opacity(0.2), lineWidth: 1)
                                    : nil
                                )
                        }
                    }
                }
                .padding(.bottom, 10)

                // Background label
                Text("BACKGROUND")
                    .font(.system(size: 10, weight: .bold, design: .rounded))
                    .foregroundColor(.white.opacity(0.3))
                    .tracking(1)
                    .padding(.bottom, 6)

                // Background picker
                HStack(spacing: 12) {
                    ForEach(ShareCardBackground.allCases, id: \.self) { bg in
                        Button {
                            if bg.requiresPremium && !data.isPremium {
                                showPaywall = true
                            } else {
                                withAnimation(.easeInOut(duration: 0.2)) { background = bg }
                            }
                        } label: {
                            backgroundThumbnail(bg)
                        }
                    }
                }
                .padding(.bottom, 12)

                // Card preview (centered, fills remaining space)
                cardPreview
                    .frame(maxWidth: .infinity)
                    .padding(.horizontal, 20)

                Spacer(minLength: 12)

                // Action buttons — 4 squares side by side
                actionButtons
                    .padding(.horizontal, 20)
                    .padding(.bottom, 28)
            }

            // Toast overlay
            if let message = toastMessage {
                VStack {
                    Spacer()
                    Text(message)
                        .font(.system(size: 14, weight: .semibold, design: .rounded))
                        .foregroundColor(.white)
                        .padding(.horizontal, 20)
                        .padding(.vertical, 10)
                        .background(Color.black.opacity(0.8))
                        .clipShape(Capsule())
                        .padding(.bottom, 100)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .zIndex(1)
            }
        }
        .presentationDragIndicator(.visible)
        .preferredColorScheme(.dark)
        .sheet(isPresented: $showPaywall) {
            PaywallView(storeManager: StoreManager.shared, gender: data.gender, currentPhase: data.currentPhase)
        }
        .task {
            while !Task.isCancelled {
                try? await Task.sleep(nanoseconds: 600_000_000)
                spriteFrame = spriteFrame == 1 ? 2 : 1
            }
        }
    }

    // MARK: - Card Preview

    private var cardPreview: some View {
        GeometryReader { geo in
            let maxWidth = geo.size.width
            let maxHeight = geo.size.height
            let cardAspect = format.pointSize.width / format.pointSize.height
            let fitWidth = min(maxWidth, maxHeight * cardAspect)
            let fitHeight = fitWidth / cardAspect
            let scale = fitWidth / format.pointSize.width

            ZStack {
                // Checkerboard behind card when transparent
                if background == .transparent {
                    checkerboard
                        .frame(width: fitWidth, height: fitHeight)
                        .clipShape(RoundedRectangle(cornerRadius: 14))
                }

                renderer.cardView(
                    type: cardType,
                    data: data,
                    format: format,
                    background: background,
                    spriteFrame: spriteFrame
                )
                .scaleEffect(scale)
                .frame(width: fitWidth, height: fitHeight)
                .clipped()
                .clipShape(RoundedRectangle(cornerRadius: 14))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color.white.opacity(0.1), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.3), radius: 12, y: 4)
            }
            .position(x: geo.size.width / 2, y: geo.size.height / 2)
        }
    }

    // MARK: - Action Buttons

    private var actionButtons: some View {
        HStack(spacing: 12) {
            // Instagram Story
            actionButton(
                icon: "camera.fill",
                label: "Instagram",
                gradient: [
                    Color(red: 0.93, green: 0.27, blue: 0.47),
                    Color(red: 0.6, green: 0.2, blue: 0.8)
                ]
            ) {
                shareToInstagramStory()
            }

            // Save GIF (Photos + Files)
            actionButton(
                icon: "arrow.down.to.line",
                label: "Save GIF",
                gradient: nil
            ) {
                saveToPhotos()
            }

            // Copy to Clipboard
            actionButton(
                icon: "doc.on.doc",
                label: "Copy",
                gradient: nil
            ) {
                copyToClipboard()
            }

            // Share
            actionButton(
                icon: "square.and.arrow.up",
                label: "Share",
                gradient: nil
            ) {
                shareGeneral()
            }
        }
        .frame(height: 72)
    }

    @ViewBuilder
    private func actionButton(
        icon: String,
        label: String,
        gradient: [Color]?,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(spacing: 6) {
                Image(systemName: icon)
                    .font(.system(size: 18, weight: .semibold))
                Text(label)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
            }
            .foregroundColor(.white)
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            .background(
                Group {
                    if let colors = gradient {
                        LinearGradient(colors: colors, startPoint: .topLeading, endPoint: .bottomTrailing)
                    } else {
                        Color.white.opacity(0.08)
                    }
                }
            )
            .clipShape(RoundedRectangle(cornerRadius: 14))
            .overlay(
                gradient == nil
                ? RoundedRectangle(cornerRadius: 14).stroke(Color.white.opacity(0.1), lineWidth: 1)
                : nil
            )
        }
    }

    // MARK: - Background Thumbnail

    @ViewBuilder
    private func backgroundThumbnail(_ bg: ShareCardBackground) -> some View {
        let isSelected = background == bg
        let isLocked = bg.requiresPremium && !data.isPremium

        VStack(spacing: 3) {
            ZStack {
                if bg == .transparent {
                    checkerboard
                } else {
                    ShareCardBackgroundView(background: bg, format: .square)
                }

                if isLocked {
                    Color.black.opacity(0.5)
                    Image(systemName: "lock.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.white.opacity(0.8))
                }
            }
            .frame(width: 44, height: 44)
            .clipShape(RoundedRectangle(cornerRadius: 10))
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        isSelected ? Color.white : Color.white.opacity(0.1),
                        lineWidth: isSelected ? 2 : 1
                    )
            )

            Text(bg.title)
                .font(.system(size: 9, weight: .medium, design: .rounded))
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

    private func renderCurrentCard() -> UIImage? {
        renderer.renderImage(
            cardType: cardType,
            data: data,
            format: format,
            background: background,
            spriteFrame: spriteFrame
        )
    }

    private func renderGIF() -> Data? {
        renderer.renderGIFData(
            cardType: cardType,
            data: data,
            format: format,
            background: background
        )
    }

    private func shareToInstagramStory() {
        guard destinationManager.isInstagramAvailable else {
            showToast("Instagram not installed")
            return
        }

        if background == .transparent {
            if let apngData = renderer.renderAPNGData(
                cardType: cardType,
                data: data,
                format: format,
                background: background
            ) {
                destinationManager.shareAPNGStickerToInstagramStory(apngData: apngData)
            }
        } else {
            guard let image = renderCurrentCard() else { return }
            destinationManager.shareBackgroundToInstagramStory(backgroundImage: image)
        }
    }

    private func saveToPhotos() {
        guard let gifData = renderGIF() else { return }
        // Save to Photos
        destinationManager.saveGIFToPhotos(data: gifData) { success in
            if success { showToast("Saved to Photos") }
        }
        // Also save to Files via share sheet so user can access GIF for Instagram
        destinationManager.saveGIFToFiles(data: gifData)
    }

    private func copyToClipboard() {
        guard let image = renderCurrentCard() else { return }
        destinationManager.copyToClipboard(image: image)
        showToast("Copied to Clipboard")
    }

    private func shareGeneral() {
        guard let image = renderCurrentCard() else { return }
        destinationManager.presentShareSheet(image: image)
    }

    private func showToast(_ message: String) {
        withAnimation(.easeInOut(duration: 0.25)) {
            toastMessage = message
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.5) {
            withAnimation(.easeInOut(duration: 0.25)) {
                toastMessage = nil
            }
        }
    }
}
