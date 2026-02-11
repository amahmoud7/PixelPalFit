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
