import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:intl/intl.dart';
import '../api/api_client.dart';
import '../api/models.dart';
import '../theme.dart';
import 'press_detail.dart';
import 'event_detail.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});
  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  late Future<List<PressItem>> _press;
  late Future<List<EventItem>> _events;

  @override
  void initState() {
    super.initState();
    _load();
  }

  void _load() {
    _press  = Api.getList('press',  params: {'per_page': '4', '_embed': '1'}).then((l) => l.map((e) => PressItem.fromJson(e)).toList());
    _events = Api.getList('events', params: {'per_page': '3', '_embed': '1'}).then((l) => l.map((e) => EventItem.fromJson(e)).toList());
  }

  Future<void> _refresh() async { setState(_load); }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: RefreshIndicator(
        onRefresh: _refresh,
        color: RKColors.burgundy,
        child: CustomScrollView(
          slivers: [
            SliverAppBar(
              expandedHeight: 220,
              pinned: true,
              backgroundColor: RKColors.burgundy,
              foregroundColor: Colors.white,
              flexibleSpace: FlexibleSpaceBar(
                title: const Text('Rachnakaar', style: TextStyle(fontWeight: FontWeight.w700)),
                background: Container(
                  decoration: const BoxDecoration(
                    gradient: LinearGradient(
                      colors: [RKColors.burgundyDark, RKColors.burgundy],
                      begin: Alignment.topLeft, end: Alignment.bottomRight,
                    ),
                  ),
                  child: Stack(
                    children: [
                      Positioned.fill(
                        child: Opacity(
                          opacity: 0.14,
                          child: Container(
                            decoration: const BoxDecoration(
                              gradient: RadialGradient(
                                colors: [RKColors.gold, Colors.transparent],
                                center: Alignment(0.5, -0.6),
                                radius: 0.9,
                              ),
                            ),
                          ),
                        ),
                      ),
                      const Center(
                        child: Padding(
                          padding: EdgeInsets.only(bottom: 36, left: 24, right: 24, top: 60),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Text('कहानियाँ जो दिल छू जाएँ',
                                  style: TextStyle(color: RKColors.goldLight, fontSize: 16, fontWeight: FontWeight.w500),
                                  textAlign: TextAlign.center),
                              SizedBox(height: 6),
                              Text('Stories that touch the heart',
                                  style: TextStyle(color: Colors.white, fontSize: 22, fontWeight: FontWeight.w700, fontFamily: 'serif'),
                                  textAlign: TextAlign.center),
                            ],
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
            SliverList(
              delegate: SliverChildListDelegate([
                _sectionHeader('Latest News', 'समाचार'),
                FutureBuilder<List<PressItem>>(
                  future: _press,
                  builder: (ctx, snap) {
                    if (snap.connectionState != ConnectionState.done) {
                      return const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator(color: RKColors.burgundy)));
                    }
                    if (snap.hasError) return _errorBox('Could not load news: ${snap.error}');
                    final items = snap.data ?? const <PressItem>[];
                    if (items.isEmpty) return _emptyBox('No press releases yet.');
                    return Column(children: items.map((p) => _PressCard(item: p)).toList());
                  },
                ),
                const SizedBox(height: 6),
                _sectionHeader('Upcoming Events', 'आगामी कार्यक्रम'),
                FutureBuilder<List<EventItem>>(
                  future: _events,
                  builder: (ctx, snap) {
                    if (snap.connectionState != ConnectionState.done) {
                      return const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator(color: RKColors.burgundy)));
                    }
                    if (snap.hasError) return _errorBox('Could not load events: ${snap.error}');
                    final items = snap.data ?? const <EventItem>[];
                    if (items.isEmpty) return _emptyBox('No upcoming events.');
                    return Column(children: items.map((e) => _EventCard(item: e)).toList());
                  },
                ),
                const SizedBox(height: 30),
              ]),
            ),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String en, String hi) => Padding(
    padding: const EdgeInsets.fromLTRB(18, 24, 18, 12),
    child: Row(
      crossAxisAlignment: CrossAxisAlignment.baseline,
      textBaseline: TextBaseline.alphabetic,
      children: [
        Container(width: 4, height: 22, decoration: BoxDecoration(color: RKColors.burgundy, borderRadius: BorderRadius.circular(2))),
        const SizedBox(width: 10),
        Text(en, style: const TextStyle(fontFamily: 'serif', fontSize: 22, fontWeight: FontWeight.w700, color: RKColors.ink)),
        const SizedBox(width: 8),
        Text(hi, style: const TextStyle(fontSize: 14, color: RKColors.burgundy)),
      ],
    ),
  );

  Widget _errorBox(String msg) => Padding(padding: const EdgeInsets.all(20), child: Text(msg, style: const TextStyle(color: Colors.red)));
  Widget _emptyBox(String msg) => Padding(padding: const EdgeInsets.all(20), child: Text(msg, style: const TextStyle(color: RKColors.muted, fontStyle: FontStyle.italic)));
}

class _PressCard extends StatelessWidget {
  final PressItem item;
  const _PressCard({required this.item});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 10),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => PressDetailScreen(id: item.id, fallback: item))),
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              SizedBox(
                width: 100, height: 100,
                child: item.featuredImage != null
                  ? CachedNetworkImage(imageUrl: item.featuredImage!, fit: BoxFit.cover, errorWidget: (c,u,e) => _placeholder())
                  : _placeholder(),
              ),
              Expanded(
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                    if (item.dateLabel.isNotEmpty)
                      Text(item.dateLabel.toUpperCase(),
                          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: RKColors.gold, letterSpacing: 0.12)),
                    const SizedBox(height: 4),
                    Text(item.title, maxLines: 3, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontFamily: 'serif', fontSize: 15, fontWeight: FontWeight.w600, color: RKColors.ink, height: 1.3)),
                  ]),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _placeholder() => Container(
    color: RKColors.champagne,
    child: const Center(child: Text('📰', style: TextStyle(fontSize: 28))),
  );
}

