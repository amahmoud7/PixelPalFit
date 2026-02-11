import SwiftUI
import StoreKit

/// Root view: splash → onboarding or main tab view.
struct ContentView: View {
    @EnvironmentObject var healthManager: HealthKitManager
    @StateObject private var appState = AppStateManager()
    @State private var showSplash = true

    var body: some View {
        ZStack {
            // Ambient gradient background
            LinearGradient(
                gradient: Gradient(colors: [
                    Color(red: 0.05, green: 0.02, blue: 0.15),
                    Color(red: 0.08, green: 0.03, blue: 0.20),
                    Color(red: 0.05, green: 0.02, blue: 0.15)
                ]),
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            if showSplash {
                SplashScreenView {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        showSplash = false
                    }
                }
            } else if !isOnboardingComplete {
                OnboardingView()
                    .transition(.opacity)
            } else {
                MainTabView()
                    .environmentObject(appState)
                    .transition(.opacity)
            }
        }
        .onAppear {
            appState.loadSavedData()
            if healthManager.isAuthorized {
                healthManager.fetchData()
                appState.fetchCumulativeSteps(healthManager: healthManager)
            }
            Task {
                await appState.storeManager.setup()
            }
        }
        .onChange(of: healthManager.currentSteps) { _ in
            appState.updateState(healthManager: healthManager)
        }
        .onChange(of: healthManager.cumulativeSteps) { _ in
            appState.cumulativeSteps = healthManager.cumulativeSteps
        }
        .onChange(of: healthManager.isAuthorized) { authorized in
            if authorized {
                appState.loadSavedData()
                healthManager.fetchData()
                appState.fetchCumulativeSteps(healthManager: healthManager)
            }
        }
        .onChange(of: healthManager.dailyStepsLast7Days) { dailyMap in
            appState.backfillWeeklyHistory(from: dailyMap, healthManager: healthManager)
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.willResignActiveNotification)) { _ in
            NotificationManager.shared.scheduleReEngagement()
        }
        .onReceive(NotificationCenter.default.publisher(for: UIApplication.didBecomeActiveNotification)) { _ in
            NotificationManager.shared.cancelReEngagement()
            NotificationManager.shared.refreshSchedule()
        }
    }

    private var isOnboardingComplete: Bool {
        let profile = PersistenceManager.shared.userProfile
        return profile != nil && healthManager.isAuthorized
    }
}

// MARK: - Glass Card Modifier

struct GlassCardModifier: ViewModifier {
    func body(content: Content) -> some View {
        content
            .padding(16)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.ultraThinMaterial.opacity(0.6))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.1), lineWidth: 1)
                    )
            )
    }
}

extension View {
    func glassCard() -> some View {
        modifier(GlassCardModifier())
    }
}

// MARK: - Phase Display View

struct PhaseDisplayView: View {
    let phase: Int
    let isPremium: Bool

    private var phaseColor: Color {
        switch phase {
        case 1: return .gray
        case 2: return .blue
        case 3: return .purple
        case 4: return .orange
        default: return .gray
        }
    }

    private var phaseIcon: String {
        switch phase {
        case 1: return "circle"
        case 2: return "circle.fill"
        case 3: return "star.fill"
        case 4: return "sparkles"
        default: return "circle"
        }
    }

    private var phaseName: String {
        switch phase {
        case 1: return "Seedling"
        case 2: return "Growing"
        case 3: return "Thriving"
        case 4: return "Legendary"
        default: return "Unknown"
        }
    }

    var body: some View {
        HStack(spacing: 8) {
            Image(systemName: phaseIcon)
                .font(.title3)
                .foregroundColor(phaseColor)

            Text("Phase \(phase)")
                .font(.headline)
                .foregroundColor(.white)

            Text("\u{2022} \(phaseName)")
                .font(.subheadline)
                .foregroundColor(phaseColor)

            if isPremium {
                Image(systemName: "crown.fill")
                    .font(.caption)
                    .foregroundColor(.yellow)
            }
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 8)
        .background(phaseColor.opacity(0.2))
        .cornerRadius(20)
    }
}
