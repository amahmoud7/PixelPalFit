# Dynamic Island Advanced Animation Guide for Pixel Pace

## Executive Summary

This guide provides comprehensive technical details for building advanced, full-screen Dynamic Island animations for Pixel Pace. The goal: create an immersive pixel character that truly "lives" in the Dynamic Island.

**Key Insight:** Live Activities have animation limitations - `withAnimation` and `.repeatForever()` are **ignored**. However, there are creative workarounds to achieve smooth, continuous character animations.

---

## Part 1: Dynamic Island Technical Specifications

### 1.1 Size Constraints

| Region | Width | Height | Notes |
|--------|-------|--------|-------|
| **Compact Leading** | ~52 pt | ~37 pt | Left of camera |
| **Compact Trailing** | ~52 pt | ~37 pt | Right of camera |
| **Minimal** | ~45 pt | ~37 pt | Circular detached |
| **Expanded Total** | Full width | 160 pt max | Long-press view |
| **Expanded Bottom** | Full width | ~100 pt | Main content area |

**Corner Radius:** 44 points (matches TrueDepth camera housing)

### 1.2 Update Frequency Limits

| Update Type | Minimum Interval | Notes |
|-------------|------------------|-------|
| Standard | ~15-16 seconds | Throttled by system |
| Frequent (opt-in) | ~1 second | Requires user permission |
| Push Updates | Variable | Subject to APNS limits |

**To enable frequent updates, add to Info.plist:**
```xml
<key>NSSupportsLiveActivitiesFrequentUpdates</key>
<true/>
```

### 1.3 Duration Limits

- **Active:** Maximum 8 hours
- **Lock Screen (after end):** Up to 4 hours
- **Total visibility:** Maximum 12 hours

---

## Part 2: Animation Capabilities

### 2.1 What Works

| Technique | Supported | Notes |
|-----------|-----------|-------|
| `.contentTransition(.numericText())` | ✅ | Numbers animate smoothly |
| `.contentTransition(.opacity)` | ✅ | Fade transitions |
| `Text(date, style: .timer)` | ✅ | Self-updating, no API calls |
| `TimelineView(.periodic)` | ✅ | Time-based content changes |
| `TimelineView(.animation)` | ✅ | High-frequency updates |
| `.transition(.move)` | ✅ | View enter/exit |
| State-driven image swaps | ✅ | Change image based on state |

### 2.2 What Does NOT Work

| Technique | Status | Why |
|-----------|--------|-----|
| `withAnimation { }` | ❌ Ignored | System controls animations |
| `.animation(.easeInOut)` | ❌ Ignored | System controls timing |
| `.repeatForever()` | ❌ Ignored | No continuous loops |
| Custom animation curves | ❌ Ignored | Only system defaults |
| GIF playback | ❌ Not supported | Use sprite frames |

### 2.3 iOS 17+ Automatic Animations

Starting iOS 17, content updates automatically animate:
- **Text changes:** Blur transition
- **Image changes:** Fade transition
- **View additions:** Fade in
- **Maximum duration:** 2 seconds

---

## Part 3: Pixel Pace Animation Strategies

### 3.1 Strategy A: State-Driven Frame Animation

**How it works:** Update `ContentState` with a frame number, triggering image swap.

```swift
struct PixelPalAttributes: ActivityAttributes {
    public struct ContentState: Codable, Hashable {
        var steps: Int
        var stateRaw: String
        var genderRaw: String
        var animationFrame: Int  // 1-32 for walking
        var isWalking: Bool
    }
}
```

**In Live Activity View:**
```swift
struct DynamicIslandCharacterView: View {
    let context: ActivityViewContext<PixelPalAttributes>

    var spriteName: String {
        if context.state.isWalking {
            return "\(context.state.genderRaw)_walking_\(context.state.animationFrame)"
        } else {
            return "\(context.state.genderRaw)_\(context.state.stateRaw)_1"
        }
    }

    var body: some View {
        Image(spriteName)
            .interpolation(.none)
            .resizable()
            .scaledToFit()
            .contentTransition(.opacity) // Smooth fade between frames
    }
}
```

