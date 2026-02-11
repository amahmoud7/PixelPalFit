import SwiftUI

struct WeeklySummaryCard: View {
    let data: ShareCardData
    let format: ShareCardFormat
    let background: ShareCardBackground
    var spriteFrame: Int = 1

    private var dailyAverage: Int {
        guard !data.weekDays.isEmpty else { return 0 }
        let daysWithData = data.weekDays.filter { $0.hasData }
        guard !daysWithData.isEmpty else { return 0 }
        return daysWithData.map(\.steps).reduce(0, +) / daysWithData.count
    }

    private var weeklyPercent: Int {
        Int(data.weeklyProgress * 100)
    }

    var body: some View {
        ZStack {
            ShareCardBackgroundView(background: background, format: format)

            VStack(spacing: 0) {
                Spacer().frame(height: format == .story ? 48 : 20)

                // Phase badge
                SharePhaseBadge(
                    phase: data.currentPhase,
                    name: data.phaseName,
                    color: data.phaseColor
                )

                Spacer().frame(height: format == .story ? 16 : 8)

                // Avatar (smaller)
                ShareAvatarView(
                    gender: data.gender,
                    state: data.avatarState,
                    phase: data.currentPhase,
                    spriteFrame: spriteFrame,
                    size: format == .story ? 100 : 72
                )

                Spacer().frame(height: format == .story ? 4 : 2)

                // Weekly header
                Text("Weekly Recap")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Spacer().frame(height: format == .story ? 8 : 4)

                // Weekly total
                Text("\(data.weeklySteps.formatted())")
                    .font(.system(size: format == .story ? 36 : 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .monospacedDigit()

                Text("steps this week")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.white)

                Spacer().frame(height: format == .story ? 14 : 8)

                // Progress bar toward next phase
                VStack(spacing: 4) {
                    ShareProgressBar(
                        progress: data.weeklyProgress,
                        stateColor: data.stateColor,
                        phaseColor: data.phaseColor
                    )

                    HStack {
                        Text("\(weeklyPercent)%")
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                        Spacer()
                        Text("\(data.weeklySteps.formatted()) / \(data.weeklyPhaseThreshold.formatted())")
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundColor(.white)
                    }
                }
                .padding(.horizontal, 24)

                Spacer().frame(height: format == .story ? 14 : 8)

                // Bar chart (prominent)
                if !data.weekDays.isEmpty {
                    ShareBarChartView(
                        days: data.weekDays,
                        barHeight: format == .story ? 90 : 50
                    )
                    .padding(.horizontal, 24)
                }

                Spacer().frame(height: format == .story ? 6 : 4)

                // Daily average
                Text("\(dailyAverage.formatted()) avg/day")
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundColor(.white)

                Spacer().frame(height: format == .story ? 6 : 4)

                // Week dots
                if !data.weekDays.isEmpty {
                    ShareWeekDots(days: data.weekDays)
                }

                Spacer()

                WatermarkView()
            }
            .shadow(color: background == .transparent ? .black.opacity(0.9) : .clear, radius: 4)
        }
        .frame(width: format.pointSize.width, height: format.pointSize.height)
    }
}
