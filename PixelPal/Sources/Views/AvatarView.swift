import SwiftUI

struct AvatarView: View {
    let state: AvatarState
    let gender: Gender
    let phase: Int
    var isWalking: Bool = false
    var size: CGFloat = 200
    var loadout: CosmeticLoadout? = nil

    @State private var idleFrame: Int = 1
    @State private var walkingFrame: Int = 1
    @State private var breathScale: CGFloat = 1.0
    @State private var bobOffset: CGFloat = 0
    @State private var appeared: Bool = false

    // 24fps walking timer
    private let walkingTimer = Timer.publish(every: 0.042, on: .main, in: .common).autoconnect()
    // Idle breathing toggle (~0.8s)
    private let idleTimer = Timer.publish(every: 0.8, on: .main, in: .common).autoconnect()

    private var spriteName: String {
        if isWalking {
            return SpriteAssets.walkingSpriteName(gender: gender, frame: walkingFrame)
        }
        return SpriteAssets.spriteName(gender: gender, state: state, frame: idleFrame)
    }

    private var phaseColor: Color {
        switch phase {
        case 1: return .gray
        case 2: return .blue
        case 3: return .purple
        case 4: return .orange
        default: return .gray
        }
    }

    private var animationSpeed: Double {
        switch state {
        case .vital: return 1.0
        case .neutral: return 0.75
        case .low: return 0.5
        }
    }

    var body: some View {
        ZStack {
            // Layer 1: Background (cosmetic or default phase glow)
            if let bgID = loadout?.background,
               let item = CosmeticCatalog.item(id: bgID) {
                Image(item.assetName)
                    .resizable()
                    .interpolation(.none)
                    .frame(width: size * 1.2, height: size * 1.2)
            } else {
                // Default phase-colored radial glow
                Circle()
                    .fill(
                        RadialGradient(
                            colors: [phaseColor.opacity(0.15), .clear],
                            center: .center,
                            startRadius: size * 0.15,
                            endRadius: size * 0.55
                        )
                    )
                    .frame(width: size * 1.2, height: size * 1.2)
            }

            // Layer 2: Character sprite (skin replaces entire character)
            if let skinID = loadout?.skin,
               let skinItem = CosmeticCatalog.item(id: skinID) {
                // Full skin replacement — no hat/accessory overlays
                Image(skinItem.assetName)
                    .resizable()
                    .interpolation(.none)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
                    .scaleEffect(isWalking ? 1.0 : breathScale)
                    .offset(y: isWalking ? 0 : bobOffset)
            } else {
                // Default character sprite + overlays
                Image(spriteName)
                    .resizable()
                    .interpolation(.none)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size, height: size)
                    .scaleEffect(isWalking ? 1.0 : breathScale)
                    .offset(y: isWalking ? 0 : bobOffset)

                // Layer 3: Hat overlay
                if let hatID = loadout?.hat,
                   let item = CosmeticCatalog.item(id: hatID) {
                    Image(item.assetName)
                        .resizable()
                        .interpolation(.none)
                        .frame(width: size * 0.6, height: size * 0.6)
                        .offset(y: -size * 0.3)
                        .scaleEffect(isWalking ? 1.0 : breathScale)
                        .offset(y: isWalking ? 0 : bobOffset)
                }

                // Layer 4: Accessory overlay
                if let accID = loadout?.accessory,
                   let item = CosmeticCatalog.item(id: accID) {
                    Image(item.assetName)
                        .resizable()
                        .interpolation(.none)
                        .frame(width: size * 0.5, height: size * 0.5)
                        .offset(x: size * 0.25)
                        .scaleEffect(isWalking ? 1.0 : breathScale)
                        .offset(y: isWalking ? 0 : bobOffset)
                }
            }
        }
        .scaleEffect(appeared ? 1.0 : 0.5)
        .opacity(appeared ? 1.0 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                appeared = true
            }
            startBreathingAnimation()
        }
        .onReceive(walkingTimer) { _ in
            guard isWalking else { return }
            walkingFrame = (walkingFrame % SpriteAssets.walkingFrameCount) + 1
        }
        .onReceive(idleTimer) { _ in
            guard !isWalking else { return }
            idleFrame = idleFrame == 1 ? 2 : 1
        }
        .onChange(of: isWalking) { walking in
            if !walking {
                walkingFrame = 1
                startBreathingAnimation()
            }
        }
    }

    private func startBreathingAnimation() {
        let duration = 1.6 / animationSpeed
        withAnimation(.easeInOut(duration: duration).repeatForever(autoreverses: true)) {
            breathScale = 1.02
            bobOffset = -2
        }
    }
}
