import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class CourseDetailPage extends StatefulWidget {
  const CourseDetailPage({Key? key}) : super(key: key);

  @override
  _CourseDetailPageState createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  List videoInfo = [];
  bool _playArea = false;
  YoutubePlayerController? _youtubeController;
  int _currentVideoIndex = 0;

  _initData() async {
    try {
      final String value = await DefaultAssetBundle.of(context)
          .loadString("assets/json/videoInfo.json");
      setState(() {
        videoInfo = json.decode(value);
      });
    } catch (e) {
      print("Error loading JSON data: $e");
    }
  }

  @override
  void initState() {
    super.initState();
    _initData();
  }

  @override
  void dispose() {
    _youtubeController?.dispose();
    super.dispose();
  }

  void _onTapVideo(int index) {
    final videoId = videoInfo[index]["videoId"];
    if (videoId == null || videoId.isEmpty) return;

    setState(() {
      _currentVideoIndex = index;
      _playArea = true;
      _youtubeController = YoutubePlayerController(
        initialVideoId: videoId,
        flags: const YoutubePlayerFlags(
          autoPlay: true,
          mute: false,
        ),
      );
    });
  }

  void _playPreviousVideo() {
    if (_currentVideoIndex > 0) {
      _onTapVideo(
          _currentVideoIndex - 1); // Automatically plays the previous video
    }
  }

  void _playNextVideo() {
    if (_currentVideoIndex < videoInfo.length - 1) {
      _onTapVideo(_currentVideoIndex + 1); // Automatically plays the next video
    }
  }

  void _togglePlayPause() {
    if (_youtubeController!.value.isPlaying) {
      _youtubeController!.pause();
    } else {
      _youtubeController!.play();
    }
  }

  Widget _navigationControls() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        IconButton(
          icon: const Icon(Icons.skip_previous, color: Colors.white),
          onPressed: _currentVideoIndex > 0 ? _playPreviousVideo : null,
          iconSize: 32,
        ),
        const SizedBox(width: 20),
        IconButton(
          icon: Icon(
            _youtubeController!.value.isPlaying
                ? Icons.pause
                : Icons.play_arrow,
            color: Colors.white,
          ),
          onPressed: _togglePlayPause,
        ),
        const SizedBox(width: 20),
        IconButton(
          icon: const Icon(Icons.skip_next, color: Colors.white),
          onPressed:
              _currentVideoIndex < videoInfo.length - 1 ? _playNextVideo : null,
          iconSize: 32,
        ),
      ],
    );
  }

  Widget _playView() {
    if (_youtubeController != null) {
      return Column(
        children: [
          YoutubePlayer(
            controller: _youtubeController!,
            showVideoProgressIndicator: true,
            progressColors: const ProgressBarColors(
              playedColor: Color.fromARGB(255, 248, 243, 243),
              handleColor: Color.fromARGB(255, 228, 97, 97),
            ),
          ),
          const SizedBox(height: 20),
          _navigationControls(),
        ],
      );
    } else {
      return const Center(
        child: Text(
          "En cours...",
          style: TextStyle(fontSize: 20, color: Colors.white60),
        ),
      );
    }
  }

  Widget _buildCard(int index) {
    return Container(
      height: 135,
      decoration: BoxDecoration(
        color: _currentVideoIndex == index && _playArea
            ? const Color.fromARGB(255, 247, 238, 238)
            : Colors.transparent,
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          const SizedBox(height: 18),
          Row(
            children: [
              const SizedBox(width: 15),
              Container(
                width: 80,
                height: 80,
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(10),
                  image: DecorationImage(
                    image: AssetImage(videoInfo[index]["thumbnail"]),
                    fit: BoxFit.cover,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    videoInfo[index]["title"],
                    style: const TextStyle(
                      color: Color.fromARGB(255, 131, 41, 41),
                      fontSize: 15,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 18),
          Row(
            children: [
              const SizedBox(width: 20),
              ...List.generate(
                100,
                (i) => Container(
                  width: 3,
                  height: 2,
                  decoration: const BoxDecoration(
                    color: Color.fromARGB(255, 252, 237, 237),
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: !_playArea
            ? const BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 228, 97, 97),
                    Color.fromARGB(255, 131, 41, 41),
                  ],
                  begin: FractionalOffset(0.0, 0.4),
                  end: Alignment.topCenter,
                ),
              )
            : BoxDecoration(
                color: Colors.grey[900],
              ),
        child: Column(
          children: [
            if (!_playArea) ...[
              Container(
                padding: const EdgeInsets.only(
                  top: 50,
                  left: 30,
                  right: 30,
                ),
                width: MediaQuery.of(context).size.width,
                height: 250,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    InkWell(
                      onTap: () {
                        Navigator.pop(
                            context); // Just pop the context to go back
                      },
                      child: Row(
                        children: const [
                          Icon(Icons.arrow_back_ios,
                              size: 20, color: Colors.white),
                        ],
                      ),
                    ),
                    const SizedBox(height: 10),
                    const Text(
                      'Transformation du cacao',
                      style: TextStyle(
                        fontSize: 20,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 5),
                    const Text(
                      'Comment traiter la fève',
                      style: TextStyle(
                        fontSize: 18,
                        color: Colors.white,
                      ),
                    ),
                    const SizedBox(height: 50),
                    Row(
                      children: [
                        Container(
                          width: 100,
                          height: 30,
                          decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(10),
                            gradient: const LinearGradient(
                              colors: [
                                Color.fromARGB(255, 228, 97, 97),
                                Color.fromARGB(255, 131, 41, 41),
                              ],
                              begin: Alignment.centerLeft,
                              end: Alignment.topRight,
                            ),
                          ),
                          child: Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: const [
                              Icon(
                                Icons.timer,
                                color: Colors.white,
                              ),
                              SizedBox(width: 5),
                              Text(
                                "2h 20min",
                                style: TextStyle(
                                  fontSize: 12,
                                  color: Colors.white60,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ],
                ),
              )
            ] else ...[
              Container(
                child: Column(
                  children: [
                    Container(
                      height: 100,
                      padding: const EdgeInsets.only(
                        top: 50,
                        left: 30,
                        right: 30,
                      ),
                      child: Row(
                        children: [
                          InkWell(
                            onTap: () {
                              setState(() {
                                _playArea = false;
                                _youtubeController?.pause();
                              });
                            },
                            child: const Icon(
                              Icons.arrow_back_ios,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                          const Spacer(),
                          const Icon(
                            Icons.info_outline,
                            size: 20,
                            color: Colors.white,
                          )
                        ],
                      ),
                    ),
                    _playView(),
                  ],
                ),
              ),
            ],
            Expanded(
              child: Container(
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  children: [
                    const SizedBox(height: 10),
                    Expanded(
                      child: ListView.builder(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 30, vertical: 8),
                        itemCount: videoInfo.length,
                        itemBuilder: (_, int index) {
                          return GestureDetector(
                            onTap: () => _onTapVideo(index),
                            child: _buildCard(index),
                          );
                        },
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
