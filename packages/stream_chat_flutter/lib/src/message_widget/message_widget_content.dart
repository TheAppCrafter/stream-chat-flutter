import 'package:flutter/material.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:meta/meta.dart';
import 'package:stream_chat_flutter/src/message_widget/reactions/desktop_reactions_builder.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// Signature for the builder function that will be called when the message
/// bottom row is built. Includes the [Message].
typedef BottomRowBuilder = Widget Function(BuildContext, Message);

/// Signature for the builder function that will be called when the message
/// bottom row is built. Includes the [Message] and the default [BottomRow].
typedef BottomRowBuilderWithDefaultWidget = Widget Function(
  BuildContext,
  Message,
  BottomRow,
);

/// {@template messageWidgetContent}
/// The main content of a [StreamMessageWidget].
///
/// Should not be used outside of [MessageWidget.
/// {@endtemplate}
@internal
class MessageWidgetContent extends StatelessWidget {
  /// {@macro messageWidgetContent}
  const MessageWidgetContent({
    super.key,
    required this.reverse,
    required this.isPinned,
    required this.showPinHighlight,
    required this.showBottomRow,
    required this.message,
    required this.showUserAvatar,
    required this.avatarWidth,
    required this.showReactions,
    required this.onReactionsTap,
    required this.onReactionsHover,
    required this.messageTheme,
    required this.streamChatTheme,
    required this.isFailedState,
    required this.hasQuotedMessage,
    required this.hasUrlAttachments,
    required this.hasNonUrlAttachments,
    required this.hasPoll,
    required this.isOnlyEmoji,
    required this.isGiphy,
    required this.attachmentBuilders,
    required this.attachmentPadding,
    required this.attachmentShape,
    required this.onAttachmentTap,
    required this.onShowMessage,
    required this.onReplyTap,
    required this.attachmentActionsModalBuilder,
    required this.textPadding,
    required this.showReactionPickerTail,
    required this.translateUserAvatar,
    required this.bottomRowPadding,
    required this.showInChannel,
    required this.streamChat,
    required this.showSendingIndicator,
    required this.showThreadReplyIndicator,
    required this.showTimeStamp,
    required this.showUsername,
    required this.showEditedLabel,
    required this.messageWidget,
    required this.onThreadTap,
    this.onUserAvatarTap,
    this.borderRadiusGeometry,
    this.borderSide,
    this.shape,
    this.onQuotedMessageTap,
    this.onMentionTap,
    this.onLinkTap,
    this.textBuilder,
    this.quotedMessageBuilder,
    this.bottomRowBuilderWithDefaultWidget,
    this.userAvatarBuilder,
    this.textBubbleBuilder,
    this.actionBar,
  });

  /// {@macro reverse}
  final bool reverse;

  /// {@macro isPinned}
  final bool isPinned;

  /// {@macro showPinHighlight}
  final bool showPinHighlight;

  /// {@macro showBottomRow}
  final bool showBottomRow;

  /// {@macro message}
  final Message message;

  /// {@macro showUserAvatar}
  final DisplayWidget showUserAvatar;

  /// The width of the avatar.
  final double avatarWidth;

  /// {@macro showReactions}
  final bool showReactions;

  /// {@macro onReactionsTap}
  final VoidCallback onReactionsTap;

  /// {@macro onReactionsHover}
  final OnReactionsHover? onReactionsHover;

  /// {@macro messageTheme}
  final StreamMessageThemeData messageTheme;

  /// {@macro onUserAvatarTap}
  final void Function(User)? onUserAvatarTap;

  /// {@macro streamChatThemeData}
  final StreamChatThemeData streamChatTheme;

  /// {@macro isFailedState}
  final bool isFailedState;

  /// {@macro borderRadiusGeometry}
  final BorderRadiusGeometry? borderRadiusGeometry;

  /// {@macro borderSide}
  final BorderSide? borderSide;

  /// {@macro shape}
  final ShapeBorder? shape;

  /// {@macro hasQuotedMessage}
  final bool hasQuotedMessage;

