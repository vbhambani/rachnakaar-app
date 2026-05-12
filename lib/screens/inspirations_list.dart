import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/api_client.dart';
import '../api/models.dart';
import '../theme.dart';

class InspirationsList extends StatefulWidget {
  const InspirationsList({super.key});
  @override
  State<InspirationsList> createState() => _InspirationsListState();
}

class _InspirationsListState extends State<InspirationsList> {
  late Future<List<InspirationItem>> _future;

  @override
  void initState() { super.initState(); _reload(); }
  void _reload() {
    _future = Api.getList('inspirations', params: {'per_page': '50', '_embed': '1'})
      .then((l) => l.map((e) => InspirationItem.fromJson(e)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Literary Inspirations')),
      body: RefreshIndicator(
        onRefresh: () async { setState(_reload); },
        color: RKColors.burgundy,
        child: FutureBuilder<List<InspirationItem>>(
          future: _future,
          builder: (ctx, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator(color: RKColors.burgundy));
            }
            final items = snap.data ?? const <InspirationItem>[];
            if (items.isEmpty) {
              return Center(child: Padding(
                padding: const EdgeInsets.all(40),
                child: Column(mainAxisSize: MainAxisSize.min, children: const [
                  Text('✍️', style: TextStyle(fontSize: 48)),
                  SizedBox(height: 14),
                  Text('No creators added yet.', style: TextStyle(fontFamily: 'serif', fontSize: 18, color: RKColors.ink)),
                  SizedBox(height: 6),
                  Text('Admin can add featured creators from the dashboard.',
                    textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 13, color: RKColors.muted, fontStyle: FontStyle.italic)),
                ]),
              ));
            }
            return GridView.builder(
              padding: const EdgeInsets.all(12),
              gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
                crossAxisCount: 2, mainAxisSpacing: 12, crossAxisSpacing: 12, childAspectRatio: 0.72,
              ),
              itemCount: items.length,
              itemBuilder: (ctx, i) {
                final c = items[i];
                return Card(
                  clipBehavior: Clip.antiAlias,
                  child: InkWell(
                    onTap: () {
                      if (c.link.isNotEmpty) {
                        launchUrl(Uri.parse(c.link), mode: LaunchMode.externalApplication);
                      }
                    },
                    child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                      Expanded(
                        child: c.featuredImage != null
                          ? CachedNetworkImage(imageUrl: c.featuredImage!, fit: BoxFit.cover, errorWidget: (_, __, ___) => _placeholder(c.hindiName.isNotEmpty ? c.hindiName : c.name))
                          : _placeholder(c.hindiName.isNotEmpty ? c.hindiName : c.name),
                      ),
                      Padding(
                        padding: const EdgeInsets.fromLTRB(12, 10, 12, 12),
                        child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                          if (c.tag.isNotEmpty) Text(c.tag.toUpperCase(),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: RKColors.gold, letterSpacing: 0.1)),
                          const SizedBox(height: 4),
                          Text(c.name, maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontFamily: 'serif', fontSize: 16, fontWeight: FontWeight.w700, color: RKColors.ink, height: 1.1)),
                          if (c.hindiName.isNotEmpty) Text(c.hindiName,
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                            style: const TextStyle(fontSize: 12, color: RKColors.burgundy)),
                          if (c.era.isNotEmpty) ...[
                            const SizedBox(height: 2),
                            Text(c.era, maxLines: 1, overflow: TextOverflow.ellipsis,
                              style: const TextStyle(fontSize: 11, color: RKColors.muted, fontStyle: FontStyle.italic)),
                          ],
                        ]),
                      ),
                    ]),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }

  Widget _placeholder(String t) => Container(
    decoration: const BoxDecoration(gradient: LinearGradient(colors: [RKColors.burgundyDark, RKColors.burgundy])),
    child: Center(child: Text(
      t.isEmpty ? 'र' : t.characters.first,
      style: const TextStyle(fontFamily: 'serif', fontSize: 56, fontWeight: FontWeight.w700, color: RKColors.goldLight),
    )),
  );
}
