import SwiftUI

/// Stats tab: Week memory + personal records + phase progress + 30-day calendar heatmap.
struct StatsView: View {
    @EnvironmentObject var appState: AppStateManager

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                Text("Stats")
                    .font(.title2)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                    .frame(maxWidth: .infinity, alignment: .leading)
                    .padding(.horizontal, 20)
                    .padding(.top, 16)

                // Week memory
                WeekMemorySection()
                    .padding(.horizontal, 20)

                // Personal records
                PersonalRecordsView()
                    .padding(.horizontal, 20)

                // Phase progress
                PhaseProgressCard(
                    weeklySteps: appState.weeklySteps,
                    currentPhase: appState.currentPhase,
                    isPremium: appState.storeManager.isPremium
                )
                .padding(.horizontal, 20)

                // 30-day calendar heatmap
                MonthCalendarView()
                    .padding(.horizontal, 20)

                Spacer().frame(height: 100)
            }
        }
    }
}

// MARK: - Phase Progress Card

private struct PhaseProgressCard: View {
    let weeklySteps: Int
    let currentPhase: Int
    let isPremium: Bool

    private var nextThreshold: Int {
        PhaseCalculator.nextThreshold(for: currentPhase)
    }

    private var progress: Double {
        PhaseCalculator.weeklyProgress(weeklySteps: weeklySteps, currentPhase: currentPhase)
    }

    private var progressColor: Color {
        switch currentPhase {
        case 1: return .gray
        case 2: return .blue
        case 3: return .purple
        case 4: return .orange
        default: return .gray
        }
    }

    private var phaseName: String {
        switch currentPhase {
        case 1: return "Seedling"
        case 2: return "Growing"
        case 3: return "Thriving"
        case 4: return "Legendary"
        default: return ""
        }
    }

    private var nextPhaseName: String {
        switch currentPhase {
        case 1: return "Growing"
        case 2: return "Thriving"
        case 3: return "Legendary"
        default: return ""
        }
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Phase Progress")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
                Text("Phase \(currentPhase) · \(phaseName)")
                    .font(.caption)
                    .fontWeight(.semibold)
                    .foregroundColor(progressColor)
            }

            if currentPhase < 4 {
                // Step count display
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(weeklySteps.formatted())
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("/ \(nextThreshold.formatted()) steps")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.4))
                    Spacer()
                    Text("\(Int(progress * 100))%")
                        .font(.system(size: 14, weight: .bold, design: .rounded))
                        .foregroundColor(progressColor)
                }

                // Progress bar
                GeometryReader { geometry in
                    ZStack(alignment: .leading) {
                        RoundedRectangle(cornerRadius: 4)
                            .fill(Color.white.opacity(0.1))
                            .frame(height: 8)

                        RoundedRectangle(cornerRadius: 4)
                            .fill(
                                LinearGradient(
                                    colors: [progressColor, progressColor.opacity(0.7)],
                                    startPoint: .leading,
                                    endPoint: .trailing
                                )
                            )
                            .frame(width: geometry.size.width * progress, height: 8)
                            .shadow(color: progressColor.opacity(0.3), radius: 4)
                    }
                }
                .frame(height: 8)

                if currentPhase >= 2 && !isPremium {
                    Text("Unlock Premium for Phase \(currentPhase + 1)")
                        .font(.caption2)
                        .foregroundColor(.purple.opacity(0.8))
                } else {
                    let remaining = max(0, nextThreshold - weeklySteps)
                    Text("\(remaining.formatted()) steps to \(nextPhaseName) · resets weekly")
                        .font(.caption2)
                        .foregroundColor(.white.opacity(0.35))
                }
            } else {
                HStack(alignment: .firstTextBaseline, spacing: 2) {
                    Text(weeklySteps.formatted())
                        .font(.system(size: 24, weight: .bold, design: .rounded))
                        .foregroundColor(.white)
                    Text("steps this week")
                        .font(.system(size: 14, weight: .medium, design: .rounded))
                        .foregroundColor(.white.opacity(0.4))
                    Spacer()
                }

                GeometryReader { geometry in
                    RoundedRectangle(cornerRadius: 4)
                        .fill(progressColor)
                        .frame(height: 8)
                        .shadow(color: progressColor.opacity(0.3), radius: 4)
                }
                .frame(height: 8)

                Text("Maximum evolution reached!")
                    .font(.caption2)
                    .foregroundColor(.orange.opacity(0.8))
            }
        }
        .glassCard()
    }
}
