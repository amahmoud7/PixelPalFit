import SwiftUI

struct EvolutionMilestoneCard: View {
    let data: ShareCardData
    let format: ShareCardFormat
    let background: ShareCardBackground
    var spriteFrame: Int = 1

    var body: some View {
        ZStack {
            ShareCardBackgroundView(background: background, format: format)

            GeometryReader { geo in
                ConfettiOverlay(size: geo.size)
            }

            VStack(spacing: 0) {
                Spacer().frame(height: format == .story ? 64 : 28)

                // Title
                Text("My Pixel Pal")
                    .font(.system(size: 15, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.9))

                Text("Just Evolved!")
                    .font(.system(size: format == .story ? 28 : 22, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Spacer().frame(height: format == .story ? 32 : 16)

                // Evolution sprites row
                HStack(spacing: format == .story ? 12 : 8) {
                    ForEach(1...4, id: \.self) { phase in
                        evolutionSprite(phase: phase)
                    }
                }

                Spacer().frame(height: format == .story ? 24 : 14)

                // Phase badge
                SharePhaseBadge(
                    phase: data.currentPhase,
                    name: data.phaseName,
                    color: data.phaseColor
                )

                Spacer().frame(height: format == .story ? 12 : 8)

                // Weekly steps
                Text("\(data.weeklySteps.formatted()) steps this week")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.6))

                Spacer().frame(height: format == .story ? 12 : 8)

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

    @ViewBuilder
    private func evolutionSprite(phase: Int) -> some View {
        let spriteState = spriteStateForPhase(phase)
        let isCurrent = phase == data.currentPhase
        let isReached = phase <= data.currentPhase
        let spriteSize: CGFloat = format == .story ? 64 : 48

        VStack(spacing: 3) {
            Image(SpriteAssets.spriteName(gender: data.gender, state: spriteState, frame: isCurrent ? spriteFrame : 1))
                .resizable()
                .interpolation(.none)
                .aspectRatio(contentMode: .fit)
                .frame(width: spriteSize, height: spriteSize)
                .opacity(isReached ? 1.0 : 0.45)
                .overlay(
                    isCurrent
                    ? RoundedRectangle(cornerRadius: 8)
                        .stroke(data.phaseColor, lineWidth: 2)
                        .padding(-4)
                    : nil
                )

            Text("\(phase)")
                .font(.system(size: 9, weight: .bold, design: .rounded))
                .foregroundColor(isReached ? data.phaseColor : .white.opacity(0.45))
        }
    }

    private func spriteStateForPhase(_ phase: Int) -> AvatarState {
        switch phase {
        case 1: return .low
        case 2: return .neutral
        case 3, 4: return .vital
        default: return .low
        }
    }
}
