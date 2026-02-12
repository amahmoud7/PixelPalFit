import SwiftUI

/// RPG-style Quest Board with left-border color coding, strikethrough completed, premium quests visible.
struct DailyMissionsView: View {
    @EnvironmentObject var appState: AppStateManager

    private var coinBalance: Int {
        PersistenceManager.shared.progressState.stepCoinBalance
    }

    var body: some View {
        VStack(alignment: .leading, spacing: 10) {
            // Header: Quest Board + coin balance
            HStack {
                Text("Quest Board")
                    .font(.system(size: 16, weight: .bold, design: .rounded))
                    .foregroundColor(.white)

                Spacer()

                HStack(spacing: 4) {
                    Image(systemName: "circle.fill")
                        .font(.system(size: 10))
                        .foregroundColor(.yellow)
                    Text("\(coinBalance)")
                        .font(.system(size: 13, weight: .bold, design: .rounded))
                        .foregroundColor(Color(red: 1.0, green: 0.84, blue: 0.0))
                }
                .padding(.horizontal, 10)
                .padding(.vertical, 5)
                .background(
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.1))
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.2), lineWidth: 1)
                        )
                )
            }

            // Quest rows
            ForEach(appState.missionManager.missions) { mission in
                questRow(mission)
            }

            // Weekly challenge (premium only)
            if let challenge = appState.missionManager.weeklyChallenge {
                weeklyRow(challenge)
            }

            // Premium quests divider + locked rows
            if !appState.storeManager.isPremium {
                premiumQuestsSection
            }
        }
    }

    // MARK: - Weekly Challenge Row

    @ViewBuilder
    private func weeklyRow(_ challenge: WeeklyChallenge) -> some View {
        let gold = Color(red: 1.0, green: 0.84, blue: 0.0)

        VStack(spacing: 0) {
            // Header
            HStack(spacing: 6) {
                Image(systemName: "crown.fill")
                    .font(.system(size: 9))
                    .foregroundColor(gold)
                Text("WEEKLY CHALLENGE")
                    .font(.system(size: 9, weight: .bold))
                    .foregroundColor(gold.opacity(0.8))
                    .tracking(1)
                Spacer()
                Text(daysLeftText)
                    .font(.system(size: 9, weight: .medium))
                    .foregroundColor(.white.opacity(0.3))
            }
            .padding(.horizontal, 14)
            .padding(.top, 10)
            .padding(.bottom, 6)

            HStack(spacing: 10) {
                // Icon
                RoundedRectangle(cornerRadius: 8)
                    .fill(gold.opacity(challenge.isCompleted ? 0.2 : 0.1))
                    .frame(width: 28, height: 28)
                    .overlay(
                        Image(systemName: challenge.isCompleted ? "checkmark" : challenge.type.icon)
                            .font(.system(size: 12, weight: .bold))
                            .foregroundColor(challenge.isCompleted ? Color(red: 0.2, green: 0.78, blue: 0.35) : gold)
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(challenge.title)
                        .font(.system(size: 13, weight: .bold))
                        .foregroundColor(challenge.isCompleted ? .white.opacity(0.5) : .white)
                        .strikethrough(challenge.isCompleted, color: .white.opacity(0.3))

                    Text(challenge.description)
                        .font(.system(size: 10, weight: .medium))
                        .foregroundColor(.white.opacity(0.4))

                    if !challenge.isCompleted {
                        Text("\(challenge.progress.formatted()) / \(challenge.target.formatted())")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.3))
                    }
                }

                Spacer()

                Text("\(challenge.coinReward)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(gold)
                + Text(" \u{1FA99}")
                    .font(.system(size: 10))
            }
            .padding(.horizontal, 14)
            .padding(.bottom, 10)
        }
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(
                    LinearGradient(
                        colors: [gold.opacity(0.06), gold.opacity(0.02)],
                        startPoint: .topLeading,
                        endPoint: .bottomTrailing
                    )
                )
                .overlay(
                    RoundedRectangle(cornerRadius: 12)
                        .stroke(gold.opacity(0.15), lineWidth: 1)
                )
        )
        .overlay {
            if !challenge.isCompleted && challenge.progress > 0 {
                GeometryReader { geo in
                    VStack {
                        Spacer()
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.white.opacity(0.06))
                            .frame(height: 3)
                            .overlay(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(gold)
                                    .frame(width: geo.size.width * challenge.progressFraction)
                                    .shadow(color: gold.opacity(0.4), radius: 3)
                            }
                            .padding(.horizontal, 14)
                    }
                    .padding(.bottom, 2)
                }
            }
        }
    }

    private var daysLeftText: String {
        let calendar = Calendar.current
        let weekday = calendar.component(.weekday, from: Date())
        // Sunday=1, Saturday=7. Days until Sunday (end of week)
        let daysLeft = weekday == 1 ? 0 : (8 - weekday)
        return daysLeft == 0 ? "Ends today" : "\(daysLeft)d left"
    }

    // MARK: - Quest Row

    @ViewBuilder
    private func questRow(_ mission: DailyMission) -> some View {
        let color = Color(hex: mission.type.color)

        HStack(spacing: 0) {
            // Left color border
            RoundedRectangle(cornerRadius: 2)
                .fill(mission.isCompleted ? Color(red: 0.2, green: 0.78, blue: 0.35) : color)
                .frame(width: 3)

            HStack(spacing: 10) {
                // Status icon
                if mission.isCompleted {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color(red: 0.2, green: 0.78, blue: 0.35))
                        .frame(width: 22, height: 22)
                        .overlay(
                            Image(systemName: "checkmark")
                                .font(.system(size: 11, weight: .bold))
                                .foregroundColor(.white)
                        )
                } else if mission.progress > 0 {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(color.opacity(0.2))
                        .frame(width: 22, height: 22)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(color, lineWidth: 1.5)
                        )
                        .overlay(
                            Image(systemName: "play.fill")
                                .font(.system(size: 8))
                                .foregroundColor(color)
                        )
                } else {
                    RoundedRectangle(cornerRadius: 6)
                        .fill(Color.white.opacity(0.05))
                        .frame(width: 22, height: 22)
                        .overlay(
                            RoundedRectangle(cornerRadius: 6)
                                .stroke(Color.white.opacity(0.15), lineWidth: 1.5)
                        )
                }

                // Content
                VStack(alignment: .leading, spacing: 2) {
                    Text(mission.title)
                        .font(.system(size: 13, weight: .semibold))
                        .foregroundColor(mission.isCompleted ? .white.opacity(0.5) : .white)
                        .strikethrough(mission.isCompleted, color: .white.opacity(0.3))

                    if !mission.isCompleted {
                        Text("\(mission.progress.formatted()) / \(mission.target.formatted())")
                            .font(.system(size: 10, weight: .medium))
                            .foregroundColor(.white.opacity(0.4))
                    }
                }

                Spacer()

                // Coin reward
                Text(mission.isCompleted ? "+\(mission.coinReward)" : "\(mission.coinReward)")
                    .font(.system(size: 11, weight: .bold))
                    .foregroundColor(mission.isCompleted
                        ? Color(red: 1.0, green: 0.84, blue: 0.0)
                        : Color(red: 1.0, green: 0.84, blue: 0.0).opacity(0.4))
                + Text(" 🪙")
                    .font(.system(size: 10))
            }
            .padding(.leading, 13)
            .padding(.trailing, 14)
            .padding(.vertical, mission.isCompleted ? 12 : 10)
        }
        .background(
            mission.isCompleted
                ? Color(red: 0.2, green: 0.78, blue: 0.35).opacity(0.06)
                : Color.white.opacity(mission.progress > 0 ? 0.03 : 0.02)
        )
        .clipShape(
            .rect(topLeadingRadius: 0, bottomLeadingRadius: 0, bottomTrailingRadius: 12, topTrailingRadius: 12)
        )
        .overlay {
            // Progress bar for in-progress quests
            if !mission.isCompleted && mission.progress > 0 {
                GeometryReader { geo in
                    VStack {
                        Spacer()
                        RoundedRectangle(cornerRadius: 2)
                            .fill(Color.white.opacity(0.06))
                            .frame(height: 4)
                            .overlay(alignment: .leading) {
                                RoundedRectangle(cornerRadius: 2)
                                    .fill(
                                        LinearGradient(
                                            colors: [color, color.opacity(0.7)],
                                            startPoint: .leading,
                                            endPoint: .trailing
                                        )
                                    )
                                    .frame(width: geo.size.width * mission.progressFraction)
                                    .shadow(color: color.opacity(0.4), radius: 3)
                            }
                            .padding(.leading, 35)
                    }
                }
            }
        }
    }

    // MARK: - Premium Quests

    private var premiumQuestsSection: some View {
        VStack(alignment: .leading, spacing: 8) {
            // Dashed divider
            Rectangle()
                .stroke(style: StrokeStyle(lineWidth: 1, dash: [6, 4]))
                .foregroundColor(Color(red: 0.49, green: 0.36, blue: 0.99).opacity(0.2))
                .frame(height: 1)

            Text("PREMIUM QUESTS")
                .font(.system(size: 10, weight: .medium))
                .foregroundColor(Color(red: 0.49, green: 0.36, blue: 0.99).opacity(0.7))
                .tracking(1)

            // Locked quest rows
            lockedQuestRow(title: "Evening Push — 2,000 steps after 5pm")
            lockedQuestRow(title: "Stay Active — 500+ steps/hr for 4 hrs")
        }
        .opacity(0.5)
    }

    private func lockedQuestRow(title: String) -> some View {
        HStack(spacing: 0) {
            RoundedRectangle(cornerRadius: 2)
                .fill(Color(red: 0.49, green: 0.36, blue: 0.99).opacity(0.15))
                .frame(width: 3)

            HStack(spacing: 10) {
                RoundedRectangle(cornerRadius: 6)
                    .fill(Color(red: 0.49, green: 0.36, blue: 0.99).opacity(0.1))
                    .frame(width: 22, height: 22)
                    .overlay(
                        Image(systemName: "lock.fill")
                            .font(.system(size: 8))
                            .foregroundColor(Color(red: 0.49, green: 0.36, blue: 0.99).opacity(0.5))
                    )

                Text(title)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.white.opacity(0.3))

                Spacer()
            }
            .padding(.leading, 13)
            .padding(.trailing, 14)
            .padding(.vertical, 10)
        }
        .background(Color.white.opacity(0.02))
        .clipShape(
            .rect(topLeadingRadius: 0, bottomLeadingRadius: 0, bottomTrailingRadius: 12, topTrailingRadius: 12)
        )
    }
}
