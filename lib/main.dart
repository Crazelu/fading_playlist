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
        primarySwatch: MaterialColor(
          Colors.black.value,
          {
            50: Colors.black.withOpacity(.1),
            100: Colors.black.withOpacity(.2),
            200: Colors.black.withOpacity(.3),
            300: Colors.black.withOpacity(.4),
            400: Colors.black.withOpacity(.5),
            500: Colors.black.withOpacity(.6),
            600: Colors.black.withOpacity(.7),
            700: Colors.black.withOpacity(.8),
            800: Colors.black.withOpacity(.9),
            900: Colors.black,
          },
        ),
        primaryColor: Colors.white,
        primaryColorLight: Colors.white,
        primaryColorDark: Colors.black,
      ),
      home: const PlaylistView(),
    );
  }
}
