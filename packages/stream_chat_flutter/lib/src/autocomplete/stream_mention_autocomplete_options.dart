import 'package:flutter/material.dart';
import 'package:stream_chat_flutter/stream_chat_flutter.dart';
import 'dart:async';

/// {@template user_mentions_overlay}
/// Overlay for displaying users that can be mentioned.
/// {@endtemplate}
class StreamMentionAutocompleteOptions extends StatefulWidget {
  /// Constructor for creating a [StreamMentionAutocompleteOptions].
  StreamMentionAutocompleteOptions({
    super.key,
    this.autoCompleteExtraUsersFunction,
    required this.query,
    required this.channel,
    this.mentionedUsers = const [],
    this.client,
    this.limit = 10,
    this.mentionAllAppUsers = false,
    this.mentionsTileBuilder,
    this.onMentionUserTap,
  })  : assert(
          channel.state != null,
          'Channel ${channel.cid} is not yet initialized',
        ),
        assert(
          !mentionAllAppUsers || (mentionAllAppUsers && client != null),
          'StreamChatClient is required in order to use mentionAllAppUsers',
        );

  /// Query for searching users.
  final String query;

  /// Function to add extra users to autocomplete.
  final Future<List<User>> Function(String)? autoCompleteExtraUsersFunction;

  /// Limit applied on user search results.
  final int limit;

  /// The channel to search for users.
  final Channel channel;

  /// The users that have already been mentioned in the message.
  final List<User> mentionedUsers;

  /// The client to search for users in case [mentionAllAppUsers] is True.
  final StreamChatClient? client;

  /// When enabled mentions search users across the entire app.
  ///
  /// Defaults to false.
  final bool mentionAllAppUsers;

  /// Customize the tile for the mentions overlay.
  final UserMentionTileBuilder? mentionsTileBuilder;

  /// Callback called when a user is selected.
  final void Function(BuildContext, User)? onMentionUserTap;

  @override
  _StreamMentionAutocompleteOptionsState createState() =>
      _StreamMentionAutocompleteOptionsState();
}

class _StreamMentionAutocompleteOptionsState
    extends State<StreamMentionAutocompleteOptions> {
  late Future<List<User>> userMentionsFuture;
  late Future<List<User>> extraUsersFuture;
  Timer? _debounce;

  @override
  void initState() {
    super.initState();
    userMentionsFuture = queryMentions(widget.query);
    extraUsersFuture = widget.autoCompleteExtraUsersFunction?.call(widget.query) ?? Future.value([]);
  }

  @override
  void dispose() {
    _debounce?.cancel();
    super.dispose();
  }

  void _debouncedQuery() {
    _debounce?.cancel();
    _debounce = Timer(const Duration(milliseconds: 0), () {
      if (mounted) {
        setState(() {
          userMentionsFuture = queryMentions(widget.query);
          extraUsersFuture = widget.autoCompleteExtraUsersFunction?.call(widget.query) ?? Future.value([]);
        });
      }
    });
  }

  @override
  void didUpdateWidget(covariant StreamMentionAutocompleteOptions oldWidget) {
    super.didUpdateWidget(oldWidget);
    
    // Immediately update for non-query changes
    if (widget.channel != oldWidget.channel ||
        widget.mentionAllAppUsers != oldWidget.mentionAllAppUsers ||
        widget.limit != oldWidget.limit) {
      userMentionsFuture = queryMentions(widget.query);
      extraUsersFuture = widget.autoCompleteExtraUsersFunction?.call(widget.query) ?? Future.value([]);
    }
    
    // Debounce query changes
    if (widget.query != oldWidget.query) {
      _debouncedQuery();
    }
  }

  @override
  Widget build(BuildContext context) {
    final futureBuilder = FutureBuilder<List<List<User>>>(
      future: Future.wait([userMentionsFuture, extraUsersFuture]),
      builder: (context, snapshot) {
        if (snapshot.hasError) return const SizedBox.shrink();
        if (!snapshot.hasData) return const SizedBox.shrink();
        final userList = snapshot.data!;
        final List<User> users = snapshot.data![0] as List<User>;
        final List<User> extraUsers = snapshot.data![1] as List<User>;
        final List<User> allUsers = [...users, ...extraUsers];
        final Set<User> usersSet = Set.from(allUsers)..removeAll(widget.mentionedUsers);

        final autocompleteOptions = StreamAutocompleteOptions<User>(
          options: usersSet.toList(),
          optionBuilder: (context, user) {
            final colorTheme = StreamChatTheme.of(context).colorTheme;
            return Material(
              color: colorTheme.barsBg,
              child: InkWell(
                onTap: widget.onMentionUserTap == null
                    ? null
                    : () => widget.onMentionUserTap!(context, user),
                child: widget.mentionsTileBuilder?.call(context, user) ??
                    StreamUserMentionTile(user),
              ),
            );
          },
        );
        return autocompleteOptions;
      },
    );
    return futureBuilder;
  }

  List<User> get membersAndWatchers {
    final state = widget.channel.state!;
    return {
      ...state.watchers,
      ...state.members.map((it) => it.user),
    }.whereType<User>().toList(growable: false);
  }

  Future<List<User>> queryMentions(String query) async {
    if (widget.mentionAllAppUsers) {
      return _queryUsers(query);
    }

    var channelState = widget.channel.state;

    channelState = channelState!;
    final members = channelState.members;

    // By default, we return maximum 100 members via queryChannels api call.
    // Thus it is safe to assume, that if number of members in channel.state
    // is < 100, then all the members are already available on client side
    // and we don't need to make any api call to queryMembers endpoint.
    if (members.length < 100) {
      final matchingUsers = membersAndWatchers.search(query);
      return matchingUsers.toList(growable: false);
    }

    final result = await _queryMembers(query);
    return result
        .map((it) => it.user)
        .whereType<User>()
        .toList(growable: false);
  }

  Future<List<Member>> _queryMembers(String query) async {
    final response = await widget.channel.queryMembers(
      pagination: PaginationParams(limit: widget.limit),
      filter: query.isEmpty
          ? const Filter.empty()
          : Filter.autoComplete('name', query),
    );
    return response.members;
  }

  Future<List<User>> _queryUsers(String query) async {
    assert(
      widget.client != null,
      'StreamChatClient is required in order to query all app users',
    );
    final response = await widget.client!.queryUsers(
      pagination: PaginationParams(limit: widget.limit),
      filter: query.isEmpty
          ? const Filter.empty()
          : Filter.or([
                Filter.autoComplete('id', query),
                Filter.autoComplete('name', query),
              ]),
      sort: [const SortOption('id', direction: SortOption.ASC)],
    );
    return response.users;
  }
}
