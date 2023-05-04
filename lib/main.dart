import 'package:fading_playlist/presentation/views/playlist_view.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const FadingPlaylistTransitionApp());
}

class FadingPlaylistTransitionApp extends StatelessWidget {
  const FadingPlaylistTransitionApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const PlaylistView(),
    );
  }
}
