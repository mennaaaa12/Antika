import 'package:antika/core/routing/routes.dart';
import 'package:antika/feature/home/ui/home.dart';
import 'package:antika/feature/videos/ui/video_player_screen.dart';
import 'package:flutter/material.dart';
class AppRouter {
  Route? generateRoute(RouteSettings settings) {
    final arguments = settings.arguments;

    switch (settings.name) {
  
      case Routes.homeScreen:
        return MaterialPageRoute(
          builder: (_) => const HomeScreen(),
        );
     case Routes.videoPlayerScreen:
        return MaterialPageRoute(
          builder: (_) => const VideoPlayerScreen(),
        );
      default:
        return null;
    }
  }
}
