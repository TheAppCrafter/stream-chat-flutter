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
    required this.showActionBar,
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

  /// {@macro showActionBar}
  final bool showActionBar;

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
                  if (isPinned && message.pinnedBy != null && showPinHighlight)
                    PinnedMessage(
                      pinnedBy: message.pinnedBy!,
                      currentUser: streamChat.currentUser!,
                    ),
                  Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      if (!reverse && showUserAvatar == DisplayWidget.show && message.user != null)
                        SizedBox(width: avatarWidth + 4),

                      Flexible(
                        child: Align(
                            alignment: reverse ? Alignment.centerRight : Alignment.centerLeft,
                            child: Stack(
                            clipBehavior: Clip.none,
                            children: [
                              if (message.isDeleted && !isFailedState)
                                Container(
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
                              else
                                Column(
                                    crossAxisAlignment: reverse ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                                    mainAxisSize: MainAxisSize.min,
                                    children: [
                                      PortalTarget(
                                        visible: showUserAvatar == DisplayWidget.show && message.user != null,
                                        portalFollower: userAvatarWidget(),
                                        anchor: Aligned(
                                          follower: Alignment(reverse ? -1 : 1, 1),
                                          target: Alignment(reverse ? 1 : -1, 1),
                                          offset: Offset(reverse ? 7 : -7, 0),
                                        ),
                                        child: MessageCard(
                                          message: message,
                                          isFailedState: isFailedState,
                                          showUserAvatar: DisplayWidget.gone, // Hide built-in avatar
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
                                      ),
                                      BottomWidget(
                                        showReactions: showReactions,
                                        showActionBar: showActionBar,
                                        showBottomRow: showBottomRow,
                                        reverse: reverse,
                                        onReactionsTap: onReactionsTap,
                                        actionBar: actionBar,
                                        buildBottomRow: _buildBottomRow(context),
                                        messageTheme: messageTheme,
                                        message: message,
                                        onReactionsHover: onReactionsHover,
                                        borderSide: borderSide,
                                      ),
                                    ],
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
                      if (reverse && showUserAvatar == DisplayWidget.show && message.user != null)
                        SizedBox(width: avatarWidth + 4),
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
                child: StreamSvgIcon(
                  icon: StreamSvgIcons.error,
                  color: streamChatTheme.colorTheme.accentError,
                ),
              ),
          ],
        ),
      ],
    );
  }

  Widget userAvatarWidget() {
    return UserAvatarTransform(
      onUserAvatarTap: onUserAvatarTap,
      userAvatarBuilder: userAvatarBuilder,
      translateUserAvatar: translateUserAvatar,
      messageTheme: messageTheme,
      message: message,
    );
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

class BottomWidget extends StatefulWidget {

  const BottomWidget({
    super.key,
    required this.showReactions,
    required this.showActionBar,
    required this.showBottomRow,
    required this.reverse,
    required this.onReactionsTap,
    required this.actionBar,
    required this.buildBottomRow,
    required this.messageTheme,
    required this.message,
    required this.onReactionsHover,
    required this.borderSide,
  });

  final bool showReactions;
  final bool showActionBar;
  final bool showBottomRow;
  final bool reverse;
  final VoidCallback onReactionsTap;
  final Widget Function()? actionBar;
  final Widget buildBottomRow;
  final StreamMessageThemeData messageTheme;
  final Message message;
  final OnReactionsHover? onReactionsHover;
  final BorderSide? borderSide;
  @override
  State<BottomWidget> createState() => BottomWidgetState();
}

class BottomWidgetState extends State<BottomWidget> {
  bool showAllReactions = false;
  bool get isMobileDevice => CurrentPlatform.isAndroid || CurrentPlatform.isIos;
  bool get isDesktopDeviceOrWeb => !isMobileDevice;

  void toggleShowAllReactions() {
    setState(() {
      showAllReactions = !showAllReactions;
    });
  }

  Widget reactionRow() {
    return ReactionsRow(
      message: widget.message,
      messageTheme: widget.messageTheme,
      onReactionsTap: widget.onReactionsTap,
      onReactionsHover: widget.onReactionsHover,
      borderSide: widget.borderSide,
      reverse: widget.reverse,
      isDesktopDeviceOrWeb: isDesktopDeviceOrWeb,
    );
  }

  List<Widget> _buildRowChildren(BuildContext context) {
    if (widget.reverse) {
      return [
        if (widget.showReactions) reactionRow(),
        if (widget.showReactions) const SizedBox(width: 16),
        widget.buildBottomRow,
      ];
    } else {
      return [
        widget.buildBottomRow,
        if (widget.showReactions) const SizedBox(width: 16),
        if (widget.showReactions) reactionRow(),
      ];
    }
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisAlignment: MainAxisAlignment.start,
      mainAxisSize: MainAxisSize.min,
      crossAxisAlignment: widget.reverse ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (widget.showBottomRow)
          Padding(
            padding: widget.reverse ? const EdgeInsets.fromLTRB(0, 0, 8, 0): const EdgeInsets.fromLTRB(8, 0, 0, 0),
            child: Align(
              alignment: widget.reverse ? Alignment.centerRight : Alignment.centerLeft,
              child: Row(
                mainAxisAlignment: MainAxisAlignment.start,
                mainAxisSize: MainAxisSize.min,
                children: _buildRowChildren(context),
              ),
            ),
        ),
        const SizedBox(height: 6),
        if (widget.showActionBar && widget.actionBar != null)
          Padding(
            padding: widget.reverse ? const EdgeInsets.fromLTRB(0, 0, 10, 0): const EdgeInsets.fromLTRB(10, 0, 0, 0),
            child: Align(
              alignment: widget.reverse ? Alignment.topRight : Alignment.topLeft,
              child: widget.actionBar!(),
            ),
          ),
      ],
    );
  }
}

