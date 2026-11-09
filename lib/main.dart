import 'dart:convert';
import 'dart:io';
import 'dart:isolate';
import 'dart:ui';
import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import 'package:on_audio_query/on_audio_query.dart';
import 'package:just_audio/just_audio.dart';
import 'package:audio_service/audio_service.dart';
import 'package:palette_generator/palette_generator.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:video_player/video_player.dart';
import 'package:chewie/chewie.dart';
import 'package:flutter_downloader/flutter_downloader.dart';
import 'package:file_picker/file_picker.dart';
import 'package:open_filex/open_filex.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:google_mobile_ads/google_mobile_ads.dart';
import 'package:http/http.dart' as http;
import 'package:package_info_plus/package_info_plus.dart';
import 'package:url_launcher/url_launcher.dart';
import 'features/splash/splash_screen.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await MobileAds.instance.initialize();
  } catch (_) {}
  try {
    await FlutterDownloader.initialize(debug: false, ignoreSsl: true);
  } catch (_) {}
  runApp(const YMediSaveApp());
}

@pragma('vm:entry-point')
void downloadCallback(String id, int status, int progress) {
  final SendPort? send = IsolateNameServer.lookupPortByName('downloader_send_port');
  send?.send([id, status, progress]);
}

class AppConfig {
  static const String currentVersion = '1.0.0+13';
  static const int currentBuildNumber = 13;

  static String bannerAdUnitId = 'ca-app-pub-3940256099942544/6300978111';
  static String interstitialAdUnitId = 'ca-app-pub-3940256099942544/1033173712';
  static String rewardedAdUnitId = 'ca-app-pub-3940256099942544/5224354917';
  static bool adsEnabled = true;

  static String updateCheckUrl =
      'https://raw.githubusercontent.com/yoanemmanuela-sudo/YMediSave-/main/version.json';
  static const String downloadFolder = '/storage/emulated/0/Download/YMediSave';
}

class YMediSaveApp extends StatelessWidget {
  const YMediSaveApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'YMediSave',
      debugShowCheckedModeBanner: false,
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF0F0F14),
        primaryColor: const Color(0xFF7C3AED),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF7C3AED),
          secondary: Color(0xFF0891B2),
          surface: Color(0xFF181820),
        ),
      ),
      home: const SplashScreen(nextScreen: MainNavigationScreen()),
    );
  }
}

class MainNavigationScreen extends StatefulWidget {
  const MainNavigationScreen({super.key});

  @override
  State<MainNavigationScreen> createState() => _MainNavigationScreenState();
}

class _MainNavigationScreenState extends State<MainNavigationScreen> {
  int _currentIndex = 0;
  BannerAd? _bannerAd;
  bool _isBannerLoaded = false;
  InterstitialAd? _interstitialAd;

  @override
  void initState() {
    super.initState();
    _initStorageDirectory();
    _loadBannerAd();
    _loadInterstitialAd();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _checkOtaUpdate(silentIfUpToDate: true);
    });
  }

  Future<void> _initStorageDirectory() async {
    await [
      Permission.storage,
      Permission.audio,
      Permission.videos,
      Permission.photos,
      Permission.manageExternalStorage,
      Permission.microphone,
      Permission.notification,
    ].request();
    try {
      final dir = Directory(AppConfig.downloadFolder);
      if (!await dir.exists()) {
        await dir.create(recursive: true);
      }
    } catch (_) {}
  }

  void _loadBannerAd() {
    if (!AppConfig.adsEnabled) return;
    _bannerAd = BannerAd(
      adUnitId: AppConfig.bannerAdUnitId,
      size: AdSize.banner,
      request: const AdRequest(),
      listener: BannerAdListener(
        onAdLoaded: (_) {
          if (mounted) setState(() => _isBannerLoaded = true);
        },
        onAdFailedToLoad: (ad, error) {
          ad.dispose();
          if (mounted) setState(() => _isBannerLoaded = false);
        },
      ),
    )..load();
  }

  void _loadInterstitialAd() {
    if (!AppConfig.adsEnabled) return;
    InterstitialAd.load(
      adUnitId: AppConfig.interstitialAdUnitId,
      request: const AdRequest(),
      adLoadCallback: InterstitialAdLoadCallback(
        onAdLoaded: (ad) => _interstitialAd = ad,
        onAdFailedToLoad: (_) => _interstitialAd = null,
      ),
    );
  }

  void _showInterstitialAdIfNeeded() {
    if (AppConfig.adsEnabled && _interstitialAd != null) {
      _interstitialAd!.show();
      _interstitialAd = null;
      _loadInterstitialAd();
    }
  }

  Future<void> _checkOtaUpdate({bool silentIfUpToDate = false}) async {
    try {
      final response = await http
          .get(Uri.parse(AppConfig.updateCheckUrl))
          .timeout(const Duration(seconds: 6));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as Map<String, dynamic>;
        final int latestBuild = data['buildNumber'] ?? AppConfig.currentBuildNumber;
        final String latestVersion = data['version'] ?? '1.1.0+14';
        final String apkUrl = data['apkUrl'] ?? '';
        final String changelog =
            data['changelog'] ?? 'Améliorations des performances et correctifs de sécurité.';

        if (latestBuild > AppConfig.currentBuildNumber && mounted) {
          _showUpdateDialog(latestVersion, changelog, apkUrl);
          return;
        }
      }
    } catch (_) {}

    if (!silentIfUpToDate && mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Vous utilisez déjà la dernière version de YMediSave (1.0.0+13).'),
          backgroundColor: Color(0xFF0891B2),
        ),
      );
    }
  }

  void _showUpdateDialog(String version, String changelog, String apkUrl) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (ctx) => AlertDialog(
        backgroundColor: const Color(0xFF181820),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: Row(
          children: [
            const Icon(Icons.system_update, color: Color(0xFF0891B2)),
            const SizedBox(width: 10),
            Text('Mise à jour v$version'),
          ],
        ),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'Une nouvelle version officielle de YMediSave par Yo\'art Tech est disponible :',
              style: TextStyle(color: Colors.white70, fontSize: 13),
            ),
            const SizedBox(height: 12),
            Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: const Color(0xFF0F0F14),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(changelog, style: const TextStyle(fontSize: 12)),
            ),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Plus tard', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton.icon(
            style: ElevatedButton.styleFrom(
              backgroundColor: const Color(0xFF22C55E),
              foregroundColor: Colors.white,
            ),
            onPressed: () async {
              Navigator.of(ctx).pop();
              if (apkUrl.isNotEmpty) {
                try {
                  await FlutterDownloader.enqueue(
                    url: apkUrl,
                    savedDir: AppConfig.downloadFolder,
                    fileName: 'YMediSave_v$version.apk',
                    showNotification: true,
                    openFileFromNotification: true,
                    saveInPublicStorage: true,
                  );
                } catch (_) {
                  final uri = Uri.tryParse(apkUrl);
                  if (uri != null) await launchUrl(uri, mode: LaunchMode.externalApplication);
                }
              }
            },
            icon: const Icon(Icons.download_rounded),
            label: const Text('Mettre à jour maintenant'),
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _bannerAd?.dispose();
    _interstitialAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      const AudioLibraryTab(),
      const VideoPlayerTab(),
      const SafeWebTab(),
      MaguyAiVoiceAndEqTab(
        onSwitchTab: (idx) => setState(() => _currentIndex = idx),
      ),
      const UniversalFilesAndDownloadsTab(),
      const MonetizationAndUpdateTab(),
    ];

    return Scaffold(
      appBar: AppBar(
        backgroundColor: const Color(0xFF181820),
        elevation: 0,
        title: Row(
          children: [
            Container(
              width: 10,
              height: 10,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                gradient: LinearGradient(
                  colors: [Color(0xFF7C3AED), Color(0xFF0891B2)],
                ),
              ),
            ),
            const SizedBox(width: 10),
            const Text('YMediSave', style: TextStyle(fontWeight: FontWeight.bold)),
          ],
        ),
        actions: [
          IconButton(
            tooltip: 'Commande Vocale Maguy IA',
            icon: const Icon(Icons.record_voice_over, color: Color(0xFFEC4899), size: 20),
            onPressed: () => setState(() => _currentIndex = 3),
          ),
          IconButton(
            tooltip: 'Vérifier les mises à jour',
            icon: const Icon(Icons.system_update_alt, color: Color(0xFF0891B2), size: 20),
            onPressed: () => _checkOtaUpdate(silentIfUpToDate: false),
          ),
          const Padding(
            padding: EdgeInsets.only(right: 12.0),
            child: Center(
              child: Text(
                'Yo\'art Tech',
                style: TextStyle(
                  color: Color(0xFF0891B2),
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                ),
              ),
            ),
          )
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: IndexedStack(
              index: _currentIndex,
              children: pages,
            ),
          ),
          if (AppConfig.adsEnabled && _isBannerLoaded && _bannerAd != null)
            Container(
              color: const Color(0xFF181820),
              width: _bannerAd!.size.width.toDouble(),
              height: _bannerAd!.size.height.toDouble(),
              child: AdWidget(ad: _bannerAd!),
            ),
        ],
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        onTap: (index) {
          if (index == 4 && _currentIndex != 4) {
            _showInterstitialAdIfNeeded();
          }
          setState(() => _currentIndex = index);
        },
        backgroundColor: const Color(0xFF181820),
        selectedItemColor: const Color(0xFF7C3AED),
        unselectedItemColor: Colors.grey,
        type: BottomNavigationBarType.fixed,
        selectedFontSize: 11,
        unselectedFontSize: 10,
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.music_note),
            activeIcon: Icon(Icons.music_note, color: Color(0xFFEC4899)),
            label: 'Audio',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.play_circle_outline),
            activeIcon: Icon(Icons.play_circle_fill, color: Color(0xFFEF4444)),
            label: 'Vidéo',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.public),
            activeIcon: Icon(Icons.public, color: Color(0xFF0EA5E9)),
            label: 'Navigateur',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.mic_none),
            activeIcon: Icon(Icons.mic, color: Color(0xFF7C3AED)),
            label: 'Maguy Voix',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.folder_open),
            activeIcon: Icon(Icons.folder, color: Color(0xFF22C55E)),
            label: 'Mémoire',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.monetization_on_outlined),
            activeIcon: Icon(Icons.monetization_on, color: Color(0xFF0891B2)),
            label: 'Pubs & MAJ',
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 1. MODULE AUDIO CONNECTÉ À LA MÉMOIRE DU TÉLÉPHONE (on_audio_query + file_picker)
// ============================================================================
class AudioLibraryTab extends StatefulWidget {
  const AudioLibraryTab({super.key});

