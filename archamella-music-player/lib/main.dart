import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:permission_handler/permission_handler.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ArchamellaPlayerApp());
}

class ArchamellaPlayerApp extends StatelessWidget {
  const ArchamellaPlayerApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Archamella Player',
      theme: ThemeData.dark(useMaterial3: true).copyWith(
        scaffoldBackgroundColor: const Color(0xFF05070D),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF00D5FF),
          secondary: Color(0xFFFF9F1C),
          surface: Color(0xFF101522),
        ),
      ),
      home: const MusicHomePage(),
    );
  }
}

class MusicHomePage extends StatefulWidget {
  const MusicHomePage({super.key});

  @override
  State<MusicHomePage> createState() => _MusicHomePageState();
}

class _MusicHomePageState extends State<MusicHomePage> {
  final OnAudioQuery audioQuery = OnAudioQuery();
  final AudioPlayer player = AudioPlayer();
  final TextEditingController searchController = TextEditingController();

  List<SongModel> songs = [];
  List<SongModel> filteredSongs = [];
  SongModel? currentSong;
  bool loading = true;
  bool hasPermission = false;
  int currentIndex = -1;

  @override
  void initState() {
    super.initState();
    loadSongs();
    player.playerStateStream.listen((_) {
      if (mounted) setState(() {});
    });
  }

  Future<void> loadSongs() async {
    final permission = await Permission.audio.request();
    final storage = await Permission.storage.request();
    final granted = permission.isGranted || storage.isGranted;

    if (!granted) {
      setState(() {
        loading = false;
        hasPermission = false;
      });
      return;
    }

    final result = await audioQuery.querySongs(
      sortType: SongSortType.TITLE,
      orderType: OrderType.ASC_OR_SMALLER,
      uriType: UriType.EXTERNAL,
      ignoreCase: true,
    );

    setState(() {
      songs = result;
      filteredSongs = result;
      loading = false;
      hasPermission = true;
    });
  }

  void filterSongs(String query) {
    final q = query.toLowerCase();
    setState(() {
      filteredSongs = songs.where((song) {
        return song.title.toLowerCase().contains(q) ||
            (song.artist ?? '').toLowerCase().contains(q) ||
            (song.album ?? '').toLowerCase().contains(q);
      }).toList();
    });
  }

  Future<void> playSong(SongModel song, int index) async {
    try {
      await player.setAudioSource(AudioSource.uri(Uri.parse(song.uri!)));
      await player.play();
      setState(() {
        currentSong = song;
        currentIndex = index;
      });
    } catch (_) {
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Lagu ini tidak dapat dimainkan.')),
      );
    }
  }

  Future<void> playNext() async {
    if (filteredSongs.isEmpty) return;
    final next = (currentIndex + 1) % filteredSongs.length;
    await playSong(filteredSongs[next], next);
  }

  Future<void> playPrevious() async {
    if (filteredSongs.isEmpty) return;
    final previous = currentIndex <= 0 ? filteredSongs.length - 1 : currentIndex - 1;
    await playSong(filteredSongs[previous], previous);
  }

  @override
  void dispose() {
    player.dispose();
    searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            const HeaderPanel(),
            Padding(
              padding: const EdgeInsets.fromLTRB(16, 8, 16, 12),
              child: TextField(
                controller: searchController,
                onChanged: filterSongs,
                decoration: InputDecoration(
                  hintText: 'Search song, artist, album...',
                  prefixIcon: const Icon(Icons.search),
                  filled: true,
                  fillColor: const Color(0xFF101522),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(18),
                    borderSide: BorderSide.none,
                  ),
                ),
              ),
            ),
            Expanded(child: buildLibrary()),
            PlayerDock(
              song: currentSong,
              isPlaying: player.playing,
              onPlayPause: () => player.playing ? player.pause() : player.play(),
              onNext: playNext,
              onPrevious: playPrevious,
            ),
          ],
        ),
      ),
    );
  }

  Widget buildLibrary() {
    if (loading) {
      return const Center(child: CircularProgressIndicator());
    }

    if (!hasPermission) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              const Icon(Icons.folder_off, size: 64),
              const SizedBox(height: 16),
              const Text('Benarkan akses audio untuk scan MP3 dalam telefon.'),
              const SizedBox(height: 16),
              FilledButton(onPressed: loadSongs, child: const Text('Allow Permission')),
            ],
          ),
        ),
      );
    }

    if (filteredSongs.isEmpty) {
      return const Center(child: Text('Tiada lagu dijumpai.'));
    }

    return ListView.builder(
      padding: const EdgeInsets.fromLTRB(12, 0, 12, 12),
      itemCount: filteredSongs.length,
      itemBuilder: (context, index) {
        final song = filteredSongs[index];
        final active = currentSong?.id == song.id;
        return Card(
          color: active ? const Color(0xFF102D3D) : const Color(0xFF0C111D),
          child: ListTile(
            leading: QueryArtworkWidget(
              id: song.id,
              type: ArtworkType.AUDIO,
              nullArtworkWidget: const CircleAvatar(child: Icon(Icons.music_note)),
            ),
            title: Text(song.title, maxLines: 1, overflow: TextOverflow.ellipsis),
            subtitle: Text(song.artist ?? 'Unknown Artist', maxLines: 1),
            trailing: Icon(active ? Icons.graphic_eq : Icons.play_arrow),
            onTap: () => playSong(song, index),
          ),
        );
      },
    );
  }
}

class HeaderPanel extends StatelessWidget {
  const HeaderPanel({super.key});

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(16),
      padding: const EdgeInsets.all(18),
      decoration: BoxDecoration(
        borderRadius: BorderRadius.circular(24),
        gradient: const LinearGradient(
          colors: [Color(0xFF11182A), Color(0xFF07101B)],
        ),
        border: Border.all(color: const Color(0xFF00D5FF), width: 1),
      ),
      child: const Row(
        children: [
          Icon(Icons.equalizer, size: 36, color: Color(0xFF00D5FF)),
          SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('ARCHAMELLA PLAYER', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 20)),
                Text('Winamp-style MP3 library for Android', style: TextStyle(color: Colors.white70)),
              ],
            ),
          ),
        ],
      ),
    );
  }
}

class PlayerDock extends StatelessWidget {
  const PlayerDock({
    super.key,
    required this.song,
    required this.isPlaying,
    required this.onPlayPause,
    required this.onNext,
    required this.onPrevious,
  });

  final SongModel? song;
  final bool isPlaying;
  final VoidCallback onPlayPause;
  final VoidCallback onNext;
  final VoidCallback onPrevious;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.fromLTRB(16, 14, 16, 18),
      decoration: const BoxDecoration(
        color: Color(0xFF101522),
        border: Border(top: BorderSide(color: Color(0xFF00D5FF), width: 1)),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              mainAxisSize: MainAxisSize.min,
              children: [
                Text(song?.title ?? 'No song selected', maxLines: 1, overflow: TextOverflow.ellipsis),
                Text(song?.artist ?? 'Tap any song to play', maxLines: 1, style: const TextStyle(color: Colors.white60)),
              ],
            ),
          ),
          IconButton(onPressed: onPrevious, icon: const Icon(Icons.skip_previous)),
          FilledButton(
            onPressed: song == null ? null : onPlayPause,
            child: Icon(isPlaying ? Icons.pause : Icons.play_arrow),
          ),
          IconButton(onPressed: onNext, icon: const Icon(Icons.skip_next)),
        ],
      ),
    );
  }
}
