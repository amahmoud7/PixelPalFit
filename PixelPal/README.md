# Pixel Pal Steps Widget (iOS MVP)

A pixel-art avatar that reflects your daily step vitality.

## Project Structure
- `PixelPalApp.swift`: Main app entry point.
- `ContentView.swift`: Main dashboard.
- `Core/`: Shared logic (HealthKit, State, App Group).
- `Widget/`: Widget implementation.
- `RawAssets/`: Generated placeholder pixel art.

## Setup Instructions

1. **Create a new Xcode Project**
   - Open Xcode -> Create New Project -> iOS App.
   - Product Name: `PixelPal`.
   - Interface: SwiftUI.
   - Language: Swift.

2. **Add Source Files**
   - Drag the `Core` folder into the project. Make sure "Copy items if needed" is checked.
   - Drag `PixelPalApp.swift`, `ContentView.swift`, `AvatarView.swift`, `OnboardingView.swift` into the project, replacing existing files.

3. **Add Widget Extension**
   - File -> New -> Target -> Widget Extension.
   - Product Name: `PixelPalWidget`.
   - Uncheck "Include Live Activity" and "Include Configuration Intent" for simplicity.
   - Replace the generated `PixelPalWidget.swift` content with the code from `Widget/PixelPalWidget.swift`.

4. **Configure App Group**
   - Select the Project -> Signing & Capabilities.
   - Add "App Groups" capability to **BOTH** the App target and the Widget target.
   - Create a new group (e.g., `group.com.yourname.PixelPal`).
   - **IMPORTANT**: Update `SharedData.swift` with your actual App Group ID.

5. **Configure HealthKit**
   - Select the App target -> Signing & Capabilities.
   - Add "HealthKit" capability.
   - Add `NSHealthShareUsageDescription` and `NSHealthUpdateUsageDescription` to `Info.plist` with a message like "Pixel Pal uses your step count to energize your avatar."

6. **Target Membership**
   - Ensure `AvatarState.swift` and `SharedData.swift` are members of **BOTH** the App target and the Widget target.
   - Select the files -> File Inspector -> Check both targets.

7. **Assets**
   - Open `Assets.xcassets`.
   - Drag the images from `RawAssets/` into the asset catalog.
   - Rename them if necessary to match: `vital_1`, `vital_2`, `neutral_1`, `neutral_2`, `low_1`, `low_2`.

8. **Run**
   - Build and run on a physical device (HealthKit steps are better tested on device, though Simulator works with mock data).
