import SwiftUI

/// Streak-specific share card: flame + streak number + 7-day calendar dots.
struct StreakShareCard: View {
    let data: ShareCardData
    let format: ShareCardFormat
    let background: ShareCardBackground
    var spriteFrame: Int = 1

    private var streak: Int {
        PersistenceManager.shared.progressState.currentStreak
    }

    private var streakColor: Color {
        if streak >= 30 { return Color(red: 1.0, green: 0.84, blue: 0.0) }
        if streak >= 7 { return Color(red: 1.0, green: 0.2, blue: 0.1) }
        return .orange
    }

    var body: some View {
        ZStack {
            ShareCardBackgroundView(background: background, format: format)

            VStack(spacing: 0) {
                Spacer().frame(height: format == .story ? 80 : 40)

                // Flame
                Image(systemName: "flame.fill")
                    .font(.system(size: format == .story ? 64 : 48))
                    .foregroundColor(streakColor)
                    .shadow(color: streakColor.opacity(0.5), radius: 12)

                Spacer().frame(height: format == .story ? 20 : 12)

                // Streak number
                Text("\(streak)")
                    .font(.system(size: format == .story ? 72 : 56, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Text("day streak")
                    .font(.system(size: format == .story ? 18 : 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.7))

                Spacer().frame(height: format == .story ? 32 : 20)

                // 7-day dots
                if !data.weekDays.isEmpty {
                    VStack(spacing: 6) {
                        ShareWeekDots(days: data.weekDays)

                        // Day labels
                        HStack(spacing: 5) {
                            ForEach(data.weekDays) { day in
                                Text(dayLabel(for: day.date))
                                    .font(.system(size: 8, weight: .medium, design: .rounded))
                                    .foregroundColor(.white.opacity(0.5))
                                    .frame(width: 8)
                            }
                        }
                    }
                }

                Spacer().frame(height: format == .story ? 20 : 12)

                // Avatar
                ShareAvatarView(
                    gender: data.gender,
                    state: data.avatarState,
                    phase: data.currentPhase,
                    spriteFrame: spriteFrame,
                    size: format == .story ? 100 : 72
                )

                Spacer()

                WatermarkView()
            }
            .shadow(color: background == .transparent ? .black.opacity(0.9) : .clear, radius: 4)
        }
        .frame(width: format.pointSize.width, height: format.pointSize.height)
    }

    private func dayLabel(for date: Date) -> String {
        let formatter = DateFormatter()
        formatter.dateFormat = "EEE"
        return String(formatter.string(from: date).prefix(1))
    }
}
