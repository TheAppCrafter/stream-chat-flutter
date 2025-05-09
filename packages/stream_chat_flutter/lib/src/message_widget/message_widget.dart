import 'package:contextmenu/contextmenu.dart';
import 'package:flutter/material.dart' hide ButtonStyle;
import 'package:flutter/services.dart';
import 'package:flutter_portal/flutter_portal.dart';
import 'package:stream_chat_flutter/conditional_parent_builder/conditional_parent_builder.dart';
import 'package:stream_chat_flutter/platform_widget_builder/platform_widget_builder.dart';
import 'package:stream_chat_flutter/src/context_menu_items/context_menu_reaction_picker.dart';
import 'package:stream_chat_flutter/src/context_menu_items/stream_chat_context_menu_item.dart';
import 'package:stream_chat_flutter/src/dialogs/dialogs.dart';
import 'package:stream_chat_flutter/src/message_actions_modal/message_actions_modal.dart';
import 'package:stream_chat_flutter/src/message_widget/message_widget_content.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

/// The display behaviour of a widget
enum DisplayWidget {
  /// Hides the widget replacing its space with a spacer
  hide,

  /// Hides the widget not replacing its space
  gone,

  /// Shows the widget normally
  show,
}

/// {@template messageWidget}
/// ![screenshot](https://raw.githubusercontent.com/GetStream/stream-chat-flutter/master/packages/stream_chat_flutter/screenshots/message_widget.png)
/// ![screenshot](https://raw.githubusercontent.com/GetStream/stream-chat-flutter/master/packages/stream_chat_flutter/screenshots/message_widget_paint.png)
///
/// Shows a message with reactions, replies and user avatar.
///
/// Usually you don't use this widget as it's the default message widget used by
/// [MessageListView].
///
/// The widget components render the ui based on the first ancestor of type
/// [StreamChatTheme].
/// Modify it to change the widget appearance.
/// {@endtemplate}
class StreamMessageWidget extends StatefulWidget {
  /// {@macro messageWidget}
  const StreamMessageWidget({
    super.key,
    required this.message,
    required this.messageTheme,
    this.reverse = false,
    this.translateUserAvatar = true,
    this.shape,
    this.borderSide,
    this.borderRadiusGeometry,
    this.attachmentShape,
    this.onMentionTap,
    this.onMessageTap,
    this.onReactionsTap,
    this.onReactionsHover,
    this.showReactionPicker = true,
    this.showReactionTail,
    this.showUserAvatar = DisplayWidget.show,
    this.showSendingIndicator = true,
    this.showThreadReplyIndicator = false,
    this.showInChannelIndicator = false,
    this.onReplyTap,
    this.onThreadTap,
    this.onConfirmDeleteTap,
    this.showUsername = true,
    this.showTimestamp = true,
    this.showEditedLabel = true,
    this.showReactions = true,
    this.showDeleteMessage = true,
    this.showEditMessage = true,
    this.showReplyMessage = true,
    this.showThreadReplyMessage = true,
    this.showMarkUnreadMessage = true,
    this.showResendMessage = true,
    this.showCopyMessage = true,
    this.showFlagButton = true,
    this.showPinButton = true,
    this.showPinHighlight = true,
    this.showActionBar = false,
    this.onUserAvatarTap,
    this.onLinkTap,
    this.onMessageActions,
    this.onShowMessage,
    this.userAvatarBuilder,
    this.quotedMessageBuilder,
    this.editMessageInputBuilder,
    this.textBuilder,
    this.bottomRowBuilderWithDefaultWidget,
    this.attachmentBuilders,
    this.padding,
    this.textPadding = const EdgeInsets.symmetric(
      horizontal: 16,
      vertical: 8,
    ),
    this.attachmentPadding = EdgeInsets.zero,
    this.widthFactor = 0.78,
    this.onQuotedMessageTap,
    this.customActions = const [],
    this.onAttachmentTap,
    this.imageAttachmentThumbnailSize = const Size(400, 400),
    this.imageAttachmentThumbnailResizeType = 'clip',
    this.imageAttachmentThumbnailCropType = 'center',
    this.attachmentActionsModalBuilder,
    this.showHideMessage,
    this.onHideMessageTap,
    this.showRegenerateMessage,
    this.onRegenerateTap,
    this.showReadAloudMessage = true,
    this.onReadAloudTap,
    this.textBubbleBuilder,
    this.messageActionItemsBuilder,
    this.conditionalActionsBuilder,
  });

  /// {@template onMentionTap}
  /// Function called on mention tap
  /// {@endtemplate}
  final void Function(User)? onMentionTap;

  /// {@template onThreadTap}
  /// The function called when tapping on threads
  /// {@endtemplate}
  final void Function(Message)? onThreadTap;

  /// {@template onReplyTap}
  /// The function called when tapping on replies
  /// {@endtemplate}
  final void Function(Message)? onReplyTap;

  /// {@template onDeleteTap}
  /// The function called when delete confirmation button is tapped.
  /// {@endtemplate}
  final Future<void> Function(Message)? onConfirmDeleteTap;

  /// {@template editMessageInputBuilder}
  /// Widget builder for edit message layout
  /// {@endtemplate}
  final Widget Function(BuildContext, Message)? editMessageInputBuilder;

  /// {@template textBuilder}
  /// Widget builder for building text
  /// {@endtemplate}
  final Widget Function(BuildContext, Message)? textBuilder;

  /// {@template onMessageActions}
  /// Function called on long press
  /// {@endtemplate}
  final void Function(BuildContext, Message)? onMessageActions;

  /// {@template bottomRowBuilderWithDefaultWidget}
  /// Widget builder for building a bottom row below the message.
  /// Also contains the default bottom row widget.
  /// {@endtemplate}
  final BottomRowBuilderWithDefaultWidget? bottomRowBuilderWithDefaultWidget;

  /// {@template userAvatarBuilder}
  /// Widget builder for building user avatar
  /// {@endtemplate}
  final Widget Function(BuildContext, User)? userAvatarBuilder;

