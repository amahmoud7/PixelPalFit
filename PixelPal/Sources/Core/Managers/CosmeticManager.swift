import Foundation
import WidgetKit

/// Manages cosmetic inventory, purchases, equipping, and widget sync.
@MainActor
class CosmeticManager: ObservableObject {
    @Published var inventory: CosmeticInventory

    init() {
        self.inventory = PersistenceManager.shared.cosmeticInventory
    }

    // MARK: - Purchase Eligibility

    func canPurchase(
        _ item: CosmeticItem,
        balance: Int,
        isPremium: Bool,
        phase: Int,
        streak: Int,
        totalSteps: Int
    ) -> PurchaseEligibility {
        if inventory.ownedItemIDs.contains(item.id) {
            return .alreadyOwned
        }
        if item.requiresPremium && !isPremium {
            return .requiresPremium
        }
        if item.requiredPhase > phase {
            return .requiresPhase(item.requiredPhase)
        }
        if item.requiredStreak > streak {
            return .requiresStreak(item.requiredStreak)
        }
        if item.requiredTotalSteps > totalSteps {
            return .requiresSteps(item.requiredTotalSteps)
        }
        if item.isLimited, !CosmeticCatalog.currentSeasonalItems().contains(where: { $0.id == item.id }) {
            // Limited items that aren't party hat (always available) check season
            if item.availableFrom != nil || item.availableTo != nil {
                return .notAvailable
            }
        }
        if balance < item.price {
            return .insufficientCoins(need: item.price - balance)
        }
        return .canBuy
    }

    // MARK: - Purchase

    /// Purchases a cosmetic item. Returns true on success.
    func purchase(_ item: CosmeticItem) -> Bool {
        let balance = PersistenceManager.shared.progressState.stepCoinBalance
        let isPremium = PersistenceManager.shared.entitlements.isPremium
        let progress = PersistenceManager.shared.progressState

        let eligibility = canPurchase(
            item,
            balance: balance,
            isPremium: isPremium,
            phase: progress.currentPhase,
            streak: progress.currentStreak,
            totalSteps: progress.totalStepsSinceStart
        )

        guard case .canBuy = eligibility else { return false }

        // Deduct coins
        PersistenceManager.shared.updateProgress { state in
            state.stepCoinBalance -= item.price
        }

        // Add to inventory
        PersistenceManager.shared.updateCosmetics { inv in
            inv.ownedItemIDs.insert(item.id)
            inv.purchaseHistory.append(
                CosmeticPurchase(itemID: item.id, date: Date(), price: item.price)
            )
        }

        inventory = PersistenceManager.shared.cosmeticInventory
        return true
    }

    // MARK: - Equip / Unequip

    func equip(_ itemID: String, category: CosmeticCategory) {
        PersistenceManager.shared.updateCosmetics { inv in
            inv.loadout.equip(itemID, for: category)
        }
        inventory = PersistenceManager.shared.cosmeticInventory
        syncToWidget()
    }

    func unequip(category: CosmeticCategory) {
        PersistenceManager.shared.updateCosmetics { inv in
            inv.loadout.equip(nil, for: category)
        }
        inventory = PersistenceManager.shared.cosmeticInventory
        syncToWidget()
    }

    var currentLoadout: CosmeticLoadout {
        inventory.loadout
    }

    /// Returns owned items for a given category.
    func ownedItems(for category: CosmeticCategory) -> [CosmeticItem] {
        CosmeticCatalog.items(for: category).filter { inventory.ownedItemIDs.contains($0.id) }
    }

    // MARK: - Widget Sync

    func syncToWidget() {
        let loadout = inventory.loadout

        // Resolve item IDs to asset names for the widget
        let bgAsset = loadout.background.flatMap { CosmeticCatalog.item(id: $0)?.assetName }
        let hatAsset = loadout.hat.flatMap { CosmeticCatalog.item(id: $0)?.assetName }
        let accAsset = loadout.accessory.flatMap { CosmeticCatalog.item(id: $0)?.assetName }
        let skinAsset = loadout.skin.flatMap { CosmeticCatalog.item(id: $0)?.assetName }

        SharedData.saveEquippedCosmetics(background: bgAsset, hat: hatAsset, accessory: accAsset, skin: skinAsset)
    }
}

// MARK: - Purchase Eligibility

enum PurchaseEligibility: Equatable {
    case canBuy
    case insufficientCoins(need: Int)
    case requiresPremium
    case requiresPhase(Int)
    case requiresStreak(Int)
    case requiresSteps(Int)
    case notAvailable
    case alreadyOwned

    var lockMessage: String? {
        switch self {
        case .canBuy, .alreadyOwned:
            return nil
        case .insufficientCoins(let need):
            return "Need \(need) more coins"
        case .requiresPremium:
            return "Premium required"
        case .requiresPhase(let phase):
            return "Reach Phase \(phase)"
        case .requiresStreak(let days):
            return "\(days)-day streak needed"
        case .requiresSteps(let steps):
            return "\(steps.formatted()) total steps needed"
        case .notAvailable:
            return "Not available right now"
        }
    }
}
