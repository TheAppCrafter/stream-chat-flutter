import 'dart:async';
import 'dart:io';

import 'package:chewie/chewie.dart';
import 'package:flutter/material.dart';
import 'package:photo_view/photo_view.dart';
import 'package:stream_chat_flutter/src/fullscreen_media/full_screen_media_widget.dart';
import 'package:stream_chat_flutter/src/fullscreen_media/gallery_navigation_item.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'package:video_player/video_player.dart';

/// A full screen image widget
class StreamFullScreenMedia extends FullScreenMediaWidget {
  /// Instantiate a new FullScreenImage
  const StreamFullScreenMedia({
    super.key,
    required this.mediaAttachmentPackages,
    this.startIndex = 0,
    this.userName = '',
    this.onShowMessage,
    this.onReplyMessage,
    this.attachmentActionsModalBuilder,
    this.autoplayVideos = false,
    this.audioAttachmentWidget,
  }) : assert(startIndex >= 0, 'startIndex cannot be negative');

  /// The url of the image
  final List<StreamAttachmentPackage> mediaAttachmentPackages;

  /// First index of media shown
  final int startIndex;

  /// Username of sender
  final String userName;

  /// Callback for when show message is tapped
  final ShowMessageCallback? onShowMessage;

  /// Callback for when reply message is tapped
  final ReplyMessageCallback? onReplyMessage;

  /// Widget builder for attachment actions modal
  /// [defaultActionsModal] is the default [AttachmentActionsModal] config
  /// Use [defaultActionsModal.copyWith] to easily customize it
  final AttachmentActionsBuilder? attachmentActionsModalBuilder;

  /// Auto-play videos when page is opened
  final bool autoplayVideos;

  /// Widget for audio attachment
  final Widget? audioAttachmentWidget;

  @override
  _FullScreenMediaState createState() => _FullScreenMediaState();
}

class _FullScreenMediaState extends State<StreamFullScreenMedia> {
  late final PageController _pageController;

  late final _currentPage = ValueNotifier(widget.startIndex);
  late final _isDisplayingDetail = ValueNotifier<bool>(true);

  void switchDisplayingDetail() {
    _isDisplayingDetail.value = !_isDisplayingDetail.value;
  }

  final videoPackages = <String, VideoPackage>{};

  @override
  void initState() {
    super.initState();
    _pageController = PageController(initialPage: widget.startIndex);
    for (var i = 0; i < widget.mediaAttachmentPackages.length; i++) {
      final attachment = widget.mediaAttachmentPackages[i].attachment;
      if (attachment.type != AttachmentType.video) continue;
      final package = VideoPackage(attachment, showControls: true);
      videoPackages[attachment.id] = package;
    }
    initializePlayers();
  }

  Future<void> initializePlayers() async {
    if (videoPackages.isEmpty) {
      return;
    }

    final currentAttachment =
        widget.mediaAttachmentPackages[widget.startIndex].attachment;

    await Future.wait(videoPackages.values.map(
      (it) => it.initialize(),
    ));

    if (widget.autoplayVideos &&
        currentAttachment.type == AttachmentType.video) {
      final package = videoPackages.values
          .firstWhere((e) => e._attachment == currentAttachment);
      package._chewieController?.play();
    }
    setState(() {}); // ignore: no-empty-block
  }

