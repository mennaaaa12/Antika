import 'package:antika/core/constant/color/my_color.dart';
import 'package:antika/core/utils/service.dart';
import 'package:antika/feature/home/data/models/channel_info.dart';
import 'package:antika/feature/home/data/models/videos_list.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:just_audio/just_audio.dart';
import 'package:logger/logger.dart';
import 'package:antika/feature/home/data/models/videos_list.dart' as videos;
import 'package:antika/feature/videos/ui/video_player_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool _loading = true;
  Channelinfo? _channelInfo;
  VideosList? _videosList;
  Item? _item;
  bool isPlaying = false;
  bool isPaused = false;
   late AudioPlayer _audioPlayer;
  String? _playListId;
  String? _nextPageToken;
  bool isButtonVisible = true;
  late ScrollController _scrollController;
  late ScrollController _scrollControllervideo;
  final Logger _logger = Logger();
  @override
  void initState() {
    super.initState();
    _audioPlayer = AudioPlayer();
    _scrollControllervideo = ScrollController();
    _scrollController = ScrollController()
      ..addListener(() {
        _onScroll();
      });
    _loading = true;
    _nextPageToken = '';
    _videosList = VideosList(
        videos: [],
        pageInfo: videos.PageInfo(totalResults: 0, resultsPerPage: 0));
    _videosList!.videos = [];
    _getChannelInfo();
    _setAudioSource();
  }

  Future<void> _setAudioSource() async {
    try {
      // Set the audio URL from Google Drive
      await _audioPlayer.setUrl(
        "https://drive.google.com/uc?export=download&id=1MsPpOUDX5y-ZGtkPL-V9IkB_Vy2fbjak",
      );
    } catch (e) {
      _logger.e("Error loading audio: $e");
    }
  }

  _loadingVideos() async {
    VideosList tempVideosList = await Service.getVideosList(
      playlistId: _playListId,
      pageToken: _nextPageToken,
    );
    _nextPageToken = tempVideosList.nextPageToken;
    _videosList!.videos.addAll(tempVideosList.videos);
    print('videos : ${_videosList!.videos.length}');
  }

  void _getChannelInfo() async {
    _channelInfo = await Service.getChannelInfo();
    if (_channelInfo != null && _channelInfo!.items.isNotEmpty) {
      _item = _channelInfo!.items[0];
      _playListId = _item!.contentDetails.relatedPlaylists.uploads;

      _logger.i('playListId: $_playListId');
      await _loadingVideos();
      setState(() {
        _loading = false;
      });
    }
  }
  void _onScroll() {
    if (_scrollController.position.userScrollDirection ==
            ScrollDirection.reverse &&
        isButtonVisible) {
      setState(() {
        isButtonVisible = false;
      });
    } else if (_scrollController.position.userScrollDirection ==
            ScrollDirection.forward &&
        !isButtonVisible) {
      setState(() {
        isButtonVisible = true;
      });
    }
  }
  @override
  void dispose() {
    _audioPlayer.dispose();
    _scrollControllervideo.dispose();
    _scrollController.dispose();
    super.dispose();
  }
 bool isLoading = false; // New loading state variable

void _onTapContainer() async {
  try {
    if (isPlaying) {
      await _audioPlayer.pause();
      setState(() {
        isPlaying = false; // Update state to paused
      });
    } else {
      await _audioPlayer.play();
      setState(() {
        isPlaying = true; // Update state to playing
      });
    }
  } catch (e) {
    _logger.e("Error toggling audio: $e");
  }
}


  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Container(
          width: double.infinity,
          height: double.infinity,
          decoration: const BoxDecoration(
            image: DecorationImage(
              image: AssetImage("assets/images/background.png"),
              fit: BoxFit.cover,
            ),
          ),
          child: Stack(
            children: [
              SingleChildScrollView(
                controller: _scrollController,
                child: Padding(
                  padding:
                      EdgeInsets.symmetric(horizontal: 0.w, vertical: 40.h),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Image.asset(
                        'assets/images/logo.png',
                        width: 150.w,
                        height: 150.h,
                      ),
                      SizedBox(height: 150.h),
                      GestureDetector(
                        onTap: _onTapContainer,
                        child: Center(
                          child: Container(
                            width: 85.w,
                            height: 85.h,
                            decoration: const BoxDecoration(
                              color: Color.fromARGB(255, 163, 155, 140),
                              shape: BoxShape.circle,
                            ),
                           child: Center(
                      child: Image.asset(
                        isPlaying
                            ? 'assets/images/pause.png'
                            : 'assets/images/play.png',
                        width: 60.w,
                        height: 60.h,
                      ),
                            ),
                          ),
                        ),
                      ),
                      SizedBox(height: 400.h),
                      _buildInfoView(),
                      NotificationListener<ScrollEndNotification>(
                        onNotification: (ScrollNotification notification) {
                          if (_videosList!.videos.length >=
                              int.parse(_item!.statistics.videoCount)) {
                            return true;
                          }
                          if (notification.metrics.pixels ==
                              notification.metrics.maxScrollExtent) {
                            _loadingVideos();
                          }
                          return true;
                        },
                        child: ListView.builder(
                            controller: _scrollControllervideo,
                            itemCount: _videosList!.videos.length,
                            shrinkWrap: true,
                            physics: const NeverScrollableScrollPhysics(),
                            itemBuilder: (context, index) {
                              VideoItem videoItem = _videosList!.videos[index];
                              return InkWell(
                                onTap: () async {
                                  Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => VideoPlayerScreen(
                                            videoItem: videoItem),
                                      ));
                                },
                                child: Container(
                                  padding: EdgeInsets.all(20.h),
                                  child: Row(
                                    children: [
                                      CachedNetworkImage(
                                        imageUrl: videoItem.video.thumbnails
                                            .thumbnailsDefault!.url,
                                      ),
                                      SizedBox(width: 20.w),
                                      Flexible(
                                        child: Text(
                                          videoItem.video.title,
                                          style: TextStyle(
                                              color: MyColor.primaryColorText,
                                              fontSize: 15.sp,
                                              fontWeight: FontWeight.w300),
                                        ),
                                      ),
                                    ],
                                  ),
                                ),
                              );
                            }),
                      )
                    ],
                  ),
                ),
              ),
              if (isButtonVisible)
                Positioned(
                  bottom: 36.h,
                  right: 170.w,
                  child: GestureDetector(
                    onTap: () {},
                    child: Center(
                      child: Icon(
                        Icons.arrow_downward,
                        color: MyColor.primaryColorinside,
                        size: 30.w,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInfoView() {
    return _loading
        ? const Center(child: CircularProgressIndicator(
          color: Color.fromARGB(255, 163, 155, 140),
        ))
        : Padding(
            padding: const EdgeInsets.all(20.0),
            child: Card(
              child: Padding(
                padding: const EdgeInsets.all(10.0),
                child: Row(
                  children: [
                    CircleAvatar(
                      backgroundImage: CachedNetworkImageProvider(
                        _item!.snippet.thumbnails.medium.url,
                      ),
                    ),
                    SizedBox(width: 20.w),
                    Expanded(
                      child: Text(
                        _item!.snippet.title,
                        style: TextStyle(
                          fontSize: 20.sp,
                          fontWeight: FontWeight.w400,
                        ),
                      ),
                    ),
                    // Text(_item!.statistics.viewCount),
                    // SizedBox(width: 20.w),
                  ],
                ),
              ),
            ),
          );
  }
}
