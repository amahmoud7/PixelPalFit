import UIKit

@MainActor
final class ShareDestinationManager {

    private static let facebookAppID = "1437491044650461"

    var isInstagramAvailable: Bool {
        guard let url = URL(string: "instagram-stories://share") else { return false }
        return UIApplication.shared.canOpenURL(url)
    }

    // MARK: - Instagram Story Sticker

    /// Shares a transparent PNG as a draggable/resizable sticker on Instagram Stories.
    func shareStickerToInstagramStory(
        stickerImage: UIImage,
        topColor: String = "#0A0A1F",
        bottomColor: String = "#1A0A2E"
    ) {
        guard let url = URL(string: "instagram-stories://share?source_application=\(Self.facebookAppID)"),
              UIApplication.shared.canOpenURL(url) else { return }

        guard let stickerData = stickerImage.pngData() else { return }

        let items: [[String: Any]] = [[
            "com.instagram.sharedSticker.stickerImage": stickerData,
            "com.instagram.sharedSticker.backgroundTopColor": topColor,
            "com.instagram.sharedSticker.backgroundBottomColor": bottomColor
        ]]

        UIPasteboard.general.setItems(items, options: [
            .expirationDate: Date().addingTimeInterval(300)
        ])

        UIApplication.shared.open(url)
    }

    /// Shares a full-screen background image to Instagram Stories.
    func shareBackgroundToInstagramStory(backgroundImage: UIImage) {
        guard let url = URL(string: "instagram-stories://share?source_application=\(Self.facebookAppID)"),
              UIApplication.shared.canOpenURL(url) else { return }

        guard let imageData = backgroundImage.pngData() else { return }

        let items: [[String: Any]] = [[
            "com.instagram.sharedSticker.backgroundImage": imageData
        ]]

        UIPasteboard.general.setItems(items, options: [
            .expirationDate: Date().addingTimeInterval(300)
        ])

        UIApplication.shared.open(url)
    }

    // MARK: - General Share Sheet

    func presentShareSheet(image: UIImage) {
        let activityVC = UIActivityViewController(
            activityItems: [image],
            applicationActivities: nil
        )
        presentActivityViewController(activityVC)
    }

    // MARK: - Private

    private func presentActivityViewController(_ vc: UIActivityViewController) {
        guard let windowScene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
              let rootVC = windowScene.windows.first?.rootViewController else { return }

        var topVC = rootVC
        while let presented = topVC.presentedViewController {
            topVC = presented
        }

        if let popover = vc.popoverPresentationController {
            popover.sourceView = topVC.view
            popover.sourceRect = CGRect(
                x: topVC.view.bounds.midX,
                y: topVC.view.bounds.midY,
                width: 0,
                height: 0
            )
        }

        topVC.present(vc, animated: true)
    }
}
