import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../search/maguy_ai_screen.dart';
import '../browser/browser_screen.dart';
import '../player/smart_player_screen.dart';
import '../../core/services/ad_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _refreshFeeds() async {
    await Future.delayed(const Duration(seconds: 2));
    if (mounted) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Flux mis à jour par Maguy !'), backgroundColor: AppColors.success),
      );
    }
  }

  void _openMaguySearch() {
    Navigator.push(context, MaterialPageRoute(builder: (context) => const MaguyAiScreen()));
  }

  void _openBrowser(String url) {
    Navigator.push(context, MaterialPageRoute(builder: (context) => BrowserScreen(initialUrl: url)));
  }

  void _openPlayer(bool isVideo, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SmartPlayerScreen(
          title: isVideo ? 'Vidéo Virale ${index + 1}' : 'Titre Tendance ${index + 1}',
          author: isVideo ? 'Créateur Populaire' : 'Artiste du moment',
          isVideo: isVideo,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft, end: Alignment.bottomRight,
            colors: [AppColors.primaryViolet.withOpacity(0.35), AppColors.backgroundDark],
            stops: const [0.0, 0.4],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Row(
                      children: [
                        Container(
                          width: 30, height: 30,
                          decoration: BoxDecoration(
                            gradient: const LinearGradient(colors: [AppColors.accentGradientStart, AppColors.accentGradientEnd]),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 20),
                        ),
                        const SizedBox(width: 10),
                        const Text('YMediSave', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white)),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.auto_awesome, color: AppColors.secondaryCyan),
                      onPressed: _openMaguySearch,
                      tooltip: 'Parler à Maguy IA',
                    ),
                  ],
                ),
              ),
              Expanded(
                child: RefreshIndicator(
                  color: AppColors.secondaryCyan,
                  backgroundColor: AppColors.surfaceDark,
                  onRefresh: _refreshFeeds,
                  child: ListView(
                    physics: const AlwaysScrollableScrollPhysics(),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: GestureDetector(
                          onTap: _openMaguySearch,
                          child: Container(
                            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
                            decoration: BoxDecoration(
                              color: AppColors.cardDark.withOpacity(0.85),
                              borderRadius: BorderRadius.circular(24),
                              border: Border.all(color: AppColors.primaryViolet.withOpacity(0.3)),
                            ),
                            child: const Row(
                              children: [
                                Icon(Icons.search, color: AppColors.textSecondaryDark),
                                SizedBox(width: 10),
                                Text('Rechercher ou demander à Maguy...', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 14)),
                              ],
                            ),
                          ),
                        ),
                      ),
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildShortcutIcon(Icons.video_collection, 'YouTube', AppColors.error, 'youtube.com'),
                            _buildShortcutIcon(Icons.music_note_rounded, 'TikTok', Colors.pinkAccent, 'tiktok.com'),
                            _buildShortcutIcon(Icons.facebook_rounded, 'Facebook', Colors.blue, 'facebook.com'),
                            _buildShortcutIcon(Icons.library_music_rounded, 'Musique', AppColors.secondaryCyan, 'soundcloud.com'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),
                      _buildSectionHeader('🔥 Vidéos Virales (Tirez pour actualiser)'),
                      _buildHorizontalScroll(Icons.local_fire_department_rounded, AppColors.error, true),
                      const SizedBox(height: 20),
                      _buildSectionHeader('🎵 Top Musiques & Nouveautés'),
                      _buildHorizontalScroll(Icons.music_note_rounded, AppColors.secondaryCyan, false),
                      const SizedBox(height: 20),
                    ],
                  ),
                ),
              ),
              const DiscreetBannerAd(placementName: 'Accueil Navigateur'),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildSectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
      child: Text(title, style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
    );
  }

  Widget _buildHorizontalScroll(IconData icon, Color color, bool isVideo) {
    return SizedBox(
      height: 140,
      child: ListView.builder(
        scrollDirection: Axis.horizontal,
        padding: const EdgeInsets.symmetric(horizontal: 12),
        itemCount: 4,
        itemBuilder: (context, index) {
          return GestureDetector(
            onTap: () => _openPlayer(isVideo, index),
            child: Container(
              width: 220,
              margin: const EdgeInsets.symmetric(horizontal: 4),
              decoration: BoxDecoration(color: AppColors.cardDark, borderRadius: BorderRadius.circular(12)),
              child: Center(child: Icon(icon, color: color.withOpacity(0.5), size: 48)),
            ),
          );
        },
      ),
    );
  }

  Widget _buildShortcutIcon(IconData icon, String label, Color color, String url) {
    return InkWell(
      onTap: () => _openBrowser(url),
      borderRadius: BorderRadius.circular(12),
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: AppColors.cardDark.withOpacity(0.8),
              shape: BoxShape.circle,
              border: Border.all(color: color.withOpacity(0.6), width: 1.5),
            ),
            child: Icon(icon, color: color, size: 26),
          ),
          const SizedBox(height: 8),
          Text(label, style: const TextStyle(color: AppColors.textPrimaryDark, fontSize: 11, fontWeight: FontWeight.w600)),
        ],
      ),
    );
  }
}