  /// {@macro hasUrlAttachments}
  final bool hasUrlAttachments;

  /// {@macro hasNonUrlAttachments}
  final bool hasNonUrlAttachments;

  /// {@macro hasPoll}
  final bool hasPoll;

  /// {@macro isOnlyEmoji}
  final bool isOnlyEmoji;

  /// {@macro isGiphy}
  final bool isGiphy;

  /// {@macro attachmentBuilders}
  final List<StreamAttachmentWidgetBuilder>? attachmentBuilders;

  /// {@macro attachmentPadding}
  final EdgeInsetsGeometry attachmentPadding;

  /// {@macro attachmentShape}
  final ShapeBorder? attachmentShape;

  /// {@macro onAttachmentTap}
  final StreamAttachmentWidgetTapCallback? onAttachmentTap;

  /// {@macro onShowMessage}
  final ShowMessageCallback? onShowMessage;

  /// {@macro onReplyTap}
  final void Function(Message)? onReplyTap;

  /// {@macro onThreadTap}
  final void Function(Message)? onThreadTap;

  /// {@macro attachmentActionsBuilder}
  final AttachmentActionsBuilder? attachmentActionsModalBuilder;

  /// {@macro textPadding}
  final EdgeInsets textPadding;

  /// {@macro onQuotedMessageTap}
  final OnQuotedMessageTap? onQuotedMessageTap;

  /// {@macro onMentionTap}
  final void Function(User)? onMentionTap;

  /// {@macro onLinkTap}
  final void Function(String)? onLinkTap;

  /// {@macro textBuilder}
  final Widget Function(BuildContext, Message)? textBuilder;

  /// {@macro quotedMessageBuilder}
  final Widget Function(BuildContext, Message)? quotedMessageBuilder;

  /// {@macro showReactionPickerTail}
  final bool showReactionPickerTail;

  /// {@macro translateUserAvatar}
  final bool translateUserAvatar;

  /// The padding to use for this widget.
  final double bottomRowPadding;

  /// {@macro bottomRowBuilderWithDefaultWidget}
  final BottomRowBuilderWithDefaultWidget? bottomRowBuilderWithDefaultWidget;

  /// {@macro showInChannelIndicator}
  final bool showInChannel;

  /// {@macro streamChat}
  final StreamChatState streamChat;

  /// {@macro showSendingIndicator}
  final bool showSendingIndicator;

  /// {@macro showThreadReplyIndicator}
  final bool showThreadReplyIndicator;

  /// {@macro showTimestamp}
  final bool showTimeStamp;

  /// {@macro showUsername}
  final bool showUsername;

  /// {@macro showEdited}
  final bool showEditedLabel;

  /// {@macro messageWidget}
  final StreamMessageWidget messageWidget;

  /// {@macro userAvatarBuilder}
  final Widget Function(BuildContext, User)? userAvatarBuilder;

  /// {@macro textBubbleBuilder}
  final TextBubbleBuilder? textBubbleBuilder;

  /// {@macro actionBar}
  final Widget Function()? actionBar;

