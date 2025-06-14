import 'dart:async';
import 'dart:math';

import 'package:desktop_drop/desktop_drop.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:photo_manager/photo_manager.dart';
import 'package:stream_chat_flutter/platform_widget_builder/src/platform_widget_builder.dart';
import 'package:stream_chat_flutter/src/message_input/attachment_button.dart';
import 'package:stream_chat_flutter/src/message_input/command_button.dart';
import 'package:stream_chat_flutter/src/message_input/dm_checkbox.dart';
import 'package:stream_chat_flutter/src/message_input/quoted_message_widget.dart';
import 'package:stream_chat_flutter/src/message_input/quoting_message_top_area.dart';
import 'package:stream_chat_flutter/src/message_input/simple_safe_area.dart';
import 'package:stream_chat_flutter/src/message_input/tld.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';

const _kCommandTrigger = '/';
const _kMentionTrigger = '@';

/// Signature for the function that determines if a [matchedUri] should be
/// previewed as an OG Attachment.
typedef OgPreviewFilter = bool Function(
  Uri matchedUri,
  String messageText,
);

/// Different types of hints that can be shown in [StreamMessageInput].
enum HintType {
  /// Hint for [StreamMessageInput] when the command is enabled and the command
  /// is 'giphy'.
  searchGif,

  /// Hint for [StreamMessageInput] when there are attachments.
  addACommentOrSend,

  /// Hint for [StreamMessageInput] when slow mode is enabled.
  slowModeOn,

  /// Hint for [StreamMessageInput] when other conditions are not met.
  writeAMessage,
}

/// Function that returns the hint text for [StreamMessageInput] based on
/// [type].
typedef HintGetter = String? Function(BuildContext context, HintType type);

/// The signature for the function that builds the list of actions.
typedef ActionsBuilder = List<Widget> Function(
  BuildContext context,
  List<Widget> defaultActions,
);

/// Signature for the function that determines if a key event should trigger
/// sending a message.
typedef AsyncKeyEventPredicate = FutureOr<bool> Function(
  FocusNode node,
  KeyEvent event,
);

/// Inactive state:
///
/// ![screenshot](https://raw.githubusercontent.com/GetStream/stream-chat-flutter/master/packages/stream_chat_flutter/screenshots/message_input.png)
/// ![screenshot](https://raw.githubusercontent.com/GetStream/stream-chat-flutter/master/packages/stream_chat_flutter/screenshots/message_input_paint.png)
///
/// Focused state:
///
/// ![screenshot](https://raw.githubusercontent.com/GetStream/stream-chat-flutter/master/packages/stream_chat_flutter/screenshots/message_input2.png)
/// ![screenshot](https://raw.githubusercontent.com/GetStream/stream-chat-flutter/master/packages/stream_chat_flutter/screenshots/message_input2_paint.png)
///
/// Widget used to enter a message and add attachments:
///
/// ```dart
/// class ChannelPage extends StatelessWidget {
///   const ChannelPage({
///     Key? key,
///   }) : super(key: key);
///
///   @override
///   Widget build(BuildContext context) => Scaffold(
///         appBar: const StreamChannelHeader(),
///         body: Column(
///           children: <Widget>[
///             Expanded(
///               child: StreamMessageListView(
///                 threadBuilder: (_, parentMessage) => ThreadPage(
///                   parent: parentMessage,
///                 ),
///               ),
///             ),
///             const StreamMessageInput(),
///           ],
///         ),
///       );
/// }
/// ```
///
/// You usually put this widget in the same page of a [StreamMessageListView]
/// as the bottom widget.
///
/// The widget renders the ui based on the first ancestor of
/// type [StreamChatTheme]. Modify it to change the widget appearance.
class StreamMessageInput extends StatefulWidget {
  /// Instantiate a new MessageInput
  const StreamMessageInput({
    super.key,
    this.onMessageSent,
    this.onMessageSentAsync,
    this.preMessageSending,
    this.maxHeight = 150,
    this.maxLines,
    this.minLines,
    this.textInputAction,
    this.keyboardType,
    this.textCapitalization = TextCapitalization.sentences,
    this.disableAttachments = false,
    this.messageInputController,
    this.actionsBuilder,
    this.spaceBetweenActions = 8,
    this.actionsLocation = ActionsLocation.left,
    this.attachmentListBuilder,
    this.fileAttachmentListBuilder,
    this.mediaAttachmentListBuilder,
    this.fileAttachmentBuilder,
    this.mediaAttachmentBuilder,
    this.focusNode,
    this.sendButtonLocation = SendButtonLocation.outside,
    this.autofocus = false,
    this.hideSendAsDm = false,
    this.idleSendButton,
    this.activeSendButton,
    this.showCommandsButton = true,
    this.userMentionsTileBuilder,
    this.maxAttachmentSize = kDefaultMaxAttachmentSize,
    this.onError,
    this.attachmentLimit = 10,
    this.allowedAttachmentPickerTypes = AttachmentPickerType.values,
    this.onAttachmentLimitExceed,
    this.attachmentButtonBuilder,
    this.commandButtonBuilder,
    this.customAutocompleteTriggers = const [],
    this.mentionAllAppUsers = false,
    this.sendButtonBuilder,
    this.sendButtonSize = 28.0,
    this.quotedMessageBuilder,
    this.quotedMessageAttachmentThumbnailBuilders,
    this.shouldKeepFocusAfterMessage,
    this.validator = _defaultValidator,
    this.restorationId,
    this.enableSafeArea,
    this.elevation,
    this.shadow,
    this.autoCorrect = true,
    this.enableMentionsOverlay = true,
    this.onQuotedMessageCleared,
    this.enableActionAnimation = true,
    this.sendMessageKeyPredicate = _defaultSendMessageKeyPredicate,
    this.clearQuotedMessageKeyPredicate = _defaultClearQuotedMessageKeyPredicate,
    this.ogPreviewFilter = _defaultOgPreviewFilter,
    this.hintGetter = _defaultHintGetter,
    this.contentInsertionConfiguration,
    this.useNativeAttachmentPickerOnMobile = false,
    this.filePickerCustomOptions,
    this.actionsShrunkFunction,
    this.streamCommandAutoCompleteOptionsBuilder,
    this.containsCommandFunction,
    this.prefixIconWidget,
    this.onAttachmentRemovePressed,
    this.autoCompleteExtraUsersFunction,
    this.onMentionUserTap,
    this.userMentionsWidgetBuilder,
    this.pollConfig,
    this.customMobileAttachmentPickerBuilder,
    this.customWebOrDesktopAttachmentPickerBuilder,
    this.enableSendButton = true,
  });

  /// The predicate used to send a message on desktop/web
  final AsyncKeyEventPredicate? sendMessageKeyPredicate;

  /// The predicate used to clear the quoted message on desktop/web
  final KeyEventPredicate? clearQuotedMessageKeyPredicate;

  /// If true the message input will animate the actions while you type
  final bool enableActionAnimation;

