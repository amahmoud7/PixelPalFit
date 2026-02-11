import SwiftUI

/// 3-tab layout: Home, Stats, Profile with Edge Glow tab bar.
struct MainTabView: View {
    @EnvironmentObject var appState: AppStateManager
    @EnvironmentObject var healthManager: HealthKitManager
    @State private var selectedTab: Tab = .home

    enum Tab: String {
        case home, stats, profile
    }

    var body: some View {
        ZStack(alignment: .bottom) {
            // Tab content
            Group {
                switch selectedTab {
                case .home:
                    HomeView()
                case .stats:
                    StatsView()
                case .profile:
                    ProfileView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)

            // Edge Glow tab bar
            tabBar
        }
        .overlay {
            // Celebration overlay
            if let event = appState.showCelebration {
                CelebrationOverlay(event: event) {
                    appState.showCelebration = nil
                } onShare: {
                    appState.showCelebration = nil
                    appState.showShareSheet = true
                }
            }

            // Step Moment overlay
            if appState.showStepMoment {
                StepMomentView()
            }

            // Coin toast
            if let coins = appState.stepCoinToast {
                VStack {
                    Spacer()
                    HStack(spacing: 6) {
                        Image(systemName: "circle.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.yellow)
                        Text("+\(coins) coins")
                            .font(.system(size: 15, weight: .bold, design: .rounded))
                            .foregroundColor(.white)
                    }
                    .padding(.horizontal, 20)
                    .padding(.vertical, 10)
                    .background(Color.black.opacity(0.8))
                    .clipShape(Capsule())
                    .padding(.bottom, 100)
                }
                .transition(.move(edge: .bottom).combined(with: .opacity))
                .animation(.easeInOut(duration: 0.3), value: appState.stepCoinToast != nil)
            }
        }
        .sheet(isPresented: $appState.showPaywall) {
            PaywallView(storeManager: appState.storeManager, gender: appState.gender, currentPhase: appState.currentPhase)
        }
        .sheet(isPresented: $appState.showShareSheet) {
            ShareSheetView(data: appState.shareCardData)
        }
    }

    // MARK: - Edge Glow Tab Bar

    private var tabBar: some View {
        VStack(spacing: 0) {
            // Gradient glow separator line
            Rectangle()
                .fill(
                    LinearGradient(
                        stops: [
                            .init(color: .clear, location: 0.0),
                            .init(color: tabGlowColor.opacity(0.5), location: tabGlowPosition - 0.05),
                            .init(color: tabGlowColor.opacity(0.7), location: tabGlowPosition),
                            .init(color: tabGlowColor.opacity(0.5), location: tabGlowPosition + 0.05),
                            .init(color: Color.white.opacity(0.05), location: tabGlowPosition + 0.15),
                            .init(color: .clear, location: 1.0)
                        ],
                        startPoint: .leading,
                        endPoint: .trailing
                    )
                )
                .frame(height: 1)

            // Tab buttons
            HStack(spacing: 0) {
                tabButton(.home, icon: "house.fill", label: "Home")
                tabButton(.stats, icon: "chart.bar.fill", label: "Stats")
                tabButton(.profile, icon: "person.fill", label: "Profile")
            }
            .padding(.horizontal, 20)
            .padding(.top, 4)
            .padding(.bottom, 2)
            .background(
                Color(red: 0.04, green: 0.04, blue: 0.08).opacity(0.95)
                    .ignoresSafeArea()
            )
        }
    }

    private func tabButton(_ tab: Tab, icon: String, label: String) -> some View {
        let isSelected = selectedTab == tab

        return Button {
            withAnimation(.easeInOut(duration: 0.15)) {
                selectedTab = tab
            }
        } label: {
            VStack(spacing: 0) {
                // Top glow indicator
                RoundedRectangle(cornerRadius: 1)
                    .fill(isSelected ? Color(red: 0.49, green: 0.36, blue: 0.99) : .clear)
                    .frame(width: 20, height: 2)
                    .shadow(color: isSelected ? Color(red: 0.49, green: 0.36, blue: 0.99).opacity(0.5) : .clear, radius: 4)
                    .padding(.bottom, 4)

                Image(systemName: icon)
                    .font(.system(size: 17, weight: isSelected ? .semibold : .regular))
                    .foregroundColor(isSelected ? .white : .white.opacity(0.3))

                Text(label)
                    .font(.system(size: 10, weight: .medium, design: .rounded))
                    .foregroundColor(isSelected ? Color(red: 0.49, green: 0.36, blue: 0.99) : .white.opacity(0.25))
                    .padding(.top, 3)
            }
            .frame(maxWidth: .infinity)
        }
    }

    // MARK: - Glow Helpers

    private var tabGlowColor: Color {
        Color(red: 0.49, green: 0.36, blue: 0.99)
    }

    private var tabGlowPosition: CGFloat {
        switch selectedTab {
        case .home: return 0.17
        case .stats: return 0.5
        case .profile: return 0.83
        }
    }
}
