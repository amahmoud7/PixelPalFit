import SwiftUI

/// Compact wardrobe row for the Profile tab showing equipped cosmetics with quick-swap.
struct WardrobeView: View {
    @EnvironmentObject var appState: AppStateManager
    @Binding var showShop: Bool

    private var cosmeticManager: CosmeticManager { appState.cosmeticManager }
    private var loadout: CosmeticLoadout { cosmeticManager.currentLoadout }

    var body: some View {
        VStack(spacing: 10) {
            // Header row
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "paintpalette.fill")
                        .font(.system(size: 13))
                        .foregroundColor(Color(red: 0.49, green: 0.36, blue: 0.99))
                    Text("Wardrobe")
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(.white)
                }

                Spacer()

                Button(action: { showShop = true }) {
                    HStack(spacing: 4) {
                        Text("Shop")
                            .font(.system(size: 11, weight: .semibold))
                        Image(systemName: "arrow.right")
                            .font(.system(size: 9, weight: .semibold))
                    }
                    .foregroundColor(Color(red: 0.49, green: 0.36, blue: 0.99))
                }
            }

            // Slot row
            HStack(spacing: 12) {
                slotView(category: .background)
                slotView(category: .hat)
                slotView(category: .accessory)
            }
        }
        .padding(14)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(Color.white.opacity(0.03))
                .overlay(
                    RoundedRectangle(cornerRadius: 14)
                        .stroke(Color(red: 0.49, green: 0.36, blue: 0.99).opacity(0.15), lineWidth: 1)
                )
        )
    }

    private func slotView(category: CosmeticCategory) -> some View {
        let equippedID = loadout.equipped(for: category)
        let equippedItem = equippedID.flatMap { CosmeticCatalog.item(id: $0) }
        let ownedItems = cosmeticManager.ownedItems(for: category)

        return Button(action: { cycleItem(category: category) }) {
            VStack(spacing: 4) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(equippedItem?.rarity.color.opacity(0.08) ?? Color.white.opacity(0.04))
                        .frame(width: 56, height: 56)

                    if let item = equippedItem {
                        Image(item.assetName)
                            .resizable()
                            .interpolation(.none)
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 36, height: 36)
                    } else {
                        Image(systemName: category.icon)
                            .font(.system(size: 18))
                            .foregroundColor(.white.opacity(0.15))
                    }
                }
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(
                            equippedItem?.rarity.color.opacity(0.3) ?? Color.white.opacity(0.06),
                            lineWidth: 1
                        )
                )

                Text(equippedItem?.name ?? category.displayName)
                    .font(.system(size: 8, weight: .medium))
                    .foregroundColor(.white.opacity(equippedItem != nil ? 0.6 : 0.25))
                    .lineLimit(1)

                // Ownership count
                if !ownedItems.isEmpty {
                    Text("\(ownedItems.count) owned")
                        .font(.system(size: 7, weight: .medium))
                        .foregroundColor(.white.opacity(0.2))
                }
            }
        }
        .buttonStyle(.plain)
        .frame(maxWidth: .infinity)
    }

    private func cycleItem(category: CosmeticCategory) {
        let owned = cosmeticManager.ownedItems(for: category)
        guard !owned.isEmpty else {
            showShop = true
            return
        }

        let currentID = loadout.equipped(for: category)

        if let currentID {
            guard let currentIndex = owned.firstIndex(where: { $0.id == currentID }) else {
                // Equipped item not in owned list — unequip
                cosmeticManager.unequip(category: category)
                return
            }
            let nextIndex = (currentIndex + 1) % (owned.count + 1)
            if nextIndex == owned.count {
                // Cycle back to "none"
                cosmeticManager.unequip(category: category)
            } else {
                cosmeticManager.equip(owned[nextIndex].id, category: category)
            }
        } else {
            // Nothing equipped — equip first owned item
            cosmeticManager.equip(owned[0].id, category: category)
        }

        let impact = UIImpactFeedbackGenerator(style: .light)
        impact.impactOccurred()
    }
}