  /// {@template quotedMessageBuilder}
  /// Widget builder for building quoted message
  /// {@endtemplate}
  final Widget Function(BuildContext, Message)? quotedMessageBuilder;

  /// {@template message}
  /// The message to display.
  /// {@endtemplate}
  final Message message;

  /// {@template messageTheme}
  /// The message theme
  /// {@endtemplate}
  final StreamMessageThemeData messageTheme;

  /// {@template reverse}
  /// If true the widget will be mirrored
  /// {@endtemplate}
  final bool reverse;

  /// {@template shape}
  /// The shape of the message text
  /// {@endtemplate}
  final ShapeBorder? shape;

  /// {@template attachmentShape}
  /// The shape of an attachment
  /// {@endtemplate}
  final ShapeBorder? attachmentShape;

  /// {@template borderSide}
  /// The borderSide of the message text
  /// {@endtemplate}
  final BorderSide? borderSide;

  /// {@template borderRadiusGeometry}
  /// The border radius of the message text
  /// {@endtemplate}
  final BorderRadiusGeometry? borderRadiusGeometry;

  /// {@template padding}
  /// The padding of the widget
  /// {@endtemplate}
  final EdgeInsetsGeometry? padding;

  /// {@template textPadding}
  /// The internal padding of the message text
  /// {@endtemplate}
  final EdgeInsets textPadding;

  /// {@template attachmentPadding}
  /// The internal padding of an attachment
  /// {@endtemplate}
  final EdgeInsetsGeometry attachmentPadding;

  /// {@template widthFactor}
  /// The percentage of the available width the message content should take
  /// {@endtemplate}
  final double widthFactor;

  /// {@template showUserAvatar}
  /// It controls the display behaviour of the user avatar
  /// {@endtemplate}
  final DisplayWidget showUserAvatar;

  /// {@template showSendingIndicator}
  /// It controls the display behaviour of the sending indicator
  /// {@endtemplate}
  final bool showSendingIndicator;

  /// {@template showReactions}
  /// If `true` the message's reactions will be shown.
  /// {@endtemplate}
  final bool showReactions;

  /// {@template showThreadReplyIndicator}
  /// If true the widget will show the thread reply indicator
  /// {@endtemplate}
  final bool showThreadReplyIndicator;

  /// {@template showInChannelIndicator}
  /// If true the widget will show the show in channel indicator
  /// {@endtemplate}
  final bool showInChannelIndicator;

  /// {@template onUserAvatarTap}
  /// The function called when tapping on UserAvatar
  /// {@endtemplate}
  final void Function(User)? onUserAvatarTap;

  /// {@template onLinkTap}
  /// The function called when tapping on a link
  /// {@endtemplate}
  final void Function(String)? onLinkTap;

  /// {@template showReactionPicker}
  /// Whether or not to show the reaction picker.
  /// Used in [StreamMessageReactionsModal] and [MessageActionsModal].
  /// {@endtemplate}
  final bool showReactionPicker;

  /// {@template showReactionPickerTail}
  /// Whether or not to show the reaction picker tail.
  /// This is calculated internally in most cases and does not need to be set.
  /// {@endtemplate}
  final bool? showReactionTail;

  /// {@template onShowMessage}
  /// Callback when show message is tapped
  /// {@endtemplate}
  final ShowMessageCallback? onShowMessage;

  /// {@template showUsername}
  /// If true show the users username next to the timestamp of the message
  /// {@endtemplate}
  final bool showUsername;

  /// {@template showTimestamp}
  /// Show message timestamp
  /// {@endtemplate}
  final bool showTimestamp;

  /// {@template showTimestamp}
  /// Show edited label if message is edited
  /// {@endtemplate}
  final bool showEditedLabel;

  /// {@template showReplyMessage}
  /// Show reply action
  /// {@endtemplate}
  final bool showReplyMessage;

  /// {@template showThreadReplyMessage}
  /// Show thread reply action
  /// {@endtemplate}
  final bool showThreadReplyMessage;

  /// {@template showMarkUnreadMessage}
  /// Show mark unread action
  /// {@endtemplate}
  final bool showMarkUnreadMessage;

  /// {@template showEditMessage}
  /// Show edit action
  /// {@endtemplate}
  final bool showEditMessage;

  /// {@template showCopyMessage}
  /// Show copy action
  /// {@endtemplate}
  final bool showCopyMessage;

  /// {@template showDeleteMessage}
  /// Show delete action
  /// {@endtemplate}
  final bool showDeleteMessage;

  /// {@template showResendMessage}
  /// Show resend action
  /// {@endtemplate}
  final bool showResendMessage;

  /// {@template showFlagButton}
  /// Show flag action
  /// {@endtemplate}
  final bool showFlagButton;

  /// {@template showPinButton}
  /// Show pin action
  /// {@endtemplate}
  final bool showPinButton;

  /// {@template showPinHighlight}
  /// Display Pin Highlight
  /// {@endtemplate}
  final bool showPinHighlight;

  /// {@template showHideMessage}
  /// Display Hide or Unhide Message
  /// {@endtemplate}
  final bool Function(Message)? showHideMessage;

  /// {@template onHideMessageTap}
  /// The function called when tapping on HideMessage
  /// {@endtemplate}
  final void Function(Message)? onHideMessageTap;

  /// {@template showRegenerateMessage}
  /// Display Regnerate Message
  /// {@endtemplate}
  final bool Function(Message)? showRegenerateMessage;

  /// {@template onRegenerateTap}
  /// The function called when tapping on RegenerateMessage
  /// {@endtemplate}
  final void Function(Message)? onRegenerateTap;

  /// {@template showReadAloudMessage}
  /// Display Read Aloud
  /// {@endtemplate}
  final bool showReadAloudMessage;

  /// {@template showActionBar}
  /// Display Action Bar
  /// {@endtemplate}
  final bool showActionBar;

  /// {@template onReadAloudTap}
  /// The function called when tapping on Read Aloud
  /// {@endtemplate}
  final void Function(Message)? onReadAloudTap;

