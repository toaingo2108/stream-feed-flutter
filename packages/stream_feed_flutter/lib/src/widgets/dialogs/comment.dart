import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:stream_feed_flutter/src/utils/typedefs.dart';
import 'package:stream_feed_flutter/src/widgets/activity/activity.dart';
import 'package:stream_feed_flutter/src/widgets/comment/button.dart';
import 'package:stream_feed_flutter/src/widgets/comment/field.dart';
import 'package:stream_feed_flutter/src/widgets/comment/item.dart';
import 'package:stream_feed_flutter/src/widgets/dialogs/dialogs.dart';
import 'package:stream_feed_flutter/src/widgets/pages/reaction_list_view.dart';
import 'package:stream_feed_flutter_core/stream_feed_flutter_core.dart';

/// {@template alert_dialog}
/// An Alert Dialog that displays an activity and a comment field.
/// {@endtemplate}
class AlertDialogComment extends StatelessWidget {
  /// Builds an [AlertDialogComment].
  const AlertDialogComment({
    Key? key,
    required this.feedGroup,
    required this.foreignId,
    this.activity,
    this.handleJsonKey = 'handle',
    this.nameJsonKey = 'name',
  }) : super(key: key);

  /// The feed group/slug that is being commented on.
  final String feedGroup;

  /// The activity that is being commented on.
  final EnrichedActivity? activity;

  final String handleJsonKey;

  final String nameJsonKey;

  final String foreignId;

  @override
  Widget build(BuildContext context) {
    final textEditingController = TextEditingController();
    return AlertDialog(
      actions: [
        AlertDialogActions(
          activity: activity,
          feedGroup: feedGroup,
          textEditingController: textEditingController,
          foreignId: foreignId,
        ),
      ],
      content: CommentView(
        activity: activity,
        feedGroup: feedGroup,
        textEditingController: textEditingController,
        nameJsonKey: nameJsonKey,
        handleJsonKey: handleJsonKey,
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(StringProperty('feedGroup', feedGroup));
    properties
        .add(DiagnosticsProperty<EnrichedActivity?>('activity', activity));
    properties.add(StringProperty('handleJsonKey', handleJsonKey));
    properties.add(StringProperty('nameJsonKey', nameJsonKey));
    properties.add(StringProperty('foreignId', foreignId));
  }
}

/// {@template comment_view}
/// A Comment View is a widget that shows the activity and a comment field and
/// reactions (if enabled).
/// {@endtemplate}
class CommentView extends StatelessWidget {
  //TODO: merge this with StreamFeedActivity
  /// Builds a [CommentView].
  const CommentView({
    Key? key,
    required this.textEditingController,
    this.activity,
    this.feedGroup = 'user',
    this.onReactionTap,
    this.onHashtagTap,
    this.onMentionTap,
    this.onUserTap,
    this.enableReactions = false,
    this.enableCommentFieldButton = false,
    this.handleJsonKey = 'handle',
    this.nameJsonKey = 'name',
    this.foreignId = 'foreign_id',
  }) : super(key: key);

  final EnrichedActivity? activity;

  final String feedGroup;

  final TextEditingController textEditingController;

  final bool enableReactions;

  /// {@macro reaction_callback}
  final OnReactionTap? onReactionTap;

  /// {@macro hashtag_callback}
  final OnHashtagTap? onHashtagTap;

  /// {@macro mention_callback}
  final OnMentionTap? onMentionTap;

  /// {@macro user_callback}
  final OnUserTap? onUserTap;

  final bool enableCommentFieldButton;

  final String handleJsonKey;

  final String nameJsonKey;

  final String foreignId;

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Expanded(
          child: SingleChildScrollView(
            child: Column(
              children: [
                //TODO(sacha): "this post has been deleted by the author"
                if (activity != null) ...[
                  StreamBuilder(
                    stream: FeedProvider.of(context)
                        .bloc
                        .getActivitiesStream(feedGroup),
                    builder: (BuildContext context,
                        AsyncSnapshot<dynamic> snapshot) {
                      return ActivityWidget(
                        activity: activity!,
                        feedGroup: feedGroup,
                        nameJsonKey: nameJsonKey,
                        handleJsonKey: handleJsonKey,
                      );
                    },
                  )
                  //TODO(sacha): analytics
                  //TODO(sacha): "in response to" activity.to
                ],
                //TODO: builder for using it elsewhere than in actions
                if (enableReactions && activity != null)
                  ReactionListView(
                    activity: activity!,
                    onReactionTap: onReactionTap,
                    onHashtagTap: onHashtagTap,
                    onMentionTap: onMentionTap,
                    onUserTap: onUserTap,
                    kind: 'comment',
                    flags: EnrichmentFlags()
                        .withReactionCounts()
                        .withOwnChildren()
                        .withOwnReactions(), //TODO: refactor this?
                    reactionBuilder: (context, reaction) => CommentItem(
                      nameJsonKey: nameJsonKey,
                      activity: activity!,
                      user: reaction.user,
                      reaction: reaction,
                      onReactionTap: onReactionTap,
                      onHashtagTap: onHashtagTap,
                      onMentionTap: onMentionTap,
                      onUserTap: onUserTap,
                    ),
                  )
              ],
            ),
          ),
        ),
        SafeArea(
          child: CommentField(
            textEditingController: textEditingController,
            activity: activity,

            //enabled in actions [RightActions]
            enableButton: enableCommentFieldButton,
            feedGroup: feedGroup,
            foreignId: foreignId,
          ),
        ),
      ],
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties
        .add(DiagnosticsProperty<EnrichedActivity?>('activity', activity));
    properties.add(StringProperty('feedGroup', feedGroup));
    properties.add(DiagnosticsProperty<TextEditingController>(
        'textEditingController', textEditingController));
    properties
        .add(DiagnosticsProperty<bool>('enableReactions', enableReactions));
    properties.add(
        ObjectFlagProperty<OnReactionTap?>.has('onReactionTap', onReactionTap));
    properties.add(
        ObjectFlagProperty<OnHashtagTap?>.has('onHashtagTap', onHashtagTap));
    properties.add(
        ObjectFlagProperty<OnMentionTap?>.has('onMentionTap', onMentionTap));
    properties.add(ObjectFlagProperty<OnUserTap?>.has('onUserTap', onUserTap));
    properties.add(DiagnosticsProperty<bool>(
        'enableCommentFieldButton', enableCommentFieldButton));
    properties.add(StringProperty('handleJsonKey', handleJsonKey));
    properties.add(StringProperty('nameJsonKey', nameJsonKey));
    properties.add(StringProperty('foreignId', foreignId));
  }
}