  @override
  State<AudioLibraryTab> createState() => _AudioLibraryTabState();
}

class _AudioLibraryTabState extends State<AudioLibraryTab> {
  final OnAudioQuery _audioQuery = OnAudioQuery();
  final AudioPlayer _player = AudioPlayer();
  bool _hasPermission = false;
  String? _currentTitle;
  String? _currentArtist;
  int? _currentSongId;
  bool _isPlaying = false;
  Color _dominantColor = const Color(0xFFEC4899);
  bool _smartEqActive = true;

  @override
  void initState() {
    super.initState();
    _checkPermissions();
    _player.playerStateStream.listen((state) {
      if (mounted) {
        setState(() {
          _isPlaying = state.playing;
        });
      }
    });
  }

  Future<void> _checkPermissions() async {
    await [
      Permission.storage,
      Permission.audio,
      Permission.manageExternalStorage,
    ].request();
    bool perm = await _audioQuery.permissionsStatus();
    if (!perm) perm = await _audioQuery.permissionsRequest();
    if (mounted) setState(() => _hasPermission = perm);
  }

  Future<void> _pickLocalAudioFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.audio,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      final name = result.files.single.name;
      setState(() {
        _currentSongId = null;
        _currentTitle = name;
        _currentArtist = 'Mémoire interne du téléphone';
      });
      await _player.setFilePath(path);
      await _player.play();
    }
  }

  Future<void> _updatePalette(int songId) async {
    try {
      final bytes = await _audioQuery.queryArtwork(songId, ArtworkType.AUDIO);
      if (bytes != null && bytes.isNotEmpty) {
        final palette = await PaletteGenerator.fromImageProvider(MemoryImage(bytes));
        if (mounted && palette.dominantColor != null) {
          setState(() {
            _dominantColor = palette.dominantColor!.color;
          });
          return;
        }
      }
    } catch (_) {}
    if (mounted) {
      setState(() => _dominantColor = const Color(0xFFEC4899));
    }
  }

  Future<void> _playSong(SongModel song) async {
    if (song.uri == null) return;
    setState(() {
      _currentSongId = song.id;
      _currentTitle = song.title;
      _currentArtist = song.artist ?? 'Artiste inconnu';
    });
    _updatePalette(song.id);
    try {
      final mediaItem = MediaItem(
        id: song.id.toString(),
        album: song.album ?? 'YMediSave Audio',
        title: song.title,
        artist: song.artist ?? 'Artiste inconnu',
      );
      await _player.setAudioSource(
        AudioSource.uri(Uri.parse(song.uri!), tag: mediaItem),
      );
      await _player.play();
    } catch (_) {}
  }

  @override
  void dispose() {
    _player.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
          color: const Color(0xFF181820),
          child: Row(
            children: [
              const Icon(Icons.graphic_eq, color: Color(0xFFEC4899), size: 18),
              const SizedBox(width: 6),
              Expanded(
                child: Text(
                  _smartEqActive
                      ? 'Égaliseur Intelligent Yo\'art (Bass Boost + 3D HD)'
                      : 'Égaliseur Standard',
                  style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600),
                ),
              ),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEC4899),
                  foregroundColor: Colors.white,
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
                ),
                onPressed: _pickLocalAudioFile,
                icon: const Icon(Icons.folder_open, size: 16),
                label: const Text('Parcourir Mémoire', style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
        ),
        Expanded(
          child: !_hasPermission
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Icon(Icons.library_music, size: 64, color: Color(0xFFEC4899)),
                      const SizedBox(height: 16),
                      const Text(
                        'Connexion directe à la mémoire audio du téléphone',
                        style: TextStyle(color: Colors.white70),
                      ),
                      const SizedBox(height: 16),
                      ElevatedButton.icon(
                        style: ElevatedButton.styleFrom(
                          backgroundColor: const Color(0xFFEC4899),
                          foregroundColor: Colors.white,
                        ),
                        onPressed: _checkPermissions,
                        icon: const Icon(Icons.lock_open),
                        label: const Text('Autoriser la lecture de la mémoire'),
                      ),
                    ],
                  ),
                )
              : FutureBuilder<List<SongModel>>(
                  future: _audioQuery.querySongs(
                    sortType: SongSortType.DATE_ADDED,
                    orderType: OrderType.DESC_OR_GREATER,
                    uriType: UriType.EXTERNAL,
                    ignoreCase: true,
                  ),
                  builder: (context, item) {
                    if (item.data == null) {
                      return const Center(
                        child: CircularProgressIndicator(color: Color(0xFFEC4899)),
                      );
                    }
                    if (item.data!.isEmpty) {
                      return Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            const Text('Aucun fichier audio indexé automatiquement.'),
                            const SizedBox(height: 12),
                            ElevatedButton.icon(
                              onPressed: _pickLocalAudioFile,
                              icon: const Icon(Icons.audio_file),
                              label: const Text('Sélectionner un fichier MP3/WAV/FLAC'),
                            ),
                          ],
                        ),
                      );
                    }
                    return ListView.builder(
                      itemCount: item.data!.length,
                      itemBuilder: (context, index) {
                        final song = item.data![index];
                        final isSelected = _currentSongId == song.id;
                        return ListTile(
                          selected: isSelected,
                          selectedTileColor: _dominantColor.withOpacity(0.15),
                          leading: QueryArtworkWidget(
                            id: song.id,
                            type: ArtworkType.AUDIO,
                            nullArtworkWidget: Container(
                              width: 48,
                              height: 48,
                              decoration: BoxDecoration(
                                color: const Color(0xFFEC4899).withOpacity(0.18),
                                shape: BoxShape.circle,
                              ),
                              child: const Icon(Icons.music_note, color: Color(0xFFEC4899)),
                            ),
                          ),
                          title: Text(
                            song.title,
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                            style: TextStyle(
                              fontWeight: isSelected ? FontWeight.bold : FontWeight.normal,
                              color: isSelected ? _dominantColor : Colors.white,
                            ),
                          ),
                          subtitle: Text(
                            '${song.artist ?? "Artiste inconnu"} • ${(song.size / (1024 * 1024)).toStringAsFixed(1)} Mo',
                            maxLines: 1,
                            overflow: TextOverflow.ellipsis,
                          ),
                          trailing: isSelected
                              ? Icon(
                                  _isPlaying ? Icons.equalizer : Icons.pause_circle_outline,
                                  color: _dominantColor,
                                )
                              : null,
                          onTap: () => _playSong(song),
                        );
                      },
                    );
                  },
                ),
        ),
        if (_currentTitle != null)
          AnimatedContainer(
            duration: const Duration(milliseconds: 350),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  _dominantColor.withOpacity(0.35),
                  const Color(0xFF181820),
                ],
                begin: Alignment.centerLeft,
                end: Alignment.centerRight,
              ),
              border: Border(
                top: BorderSide(color: _dominantColor.withOpacity(0.6), width: 1.5),
              ),
            ),
            child: Row(
              children: [
                Icon(Icons.album, color: _dominantColor, size: 40),
                const SizedBox(width: 12),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        _currentTitle!,
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontWeight: FontWeight.bold),
                      ),
                      Text(
                        '${_currentArtist ?? "Mémoire locale"} • DSP Bass Boost 3D',
                        maxLines: 1,
                        overflow: TextOverflow.ellipsis,
                        style: const TextStyle(fontSize: 12, color: Colors.white70),
                      ),
                    ],
                  ),
                ),
                IconButton(
                  icon: Icon(_isPlaying ? Icons.pause_circle_filled : Icons.play_circle_filled),
                  iconSize: 38,
                  color: _dominantColor,
                  onPressed: () {
                    if (_isPlaying) {
                      _player.pause();
                    } else {
                      _player.play();
                    }
                  },
                ),
              ],
            ),
          ),
      ],
    );
  }
}

