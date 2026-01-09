import 'package:flutter/material.dart';

/// Custom scroll physics that preserves scroll position during message content
/// updates while respecting viewport changes and other scroll behaviors.
///
/// This physics is specifically designed to prevent scroll position jumping
/// when messages grow (e.g., during AI text streaming) while the user is
/// scrolled away from the bottom of the list.
///
/// The physics only preserves position when ALL safety conditions are met:
/// - Not actively scrolling (respects user gestures)
/// - No animation running (respects programmatic scrolls)
/// - Viewport dimensions unchanged (allows keyboard/rotation adjustments)
/// - Small content changes only (allows pagination to work normally)
///
/// See also:
/// - [ClampingScrollPhysics], which this extends
/// - [ScrollPhysics.adjustPositionForNewDimensions], the method we override
class PositionPreservingScrollPhysics extends ClampingScrollPhysics {
  /// Creates scroll physics that can preserve position during content updates.
  ///
  /// When [preservePosition] is true and safety conditions are met, the scroll
  /// position will be maintained even when content dimensions change.
  const PositionPreservingScrollPhysics({
    super.parent,
    required this.preservePosition,
  });

  /// When true, attempts to preserve scroll position during content updates.
  ///
  /// Position is only preserved when additional safety checks pass:
  /// - User is not actively scrolling
  /// - No scroll animation is running
  /// - Viewport size hasn't changed (not keyboard/rotation)
  /// - Content change is small (< 500px, not pagination)
  final bool preservePosition;

  @override
  PositionPreservingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    return PositionPreservingScrollPhysics(
      parent: buildParent(ancestor),
      preservePosition: preservePosition,
    );
  }

  @override
  double adjustPositionForNewDimensions({
    required ScrollMetrics oldPosition,
    required ScrollMetrics newPosition,
    required bool isScrolling,
    required double velocity,
  }) {
    // Calculate how much the scrollable content extent changed
    final extentChange =
        newPosition.maxScrollExtent - oldPosition.maxScrollExtent;

    // Only preserve position when ALL safety conditions are met:
    // 1. Feature is enabled
    // 2. User is not actively scrolling (don't interfere with gestures)
    // 3. No animation is running (don't interfere with programmatic scrolls)
    // 4. Viewport dimensions unchanged (allow keyboard/rotation adjustments)
    // 5. Content change is small (allow pagination to work normally)
    final shouldPreserve = preservePosition &&
        !isScrolling &&
        velocity == 0 &&
        oldPosition.viewportDimension == newPosition.viewportDimension &&
        extentChange.abs() < 500.0;

    if (shouldPreserve) {
      // Maintain exact scroll position - prevents jumping during message growth
      return oldPosition.pixels;
    }

    // Otherwise, use default ClampingScrollPhysics behavior
    // This handles keyboard appearance, rotation, pagination, etc.
    return super.adjustPositionForNewDimensions(
      oldPosition: oldPosition,
      newPosition: newPosition,
      isScrolling: isScrolling,
      velocity: velocity,
    );
  }
}