**Limitation:** Subject to 15-second throttling unless frequent updates enabled.

### 3.2 Strategy B: TimelineView for Local Animation

**How it works:** Use `TimelineView` to cycle through frames locally (no API updates).

```swift
struct AnimatedCharacterView: View {
    let gender: String
    let state: String

    var body: some View {
        TimelineView(.periodic(every: 0.5)) { timeline in
            let frame = frameNumber(from: timeline.date)

            Image("\(gender)_\(state)_\(frame)")
                .interpolation(.none)
                .resizable()
                .scaledToFit()
        }
    }

    private func frameNumber(from date: Date) -> Int {
        // Alternate between frame 1 and 2
        let seconds = Int(date.timeIntervalSince1970)
        return (seconds % 2) + 1
    }
}
```

**Advantage:** No API calls, animations run locally at full speed.

### 3.3 Strategy C: Canvas + TimelineView for Complex Animation

**How it works:** Use Canvas for pixel-perfect rendering with smooth movement.

```swift
struct PixelCharacterCanvas: View {
    let gender: String
    let state: String

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.042)) { timeline in
            Canvas { context, size in
                let time = timeline.date.timeIntervalSinceReferenceDate

                // Breathing animation (subtle up/down)
                let breathOffset = sin(time * 2) * 2

                // Frame selection (2 frames)
                let frame = Int(time * 2) % 2 + 1

                if let image = context.resolve(Image("\(gender)_\(state)_\(frame)")) {
                    let rect = CGRect(
                        x: (size.width - 40) / 2,
                        y: (size.height - 40) / 2 + breathOffset,
                        width: 40,
                        height: 40
                    )
                    context.draw(image, in: rect)
                }
            }
        }
    }
}
```

### 3.4 Strategy D: Walking Animation with 32 Frames

For smooth walking animation during active movement:

```swift
struct WalkingAnimationView: View {
    let gender: String
    @State private var currentFrame = 1

    // 24 FPS = 42ms per frame
    let timer = Timer.publish(every: 0.042, on: .main, in: .common).autoconnect()

    var body: some View {
        Image("\(gender)_walking_\(currentFrame)")
            .interpolation(.none)
            .resizable()
            .scaledToFit()
            .onReceive(timer) { _ in
                currentFrame = (currentFrame % 32) + 1
            }
    }
}
```

**Asset Requirements:**
- 32 frames per gender: `male_walking_1` through `male_walking_32`
- 32x32 or 64x64 PNG sprites
- Transparent background
- Consistent character position across frames

---

## Part 4: Full Dynamic Island Layout for Pixel Pace

### 4.1 Recommended Layout

```
┌─────────────────────────────────────────────────┐
│                  EXPANDED VIEW                   │
├─────────────────────────────────────────────────┤
│  ┌──────┐                          ┌──────────┐ │
│  │      │    ● ● ● ●               │  12,345  │ │
│  │ 🧍   │    Phase 3               │  steps   │ │
│  │      │                          └──────────┘ │
│  └──────┘                                       │
│─────────────────────────────────────────────────│
│                                                 │
│           ┌──────────────────────┐              │
│           │                      │              │
│           │    🚶 WALKING 🚶     │              │
│           │    Large animated    │              │
│           │      character       │              │
│           │                      │              │
│           └──────────────────────┘              │
│                                                 │
└─────────────────────────────────────────────────┘

┌─────────────────────────────────────────────────┐
│                  COMPACT VIEW                    │
├─────────────────────────────────────────────────┤
│     🧍     │    ◉◉◉◉    │     ⭐ P3              │
│  Leading   │   Camera   │    Trailing            │
└─────────────────────────────────────────────────┘

┌──────────┐
│ MINIMAL  │
│    🧍    │
└──────────┘
```

### 4.2 Complete Implementation