  /// {@template attachmentBuilders}
  /// List of attachment builders for rendering attachment widgets pre-defined
  /// and custom attachment types.
  ///
  /// If null, the widget will create a default list of attachment builders
  /// based on the [Attachment.type] of the attachment.
  /// {@endtemplate}
  final List<StreamAttachmentWidgetBuilder>? attachmentBuilders;

  /// {@template translateUserAvatar}
  /// Center user avatar with bottom of the message
  /// {@endtemplate}
  final bool translateUserAvatar;

  /// {@macro onQuotedMessageTap}
  final OnQuotedMessageTap? onQuotedMessageTap;

  /// {@macro onMessageTap}
  final void Function(Message)? onMessageTap;

  /// {@macro onReactionsTap}
  ///
  /// Note: Only used in mobile devices (iOS and Android). Do not confuse this
  /// with the tap action on the reactions picker.
  final OnReactionsTap? onReactionsTap;

  /// {@macro onReactionsHover}
  ///
  /// Note: Only used in desktop devices (web and desktop).
  final OnReactionsHover? onReactionsHover;

  /// {@template customActions}
  /// List of custom actions shown on message long tap
  /// {@endtemplate}
  final List<StreamMessageAction> customActions;

  /// {@macro onMessageWidgetAttachmentTap}
  final StreamAttachmentWidgetTapCallback? onAttachmentTap;

  /// {@macro attachmentActionsBuilder}
  final AttachmentActionsBuilder? attachmentActionsModalBuilder;

  /// Size of the image attachment thumbnail.
  final Size imageAttachmentThumbnailSize;

  /// Resize type of the image attachment thumbnail.
  ///
  /// Defaults to [crop]
  final String /*clip|crop|scale|fill*/ imageAttachmentThumbnailResizeType;

  /// Crop type of the image attachment thumbnail.
  ///
  /// Defaults to [center]
  final String /*center|top|bottom|left|right*/
      imageAttachmentThumbnailCropType;

  /// {@macro textBubbleBuilder}
  final TextBubbleBuilder? textBubbleBuilder;

    /// Builder for custom message action items
  /// If provided, this will override the default message actions
  final List<StreamChatContextMenuItem> Function(BuildContext context)? messageActionItemsBuilder;

  /// Builder for custom conditional parent
  /// If provided, this will override the default ConditionalParentBuilder builder method
  final Widget Function(BuildContext context, Widget child)? conditionalActionsBuilder;