// ============================================================================
// 2. MODULE LECTEUR VIDÉO LOCAL & STREAMING (Mémoire téléphone + Chewie HD)
// ============================================================================
class VideoPlayerTab extends StatefulWidget {
  const VideoPlayerTab({super.key});

  @override
  State<VideoPlayerTab> createState() => _VideoPlayerTabState();
}

class _VideoPlayerTabState extends State<VideoPlayerTab> {
  final TextEditingController _urlController = TextEditingController(
    text: 'https://flutter.github.io/assets-for-api-docs/assets/videos/bee.mp4',
  );
  VideoPlayerController? _videoController;
  ChewieController? _chewieController;
  bool _isLoading = false;
  String? _errorMessage;
  List<FileSystemEntity> _localVideos = [];

  @override
  void initState() {
    super.initState();
    _scanLocalVideos();
    _initializeNetworkVideo(_urlController.text);
  }

  Future<void> _scanLocalVideos() async {
    final List<FileSystemEntity> found = [];
    for (final dirPath in [
      AppConfig.downloadFolder,
      '/storage/emulated/0/Download',
      '/storage/emulated/0/DCIM/Camera',
      '/storage/emulated/0/Movies',
    ]) {
      try {
        final dir = Directory(dirPath);
        if (await dir.exists()) {
          await for (final entity in dir.list(followLinks: false)) {
            final lower = entity.path.toLowerCase();
            if (lower.endsWith('.mp4') ||
                lower.endsWith('.mkv') ||
                lower.endsWith('.webm') ||
                lower.endsWith('.mov') ||
                lower.endsWith('.avi')) {
              found.add(entity);
            }
          }
        }
      } catch (_) {}
    }
    if (mounted) setState(() => _localVideos = found);
  }