```swift
import ActivityKit
import SwiftUI
import WidgetKit

struct PixelPalLiveActivity: Widget {
    var body: some WidgetConfiguration {
        ActivityConfiguration(for: PixelPalAttributes.self) { context in
            // Lock Screen View
            LockScreenView(context: context)
        } dynamicIsland: { context in
            DynamicIsland {
                // EXPANDED: Leading - Character
                DynamicIslandExpandedRegion(.leading) {
                    ExpandedLeadingView(context: context)
                }

                // EXPANDED: Trailing - Steps (only when walking/milestone)
                DynamicIslandExpandedRegion(.trailing) {
                    ExpandedTrailingView(context: context)
                }

                // EXPANDED: Center - Phase indicator
                DynamicIslandExpandedRegion(.center) {
                    PhaseIndicator(phase: context.state.currentPhase)
                }

                // EXPANDED: Bottom - Large animated character
                DynamicIslandExpandedRegion(.bottom) {
                    ExpandedBottomView(context: context)
                }
            } compactLeading: {
                // Small animated character
                CompactCharacterView(context: context)
            } compactTrailing: {
                // Phase icon or step count
                CompactTrailingView(context: context)
            } minimal: {
                // Tiny character only
                MinimalCharacterView(context: context)
            }
            .keylineTint(phaseColor(context.state.currentPhase))
        }
    }

    private func phaseColor(_ phase: Int) -> Color {
        switch phase {
        case 1: return .gray
        case 2: return .blue
        case 3: return .purple
        case 4: return .orange
        default: return .gray
        }
    }
}

// MARK: - Expanded Bottom (Main Animation Area)

struct ExpandedBottomView: View {
    let context: ActivityViewContext<PixelPalAttributes>

    var body: some View {
        ZStack {
            if context.state.isWalking {
                // Large walking animation
                WalkingCharacterView(
                    gender: context.state.genderRaw,
                    frame: context.state.walkingFrame
                )
                .frame(height: 100)
            } else {
                // Idle breathing animation
                IdleCharacterView(
                    gender: context.state.genderRaw,
                    state: context.state.stateRaw
                )
                .frame(height: 80)
            }
        }
    }
}

struct WalkingCharacterView: View {
    let gender: String
    let frame: Int

    var body: some View {
        TimelineView(.animation(minimumInterval: 0.042)) { timeline in
            let localFrame = calculateFrame(from: timeline.date)

            Image("\(gender)_walking_\(localFrame)")
                .interpolation(.none)
                .resizable()
                .scaledToFit()
        }
    }

    private func calculateFrame(from date: Date) -> Int {
        // Cycle through 32 frames at 24 FPS
        let elapsed = date.timeIntervalSinceReferenceDate
        return Int(elapsed * 24) % 32 + 1
    }
}

struct IdleCharacterView: View {
    let gender: String
    let state: String

    var body: some View {
        TimelineView(.periodic(every: 0.8)) { timeline in
            let frame = calculateFrame(from: timeline.date)

            // Add subtle breathing motion
            let breathOffset = sin(timeline.date.timeIntervalSinceReferenceDate * 2) * 2

            Image("\(gender)_\(state)_\(frame)")
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .offset(y: breathOffset)
        }
    }

    private func calculateFrame(from date: Date) -> Int {
        return Int(date.timeIntervalSince1970) % 2 + 1
    }
}

// MARK: - Compact Views

struct CompactCharacterView: View {
    let context: ActivityViewContext<PixelPalAttributes>

    var body: some View {
        TimelineView(.periodic(every: 0.5)) { timeline in
            let frame = Int(timeline.date.timeIntervalSince1970) % 2 + 1
            let spriteName: String

            if context.state.isWalking {
                // Simplified walking (use 2-frame cycle for compact)
                spriteName = "\(context.state.genderRaw)_walking_\(frame)"
            } else {
                spriteName = "\(context.state.genderRaw)_\(context.state.stateRaw)_\(frame)"
            }

            Image(spriteName)
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: 28, height: 28)
        }
    }
}

struct CompactTrailingView: View {
    let context: ActivityViewContext<PixelPalAttributes>

    var body: some View {
        if let milestone = context.state.milestoneText {
            // Milestone celebration
            Text(milestone)
                .font(.caption)
                .fontWeight(.bold)
                .foregroundColor(.green)
        } else if context.state.isWalking {
            // Walking: show steps
            Text("\(context.state.steps)")
                .font(.caption2)
                .fontWeight(.semibold)
                .contentTransition(.numericText())
        } else {
            // Idle: show phase icon
            PhaseIcon(phase: context.state.currentPhase)
        }
    }
}

struct MinimalCharacterView: View {
    let context: ActivityViewContext<PixelPalAttributes>

    var body: some View {
        TimelineView(.periodic(every: 0.8)) { timeline in
            let frame = Int(timeline.date.timeIntervalSince1970) % 2 + 1

            Image("\(context.state.genderRaw)_\(context.state.stateRaw)_\(frame)")
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: 20, height: 20)
        }
    }
}

// MARK: - Phase Indicator

struct PhaseIndicator: View {
    let phase: Int

    var body: some View {
        HStack(spacing: 4) {
            ForEach(1...4, id: \.self) { p in
                Circle()
                    .fill(p <= phase ? phaseColor(p) : Color.gray.opacity(0.3))
                    .frame(width: 6, height: 6)
            }
        }
    }

    private func phaseColor(_ phase: Int) -> Color {
        switch phase {
        case 1: return .gray
        case 2: return .blue
        case 3: return .purple
        case 4: return .orange
        default: return .gray
        }
    }
}

struct PhaseIcon: View {
    let phase: Int

    private var iconName: String {
        switch phase {
        case 1: return "circle"
        case 2: return "circle.fill"
        case 3: return "star.fill"
        case 4: return "sparkles"
        default: return "circle"
        }
    }

    private var color: Color {
        switch phase {
        case 1: return .gray
        case 2: return .blue
        case 3: return .purple
        case 4: return .orange
        default: return .gray
        }
    }

    var body: some View {
        Image(systemName: iconName)
            .font(.caption2)
            .foregroundColor(color)
    }
}
```

