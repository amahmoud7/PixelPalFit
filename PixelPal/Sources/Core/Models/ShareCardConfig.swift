import SwiftUI

// MARK: - Share Card Type

enum ShareCardType: String, CaseIterable {
    case dailyProgress
    case evolutionMilestone
    case weeklySummary

    var title: String {
        switch self {
        case .dailyProgress: return "Daily"
        case .evolutionMilestone: return "Evolution"
        case .weeklySummary: return "Weekly"
        }
    }

    var icon: String {
        switch self {
        case .dailyProgress: return "figure.walk"
        case .evolutionMilestone: return "sparkles"
        case .weeklySummary: return "chart.bar.fill"
        }
    }
}

// MARK: - Share Card Format

enum ShareCardFormat: String, CaseIterable {
    case story
    case square

    var title: String {
        switch self {
        case .story: return "Story"
        case .square: return "Square"
        }
    }

    /// Render size in points (rendered at 3x for crisp output)
    var pointSize: CGSize {
        switch self {
        case .story: return CGSize(width: 360, height: 640)
        case .square: return CGSize(width: 360, height: 360)
        }
    }

    /// Pixel size at 3x scale for export
    var pixelSize: CGSize {
        switch self {
        case .story: return CGSize(width: 1080, height: 1920)
        case .square: return CGSize(width: 1080, height: 1080)
        }
    }
}

// MARK: - Share Card Background

enum ShareCardBackground: String, CaseIterable {
    case darkGlow
    case sunset
    case ocean
    case retro
    case transparent

    var title: String {
        switch self {
        case .darkGlow: return "Dark"
        case .sunset: return "Sunset"
        case .ocean: return "Ocean"
        case .retro: return "Retro"
        case .transparent: return "Clear"
        }
    }

    var isTransparent: Bool { self == .transparent }
}

// MARK: - Share Card Data

struct ShareCardData {
    let todaySteps: Int
    let weeklySteps: Int
    let avatarState: AvatarState
    let gender: Gender
    let currentPhase: Int
    let isPremium: Bool
    let weekDays: [DailyHistory.DayViewData]

    static let dailyGoal = 7500

    var phaseName: String {
        switch currentPhase {
        case 1: return "Seedling"
        case 2: return "Growing"
        case 3: return "Thriving"
        case 4: return "Legendary"
        default: return "Unknown"
        }
    }

    var phaseColor: Color {
        switch currentPhase {
        case 1: return .gray
        case 2: return .blue
        case 3: return .purple
        case 4: return .orange
        default: return .gray
        }
    }

    var stateColor: Color {
        switch avatarState {
        case .vital: return Color(hex: "#34C759")
        case .neutral: return Color(red: 0.35, green: 0.78, blue: 0.98)
        case .low: return .orange
        }
    }

    var dailyProgress: Double {
        min(Double(todaySteps) / Double(Self.dailyGoal), 1.0)
    }

    var weeklyPhaseThreshold: Int {
        PhaseCalculator.nextThreshold(for: currentPhase)
    }

    var weeklyProgress: Double {
        PhaseCalculator.weeklyProgress(weeklySteps: weeklySteps, currentPhase: currentPhase)
    }
}
