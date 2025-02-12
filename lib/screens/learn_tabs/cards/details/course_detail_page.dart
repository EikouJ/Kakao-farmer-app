import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:video_player/video_player.dart';

class VideoInfo {
  final String title;
  final String time;
  final String thumbnail;
  final String videoPath; // Changed from videoURL to videoPath

  VideoInfo({
    required this.title,
    required this.time,
    required this.thumbnail,
    required this.videoPath,
  });

  factory VideoInfo.fromJson(Map<String, dynamic> json) {
    return VideoInfo(
      title: json['title'] ?? '',
      time: json['time'] ?? '',
      thumbnail: json['thumbnail'] ?? '',
      videoPath: json['videoPath'] ?? '', // Use videoPath instead of videoURL
    );
  }
}

class CourseDetailPage extends StatefulWidget {
  const CourseDetailPage({Key? key}) : super(key: key);

  @override
  _CourseDetailPageState createState() => _CourseDetailPageState();
}

class _CourseDetailPageState extends State<CourseDetailPage> {
  List<VideoInfo> _videoInfo = [];
  bool _playArea = false;
  bool _isPlaying = false;
  VideoPlayerController? _controller;
  Duration _position = Duration.zero;
  Duration _duration = Duration.zero;
  int _currentVideoIndex = -1;

  @override
  void initState() {
    super.initState();
    _initData();
  }

  Future<void> _initData() async {
    try {
      final String value = await DefaultAssetBundle.of(context)
          .loadString("assets/json/video_info.json");
      setState(() {
        final List<dynamic> decodedData = json.decode(value);
        _videoInfo =
            decodedData.map((item) => VideoInfo.fromJson(item)).toList();
      });
    } catch (e) {
      debugPrint("Error loading JSON data: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Échec du chargement du contenu du cours')),
      );
    }
  }