---

## Part 5: Asset Requirements

### 5.1 Sprite Specifications

| Asset Type | Size | Frames | Format |
|------------|------|--------|--------|
| Idle (vital) | 32x32 | 2 | PNG, transparent |
| Idle (neutral) | 32x32 | 2 | PNG, transparent |
| Idle (low) | 32x32 | 2 | PNG, transparent |
| Walking | 32x32 or 64x64 | 32 | PNG, transparent |

### 5.2 Required Assets for Full Animation

**Per Gender (Male + Female):**
```
// Idle states (2 frames each)
male_vital_1.png, male_vital_2.png
male_neutral_1.png, male_neutral_2.png
male_low_1.png, male_low_2.png

// Walking animation (32 frames)
male_walking_1.png through male_walking_32.png

// Same for female
female_vital_1.png, female_vital_2.png
female_neutral_1.png, female_neutral_2.png
female_low_1.png, female_low_2.png
female_walking_1.png through female_walking_32.png
```

**Total: 76 sprites (38 per gender)**

### 5.3 Walking Animation Frame Breakdown

For a natural walking cycle, distribute the 32 frames:

| Frames | Action |
|--------|--------|
| 1-4 | Right leg forward, starting step |
| 5-8 | Right leg contact, weight transfer |
| 9-12 | Right leg push-off |
| 13-16 | Both legs passing (mid-stride) |
| 17-20 | Left leg forward, starting step |
| 21-24 | Left leg contact, weight transfer |
| 25-28 | Left leg push-off |
| 29-32 | Both legs passing, return to start |

---

## Part 6: Performance Optimization

### 6.1 Frame Rate Management

```swift
// Check if user has reduced motion enabled
@Environment(\.accessibilityReduceMotion) var reduceMotion

var animationInterval: TimeInterval {
    reduceMotion ? 1.0 : 0.042 // 24 FPS vs 1 FPS
}
```

