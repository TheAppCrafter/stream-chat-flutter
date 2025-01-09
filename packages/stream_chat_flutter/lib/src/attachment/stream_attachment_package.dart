import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// The [StreamAttachmentPackage] class is basically meant to wrap
/// individual attachments with their corresponding message
class StreamAttachmentPackage {
  /// Default constructor to prepare an [StreamAttachmentPackage] object
  StreamAttachmentPackage({
    required this.attachment,
    required this.message,
    this.channel,
    this.showAttachmentName = false,
  });

  /// This is the individual attachment
  final Attachment attachment;

  /// This is the message that the attachment belongs to
  /// The message object may have attachment(s) other than the one packaged
  final Message? message;

  /// This is the channel that the message and attachment belongs to
  final Channel? channel;

  /// This is a flag to show the attachment name
  final bool showAttachmentName;
}