// Create a separate StatefulWidget for reactions
class ReactionsRow extends StatefulWidget {
  const ReactionsRow({
    Key? key,
    required this.message,
    required this.messageTheme,
    required this.onReactionsTap,
    required this.onReactionsHover,
    required this.borderSide,
    required this.reverse,
    required this.isDesktopDeviceOrWeb,
  }) : super(key: key);

  final Message message;
  final StreamMessageThemeData messageTheme;
  final VoidCallback onReactionsTap;
  final OnReactionsHover? onReactionsHover;
  final BorderSide? borderSide;
  final bool reverse;
  final bool isDesktopDeviceOrWeb;

  @override
  State<ReactionsRow> createState() => _ReactionsRowState();
}

class _ReactionsRowState extends State<ReactionsRow> {
  bool showAllReactions = false;

  void toggleShowAllReactions() {
    setState(() {
      showAllReactions = !showAllReactions;
    });
  }

  @override
  Widget build(BuildContext context) {
    final reactions = DesktopReactionsBuilder(
      message: widget.message,
      messageTheme: widget.messageTheme,
      onHover: widget.onReactionsHover,
      borderSide: widget.borderSide,
      reverse: widget.reverse,
      showAll: showAllReactions,
    );
    
    final newReactionButton = Tooltip(
      message: 'Reactions',
      child: MouseRegion(
        cursor: SystemMouseCursors.click,
        child: GestureDetector(
          onTap: widget.isDesktopDeviceOrWeb ? toggleShowAllReactions : widget.onReactionsTap,
          child: const Icon(
            Icons.emoji_emotions,
            size: 14,
          ),
        ),
      ),
    );

    final reactionWidgetList = widget.reverse 
        ? [if (widget.isDesktopDeviceOrWeb) newReactionButton, if (widget.isDesktopDeviceOrWeb) const SizedBox(width: 4), reactions] 
        : [reactions, if (widget.isDesktopDeviceOrWeb) const SizedBox(width: 4), if (widget.isDesktopDeviceOrWeb) newReactionButton];

    return Row(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: widget.reverse ? MainAxisAlignment.end : MainAxisAlignment.start,
      children: reactionWidgetList,
    );
  }
}
