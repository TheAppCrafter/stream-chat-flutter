import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// {@template copyMessageButton}
/// Allows a user to regnerate an AI message
///
/// Used by [MessageActionsModal]. Should not be used by itself.
/// {@endtemplate}
class HideMessageButton extends StatelessWidget {
  /// {@macro copyMessageButton}
  const HideMessageButton({
    super.key,
    required this.message,
    required this.onTap,
  });

  /// The Message to hide or unhide
  final Message message;

  /// The callback to perform when the button is tapped.
  final VoidCallback onTap;

  @override
  Widget build(BuildContext context) {
    final streamChatThemeData = StreamChatTheme.of(context);
    return InkWell(
      onTap: onTap,
      child: Padding(
        padding: const EdgeInsets.symmetric(vertical: 11, horizontal: 16),
        child: Row(
          children: [
            if (message.extraData['hidden'] == true)
              Icon(
                Icons.visibility_off,
                size: 24,
                color: streamChatThemeData.primaryIconTheme.color,
              ),
            if (message.extraData['hidden'] == false)
              Icon(
                Icons.visibility,
                size: 24,
                color: streamChatThemeData.primaryIconTheme.color,
              ),
            const SizedBox(width: 16),
            Text(
              message.extraData['hidden'] == true
                  ? 'Hide message'
                  : 'Unhide message',
              style: streamChatThemeData.textTheme.body,
            ),
          ],
        ),
      ),
    );
  }
}