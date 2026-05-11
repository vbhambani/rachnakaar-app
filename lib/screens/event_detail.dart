import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/api_client.dart';
import '../api/models.dart';
import '../theme.dart';

class EventDetailScreen extends StatefulWidget {
  final int id;
  final EventItem fallback;
  const EventDetailScreen({super.key, required this.id, required this.fallback});
  @override
  State<EventDetailScreen> createState() => _EventDetailScreenState();
}

class _EventDetailScreenState extends State<EventDetailScreen> {
  late Future<EventItem> _future;

  @override
  void initState() {
    super.initState();
    _future = Api.getOne('events', widget.id).then((j) => EventItem.fromJson(j));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Event')),
      body: FutureBuilder<EventItem>(
        future: _future,
        builder: (ctx, snap) {
          final e = snap.data ?? widget.fallback;
          final loading = snap.connectionState != ConnectionState.done;
          return ListView(padding: EdgeInsets.zero, children: [
            if (e.featuredImage != null)
              AspectRatio(aspectRatio: 16/9, child: CachedNetworkImage(imageUrl: e.featuredImage!, fit: BoxFit.cover))
            else
              AspectRatio(aspectRatio: 16/9, child: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [RKColors.burgundyDark, RKColors.burgundy])))),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                Row(children: [
                  if (e.type.isNotEmpty) Container(
                    padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                    decoration: BoxDecoration(color: RKColors.gold, borderRadius: BorderRadius.circular(999)),
                    child: Text(e.type.toUpperCase(), style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w800, color: RKColors.ink, letterSpacing: 0.08)),
                  ),
                ]),
                const SizedBox(height: 14),
                Text(e.title, style: Theme.of(context).textTheme.headlineMedium),
                const SizedBox(height: 12),
                Container(height: 1, color: RKColors.gold),
                const SizedBox(height: 16),
                _row('🗓️ Date',  e.displayDate),
                _row('🕐 Time',  e.time),
                _row('📍 Venue', e.venue),
                const SizedBox(height: 16),
                if (loading)
                  const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator(color: RKColors.burgundy)))
                else if (e.content.isNotEmpty)
                  Text(_strip(e.content), style: const TextStyle(fontSize: 15, height: 1.7, color: RKColors.text))
                else if (e.excerpt.isNotEmpty)
                  Text(e.excerpt, style: const TextStyle(fontSize: 15, height: 1.7, color: RKColors.text)),
                const SizedBox(height: 24),
                if (e.registerUrl.isNotEmpty)
                  SizedBox(width: double.infinity, child: ElevatedButton.icon(
                    onPressed: () {
                      var u = e.registerUrl;
                      if (u.startsWith('/')) u = 'https://rachnakaar.com$u';
                      launchUrl(Uri.parse(u), mode: LaunchMode.externalApplication);
                    },
                    icon: const Icon(Icons.event_available),
                    label: const Text('RSVP / Register'),
                  )),
              ]),
            ),
          ]);
        },
      ),
    );
  }

  Widget _row(String label, String val) => val.isEmpty ? const SizedBox.shrink() : Padding(
    padding: const EdgeInsets.only(bottom: 8),
    child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
      SizedBox(width: 100, child: Text(label, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: RKColors.muted, letterSpacing: 0.06))),
      Expanded(child: Text(val, style: const TextStyle(fontSize: 14, color: RKColors.ink, fontWeight: FontWeight.w500))),
    ]),
  );

  String _strip(String html) => html
    .replaceAll(RegExp(r'<br\s*/?>'), '\n')
    .replaceAll(RegExp(r'</p\s*>'), '\n\n')
    .replaceAll(RegExp(r'<[^>]*>'), '')
    .replaceAll(RegExp(r'\n{3,}'), '\n\n')
    .trim();
}
