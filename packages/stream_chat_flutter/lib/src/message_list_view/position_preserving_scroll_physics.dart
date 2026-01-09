import 'package:flutter/material.dart';
import 'package:logging/logging.dart';

/// Callback type for checking if position should be preserved.
/// This is evaluated at runtime, not at widget construction time.
typedef ShouldPreservePosition = bool Function();

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
/// **Important**: Use [shouldPreservePositionCallback] instead of a fixed
/// boolean because Flutter caches ScrollPhysics objects. The callback is
/// evaluated at runtime when [adjustPositionForNewDimensions] is called.
///
/// See also:
/// - [ClampingScrollPhysics], which this extends
/// - [ScrollPhysics.adjustPositionForNewDimensions], the method we override
class PositionPreservingScrollPhysics extends ClampingScrollPhysics {
  /// Creates scroll physics that can preserve position during content updates.
  ///
  /// Use [shouldPreservePositionCallback] to dynamically determine if position
  /// should be preserved. This callback is evaluated at runtime, which is
  /// important because Flutter caches ScrollPhysics objects.
  const PositionPreservingScrollPhysics({
    super.parent,
    this.shouldPreservePositionCallback,
  });

  /// Logger for scroll stability debugging
  static final _logger = Logger.detached('StreamChat.ScrollStability');

  /// Callback to check if position should be preserved.
  ///
  /// This is called at runtime when [adjustPositionForNewDimensions] is
  /// invoked, allowing dynamic state changes to be reflected even though
  /// Flutter caches the ScrollPhysics object.
  ///
  /// If null, position preservation is disabled.
  final ShouldPreservePosition? shouldPreservePositionCallback;

  @override
  PositionPreservingScrollPhysics applyTo(ScrollPhysics? ancestor) {
    _logger.info(
      'Position preserving scroll physics enabled: maintaining stable '
      'scroll position during message content growth.',
    );
    return PositionPreservingScrollPhysics(
      parent: buildParent(ancestor),
      shouldPreservePositionCallback: shouldPreservePositionCallback,
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

    // Evaluate the callback at runtime to get current state
    final preservePosition = shouldPreservePositionCallback?.call() ?? false;

    // Only preserve position when ALL safety conditions are met:
    // 1. Feature is enabled (callback returns true)
    // 2. User is not actively scrolling (don't interfere with gestures)
    // 3. No animation is running (don't interfere with programmatic scrolls)
    // 4. Viewport dimensions unchanged (allow keyboard/rotation)
    // 5. Content change is small (allows pagination to work)
    final shouldPreserve = preservePosition &&
        !isScrolling &&
        velocity == 0 &&
        oldPosition.viewportDimension ==
            newPosition.viewportDimension &&
        extentChange.abs() < 500.0;

    if (shouldPreserve && extentChange != 0) {
      // CRITICAL: To keep the VISIBLE content frozen on screen, we need to
      // adjust the scroll position by the amount the content grew/shrunk.
      //
      // Example: User is at 1000px, message below viewport grows by 100px
      // - Without adjustment: position stays 1000px -> content shifts up
      // - With adjustment: position becomes 1100px -> same content visible
      //
      // This is the key difference: we're not just preserving the position,
      // we're adjusting it to compensate for content changes below viewport.
      final adjustedPosition = oldPosition.pixels + extentChange;

      _logger.fine(
        'Prevented list jump by adjusting scroll position after message '
        'content update. (Position maintained while user was scrolled '
        'away from bottom). Details: [old: '
        '${oldPosition.pixels.toStringAsFixed(1)}, change: '
        '${extentChange.toStringAsFixed(1)}, new: '
        '${adjustedPosition.toStringAsFixed(1)}]',
      );

      // Ensure the adjusted position is within valid bounds
      return adjustedPosition.clamp(
        newPosition.minScrollExtent,
        newPosition.maxScrollExtent,
      );
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
