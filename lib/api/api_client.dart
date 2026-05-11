import 'dart:convert';
import 'package:http/http.dart' as http;

/// Single source for the base URL — change this if you ever move the site.
class Api {
  static const String baseUrl = 'https://rachnakaar.com/wp-json/wp/v2';

  /// Generic GET helper with timeout.
  static Future<List<dynamic>> getList(String path, {Map<String, String>? params}) async {
    final uri = Uri.parse('$baseUrl/$path').replace(queryParameters: params);
    final resp = await http.get(uri).timeout(const Duration(seconds: 20));
    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode} for $path');
    }
    final data = json.decode(resp.body);
    if (data is! List) throw Exception('Expected list, got ${data.runtimeType}');
    return data;
  }

  /// Get a single post by ID (uses _embed to pull featured image in one call).
  static Future<Map<String, dynamic>> getOne(String path, int id) async {
    final uri = Uri.parse('$baseUrl/$path/$id').replace(queryParameters: {'_embed': '1'});
    final resp = await http.get(uri).timeout(const Duration(seconds: 20));
    if (resp.statusCode != 200) {
      throw Exception('HTTP ${resp.statusCode}');
    }
    return json.decode(resp.body) as Map<String, dynamic>;
  }

  /// Fetch featured image URL for a post when included via _embed.
  static String? embeddedImage(Map<String, dynamic> post) {
    try {
      final embedded = post['_embedded'];
      if (embedded == null) return null;
      final media = embedded['wp:featuredmedia'];
      if (media is List && media.isNotEmpty) {
        final first = media[0];
        // Prefer 'medium' or 'large' size if available, fall back to source URL.
        final details = first['media_details'];
        if (details != null && details['sizes'] != null) {
          final sizes = details['sizes'];
          for (final size in ['medium_large', 'medium', 'large', 'full']) {
            if (sizes[size] != null && sizes[size]['source_url'] != null) {
              return sizes[size]['source_url'] as String;
            }
          }
        }
        return first['source_url'] as String?;
      }
    } catch (_) {}
    return null;
  }
}