  /// List of triggers for showing autocomplete.
  final Iterable<StreamAutocompleteTrigger> customAutocompleteTriggers;

  /// Max attachment size in bytes:
  /// - Defaults to 20 MB
  /// - Do not set it if you're using our default CDN
  final int maxAttachmentSize;

  /// Function called after sending the message.
  final void Function(BuildContext, Message)? onMessageSent;

  /// Async Function called after sending the message.
  final Future<void> Function(BuildContext, Message)? onMessageSentAsync;

  /// Function called right before sending the message.
  ///
  /// Use this to transform the message.
  final FutureOr<Message> Function(Message)? preMessageSending;

  /// Maximum Height for the TextField to grow before it starts scrolling.
  final double maxHeight;

  /// The maximum lines of text the input can span.
  final int? maxLines;

  /// The minimum lines of text the input can span.
  final int? minLines;

  /// The type of action button to use for the keyboard.
  final TextInputAction? textInputAction;

  /// The keyboard type assigned to the TextField.
  final TextInputType? keyboardType;

  /// {@macro flutter.widgets.editableText.textCapitalization}
  final TextCapitalization textCapitalization;

  /// If true the attachments button will not be displayed.
  final bool disableAttachments;

  /// Use this property to hide/show the commands button.
  final bool showCommandsButton;

  /// Hide send as dm checkbox.
  final bool hideSendAsDm;

  /// The text controller of the TextField.
  final StreamMessageInputController? messageInputController;

  /// List of action widgets.
  final ActionsBuilder? actionsBuilder;

  /// Space between the actions.
  final double spaceBetweenActions;

  /// The location of the custom actions.
  final ActionsLocation actionsLocation;

  /// Builder used to build the attachment list present in the message input.
  ///
  /// In case you want to customize only sub-parts of the attachment list,
  /// consider using [fileAttachmentListBuilder], [mediaAttachmentListBuilder].
  final AttachmentListBuilder? attachmentListBuilder;

  /// Builder used to build the file type attachment list.
  ///
  /// In case you want to customize the attachment item, consider using
  /// [fileAttachmentBuilder].
  final AttachmentListBuilder? fileAttachmentListBuilder;

  /// Builder used to build the media type attachment list.
  ///
  /// In case you want to customize the attachment item, consider using
  /// [mediaAttachmentBuilder].
  final AttachmentListBuilder? mediaAttachmentListBuilder;

  /// Builder used to build the file attachment item.
  final AttachmentItemBuilder? fileAttachmentBuilder;

  /// Builder used to build the media attachment item.
  final AttachmentItemBuilder? mediaAttachmentBuilder;

  /// Map that defines a thumbnail builder for an attachment type.
  ///
  /// This is used to build the thumbnail for the attachment in the quoted
  /// message.
  final Map<String, QuotedMessageAttachmentThumbnailBuilder>?
      quotedMessageAttachmentThumbnailBuilders;

  /// The focus node associated to the TextField.
  final FocusNode? focusNode;

  /// The location of the send button
  final SendButtonLocation sendButtonLocation;

  /// Autofocus property passed to the TextField
  final bool autofocus;

  /// Send button widget in an idle state
  final Widget? idleSendButton;

  /// Send button widget in an active state
  final Widget? activeSendButton;

  /// Customize the tile for the mentions overlay.
  final UserMentionTileBuilder? userMentionsTileBuilder;

  /// A callback for error reporting
  final ErrorListener? onError;

  /// A limit for the no. of attachments that can be sent with a single message.
  final int attachmentLimit;

  /// The list of allowed attachment types which can be picked using the
  /// attachment button.
  ///
  /// By default, all the attachment types are allowed.
  final List<AttachmentPickerType> allowedAttachmentPickerTypes;

  /// A callback for when the [attachmentLimit] is exceeded.
  ///
  /// This will override the default error alert behaviour.
  final AttachmentLimitExceedListener? onAttachmentLimitExceed;

  /// Builder for customizing the attachment button.
  ///
  /// The builder contains the default [AttachmentButton] that can be customized
  /// by calling `.copyWith`.
  final AttachmentButtonBuilder? attachmentButtonBuilder;

  /// Builder for customizing the command button.
  ///
  /// The builder contains the default [CommandButton] that can be customized by
  /// calling `.copyWith`.
  final CommandButtonBuilder? commandButtonBuilder;

  /// When enabled mentions search users across the entire app.
  ///
  /// Defaults to false.
  final bool mentionAllAppUsers;

  /// Builder for creating send button
  final MessageRelatedBuilder? sendButtonBuilder;

  /// The size of the send button.
  final double sendButtonSize;

  /// Builder for building quoted message
  final Widget Function(BuildContext, Message)? quotedMessageBuilder;

  /// Defines if the [StreamMessageInput] loses focuses after a message is sent.
  /// The default behaviour keeps focus until a command is enabled.
  final bool? shouldKeepFocusAfterMessage;

  /// A callback function that validates the message.
  final MessageValidator validator;

  /// Restoration ID to save and restore the state of the MessageInput.
  final String? restorationId;

  /// Wrap [StreamMessageInput] with a [SafeArea widget]
  final bool? enableSafeArea;

  /// Elevation of the [StreamMessageInput]
  final double? elevation;

  /// Shadow for the [StreamMessageInput] widget
  final BoxShadow? shadow;

  /// Disable autoCorrect by passing false
  /// autoCorrect is enabled by default
  final bool autoCorrect;

  /// Disable the mentions overlay by passing false
  /// Enabled by default
  final bool enableMentionsOverlay;

  /// Callback for when the quoted message is cleared
  final VoidCallback? onQuotedMessageCleared;

  /// The filter used to determine if a link should be shown as an OpenGraph
  /// preview.
  final OgPreviewFilter ogPreviewFilter;

  /// Returns the hint text for the message input.
  final HintGetter hintGetter;

  /// {@macro flutter.widgets.editableText.contentInsertionConfiguration}
  final ContentInsertionConfiguration? contentInsertionConfiguration;

  /// Custom options for the file picker
  final Iterable<AttachmentPickerOption>? filePickerCustomOptions;

  final bool Function(StreamMessageInputController, int)? actionsShrunkFunction;

  final Widget Function(BuildContext, String, StreamMessageInputController)? streamCommandAutoCompleteOptionsBuilder;

  final Future<Message> Function(Message)? containsCommandFunction;

  final Widget Function(BuildContext, StreamMessageInputController)? prefixIconWidget;

    /// Forces use of native attachment picker on mobile instead of the custom
  /// Stream attachment picker.
  final bool useNativeAttachmentPickerOnMobile;

  final Future<void> Function(Attachment)? onAttachmentRemovePressed;

  final Future<List<User>> Function(String)? autoCompleteExtraUsersFunction;

  final void Function(BuildContext, User)? onMentionUserTap;

  final Widget Function(BuildContext, StreamMessageInputController)? userMentionsWidgetBuilder;
  /// The configuration to use while creating a poll.
  ///
  /// If not provided, the default configuration is used.
  final PollConfig? pollConfig;

