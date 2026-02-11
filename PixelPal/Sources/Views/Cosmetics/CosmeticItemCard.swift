import SwiftUI

/// Grid card showing a cosmetic item thumbnail, name, price, and lock state.
struct CosmeticItemCard: View {
    let item: CosmeticItem
    let isOwned: Bool
    let isEquipped: Bool
    let eligibility: PurchaseEligibility

    var body: some View {
        VStack(spacing: 6) {
            // Thumbnail
            ZStack {
                RoundedRectangle(cornerRadius: 10)
                    .fill(item.rarity.color.opacity(0.08))
                    .frame(height: 80)

                Image(item.assetName)
                    .resizable()
                    .interpolation(.none)
                    .aspectRatio(contentMode: .fit)
                    .frame(width: 48, height: 48)
                    .opacity(isLocked ? 0.35 : 1.0)

                // Lock overlay
                if isLocked {
                    lockBadge
                }

                // Equipped indicator
                if isEquipped {
                    VStack {
                        HStack {
                            Spacer()
                            Image(systemName: "checkmark.circle.fill")
                                .font(.system(size: 14))
                                .foregroundColor(Color(red: 0.2, green: 0.78, blue: 0.35))
                                .padding(4)
                        }
                        Spacer()
                    }
                }

                // Rarity indicator
                VStack {
                    Spacer()
                    HStack {
                        Spacer()
                        Text(item.rarity.displayName)
                            .font(.system(size: 7, weight: .bold))
                            .foregroundColor(item.rarity.color)
                            .padding(.horizontal, 4)
                            .padding(.vertical, 2)
                            .background(item.rarity.color.opacity(0.15))
                            .clipShape(Capsule())
                            .padding(4)
                    }
                }
            }
            .overlay(
                RoundedRectangle(cornerRadius: 10)
                    .stroke(
                        isEquipped ? Color(red: 0.2, green: 0.78, blue: 0.35).opacity(0.6) :
                            item.rarity.color.opacity(0.15),
                        lineWidth: isEquipped ? 2 : 1
                    )
            )

            // Name
            Text(item.name)
                .font(.system(size: 10, weight: .semibold))
                .foregroundColor(.white)
                .lineLimit(1)

            // Price or status
            if isOwned {
                Text(isEquipped ? "Equipped" : "Owned")
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(isEquipped ? Color(red: 0.2, green: 0.78, blue: 0.35) : .white.opacity(0.4))
            } else if isLocked {
                Text(eligibility.lockMessage ?? "Locked")
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(.white.opacity(0.3))
                    .lineLimit(1)
            } else {
                HStack(spacing: 2) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 6))
                        .foregroundColor(.yellow)
                    Text("\(item.price)")
                        .font(.system(size: 10, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.0))
                }
            }
        }
    }

    private var isLocked: Bool {
        switch eligibility {
        case .canBuy, .alreadyOwned, .insufficientCoins:
            return false
        default:
            return true
        }
    }

    @ViewBuilder
    private var lockBadge: some View {
        switch eligibility {
        case .requiresPremium:
            Image(systemName: "crown.fill")
                .font(.system(size: 16))
                .foregroundColor(.yellow.opacity(0.6))
        case .requiresPhase, .requiresStreak, .requiresSteps:
            Image(systemName: "lock.fill")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.3))
        case .notAvailable:
            Image(systemName: "clock.fill")
                .font(.system(size: 16))
                .foregroundColor(.white.opacity(0.3))
        default:
            EmptyView()
        }
    }
}
