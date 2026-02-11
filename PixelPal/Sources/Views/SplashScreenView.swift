import SwiftUI

/// Animated splash screen — seamless transition from iOS launch screen into the app.
/// Deep indigo background matches LaunchBackground color set for zero-flash handoff.
struct SplashScreenView: View {
    let onFinished: () -> Void

    // Animation states
    @State private var glowScale: CGFloat = 0.6
    @State private var glowOpacity: Double = 0
    @State private var logoOpacity: Double = 0
    @State private var logoOffset: CGFloat = 12
    @State private var characterOpacity: Double = 0
    @State private var characterScale: CGFloat = 0.7
    @State private var subtitleOpacity: Double = 0
    @State private var ringRotation: Double = 0
    @State private var ringOpacity: Double = 0
    @State private var exitScale: CGFloat = 1.0
    @State private var exitOpacity: Double = 1.0
    @State private var animFrame: Int = 1

    private let frameTimer = Timer.publish(every: 0.7, on: .main, in: .common).autoconnect()

    private let purple = Color(red: 0.49, green: 0.36, blue: 0.99)
    private let cyan = Color(red: 0.0, green: 0.83, blue: 1.0)

    var body: some View {
        ZStack {
            // Background — matches LaunchBackground color
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.02, blue: 0.15),
                    Color(red: 0.08, green: 0.03, blue: 0.20),
                    Color(red: 0.05, green: 0.02, blue: 0.15)
                ],
                startPoint: .top,
                endPoint: .bottom
            )
            .ignoresSafeArea()

            // Ambient glow
            Circle()
                .fill(
                    RadialGradient(
                        colors: [
                            purple.opacity(0.25),
                            purple.opacity(0.08),
                            cyan.opacity(0.03),
                            .clear
                        ],
                        center: .center,
                        startRadius: 10,
                        endRadius: 180
                    )
                )
                .frame(width: 360, height: 360)
                .scaleEffect(glowScale)
                .opacity(glowOpacity)

            // Rotating ring
            Circle()
                .stroke(
                    AngularGradient(
                        colors: [purple.opacity(0.4), cyan.opacity(0.2), .clear, .clear, purple.opacity(0.4)],
                        center: .center
                    ),
                    lineWidth: 1.5
                )
                .frame(width: 200, height: 200)
                .rotationEffect(.degrees(ringRotation))
                .opacity(ringOpacity)

            // Second ring (counter-rotate)
            Circle()
                .stroke(
                    AngularGradient(
                        colors: [cyan.opacity(0.3), .clear, .clear, purple.opacity(0.2), cyan.opacity(0.3)],
                        center: .center
                    ),
                    lineWidth: 1
                )
                .frame(width: 240, height: 240)
                .rotationEffect(.degrees(-ringRotation * 0.7))
                .opacity(ringOpacity * 0.6)

            // Content
            VStack(spacing: 0) {
                Spacer()

                // Characters
                HStack(spacing: 16) {
                    Image(SpriteAssets.spriteName(gender: .male, state: .vital, frame: animFrame))
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90, height: 90)

                    Image(SpriteAssets.spriteName(gender: .female, state: .vital, frame: animFrame))
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 90, height: 90)
                }
                .scaleEffect(characterScale)
                .opacity(characterOpacity)

                Spacer().frame(height: 32)

                // App name
                VStack(spacing: 8) {
                    Text("PIXEL")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundColor(.white)
                        .tracking(6)
                    + Text(" STEPPER")
                        .font(.system(size: 36, weight: .black, design: .rounded))
                        .foregroundColor(purple)
                        .tracking(6)
                }
                .opacity(logoOpacity)
                .offset(y: logoOffset)

                Spacer().frame(height: 10)

                // Tagline
                Text("Walk. Evolve. Compete.")
                    .font(.system(size: 14, weight: .medium, design: .rounded))
                    .foregroundColor(.white.opacity(0.4))
                    .tracking(2)
                    .opacity(subtitleOpacity)

                Spacer()
            }
        }
        .scaleEffect(exitScale)
        .opacity(exitOpacity)
        .onReceive(frameTimer) { _ in
            animFrame = animFrame == 1 ? 2 : 1
        }
        .onAppear { runSequence() }
    }

    private func runSequence() {
        // Phase 1: Glow fades in
        withAnimation(.easeOut(duration: 0.6)) {
            glowOpacity = 1.0
            glowScale = 1.0
        }

        // Phase 2: Rings appear and rotate
        withAnimation(.easeOut(duration: 0.5).delay(0.2)) {
            ringOpacity = 1.0
        }
        withAnimation(.linear(duration: 8).repeatForever(autoreverses: false)) {
            ringRotation = 360
        }

        // Phase 3: Characters spring in
        withAnimation(.spring(response: 0.6, dampingFraction: 0.7).delay(0.3)) {
            characterOpacity = 1.0
            characterScale = 1.0
        }

        // Phase 4: Logo slides up
        withAnimation(.easeOut(duration: 0.5).delay(0.5)) {
            logoOpacity = 1.0
            logoOffset = 0
        }

        // Phase 5: Subtitle
        withAnimation(.easeOut(duration: 0.4).delay(0.7)) {
            subtitleOpacity = 1.0
        }

        // Phase 6: Hold for a beat, then exit
        DispatchQueue.main.asyncAfter(deadline: .now() + 2.2) {
            withAnimation(.easeIn(duration: 0.4)) {
                exitScale = 1.08
                exitOpacity = 0
            }
            DispatchQueue.main.asyncAfter(deadline: .now() + 0.45) {
                onFinished()
            }
        }
    }
}
