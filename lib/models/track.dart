class Track {
  final String url;
  final String filename;

  const Track({required this.url, required this.filename});

  //CREDITS: https://trendybeatz.com/
  static List<Track> tracks = const [
    Track(
      url:
          "https://cdn.trendybeatz.com/audio/Rema-Charm-New-Track-(TrendyBeatz.com).mp3",
      filename: "Rema - Charm",
    ),
    Track(
      url:
          "https://cdn.trendybeatz.com/audio/Davido-Feel-(TrendyBeatz.com).mp3",
      filename: "Davido - Feel",
    ),
    Track(
      url:
          "https://cdn.trendybeatz.com/audio/Ckay-Ft-Davido-Focalistic-and-Abidoza-Watawi-(TrendyBeatz.com).mp3",
      filename: "Ckay - Watawi ft Davido, Focalistic, Abidoza",
    ),
    Track(
      url:
          "https://cdn.trendybeatz.com/audio/Blaqbonez-Ft-Jae5-Back-In-Uni-(TrendyBeatz.com).mp3",
      filename: "Blaqbonez - Back In Uni ft Jae5",
    ),
    Track(
      url:
          "https://cdn.trendybeatz.com/audio/Davido-Ft-The-Cavemen-and-Angelique-Kidjo-Na-Money-(TrendyBeatz.com).mp3",
      filename: "Davido - Na Money ft The Cavemen, Angelique Kidjo",
    ),
  ];
}
