class Track {
  final String url;
  final String artist;
  final String title;

  const Track({
    required this.url,
    required this.artist,
    required this.title,
  });

  //CREDITS: https://trendybeatz.com/
  static List<Track> tracks = const [
    Track(
      url:
          "https://cdn.trendybeatz.com/audio/Kizz-Daniel-Cough-Odo-(TrendyBeatz.com).mp3",
      artist: "Kizz Daniel",
      title: "Cough (Odo)",
    ),
    Track(
      url:
          "https://cdn.trendybeatz.com/audio/Davido-Feel-(TrendyBeatz.com).mp3",
      artist: "Davido",
      title: "Feel",
    ),
    Track(
      url:
          "https://cdn.trendybeatz.com/audio/Ckay-Ft-Davido-Focalistic-and-Abidoza-Watawi-(TrendyBeatz.com).mp3",
      artist: "Ckay ft Davido, Focalistic, Abidoza",
      title: "Watawi",
    ),
    Track(
      url:
          "https://cdn.trendybeatz.com/audio/Blaqbonez-Ft-Jae5-Back-In-Uni-(TrendyBeatz.com).mp3",
      artist: "Blaqbonez ft Jae5",
      title: "Back In Uni",
    ),
    Track(
      url:
          "https://cdn.trendybeatz.com/audio/Davido-Ft-The-Cavemen-and-Angelique-Kidjo-Na-Money-(TrendyBeatz.com).mp3",
      artist: "Davido ft The Cavemen, Angelique Kidjo",
      title: "Na Money",
    ),
    Track(
      url:
          "https://cdn.trendybeatz.com/audio/Wizkid-Ft-Ayra-Starr-2-Sugar-(TrendyBeatz.com).mp3",
      artist: "Wizkid ft Ayra Starr",
      title: "2 Sugar",
    ),
  ];
}