  /// Custom mobile attachment picker builder
  final MobileAttachmentPickerBuilderType? customMobileAttachmentPickerBuilder;

  /// Custom web or desktop attachment picker builder
  final WebOrDesktopAttachmentPickerBuilderType? customWebOrDesktopAttachmentPickerBuilder;

  /// added to control the send button idle state in addition to the validation state
  final bool enableSendButton;

  static String? _defaultHintGetter(
    BuildContext context,
    HintType type,
  ) {
    switch (type) {
      case HintType.searchGif:
        return context.translations.searchGifLabel;
      case HintType.addACommentOrSend:
        return context.translations.addACommentOrSendLabel;
      case HintType.slowModeOn:
        return context.translations.slowModeOnLabel;
      case HintType.writeAMessage:
        return context.translations.writeAMessageLabel;
    }
  }

  static bool _defaultOgPreviewFilter(
    Uri matchedUri,
    String messageText,
  ) {
    // Show the preview for all links
    return true;
  }

  static bool _defaultValidator(Message message) =>
      message.text?.isNotEmpty == true || message.attachments.isNotEmpty;

  static FutureOr<bool> _defaultSendMessageKeyPredicate(
    FocusNode node,
    KeyEvent event,
  ) {
    if (CurrentPlatform.isWeb ||
        CurrentPlatform.isMacOS ||
        CurrentPlatform.isWindows ||
        CurrentPlatform.isLinux) {
      // On desktop/web, send the message when the user presses the enter key.
      return event is KeyUpEvent &&
          event.logicalKey == LogicalKeyboardKey.enter;
    }

    return false;
  }

  static bool _defaultClearQuotedMessageKeyPredicate(
    FocusNode node,
    KeyEvent event,
  ) {
    if (CurrentPlatform.isWeb ||
        CurrentPlatform.isMacOS ||
        CurrentPlatform.isWindows ||
        CurrentPlatform.isLinux) {
      // On desktop/web, clear the quoted message when the user presses the escape key.
      return event is KeyUpEvent &&
          event.logicalKey == LogicalKeyboardKey.escape;
    }

    return false;
  }

  @override
  StreamMessageInputState createState() => StreamMessageInputState();
}