class _EventCard extends StatelessWidget {
  final EventItem item;
  const _EventCard({required this.item});
  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(14, 4, 14, 10),
      child: Card(
        clipBehavior: Clip.antiAlias,
        child: InkWell(
          onTap: () => Navigator.push(context, MaterialPageRoute(builder: (_) => EventDetailScreen(id: item.id, fallback: item))),
          child: Row(crossAxisAlignment: CrossAxisAlignment.stretch, children: [
            Container(
              width: 84,
              decoration: const BoxDecoration(gradient: LinearGradient(colors: [RKColors.burgundyDark, RKColors.burgundy])),
              child: Center(
                child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
                  Text(item.displayDay, style: const TextStyle(fontFamily: 'serif', fontSize: 28, fontWeight: FontWeight.w700, color: RKColors.goldLight, height: 1)),
                  const SizedBox(height: 2),
                  Text(item.displayMonth, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: Colors.white, letterSpacing: 0.1)),
                ]),
              ),
            ),
            Expanded(
              child: Padding(
                padding: const EdgeInsets.all(14),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, mainAxisAlignment: MainAxisAlignment.center, children: [
                  if (item.type.isNotEmpty)
                    Container(padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                      decoration: BoxDecoration(color: RKColors.gold, borderRadius: BorderRadius.circular(999)),
                      child: Text(item.type.toUpperCase(), style: const TextStyle(fontSize: 9, fontWeight: FontWeight.w800, color: RKColors.ink, letterSpacing: 0.1))),
                  const SizedBox(height: 6),
                  Text(item.title, maxLines: 2, overflow: TextOverflow.ellipsis,
                      style: const TextStyle(fontFamily: 'serif', fontSize: 15, fontWeight: FontWeight.w600, color: RKColors.ink, height: 1.3)),
                  if (item.venue.isNotEmpty) ...[
                    const SizedBox(height: 4),
                    Text('📍 ${item.venue}', maxLines: 1, overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: RKColors.muted)),
                  ],
                ]),
              ),
            ),
          ]),
        ),
      ),
    );
  }
}