/// {@template alert_dialog_actions}
/// The Actions displayed in the dialog i.e. medias, gif, emojis etc.
/// {@endtemplate}
class AlertDialogActions extends StatelessWidget {
  /// Builds an [AlertDialogActions].
  const AlertDialogActions({
    Key? key,
    this.activity,
    this.targetFeeds,
    required this.feedGroup,
    required this.textEditingController,
    required this.foreignId,
  }) : super(key: key);

  final EnrichedActivity? activity;

  final List<FeedId>? targetFeeds;
  final String feedGroup;
  final String foreignId;

  final TextEditingController textEditingController;

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.bottomLeft,
      child: Stack(
        children: [
          const LeftActions(), //TODO: upload controller thingy
          RightActions(
            textEditingController: textEditingController,
            activity: activity, //TODO: upload controller thingy
            targetFeeds: targetFeeds,
            feedGroup: feedGroup,
            foreignId: foreignId,
          ),
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
        DiagnosticsProperty<GenericEnrichedActivity?>('activity', activity));
    properties.add(IterableProperty<FeedId>('targetFeeds', targetFeeds));
    properties.add(StringProperty('feedGroup', feedGroup));
    properties.add(DiagnosticsProperty<TextEditingController>(
        'textEditingController', textEditingController));
    properties.add(StringProperty('foreignId', foreignId));
  }
}

/// {@template left_actions}
/// Actions on the left side of the dialog i.e. medias, gif, emojis etc.
/// {@endtemplate}
class LeftActions extends StatelessWidget {
  /// Builds a [LeftActions].
  const LeftActions({
    Key? key,
    this.spaceBefore = 60,
    this.spaceBetween = 8.0,
  }) : super(key: key);

  final double spaceBefore;

  //useful for reddit style clone
  final double spaceBetween;

  @override
  Widget build(BuildContext context) {
    return Positioned(
      left: spaceBefore, //TODO: compute this based on media query size
      child: Row(
        children: [
          //TODO: actual emojis, upload images, gif, etc
          const MediasAction(), //TODO: push an other dialog open file explorer take file uri upload it using sdk and it to attachments (sent in RightActions/PostCommentButton)
          SizedBox(width: spaceBetween),
          const EmojisAction(), //TODO: push an other dialog and display a nice grid of emojis, add selected emoji to text controller
          SizedBox(width: spaceBetween),
          const GIFAction(), //TODO: push an other dialog and display gif in a card and it to list of attachments
        ],
      ),
    );
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(DoubleProperty('spaceBefore', spaceBefore));
    properties.add(DoubleProperty('spaceBetween', spaceBetween));
  }
}

/// {@template right_actions}
/// Actions on the right side of the dialog i.e. "Post" button.
/// {@endtemplate}
class RightActions extends StatelessWidget {
  /// Builds a [RighActions].
  const RightActions({
    Key? key,
    required this.textEditingController,
    this.activity,
    required this.feedGroup,
    required this.foreignId,
    this.targetFeeds,
  }) : super(key: key);

  final EnrichedActivity? activity;

  final TextEditingController textEditingController;

  final String feedGroup;

  final List<FeedId>? targetFeeds;

  final String foreignId;

  @override
  Widget build(BuildContext context) {
    return Align(
        alignment: Alignment.bottomRight,
        //TODO: Row : show progress (if textInputValue.length> 0) if number of characters restricted
        child: PostCommentButton(
          feedGroup: feedGroup,
          activity: activity,
          targetFeeds: targetFeeds,
          textEditingController: textEditingController,
          foreignId: foreignId,
        ));
  }

  @override
  void debugFillProperties(DiagnosticPropertiesBuilder properties) {
    super.debugFillProperties(properties);
    properties.add(
        DiagnosticsProperty<GenericEnrichedActivity?>('activity', activity));
    properties.add(DiagnosticsProperty<TextEditingController>(
        'textEditingController', textEditingController));
    properties.add(StringProperty('feedGroup', feedGroup));
    properties.add(IterableProperty<FeedId>('targetFeeds', targetFeeds));
    properties.add(StringProperty('foreignId', foreignId));
  }
}
