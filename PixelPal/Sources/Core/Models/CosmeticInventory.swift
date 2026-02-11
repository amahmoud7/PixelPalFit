import Foundation

/// Player's owned cosmetic items and current equipment loadout.
struct CosmeticInventory: Codable {
    var ownedItemIDs: Set<String>
    var loadout: CosmeticLoadout
    var purchaseHistory: [CosmeticPurchase]

    static func createEmpty() -> CosmeticInventory {
        CosmeticInventory(
            ownedItemIDs: [],
            loadout: CosmeticLoadout(),
            purchaseHistory: []
        )
    }
}

/// Currently equipped cosmetic items (one per slot).
struct CosmeticLoadout: Codable, Equatable {
    var background: String?
    var hat: String?
    var accessory: String?
    var skin: String?

    /// Returns the equipped item ID for a given category.
    func equipped(for category: CosmeticCategory) -> String? {
        switch category {
        case .background: return background
        case .hat: return hat
        case .accessory: return accessory
        case .skin: return skin
        }
    }

    /// Sets the equipped item ID for a given category.
    mutating func equip(_ itemID: String?, for category: CosmeticCategory) {
        switch category {
        case .background: background = itemID
        case .hat: hat = itemID
        case .accessory: accessory = itemID
        case .skin: skin = itemID
        }
    }

    // Backward-compatible decoding
    enum CodingKeys: String, CodingKey {
        case background, hat, accessory, skin
    }

    init(background: String? = nil, hat: String? = nil, accessory: String? = nil, skin: String? = nil) {
        self.background = background
        self.hat = hat
        self.accessory = accessory
        self.skin = skin
    }

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        background = try container.decodeIfPresent(String.self, forKey: .background)
        hat = try container.decodeIfPresent(String.self, forKey: .hat)
        accessory = try container.decodeIfPresent(String.self, forKey: .accessory)
        skin = try container.decodeIfPresent(String.self, forKey: .skin)
    }
}

/// Records a single cosmetic purchase for history tracking.
struct CosmeticPurchase: Codable {
    let itemID: String
    let date: Date
    let price: Int
}
