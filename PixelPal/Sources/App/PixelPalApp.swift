import SwiftUI

@main
struct PixelStepperApp: App {
    @StateObject private var healthManager = HealthKitManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(healthManager)
        }
    }
}
