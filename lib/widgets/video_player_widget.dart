import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerWidget extends StatelessWidget {
  final String videoId;

  const VideoPlayerWidget({super.key, required this.videoId});

  @override
  Widget build(BuildContext context) {
    return YoutubePlayer(
      /*aspectRatio: 16 / 9,
      bottomActions: [
        CurrentPosition(),
        ProgressBar(isExpanded: true),
        RemainingDuration(),
        FullScreenButton(),
      ],*/
      controller: YoutubePlayerController(
        initialVideoId: videoId,
        flags: YoutubePlayerFlags(
          autoPlay: false,
        ),
      ),
      showVideoProgressIndicator: true,
    );
  }
}
