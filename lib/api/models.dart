import 'package:html_unescape/html_unescape.dart';
import 'package:intl/intl.dart';
import 'api_client.dart';

final _unescape = HtmlUnescape();

String _decode(String? s) => _unescape.convert(s ?? '');

String _stripTags(String html) =>
    html.replaceAll(RegExp(r'<[^>]*>'), '').replaceAll(RegExp(r'\s+'), ' ').trim();

/// PRESS RELEASE / NEWS
class PressItem {
  final int id;
  final String title;
  final String excerpt;
  final String content;
  final String dateLabel;
  final String? externalUrl;
  final String? featuredImage;

  PressItem({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.content,
    required this.dateLabel,
    this.externalUrl,
    this.featuredImage,
  });

  factory PressItem.fromJson(Map<String, dynamic> j) {
    final meta = j['meta'] as Map<String, dynamic>? ?? {};
    String dateLabel = meta['_rk_press_date_label']?.toString() ?? '';
    if (dateLabel.isEmpty && j['date'] != null) {
      try {
        dateLabel = DateFormat('d MMM yyyy').format(DateTime.parse(j['date']));
      } catch (_) {}
    }
    return PressItem(
      id: j['id'] as int,
      title: _decode(j['title']?['rendered']?.toString()),
      excerpt: _decode(_stripTags(j['excerpt']?['rendered']?.toString() ?? '')),
      content: _decode(j['content']?['rendered']?.toString() ?? ''),
      dateLabel: dateLabel,
      externalUrl: meta['_rk_press_external_url']?.toString(),
      featuredImage: Api.embeddedImage(j),
    );
  }
}

/// EVENT
class EventItem {
  final int id;
  final String title;
  final String excerpt;
  final String content;
  final String date;
  final String time;
  final String venue;
  final String type;
  final String registerUrl;
  final String? featuredImage;

  EventItem({
    required this.id,
    required this.title,
    required this.excerpt,
    required this.content,
    required this.date,
    required this.time,
    required this.venue,
    required this.type,
    required this.registerUrl,
    this.featuredImage,
  });

  factory EventItem.fromJson(Map<String, dynamic> j) {
    final meta = j['meta'] as Map<String, dynamic>? ?? {};
    return EventItem(
      id: j['id'] as int,
      title: _decode(j['title']?['rendered']?.toString()),
      excerpt: _decode(_stripTags(j['excerpt']?['rendered']?.toString() ?? '')),
      content: _decode(j['content']?['rendered']?.toString() ?? ''),
      date: meta['_rk_event_date']?.toString() ?? '',
      time: meta['_rk_event_time']?.toString() ?? '',
      venue: meta['_rk_event_venue']?.toString() ?? '',
      type: meta['_rk_event_type']?.toString() ?? '',
      registerUrl: meta['_rk_event_register_url']?.toString() ?? '',
      featuredImage: Api.embeddedImage(j),
    );
  }

  String get displayDate {
    if (date.isEmpty) return '';
    try {
      return DateFormat('d MMM yyyy').format(DateTime.parse(date));
    } catch (_) {
      return date;
    }
  }

  String get displayDay {
    if (date.isEmpty) return '—';
    try {
      return DateFormat('dd').format(DateTime.parse(date));
    } catch (_) {
      return '—';
    }
  }

  String get displayMonth {
    if (date.isEmpty) return '';
    try {
      return DateFormat('MMM').format(DateTime.parse(date)).toUpperCase();
    } catch (_) {
      return '';
    }
  }
}

/// LITERARY INSPIRATION
class InspirationItem {
  final int id;
  final String name;
  final String hindiName;
  final String era;
  final String tag;
  final String link;
  final String? featuredImage;

  InspirationItem({
    required this.id,
    required this.name,
    required this.hindiName,
    required this.era,
    required this.tag,
    required this.link,
    this.featuredImage,
  });

  factory InspirationItem.fromJson(Map<String, dynamic> j) {
    final meta = j['meta'] as Map<String, dynamic>? ?? {};
    return InspirationItem(
      id: j['id'] as int,
      name: _decode(j['title']?['rendered']?.toString()),
      hindiName: meta['_rk_inspiration_title_hi']?.toString() ?? '',
      era: meta['_rk_inspiration_era']?.toString() ?? '',
      tag: meta['_rk_inspiration_tag']?.toString() ?? '',
      link: meta['_rk_inspiration_link']?.toString() ?? '',
      featuredImage: Api.embeddedImage(j),
    );
  }
}

/// TRACK (YouTube video)
class TrackItem {
  final int id;
  final String title;
  final String youtubeUrl;
  final String artist;
  final String genre;
  final String language;
  final String? featuredImage;

  TrackItem({
    required this.id,
    required this.title,
    required this.youtubeUrl,
    required this.artist,
    required this.genre,
    required this.language,
    this.featuredImage,
  });

  factory TrackItem.fromJson(Map<String, dynamic> j) {
    final meta = j['meta'] as Map<String, dynamic>? ?? {};
    return TrackItem(
      id: j['id'] as int,
      title: _decode(j['title']?['rendered']?.toString()),
      youtubeUrl: meta['_rachnakaar_youtube_url']?.toString() ?? '',
      artist: meta['_rachnakaar_artist']?.toString() ?? '',
      genre: meta['_rachnakaar_genre']?.toString() ?? '',
      language: meta['_rachnakaar_language']?.toString() ?? '',
      featuredImage: Api.embeddedImage(j),
    );
  }

  /// Extract 11-char YouTube video ID from any URL.
  String? get youtubeId {
    final patterns = [
      RegExp(r'youtube\.com/watch\?v=([A-Za-z0-9_-]{11})'),
      RegExp(r'youtu\.be/([A-Za-z0-9_-]{11})'),
      RegExp(r'youtube\.com/embed/([A-Za-z0-9_-]{11})'),
      RegExp(r'youtube\.com/shorts/([A-Za-z0-9_-]{11})'),
    ];
    for (final p in patterns) {
      final m = p.firstMatch(youtubeUrl);
      if (m != null) return m.group(1);
    }
    return null;
  }

  String? get thumbnail =>
      youtubeId != null ? 'https://i.ytimg.com/vi/$youtubeId/hqdefault.jpg' : featuredImage;
}
