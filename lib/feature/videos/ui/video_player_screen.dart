import 'package:antika/core/constant/color/my_color.dart';
import 'package:antika/feature/home/data/models/videos_list.dart';
import 'package:flutter/material.dart';
import 'package:youtube_player_flutter/youtube_player_flutter.dart';

class VideoPlayerScreen extends StatefulWidget {
  const VideoPlayerScreen({super.key,  this.videoItem});
  final VideoItem? videoItem;

  @override
  State<VideoPlayerScreen> createState() => _VideoPlayerScreenState();
}

class _VideoPlayerScreenState extends State<VideoPlayerScreen> {
  YoutubePlayerController _controller= YoutubePlayerController(initialVideoId: '0', flags: const YoutubePlayerFlags()
  );
  bool _isPlayerReady = false;

  @override
  void initState() {
    _isPlayerReady = false;
    _controller = YoutubePlayerController(
      initialVideoId: widget.videoItem!.video.resourceId.videoId,
      flags: const YoutubePlayerFlags(
        autoPlay: true,
        mute: false,
     ) )..addListener(_listener);
    
    super.initState();}

  void _listener() {
    if (_isPlayerReady && mounted && !_controller.value.isFullScreen) {
      setState(() {
        _isPlayerReady = true;
      });
    }}

@override
  void deactivate() {
    _controller.pause();
    super.deactivate();
  }
  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: MyColor.primaryBackGroundColor,
        title: Text(widget.videoItem!.video.title,style: const TextStyle(color: Colors.white),),
      ),
      body: YoutubePlayer(
        controller: _controller,
        showVideoProgressIndicator: true,
        progressIndicatorColor: Colors.amber,
        onReady: () {
          // print('Player is ready.');
          _isPlayerReady = true;  
        },
      ),
      
    );
  }
}