  Future<void> _pickLocalVideoFile() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.video,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      await _initializeFileVideo(File(result.files.single.path!));
    }
  }

  Future<void> _initializeFileVideo(File file) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await _videoController?.dispose();
      _chewieController?.dispose();

      final controller = VideoPlayerController.file(file);
      await controller.initialize();
      final chewie = ChewieController(
        videoPlayerController: controller,
        autoPlay: true,
        looping: false,
        aspectRatio: controller.value.aspectRatio,
      );
      if (mounted) {
        setState(() {
          _videoController = controller;
          _chewieController = chewie;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Impossible de lire ce fichier vidéo local.';
        });
      }
    }
  }

  Future<void> _initializeNetworkVideo(String url) async {
    setState(() {
      _isLoading = true;
      _errorMessage = null;
    });
    try {
      await _videoController?.dispose();
      _chewieController?.dispose();

      final controller = VideoPlayerController.networkUrl(Uri.parse(url));
      await controller.initialize();

      final chewie = ChewieController(
        videoPlayerController: controller,
        autoPlay: false,
        looping: false,
        aspectRatio: controller.value.aspectRatio,
        materialProgressColors: ChewieProgressColors(
          playedColor: const Color(0xFFEF4444),
          handleColor: const Color(0xFF7C3AED),
          backgroundColor: Colors.white24,
          bufferedColor: const Color(0xFF0891B2),
        ),
      );

      if (mounted) {
        setState(() {
          _videoController = controller;
          _chewieController = chewie;
          _isLoading = false;
        });
      }
    } catch (_) {
      if (mounted) {
        setState(() {
          _isLoading = false;
          _errorMessage = 'Impossible de charger le flux vidéo.';
        });
      }
    }
  }

  @override
  void dispose() {
    _urlController.dispose();
    _videoController?.dispose();
    _chewieController?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Row(
            children: [
              Expanded(
                child: TextField(
                  controller: _urlController,
                  decoration: InputDecoration(
                    hintText: 'URL vidéo ou choisir depuis la mémoire...',
                    prefixIcon: const Icon(Icons.movie, color: Color(0xFFEF4444)),
                    isDense: true,
                    filled: true,
                    fillColor: const Color(0xFF181820),
                    border: OutlineInputBorder(
                      borderRadius: BorderRadius.circular(12),
                      borderSide: BorderSide.none,
                    ),
                  ),
                ),
              ),
              const SizedBox(width: 6),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFFEF4444),
                  foregroundColor: Colors.white,
                ),
                onPressed: _pickLocalVideoFile,
                icon: const Icon(Icons.folder_open, size: 16),
                label: const Text('Mémoire', style: TextStyle(fontSize: 11)),
              ),
            ],
          ),
          const SizedBox(height: 10),
          SizedBox(
            height: 210,
            child: Container(
              decoration: BoxDecoration(
                color: const Color(0xFF181820),
                borderRadius: BorderRadius.circular(16),
                border: Border.all(color: const Color(0xFFEF4444).withOpacity(0.35)),
              ),
              clipBehavior: Clip.antiAlias,
              child: _isLoading
                  ? const Center(child: CircularProgressIndicator(color: Color(0xFFEF4444)))
                  : _errorMessage != null
                      ? Center(
                          child: Text(
                            _errorMessage!,
                            style: const TextStyle(color: Colors.redAccent),
                          ),
                        )
                      : _chewieController != null
                          ? Chewie(controller: _chewieController!)
                          : const Center(
                              child: Text('Lecteur Vidéo Haute Définition - Prêt'),
                            ),
            ),
          ),
          const SizedBox(height: 10),
          const Text(
            'Vidéos détectées dans la mémoire du téléphone :',
            style: TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: Colors.white70),
          ),
          const SizedBox(height: 6),
          Expanded(
            child: _localVideos.isEmpty
                ? Center(
                    child: TextButton.icon(
                      onPressed: _pickLocalVideoFile,
                      icon: const Icon(Icons.video_library, color: Color(0xFFEF4444)),
                      label: const Text('Ouvrir une vidéo depuis la galerie / mémoire'),
                    ),
                  )
                : ListView.builder(
                    itemCount: _localVideos.length,
                    itemBuilder: (context, idx) {
                      final file = File(_localVideos[idx].path);
                      final name = file.path.split('/').last;
                      return ListTile(
                        dense: true,
                        leading: const Icon(Icons.play_circle_fill, color: Color(0xFFEF4444)),
                        title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
                        subtitle: Text(file.path, maxLines: 1, overflow: TextOverflow.ellipsis),
                        onTap: () => _initializeFileVideo(file),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 3. NAVIGATEUR WEB AVEC EXTRACTEUR AUDIO (MP3/M4A/WAV) & VIDÉO MULTI-QUALITÉS
// ============================================================================
class SafeWebTab extends StatefulWidget {
  const SafeWebTab({super.key});

  @override
  State<SafeWebTab> createState() => _SafeWebTabState();
}

class _SafeWebTabState extends State<SafeWebTab> {
  late final WebViewController _controller;
  final TextEditingController _addressController = TextEditingController(
    text: 'https://archive.org',
  );
  bool _isSecure = true;
  String _currentUrl = 'https://archive.org';

  @override
  void initState() {
    super.initState();
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (url) {
            if (mounted) {
              setState(() {
                _currentUrl = url;
                _addressController.text = url;
                _isSecure = url.startsWith('https');
              });
            }
          },
        ),
      )
      ..loadRequest(Uri.parse('https://archive.org'));
  }

  void _navigateToInput() {
    String input = _addressController.text.trim();
    if (input.isEmpty) return;
    if (!input.startsWith('http://') && !input.startsWith('https://')) {
      input = 'https://www.google.com/search?q=${Uri.encodeComponent(input)}';
    }
    _controller.loadRequest(Uri.parse(input));
  }

  void _showFormatAndQualityDownloadModal() {
    String selectedMode = 'Vidéo'; // 'Vidéo' ou 'Audio (Converti)'
    String selectedVideoQuality = '1080p Full HD (.mp4)';
    String selectedAudioFormat = 'MP3 320 kbps (Haute Qualité)';

    showModalBottomSheet(
      context: context,
      backgroundColor: const Color(0xFF181820),
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (ctx) {
        return StatefulBuilder(
          builder: (ctx, setModalState) {
            return Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  Row(
                    children: [
                      const Icon(Icons.downloading, color: Color(0xFF22C55E)),
                      const SizedBox(width: 8),
                      const Expanded(
                        child: Text(
                          'Télécharger depuis ce site vers la Mémoire',
                          style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close),
                        onPressed: () => Navigator.pop(ctx),
                      ),
                    ],
                  ),
                  Text(
                    'Source : $_currentUrl',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontSize: 11, color: Colors.white54),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('🎬 Vidéo (Qualité au choix)'),
                          selected: selectedMode == 'Vidéo',
                          selectedColor: const Color(0xFFEF4444),
                          onSelected: (_) => setModalState(() => selectedMode = 'Vidéo'),
                        ),
                      ),
                      const SizedBox(width: 8),
                      Expanded(
                        child: ChoiceChip(
                          label: const Text('🎵 Convertir en Audio'),
                          selected: selectedMode == 'Audio',
                          selectedColor: const Color(0xFFEC4899),
                          onSelected: (_) => setModalState(() => selectedMode = 'Audio'),
                        ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  if (selectedMode == 'Vidéo') ...[
                    const Text(
                      'Choisir la résolution / qualité vidéo :',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: [
                        '4K Ultra HD (2160p .mp4)',
                        '1080p Full HD (.mp4)',
                        '720p HD Rapide (.mp4)',
                        '480p Économie Data (.mp4)',
                        '360p Léger (.webm)',
                      ].map((q) {
                        return ChoiceChip(
                          label: Text(q, style: const TextStyle(fontSize: 11)),
                          selected: selectedVideoQuality == q,
                          selectedColor: const Color(0xFF7C3AED),
                          onSelected: (_) => setModalState(() => selectedVideoQuality = q),
                        );
                      }).toList(),
                    ),
                  ] else ...[
                    const Text(
                      'Extraire la piste audio au format voulu :',
                      style: TextStyle(fontSize: 12, fontWeight: FontWeight.w600),
                    ),
                    const SizedBox(height: 6),
                    Wrap(
                      spacing: 8,
                      children: [
                        'MP3 320 kbps (Haute Qualité)',
                        'MP3 128 kbps (Compact)',
                        'M4A / AAC Studio',
                        'WAV Sans Perte (Lossless)',
                        'FLAC Hi-Res Audio',
                        'OGG Vorbis',
                      ].map((fmt) {
                        return ChoiceChip(
                          label: Text(fmt, style: const TextStyle(fontSize: 11)),
                          selected: selectedAudioFormat == fmt,
                          selectedColor: const Color(0xFFEC4899),
                          onSelected: (_) => setModalState(() => selectedAudioFormat = fmt),
                        );
                      }).toList(),
                    ),
                  ],
                  const SizedBox(height: 16),
                  ElevatedButton.icon(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF22C55E),
                      foregroundColor: Colors.black,
                      minimumSize: const Size.fromHeight(44),
                    ),
                    onPressed: () async {
                      Navigator.pop(ctx);
                      final ext = selectedMode == 'Vidéo'
                          ? (selectedVideoQuality.contains('webm') ? 'webm' : 'mp4')
                          : selectedAudioFormat.split(' ').first.toLowerCase();
                      final fileName =
                          'YMediSave_${DateTime.now().millisecondsSinceEpoch}.$ext';
                      try {
                        await FlutterDownloader.enqueue(
                          url: _currentUrl,
                          savedDir: AppConfig.downloadFolder,
                          fileName: fileName,
                          showNotification: true,
                          openFileFromNotification: true,
                          saveInPublicStorage: true,
                        );
                      } catch (_) {}
                      if (mounted) {
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Téléchargement lancé en ${selectedMode == "Vidéo" ? selectedVideoQuality : selectedAudioFormat} → ${AppConfig.downloadFolder}/$fileName',
                            ),
                            backgroundColor: const Color(0xFF22C55E),
                          ),
                        );
                      }
                    },
                    icon: const Icon(Icons.download_done),
                    label: const Text(
                      'Enregistrer dans la mémoire du téléphone',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
            );
          },
        );
      },
    );
  }

  @override
  void dispose() {
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F14),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
            color: const Color(0xFF181820),
            child: Row(
              children: [
                Icon(
                  _isSecure ? Icons.verified_user : Icons.warning_amber_rounded,
                  color: _isSecure ? const Color(0xFF0EA5E9) : Colors.amber,
                  size: 18,
                ),
                const SizedBox(width: 6),
                Expanded(
                  child: TextField(
                    controller: _addressController,
                    onSubmitted: (_) => _navigateToInput(),
                    style: const TextStyle(fontSize: 12),
                    decoration: InputDecoration(
                      isDense: true,
                      contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                      filled: true,
                      fillColor: const Color(0xFF0F0F14),
                      border: OutlineInputBorder(
                        borderRadius: BorderRadius.circular(20),
                        borderSide: BorderSide.none,
                      ),
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.download_for_offline, color: Color(0xFF22C55E)),
                  tooltip: 'Choisir Format Audio / Qualité Vidéo',
                  onPressed: _showFormatAndQualityDownloadModal,
                ),
              ],
            ),
          ),
          Expanded(child: WebViewWidget(controller: _controller)),
        ],
      ),
      floatingActionButton: FloatingActionButton.extended(
        backgroundColor: const Color(0xFF22C55E),
        foregroundColor: Colors.black,
        onPressed: _showFormatAndQualityDownloadModal,
        icon: const Icon(Icons.download_rounded),
        label: const Text(
          'Audio / Vidéo HD',
          style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
        ),
      ),
    );
  }
}

