import 'package:collection/collection.dart';
import 'package:flutter/widgets.dart';
import 'package:stream_chat_flutter/src/attachment/builder/attachment_widget_builder.dart';
import 'package:stream_chat_flutter/src/utils/extensions.dart';
import 'package:stream_chat_flutter_core/stream_chat_flutter_core.dart';

/// {@template attachmentWidgetCatalog}
/// A widget catalog which determines which attachment widget should be build
/// for a given [Message] and [Attachment] based on the list of [builders].
///
/// This is used by the [MessageWidget] to build the widget for the
/// [Message.attachments]. If you want to customize the widget used to show
/// attachments, you can use this to add your own attachment builder.
/// {@endtemplate}
///
/// See also:
///
///   * [StreamAttachmentWidgetBuilder], which is used to build a widget for a
///   given [Message] and [Attachment].
///   * [MessageWidget] which uses the [AttachmentWidgetCatalog] to build the
///   widget for the [Message.attachments].
class AttachmentWidgetCatalog {
  const AttachmentWidgetCatalog({required this.builders});

  final List<StreamAttachmentWidgetBuilder> builders;

  /// Builds a widget for the given [message] and [attachments].
  ///
  /// It iterates through the list of builders and ensures that only the first
  /// builder that can handle each **group** of attachments by type is used.
  ///
  /// A space is inserted between each built widget using `insertBetween`.
  Widget build(BuildContext context, Message message) {
    assert(!message.isDeleted, 'Cannot build attachment for deleted message');
    assert(
      message.attachments.isNotEmpty,
      'Cannot build attachment for message without attachments',
    );

    final attachments = message.attachments.grouped;
    final builtWidgets = <Widget>[];

    // Track which attachment types have been handled.
    final handledAttachmentTypes = <String>{};

    for (final builder in builders) {
      for (final entry in attachments.entries) {
        final attachmentType = entry.key;
        final attachmentGroup = entry.value;

        // Skip groups that have already been handled.
        if (handledAttachmentTypes.contains(attachmentType)) {
          continue;
        }

        // Create the map to pass to canHandle and build
        final attachmentMap = {attachmentType: attachmentGroup};

        // If the builder can handle the attachment group, build it.
        if (builder.canHandle(message, attachmentMap)) {
          handledAttachmentTypes.add(attachmentType); // Mark this group as handled
          builtWidgets.add(builder.build(context, message, attachmentMap));
          break; // Stop checking other builders for this attachment type
        }
      }
    }

    if (builtWidgets.isEmpty) {
      throw Exception('No builder found for $message and $attachments');
    }

    // Insert a space between each widget.
    return Column(
      children: builtWidgets.insertBetween(const SizedBox(height: 8)),
    );
  }
}

extension on List<Attachment> {
  /// Groups the attachments by their type.
  Map<String, List<Attachment>> get grouped {
    return groupBy(where((it) {
      return it.type != null;
    }), (attachment) => attachment.type!);
  }
}