### 6.2 Always-On Display Handling

```swift
@Environment(\.isLuminanceReduced) var isLuminanceReduced

var body: some View {
    if isLuminanceReduced {
        // Static image for Always-On Display
        Image("\(gender)_\(state)_1")
            .interpolation(.none)
            .resizable()
            .scaledToFit()
    } else {
        // Animated content
        AnimatedCharacterView(gender: gender, state: state)
    }
}
```

### 6.3 Battery Considerations

| Optimization | Impact |
|--------------|--------|
| Use `TimelineView(.periodic(every: 0.5))` | Medium battery |
| Use `TimelineView(.animation)` | Higher battery |
| Check `isLuminanceReduced` | Saves battery on AOD |
| Limit to 2-frame idle | Lower battery |

---

## Part 7: Testing Checklist

### 7.1 Device Testing

- [ ] iPhone 14 Pro / Pro Max
- [ ] iPhone 15 Pro / Pro Max
- [ ] iPhone 16 Pro / Pro Max
- [ ] iOS Simulator (limited animation support)

### 7.2 Scenario Testing

- [ ] **Idle state:** Character breathes/toggles frames
- [ ] **Walking state:** Smooth 32-frame animation
- [ ] **Transition:** Idle → Walking → Idle
- [ ] **Expanded view:** Large character fills bottom region
- [ ] **Compact view:** Small character animates in leading
- [ ] **Minimal view:** Tiny character visible
- [ ] **Multiple activities:** Your activity + another app
- [ ] **Always-On Display:** Static image, no animation
- [ ] **Reduced Motion:** Slower/no animation

### 7.3 Edge Cases

- [ ] App killed while Live Activity running
- [ ] Device reboot with active Live Activity
- [ ] 8-hour duration limit reached
- [ ] User disables Live Activities mid-session

---

## Part 8: Implementation Roadmap for Pixel Pace

### Phase 1: Enhanced Idle Animation (Week 1)
- [ ] Add breathing motion to idle characters
- [ ] Implement TimelineView for local animation
- [ ] Test on real devices

### Phase 2: Walking Animation Assets (Week 2)
- [ ] Create 32-frame walking sprites (male)
- [ ] Create 32-frame walking sprites (female)
- [ ] Add to Asset Catalog

### Phase 3: Walking Animation Integration (Week 3)
- [ ] Update PixelPalAttributes with walking state
- [ ] Implement WalkingCharacterView
- [ ] Update LiveActivityManager with walking detection

### Phase 4: Expanded View Enhancement (Week 4)
- [ ] Redesign expanded bottom with large character
- [ ] Add phase progress dots
- [ ] Polish transitions between states

### Phase 5: Testing & Optimization (Week 5)
- [ ] Test on all supported devices
- [ ] Optimize for battery
- [ ] Handle edge cases
- [ ] Submit update to App Store

---

## Conclusion

The Dynamic Island offers a unique opportunity to create an immersive, always-visible pixel companion. While Apple limits traditional animations, creative use of `TimelineView`, state-driven updates, and Canvas rendering can achieve smooth, engaging character animations.

**Key takeaways:**
1. Use `TimelineView(.periodic)` for local animations (no API calls)
2. Reserve state updates for meaningful changes (walking start/stop)
3. Keep 32 frames for walking, 2 frames for idle
4. Always handle Always-On Display and Reduced Motion
5. Test on real devices - Simulator has limited animation support

---

## References

- [Apple Developer: DynamicIsland](https://developer.apple.com/documentation/widgetkit/dynamicisland)
- [Apple Developer: ActivityKit](https://developer.apple.com/documentation/activitykit)
- [WWDC23: Meet ActivityKit](https://developer.apple.com/videos/play/wwdc2023/10184/)
- [WWDC23: Design Dynamic Live Activities](https://developer.apple.com/videos/play/wwdc2023/10194/)
- [Swift with Majid: Mastering Dynamic Island](https://swiftwithmajid.com/2022/09/28/mastering-dynamic-island-in-swiftui/)