  @override
  Widget build(BuildContext context) {
    final bottomWidgetsHeight = showBottomRow ? 55.0 : 0.0;
    return Column(
      crossAxisAlignment:
          reverse ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      children: [
        Stack(
          clipBehavior: Clip.none,
          alignment: reverse
              ? AlignmentDirectional.bottomEnd
              : AlignmentDirectional.bottomStart,
          children: [
            Padding(
              padding: EdgeInsets.only(
                bottom: isPinned && showPinHighlight ? 8.0 : 0.0,
              ),
              child: Column(
                crossAxisAlignment:
                    reverse ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: [
                  if (message.pinned &&
                      message.pinnedBy != null &&
                      showPinHighlight)
                    PinnedMessage(
                      pinnedBy: message.pinnedBy!,
                      currentUser: streamChat.currentUser!,
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!reverse && showUserAvatar == DisplayWidget.show && message.user != null) ...[
                        userAvatarWidget(bottomWidgetsHeight),
                        const SizedBox(width: 4),
                      ],

                      Flexible(
                        child: PortalTarget(
                          visible: isMobileDevice && showReactions,
                          portalFollower: isMobileDevice && showReactions
                              ? ReactionIndicator(
                                  message: message,
                                  messageTheme: messageTheme,
                                  ownId: streamChat.currentUser!.id,
                                  reverse: reverse,
                                  onTap: onReactionsTap,
                                )
                              : null,
                          anchor: Aligned(
                            follower: Alignment(
                              reverse ? 1 : -1,
                              -1,
                            ),
                            target: Alignment(
                              reverse ? -1 : 1,
                              -1,
                            ),
                          ),
                          child: Align(
                            alignment: reverse ? Alignment.centerRight : Alignment.centerLeft,
                            child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              Padding(
                                padding: showReactions
                                    ? const EdgeInsets.only(top: 18)
                                    : EdgeInsets.zero,
                                child: (message.isDeleted && !isFailedState)
                                    ? Container(
                                        margin: EdgeInsets.symmetric(
                                          horizontal: showUserAvatar ==
                                                  DisplayWidget.gone
                                              ? 0
                                              : 4.0,
                                        ),
                                        child: StreamDeletedMessage(
                                          borderRadiusGeometry:
                                              borderRadiusGeometry,
                                          borderSide: borderSide,
                                          shape: shape,
                                          messageTheme: messageTheme,
                                        ),
                                      )
                                    : Column(
                                        crossAxisAlignment: reverse ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                        mainAxisSize: MainAxisSize.min,
                                        children: [
                                          MessageCard(
                                            message: message,
                                            isFailedState: isFailedState,
                                            showUserAvatar: showUserAvatar,
                                            messageTheme: messageTheme,
                                            hasQuotedMessage: hasQuotedMessage,
                                            hasUrlAttachments: hasUrlAttachments,
                                            hasNonUrlAttachments:
                                                hasNonUrlAttachments,
                                            hasPoll: hasPoll,
                                            isOnlyEmoji: isOnlyEmoji,
                                            isGiphy: isGiphy,
                                            attachmentBuilders: attachmentBuilders,
                                            attachmentPadding: attachmentPadding,
                                            attachmentShape: attachmentShape,
                                            onAttachmentTap: onAttachmentTap,
                                            onReplyTap: onReplyTap,
                                            onShowMessage: onShowMessage,
                                            attachmentActionsModalBuilder:
                                                attachmentActionsModalBuilder,
                                            textPadding: textPadding,
                                            reverse: reverse,
                                            onQuotedMessageTap: onQuotedMessageTap,
                                            onMentionTap: onMentionTap,
                                            onLinkTap: onLinkTap,
                                            textBuilder: textBuilder,
                                            quotedMessageBuilder:
                                                quotedMessageBuilder,
                                            borderRadiusGeometry:
                                                borderRadiusGeometry,
                                            borderSide: borderSide,
                                            shape: shape,
                                            textBubbleBuilder: textBubbleBuilder,
                                          ),
                                          Container(
                                            padding: EdgeInsets.zero,
                                            height: bottomWidgetsHeight,
                                            child: Column(
                                              mainAxisSize: MainAxisSize.min,
                                              crossAxisAlignment: reverse ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                              children: bottomWidgets(context, bottomWidgetsHeight),
                                            ),
                                          ),
                                        ],
                                  ),
                              ),
                              /*
                              // TODO: Make tail part of the Reaction Picker.
                              if (showReactionPickerTail)
                                Positioned(
                                  right: reverse ? null : 4,
                                  left: reverse ? 4 : null,
                                  top: -8,
                                  child: CustomPaint(
                                    painter: ReactionBubblePainter(
                                      streamChatTheme.colorTheme.barsBg,
                                      Colors.transparent,
                                      Colors.transparent,
                                      tailCirclesSpace: 1,
                                      flipTail: !reverse,
                                    ),
                                  ),
                                ),
                              */
                            ],
                          ),
                        ),
                        ),
                      ),
                      if (reverse && showUserAvatar == DisplayWidget.show && message.user != null) ...[
                          const SizedBox(width: 4),
                          userAvatarWidget(bottomWidgetsHeight)
                      ],
                    ],
                  ),
                  /*
                  if (showBottomRow)
                    SizedBox(
                      height: context.textScaleFactor * 18.0,
                    ),
                  */
                ],
              ),
            ),
            if (isFailedState)
              Positioned(
                right: reverse ? 0 : null,
                left: reverse ? null : 0,
                bottom: showBottomRow ? 18 : -2,
                child: StreamSvgIcon.error(size: 20),
              ),
          ],
        ),
      ],
    );
  }

  Widget userAvatarWidget(double bottomWidgetsHeight) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.end,
      children: [
        UserAvatarTransform(
          onUserAvatarTap: onUserAvatarTap,
          userAvatarBuilder: userAvatarBuilder,
          translateUserAvatar: translateUserAvatar,
          messageTheme: messageTheme,
          message: message,
        ),
        SizedBox(height: bottomWidgetsHeight),
      ],
    );
  }

  List<Widget> bottomWidgets(BuildContext context, double bottomWidgetsHeight){
    return [
      if (showBottomRow)
        Padding(
          padding: reverse ? const EdgeInsets.fromLTRB(0, 0, 10, 0): const EdgeInsets.fromLTRB(10, 0, 0, 0),
          child: Align(
            alignment: reverse ? Alignment.topRight : Alignment.topLeft,
            child: Row(
              mainAxisSize: MainAxisSize.min,
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: _buildRowChildren(context),
            ),
          ),
      ),
      const SizedBox(height: 8),
      if (actionBar != null)
        Padding(
          padding: reverse ? const EdgeInsets.fromLTRB(0, 0, 10, 0): const EdgeInsets.fromLTRB(10, 0, 0, 0),
          child: Align(
            alignment: reverse ? Alignment.topRight : Alignment.topLeft,
            child: actionBar!(),
          ),
        ),
    ];
  }

   List<Widget> _buildRowChildren(BuildContext context) {
    final reactionsRow = isDesktopDeviceOrWeb && showReactions
        ? Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Tooltip(
                message: 'Reactions',
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: onReactionsTap,
                    child: const Icon(
                      Icons.emoji_emotions,
                      size: 14,
                    ),
                  ),
                ),
              ),
              DesktopReactionsBuilder(
                message: message,
                messageTheme: messageTheme,
                onHover: onReactionsHover,
                borderSide: borderSide,
                reverse: reverse,
              ),
            ],
          )
        : const SizedBox.shrink();

    if (reverse) {
      return [
        reactionsRow,
        const SizedBox(width: 8),
        _buildBottomRow(context),
      ];
    } else {
      return [
        _buildBottomRow(context),
        const SizedBox(width: 8),
        reactionsRow,
      ];
    }
  }

  Widget _buildBottomRow(BuildContext context) {
    final defaultWidget = BottomRow(
      onThreadTap: onThreadTap,
      message: message,
      reverse: reverse,
      messageTheme: messageTheme,
      hasUrlAttachments: hasUrlAttachments,
      isOnlyEmoji: isOnlyEmoji,
      isDeleted: message.isDeleted,
      isGiphy: isGiphy,
      showInChannel: showInChannel,
      showSendingIndicator: showSendingIndicator,
      showThreadReplyIndicator: showThreadReplyIndicator,
      showTimeStamp: showTimeStamp,
      showUsername: showUsername,
      showEditedLabel: showEditedLabel,
      streamChatTheme: streamChatTheme,
      streamChat: streamChat,
      hasNonUrlAttachments: hasNonUrlAttachments,
    );

    if (bottomRowBuilderWithDefaultWidget != null) {
      return bottomRowBuilderWithDefaultWidget!(
        context,
        message,
        defaultWidget,
      );
    }

    return defaultWidget;
  }
}