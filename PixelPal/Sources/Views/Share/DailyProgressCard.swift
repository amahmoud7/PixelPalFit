import SwiftUI

struct DailyProgressCard: View {
    let data: ShareCardData
    let format: ShareCardFormat
    let background: ShareCardBackground
    var spriteFrame: Int = 1

    private var progressPercent: Int {
        Int(data.dailyProgress * 100)
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

                Spacer().frame(height: format == .story ? 24 : 12)

                // Avatar with glow
                ShareAvatarView(
                    gender: data.gender,
                    state: data.avatarState,
                    phase: data.currentPhase,
                    spriteFrame: spriteFrame,
                    size: format == .story ? 140 : 100
                )

                // State badge
                ShareStateBadge(state: data.avatarState, color: data.stateColor)
                    .padding(.top, format == .story ? 4 : 2)

                Spacer().frame(height: format == .story ? 16 : 8)

                // Step count
                Text("\(data.todaySteps.formatted())")
                    .font(.system(size: format == .story ? 36 : 28, weight: .bold, design: .rounded))
                    .foregroundColor(.white)
                    .monospacedDigit()

                Text("steps today")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.75))

                Spacer().frame(height: format == .story ? 16 : 10)

                // Progress bar (widget style)
                VStack(spacing: 4) {
                    ShareProgressBar(
                        progress: data.dailyProgress,
                        stateColor: data.stateColor,
                        phaseColor: data.phaseColor
                    )

                    HStack {
                        Text("\(progressPercent)%")
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                        Spacer()
                        Text("\(data.todaySteps.formatted()) / \(ShareCardData.dailyGoal.formatted())")
                            .font(.system(size: 9, weight: .medium, design: .rounded))
                            .foregroundColor(.white.opacity(0.7))
                    }
                }
                .padding(.horizontal, 24)

                Spacer().frame(height: format == .story ? 16 : 8)

                // Bar chart (widget style colors)
                if !data.weekDays.isEmpty {
                    ShareBarChartView(
                        days: data.weekDays,
                        barHeight: format == .story ? 80 : 44
                    )
                    .padding(.horizontal, 24)
                }

                Spacer().frame(height: format == .story ? 8 : 4)

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