  @override
  void dispose() {
    _currentPage.dispose();
    _pageController.dispose();
    _isDisplayingDetail.dispose();
    for (final package in videoPackages.values) {
      package.dispose();
    }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      resizeToAvoidBottomInset: false,
      body: ValueListenableBuilder<int>(
        valueListenable: _currentPage,
        builder: (context, currentPage, child) {
          final _currentAttachmentPackage =
              widget.mediaAttachmentPackages[currentPage];
          final _currentMessage = _currentAttachmentPackage.message;
          final _currentAttachment = _currentAttachmentPackage.attachment;
          // added _currentChannel and stream channel widget to satisfy child widget requirements while still allowing for attachments from multiple channels
          final _currentChannel = _currentAttachmentPackage.channel;
          return Stack(
              children: [
                child!,
                ValueListenableBuilder<bool>(
                  valueListenable: _isDisplayingDetail,
                  builder: (context, isDisplayingDetail, child) {
                    final mediaQuery = MediaQuery.of(context);
                    final topPadding = mediaQuery.padding.top;
                    return AnimatedPositionedDirectional(
                      duration: kThemeAnimationDuration,
                      curve: Curves.easeInOut,
                      top:
                          isDisplayingDetail ? 0 : -(topPadding + kToolbarHeight),
                      start: 0,
                      end: 0,
                      height: topPadding + kToolbarHeight,
                      child: StreamGalleryHeader(
                        channel: _currentChannel,
                        userName: widget.userName,
                        sentAt: _currentAttachmentPackage.message != null ? context.translations.sentAtText(
                          date: _currentAttachmentPackage.message!.createdAt,
                          time: _currentAttachmentPackage.message!.createdAt,
                        ) : '',
                        onBackPressed: Navigator.of(context).pop,
                        message: _currentMessage,
                        attachment: _currentAttachment,
                        onShowMessage: _currentMessage != null && _currentChannel != null && widget.onShowMessage != null
                            ? () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                                widget.onShowMessage?.call(
                                  _currentMessage,
                                  _currentChannel,
                                );
                              }
                            : null,
                        onReplyMessage: _currentMessage != null && widget.onReplyMessage != null
                            ? () {
                                Navigator.pop(context);
                                Navigator.pop(context);
                                widget.onReplyMessage?.call(
                                  _currentMessage,
                                );
                              }
                            : null,
                        attachmentActionsModalBuilder:
                            widget.attachmentActionsModalBuilder,
                      ),
                    );
                  },
                ),
                if (_currentMessage?.isEphemeral == false)
                  ValueListenableBuilder<bool>(
                    valueListenable: _isDisplayingDetail,
                    builder: (context, isDisplayingDetail, child) {
                      final mediaQuery = MediaQuery.of(context);
                      final bottomPadding = mediaQuery.padding.bottom;
                      return AnimatedPositionedDirectional(
                        duration: kThemeAnimationDuration,
                        curve: Curves.easeInOut,
                        bottom: isDisplayingDetail
                            ? 0
                            : -(bottomPadding + kToolbarHeight),
                        start: 0,
                        end: 0,
                        height: bottomPadding + kToolbarHeight,
                        child: StreamGalleryFooter(
                          currentPage: currentPage,
                          totalPages: widget.mediaAttachmentPackages.length,
                          mediaAttachmentPackages: widget.mediaAttachmentPackages,
                          mediaSelectedCallBack: (val) {
                            _currentPage.value = val;
                            _pageController.animateToPage(
                              val,
                              duration: const Duration(milliseconds: 300),
                              curve: Curves.easeInOut,
                            );
                            Navigator.pop(context);
                          },
                        ),
                      );
                    },
                  ),
                if (widget.mediaAttachmentPackages.length > 1) ...[
                  if (currentPage > 0)
                    GalleryNavigationItem(
                      left: 8,
                      opacityAnimation: _isDisplayingDetail,
                      icon: const Icon(Icons.chevron_left_rounded),
                      onPressed: () {
                        _currentPage.value--;
                        _pageController.previousPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                  if (currentPage < widget.mediaAttachmentPackages.length - 1)
                    GalleryNavigationItem(
                      right: 8,
                      opacityAnimation: _isDisplayingDetail,
                      icon: const Icon(Icons.chevron_right_rounded),
                      onPressed: () {
                        _currentPage.value++;
                        _pageController.nextPage(
                          duration: const Duration(milliseconds: 300),
                          curve: Curves.easeInOut,
                        );
                      },
                    ),
                ],
              ],
            );
        },
        child: InkWell(
          onTap: switchDisplayingDetail,
          child: KeyboardShortcutRunner(
            onEscapeKeypress: Navigator.of(context).pop,
            onLeftArrowKeypress: () {
              if (_currentPage.value > 0) {
                _currentPage.value--;
                _pageController.previousPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            onRightArrowKeypress: () {
              if (_currentPage.value <
                  widget.mediaAttachmentPackages.length - 1) {
                _currentPage.value++;
                _pageController.nextPage(
                  duration: const Duration(milliseconds: 300),
                  curve: Curves.easeInOut,
                );
              }
            },
            child: PageView.builder(
              controller: _pageController,
              itemCount: widget.mediaAttachmentPackages.length,
              onPageChanged: (val) {
                _currentPage.value = val;
                if (videoPackages.isEmpty) return;
                final currentAttachment =
                    widget.mediaAttachmentPackages[val].attachment;
                for (final e in videoPackages.values) {
                  if (e._attachment != currentAttachment) {
                    e._chewieController?.pause();
                  }
                }
                if (widget.autoplayVideos &&
                    currentAttachment.type == AttachmentType.video) {
                  final controller = videoPackages[currentAttachment.id]!;
                  controller._chewieController?.play();
                }
              },
              itemBuilder: (context, index) {
                final currentAttachmentPackage =
                    widget.mediaAttachmentPackages[index];
                final attachment = currentAttachmentPackage.attachment;
                final showAttachmentName = 
                    currentAttachmentPackage.showAttachmentName;
                return ValueListenableBuilder(
                  valueListenable: _isDisplayingDetail,
                  builder: (context, isDisplayingDetail, child) {
                    return AnimatedContainer(
                      duration: kThemeChangeDuration,
                      color: isDisplayingDetail
                          ? StreamChannelHeaderTheme.of(context).color
                          : Colors.black,
                      child: Builder(
                        builder: (context) {
                          Widget topWidget;

                          if (attachment.type == AttachmentType.image || attachment.type == AttachmentType.giphy) {
                            topWidget = PhotoView.customChild(
                              maxScale: PhotoViewComputedScale.covered,
                              minScale: PhotoViewComputedScale.contained,
                              initialScale: PhotoViewComputedScale.contained,
                              backgroundDecoration: const BoxDecoration(
                                color: Colors.transparent,
                              ),
                              child: SizedBox.expand(
                                child: StreamMediaAttachmentThumbnail(
                                  media: attachment,
                                  width: double.infinity,
                                  height: double.infinity,
                                  fit: BoxFit.contain,
                                ),
                              ),
                            );
                          } else if (attachment.type == AttachmentType.video) {
                            final controller = videoPackages[attachment.id]!;
                            if (!controller.initialized) {
                              topWidget = const Center(
                                child: CircularProgressIndicator.adaptive(),
                              );
                            } else {
                              final mediaQuery = MediaQuery.of(context);
                              final bottomPadding = mediaQuery.padding.bottom;

                              topWidget = AnimatedPadding(
                                duration: kThemeChangeDuration,
                                padding: EdgeInsets.symmetric(
                                  vertical: isDisplayingDetail
                                      ? kToolbarHeight + bottomPadding
                                      : 0,
                                ),
                                child: Center(
                                  child: AspectRatio(
                                    aspectRatio: controller.videoPlayer.value.aspectRatio,
                                    child: Chewie(
                                      controller: controller.chewieController!,
                                    ),
                                  ),
                                ),
                              );
                            }
                          } else if (attachment.type == AttachmentType.file) {
                            final mediaType = attachment.title?.mediaType;
                            topWidget = Container(
                              width: double.infinity,
                              height: double.infinity,
                              margin: const EdgeInsets.all(50),
                              child: getFileTypeImage(mediaType?.mimeType),
                            );
                          } 
                          else if (attachment.type == AttachmentType.audio){
                            return widget.audioAttachmentWidget ?? const SizedBox.shrink();
                          }
                          else {
                            topWidget = const SizedBox.shrink(); // Default case
                          }

                          return Stack(
                            children: [
                              Positioned.fill(
                                child: Center(child: topWidget),
                              ),
                              if (showAttachmentName)
                                Positioned(
                                  left: 30,
                                  right: 30,
                                  bottom: isDisplayingDetail ? (kToolbarHeight + 
                                    MediaQuery.of(context).padding.bottom + 10) : 10,
                                  child: Text(
                                    attachment.title ?? 'Unnamed Attachment',
                                    maxLines: 2,
                                    overflow: TextOverflow.ellipsis,
                                    style: Theme.of(context).textTheme.bodyLarge,
                                    textAlign: TextAlign.center,
                                  ),
                                ),
                            ],
                          );
                        },
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ),
      ),
    );
  }
}

/// Class for packaging up things required for videos
class VideoPackage {
  /// Constructor for creating [VideoPackage]
  VideoPackage(
    this._attachment, {
    bool showControls = false,
    bool autoInitialize = true,
  })  : _showControls = showControls,
        _autoInitialize = autoInitialize,
        _videoPlayerController = _attachment.localUri != null
            ? VideoPlayerController.file(
                File.fromUri(_attachment.localUri!),
              )
            : VideoPlayerController.networkUrl(
                Uri.parse(_attachment.assetUrl!),
              );

  final Attachment _attachment;
  final bool _showControls;
  final bool _autoInitialize;
  final VideoPlayerController _videoPlayerController;
  ChewieController? _chewieController;

  /// Get video player for video
  VideoPlayerController get videoPlayer => _videoPlayerController;

  /// Get [ChewieController] for video
  ChewieController? get chewieController => _chewieController;

  /// Check if controller is initialised
  bool get initialized => _videoPlayerController.value.isInitialized;

  /// Initialize all things required for [VideoPackage]
  Future<void> initialize() {
    return _videoPlayerController.initialize().then((_) {
      _chewieController = ChewieController(
        videoPlayerController: _videoPlayerController,
        autoInitialize: _autoInitialize,
        showControls: _showControls,
        showOptions: false,
        aspectRatio: _videoPlayerController.value.aspectRatio,
      );
    });
  }

  /// Add a listener to video player controller
  void addListener(VoidCallback listener) =>
      _videoPlayerController.addListener(listener);

  /// Remove a listener to video player controller
  void removeListener(VoidCallback listener) =>
      _videoPlayerController.removeListener(listener);

  /// Dispose controllers
  Future<void> dispose() {
    _chewieController?.dispose();
    return _videoPlayerController.dispose();
  }
}