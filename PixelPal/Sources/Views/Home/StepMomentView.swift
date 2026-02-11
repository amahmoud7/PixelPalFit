import SwiftUI

/// Time Freeze Step Moment — clock-centered, ambient rings, purple CTA, meditative layout.
struct StepMomentView: View {
    @EnvironmentObject var appState: AppStateManager
    @EnvironmentObject var healthManager: HealthKitManager
    @State private var isShowing = false
    @State private var ringScale: CGFloat = 0.8

    private var progress: Double {
        min(Double(healthManager.currentSteps) / 7500.0, 1.0)
    }

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.04, green: 0.02, blue: 0.06),
                    Color(red: 0.08, green: 0.03, blue: 0.12),
                    Color(red: 0.04, green: 0.02, blue: 0.06)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Ambient clock rings
            Circle()
                .stroke(Color(red: 0.49, green: 0.36, blue: 0.99).opacity(0.06), lineWidth: 1)
                .frame(width: 280, height: 280)
                .scaleEffect(ringScale)
                .offset(y: -30)

            Circle()
                .stroke(Color(red: 0.49, green: 0.36, blue: 0.99).opacity(0.04), lineWidth: 1)
                .frame(width: 220, height: 220)
                .scaleEffect(ringScale)
                .offset(y: -30)

            Circle()
                .stroke(Color(red: 0.49, green: 0.36, blue: 0.99).opacity(0.02), lineWidth: 1)
                .frame(width: 340, height: 340)
                .scaleEffect(ringScale)
                .offset(y: -30)

            // Content
            VStack(spacing: 0) {
                Spacer()
                    .frame(height: 80)

                // Time display
                Text(Date(), style: .time)
                    .font(.system(size: 56, weight: .ultraLight, design: .rounded))
                    .foregroundColor(.white)
                    .tracking(4)

                Text("STEP MOMENT")
                    .font(.system(size: 11, weight: .medium))
                    .foregroundColor(Color(red: 0.49, green: 0.36, blue: 0.99).opacity(0.7))
                    .tracking(3)
                    .padding(.top, 4)

                Spacer()
                    .frame(height: 36)

                // Avatar
                AvatarView(
                    state: appState.avatarState,
                    gender: appState.gender,
                    phase: appState.currentPhase
                )
                .scaleEffect(0.7)
                .background(
                    Circle()
                        .fill(Color(red: 0.49, green: 0.36, blue: 0.99).opacity(0.08))
                        .frame(width: 100, height: 100)
                )

                Spacer()
                    .frame(height: 24)

                // Steps
                Text("\(Int(healthManager.currentSteps))")
                    .font(.system(size: 52, weight: .black, design: .rounded))
                    .foregroundColor(.white)
                    .monospacedDigit()

                Text("steps at this moment")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.white.opacity(0.4))

                Spacer()
                    .frame(height: 24)

                // Progress bar
                VStack(spacing: 6) {
                    GeometryReader { geo in
                        ZStack(alignment: .leading) {
                            RoundedRectangle(cornerRadius: 2)
                                .fill(Color.white.opacity(0.06))
                                .frame(height: 4)

                            RoundedRectangle(cornerRadius: 2)
                                .fill(
                                    LinearGradient(
                                        colors: [
                                            Color(red: 0.49, green: 0.36, blue: 0.99),
                                            Color(red: 0.0, green: 0.83, blue: 1.0)
                                        ],
                                        startPoint: .leading,
                                        endPoint: .trailing
                                    )
                                )
                                .frame(width: geo.size.width * progress, height: 4)
                                .shadow(color: Color(red: 0.49, green: 0.36, blue: 0.99).opacity(0.4), radius: 4)
                        }
                    }
                    .frame(height: 4)
                    .padding(.horizontal, 60)

                    Text("\(Int(progress * 100))% of daily goal")
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.3))
                }

                Spacer()

                // Share CTA — purple
                Button(action: shareNow) {
                    Text("Share This Moment")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                        .padding(.vertical, 15)
                        .frame(maxWidth: .infinity)
                        .background(
                            LinearGradient(
                                colors: [
                                    Color(red: 0.49, green: 0.36, blue: 0.99),
                                    Color(red: 0.36, green: 0.25, blue: 0.83)
                                ],
                                startPoint: .leading,
                                endPoint: .trailing
                            )
                        )
                        .cornerRadius(14)
                        .shadow(color: Color(red: 0.49, green: 0.36, blue: 0.99).opacity(0.3), radius: 12, y: 4)
                }
                .padding(.horizontal, 40)

                // Dismiss
                Button(action: dismiss) {
                    Text("Maybe Later")
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.white.opacity(0.25))
                }
                .padding(.top, 16)
                .padding(.bottom, 44)
            }
            .opacity(isShowing ? 1.0 : 0)
            .scaleEffect(isShowing ? 1.0 : 0.95)
        }
        .onAppear {
            appState.stepMomentManager.captureMoment(
                steps: Int(healthManager.currentSteps),
                state: appState.avatarState.rawValue,
                phase: appState.currentPhase
            )

            withAnimation(.easeOut(duration: 0.5)) {
                isShowing = true
            }
            withAnimation(.easeOut(duration: 1.2)) {
                ringScale = 1.0
            }
        }
    }

    private func shareNow() {
        dismiss()
        appState.showShareSheet = true
    }

    private func dismiss() {
        withAnimation(.easeIn(duration: 0.3)) {
            isShowing = false
        }
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.3) {
            appState.showStepMoment = false
        }
    }
}
