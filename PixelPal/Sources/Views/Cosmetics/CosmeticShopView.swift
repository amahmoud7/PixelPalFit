import SwiftUI

/// Full-screen cosmetic shop with category tabs and item grid.
struct CosmeticShopView: View {
    @EnvironmentObject var appState: AppStateManager
    @Environment(\.dismiss) private var dismiss
    @State private var selectedCategory: CosmeticCategory = .hat
    @State private var selectedItem: CosmeticItem?

    private var cosmeticManager: CosmeticManager { appState.cosmeticManager }
    private var balance: Int { PersistenceManager.shared.progressState.stepCoinBalance }

    var body: some View {
        ZStack {
            // Background
            LinearGradient(
                colors: [
                    Color(red: 0.05, green: 0.02, blue: 0.15),
                    Color(red: 0.10, green: 0.04, blue: 0.22),
                    Color(red: 0.05, green: 0.02, blue: 0.15)
                ],
                startPoint: .topLeading,
                endPoint: .bottomTrailing
            )
            .ignoresSafeArea()

            VStack(spacing: 0) {
                // Header
                header

                // Category tabs
                categoryTabs
                    .padding(.top, 8)

                // Item grid
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 16) {
                        // Featured rotation
                        featuredSection

                        itemGrid

                        // Seasonal section
                        seasonalSection

                        Spacer().frame(height: 40)
                    }
                    .padding(.top, 16)
                }
            }
        }
        .sheet(item: $selectedItem) { item in
            CosmeticDetailSheet(item: item)
                .environmentObject(appState)
        }
    }

    // MARK: - Header

    private var header: some View {
        HStack {
            Button(action: { dismiss() }) {
                Image(systemName: "xmark.circle.fill")
                    .font(.system(size: 26))
                    .foregroundColor(.white.opacity(0.3))
            }

            Spacer()

            Text("COSMETIC SHOP")
                .font(.system(size: 16, weight: .bold, design: .rounded))
                .foregroundColor(.white)
                .tracking(1.5)

            Spacer()

            // Coin balance
            HStack(spacing: 4) {
                Image(systemName: "circle.fill")
                    .font(.system(size: 10))
                    .foregroundColor(.yellow)
                Text("\(balance)")
                    .font(.system(size: 14, weight: .bold, design: .rounded))
                    .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.0))
            }
            .padding(.horizontal, 10)
            .padding(.vertical, 6)
            .background(Color.white.opacity(0.06))
            .clipShape(Capsule())
        }
        .padding(.horizontal, 20)
        .padding(.top, 16)
    }

    // MARK: - Category Tabs

    private var categoryTabs: some View {
        HStack(spacing: 8) {
            ForEach(CosmeticCategory.allCases, id: \.self) { category in
                Button(action: { selectedCategory = category }) {
                    HStack(spacing: 4) {
                        Image(systemName: category.icon)
                            .font(.system(size: 11))
                        Text(category.displayName)
                            .font(.system(size: 12, weight: .semibold))
                    }
                    .foregroundColor(selectedCategory == category ? .white : .white.opacity(0.4))
                    .padding(.horizontal, 14)
                    .padding(.vertical, 8)
                    .background(
                        selectedCategory == category
                            ? Color(red: 0.49, green: 0.36, blue: 0.99).opacity(0.3)
                            : Color.white.opacity(0.04)
                    )
                    .clipShape(Capsule())
                    .overlay(
                        Capsule()
                            .stroke(
                                selectedCategory == category
                                    ? Color(red: 0.49, green: 0.36, blue: 0.99).opacity(0.5)
                                    : Color.white.opacity(0.06),
                                lineWidth: 1
                            )
                    )
                }
            }
        }
        .padding(.horizontal, 20)
    }

    // MARK: - Featured Section

    private var featuredSection: some View {
        let featured = CosmeticCatalog.featuredItems(isPremium: appState.storeManager.isPremium)
        let timeLeft = CosmeticCatalog.timeUntilNextRotation()
        let hoursLeft = Int(timeLeft / 3600)

        return VStack(spacing: 10) {
            HStack {
                HStack(spacing: 6) {
                    Image(systemName: "star.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.orange)
                    Text("FEATURED")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(.orange)
                        .tracking(1.0)
                }

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "clock")
                        .font(.system(size: 9))
                    Text(hoursLeft > 24 ? "\(hoursLeft / 24)d \(hoursLeft % 24)h" : "\(hoursLeft)h left")
                        .font(.system(size: 10, weight: .medium))
                }
                .foregroundColor(.white.opacity(0.35))

                if appState.storeManager.isPremium {
                    Text("EARLY ACCESS")
                        .font(.system(size: 8, weight: .bold))
                        .foregroundColor(.yellow)
                        .padding(.horizontal, 6)
                        .padding(.vertical, 2)
                        .background(Color.yellow.opacity(0.15))
                        .clipShape(Capsule())
                }
            }
            .padding(.horizontal, 16)

            let columns = [
                GridItem(.flexible(), spacing: 10),
                GridItem(.flexible(), spacing: 10),
                GridItem(.flexible(), spacing: 10)
            ]

            LazyVGrid(columns: columns, spacing: 12) {
                ForEach(featured) { item in
                    Button(action: { selectedItem = item }) {
                        CosmeticItemCard(
                            item: item,
                            isOwned: cosmeticManager.inventory.ownedItemIDs.contains(item.id),
                            isEquipped: cosmeticManager.currentLoadout.equipped(for: item.category) == item.id,
                            eligibility: cosmeticManager.canPurchase(
                                item,
                                balance: balance,
                                isPremium: appState.storeManager.isPremium,
                                phase: appState.currentPhase,
                                streak: appState.currentStreak,
                                totalSteps: PersistenceManager.shared.progressState.totalStepsSinceStart
                            ),
                            isFeatured: true
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding(.horizontal, 16)

            Rectangle()
                .fill(Color.white.opacity(0.04))
                .frame(height: 1)
                .padding(.horizontal, 16)
        }
    }

    // MARK: - Item Grid

    private var itemGrid: some View {
        let items = CosmeticCatalog.items(for: selectedCategory).filter { !$0.isLimited }
        let columns = [
            GridItem(.flexible(), spacing: 10),
            GridItem(.flexible(), spacing: 10),
            GridItem(.flexible(), spacing: 10)
        ]

        return LazyVGrid(columns: columns, spacing: 12) {
            ForEach(items) { item in
                Button(action: { selectedItem = item }) {
                    CosmeticItemCard(
                        item: item,
                        isOwned: cosmeticManager.inventory.ownedItemIDs.contains(item.id),
                        isEquipped: cosmeticManager.currentLoadout.equipped(for: item.category) == item.id,
                        eligibility: cosmeticManager.canPurchase(
                            item,
                            balance: balance,
                            isPremium: appState.storeManager.isPremium,
                            phase: appState.currentPhase,
                            streak: appState.currentStreak,
                            totalSteps: PersistenceManager.shared.progressState.totalStepsSinceStart
                        )
                    )
                }
                .buttonStyle(.plain)
            }
        }
        .padding(.horizontal, 16)
    }

    // MARK: - Seasonal Section

    @ViewBuilder
    private var seasonalSection: some View {
        let seasonal = CosmeticCatalog.currentSeasonalItems()
            .filter { $0.category == selectedCategory || selectedCategory == .hat }

        if !seasonal.isEmpty {
            VStack(spacing: 10) {
                HStack {
                    Text("LIMITED TIME")
                        .font(.system(size: 10, weight: .bold))
                        .foregroundColor(CosmeticRarity.seasonal.color)
                        .tracking(1.0)

                    Rectangle()
                        .fill(CosmeticRarity.seasonal.color.opacity(0.2))
                        .frame(height: 1)
                }
                .padding(.horizontal, 16)

                let columns = [
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10)
                ]

                LazyVGrid(columns: columns, spacing: 12) {
                    ForEach(seasonal) { item in
                        Button(action: { selectedItem = item }) {
                            CosmeticItemCard(
                                item: item,
                                isOwned: cosmeticManager.inventory.ownedItemIDs.contains(item.id),
                                isEquipped: cosmeticManager.currentLoadout.equipped(for: item.category) == item.id,
                                eligibility: cosmeticManager.canPurchase(
                                    item,
                                    balance: balance,
                                    isPremium: appState.storeManager.isPremium,
                                    phase: appState.currentPhase,
                                    streak: appState.currentStreak,
                                    totalSteps: PersistenceManager.shared.progressState.totalStepsSinceStart
                                )
                            )
                        }
                        .buttonStyle(.plain)
                    }
                }
                .padding(.horizontal, 16)
            }
        }
    }
}
