import 'dart:io';

import 'package:antika/core/utils/constants.dart';
import 'package:antika/feature/home/data/models/channel_info.dart';
import 'package:antika/feature/home/data/models/videos_list.dart';
import 'package:http/http.dart';

class Service {
  static const channelId = 'UC_uwN86L77v24e7_ZAMrYJw';
  static const _baseUrl = 'youtube.googleapis.com';
  //static const playListId ='UU_uwN86L77v24e7_ZAMrYJw';

  static Future<Channelinfo> getChannelInfo() async {
    Map<String, String> parameters = {
      'part': 'snippet,contentDetails,statistics',
      'id': channelId,
      'key': Constants.apiKey,
    };
    Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };
    Uri uri = Uri.https(
      _baseUrl,
      '/youtube/v3/channels',
      parameters,
    );
    Response response = await get(uri, headers: headers);
    // print(response.body);
    return channelinfoFromJson(response.body);
  }
  static Future<VideosList> getVideosList({String? playlistId,String? pageToken}) async {
   Map<String, String> parameters = {
    'part': 'snippet',
    'playlistId': playlistId!,
    'maxResults': '64',
    'pageToken': pageToken!,
    'key': Constants.apiKey,
   };
   Map<String, String> headers = {
      HttpHeaders.contentTypeHeader: 'application/json',
    };
   Uri uri = Uri.https(
      _baseUrl,
      '/youtube/v3/playlistItems',
      parameters,
    );
    Response response = await get(uri, headers: headers);
    // print(response.body);
    VideosList videosList = videosListFromJson(response.body);
    return videosList;
  }
}
