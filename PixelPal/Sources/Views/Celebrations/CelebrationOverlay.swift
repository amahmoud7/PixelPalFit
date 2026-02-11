import SwiftUI

/// Spotlight Stage celebration — dark stage, golden spotlight, sparkles, "Milestone Unlocked" badge, gold CTA.
struct CelebrationOverlay: View {
    let event: CelebrationEvent
    let onDismiss: () -> Void
    let onShare: () -> Void

    @State private var isShowing = false
    @State private var spotlightScale: CGFloat = 0.3
    @State private var autoDismissTask: Task<Void, Never>?

    private var accentColor: Color {
        switch event {
        case .streakMilestone: return Color(red: 1.0, green: 0.6, blue: 0.0)
        case .phaseEvolution: return Color(red: 0.49, green: 0.36, blue: 0.99)
        case .dailyGoalMet: return Color(red: 0.2, green: 0.78, blue: 0.35)
        case .personalRecord: return Color(red: 1.0, green: 0.84, blue: 0.0)
        case .stepMilestone: return Color(red: 0.0, green: 0.48, blue: 1.0)
        }
    }

    private var coinReward: Int {
        switch event {
        case .streakMilestone(let days):
            return days >= 100 ? 500 : days >= 30 ? 300 : 100
        case .phaseEvolution: return 250
        case .dailyGoalMet: return 25
        case .personalRecord: return 150
        case .stepMilestone(let cumulative):
            return cumulative >= 100_000 ? 500 : cumulative >= 50_000 ? 300 : 100
        }
    }

    var body: some View {
        ZStack {
            // Pure black background
            Color(red: 0.02, green: 0.02, blue: 0.03)
                .ignoresSafeArea()
                .onTapGesture { dismiss() }

            // Spotlight glow layers
            Circle()
                .fill(
                    RadialGradient(
                        colors: [accentColor.opacity(0.12), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 200
                    )
                )
                .frame(width: 400, height: 400)
                .offset(y: -60)
                .scaleEffect(spotlightScale)

            Circle()
                .fill(
                    RadialGradient(
                        colors: [Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.08), .clear],
                        center: .center,
                        startRadius: 0,
                        endRadius: 140
                    )
                )
                .frame(width: 280, height: 280)
                .offset(y: -60)
                .scaleEffect(spotlightScale)

            // Sparkle particles
            SparkleParticleView(accentColor: accentColor)
                .ignoresSafeArea()

            // Content
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 80)

                // "Milestone Unlocked" badge
                Text("MILESTONE UNLOCKED")
                    .font(.system(size: 11, weight: .semibold))
                    .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.0))
                    .tracking(1)
                    .padding(.horizontal, 16)
                    .padding(.vertical, 7)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .fill(Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.12))
                            .overlay(
                                RoundedRectangle(cornerRadius: 10)
                                    .stroke(Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.3), lineWidth: 1)
                            )
                    )
                    .opacity(isShowing ? 1 : 0)
                    .offset(y: isShowing ? 0 : 10)

                Spacer()
                    .frame(height: 24)

                // Achievement icon
                achievementIcon
                    .scaleEffect(isShowing ? 1.0 : 0.5)
                    .opacity(isShowing ? 1.0 : 0)

                Spacer()
                    .frame(height: 24)

                // Category label
                Text(eventCategory)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.4))
                    .tracking(3)
                    .textCase(.uppercase)
                    .opacity(isShowing ? 1 : 0)

                // Title
                Text(event.title)
                    .font(.system(size: 44, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 24)
                    .opacity(isShowing ? 1 : 0)
                    .offset(y: isShowing ? 0 : 15)

                Spacer()
                    .frame(height: 12)

                // Subtitle
                Text(event.subtitle)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.5))
                    .multilineTextAlignment(.center)
                    .padding(.horizontal, 32)
                    .lineSpacing(3)
                    .opacity(isShowing ? 1 : 0)

                Spacer()
                    .frame(height: 20)

                // Coin reward pill
                HStack(spacing: 6) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 12))
                        .foregroundColor(.yellow)
                    Text("+\(coinReward) coins earned")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.0))
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 7)
                .background(
                    Capsule()
                        .fill(Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.08))
                        .overlay(
                            Capsule()
                                .stroke(Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.15), lineWidth: 1)
                        )
                )
                .opacity(isShowing ? 1 : 0)

                Spacer()

                // Share CTA — gold gradient
                Button(action: {
                    let impact = UIImpactFeedbackGenerator(style: .medium)
                    impact.impactOccurred()
                    onShare()
                }) {
                    Text("Share Achievement")
                        .font(.system(size: 15, weight: .bold))
                        .foregroundColor(.black)
                        .padding(.vertical, 14)
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 1.0, green: 0.84, blue: 0.0),
                                    Color(red: 1.0, green: 0.6, blue: 0.0)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(12)
                        .shadow(color: Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.2), radius: 12, y: 4)
                }
                .padding(.horizontal, 40)
                .opacity(isShowing ? 1 : 0)

                // Dismiss hint
                Button(action: dismiss) {
                    Text("Tap to dismiss")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.white.opacity(0.2))
                }
                .padding(.top, 14)
                .padding(.bottom, 44)
            }
        }
        .onAppear {
            let notification = UINotificationFeedbackGenerator()
            notification.notificationOccurred(.success)

            withAnimation(.spring(response: 0.8, dampingFraction: 0.7)) {
                isShowing = true
            }
            withAnimation(.easeOut(duration: 1.2)) {
                spotlightScale = 1.0
            }

            autoDismissTask = Task {
                try? await Task.sleep(nanoseconds: 5_000_000_000)
                guard !Task.isCancelled else { return }
                await MainActor.run { dismiss() }
            }
        }
        .onDisappear {
            autoDismissTask?.cancel()
        }
    }

    private func dismiss() {
        autoDismissTask?.cancel()
        withAnimation(.easeOut(duration: 0.3)) {
            isShowing = false
            spotlightScale = 0.3
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            onDismiss()
        }
    }

    // MARK: - Achievement Icon

    @ViewBuilder
    private var achievementIcon: some View {
        let iconConfig: (name: String, color: Color) = {
            switch event {
            case .streakMilestone: return ("flame.fill", .orange)
            case .phaseEvolution: return ("sparkles", Color(red: 0.49, green: 0.36, blue: 0.99))
            case .dailyGoalMet: return ("checkmark.circle.fill", Color(red: 0.2, green: 0.78, blue: 0.35))
            case .personalRecord: return ("trophy.fill", Color(red: 1.0, green: 0.84, blue: 0.0))
            case .stepMilestone: return ("figure.walk", Color(red: 0.0, green: 0.48, blue: 1.0))
            }
        }()

        ZStack {
            Circle()
                .fill(iconConfig.color.opacity(0.1))
                .frame(width: 96, height: 96)

            Circle()
                .stroke(iconConfig.color.opacity(0.3), lineWidth: 2)
                .frame(width: 96, height: 96)

            Image(systemName: iconConfig.name)
                .font(.system(size: 40))
                .foregroundColor(iconConfig.color)
                .shadow(color: iconConfig.color.opacity(0.5), radius: 12)
        }
    }

    private var eventCategory: String {
        switch event {
        case .streakMilestone: return "Streak"
        case .phaseEvolution: return "Evolution"
        case .dailyGoalMet: return "Daily Goal"
        case .personalRecord: return "Personal Record"
        case .stepMilestone: return "Milestone"
        }
    }
}