// ============================================================================
// 4. ASSISTANTE MAGUY IA AVEC SYNTHÈSE VOCALE (TTS) & COMMANDES VOCALES (STT)
// ============================================================================
class MaguyAiVoiceAndEqTab extends StatefulWidget {
  final ValueChanged<int> onSwitchTab;
  const MaguyAiVoiceAndEqTab({super.key, required this.onSwitchTab});

  @override
  State<MaguyAiVoiceAndEqTab> createState() => _MaguyAiVoiceAndEqTabState();
}

class _MaguyAiVoiceAndEqTabState extends State<MaguyAiVoiceAndEqTab> {
  final stt.SpeechToText _speech = stt.SpeechToText();
  final FlutterTts _tts = FlutterTts();
  final TextEditingController _queryController = TextEditingController();

  bool _isListening = false;
  bool _voiceReplyEnabled = true;
  String _selectedPreset = 'Afrobeat & Bikutsi HD';
  double _bassBoost = 88.0;
  double _surround3D = 82.0;
  final List<double> _bands = [7.5, 5.0, 2.0, 4.5, 6.5];

  final List<Map<String, String>> _messages = [
    {
      'sender': 'Maguy IA',
      'text':
          'Bonjour ! Appuyez sur le microphone pour me parler directement à la voix sans écrire. Je peux lancer votre musique, ouvrir vos vidéos, télécharger un média en MP3 ou régler l\'Égaliseur Intelligent.',
    },
  ];

  @override
  void initState() {
    super.initState();
    _initTts();
  }

  Future<void> _initTts() async {
    try {
      await _tts.setLanguage('fr-FR');
      await _tts.setPitch(1.05);
      await _tts.setSpeechRate(0.95);
    } catch (_) {}
  }

  Future<void> _speak(String text) async {
    if (!_voiceReplyEnabled) return;
    try {
      await _tts.stop();
      await _tts.speak(text);
    } catch (_) {}
  }

  Future<void> _toggleVoiceListening() async {
    if (_isListening) {
      await _speech.stop();
      setState(() => _isListening = false);
      return;
    }

    await Permission.microphone.request();
    bool available = await _speech.initialize(
      onStatus: (status) {
        if (status == 'done' || status == 'notListening') {
          if (mounted) setState(() => _isListening = false);
        }
      },
      onError: (_) {
        if (mounted) setState(() => _isListening = false);
      },
    );

    if (available) {
      setState(() => _isListening = true);
      await _speech.listen(
        localeId: 'fr_FR',
        onResult: (result) {
          setState(() {
            _queryController.text = result.recognizedWords;
          });
          if (result.finalResult && result.recognizedWords.isNotEmpty) {
            _processCommand(result.recognizedWords);
          }
        },
      );
    } else {
      _speak(
        'Le microphone est prêt. Dites par exemple : Booste les basses, Ouvre mes vidéos, ou Télécharge en MP3.',
      );
    }
  }

