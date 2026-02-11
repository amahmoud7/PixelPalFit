import SwiftUI

/// A cosmetic item that can be purchased and equipped on the avatar.
struct CosmeticItem: Codable, Identifiable, Hashable {
    let id: String
    let name: String
    let category: CosmeticCategory
    let rarity: CosmeticRarity
    let price: Int
    let assetName: String
    let requiresPremium: Bool
    let requiredPhase: Int
    let requiredStreak: Int
    let requiredTotalSteps: Int
    let isLimited: Bool
    let availableFrom: Date?
    let availableTo: Date?
}

enum CosmeticCategory: String, Codable, CaseIterable {
    case background, hat, accessory, skin

    var displayName: String {
        switch self {
        case .background: return "Backgrounds"
        case .hat: return "Hats"
        case .accessory: return "Accessories"
        case .skin: return "Skins"
        }
    }

    var icon: String {
        switch self {
        case .background: return "circle.hexagongrid.fill"
        case .hat: return "crown"
        case .accessory: return "sparkle"
        case .skin: return "person.fill"
        }
    }
}

enum CosmeticRarity: String, Codable, CaseIterable {
    case common, uncommon, rare, epic, legendary, seasonal

    var displayName: String { rawValue.capitalized }

    var color: Color {
        switch self {
        case .common: return Color(white: 0.6)
        case .uncommon: return Color(red: 0.2, green: 0.78, blue: 0.35)
        case .rare: return Color(red: 0.35, green: 0.55, blue: 1.0)
        case .epic: return Color(red: 0.6, green: 0.35, blue: 1.0)
        case .legendary: return Color(red: 1.0, green: 0.6, blue: 0.0)
        case .seasonal: return Color(red: 1.0, green: 0.4, blue: 0.6)
        }
    }
}
