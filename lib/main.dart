import 'package:flutter/material.dart';
import 'theme.dart';
import 'screens/home_screen.dart';
import 'screens/press_list.dart';
import 'screens/events_list.dart';
import 'screens/inspirations_list.dart';
import 'screens/tracks_list.dart';

void main() => runApp(const RachnakaarApp());

class RachnakaarApp extends StatelessWidget {
  const RachnakaarApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Rachnakaar',
      theme: buildRachnakaarTheme(),
      debugShowCheckedModeBanner: false,
      home: const RootShell(),
    );
  }
}

class RootShell extends StatefulWidget {
  const RootShell({super.key});

  @override
  State<RootShell> createState() => _RootShellState();
}

class _RootShellState extends State<RootShell> {
  int _idx = 0;

  final _pages = const [
    HomeScreen(),
    PressList(),
    EventsList(),
    InspirationsList(),
    TracksList(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: _pages[_idx],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _idx,
        onTap: (i) => setState(() => _idx = i),
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.home_outlined),       activeIcon: Icon(Icons.home),       label: 'Home'),
          BottomNavigationBarItem(icon: Icon(Icons.article_outlined),    activeIcon: Icon(Icons.article),    label: 'News'),
          BottomNavigationBarItem(icon: Icon(Icons.event_outlined),      activeIcon: Icon(Icons.event),      label: 'Events'),
          BottomNavigationBarItem(icon: Icon(Icons.menu_book_outlined),  activeIcon: Icon(Icons.menu_book),  label: 'Creators'),
          BottomNavigationBarItem(icon: Icon(Icons.music_note_outlined), activeIcon: Icon(Icons.music_note), label: 'Tracks'),
        ],
      ),
    );
  }
}
