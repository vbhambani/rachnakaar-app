import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:url_launcher/url_launcher.dart';
import '../api/api_client.dart';
import '../api/models.dart';
import '../theme.dart';

class PressDetailScreen extends StatefulWidget {
  final int id;
  final PressItem fallback;
  const PressDetailScreen({super.key, required this.id, required this.fallback});
  @override
  State<PressDetailScreen> createState() => _PressDetailScreenState();
}

class _PressDetailScreenState extends State<PressDetailScreen> {
  late Future<PressItem> _future;

  @override
  void initState() {
    super.initState();
    _future = Api.getOne('press', widget.id).then((j) => PressItem.fromJson(j));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Press Release')),
      body: FutureBuilder<PressItem>(
        future: _future,
        builder: (ctx, snap) {
          final p = snap.data ?? widget.fallback;
          final loading = snap.connectionState != ConnectionState.done;
          return ListView(
            padding: EdgeInsets.zero,
            children: [
              if (p.featuredImage != null)
                AspectRatio(aspectRatio: 16/9, child: CachedNetworkImage(imageUrl: p.featuredImage!, fit: BoxFit.cover, errorWidget: (c,u,e) => Container(color: RKColors.champagne))),
              Padding(
                padding: const EdgeInsets.all(20),
                child: Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
                  if (p.dateLabel.isNotEmpty)
                    Text(p.dateLabel.toUpperCase(),
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: RKColors.gold, letterSpacing: 0.14)),
                  const SizedBox(height: 8),
                  Text(p.title, style: Theme.of(context).textTheme.headlineMedium),
                  const SizedBox(height: 14),
                  Container(height: 1, color: RKColors.gold),
                  const SizedBox(height: 16),
                  if (loading)
                    const Padding(padding: EdgeInsets.all(20), child: Center(child: CircularProgressIndicator(color: RKColors.burgundy)))
                  else
                    Text(_strip(p.content), style: const TextStyle(fontSize: 15, height: 1.7, color: RKColors.text)),
                  const SizedBox(height: 20),
                  if (p.externalUrl != null && p.externalUrl!.isNotEmpty)
                    ElevatedButton.icon(
                      onPressed: () => launchUrl(Uri.parse(p.externalUrl!), mode: LaunchMode.externalApplication),
                      icon: const Icon(Icons.open_in_new),
                      label: const Text('Read full article'),
                    ),
                ]),
              ),
            ],
          );
        },
      ),
    );
  }

  String _strip(String html) =>
    html.replaceAll(RegExp(r'<br\s*/?>'), '\n')
        .replaceAll(RegExp(r'</p\s*>'), '\n\n')
        .replaceAll(RegExp(r'<[^>]*>'), '')
        .replaceAll(RegExp(r'\n{3,}'), '\n\n')
        .trim();
}