  /// {@template copyWith}
  /// Creates a copy of [StreamMessageWidget] with specified attributes
  /// overridden.
  /// {@endtemplate}
  StreamMessageWidget copyWith({
    Key? key,
    void Function(User)? onMentionTap,
    void Function(Message)? onThreadTap,
    void Function(Message)? onReplyTap,
    Future<void> Function(Message)? onConfirmDeleteTap,
    Widget Function(BuildContext, Message)? editMessageInputBuilder,
    Widget Function(BuildContext, Message)? textBuilder,
    Widget Function(BuildContext, Message)? quotedMessageBuilder,
    BottomRowBuilderWithDefaultWidget? bottomRowBuilderWithDefaultWidget,
    void Function(BuildContext, Message)? onMessageActions,
    Message? message,
    StreamMessageThemeData? messageTheme,
    bool? reverse,
    ShapeBorder? shape,
    ShapeBorder? attachmentShape,
    BorderSide? borderSide,
    BorderRadiusGeometry? borderRadiusGeometry,
    EdgeInsetsGeometry? padding,
    EdgeInsets? textPadding,
    EdgeInsetsGeometry? attachmentPadding,
    double? widthFactor,
    DisplayWidget? showUserAvatar,
    bool? showSendingIndicator,
    bool? showReactions,
    bool? allRead,
    bool? showThreadReplyIndicator,
    bool? showInChannelIndicator,
    void Function(User)? onUserAvatarTap,
    void Function(String)? onLinkTap,
    bool? showReactionBrowser,
    bool? showReactionPicker,
    bool? showReactionTail,
    List<Read>? readList,
    ShowMessageCallback? onShowMessage,
    bool? showUsername,
    bool? showTimestamp,
    bool? showEditedLabel,
    bool? showReplyMessage,
    bool? showThreadReplyMessage,
    bool? showEditMessage,
    bool? showCopyMessage,
    bool? showDeleteMessage,
    bool? showResendMessage,
    bool? showFlagButton,
    bool? showPinButton,
    bool? showPinHighlight,
    bool? showMarkUnreadMessage,
    bool? showActionBar,
    List<StreamAttachmentWidgetBuilder>? attachmentBuilders,
    bool? translateUserAvatar,
    OnQuotedMessageTap? onQuotedMessageTap,
    void Function(Message)? onMessageTap,
    OnReactionsTap? onReactionsTap,
    OnReactionsHover? onReactionsHover,
    List<StreamMessageAction>? customActions,
    void Function(Message message, Attachment attachment)? onAttachmentTap,
    Widget Function(BuildContext, User)? userAvatarBuilder,
    Size? imageAttachmentThumbnailSize,
    String? imageAttachmentThumbnailResizeType,
    String? imageAttachmentThumbnailCropType,
    AttachmentActionsBuilder? attachmentActionsModalBuilder,
    void Function(Message)? onHideMessageTap,
    void Function(Message)? onRegenerateTap,
    void Function(Message)? onReadAloudTap,
    bool Function(Message)? showHideMessage,
    bool Function(Message)? showRegenerateMessage,
    bool? showReadAloudMessage,
    TextBubbleBuilder? textBubbleBuilder,
    List<StreamChatContextMenuItem> Function(BuildContext context)? messageActionItemsBuilder,
    Widget Function(BuildContext context, Widget child)? conditionalActionsBuilder,
  }) {
    return StreamMessageWidget(
      key: key ?? this.key,
      onMentionTap: onMentionTap ?? this.onMentionTap,
      onThreadTap: onThreadTap ?? this.onThreadTap,
      onReplyTap: onReplyTap ?? this.onReplyTap,
      onConfirmDeleteTap: onConfirmDeleteTap ?? this.onConfirmDeleteTap,
      editMessageInputBuilder:
          editMessageInputBuilder ?? this.editMessageInputBuilder,
      textBuilder: textBuilder ?? this.textBuilder,
      quotedMessageBuilder: quotedMessageBuilder ?? this.quotedMessageBuilder,
      bottomRowBuilderWithDefaultWidget: bottomRowBuilderWithDefaultWidget ??
          this.bottomRowBuilderWithDefaultWidget,
      onMessageActions: onMessageActions ?? this.onMessageActions,
      message: message ?? this.message,
      messageTheme: messageTheme ?? this.messageTheme,
      reverse: reverse ?? this.reverse,
      shape: shape ?? this.shape,
      attachmentShape: attachmentShape ?? this.attachmentShape,
      borderSide: borderSide ?? this.borderSide,
      borderRadiusGeometry: borderRadiusGeometry ?? this.borderRadiusGeometry,
      padding: padding ?? this.padding,
      textPadding: textPadding ?? this.textPadding,
      attachmentPadding: attachmentPadding ?? this.attachmentPadding,
      widthFactor: widthFactor ?? this.widthFactor,
      showUserAvatar: showUserAvatar ?? this.showUserAvatar,
      showSendingIndicator: showSendingIndicator ?? this.showSendingIndicator,
      showEditedLabel: showEditedLabel ?? this.showEditedLabel,
      showReactions: showReactions ?? this.showReactions,
      showThreadReplyIndicator:
          showThreadReplyIndicator ?? this.showThreadReplyIndicator,
      showInChannelIndicator:
          showInChannelIndicator ?? this.showInChannelIndicator,
      onUserAvatarTap: onUserAvatarTap ?? this.onUserAvatarTap,
      onLinkTap: onLinkTap ?? this.onLinkTap,
      showReactionPicker: showReactionPicker ?? this.showReactionPicker,
      showReactionTail: showReactionTail ?? this.showReactionTail,
      onShowMessage: onShowMessage ?? this.onShowMessage,
      showUsername: showUsername ?? this.showUsername,
      showTimestamp: showTimestamp ?? this.showTimestamp,
      showReplyMessage: showReplyMessage ?? this.showReplyMessage,
      showThreadReplyMessage:
          showThreadReplyMessage ?? this.showThreadReplyMessage,
      showEditMessage: showEditMessage ?? this.showEditMessage,
      showCopyMessage: showCopyMessage ?? this.showCopyMessage,
      showDeleteMessage: showDeleteMessage ?? this.showDeleteMessage,
      showResendMessage: showResendMessage ?? this.showResendMessage,
      showFlagButton: showFlagButton ?? this.showFlagButton,
      showPinButton: showPinButton ?? this.showPinButton,
      showPinHighlight: showPinHighlight ?? this.showPinHighlight,
      showMarkUnreadMessage:
          showMarkUnreadMessage ?? this.showMarkUnreadMessage,
      showActionBar: showActionBar ?? this.showActionBar,
      attachmentBuilders: attachmentBuilders ?? this.attachmentBuilders,
      translateUserAvatar: translateUserAvatar ?? this.translateUserAvatar,
      onQuotedMessageTap: onQuotedMessageTap ?? this.onQuotedMessageTap,
      onMessageTap: onMessageTap ?? this.onMessageTap,
      onReactionsTap: onReactionsTap ?? this.onReactionsTap,
      onReactionsHover: onReactionsHover ?? this.onReactionsHover,
      customActions: customActions ?? this.customActions,
      onAttachmentTap: onAttachmentTap ?? this.onAttachmentTap,
      userAvatarBuilder: userAvatarBuilder ?? this.userAvatarBuilder,
      imageAttachmentThumbnailSize:
          imageAttachmentThumbnailSize ?? this.imageAttachmentThumbnailSize,
      imageAttachmentThumbnailResizeType: imageAttachmentThumbnailResizeType ??
          this.imageAttachmentThumbnailResizeType,
      imageAttachmentThumbnailCropType: imageAttachmentThumbnailCropType ??
          this.imageAttachmentThumbnailCropType,
      attachmentActionsModalBuilder:
          attachmentActionsModalBuilder ?? this.attachmentActionsModalBuilder,
      onHideMessageTap: onHideMessageTap ?? this.onHideMessageTap,
      onRegenerateTap: onRegenerateTap ?? this.onRegenerateTap,
      onReadAloudTap: onReadAloudTap ?? this.onReadAloudTap,
      showHideMessage: showHideMessage ?? this.showHideMessage,
      showRegenerateMessage: showRegenerateMessage ?? this.showRegenerateMessage,
      showReadAloudMessage: showReadAloudMessage ?? this.showReadAloudMessage,
      textBubbleBuilder: textBubbleBuilder ?? this.textBubbleBuilder,
      messageActionItemsBuilder: messageActionItemsBuilder ?? this.messageActionItemsBuilder,
      conditionalActionsBuilder: conditionalActionsBuilder ?? this.conditionalActionsBuilder,
    );
  }

  @override
  StreamMessageWidgetState createState() => StreamMessageWidgetState();
}