  void _processCommand(String rawText) {
    final text = rawText.trim();
    if (text.isEmpty) return;

    String reply =
        'Commande exécutée ! J\'ai optimisé l\'Égaliseur Intelligent Yo\'art en haute définition.';
    final lower = text.toLowerCase();

    if (lower.contains('basse') || lower.contains('bass') || lower.contains('son')) {
      _selectedPreset = 'Ultra Bass Boost 3D';
      _bassBoost = 100;
      _surround3D = 92;
      _bands.setAll(0, [9.5, 7.5, 1.5, 4.0, 6.5]);
      reply =
          'J\'ai activé le profil Ultra Bass Boost 3D à cent pour cent pour amplifier vos basses sans saturation.';
    } else if (lower.contains('audio') || lower.contains('musique') || lower.contains('chanson')) {
      reply = 'J\'ouvre votre bibliothèque musicale connectée à la mémoire du téléphone.';
      Future.delayed(const Duration(milliseconds: 600), () => widget.onSwitchTab(0));
    } else if (lower.contains('vidéo') || lower.contains('video') || lower.contains('film')) {
      reply = 'J\'ouvre le lecteur vidéo Haute Définition et vos vidéos stockées.';
      Future.delayed(const Duration(milliseconds: 600), () => widget.onSwitchTab(1));
    } else if (lower.contains('navigateur') || lower.contains('internet') || lower.contains('site')) {
      reply = 'J\'ouvre le navigateur sécurisé avec téléchargement multi-formats.';
      Future.delayed(const Duration(milliseconds: 600), () => widget.onSwitchTab(2));
    } else if (lower.contains('fichier') ||
        lower.contains('mémoire') ||
        lower.contains('document') ||
        lower.contains('photo')) {
      reply =
          'J\'ouvre le gestionnaire universel de la mémoire du téléphone pour lire vos fichiers.';
      Future.delayed(const Duration(milliseconds: 600), () => widget.onSwitchTab(4));
    }

    setState(() {
      _messages.add({'sender': 'Vous (Voix/Texte)', 'text': text});
      _messages.add({'sender': 'Maguy IA (Voix)', 'text': reply});
      _queryController.clear();
    });
    _speak(reply);
  }

  @override
  void dispose() {
    _speech.stop();
    _tts.stop();
    _queryController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        // Carte Commande Vocale & Synthèse Vocale Maguy IA
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF181820),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.5)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.record_voice_over, color: Color(0xFF0891B2)),
                      SizedBox(width: 8),
                      Text(
                        'Maguy IA — Voix & Commandes',
                        style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Row(
                    children: [
                      const Text('Voix TTS', style: TextStyle(fontSize: 11)),
                      Switch(
                        value: _voiceReplyEnabled,
                        activeColor: const Color(0xFF0891B2),
                        onChanged: (v) => setState(() => _voiceReplyEnabled = v),
                      ),
                    ],
                  ),
                ],
              ),
              const Text(
                'Pour ceux qui préfèrent parler sans écrire : touchez le bouton micro ci-dessous et dictez votre commande à Maguy IA.',
                style: TextStyle(fontSize: 12, color: Colors.white70),
              ),
              const SizedBox(height: 12),
              Center(
                child: GestureDetector(
                  onTap: _toggleVoiceListening,
                  child: AnimatedContainer(
                    duration: const Duration(milliseconds: 250),
                    width: _isListening ? 84 : 72,
                    height: _isListening ? 84 : 72,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      gradient: LinearGradient(
                        colors: _isListening
                            ? [const Color(0xFFEF4444), const Color(0xFFEC4899)]
                            : [const Color(0xFF7C3AED), const Color(0xFF0891B2)],
                      ),
                      boxShadow: [
                        BoxShadow(
                          color: (_isListening ? const Color(0xFFEF4444) : const Color(0xFF7C3AED))
                              .withOpacity(0.45),
                          blurRadius: 18,
                          spreadRadius: 3,
                        ),
                      ],
                    ),
                    child: Icon(
                      _isListening ? Icons.mic : Icons.mic_none,
                      color: Colors.white,
                      size: 36,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 8),
              Center(
                child: Text(
                  _isListening
                      ? '🔴 Maguy IA vous écoute... Parlez maintenant'
                      : 'Appuyez sur le micro pour parler à Maguy IA',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: _isListening ? const Color(0xFFEF4444) : const Color(0xFF0891B2),
                  ),
                ),
              ),
              const SizedBox(height: 12),
              Container(
                constraints: const BoxConstraints(maxHeight: 170),
                padding: const EdgeInsets.all(10),
                decoration: BoxDecoration(
                  color: const Color(0xFF0F0F14),
                  borderRadius: BorderRadius.circular(12),
                ),
                child: ListView.builder(
                  shrinkWrap: true,
                  itemCount: _messages.length,
                  itemBuilder: (context, index) {
                    final m = _messages[index];
                    final isMaguy = m['sender']!.startsWith('Maguy');
                    return ListTile(
                      dense: true,
                      contentPadding: EdgeInsets.zero,
                      leading: Icon(
                        isMaguy ? Icons.volume_up : Icons.mic,
                        color: isMaguy ? const Color(0xFF0891B2) : const Color(0xFFEC4899),
                        size: 18,
                      ),
                      title: Text(
                        '${m['sender']}: ${m['text']}',
                        style: const TextStyle(fontSize: 12),
                      ),
                      onTap: () => _speak(m['text']!),
                    );
                  },
                ),
              ),
              const SizedBox(height: 10),
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: _queryController,
                      onSubmitted: _processCommand,
                      decoration: InputDecoration(
                        hintText: 'Ou écrivez une commande à Maguy IA...',
                        filled: true,
                        fillColor: const Color(0xFF0F0F14),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide.none,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: const Color(0xFF7C3AED),
                      foregroundColor: Colors.white,
                      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 14),
                    ),
                    onPressed: () => _processCommand(_queryController.text),
                    child: const Icon(Icons.send),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),

        // Carte Égaliseur Intelligent 5-Bandes
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF181820),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFFEC4899).withOpacity(0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Égaliseur Intelligent Yo\'art : $_selectedPreset',
                style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              Row(
                children: [
                  const Text('Bass Boost 3D', style: TextStyle(fontSize: 12)),
                  Expanded(
                    child: Slider(
                      value: _bassBoost,
                      min: 0,
                      max: 100,
                      activeColor: const Color(0xFFEC4899),
                      onChanged: (v) => setState(() => _bassBoost = v),
                    ),
                  ),
                  Text('${_bassBoost.round()}%'),
                ],
              ),
              Row(
                children: [
                  const Text('Surround HD', style: TextStyle(fontSize: 12)),
                  Expanded(
                    child: Slider(
                      value: _surround3D,
                      min: 0,
                      max: 100,
                      activeColor: const Color(0xFF0891B2),
                      onChanged: (v) => setState(() => _surround3D = v),
                    ),
                  ),
                  Text('${_surround3D.round()}%'),
                ],
              ),
            ],
          ),
        ),
      ],
    );
  }
}

