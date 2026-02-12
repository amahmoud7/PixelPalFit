import SwiftUI

/// Home tab: Avatar + streak hero + daily missions + step count.
struct HomeView: View {
    @EnvironmentObject var appState: AppStateManager
    @EnvironmentObject var healthManager: HealthKitManager

    var body: some View {
        ScrollView(showsIndicators: false) {
            VStack(spacing: 20) {
                // Top bar
                topBar
                    .padding(.top, 8)

                // HealthKit unavailable banner (iPad/no Health app)
                if !healthManager.isHealthDataAvailable {
                    healthKitUnavailableBanner
                        .padding(.horizontal, 20)
                }

                // "Not seeing steps?" help (shows when authorized but 0 steps for a while)
                if healthManager.isAuthorized && healthManager.currentSteps == 0 && hasProfile {
                    stepsHelpBanner
                        .padding(.horizontal, 20)
                }

                // Hero avatar
                AvatarView(
                    state: appState.avatarState,
                    gender: appState.gender,
                    phase: appState.currentPhase,
                    loadout: appState.currentLoadout
                )

                // Streak hero (Glass Dashboard)
                StreakHeroView(
                    streak: appState.currentStreak,
                    todaySteps: Int(healthManager.currentSteps),
                    dailyGoal: 7500,
                    missionsCompleted: appState.missionManager.completedCount,
                    missionsTotal: appState.missionManager.missions.count
                )
                .padding(.horizontal, 20)

                // Daily missions
                DailyMissionsView()
                    .padding(.horizontal, 20)

                if let lastUpdate = SharedData.loadLastUpdateDate() {
                    Text("Updated \(lastUpdate.formatted(date: .omitted, time: .shortened))")
                        .font(.caption2)
                        .foregroundColor(.gray.opacity(0.6))
                }

                Spacer().frame(height: 100)
            }
        }
        .refreshable {
            healthManager.fetchData()
            appState.fetchCumulativeSteps(healthManager: healthManager)
            appState.updateState(healthManager: healthManager)
        }
    }

    // MARK: - HealthKit Banners

    @State private var showStepsHelp = false
    @State private var dismissedStepsHelp = false

    private var hasProfile: Bool {
        PersistenceManager.shared.userProfile != nil
    }

    /// Shows when HealthKit is not available on the device (iPad, etc.)
    private var healthKitUnavailableBanner: some View {
        HStack(spacing: 10) {
            Image(systemName: "heart.slash.fill")
                .font(.system(size: 20))
                .foregroundColor(.red.opacity(0.6))

            VStack(alignment: .leading, spacing: 2) {
                Text("Health data not available")
                    .font(.system(size: 13, weight: .semibold))
                    .foregroundColor(.white)
                Text("This device doesn't support step tracking")
                    .font(.system(size: 10, weight: .medium))
                    .foregroundColor(.white.opacity(0.4))
            }

            Spacer()
        }
        .padding(12)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(Color.red.opacity(0.08))
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(Color.red.opacity(0.2), lineWidth: 1)
                )
        )
    }

    /// Shows when authorized but steps are 0 — user may have denied read access in Health settings.
    private var stepsHelpBanner: some View {
        Group {
            if !dismissedStepsHelp {
                Button(action: { showStepsHelp = true }) {
                    HStack(spacing: 10) {
                        Image(systemName: "questionmark.circle.fill")
                            .font(.system(size: 18))
                            .foregroundColor(.orange.opacity(0.8))

                        VStack(alignment: .leading, spacing: 2) {
                            Text("Not seeing your steps?")
                                .font(.system(size: 13, weight: .semibold))
                                .foregroundColor(.white)
                            Text("Tap for help enabling step access")
                                .font(.system(size: 10, weight: .medium))
                                .foregroundColor(.white.opacity(0.4))
                        }

                        Spacer()

                        Button(action: { dismissedStepsHelp = true }) {
                            Image(systemName: "xmark")
                                .font(.system(size: 10, weight: .bold))
                                .foregroundColor(.white.opacity(0.3))
                                .padding(6)
                        }
                    }
                    .padding(12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(Color.orange.opacity(0.06))
                            .overlay(
                                RoundedRectangle(cornerRadius: 12)
                                    .stroke(Color.orange.opacity(0.15), lineWidth: 1)
                            )
                    )
                }
                .alert("Enable Step Tracking", isPresented: $showStepsHelp) {
                    Button("Open Health App") {
                        if let url = URL(string: "x-apple-health://") {
                            UIApplication.shared.open(url)
                        }
                    }
                    Button("Try Again") {
                        healthManager.requestAuthorization { _ in }
                    }
                    Button("Dismiss", role: .cancel) {
                        dismissedStepsHelp = true
                    }
                } message: {
                    Text("To enable step tracking:\n\n1. Open the Health app\n2. Tap your profile icon (top right)\n3. Tap \"Apps\" under Privacy\n4. Tap \"Pixel Stepper\"\n5. Turn on \"Steps\"")
                }
            }
        }
    }

    // MARK: - Top Bar

    private var topBar: some View {
        HStack {
            PhaseDisplayView(phase: appState.currentPhase, isPremium: appState.storeManager.isPremium)

            Spacer()

            if !appState.storeManager.isPremium {
                Button(action: { appState.showPaywall = true }) {
                    Image(systemName: "crown.fill")
                        .font(.title3)
                        .foregroundColor(.yellow.opacity(0.8))
                        .padding(8)
                        .background(Color.white.opacity(0.08))
                        .clipShape(Circle())
                }
            }

            Button(action: { appState.showShareSheet = true }) {
                Image(systemName: "square.and.arrow.up")
                    .font(.system(size: 15, weight: .medium))
                    .foregroundColor(.white.opacity(0.7))
                    .padding(8)
                    .background(Color.white.opacity(0.08))
                    .clipShape(Circle())
            }
        }
        .padding(.horizontal, 20)
    }

}