class StreamMessageWidgetState extends State<StreamMessageWidget>
    with AutomaticKeepAliveClientMixin<StreamMessageWidget> {
  bool get showThreadReplyIndicator => widget.showThreadReplyIndicator;

  bool get showSendingIndicator => widget.showSendingIndicator;

  bool get isDeleted => widget.message.isDeleted;

  bool get showUsername => widget.showUsername;

  bool get showTimeStamp => widget.showTimestamp;

  bool get showEditedLabel => widget.showEditedLabel;

  bool get isTextEdited => widget.message.messageTextUpdatedAt != null;

  bool get showInChannel => widget.showInChannelIndicator;

  /// {@template hasQuotedMessage}
  /// `true` if [StreamMessageWidget.quotedMessage] is not null.
  /// {@endtemplate}
  bool get hasQuotedMessage => widget.message.quotedMessage != null;

  bool get isSendFailed => widget.message.state.isSendingFailed;

  bool get isUpdateFailed => widget.message.state.isUpdatingFailed;

  bool get isDeleteFailed => widget.message.state.isDeletingFailed;

  /// {@template isFailedState}
  /// Whether the message has failed to be sent, updated, or deleted.
  /// {@endtemplate}
  bool get isFailedState => isSendFailed || isUpdateFailed || isDeleteFailed;

  /// {@template isGiphy}
  /// `true` if any of the [message]'s attachments are a giphy.
  /// {@endtemplate}
  bool get isGiphy => widget.message.attachments
      .any((element) => element.type == AttachmentType.giphy);

  /// {@template isOnlyEmoji}
  /// `true` if [message.text] contains only emoji.
  /// {@endtemplate}
  bool get isOnlyEmoji => widget.message.text?.isOnlyEmoji == true;

  /// {@template hasNonUrlAttachments}
  /// `true` if any of the [message]'s attachments are a giphy and do not
  /// have a [Attachment.titleLink].
  /// {@endtemplate}
  bool get hasNonUrlAttachments => widget.message.attachments
      .any((it) => it.type != AttachmentType.urlPreview);

  /// {@template hasPoll}
  /// `true` if the [message] contains a poll.
  /// {@endtemplate}
  bool get hasPoll => widget.message.poll != null;

  /// {@template hasUrlAttachments}
  /// `true` if any of the [message]'s attachments are a giphy with a
  /// [Attachment.titleLink].
  /// {@endtemplate}
  bool get hasUrlAttachments => widget.message.attachments
      .any((it) => it.type == AttachmentType.urlPreview);

  /// {@template showBottomRow}
  /// Show the [BottomRow] widget if any of the following are `true`:
  /// * [StreamMessageWidget.showThreadReplyIndicator]
  /// * [StreamMessageWidget.showUsername]
  /// * [StreamMessageWidget.showTimestamp]
  /// * [StreamMessageWidget.showInChannelIndicator]
  /// * [StreamMessageWidget.showSendingIndicator]
  /// * [StreamMessageWidget.message.isDeleted]
  /// {@endtemplate}
  bool get showBottomRow =>
      showThreadReplyIndicator ||
      showUsername ||
      showTimeStamp ||
      showInChannel ||
      widget.showReactions ||
      showSendingIndicator ||
      isTextEdited;

  /// {@template isPinned}
  /// Whether [StreamMessageWidget.message] is pinned or not.
  /// {@endtemplate}
  bool get isPinned => widget.message.pinned;

  /// {@template shouldShowReactions}
  /// Should show message reactions if [StreamMessageWidget.showReactions] is
  /// `true`, if there are reactions to show, and if the message is not deleted.
  /// {@endtemplate}
  bool get shouldShowReactions =>
      widget.showReactions &&
      ((widget.message.reactionCounts?.isNotEmpty == true) || isDesktopDeviceOrWeb) &&
      !widget.message.isDeleted;

  bool get shouldShowReplyAction =>
      widget.showReplyMessage && !isFailedState && widget.onReplyTap != null;

  bool get shouldShowEditAction =>
      widget.showEditMessage == true &&
      isOwner &&
      !isDeleteFailed &&
      !hasPoll &&
      !widget.message.attachments
          .any((element) => element.type == AttachmentType.giphy);

  bool get shouldShowHideMessageAction {
    return (widget.showHideMessage != null ? widget.showHideMessage?.call(widget.message) == true : false) && widget.onHideMessageTap != null;
  }

  bool get shouldShowRegenerateMessage {
    return (widget.showRegenerateMessage != null ? widget.showRegenerateMessage?.call(widget.message) == true : false) && 
    widget.onRegenerateTap != null;
  }

  bool get shouldShowReadAloudMessage =>
      widget.showReadAloudMessage && 
      !isFailedState &&
      widget.onReadAloudTap != null;

  bool get shouldShowResendAction =>
      widget.showResendMessage && (isSendFailed || isUpdateFailed);

  bool get shouldShowCopyAction =>
      widget.showCopyMessage &&
      !isFailedState &&
      widget.message.text?.trim().isNotEmpty == true;

  bool get shouldShowThreadReplyAction =>
      widget.showThreadReplyMessage &&
      !isFailedState &&
      widget.onThreadTap != null;

  bool get shouldShowDeleteAction => isOwner || isDeleteFailed;

  @override
  bool get wantKeepAlive => widget.message.attachments.isNotEmpty;

  bool get isOwner => widget.message.extraData['owner'] == StreamChat.of(context).currentUser?.id;

  late StreamChatThemeData streamChatTheme;
  late StreamChatState streamChat;

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    streamChatTheme = StreamChatTheme.of(context);
    streamChat = StreamChat.of(context);
  }

  @override
  Widget build(BuildContext context) {
    super.build(context);
    final avatarWidth =
        widget.messageTheme.avatarTheme?.constraints.maxWidth ?? 40;
    final bottomRowPadding =
        widget.showUserAvatar != DisplayWidget.gone ? avatarWidth + 8.5 : 0.5;

    final showReactions = shouldShowReactions;

    final child = Material(
      type: MaterialType.transparency,
      child: AnimatedContainer(
        duration: const Duration(seconds: 1),
        color: widget.message.pinned && widget.showPinHighlight
            ? streamChatTheme.colorTheme.highlight
            : streamChatTheme.colorTheme.barsBg.withOpacity(0),
        child: Portal(
          child: PlatformWidgetBuilder(
            mobile: (context, child) {
              return SelectionArea(
                child: GestureDetector(
                  onLongPress: widget.message.state.isDeleted
                      ? null
                      : () {
                          // Add haptic feedback
                          HapticFeedback.mediumImpact();
                          onLongPress(context);
                        },
                  behavior: HitTestBehavior.translucent, // Important for ripple effect
                  child: child,
                ),
              );
            },
            desktop: (_, child) => MouseRegion(child: SelectionArea(child: child ?? const SizedBox.shrink())),
            web: (_, child) => MouseRegion(child: SelectionArea(child: child ?? const SizedBox.shrink())),
            child: Padding(
              padding: widget.padding ?? const EdgeInsets.all(8),
              child: FractionallySizedBox(
                alignment: widget.reverse
                    ? Alignment.centerRight
                    : Alignment.centerLeft,
                widthFactor: widget.widthFactor,
                child: Builder(builder: (context) {
                  return Column(
                    crossAxisAlignment: widget.reverse ? CrossAxisAlignment.end : CrossAxisAlignment.start,
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      MessageWidgetContent(
                        streamChatTheme: streamChatTheme,
                        showUsername: showUsername,
                        showTimeStamp: showTimeStamp,
                        showEditedLabel: showEditedLabel,
                        showThreadReplyIndicator: showThreadReplyIndicator,
                        showSendingIndicator: showSendingIndicator,
                        showInChannel: showInChannel,
                        isGiphy: isGiphy,
                        isOnlyEmoji: isOnlyEmoji,
                        hasUrlAttachments: hasUrlAttachments,
                        messageTheme: widget.messageTheme,
                        reverse: widget.reverse,
                        message: widget.message,
                        hasNonUrlAttachments: hasNonUrlAttachments,
                        hasPoll: hasPoll,
                        hasQuotedMessage: hasQuotedMessage,
                        textPadding: widget.textPadding,
                        attachmentBuilders: widget.attachmentBuilders,
                        attachmentPadding: widget.attachmentPadding,
                        attachmentShape: widget.attachmentShape,
                        onAttachmentTap: widget.onAttachmentTap,
                        onReplyTap: widget.onReplyTap,
                        onThreadTap: widget.onThreadTap,
                        onShowMessage: widget.onShowMessage,
                        attachmentActionsModalBuilder:
                            widget.attachmentActionsModalBuilder,
                        avatarWidth: avatarWidth,
                        bottomRowPadding: bottomRowPadding,
                        isFailedState: isFailedState,
                        isPinned: isPinned,
                        messageWidget: widget,
                        showBottomRow: showBottomRow,
                        showPinHighlight: widget.showPinHighlight,
                        showReactionPickerTail: calculateReactionTailEnabled(
                          ReactionTailType.list,
                        ),
                        showReactions: showReactions,
                        onReactionsTap: () {
                          widget.onReactionsTap != null
                              ? widget.onReactionsTap!(widget.message)
                              : showMessageReactionsModal(context);
                        },
                        onReactionsHover: widget.onReactionsHover,
                        showUserAvatar: widget.showUserAvatar,
                        streamChat: streamChat,
                        translateUserAvatar: widget.translateUserAvatar,
                        shape: widget.shape,
                        borderSide: widget.borderSide,
                        borderRadiusGeometry: widget.borderRadiusGeometry,
                        textBubbleBuilder: widget.textBubbleBuilder,
                        textBuilder: widget.textBuilder,
                        quotedMessageBuilder: widget.quotedMessageBuilder,
                        onLinkTap: widget.onLinkTap,
                        onMentionTap: widget.onMentionTap,
                        onQuotedMessageTap: widget.onQuotedMessageTap,
                        bottomRowBuilderWithDefaultWidget: widget.bottomRowBuilderWithDefaultWidget,
                        onUserAvatarTap: widget.onUserAvatarTap,
                        userAvatarBuilder: widget.userAvatarBuilder,
                        showActionBar: widget.showActionBar,
                        actionBar: !widget.message.state.isDeleted && isDesktopDeviceOrWeb ? actionBar : null,
                      ),
                    ],
                  );
                }),
              ),
            ),
          ),
        ),
      ),
    );

    return ConditionalParentBuilder(
      builder: widget.conditionalActionsBuilder ?? (context, child) {
        if (!widget.message.state.isDeleted && !isDesktopDeviceOrWeb) {
          return ContextMenuArea(
            verticalPadding: 0,
            builder: (_) {
              return buildContextMenu();
            },
            child: child,
          );
        }
        return child;
      },
      child: child
    );
  }

  List<StreamChatContextMenuItem> messageActionItems({double? iconSize}) {
    if (widget.messageActionItemsBuilder != null) {
      return widget.messageActionItemsBuilder!(context);
    }

    final channel = StreamChannel.of(context).channel;
    return [
      if (widget.showReactionPicker)
        StreamChatContextMenuItem(
          child: StreamChannel(
            channel: channel,
            child: ContextMenuReactionPicker(
              message: widget.message,
            ),
          ),
        ),
      if (shouldShowRegenerateMessage)
        StreamChatContextMenuItem(
          leading: Icon(
            Icons.autorenew,
            color: Colors.grey,
            size: iconSize,
          ),
          title: Text(context.translations.regenerateMessageLabel),
          onClick: () {
            if (!isDesktopDeviceOrWeb) {
              Navigator.of(context, rootNavigator: true).pop();
            }
            widget.onRegenerateTap!(widget.message);
          },
        ),
      if (shouldShowReplyAction) ...[
        StreamChatContextMenuItem(
          leading: StreamSvgIcon.reply(size: iconSize),
          title: Text(context.translations.replyLabel),
          onClick: () {
            if (!isDesktopDeviceOrWeb) {
              Navigator.of(context, rootNavigator: true).pop();
            }
            widget.onReplyTap!(widget.message);
          },
        ),
      ],
      if (shouldShowThreadReplyAction)
        StreamChatContextMenuItem(
          leading: StreamSvgIcon.thread(size: iconSize),
          title: Text(context.translations.threadReplyLabel),
          onClick: () {
            if (!isDesktopDeviceOrWeb) {
              Navigator.of(context, rootNavigator: true).pop();
            }
            widget.onThreadTap!(widget.message);
          },
        ),
      if (shouldShowHideMessageAction)
        StreamChatContextMenuItem(
          leading: widget.message.extraData['hidden'] == true
              ? Icon(Icons.visibility_off, color: Colors.grey, size: iconSize)
              : Icon(Icons.visibility, color: Colors.grey, size: iconSize),
          title: Text(
            widget.message.extraData['hidden'] == true
                ? 'Hide message'
                : 'Unhide message',
          ),
          onClick: () async {
            if (!isDesktopDeviceOrWeb) {
              Navigator.of(context, rootNavigator: true).pop();
            }
            widget.onHideMessageTap!(widget.message);
          },
        ),
      if (widget.showMarkUnreadMessage)
        StreamChatContextMenuItem(
          leading: StreamSvgIcon.messageUnread(size: iconSize),
          title: Text(context.translations.markAsUnreadLabel),
          onClick: () async {
            try {
              await channel.markUnread(widget.message.id);
            } catch (ex) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(
                    context.translations.markUnreadError,
                  ),
                ),
              );
            }
            if (!isDesktopDeviceOrWeb) {
              Navigator.of(context, rootNavigator: true).pop();
            }
          },
        ),
      if (shouldShowCopyAction)
        StreamChatContextMenuItem(
          leading: StreamSvgIcon.copy(size: iconSize),
          title: Text(context.translations.copyMessageLabel),
          onClick: () {
            if (!isDesktopDeviceOrWeb) {
              Navigator.of(context, rootNavigator: true).pop();
            }
            var messageToCopy = widget.message.text;
            for (final user in widget.message.mentionedUsers.toSet()) {
              final userId = user.id;
              final userName = user.name;
              messageToCopy = messageToCopy?.replaceAll(
                    RegExp('@($userId|$userName)'),
                    '@$userName',
                  ) ??
                  '';
            }

            if (messageToCopy != null) {
              Clipboard.setData(
                ClipboardData(text: messageToCopy),
              );
            }
          },
        ),
      if (shouldShowEditAction) ...[
        StreamChatContextMenuItem(
          leading: StreamSvgIcon.edit(color: Colors.grey, size: iconSize),
          title: Text(context.translations.editMessageLabel),
          onClick: () {
            if (!isDesktopDeviceOrWeb) {
              Navigator.of(context, rootNavigator: true).pop();
            }
            showModalBottomSheet(
              context: context,
              constraints: BoxConstraints(maxWidth: MediaQuery.of(context).size.width, maxHeight: MediaQuery.of(context).size.height),
              elevation: 2,
              clipBehavior: Clip.hardEdge,
              isScrollControlled: true,
              backgroundColor:
                  StreamMessageInputTheme.of(context).inputBackgroundColor,
              shape: const RoundedRectangleBorder(
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(16),
                  topRight: Radius.circular(16),
                ),
              ),
              builder: (_) => EditMessageSheet(
                message: widget.message,
                channel: StreamChannel.of(context).channel,
                editMessageInputBuilder: widget.editMessageInputBuilder,
              ),
            );
          },
        ),
      ],
      if (shouldShowReadAloudMessage)
        StreamChatContextMenuItem(
          leading: Icon(
            Icons.volume_up,
            color: Colors.grey,
            size: iconSize,
          ),
          title: Text(context.translations.readAloudMessageLabel),
          onClick: () {
            if (!isDesktopDeviceOrWeb) {
              Navigator.of(context, rootNavigator: true).pop();
            }
            widget.onRegenerateTap!(widget.message);
          },
        ),
      if (widget.showPinButton)
        StreamChatContextMenuItem(
          leading: StreamSvgIcon.pin(
            color: Colors.grey,
            size: iconSize,
          ),
          title: Text(
            context.translations.togglePinUnpinText(
              pinned: widget.message.pinned,
            ),
          ),
          onClick: () async {
            if (!isDesktopDeviceOrWeb) {
              Navigator.of(context, rootNavigator: true).pop();
            }
            try {
              if (!widget.message.pinned) {
                await channel.pinMessage(widget.message);
              } else {
                await channel.unpinMessage(widget.message);
              }
            } catch (e) {
              throw Exception(e);
            }
          },
        ),
      if (shouldShowResendAction)
        StreamChatContextMenuItem(
          leading: StreamSvgIcon.iconSendMessage(size: iconSize),
          title: Text(
            context.translations.toggleResendOrResendEditedMessage(
              isUpdateFailed: widget.message.state.isUpdatingFailed,
            ),
          ),
          onClick: () {
            if (!isDesktopDeviceOrWeb) {
              Navigator.of(context, rootNavigator: true).pop();
            }
            final isUpdateFailed = widget.message.state.isUpdatingFailed;
            final channel = StreamChannel.of(context).channel;
            if (isUpdateFailed) {
              channel.updateMessage(widget.message);
            } else {
              channel.sendMessage(widget.message);
            }
          },
        ),
      if (shouldShowDeleteAction)
        StreamChatContextMenuItem(
          leading: StreamSvgIcon.delete(color: Colors.red, size: iconSize),
          title: Text(
            context.translations.deleteMessageLabel,
            style: const TextStyle(color: Colors.red),
          ),
          onClick: () async {
            if (!isDesktopDeviceOrWeb) {
              Navigator.of(context, rootNavigator: true).pop();
            }
            final deleted = await showDialog<bool?>(
              context: context,
              barrierDismissible: false,
              builder: (_) => const DeleteMessageDialog(),
            );
            if (deleted == true) {
              try {
                final onConfirmDeleteTap = widget.onConfirmDeleteTap;
                if (onConfirmDeleteTap != null) {
                  await onConfirmDeleteTap(widget.message);
                } else {
                  await StreamChannel.of(context)
                      .channel
                      .deleteMessage(widget.message);
                }
              } catch (e) {
                showDialog(
                  context: context,
                  builder: (_) => const MessageDialog(),
                );
              }
            }
          },
        ),
      ...widget.customActions.map(
        (e) => StreamChatContextMenuItem(
          leading: e.leading,
          title: e.title,
          onClick: () => e.onTap?.call(widget.message),
        ),
      ),
    ];
  }

  List<Widget> buildContextMenu() {
    return messageActionItems(iconSize: 24);
  }

  Widget actionBar() {
    const iconSize = 14.0;
    final items = messageActionItems(iconSize: iconSize);
    
    return showBottomRow ? Container(
      padding: EdgeInsets.zero,
      child: Wrap(
        spacing: 16,
        children: [
          for (final item in items)
            if (item.leading != null)
              Tooltip(
                height: 0,
                padding: EdgeInsets.zero,
                margin: EdgeInsets.zero,
                message: (item.title as Text?)?.data ?? '',
                child: MouseRegion(
                  cursor: SystemMouseCursors.click,
                  child: GestureDetector(
                    onTap: item.onClick,
                    child: item.leading!,
                  ),
                ),
              ),
        ],
      ),
    ) : const SizedBox.shrink();
  }

  void showMessageReactionsModal(BuildContext context) {
    final channel = StreamChannel.of(context).channel;

    showDialog(
      useRootNavigator: false,
      context: context,
      useSafeArea: false,
      barrierColor: streamChatTheme.colorTheme.overlay,
      builder: (context) => StreamChannel(
        channel: channel,
        child: StreamMessageReactionsModal(
          showReactionPicker: widget.showReactionPicker,
          messageWidget: widget.copyWith(
            key: const Key('MessageWidget'),
            message: widget.message.copyWith(
              text: (widget.message.text?.length ?? 0) > 200
                  ? '${widget.message.text!.substring(0, 200)}...'
                  : widget.message.text,
            ),
            showReactions: true,
            showReactionTail: calculateReactionTailEnabled(
              ReactionTailType.reactions,
            ),
            showUsername: true,
            showTimestamp: true,
            showActionBar: false,
            translateUserAvatar: false,
            showSendingIndicator: true,
            padding: EdgeInsets.zero,
            showReactionPicker: widget.showReactionPicker,
            showPinHighlight: false,
            showUserAvatar:
                widget.message.user!.id == channel.client.state.currentUser!.id
                    ? DisplayWidget.gone
                    : DisplayWidget.show,
          ),
          onUserAvatarTap: widget.onUserAvatarTap,
          messageTheme: widget.messageTheme,
          reverse: widget.reverse,
          message: widget.message,
        ),
      ),
    );
  }

  void onLongPress(BuildContext context) {
    if (widget.message.isEphemeral || widget.message.state.isOutgoing) {
      return;
    }

    if (widget.onMessageActions != null) {
      return widget.onMessageActions!(context, widget.message);
    }

    return _showMessageActionModalBottomSheet(context);
  }

  void _showMessageActionModalBottomSheet(BuildContext context) {
    final channel = StreamChannel.of(context).channel;

    showDialog(
      useRootNavigator: false,
      context: context,
      useSafeArea: false,
      barrierColor: streamChatTheme.colorTheme.overlay,
      builder: (context) {
        return StreamChannel(
          channel: channel,
          child: MessageActionsModal(
            messageWidget: widget.copyWith(
              key: const Key('MessageWidget'),
              message: widget.message.copyWith(
                text: (widget.message.text?.length ?? 0) > 200
                    ? '${widget.message.text!.substring(0, 200)}...'
                    : widget.message.text,
              ),
              showReactions: false,
              showReactionTail: calculateReactionTailEnabled(
                ReactionTailType.messageActions,
              ),
              showUsername: true,
              showTimestamp: true,
              translateUserAvatar: false,
              showSendingIndicator: true,
              padding: EdgeInsets.zero,
              showPinHighlight: false,
              showUserAvatar: widget.message.user!.id ==
                      channel.client.state.currentUser!.id
                  ? DisplayWidget.gone
                  : DisplayWidget.show,
            ),
            onCopyTap: (message) {
              var messageToCopy = message.text;
              for (final user in widget.message.mentionedUsers.toSet()) {
                final userId = user.id;
                final userName = user.name;
                messageToCopy = messageToCopy?.replaceAll(
                      RegExp('@($userId|$userName)'),
                      '@$userName',
                    ) ??
                    '';
              }
              if (messageToCopy != null) {
                Clipboard.setData(
                  ClipboardData(text: messageToCopy),
                );
              }
            },
            messageTheme: widget.messageTheme,
            reverse: widget.reverse,
            showDeleteMessage: shouldShowDeleteAction,
            onConfirmDeleteTap: widget.onConfirmDeleteTap,
            message: widget.message,
            editMessageInputBuilder: widget.editMessageInputBuilder,
            onReplyTap: widget.onReplyTap,
            onThreadReplyTap: widget.onThreadTap,
            showResendMessage: shouldShowResendAction,
            showCopyMessage: shouldShowCopyAction,
            showEditMessage: shouldShowEditAction,
            showHideMessage: shouldShowHideMessageAction,
            onHideMessageTap: widget.onHideMessageTap,
            showRegenerateMessage: shouldShowRegenerateMessage,
            onRegenerateTap: widget.onRegenerateTap,
            showReadAloudMessage: shouldShowReadAloudMessage,
            onReadAloudTap: widget.onReadAloudTap,
            showReactionPicker: widget.showReactionPicker,
            showReplyMessage: shouldShowReplyAction,
            showThreadReplyMessage: shouldShowThreadReplyAction,
            showFlagButton: widget.showFlagButton,
            showPinButton: widget.showPinButton,
            showMarkUnreadMessage: widget.showMarkUnreadMessage,
            customActions: widget.customActions,
          ),
        );
      },
    );
  }

  /// Calculates if the reaction picker tail should be enabled.
  bool calculateReactionTailEnabled(ReactionTailType type) {
    if (widget.showReactionTail != null) return widget.showReactionTail!;

    switch (type) {
      case ReactionTailType.list:
        return false;
      case ReactionTailType.messageActions:
        return widget.showReactionPicker;
      case ReactionTailType.reactions:
        return widget.showReactionPicker;
    }
  }
}

/// Enum for declaring the location of the message for which the reaction picker
/// is to be enabled.
enum ReactionTailType {
  /// Message is in the [StreamMessageListView]
  list,

  /// Message is in the [MessageActionsModal]
  messageActions,

  /// Message is in the message reactions modal
  reactions,
}