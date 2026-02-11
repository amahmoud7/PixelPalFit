import SwiftUI

/// Glass Dashboard streak display — ring + stats side-by-side, steps/missions grid below, at-risk banner.
struct StreakHeroView: View {
    let streak: Int
    let todaySteps: Int
    let dailyGoal: Int
    let missionsCompleted: Int
    let missionsTotal: Int

    private var progress: Double {
        min(Double(todaySteps) / Double(dailyGoal), 1.0)
    }

    private var isAtRisk: Bool {
        streak > 0 && todaySteps < dailyGoal
    }

    private var streakColor: Color {
        if streak == 0 { return .gray }
        if streak >= 30 { return Color(red: 1.0, green: 0.84, blue: 0.0) }
        if streak >= 7 { return Color(red: 1.0, green: 0.2, blue: 0.1) }
        return .orange
    }

    private var bestStreak: Int {
        PersistenceManager.shared.progressState.longestStreak
    }

    var body: some View {
        VStack(spacing: 10) {
            if streak == 0 {
                zeroStreakView
            } else {
                activeStreakView
            }
        }
    }

    // MARK: - Zero Streak

    private var zeroStreakView: some View {
        VStack(spacing: 12) {
            HStack(spacing: 16) {
                // Progress ring
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.06), lineWidth: 5)
                        .frame(width: 72, height: 72)

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(Color.blue, style: StrokeStyle(lineWidth: 5, lineCap: .round))
                        .frame(width: 72, height: 72)
                        .rotationEffect(.degrees(-90))

                    VStack(spacing: 1) {
                        Text("\(Int(progress * 100))%")
                            .font(.system(size: 18, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                }

                VStack(alignment: .leading, spacing: 4) {
                    Text("START YOUR STREAK")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.4))
                        .tracking(1)

                    Text("0 days")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    Text("\(max(0, dailyGoal - todaySteps).formatted()) steps to begin")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.blue.opacity(0.8))
                }

                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white.opacity(0.03))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                    )
            )
        }
    }

    // MARK: - Active Streak (Glass Dashboard)

    private var activeStreakView: some View {
        VStack(spacing: 10) {
            // Main glass card: ring + stats side-by-side
            HStack(spacing: 16) {
                // Streak ring
                ZStack {
                    Circle()
                        .stroke(Color.white.opacity(0.06), lineWidth: 5)
                        .frame(width: 76, height: 76)

                    Circle()
                        .trim(from: 0, to: progress)
                        .stroke(
                            LinearGradient(
                                colors: [streakColor, streakColor.opacity(0.7)],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            ),
                            style: StrokeStyle(lineWidth: 5, lineCap: .round)
                        )
                        .frame(width: 76, height: 76)
                        .rotationEffect(.degrees(-90))
                        .shadow(color: streakColor.opacity(0.3), radius: 6)

                    VStack(spacing: 1) {
                        Image(systemName: "flame.fill")
                            .font(.system(size: 12))
                            .foregroundColor(streakColor)

                        Text("\(streak)")
                            .font(.system(size: 22, weight: .black, design: .rounded))
                            .foregroundColor(.white)
                    }
                }

                // Stats column
                VStack(alignment: .leading, spacing: 4) {
                    Text("CURRENT STREAK")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.4))
                        .tracking(1)

                    Text("\(streak) days")
                        .font(.system(size: 20, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    // 7-day dots
                    weekDots

                    Text("Best: \(bestStreak) days")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(streakColor.opacity(0.8))
                }

                Spacer()
            }
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 18)
                    .fill(Color.white.opacity(0.03))
                    .overlay(
                        RoundedRectangle(cornerRadius: 18)
                            .stroke(Color.white.opacity(0.06), lineWidth: 1)
                    )
            )

            // 2-column grid: steps + missions
            HStack(spacing: 10) {
                // Steps mini card
                VStack(alignment: .leading, spacing: 4) {
                    Text("TODAY")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.white.opacity(0.4))
                        .tracking(0.5)

                    Text("\(todaySteps.formatted())")
                        .font(.system(size: 22, weight: .bold, design: .rounded))
                        .foregroundColor(.white)

                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.white.opacity(0.06))
                                .frame(height: 3)
                            RoundedRectangle(cornerRadius: 2)
                                .fill(
                                    LinearGradient(
                                        colors: [Color(red: 0.2, green: 0.78, blue: 0.35), Color(red: 0.19, green: 0.82, blue: 0.35)],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * progress, height: 3)
                        }
                    }
                    .frame(height: 3)

                    Text("\(Int(progress * 100))% of goal")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.white.opacity(0.3))
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white.opacity(0.03))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.06), lineWidth: 1)
                        )
                )

                // Missions mini card
                VStack(alignment: .leading, spacing: 4) {
                    Text("MISSIONS")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.white.opacity(0.4))
                        .tracking(0.5)

                    HStack(alignment: .firstTextBaseline, spacing: 1) {
                        Text("\(missionsCompleted)")
                            .font(.system(size: 22, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                        Text("/\(missionsTotal)")
                            .font(.system(size: 14, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.3))
                    }

                    HStack(spacing: 4) {
                        ForEach(0..<missionsTotal, id: \.self) { i in
                            RoundedRectangle(cornerRadius: 2)
                                .fill(i < missionsCompleted
                                    ? Color(red: 0.2, green: 0.78, blue: 0.35)
                                    : (i == missionsCompleted
                                        ? Color(red: 0.49, green: 0.36, blue: 0.99).opacity(0.4)
                                        : Color.white.opacity(0.06)))
                                .frame(height: 3)
                        }
                    }

                    let balance = PersistenceManager.shared.progressState.stepCoinBalance
                    Text("+\(balance) coins earned")
                        .font(.system(size: 9, weight: .medium))
                        .foregroundColor(.white.opacity(0.3))
                }
                .padding(14)
                .frame(maxWidth: .infinity, alignment: .leading)
                .background(
                    RoundedRectangle(cornerRadius: 14)
                        .fill(Color.white.opacity(0.03))
                        .overlay(
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.white.opacity(0.06), lineWidth: 1)
                        )
                )
            }

            // Streak at risk banner
            if isAtRisk {
                StreakAtRiskView(
                    stepsRemaining: dailyGoal - todaySteps,
                    streak: streak
                )
            }
        }
    }

    // MARK: - Week Dots

    private var weekDots: some View {
        let weekData = HistoryManager.shared.history.weekViewData()

        return HStack(spacing: 4) {
            ForEach(weekData) { day in
                Circle()
                    .fill(day.isToday && !day.isGoalMet
                        ? Color.orange.opacity(0.4)
                        : (day.isGoalMet ? Color(red: 0.2, green: 0.78, blue: 0.35) : Color.white.opacity(0.1)))
                    .frame(width: 6, height: 6)
                    .overlay(
                        day.isToday && !day.isGoalMet
                            ? Circle().stroke(Color.orange.opacity(0.6), lineWidth: 1)
                            : nil
                    )
            }
        }
    }
}

/// Streak-at-risk alert banner with time estimate.
struct StreakAtRiskView: View {
    let stepsRemaining: Int
    let streak: Int
    @State private var isPulsing = false

    private var walkMinutes: Int {
        max(5, stepsRemaining / 65) // ~65 steps per minute casual walk
    }

    var body: some View {
        HStack(spacing: 10) {
            Image(systemName: "exclamationmark.triangle.fill")
                .foregroundColor(.orange)
                .font(.system(size: 14))
                .scaleEffect(isPulsing ? 1.1 : 1.0)

            VStack(alignment: .leading, spacing: 2) {
                Text("Streak at risk")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundColor(.orange)

                Text("\(stepsRemaining.formatted()) steps to save it — ~\(walkMinutes) min walk")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.orange.opacity(0.7))
            }

            Spacer()
        }
        .padding(.horizontal, 14)
        .padding(.vertical, 10)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.orange.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.orange.opacity(0.2), lineWidth: 1)
                )
        )
        .onAppear {
            withAnimation(.easeInOut(duration: 1.0).repeatForever(autoreverses: true)) {
                isPulsing = true
            }
        }
    }
}