  Future<void> _initializeVideo(int index) async {
    if (index < 0 || index >= _videoInfo.length) return;

    final videoPath = _videoInfo[index].videoPath;
    if (videoPath.isEmpty) return;

    try {
      await _controller?.dispose();
      _controller = VideoPlayerController.asset(
          "assets/videos/Shimmer_Loading_Effect___FLUTTER_Tutorial(720p).mp4");

      await _controller!.initialize();
      _controller!.addListener(_onControllerUpdate);
      await _controller!.play();

      setState(() {
        _currentVideoIndex = index;
        _isPlaying = true;
        _playArea = true;
      });
    } catch (e) {
      debugPrint("Error initializing video: $e");
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content:
              Text('Erreur lors du chargement de la vidéo: ${e.toString()}'),
          duration: Duration(seconds: 3),
        ),
      );
    }
  }

  void _onControllerUpdate() {
    if (_controller != null && _controller!.value.isInitialized) {
      setState(() {
        _position = _controller!.value.position;
        _duration = _controller!.value.duration;
        _isPlaying = _controller!.value.isPlaying;
      });
    }
  }

  void _playNextVideo() {
    if (_currentVideoIndex < _videoInfo.length - 1) {
      _initializeVideo(_currentVideoIndex + 1);
    }
  }

  void _playPreviousVideo() {
    if (_currentVideoIndex > 0) {
      _initializeVideo(_currentVideoIndex - 1);
    }
  }

  @override
  void dispose() {
    _controller?.dispose();
    super.dispose();
  }

  String _formatDuration(Duration duration) {
    String twoDigits(int n) => n.toString().padLeft(2, '0');
    final hours = twoDigits(duration.inHours);
    final minutes = twoDigits(duration.inMinutes.remainder(60));
    final seconds = twoDigits(duration.inSeconds.remainder(60));
    return duration.inHours > 0
        ? '$hours:$minutes:$seconds'
        : '$minutes:$seconds';
  }

  Widget _buildVideoControls() {
    return Column(
      children: [
        Slider(
          value: _position.inSeconds.toDouble(),
          min: 0,
          max: _duration.inSeconds.toDouble(),
          onChanged: (value) {
            final newPosition = Duration(seconds: value.toInt());
            setState(() {
              _position = newPosition; // Update position in real-time
            });
          },
          onChangeEnd: (value) {
            _controller?.seekTo(Duration(seconds: value.toInt()));
          },
        ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 16),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(_formatDuration(_position),
                  style: TextStyle(color: Colors.white)),
              Text(_formatDuration(_duration),
                  style: TextStyle(color: Colors.white)),
            ],
          ),
        ),
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            IconButton(
              onPressed: _currentVideoIndex > 0 ? _playPreviousVideo : null,
              icon: Icon(Icons.skip_previous,
                  color: _currentVideoIndex > 0 ? Colors.white : Colors.grey,
                  size: 36),
            ),
            IconButton(
              onPressed: () {
                final newPosition = _position - Duration(seconds: 10);
                _controller?.seekTo(newPosition);
              },
              icon: Icon(Icons.replay_10, color: Colors.white, size: 36),
            ),
            IconButton(
              onPressed: () {
                if (_controller != null) {
                  setState(() {
                    _isPlaying ? _controller?.pause() : _controller?.play();
                    _isPlaying = !_isPlaying;
                  });
                }
              },
              icon: Icon(
                _isPlaying ? Icons.pause : Icons.play_arrow,
                color: Colors.white,
                size: 46,
              ),
            ),
            IconButton(
              onPressed: () {
                final newPosition = _position + Duration(seconds: 10);
                _controller?.seekTo(newPosition);
              },
              icon: Icon(Icons.forward_10, color: Colors.white, size: 36),
            ),
            IconButton(
              onPressed: _currentVideoIndex < _videoInfo.length - 1
                  ? _playNextVideo
                  : null,
              icon: Icon(Icons.skip_next,
                  color: _currentVideoIndex < _videoInfo.length - 1
                      ? Colors.white
                      : Colors.grey,
                  size: 36),
            ),
          ],
        ),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: _playArea
            ? BoxDecoration(color: Colors.black)
            : BoxDecoration(
                gradient: LinearGradient(
                  colors: [
                    Color.fromARGB(255, 228, 97, 97),
                    Color.fromARGB(255, 131, 41, 41),
                  ],
                  begin: const FractionalOffset(0.0, 0.4),
                  end: Alignment.topCenter,
                ),
              ),
        child: Column(
          children: [
            if (_playArea) ...[
              SafeArea(
                child: Column(
                  children: [
                    Container(
                      height: 60,
                      padding: const EdgeInsets.symmetric(horizontal: 16),
                      child: Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              setState(() {
                                _playArea = false;
                                _controller?.pause();
                              });
                            },
                            icon: Icon(Icons.arrow_back_ios,
                                color: Colors.white, size: 20),
                          ),
                          Expanded(child: Container()),
                          IconButton(
                            onPressed: () {},
                            icon: Icon(Icons.info_outline,
                                color: Colors.white, size: 20),
                          ),
                        ],
                      ),
                    ),
                    if (_controller != null && _controller!.value.isInitialized)
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: VideoPlayer(_controller!),
                      )
                    else
                      AspectRatio(
                        aspectRatio: 16 / 9,
                        child: Center(
                          child: CircularProgressIndicator(color: Colors.white),
                        ),
                      ),
                    _buildVideoControls(),
                  ],
                ),
              ),
            ] else ...[
              SafeArea(
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 30, vertical: 20),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        children: [
                          IconButton(
                            onPressed: () {
                              Navigator.of(context).pop();
                            },
                            icon: Icon(Icons.arrow_back_ios,
                                size: 20, color: Colors.white),
                          ),
                          Expanded(child: Container()),
                          Icon(Icons.info_outline,
                              size: 20, color: Colors.white),
                        ],
                      ),
                      SizedBox(height: 20),
                      Text(
                        'Transformation du cacao',
                        style: TextStyle(
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                            color: Colors.white),
                      ),
                      SizedBox(height: 5),
                      Text(
                        'Comment traiter la fève',
                        style: TextStyle(fontSize: 18, color: Colors.white70),
                      ),
                      SizedBox(height: 20),
                      Container(
                        padding:
                            EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                        decoration: BoxDecoration(
                          borderRadius: BorderRadius.circular(15),
                          color: Colors.white.withOpacity(0.1),
                        ),
                        child: Row(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Icon(Icons.timer, color: Colors.white, size: 16),
                            SizedBox(width: 5),
                            Text("2h 20min",
                                style: TextStyle(
                                    color: Colors.white70, fontSize: 14)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
            Expanded(
              child: ListView.builder(
                padding: EdgeInsets.symmetric(horizontal: 30, vertical: 8),
                itemCount: _videoInfo.length,
                itemBuilder: (context, index) {
                  final video = _videoInfo[index];
                  return GestureDetector(
                    onTap: () => _initializeVideo(index),
                    child: Container(
                      height: 100,
                      margin: EdgeInsets.only(bottom: 20),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(15),
                        color: Colors.white,
                        boxShadow: [
                          BoxShadow(
                            color: Colors.black.withOpacity(0.1),
                            blurRadius: 10,
                            offset: Offset(0, 5),
                          ),
                        ],
                      ),
                      child: Row(
                        children: [
                          Container(
                            width: 100,
                            decoration: BoxDecoration(
                              borderRadius: BorderRadius.only(
                                topLeft: Radius.circular(15),
                                bottomLeft: Radius.circular(15),
                              ),
                              image: DecorationImage(
                                image: AssetImage(video.thumbnail),
                                fit: BoxFit.cover,
                              ),
                            ),
                          ),
                          Expanded(
                            child: Padding(
                              padding: const EdgeInsets.all(16),
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                mainAxisAlignment: MainAxisAlignment.center,
                                children: [
                                  Text(
                                    video.title,
                                    style: TextStyle(
                                      fontSize: 16,
                                      fontWeight: FontWeight.bold,
                                      color: Color.fromARGB(255, 131, 41, 41),
                                    ),
                                  ),
                                  SizedBox(height: 8),
                                  Text(
                                    video.time,
                                    style: TextStyle(
                                      color: Colors.grey[600],
                                      fontSize: 14,
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
                },
              ),
            ),
          ],
        ),
      ),
    );
  }
}
