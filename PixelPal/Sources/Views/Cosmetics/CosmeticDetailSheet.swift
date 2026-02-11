import SwiftUI

/// Detail sheet showing a cosmetic item with live avatar preview, info, and buy/equip actions.
struct CosmeticDetailSheet: View {
    let item: CosmeticItem
    @EnvironmentObject var appState: AppStateManager
    @Environment(\.dismiss) private var dismiss

    @State private var showPurchaseSuccess = false

    private var cosmeticManager: CosmeticManager { appState.cosmeticManager }
    private var isOwned: Bool { cosmeticManager.inventory.ownedItemIDs.contains(item.id) }
    private var isEquipped: Bool { cosmeticManager.currentLoadout.equipped(for: item.category) == item.id }
    private var balance: Int { PersistenceManager.shared.progressState.stepCoinBalance }

    private var eligibility: PurchaseEligibility {
        cosmeticManager.canPurchase(
            item,
            balance: balance,
            isPremium: appState.storeManager.isPremium,
            phase: appState.currentPhase,
            streak: appState.currentStreak,
            totalSteps: PersistenceManager.shared.progressState.totalStepsSinceStart
        )
    }

    /// Preview loadout: current loadout with this item equipped.
    private var previewLoadout: CosmeticLoadout {
        var loadout = cosmeticManager.currentLoadout
        loadout.equip(item.id, for: item.category)
        return loadout
    }

    var body: some View {
        VStack(spacing: 0) {
            // Header
            HStack {
                Spacer()
                Button(action: { dismiss() }) {
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24))
                        .foregroundColor(.white.opacity(0.3))
                }
            }
            .padding(.horizontal, 20)
            .padding(.top, 16)

            Spacer().frame(height: 16)

            // Live preview
            AvatarView(
                state: appState.avatarState,
                gender: appState.gender,
                phase: appState.currentPhase,
                size: 160,
                loadout: previewLoadout
            )
            .frame(height: 180)

            Spacer().frame(height: 20)

            // Item name + rarity
            Text(item.name)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)

            Spacer().frame(height: 6)

            Text(item.rarity.displayName)
                .font(.system(size: 12, weight: .bold))
                .foregroundColor(item.rarity.color)
                .padding(.horizontal, 10)
                .padding(.vertical, 4)
                .background(item.rarity.color.opacity(0.15))
                .clipShape(Capsule())

            Spacer().frame(height: 6)

            Text(item.category.displayName.dropLast()) // "Background", "Hat", "Accessory"
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.white.opacity(0.4))

            Spacer().frame(height: 24)

            // Action area
            actionButton

            if showPurchaseSuccess {
                Text("Purchase successful!")
                    .font(.system(size: 13, weight: .medium))
                    .foregroundColor(Color(red: 0.2, green: 0.78, blue: 0.35))
                    .padding(.top, 8)
            }

            Spacer()
        }
        .background(
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.02, blue: 0.15),
                    Color(red: 0.10, green: 0.04, blue: 0.22)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()
        )
    }

    @ViewBuilder
    private var actionButton: some View {
        if isOwned {
            // Equip / Unequip
            Button(action: {
                let impact = UIImpactFeedbackGenerator(style: .light)
                impact.impactOccurred()
                if isEquipped {
                    cosmeticManager.unequip(category: item.category)
                } else {
                    cosmeticManager.equip(item.id, category: item.category)
                }
            }) {
                Text(isEquipped ? "Unequip" : "Equip")
                    .font(.system(size: 17, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        isEquipped
                            ? Color.white.opacity(0.1)
                            : Color(red: 0.2, green: 0.78, blue: 0.35)
                    )
                    .cornerRadius(16)
            }
            .padding(.horizontal, 32)
        } else {
            switch eligibility {
            case .canBuy:
                Button(action: purchaseItem) {
                    HStack(spacing: 8) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.yellow)
                        Text("Buy for \(item.price)")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(
                        LinearGradient(
                            colors: [Color(red: 0.49, green: 0.36, blue: 0.99), Color(red: 0.0, green: 0.83, blue: 1.0).opacity(0.8)],
                            startPoint: .leading,
                            endPoint: .trailing
                        )
                    )
                    .cornerRadius(16)
                }
                .padding(.horizontal, 32)

                // Balance display
                HStack(spacing: 4) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 8))
                        .foregroundColor(.yellow)
                    Text("Balance: \(balance)")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.4))
                }
                .padding(.top, 8)

            case .insufficientCoins(let need):
                VStack(spacing: 8) {
                    HStack(spacing: 8) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 10))
                            .foregroundColor(.yellow.opacity(0.4))
                        Text("Buy for \(item.price)")
                            .font(.system(size: 17, weight: .bold, design: .rounded))
                            .foregroundColor(.white.opacity(0.4))
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 16)
                    .background(Color.white.opacity(0.06))
                    .cornerRadius(16)
                    .padding(.horizontal, 32)

                    Text("Need \(need) more coins")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.orange)
                }

            case .requiresPremium:
                VStack(spacing: 8) {
                    Button(action: { appState.showPaywall = true }) {
                        HStack(spacing: 8) {
                            Image(systemName: "crown.fill")
                                .font(.system(size: 14))
                                .foregroundColor(.yellow)
                            Text("Unlock Premium")
                                .font(.system(size: 17, weight: .bold, design: .rounded))
                                .foregroundColor(.white)
                        }
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 16)
                        .background(Color(red: 0.49, green: 0.36, blue: 0.99).opacity(0.3))
                        .cornerRadius(16)
                    }
                    .padding(.horizontal, 32)

                    Text("Premium subscription required")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.yellow.opacity(0.6))
                }

            default:
                Text(eligibility.lockMessage ?? "Not available")
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.white.opacity(0.4))
                    .padding(.vertical, 16)
            }
        }
    }

    private func purchaseItem() {
        let impact = UIImpactFeedbackGenerator(style: .medium)
        impact.impactOccurred()

        guard cosmeticManager.purchase(item) else { return }
        showPurchaseSuccess = true

        let success = UINotificationFeedbackGenerator()
        success.notificationOccurred(.success)

        // Auto-equip after purchase
        cosmeticManager.equip(item.id, category: item.category)
    }
}