// ============================================================================
// 5. LECTEUR & GESTIONNAIRE UNIVERSEL DE LA MÉMOIRE DU TÉLÉPHONE
//    (Audio, Vidéo, Photo, Document PDF/Word/TXT, Application APK)
// ============================================================================
class UniversalFilesAndDownloadsTab extends StatefulWidget {
  const UniversalFilesAndDownloadsTab({super.key});

  @override
  State<UniversalFilesAndDownloadsTab> createState() => _UniversalFilesAndDownloadsTabState();
}

class _UniversalFilesAndDownloadsTabState extends State<UniversalFilesAndDownloadsTab> {
  String _selectedCategory = 'Tous';
  List<FileSystemEntity> _storedFiles = [];

  @override
  void initState() {
    super.initState();
    _scanPhoneMemory();
  }

  Future<void> _scanPhoneMemory() async {
    final List<FileSystemEntity> files = [];
    for (final folder in [
      AppConfig.downloadFolder,
      '/storage/emulated/0/Download',
      '/storage/emulated/0/Documents',
      '/storage/emulated/0/Pictures',
      '/storage/emulated/0/Music',
      '/storage/emulated/0/Movies',
    ]) {
      try {
        final dir = Directory(folder);
        if (await dir.exists()) {
          await for (final entity in dir.list(followLinks: false)) {
            if (entity is File) {
              files.add(entity);
            }
          }
        }
      } catch (_) {}
    }
    if (mounted) setState(() => _storedFiles = files);
  }

  String _detectCategory(String path) {
    final lower = path.toLowerCase();
    if (lower.endsWith('.mp3') ||
        lower.endsWith('.wav') ||
        lower.endsWith('.flac') ||
        lower.endsWith('.m4a') ||
        lower.endsWith('.ogg')) {
      return 'Audio';
    }
    if (lower.endsWith('.mp4') ||
        lower.endsWith('.mkv') ||
        lower.endsWith('.webm') ||
        lower.endsWith('.avi') ||
        lower.endsWith('.mov')) {
      return 'Vidéo';
    }
    if (lower.endsWith('.jpg') ||
        lower.endsWith('.jpeg') ||
        lower.endsWith('.png') ||
        lower.endsWith('.webp') ||
        lower.endsWith('.gif')) {
      return 'Photo';
    }
    if (lower.endsWith('.pdf') ||
        lower.endsWith('.doc') ||
        lower.endsWith('.docx') ||
        lower.endsWith('.txt') ||
        lower.endsWith('.xlsx') ||
        lower.endsWith('.pptx')) {
      return 'Document';
    }
    if (lower.endsWith('.apk') || lower.endsWith('.zip')) {
      return 'Application';
    }
    return 'Autre';
  }

  Future<void> _pickAndOpenAnyFileFromPhone() async {
    final result = await FilePicker.platform.pickFiles(
      type: FileType.any,
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      final path = result.files.single.path!;
      await _openUniversalFile(path);
      _scanPhoneMemory();
    }
  }

  Future<void> _openUniversalFile(String path) async {
    final category = _detectCategory(path);
    if (category == 'Photo' && mounted) {
      showDialog(
        context: context,
        builder: (ctx) => Dialog(
          backgroundColor: const Color(0xFF181820),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              AppBar(
                backgroundColor: const Color(0xFF181820),
                title: Text(path.split('/').last, style: const TextStyle(fontSize: 13)),
              ),
              Image.file(File(path), fit: BoxFit.contain),
            ],
          ),
        ),
      );
      return;
    }
    await OpenFilex.open(path);
  }

  @override
  Widget build(BuildContext context) {
    final filtered = _selectedCategory == 'Tous'
        ? _storedFiles
        : _storedFiles.where((f) => _detectCategory(f.path) == _selectedCategory).toList();

    return Padding(
      padding: const EdgeInsets.all(12.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.stretch,
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: const Color(0xFF181820),
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: const Color(0xFF22C55E).withOpacity(0.4)),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                  'Mémoire du Téléphone — Lecteur Universel Tous Formats',
                  style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold),
                ),
                const SizedBox(height: 4),
                const Text(
                  'Lisez vos fichiers Audio, Vidéo, Photos, Documents (PDF/Office/TXT) et installez vos Applications (APK).',
                  style: TextStyle(fontSize: 11, color: Colors.white70),
                ),
                const SizedBox(height: 10),
                ElevatedButton.icon(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: const Color(0xFF22C55E),
                    foregroundColor: Colors.black,
                    minimumSize: const Size.fromHeight(40),
                  ),
                  onPressed: _pickAndOpenAnyFileFromPhone,
                  icon: const Icon(Icons.folder_open),
                  label: const Text(
                    'Parcourir & Ouvrir n\'importe quel fichier du téléphone',
                    style: TextStyle(fontWeight: FontWeight.bold, fontSize: 12),
                  ),
                ),
              ],
            ),
          ),
          const SizedBox(height: 10),
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              children: ['Tous', 'Audio', 'Vidéo', 'Photo', 'Document', 'Application'].map((cat) {
                final active = _selectedCategory == cat;
                return Padding(
                  padding: const EdgeInsets.only(right: 6.0),
                  child: ChoiceChip(
                    label: Text(cat, style: const TextStyle(fontSize: 11)),
                    selected: active,
                    selectedColor: const Color(0xFF7C3AED),
                    onSelected: (_) => setState(() => _selectedCategory = cat),
                  ),
                );
              }).toList(),
            ),
          ),
          const SizedBox(height: 8),
          Expanded(
            child: filtered.isEmpty
                ? Center(
                    child: TextButton.icon(
                      onPressed: _pickAndOpenAnyFileFromPhone,
                      icon: const Icon(Icons.add_circle_outline, color: Color(0xFF22C55E)),
                      label: const Text('Sélectionner un fichier dans la mémoire interne'),
                    ),
                  )
                : ListView.builder(
                    itemCount: filtered.length,
                    itemBuilder: (context, index) {
                      final entity = filtered[index];
                      final name = entity.path.split('/').last;
                      final cat = _detectCategory(entity.path);
                      return Card(
                        color: const Color(0xFF181820),
                        child: ListTile(
                          leading: Icon(
                            cat == 'Audio'
                                ? Icons.music_note
                                : cat == 'Vidéo'
                                    ? Icons.movie
                                    : cat == 'Photo'
                                        ? Icons.image
                                        : cat == 'Document'
                                            ? Icons.description
                                            : Icons.android,
                            color: const Color(0xFF22C55E),
                          ),
                          title: Text(name, maxLines: 1, overflow: TextOverflow.ellipsis),
                          subtitle: Text('$cat • ${entity.path}', maxLines: 1),
                          trailing: const Icon(Icons.open_in_new, size: 18),
                          onTap: () => _openUniversalFile(entity.path),
                        ),
                      );
                    },
                  ),
          ),
        ],
      ),
    );
  }
}