/// State of [StreamMessageInput]
class StreamMessageInputState extends State<StreamMessageInput>
    with RestorationMixin<StreamMessageInput>, WidgetsBindingObserver {
  bool get _commandEnabled => _effectiveController.message.command != null || _effectiveController.message.extraData['customCommand'] != null;

  bool _actionsShrunk = false;

  late StreamChatThemeData _streamChatTheme;
  late StreamMessageInputThemeData _messageInputTheme;

  bool get _hasQuotedMessage =>
      _effectiveController.message.quotedMessage != null;

  bool get _isEditing => !_effectiveController.message.state.isInitial;

  BoxBorder? _draggingBorder;

  FocusNode get _effectiveFocusNode =>
      widget.focusNode ?? (_focusNode ??= FocusNode());
  FocusNode? _focusNode;

  StreamMessageInputController get _effectiveController =>
      widget.messageInputController ?? _controller!.value;
  StreamRestorableMessageInputController? _controller;

  late final Future<void> Function(Attachment) _onAttachmentRemovePressed;

  void _createLocalController([Message? message]) {
    assert(_controller == null, '');
    _controller = StreamRestorableMessageInputController(message: message);
  }

  void _registerController() {
    assert(_controller != null, '');

    registerForRestoration(_controller!, 'messageInputController');
    _effectiveController
      ..removeListener(_onChangedDebounced)
      ..addListener(_onChangedDebounced);
    if (!_isEditing && _timeOut <= 0) _startSlowMode();
  }

  void _initialiseEffectiveController() {
    _effectiveController
      ..removeListener(_onChangedDebounced)
      ..addListener(_onChangedDebounced);
    if (!_isEditing && _timeOut <= 0) _startSlowMode();
  }

  // Add a new ValueNotifier to track validation state
  late final ValueNotifier<bool> validationNotifier = ValueNotifier(false);
  
  CancelableOperation<bool>? _currentValidation;

  Future<void> _updateValidationState() async {
    // Cancel any pending validation
    await _currentValidation?.cancel();

    final validationResult = widget.validator(_effectiveController.message);
    
    if (validationResult is Future<bool>) {
      _currentValidation = CancelableOperation.fromFuture(
        validationResult,
      );
      
      final isValid = await _currentValidation?.value;
      if (isValid != null) { // Check if operation wasn't cancelled
        validationNotifier.value = isValid;
      }
    } else {
      // Handle synchronous result
      validationNotifier.value = validationResult as bool;
    }
  }

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    
    _onAttachmentRemovePressed = widget.onAttachmentRemovePressed ?? defaultOnAttachmentRemovePressed;

    if (widget.messageInputController == null) {
      _createLocalController();
    } else {
      _initialiseEffectiveController();
    }
    _effectiveFocusNode.addListener(_focusNodeListener);
    
    // Initial validation
    _updateValidationState();
    
    // Add listener to controller to trigger validation
    _effectiveController.addListener(_updateValidationState);
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _streamChatTheme = StreamChatTheme.of(context);
    _messageInputTheme = StreamMessageInputTheme.of(context);
  }

  bool _askingForPermission = false;

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) async {
    if (state == AppLifecycleState.resumed &&
        _permissionState != null &&
        !_askingForPermission) {
      _askingForPermission = true;

      try {
        final newPermissionState = await PhotoManager.requestPermissionExtend();
        if (newPermissionState != _permissionState && mounted) {
          setState(() {
            _permissionState = newPermissionState;
          });
        }
      } catch (_) {}

      _askingForPermission = false;
    }
    super.didChangeAppLifecycleState(state);
  }

  @override
  void didUpdateWidget(covariant StreamMessageInput oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (widget.messageInputController == null &&
        oldWidget.messageInputController != null) {
      _createLocalController(oldWidget.messageInputController!.message);
    } else if (widget.messageInputController != null &&
        oldWidget.messageInputController == null) {
      unregisterFromRestoration(_controller!);
      _controller!.dispose();
      _controller = null;
      _initialiseEffectiveController();
    }

    // Update _focusNode
    if (widget.focusNode != oldWidget.focusNode) {
      (oldWidget.focusNode ?? _focusNode)?.removeListener(_focusNodeListener);
      (widget.focusNode ?? _focusNode)?.addListener(_focusNodeListener);
    }
  }

  @override
  void restoreState(RestorationBucket? oldBucket, bool initialRestore) {
    if (_controller != null) {
      _registerController();
    }
  }

  @override
  String? get restorationId => widget.restorationId;

  // ignore: no-empty-block
  void _focusNodeListener() {}

  int _timeOut = 0;
  Timer? _slowModeTimer;

  PermissionState? _permissionState;

  void _startSlowMode() {
    if (!mounted) {
      return;
    }
    final channel = StreamChannel.of(context).channel;
    final cooldownStartedAt = channel.cooldownStartedAt;
    if (cooldownStartedAt != null) {
      final diff = DateTime.now().difference(cooldownStartedAt).inSeconds;
      if (diff < channel.cooldown) {
        _timeOut = channel.cooldown - diff;
        if (_timeOut > 0) {
          _slowModeTimer = Timer.periodic(const Duration(seconds: 1), (timer) {
            if (_timeOut == 0) {
              timer.cancel();
            } else {
              if (mounted) {
                setState(() => _timeOut -= 1);
              }
            }
          });
        }
      }
    }
  }

  void _stopSlowMode() => _slowModeTimer?.cancel();

  @override
  Widget build(BuildContext context) {
    final channel = StreamChannel.of(context).channel;
    if (channel.state != null &&
        !channel.ownCapabilities.contains(PermissionType.sendMessage)) {
      return SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 24,
            vertical: 15,
          ),
          child: Text(
            context.translations.sendMessagePermissionError,
            style: _messageInputTheme.inputTextStyle,
          ),
        ),
      );
    }

    return StreamMessageValueListenableBuilder(
      valueListenable: _effectiveController,
      builder: (context, value, _) {
        Widget child = DecoratedBox(
          decoration: BoxDecoration(
            color: _messageInputTheme.inputBackgroundColor,
            boxShadow: widget.shadow == null
                ? (_streamChatTheme.messageInputTheme.shadow == null
                    ? []
                    : [_streamChatTheme.messageInputTheme.shadow!])
                : [widget.shadow!],
          ),
          child: SimpleSafeArea(
            enabled: widget.enableSafeArea ??
                _streamChatTheme.messageInputTheme.enableSafeArea ??
                true,
            child: GestureDetector(
              onPanUpdate: (details) {
                if (details.delta.dy > 0) {
                  _effectiveFocusNode.unfocus();
                }
              },
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  if (_hasQuotedMessage && !_isEditing)
                    // Ensure this doesn't show on web & desktop
                    PlatformWidgetBuilder(
                      mobile: (context, child) => child,
                      child: QuotingMessageTopArea(
                        hasQuotedMessage: _hasQuotedMessage,
                        onQuotedMessageCleared: widget.onQuotedMessageCleared,
                      ),
                    )
                  else if (_effectiveController.ogAttachment != null)
                    OGAttachmentPreview(
                      attachment: _effectiveController.ogAttachment!,
                      onDismissPreviewPressed: () {
                        _effectiveController.clearOGAttachment();
                        _effectiveFocusNode.unfocus();
                      },
                    ),
                  Padding(
                    padding: const EdgeInsets.symmetric(vertical: 8),
                    child: _buildTextField(context),
                  ),
                  if (_effectiveController.message.parentId != null &&
                      !widget.hideSendAsDm)
                    Padding(
                      padding: const EdgeInsets.only(
                        right: 12,
                        left: 12,
                        bottom: 12,
                      ),
                      child: DmCheckbox(
                        foregroundDecoration: BoxDecoration(
                          border: _effectiveController.showInChannel
                              ? null
                              : Border.all(
                                  color: _streamChatTheme
                                      .colorTheme.textHighEmphasis
                                      // ignore: deprecated_member_use
                                      .withOpacity(0.5),
                                  width: 2,
                                ),
                          borderRadius: BorderRadius.circular(3),
                        ),
                        color: _effectiveController.showInChannel
                            ? _streamChatTheme.colorTheme.accentPrimary
                            : _streamChatTheme.colorTheme.barsBg,
                        onTap: () {
                          _effectiveController.showInChannel =
                              !_effectiveController.showInChannel;
                        },
                        crossFadeState: _effectiveController.showInChannel
                            ? CrossFadeState.showFirst
                            : CrossFadeState.showSecond,
                      ),
                    ),
                ],
              ),
            ),
          ),
        );
        if (!_isEditing) {
          child = Material(
            elevation: widget.elevation ??
                _streamChatTheme.messageInputTheme.elevation ??
                8,
            color: _messageInputTheme.inputBackgroundColor,
            child: child,
          );
        }

        return StreamAutocomplete(
          focusNode: _effectiveFocusNode,
          messageEditingController: _effectiveController,
          fieldViewBuilder: (_, __, ___) => child,
          autocompleteTriggers: [
            ...widget.customAutocompleteTriggers,
            StreamAutocompleteTrigger(
              trigger: _kCommandTrigger,
              triggerOnlyAtStart: true,
              optionsViewBuilder: (
                context,
                autocompleteQuery,
                messageEditingController,
              ) {
                if (widget.showCommandsButton == false) {
                  return const Offstage();
                }
                else {
                  final query = autocompleteQuery.query;
                  if (widget.streamCommandAutoCompleteOptionsBuilder != null){
                    return widget.streamCommandAutoCompleteOptionsBuilder!(context, query, messageEditingController);
                  }
                  return StreamCommandAutocompleteOptions(
                    query: query,
                    channel: StreamChannel.of(context).channel,
                    onCommandSelected: (command) {
                      _effectiveController.command = command.name;
                      // removing the overlay after the command is selected
                      StreamAutocomplete.of(context).closeSuggestions();
                    },
                  );
                }
              },
            ),
            if (widget.enableMentionsOverlay)
              StreamAutocompleteTrigger(
                trigger: _kMentionTrigger,
                optionsViewBuilder: (
                  context,
                  autocompleteQuery,
                  messageEditingController,
                ) {
                  final query = autocompleteQuery.query;
                  return StreamMentionAutocompleteOptions(
                    client: StreamChat.of(context).client,
                    query: query,
                    autoCompleteExtraUsersFunction: widget.autoCompleteExtraUsersFunction,
                    channel: StreamChannel.of(context).channel,
                    mentionedUsers: _effectiveController.message.mentionedUsers,
                    mentionAllAppUsers: widget.mentionAllAppUsers,
                    mentionsTileBuilder: widget.userMentionsTileBuilder,
                    onMentionUserTap: widget.onMentionUserTap ?? (context, user) {
                      // adding the mentioned user to the controller.
                      _effectiveController.addMentionedUser(user);

                      // accepting the autocomplete option.
                      StreamAutocomplete.of(context)
                          .acceptAutocompleteOption(user.name);
                    },
                  );
                },
              ),
          ],
        );
      },
    );
  }

  Flex _buildTextField(BuildContext context) {
    return Flex(
      direction: Axis.horizontal,
      children: <Widget>[
        if (!_commandEnabled && widget.actionsLocation == ActionsLocation.left)
          _buildExpandActionsButton(context),
        _buildTextInput(context),
        if (!_commandEnabled && widget.actionsLocation == ActionsLocation.right)
          _buildExpandActionsButton(context),
        if (widget.sendButtonLocation == SendButtonLocation.outside)
          _buildSendButton(context),
      ],
    );
  }

  Widget _buildSendButton(BuildContext context) {
    if (widget.sendButtonBuilder != null) {
      return widget.sendButtonBuilder!(context, _effectiveController);
    }

    return ValueListenableBuilder<bool>(
      valueListenable: validationNotifier,
      builder: (context, isValid, _) {
        return StreamMessageSendButton(
          onSendMessage: sendMessage,
          timeOut: _timeOut,
          isIdle: widget.enableSendButton == false || !isValid,
          isEditEnabled: _isEditing,
          idleSendButton: widget.idleSendButton,
          activeSendButton: widget.activeSendButton,
          size: widget.sendButtonSize,
        );
      },
    );
  }

  Widget _buildExpandActionsButton(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 8),
      child: AnimatedCrossFade(
        crossFadeState: (_actionsShrunk && widget.enableActionAnimation)
            ? CrossFadeState.showFirst
            : CrossFadeState.showSecond,
        firstCurve: Curves.easeOut,
        secondCurve: Curves.easeIn,
        firstChild: IconButton(
          onPressed: () {
            if (_actionsShrunk) {
              setState(() => _actionsShrunk = false);
            }
          },
          icon: Transform.rotate(
            angle: (widget.actionsLocation == ActionsLocation.right ||
                    widget.actionsLocation == ActionsLocation.rightInside)
                ? pi
                : 0,
            child: StreamSvgIcon.emptyCircleLeft(
              color: _messageInputTheme.expandButtonColor,
            ),
          ),
          padding: EdgeInsets.zero,
          constraints: const BoxConstraints.tightFor(
            height: 24,
            width: 24,
          ),
          splashRadius: 24,
        ),
        secondChild: widget.disableAttachments &&
                !widget.showCommandsButton &&
                !(widget.actionsBuilder != null)
            ? const Offstage()
            : Wrap(
                children: _actionsList()
                    .insertBetween(SizedBox(width: widget.spaceBetweenActions)),
              ),
        duration: const Duration(milliseconds: 300),
        alignment: Alignment.center,
      ),
    );
  }

  List<Widget> _actionsList() {
    final channel = StreamChannel.of(context).channel;
    final defaultActions = <Widget>[
      if (!widget.disableAttachments)
        _buildAttachmentButton(context),
      if (widget.showCommandsButton &&
          !_isEditing &&
          channel.state != null &&
          channel.config?.commands.isNotEmpty == true)
        _buildCommandButton(context),
    ];
    if (widget.actionsBuilder != null) {
      return widget.actionsBuilder!(
        context,
        defaultActions,
      );
    } else {
      return defaultActions;
    }
  }

  Widget _buildAttachmentButton(BuildContext context) {
    final defaultButton = AttachmentButton(
      color: _messageInputTheme.actionButtonIdleColor,
      onPressed: _onAttachmentButtonPressed,
    );

    return widget.attachmentButtonBuilder?.call(context, defaultButton) ??
        defaultButton;
  }

  Future<void> _sendPoll(Poll poll) {
    final streamChannel = StreamChannel.of(context);
    final channel = streamChannel.channel;

    return channel.sendPoll(poll);
  }

  Future<void> _updatePoll(Poll poll) {
    final streamChannel = StreamChannel.of(context);
    final channel = streamChannel.channel;

    return channel.updatePoll(poll);
  }

  Future<void> _deletePoll(Poll poll) {
    final streamChannel = StreamChannel.of(context);
    final channel = streamChannel.channel;

    return channel.deletePoll(poll);
  }

  Future<void> _createOrUpdatePoll(Poll? old, Poll? current) async {
    // If both are null or the same, return
    if ((old == null && current == null) || old == current) return;

    // If old is null, i.e., there was no poll before, create the poll.
    if (old == null) return _sendPoll(current!);

    // If current is null, i.e., the poll is removed, delete the poll.
    if (current == null) return _deletePoll(old);

    // Otherwise, update the poll.
    return _updatePoll(current);
  }

  /// Handle the platform-specific logic for selecting files.
  ///
  /// On mobile, this will open the file selection bottom sheet. On desktop,
  /// this will open the native file system and allow the user to select one
  /// or more files.
  Future<void> _onAttachmentButtonPressed() async {
    final initialPoll = _effectiveController.poll;
    final initialAttachments = _effectiveController.attachments;

    // Remove AttachmentPickerType.poll if the user doesn't have the permission
    // to send a poll or if this is a thread message.
    final allowedTypes = [...widget.allowedAttachmentPickerTypes]
      ..removeWhere((it) {
        if (it != AttachmentPickerType.poll) return false;
        if (_effectiveController.message.parentId != null) return true;
        final channel = StreamChannel.of(context).channel;
        if (channel.ownCapabilities.contains(PermissionType.sendPoll)) {
          return false;
        }

        return true;
      });

    final value = await showStreamAttachmentPickerModalBottomSheet(
      context: context,
      constraints: BoxConstraints(
        maxHeight: MediaQuery.of(context).size.height * 0.5,
      ),
      onError: widget.onError,
      allowedTypes: allowedTypes,
      pollConfig: widget.pollConfig,
      initialPoll: initialPoll,
      initialAttachments: initialAttachments,
      useNativeAttachmentPickerOnMobile:
          widget.useNativeAttachmentPickerOnMobile,
      customOptions: widget.filePickerCustomOptions,
      customMobileAttachmentPickerBuilder: widget.customMobileAttachmentPickerBuilder,
      customWebOrDesktopAttachmentPickerBuilder: widget.customWebOrDesktopAttachmentPickerBuilder,
    );

    if (value == null || value is! AttachmentPickerValue) return;

    // Add the attachments to the controller.
    _effectiveController.attachments = value.attachments;

    // Create or update the poll.
    await _createOrUpdatePoll(initialPoll, value.poll);
  }

  Expanded _buildTextInput(BuildContext context) {
    final margin = (widget.sendButtonLocation == SendButtonLocation.inside
            ? const EdgeInsets.only(right: 8)
            : EdgeInsets.zero) +
        (widget.actionsLocation != ActionsLocation.left || _commandEnabled
            ? const EdgeInsets.only(left: 8)
            : EdgeInsets.zero);

    return Expanded(
      child: DropTarget(
        onDragDone: (details) async {
          final files = details.files;
          final attachments = <Attachment>[];
          for (final file in files) {
            final attachment = await file.toAttachment(type: 'file');
            attachments.add(attachment);
          }

          if (attachments.isNotEmpty) _addAttachments(attachments);
        },
        onDragEntered: (details) {
          setState(() {
            _draggingBorder = Border.all(
              color: _streamChatTheme.colorTheme.accentPrimary,
            );
          });
        },
        onDragExited: (details) {
          setState(() => _draggingBorder = null);
        },
        child: Container(
          clipBehavior: Clip.hardEdge,
          margin: margin,
          decoration: BoxDecoration(
            borderRadius: _messageInputTheme.borderRadius,
            gradient: _effectiveFocusNode.hasFocus
                ? _messageInputTheme.activeBorderGradient
                : _messageInputTheme.idleBorderGradient,
            border: _draggingBorder,
          ),
          child: Padding(
            padding: const EdgeInsets.all(1.5),
            child: DecoratedBox(
              decoration: BoxDecoration(
                borderRadius: _messageInputTheme.borderRadius,
                color: _messageInputTheme.inputBackgroundColor,
              ),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  _buildReplyToMessage(),
                  _buildAttachments(),
                  if (widget.userMentionsWidgetBuilder != null)
                    widget.userMentionsWidgetBuilder!(context, _effectiveController),
                  LimitedBox(
                    maxHeight: widget.maxHeight,
                    child: PlatformWidgetBuilder(
                      web: (context, child) => Focus(
                        skipTraversal: true,
                        onKeyEvent: _handleKeyPressed,
                        child: child!,
                      ),
                      desktop: (context, child) => Focus(
                        skipTraversal: true,
                        onKeyEvent: _handleKeyPressed,
                        child: child!,
                      ),
                      mobile: (context, child) => Focus(
                        skipTraversal: true,
                        onKeyEvent: _handleKeyPressed,
                        child: child!,
                      ),
                      child: StreamMessageTextField(
                        key: const Key('messageInputText'),
                        maxLines: widget.maxLines,
                        minLines: widget.minLines,
                        textInputAction: widget.textInputAction,
                        onSubmitted: (_) => sendMessage(),
                        keyboardType: widget.keyboardType,
                        controller: _effectiveController,
                        focusNode: _effectiveFocusNode,
                        style: _messageInputTheme.inputTextStyle,
                        autofocus: widget.autofocus,
                        textAlignVertical: TextAlignVertical.center,
                        decoration: _getInputDecoration(context),
                        textCapitalization: widget.textCapitalization,
                        autocorrect: widget.autoCorrect,
                        contentInsertionConfiguration:
                            widget.contentInsertionConfiguration,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  KeyEventResult _handleKeyPressed(FocusNode node, KeyEvent event) {
    // Check for send message key.
    if ((event is KeyUpEvent || event is KeyDownEvent) && 
        (CurrentPlatform.isWeb ||
        CurrentPlatform.isMacOS ||
        CurrentPlatform.isWindows ||
        CurrentPlatform.isLinux) &&
        event.logicalKey == LogicalKeyboardKey.enter) {
      
      // Allow Shift+Enter to insert a new line
      if (HardwareKeyboard.instance.isShiftPressed) {
        return KeyEventResult.ignored;
      }
      
      // Always handle the Enter key to prevent new lines
      // Only send the message if it's valid and it's a KeyUpEvent
      if (validationNotifier.value && event is KeyUpEvent) {
        _handleSendMessageKeyPressed(node, event);
      }
      // Always return handled to prevent new line
      return KeyEventResult.handled;
    }

    // Check for clear quoted message key.
    if (widget.clearQuotedMessageKeyPredicate!(node, event)) {
      if (_hasQuotedMessage && _effectiveController.text.isEmpty) {
        widget.onQuotedMessageCleared?.call();
      }
      return KeyEventResult.handled;
    }

    // Return ignored to allow other key events to be handled.
    return KeyEventResult.ignored;
  }

  // New method to handle the async validation
  Future<void> _handleSendMessageKeyPressed(FocusNode node, KeyEvent event) async {
    final shouldSendMessage = await widget.sendMessageKeyPredicate!(node, event);
    if (shouldSendMessage && mounted) {
      sendMessage();
    }
  }

  InputDecoration _getInputDecoration(BuildContext context) {
    final passedDecoration = _messageInputTheme.inputDecoration;
    return InputDecoration(
      isDense: true,
      hintText: _getHint(context),
      hintStyle: _messageInputTheme.inputTextStyle!.copyWith(
        color: _streamChatTheme.colorTheme.textLowEmphasis,
      ),
      border: const OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.transparent,
        ),
      ),
      focusedBorder: const OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.transparent,
        ),
      ),
      enabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.transparent,
        ),
      ),
      errorBorder: const OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.transparent,
        ),
      ),
      disabledBorder: const OutlineInputBorder(
        borderSide: BorderSide(
          color: Colors.transparent,
        ),
      ),
      contentPadding: const EdgeInsets.fromLTRB(16, 12, 13, 11),
      prefixIcon: _commandEnabled ? 
          widget.prefixIconWidget != null ? 
          widget.prefixIconWidget!(context, _effectiveController) :
          Padding(
              padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
              child: ConstrainedBox(
                constraints: const BoxConstraints(
                  minWidth: 64, 
                  maxWidth: 100, 
                  minHeight: 24, 
                  maxHeight: 48,
                ),
                child: IntrinsicWidth(
                  child: Container(
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: _streamChatTheme.colorTheme.accentPrimary,
                    ),
                    alignment: Alignment.center,
                    child: Padding(
                      padding: const EdgeInsets.all(2),
                      child: Row(
                        mainAxisSize: MainAxisSize.min,
                        children: [
                          StreamSvgIcon.lightning(
                            color: Theme.of(context).colorScheme.surface,
                            size: 16,
                          ),
                          Flexible(
                            child: Text(
                              _effectiveController.message.command!.toUpperCase(),
                              style: _streamChatTheme.textTheme.footnoteBold.copyWith(
                                color: Theme.of(context).colorScheme.surface,
                              ),
                              maxLines: 2, 
                              overflow: TextOverflow.ellipsis, 
                              softWrap: true, 
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),
              ),
            )
          : (widget.actionsLocation == ActionsLocation.leftInside
              ? Row(
                  mainAxisSize: MainAxisSize.min,
                  children: [_buildExpandActionsButton(context)],
                )
              : null),
      suffixIconConstraints: const BoxConstraints.tightFor(height: 40),
      prefixIconConstraints: const BoxConstraints.tightFor(height: 40),
      suffixIcon: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (_commandEnabled)
            Padding(
              padding: const EdgeInsets.only(right: 8),
              child: IconButton(
                icon: StreamSvgIcon.closeSmall(),
                splashRadius: 24,
                padding: EdgeInsets.zero,
                constraints: const BoxConstraints.tightFor(
                  height: 24,
                  width: 24,
                ),
                onPressed: _effectiveController.clear,
              ),
            ),
          if (!_commandEnabled &&
              widget.actionsLocation == ActionsLocation.rightInside)
            _buildExpandActionsButton(context),
          if (widget.sendButtonLocation == SendButtonLocation.inside)
            _buildSendButton(context),
        ],
      ),
    ).merge(passedDecoration);
  }

  late final _onChangedDebounced = debounce(
    () {
      var value = _effectiveController.text;
      if (!mounted) return;
      value = value.trim();

      final channel = StreamChannel.of(context).channel;
      if (value.isNotEmpty &&
          channel.ownCapabilities.contains(PermissionType.sendTypingEvents)) {
        // Notify the server that the user started typing.
        channel.keyStroke(_effectiveController.message.parentId).onError(
          (error, stackTrace) {
            widget.onError?.call(error!, stackTrace);
          },
        );
      }

      int actionsLength;
      if (widget.actionsBuilder != null) {
        actionsLength = widget.actionsBuilder!(context, []).length;
      } else {
        actionsLength = 0;
      }
      if (widget.showCommandsButton) actionsLength += 1;
      if (!widget.disableAttachments) actionsLength += 1;

      setState(() => _actionsShrunk = widget.actionsShrunkFunction?.call(_effectiveController, actionsLength) ?? (value.isNotEmpty && actionsLength > 1));

      _checkContainsUrl(value, context);
    },
    const Duration(milliseconds: 350),
    leading: true,
  );

  String? _getHint(BuildContext context) {
    HintType hintType;

    if (_commandEnabled && _effectiveController.message.command == 'giphy') {
      hintType = HintType.searchGif;
    } else if (_effectiveController.attachments.isNotEmpty) {
      hintType = HintType.addACommentOrSend;
    } else if (_timeOut != 0) {
      hintType = HintType.slowModeOn;
    } else {
      hintType = HintType.writeAMessage;
    }

    return widget.hintGetter.call(context, hintType);
  }

  String? _lastSearchedContainsUrlText;
  CancelableOperation? _enrichUrlOperation;
  final _urlRegex = RegExp(
    r'https?://(www\.)?[-a-zA-Z0-9@:%._+~#=]{2,256}\.[a-z]{2,4}\b([-a-zA-Z0-9@:%_+.~#?&//=]*)',
    caseSensitive: false,
  );

  void _checkContainsUrl(String value, BuildContext context) async {
    // Cancel the previous operation if it's still running
    _enrichUrlOperation?.cancel();

    // If the text is same as the last time, don't do anything
    if (_lastSearchedContainsUrlText == value) return;
    _lastSearchedContainsUrlText = value;

    final matchedUrls = _urlRegex.allMatches(value).where((it) {
      final _parsedMatch = Uri.tryParse(it.group(0) ?? '')?.withScheme;
      if (_parsedMatch == null) return false;

      return _parsedMatch.host.split('.').last.isValidTLD() &&
          widget.ogPreviewFilter.call(_parsedMatch, value);
    }).toList();

    // Reset the og attachment if the text doesn't contain any url
    if (matchedUrls.isEmpty ||
        !StreamChannel.of(context)
            .channel
            .ownCapabilities
            .contains(PermissionType.sendLinks)) {
      _effectiveController.clearOGAttachment();
      return;
    }

    final firstMatchedUrl = matchedUrls.first.group(0)!;

    // If the parsed url matches the ogAttachment url, don't do anything
    if (_effectiveController.ogAttachment?.titleLink == firstMatchedUrl) {
      return;
    }

    final client = StreamChat.of(context).client;

    _enrichUrlOperation = CancelableOperation.fromFuture(
      _enrichUrl(firstMatchedUrl, client),
    ).then(
      (ogAttachment) {
        final attachment = Attachment.fromOGAttachment(ogAttachment);
        _effectiveController.setOGAttachment(attachment);
      },
      onError: (error, stackTrace) {
        // Reset the ogAttachment if there was an error
        _effectiveController.clearOGAttachment();
        widget.onError?.call(error, stackTrace);
      },
    );
  }

  final _ogAttachmentCache = <String, OGAttachmentResponse>{};

  Future<OGAttachmentResponse> _enrichUrl(
    String url,
    StreamChatClient client,
  ) async {
    var response = _ogAttachmentCache[url];
    if (response == null) {
      final client = StreamChat.of(context).client;
      try {
        response = await client.enrichUrl(url);
        _ogAttachmentCache[url] = response;
      } catch (e, stk) {
        return Future.error(e, stk);
      }
    }
    return response;
  }

  Widget _buildReplyToMessage() {
    if (!_hasQuotedMessage) return const Offstage();
    final quotedMessage = _effectiveController.message.quotedMessage!;

    final quotedMessageBuilder = widget.quotedMessageBuilder;
    if (quotedMessageBuilder != null) {
      return quotedMessageBuilder(
        context,
        _effectiveController.message.quotedMessage!,
      );
    }

    final containsUrl = quotedMessage.attachments.any((it) {
      return it.type == AttachmentType.urlPreview;
    });

    return StreamQuotedMessageWidget(
      reverse: true,
      showBorder: !containsUrl,
      message: quotedMessage,
      messageTheme: _streamChatTheme.otherMessageTheme,
      onQuotedMessageClear: widget.onQuotedMessageCleared,
      attachmentThumbnailBuilders:
          widget.quotedMessageAttachmentThumbnailBuilders,
    );
  }

  Widget _buildAttachments() {
    final attachments = _effectiveController.attachments;
    final nonOGAttachments = attachments.where((it) {
      return it.titleLink == null;
    }).toList(growable: false);

    // If there are no attachments, return an empty widget
    if (nonOGAttachments.isEmpty) return const Offstage();

    // If the user has provided a custom attachment list builder, use that.
    final attachmentListBuilder = widget.attachmentListBuilder;
    if (attachmentListBuilder != null) {
      return attachmentListBuilder(
        context,
        nonOGAttachments,
        _onAttachmentRemovePressed,
      );
    }

    // Otherwise, use the default attachment list builder.
    return LimitedBox(
      maxHeight: 240,
      child: StreamMessageInputAttachmentList(
        attachments: nonOGAttachments,
        onRemovePressed: _onAttachmentRemovePressed,
        fileAttachmentListBuilder: widget.fileAttachmentListBuilder,
        mediaAttachmentListBuilder: widget.mediaAttachmentListBuilder,
        fileAttachmentBuilder: widget.fileAttachmentBuilder,
        mediaAttachmentBuilder: widget.mediaAttachmentBuilder,
      ),
    );
  }

  // Default callback for removing an attachment.
  Future<void> defaultOnAttachmentRemovePressed(Attachment attachment) async {
    final file = attachment.file;
    final uploadState = attachment.uploadState;

    if (file != null && !uploadState.isSuccess && !isWeb) {
      await StreamAttachmentHandler.instance.deleteAttachmentFile(
        attachmentFile: file,
      );
    }

    _effectiveController.removeAttachmentById(attachment.id);
  }

  Widget _buildCommandButton(BuildContext context) {
    final s = _effectiveController.text.trim();
    final isCommandOptionsVisible = s.startsWith(_kCommandTrigger);
    final defaultButton = CommandButton(
      color: s.isNotEmpty
          ? _streamChatTheme.colorTheme.disabled
          : (isCommandOptionsVisible
              ? _messageInputTheme.actionButtonColor!
              : _messageInputTheme.actionButtonIdleColor!),
      onPressed: () async {
        // Clear the text if the commands options are already visible.
        if (isCommandOptionsVisible) {
          _effectiveController.clear();
          _effectiveFocusNode.unfocus();
        } else {
          // This triggers the [StreamAutocomplete] to show the command trigger.
          _effectiveController.textEditingValue = const TextEditingValue(
            text: _kCommandTrigger,
            selection: TextSelection.collapsed(offset: _kCommandTrigger.length),
          );
          _effectiveFocusNode.requestFocus();
        }
      },
    );

    return widget.commandButtonBuilder?.call(context, defaultButton) ??
        defaultButton;
  }

  /// Adds an attachment to the [messageInputController.attachments] map
  void _addAttachments(Iterable<Attachment> attachments) {
    final limit = widget.attachmentLimit;
    final length = _effectiveController.attachments.length + attachments.length;
    if (length > limit) {
      final onAttachmentLimitExceed = widget.onAttachmentLimitExceed;
      if (onAttachmentLimitExceed != null) {
        return onAttachmentLimitExceed(
          widget.attachmentLimit,
          context.translations.attachmentLimitExceedError(limit),
        );
      }
      return _showErrorAlert(
        context.translations.attachmentLimitExceedError(limit),
      );
    }
    for (final attachment in attachments) {
      _effectiveController.addAttachment(attachment);
    }
  }

  /// Sends the current message
  Future<void> sendMessage() async {
    if (_timeOut > 0) {
      return;
    }

    final streamChannel = StreamChannel.of(context);
    final channel = streamChannel.channel;
    var message = _effectiveController.value;

    if (!channel.ownCapabilities.contains(PermissionType.sendLinks) &&
        _urlRegex.allMatches(message.text ?? '').any((element) =>
            element.group(0)?.split('.').last.isValidTLD() == true)) {
      showInfoBottomSheet(
        context,
        icon: StreamSvgIcon.error(
          color: StreamChatTheme.of(context).colorTheme.accentError,
          size: 24,
        ),
        title: 'Links are disabled',
        details: 'Sending links is not allowed in this conversation.',
        okText: context.translations.okLabel,
      );
      return;
    }

    final containsCommand = message.command != null || message.extraData['customCommand'] != null;
    // If the message contains command we should prepend it to the text before sending it.
    if (containsCommand) {
      widget.containsCommandFunction != null ? 
          message = await widget.containsCommandFunction!(message) : 
          message = message.copyWith(text: '/${message.command} ${message.text}');
    }

    var shouldKeepFocus = widget.shouldKeepFocusAfterMessage;
    shouldKeepFocus ??= !_commandEnabled;

    widget.onQuotedMessageCleared?.call();

    _effectiveController.reset();

    if (widget.preMessageSending != null) {
      message = await widget.preMessageSending!(message);
    }

    // adding check here for upload file permssion. Since the new chat page does
    // not create the new channel until the preMessageSending is called, file
    // uploads will always be disabled on that screen. Instead, we can check the
    // permissions here.
    if (!channel.ownCapabilities.contains(PermissionType.uploadFile) && 
      message.attachments.isNotEmpty) {
      showInfoBottomSheet(
        context,
        icon: StreamSvgIcon.error(
          color: StreamChatTheme.of(context).colorTheme.accentError,
          size: 24,
        ),
        title: 'Attachments are disabled',
        details: 'Uploading attachments is not allowed in this conversation.',
        okText: context.translations.okLabel,
      );
      return;
    }

    message = message.replaceMentionsWithId();

    // If the channel is not up to date, we should reload it before sending
    // the message.
    if (!channel.state!.isUpToDate) {
      await streamChannel.reloadChannel();

      // We need to wait for the frame to be rendered with the updated channel
      // state before sending the message.
      await WidgetsBinding.instance.endOfFrame;
    }

    await _sendOrUpdateMessage(message: message);

    if (mounted) {
      if (shouldKeepFocus) {
        FocusScope.of(context).requestFocus(_effectiveFocusNode);
      } else {
        FocusScope.of(context).unfocus();
      }
    }
  }

  Future<void> _sendOrUpdateMessage({
    required Message message,
  }) async {
    final channel = StreamChannel.of(context).channel;

    try {
      Future sendingFuture;
      if (_isEditing) {
        sendingFuture = channel.updateMessage(message);
      } else {
        sendingFuture = channel.sendMessage(message);
      }

      final resp = await sendingFuture;
      if (resp.message?.isError ?? false) {
        _effectiveController.message = message;
      }
      _startSlowMode();
      widget.onMessageSentAsync?.call(context, resp.message);
      widget.onMessageSent?.call(context, resp.message);
    } catch (e, stk) {
      if (widget.onError != null) {
        return widget.onError?.call(e, stk);
      }

      rethrow;
    }
  }

  void _showErrorAlert(String description) {
    showModalBottomSheet(
      backgroundColor: _streamChatTheme.colorTheme.barsBg,
      context: context,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(16),
          topRight: Radius.circular(16),
        ),
      ),
      builder: (context) => ErrorAlertSheet(
        errorDescription: context.translations.somethingWentWrongError,
      ),
    );
  }

  @override
  void dispose() {
    _currentValidation?.cancel();
    _effectiveController
      ..removeListener(_onChangedDebounced)
      ..removeListener(_updateValidationState);
    _controller?.dispose();
    _effectiveFocusNode.removeListener(_focusNodeListener);
    _focusNode?.dispose();
    _stopSlowMode();
    _onChangedDebounced.cancel();
    WidgetsBinding.instance.removeObserver(this);
    validationNotifier.dispose();
    super.dispose();
  }
}

/// Preview of an Open Graph attachment.
class OGAttachmentPreview extends StatelessWidget {
  /// Returns a new instance of [OGAttachmentPreview]
  const OGAttachmentPreview({
    super.key,
    required this.attachment,
    this.onDismissPreviewPressed,
  });

  /// The attachment to be rendered.
  final Attachment attachment;

  /// Called when the dismiss button is pressed.
  final VoidCallback? onDismissPreviewPressed;

  @override
  Widget build(BuildContext context) {
    final chatTheme = StreamChatTheme.of(context);
    final textTheme = chatTheme.textTheme;
    final colorTheme = chatTheme.colorTheme;

    final attachmentTitle = attachment.title;
    final attachmentText = attachment.text;

    return Row(
      children: [
        Padding(
          padding: const EdgeInsets.all(8),
          child: Icon(
            Icons.link,
            color: colorTheme.accentPrimary,
          ),
        ),
        Expanded(
          child: Container(
            decoration: BoxDecoration(
              border: Border(
                left: BorderSide(
                  color: colorTheme.accentPrimary,
                  width: 2,
                ),
              ),
            ),
            padding: const EdgeInsets.only(left: 6),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                if (attachmentTitle != null)
                  Text(
                    attachmentTitle.trim(),
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.body.copyWith(fontWeight: FontWeight.w700),
                  ),
                if (attachmentText != null)
                  Text(
                    attachmentText,
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: textTheme.body.copyWith(fontWeight: FontWeight.w400),
                  ),
              ],
            ),
          ),
        ),
        IconButton(
          visualDensity: VisualDensity.compact,
          icon: StreamSvgIcon.closeSmall(),
          onPressed: onDismissPreviewPressed,
        ),
      ],
    );
  }
}
