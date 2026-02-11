import Foundation

/// Generates and tracks daily missions. 3 free, 5 for premium.
@MainActor
class MissionManager: ObservableObject {
    @Published var missions: [DailyMission] = []

    private let persistence = PersistenceManager.shared
    private let dailyGoal = 7500

    private var todayString: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return formatter.string(from: Date())
    }

    // MARK: - Public API

    /// Loads existing missions for today or generates new ones.
    func loadOrGenerateMissions(weeklyAverage: Int) {
        let isPremium = PersistenceManager.shared.entitlements.isPremium
        let expectedCount = isPremium ? 5 : 3

        if let saved = loadMissions(), saved.dateString == todayString {
            if saved.missions.count == expectedCount {
                missions = saved.missions
            } else {
                // Premium status changed mid-day — regenerate with correct count
                missions = generateMissions(weeklyAverage: max(weeklyAverage, 3000), isPremium: isPremium)
                saveMissions()
            }
        } else {
            missions = generateMissions(weeklyAverage: max(weeklyAverage, 3000), isPremium: isPremium)
            saveMissions()
        }
    }

    /// Updates mission progress based on current state.
    func updateProgress(todaySteps: Int, currentStreak: Int, currentHour: Int) {
        var changed = false

        for i in missions.indices {
            guard !missions[i].isCompleted else { continue }

            let newProgress: Int
            switch missions[i].type {
            case .stepTarget, .goalCrush:
                newProgress = todaySteps
            case .morningWalk:
                newProgress = currentHour < 12 ? todaySteps : missions[i].progress
            case .eveningPush:
                // Track steps after 5pm (simplified: use total steps if after 5pm)
                newProgress = currentHour >= 17 ? min(todaySteps, missions[i].target) : missions[i].progress
            case .streakExtend:
                newProgress = todaySteps >= dailyGoal ? 1 : 0
            case .consistentDay:
                // Simplified: count as progress if steps > 500 per active hour
                let activeHours = max(1, currentHour - 7)
                let avgPerHour = todaySteps / activeHours
                newProgress = avgPerHour >= 500 ? min(activeHours, missions[i].target) : missions[i].progress
            }

            if newProgress != missions[i].progress {
                missions[i].progress = newProgress
                changed = true
            }
        }

        if changed {
            saveMissions()
        }
    }

    /// Returns completed missions count.
    var completedCount: Int {
        missions.filter(\.isCompleted).count
    }

    // MARK: - Generation

    private func generateMissions(weeklyAverage: Int, isPremium: Bool) -> [DailyMission] {
        // Use date-based seed for deterministic generation
        let seed = todayString.hashValue
        var rng = SeededRandomNumberGenerator(seed: UInt64(bitPattern: Int64(seed)))

        var types = MissionType.allCases.shuffled(using: &rng)
        let missionCount = isPremium ? 5 : 3

        var result: [DailyMission] = []
        for i in 0..<missionCount {
            let type = types[i % types.count]
            result.append(createMission(type: type, weeklyAverage: weeklyAverage, index: i, rng: &rng))
        }

        return result
    }

    private func createMission(type: MissionType, weeklyAverage: Int, index: Int, rng: inout SeededRandomNumberGenerator) -> DailyMission {
        let dailyAvg = max(3000, weeklyAverage)

        let (title, target, coinReward): (String, Int, Int)

        switch type {
        case .stepTarget:
            let scaled = Int(Double(dailyAvg) * Double.random(in: 0.7...1.2, using: &rng))
            let rounded = (scaled / 500) * 500
            title = "Walk \(rounded.formatted()) steps today"
            target = rounded
            coinReward = rounded >= dailyGoal ? 40 : 20
        case .morningWalk:
            title = "Hit 1,000 steps before noon"
            target = 1000
            coinReward = 25
        case .eveningPush:
            title = "Walk 2,000 steps after 5pm"
            target = 2000
            coinReward = 30
        case .streakExtend:
            title = "Keep your streak alive"
            target = 1
            coinReward = 20
        case .goalCrush:
            let crushTarget = Int(Double(dailyGoal) * 1.5)
            title = "Crush your goal — hit \(crushTarget.formatted()) steps"
            target = crushTarget
            coinReward = 50
        case .consistentDay:
            title = "Stay active for 4+ hours (500+ steps/hr)"
            target = 4
            coinReward = 35
        }

        return DailyMission(
            id: "\(todayString)_\(type.rawValue)_\(index)",
            type: type,
            title: title,
            target: target,
            progress: 0,
            coinReward: coinReward,
            dateString: todayString
        )
    }

    // MARK: - Persistence

    private func saveMissions() {
        let state = DailyMissionsState(missions: missions, dateString: todayString)
        let url = missionsFileURL
        do {
            let data = try JSONEncoder().encode(state)
            try data.write(to: url, options: .atomic)
        } catch {
            print("MissionManager: Failed to save: \(error)")
        }
    }

    private func loadMissions() -> DailyMissionsState? {
        let url = missionsFileURL
        guard let data = try? Data(contentsOf: url) else { return nil }
        return try? JSONDecoder().decode(DailyMissionsState.self, from: data)
    }

    private var missionsFileURL: URL {
        let urls = FileManager.default.urls(for: .applicationSupportDirectory, in: .userDomainMask)
        let dir = urls[0].appendingPathComponent("PixelPal", isDirectory: true)
        if !FileManager.default.fileExists(atPath: dir.path) {
            try? FileManager.default.createDirectory(at: dir, withIntermediateDirectories: true)
        }
        return dir.appendingPathComponent("DailyMissions.json")
    }
}

// MARK: - Seeded RNG

struct SeededRandomNumberGenerator: RandomNumberGenerator {
    private var state: UInt64

    init(seed: UInt64) {
        state = seed == 0 ? 1 : seed
    }

    mutating func next() -> UInt64 {
        state &+= 0x9e3779b97f4a7c15
        var z = state
        z = (z ^ (z >> 30)) &* 0xbf58476d1ce4e5b9
        z = (z ^ (z >> 27)) &* 0x94d049bb133111eb
        return z ^ (z >> 31)
    }
}
