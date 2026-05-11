import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../api/api_client.dart';
import '../api/models.dart';
import '../theme.dart';
import 'event_detail.dart';

class EventsList extends StatefulWidget {
  const EventsList({super.key});
  @override
  State<EventsList> createState() => _EventsListState();
}

class _EventsListState extends State<EventsList> {
  late Future<List<EventItem>> _future;

  @override
  void initState() { super.initState(); _reload(); }
  void _reload() {
    _future = Api.getList('events', params: {'per_page': '30', '_embed': '1'}).then((l) => l.map((e) => EventItem.fromJson(e)).toList());
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Events & Workshops')),
      body: RefreshIndicator(
        onRefresh: () async { setState(_reload); },
        color: RKColors.burgundy,
        child: FutureBuilder<List<EventItem>>(
          future: _future,
          builder: (ctx, snap) {
            if (snap.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator(color: RKColors.burgundy));
            }
            if (snap.hasError) return Center(child: Text('Error: ${snap.error}', style: const TextStyle(color: Colors.red)));
            final items = snap.data ?? const <EventItem>[];
            if (items.isEmpty) return const Center(child: Text('No events yet.', style: TextStyle(color: RKColors.muted)));
            return ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 12),
              itemCount: items.length,
              itemBuilder: (ctx, i) {
                final e = items[i];
                return Padding(
                  padding: const EdgeInsets.fromLTRB(14, 6, 14, 6),
                  child: Card(
                    clipBehavior: Clip.antiAlias,
                    child: InkWell(
                      onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailScreen(id: e.id, fallback: e))),
                      child: Column(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
                        Stack(children: [
                          if (e.featuredImage != null)
                            AspectRatio(aspectRatio: 16/9, child: CachedNetworkImage(imageUrl: e.featuredImage!, fit: BoxFit.cover))
                          else
                            AspectRatio(aspectRatio: 16/9,
                              child: Container(decoration: const BoxDecoration(gradient: LinearGradient(colors: [RKColors.burgundyDark, RKColors.burgundy])))),
                          Positioned(left: 14, top: 14, child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(10),
                              boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.18), blurRadius: 12, offset: const Offset(0,4))]),
                            child: Column(mainAxisSize: MainAxisSize.min, children: [
                              Text(e.displayDay, style: const TextStyle(fontFamily: 'serif', fontSize: 22, fontWeight: FontWeight.w700, color: RKColors.burgundy, height: 1)),
                              const SizedBox(height: 2),
                              Text(e.displayMonth, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: RKColors.ink, letterSpacing: 0.1)),
                            ]),
                          )),
                          if (e.type.isNotEmpty) Positioned(right: 14, top: 14, child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                            decoration: BoxDecoration(color: RKColors.gold, borderRadius: BorderRadius.circular(999)),
                            child: Text(e.type.toUpperCase(), style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w800, color: RKColors.ink, letterSpacing: 0.08)),
                          )),
                        ]),
                        Padding(
                          padding: const EdgeInsets.all(16),
                          child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                            Text(e.title, style: const TextStyle(fontFamily: 'serif', fontSize: 18, fontWeight: FontWeight.w700, color: RKColors.ink, height: 1.25)),
                            const SizedBox(height: 8),
                            if (e.time.isNotEmpty) _meta('🕐', e.time),
                            if (e.venue.isNotEmpty) _meta('📍', e.venue),
                            if (e.excerpt.isNotEmpty) ...[
                              const SizedBox(height: 8),
                              Text(e.excerpt, maxLines: 2, overflow: TextOverflow.ellipsis, style: const TextStyle(fontSize: 13, color: RKColors.text, height: 1.5)),
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

  Widget _meta(String icon, String text) => Padding(
    padding: const EdgeInsets.only(top: 2, bottom: 2),
    child: Row(children: [Text(icon), const SizedBox(width: 6), Expanded(child: Text(text, style: const TextStyle(fontSize: 13, color: RKColors.text)))]),
  );
}
