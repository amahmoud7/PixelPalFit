import Foundation

/// Premium-only weekly challenge with larger goals and coin rewards.
struct WeeklyChallenge: Codable, Identifiable, Equatable {
    let id: String
    let title: String
    let description: String
    let target: Int
    var progress: Int
    let coinReward: Int
    let weekString: String  // e.g. "2026-W06"
    let type: WeeklyChallengeType

    var isCompleted: Bool {
        progress >= target
    }

    var progressFraction: Double {
        guard target > 0 else { return 0 }
        return min(Double(progress) / Double(target), 1.0)
    }

    static func == (lhs: WeeklyChallenge, rhs: WeeklyChallenge) -> Bool {
        lhs.id == rhs.id && lhs.progress == rhs.progress
    }
}

enum WeeklyChallengeType: String, Codable, CaseIterable {
    case totalSteps       // Walk X total steps this week
    case activeDays       // Meet your daily goal X days this week
    case streakWeek       // Maintain a streak all 7 days
    case bigDay           // Hit 10,000+ steps in a single day
    case consistentWeek   // Walk 5,000+ steps every day this week

    var icon: String {
        switch self {
        case .totalSteps: return "figure.walk.motion"
        case .activeDays: return "checkmark.seal.fill"
        case .streakWeek: return "flame.fill"
        case .bigDay: return "star.fill"
        case .consistentWeek: return "chart.bar.fill"
        }
    }
}

/// Persisted weekly challenge state.
struct WeeklyChallengeState: Codable {
    var challenge: WeeklyChallenge
    var weekString: String
}
