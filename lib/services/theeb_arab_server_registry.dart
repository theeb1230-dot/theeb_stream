/// Canonical migration inventory agreed for Theeb Arab -> Theeb Stream.
///
/// This registry is deliberately metadata-only until a playback adapter has a
/// verified movie/series template or resolver contract. A name appearing here
/// MUST NOT be treated as a working stream by health/ranking code.
class TheebArabServerDefinition {
  final String id;
  final String name;
  final bool alreadyInRuntime;
  final String? runtimeName;
  final bool supportsMovie;
  final bool supportsSeries;

  const TheebArabServerDefinition({
    required this.id,
    required this.name,
    required this.alreadyInRuntime,
    this.runtimeName,
    this.supportsMovie = true,
    this.supportsSeries = true,
  });
}

class TheebArabServerRegistry {
  const TheebArabServerRegistry._();

  /// Exact 27-name inventory recovered from the agreed CinemaServer source.
  /// Do not rename/reorder entries casually: order is the historical fallback
  /// priority until runtime health ranking supersedes it.
  static const List<TheebArabServerDefinition> all = [
    TheebArabServerDefinition(id: 'pomfy', name: 'Pomfy', alreadyInRuntime: false),
    TheebArabServerDefinition(
      id: 'videasy',
      name: 'Videasy',
      alreadyInRuntime: true,
      runtimeName: 'Videasy',
    ),
    TheebArabServerDefinition(id: 'superflix', name: 'Superflix', alreadyInRuntime: false),
    TheebArabServerDefinition(
      id: 'vidfast',
      name: 'VidFast',
      alreadyInRuntime: true,
      runtimeName: 'VidFast',
    ),
    TheebArabServerDefinition(id: 'vidsrc-pro', name: 'VidSrc Pro', alreadyInRuntime: false),
    TheebArabServerDefinition(id: 'vidsrc-to', name: 'VidSrc To', alreadyInRuntime: false),
    TheebArabServerDefinition(id: 'superembed', name: 'SuperEmbed', alreadyInRuntime: false),
    TheebArabServerDefinition(
      id: '2embed',
      name: '2Embed',
      alreadyInRuntime: true,
      runtimeName: '2Embed',
    ),
    TheebArabServerDefinition(id: 'autoembed', name: 'AutoEmbed', alreadyInRuntime: false),
    TheebArabServerDefinition(id: 'vidsrc-me', name: 'VidSrc Me', alreadyInRuntime: false),
    TheebArabServerDefinition(id: 'embedsu', name: 'EmbedSu', alreadyInRuntime: false),
    TheebArabServerDefinition(id: 'smashystream', name: 'SmashyStream', alreadyInRuntime: false),
    TheebArabServerDefinition(id: 'nontongo', name: 'NontonGo', alreadyInRuntime: false),
    TheebArabServerDefinition(id: 'movieapi', name: 'MovieAPI', alreadyInRuntime: false),
    TheebArabServerDefinition(id: 'vidbox', name: 'VidBox', alreadyInRuntime: false),
    TheebArabServerDefinition(id: 'moviesapi', name: 'MoviesAPI', alreadyInRuntime: false),
    TheebArabServerDefinition(id: 'fembed', name: 'Fembed', alreadyInRuntime: false),
    TheebArabServerDefinition(
      id: 'frembed',
      name: 'Frembed',
      alreadyInRuntime: true,
      runtimeName: 'Frembed',
    ),
    TheebArabServerDefinition(id: 'databasegdrive', name: 'DatabaseGdrive', alreadyInRuntime: false),
    TheebArabServerDefinition(id: 'anime-day', name: 'أنمي داي', alreadyInRuntime: false),
    TheebArabServerDefinition(id: 'animevibe', name: 'AnimeVibe', alreadyInRuntime: false),
    TheebArabServerDefinition(id: 'vidsrc-xyz', name: 'VidSrc XYZ', alreadyInRuntime: false),
    TheebArabServerDefinition(id: 'streamhd', name: 'StreamHD', alreadyInRuntime: false),
    TheebArabServerDefinition(
      id: 'vidlink',
      name: 'VidLink',
      alreadyInRuntime: true,
      runtimeName: 'VidLink',
    ),
    TheebArabServerDefinition(id: 'filmfast', name: 'FilmFast', alreadyInRuntime: false),
    TheebArabServerDefinition(id: 'arabstream', name: 'ArabStream', alreadyInRuntime: false),
    TheebArabServerDefinition(
      id: 'generic-fallback',
      name: 'الاحتياطي العام',
      alreadyInRuntime: false,
    ),
  ];

  static List<TheebArabServerDefinition> get integrated =>
      all.where((server) => server.alreadyInRuntime).toList(growable: false);

  static List<TheebArabServerDefinition> get pending =>
      all.where((server) => !server.alreadyInRuntime).toList(growable: false);
}