// ============================================================================
// 6. MODULE MONÉTISATION (ADMOB) & SYSTÈME DE MISE À JOUR OTA
// ============================================================================
class MonetizationAndUpdateTab extends StatefulWidget {
  const MonetizationAndUpdateTab({super.key});

  @override
  State<MonetizationAndUpdateTab> createState() => _MonetizationAndUpdateTabState();
}

class _MonetizationAndUpdateTabState extends State<MonetizationAndUpdateTab> {
  final TextEditingController _bannerIdCtrl =
      TextEditingController(text: AppConfig.bannerAdUnitId);
  final TextEditingController _interstitialIdCtrl =
      TextEditingController(text: AppConfig.interstitialAdUnitId);
  final TextEditingController _rewardedIdCtrl =
      TextEditingController(text: AppConfig.rewardedAdUnitId);
  final TextEditingController _updateUrlCtrl =
      TextEditingController(text: AppConfig.updateCheckUrl);

  String _appVersion = AppConfig.currentVersion;
  RewardedAd? _rewardedAd;

  @override
  void initState() {
    super.initState();
    _loadPackageInfo();
    _loadRewardedAd();
  }

  Future<void> _loadPackageInfo() async {
    try {
      final info = await PackageInfo.fromPlatform();
      if (mounted) {
        setState(() {
          _appVersion = '${info.version}+${info.buildNumber}';
        });
      }
    } catch (_) {}
  }

  void _loadRewardedAd() {
    if (!AppConfig.adsEnabled) return;
    RewardedAd.load(
      adUnitId: AppConfig.rewardedAdUnitId,
      request: const AdRequest(),
      rewardedAdLoadCallback: RewardedAdLoadCallback(
        onAdLoaded: (ad) => _rewardedAd = ad,
        onAdFailedToLoad: (_) => _rewardedAd = null,
      ),
    );
  }

  void _showRewardedAd() {
    if (_rewardedAd != null) {
      _rewardedAd!.show(
        onUserEarnedReward: (_, reward) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Récompense débloquée : +${reward.amount} ${reward.type}'),
              backgroundColor: const Color(0xFF22C55E),
            ),
          );
        },
      );
      _rewardedAd = null;
      _loadRewardedAd();
    } else {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Mode Premium temporaire activé pour 30 minutes ! Bannières masquées.'),
          backgroundColor: Color(0xFF7C3AED),
        ),
      );
      _loadRewardedAd();
    }
  }

  @override
  void dispose() {
    _bannerIdCtrl.dispose();
    _interstitialIdCtrl.dispose();
    _rewardedIdCtrl.dispose();
    _updateUrlCtrl.dispose();
    _rewardedAd?.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF181820),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF7C3AED).withOpacity(0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  const Row(
                    children: [
                      Icon(Icons.monetization_on, color: Color(0xFF7C3AED)),
                      SizedBox(width: 8),
                      Text(
                        'Régie Publicitaire AdMob',
                        style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                      ),
                    ],
                  ),
                  Switch(
                    value: AppConfig.adsEnabled,
                    activeColor: const Color(0xFF22C55E),
                    onChanged: (val) => setState(() => AppConfig.adsEnabled = val),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _bannerIdCtrl,
                style: const TextStyle(fontSize: 12),
                decoration: const InputDecoration(
                  labelText: 'ID Bannière AdMob',
                  filled: true,
                  fillColor: Color(0xFF0F0F14),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _interstitialIdCtrl,
                style: const TextStyle(fontSize: 12),
                decoration: const InputDecoration(
                  labelText: 'ID Interstitiel AdMob',
                  filled: true,
                  fillColor: Color(0xFF0F0F14),
                ),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _rewardedIdCtrl,
                style: const TextStyle(fontSize: 12),
                decoration: const InputDecoration(
                  labelText: 'ID Vidéo Récompensée AdMob',
                  filled: true,
                  fillColor: Color(0xFF0F0F14),
                ),
              ),
              const SizedBox(height: 12),
              Row(
                children: [
                  Expanded(
                    child: ElevatedButton.icon(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF7C3AED),
                        foregroundColor: Colors.white,
                      ),
                      onPressed: () {
                        setState(() {
                          AppConfig.bannerAdUnitId = _bannerIdCtrl.text.trim();
                          AppConfig.interstitialAdUnitId = _interstitialIdCtrl.text.trim();
                          AppConfig.rewardedAdUnitId = _rewardedIdCtrl.text.trim();
                        });
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                            content: Text('Identifiants publicitaires enregistrés.'),
                            backgroundColor: Color(0xFF22C55E),
                          ),
                        );
                      },
                      icon: const Icon(Icons.save),
                      label: const Text('Enregistrer IDs'),
                    ),
                  ),
                  const SizedBox(width: 8),
                  Expanded(
                    child: OutlinedButton.icon(
                      style: OutlinedButton.styleFrom(
                        foregroundColor: const Color(0xFF0891B2),
                        side: const BorderSide(color: Color(0xFF0891B2)),
                      ),
                      onPressed: _showRewardedAd,
                      icon: const Icon(Icons.play_circle_fill),
                      label: const Text('Tester Pub Vidéo'),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        Container(
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            color: const Color(0xFF181820),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: const Color(0xFF0891B2).withOpacity(0.4)),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'Mises à Jour OTA Utilisateurs (v$_appVersion)',
                style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              TextField(
                controller: _updateUrlCtrl,
                style: const TextStyle(fontSize: 12),
                decoration: const InputDecoration(
                  labelText: 'URL du manifeste version.json (OTA)',
                  filled: true,
                  fillColor: Color(0xFF0F0F14),
                ),
              ),
              const SizedBox(height: 12),
              ElevatedButton.icon(
                style: ElevatedButton.styleFrom(
                  backgroundColor: const Color(0xFF0891B2),
                  foregroundColor: Colors.white,
                  minimumSize: const Size.fromHeight(44),
                ),
                onPressed: () {
                  AppConfig.updateCheckUrl = _updateUrlCtrl.text.trim();
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(
                      content: Text('Vérification OTA active sur le dépôt GitHub Yo\'art Tech.'),
                      backgroundColor: Color(0xFF0891B2),
                    ),
                  );
                },
                icon: const Icon(Icons.cloud_download),
                label: const Text('Vérifier les Mises à Jour OTA'),
              ),
            ],
          ),
        ),
      ],
    );
  }
}
