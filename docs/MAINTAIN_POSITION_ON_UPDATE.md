# Maintain Position On Update Feature

## Overview

The `maintainPositionOnUpdate` feature prevents the message list from automatically jumping when message content updates (e.g., during AI text streaming) while the user is scrolled away from the bottom.

## Implementation

### Files Created/Modified

1. **New File**: `lib/src/message_list_view/position_preserving_scroll_physics.dart`
   - Custom `ScrollPhysics` that overrides `adjustPositionForNewDimensions`.
   - Uses a runtime callback to bypass Flutter's internal physics caching.
   - Includes safety checks for viewport changes, active scrolling, and animations.
   
2. **Modified**: `lib/src/message_list_view/message_list_view.dart`
   - Added `maintainPositionOnUpdate` boolean parameter (default: `true`).
   - Added `_preservingPosition` state flag and a 500ms sliding window `Timer`.
   - Added content update detection in `_buildListView`.
   - Integrated custom physics with `ScrollablePositionedList`.

## How It Works

### Detection Logic

The feature activates when ALL conditions are met:
- Message count unchanged (content update, not new messages).
- User scrolled away from bottom (`_inBetweenList == true`).
- Feature enabled (`maintainPositionOnUpdate == true`).

### The Timer Mechanism (Sliding Window)

A 500ms `Timer` is used to maintain the `_preservingPosition` state for several reasons:

1. **Build vs. Layout Sync**: Flutter builds the widget tree first, but the `ScrollPhysics` doesn't see content size changes until the Layout phase. The timer ensures the flag stays active long enough for the layout engine to perform the pixel adjustment.
2. **Burst Updates**: AI messages stream rapidly. The timer resets on every new character, creating a continuous "window" of stability during active streaming.
3. **Graceful Exit**: Once streaming stops for 500ms, the timer expires and disables preservation, returning the list to default behavior automatically.

### The Physics Callback (Caching Bypass)

Flutter caches `ScrollPhysics` objects internally. To ensure state changes are reflected immediately without creating new physics objects constantly, we use a callback:

```dart
physics: PositionPreservingScrollPhysics(
  shouldPreservePositionCallback: () => _preservingPosition,
)
```

This allow the physics object to read the current state of the `MessageListView` at the exact moment the layout engine performs an adjustment.

### Safety Checks in ScrollPhysics

Position is only preserved when:
- ✅ Not actively scrolling (`isScrolling == false`).
- ✅ No animation running (`velocity == 0`).
- ✅ Viewport unchanged (`oldPosition.viewportDimension == newPosition.viewportDimension`).
- ✅ Small content change (`extentChange.abs() < 500px`).

These checks ensure:
- Keyboard appearance/dismissal works normally.
- Device rotation works normally.
- Pagination works normally.
- User gestures are not interfered with.
- Programmatic scrolls work normally.

## Usage

### Basic Usage (Default Behavior)

```dart
// Position preservation is enabled by default
StreamMessageListView(
  // ... other parameters
)
```

### Disabling Position Preservation

```dart
// Disable if you want default Flutter scroll behavior
StreamMessageListView(
  maintainPositionOnUpdate: false,
  // ... other parameters
)
```

## Use Cases

### Primary Use Case: AI Streaming Messages

Perfect for chat applications where AI assistants stream responses:

```dart
// AI message text grows character by character
// Without this feature: list jumps on each update
// With this feature: list position stays stable

StreamMessageListView(
  maintainPositionOnUpdate: true, // Enable (default)
  // ... other parameters
)
```

### When to Disable

Consider disabling if:
- You want messages to "push" content up as they grow.
- You have custom scroll behavior that conflicts.
- You're experiencing unexpected scroll issues.

## Performance

- **Overhead**: ~0.01ms per rebuild (O(1) boolean checks + simple arithmetic).
- **Memory**: Negligible (one boolean flag + one Timer).
- **Impact**: Zero - maintains 60/120 FPS during streaming by respecting `isScrolling` and `velocity` flags.

## Edge Cases Handled

| Scenario | Behavior |
|----------|----------|
| Keyboard appears | Position adjusts (viewport check) |
| Device rotation | Position adjusts (viewport check) |
| Pagination | Position adjusts (extent change check) |
| User scrolls | No preservation (isScrolling check) |
| Animation running | No preservation (velocity check) |
| Own message sent | Auto-scrolls to bottom (uses controller) |
| Message grows >500px | Position may jump (threshold exceeded) |

## Related Files

- Implementation: `position_preserving_scroll_physics.dart`
- Integration: `message_list_view.dart`

## References

- Flutter ScrollPhysics: https://api.flutter.dev/flutter/widgets/ScrollPhysics-class.html
- adjustPositionForNewDimensions: https://api.flutter.dev/flutter/widgets/ScrollPhysics/adjustPositionForNewDimensions.html
