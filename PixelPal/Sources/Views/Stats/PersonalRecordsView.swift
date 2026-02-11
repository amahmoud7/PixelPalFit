import SwiftUI

/// Grid of personal bests: best day, longest streak, total steps, active days.
struct PersonalRecordsView: View {
    private var progress: ProgressState {
        PersistenceManager.shared.progressState
    }

    var body: some View {
        VStack(spacing: 12) {
            HStack {
                Text("Personal Records")
                    .font(.headline)
                    .foregroundColor(.white)
                Spacer()
            }

            LazyVGrid(columns: [
                GridItem(.flexible(), spacing: 12),
                GridItem(.flexible(), spacing: 12)
            ], spacing: 12) {
                recordCard(
                    icon: "trophy.fill",
                    color: .yellow,
                    value: progress.bestDaySteps > 0 ? "\(progress.bestDaySteps.formatted())" : "--",
                    label: "Best Day",
                    subtitle: bestDaySubtitle
                )

                recordCard(
                    icon: "flame.fill",
                    color: .orange,
                    value: "\(progress.longestStreak)",
                    label: "Longest Streak",
                    subtitle: progress.longestStreak > 0 ? "\(progress.longestStreak) days" : "Start walking!"
                )

                recordCard(
                    icon: "figure.walk",
                    color: .green,
                    value: formatLargeNumber(progress.totalStepsSinceStart),
                    label: "Total Steps",
                    subtitle: "All time"
                )

                recordCard(
                    icon: "calendar",
                    color: .blue,
                    value: "\(progress.totalActiveDays)",
                    label: "Active Days",
                    subtitle: "Goals met"
                )
            }
        }
        .glassCard()
    }

    private var bestDaySubtitle: String {
        guard let date = progress.bestDayDate else { return "No data yet" }
        let formatter = DateFormatter()
        formatter.dateFormat = "MMM d"
        return formatter.string(from: date)
    }

    private func formatLargeNumber(_ number: Int) -> String {
        if number >= 1_000_000 {
            return String(format: "%.1fM", Double(number) / 1_000_000)
        } else if number >= 1_000 {
            return String(format: "%.1fK", Double(number) / 1_000)
        }
        return "\(number)"
    }

    @ViewBuilder
    private func recordCard(icon: String, color: Color, value: String, label: String, subtitle: String) -> some View {
        VStack(spacing: 6) {
            Image(systemName: icon)
                .font(.system(size: 20))
                .foregroundColor(color)

            Text(value)
                .font(.system(size: 22, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .monospacedDigit()

            Text(label)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.white.opacity(0.8))

            Text(subtitle)
                .font(.caption2)
                .foregroundColor(.gray)
        }
        .frame(maxWidth: .infinity)
        .padding(.vertical, 12)
        .background(Color.white.opacity(0.05))
        .cornerRadius(12)
    }
}
