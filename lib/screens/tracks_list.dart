import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/api_client.dart';
import '../api/models.dart';
import '../theme.dart';

class TracksList extends StatefulWidget {
  const TracksList({super.key});
  @override
  State<TracksList> createState() => _TracksListState();
}

class _TracksListState extends State<TracksList> {
  late Future<List<TrackItem>> _future;

  @override
  void initState() { super.initState(); _reload(); }
  void _reload() {
    _future = Api.getList('tracks', params: {'per_page': '50', '_embed': '1'})
      .then((l) => l.map((e) => TrackItem.fromJson(e)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Tracks · Music & Talks')),
      body: RefreshIndicator(
        onRefresh: () async { setState(_reload); },
        color: RKColors.burgundy,
        child: FutureBuilder<List<TrackItem>>(
          future: _future,
          builder: (ctx, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator(color: RKColors.burgundy));
            }
            final items = snap.data ?? const <TrackItem>[];
            if (items.isEmpty) return const Center(child: Text('No tracks yet.', style: TextStyle(color: RKColors.muted)));
            return ListView.builder(
              padding: const EdgeInsets.all(12),
              itemCount: items.length,
              itemBuilder: (ctx, i) {
                final t = items[i];
                final thumb = t.thumbnail;
                return Padding(
                  padding: const EdgeInsets.only(bottom: 12),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () {
                        if (t.youtubeUrl.isNotEmpty) {
                          launchUrl(Uri.parse(t.youtubeUrl), mode: LaunchMode.externalApplication);
                        }
                      },
                      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                        Stack(children: [
                          AspectRatio(aspectRatio: 16/9,
                            child: thumb != null
                              ? CachedNetworkImage(imageUrl: thumb, fit: BoxFit.cover,
                                  errorWidget: (c,u,e) => Container(color: RKColors.ink))
                              : Container(color: RKColors.ink)),
                          const Positioned.fill(child: Center(child: CircleAvatar(
                            radius: 28,
                            backgroundColor: RKColors.burgundy,
                            child: Icon(Icons.play_arrow, color: Colors.white, size: 32),
                          ))),
                        ]),
                        Padding(
                          padding: const EdgeInsets.all(14),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(t.title, style: const TextStyle(fontFamily: 'serif', fontSize: 16, fontWeight: FontWeight.w700, color: RKColors.ink, height: 1.25)),
                            if (t.artist.isNotEmpty) ...[
                              const SizedBox(height: 4),
                              Text(t.artist, style: const TextStyle(fontSize: 13, color: RKColors.muted)),
                            ],
                            const SizedBox(height: 8),
                            Wrap(spacing: 6, children: [
                              if (t.genre.isNotEmpty) _chip(t.genre),
                              if (t.language.isNotEmpty) _chip(t.language, gold: true),
                            ]),
                          ]),
                        ),
                      ]),
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _chip(String text, {bool gold = false}) => Container(
    padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
    decoration: BoxDecoration(
      color: gold ? RKColors.gold : RKColors.champagne,
      borderRadius: BorderRadius.circular(999),
    ),
    child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w600,
      color: gold ? RKColors.ink : RKColors.burgundy)),
  );
}
