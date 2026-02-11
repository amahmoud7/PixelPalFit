import Foundation

/// Manages celebration triggers, queuing, and deduplication.
/// Max 1 celebration per app session; others queued for next foreground.
@MainActor
class CelebrationManager: ObservableObject {
    /// Events waiting to be shown.
    private var queue: [CelebrationEvent] = []

    /// Events already shown this session.
    private var shownThisSession: Set<String> = []

    /// Whether a celebration has been shown this session.
    private var hasShownThisSession = false

    /// Attempts to trigger a celebration. Returns true if queued.
    @discardableResult
    func tryTrigger(_ event: CelebrationEvent) -> Bool {
        guard !shownThisSession.contains(event.id) else { return false }
        guard !queue.contains(where: { $0.id == event.id }) else { return false }

        queue.append(event)
        return true
    }

    /// Dequeues the next celebration to show.
    /// Returns nil if already shown one this session or queue is empty.
    func dequeueNext() -> CelebrationEvent? {
        guard !hasShownThisSession else { return nil }
        guard !queue.isEmpty else { return nil }

        let event = queue.removeFirst()
        shownThisSession.insert(event.id)
        hasShownThisSession = true
        return event
    }

    /// Resets session tracking (call on app foreground).
    func resetSession() {
        hasShownThisSession = false
    }
}
