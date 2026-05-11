import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../api/api_client.dart';
import '../api/models.dart';
import '../theme.dart';
import 'press_detail.dart';

class PressList extends StatefulWidget {
  const PressList({super.key});
  @override
  State<PressList> createState() => _PressListState();
}

class _PressListState extends State<PressList> {
  late Future<List<PressItem>> _future;

  @override
  void initState() { super.initState(); _reload(); }
  void _reload() {
    _future = Api.getList('press', params: {'per_page': '30', '_embed': '1'}).then((l) => l.map((e) => PressItem.fromJson(e)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Press & News')),
      body: RefreshIndicator(
        onRefresh: () async { setState(_reload); },
        color: RKColors.burgundy,
        child: FutureBuilder<List<PressItem>>(
          future: _future,
          builder: (ctx, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator(color: RKColors.burgundy));
            }
            if (snap.hasError) return Center(child: Text('Error: ${snap.error}', style: const TextStyle(color: Colors.red)));
            final items = snap.data ?? const <PressItem>[];
            if (items.isEmpty) return const Center(child: Text('No press releases yet.', style: TextStyle(color: RKColors.muted)));
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: items.length,
              itemBuilder: (ctx, i) {
                final p = items[i];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PressDetailScreen(id: p.id, fallback: p))),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                        if (p.featuredImage != null)
                          AspectRatio(
                            aspectRatio: 16/9,
                            child: CachedNetworkImage(imageUrl: p.featuredImage!, fit: BoxFit.cover, errorWidget: (c,u,e) => Container(color: RKColors.champagne)),
                          ),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            if (p.dateLabel.isNotEmpty)
                              Text(p.dateLabel.toUpperCase(),
                                style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: RKColors.gold, letterSpacing: 0.12)),
                            const SizedBox(height: 6),
                            Text(p.title, style: const TextStyle(fontFamily: 'serif', fontSize: 18, fontWeight: FontWeight.w700, color: RKColors.ink, height: 1.25)),
                            if (p.excerpt.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(p.excerpt, maxLines: 3, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13.5, color: RKColors.text, height: 1.5)),
                            ],
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
}
