import Foundation

/// Snapshot of a Step Moment check-in.
struct StepMoment: Codable {
    let stepsAtCapture: Int
    let avatarState: String
    let phase: Int
    let hasShared: Bool
    let date: Date
    let dateString: String

    static func capture(steps: Int, state: String, phase: Int) -> StepMoment {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd"
        return StepMoment(
            stepsAtCapture: steps,
            avatarState: state,
            phase: phase,
            hasShared: false,
            date: Date(),
            dateString: formatter.string(from: Date())
        )
    }
}
