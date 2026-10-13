import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/ad_service.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final List<Map<String, String>> demoFiles = [
      {
        'title': '[DÉMO] Big Buck Bunny (Open Movie).mp4',
        'info': 'Vidéo • 720p • 32.5 Mo',
        'type': 'video',
      },
      {
        'title': '[DÉMO] Cours Programmation Flutter.mp4',
        'info': 'Vidéo • 1080p • 84.0 Mo',
        'type': 'video',
      },
      {
        'title': '[DÉMO] Ambiance Pluie Tropicale.mp3',
        'info': 'Audio • MP3 • 12.1 Mo',
        'type': 'audio',
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('Bibliothèque'),
        actions: [
          IconButton(
            icon: const Icon(Icons.sort_rounded),
            tooltip: 'Trier',
            onPressed: () {},
          ),
        ],
      ),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 14),
              decoration: BoxDecoration(
                color: AppColors.cardDark,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const TextField(
                style: TextStyle(color: AppColors.textPrimaryDark),
                decoration: InputDecoration(
                  icon: Icon(Icons.search, color: AppColors.textSecondaryDark),
                  border: InputBorder.none,
                  hintText: 'Rechercher dans vos fichiers hors-ligne...',
                  hintStyle: TextStyle(color: AppColors.textSecondaryDark, fontSize: 13),
                ),
              ),
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.all(16),
              itemCount: demoFiles.length,
              itemBuilder: (context, index) {
                final item = demoFiles[index];
                final isVideo = item['type'] == 'video';
                return Card(
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ListTile(
                    leading: Container(
                      width: 50,
                      height: 50,
                      decoration: BoxDecoration(
                        color: isVideo
                            ? AppColors.primaryViolet.withOpacity(0.18)
                            : AppColors.secondaryCyan.withOpacity(0.18),
                        borderRadius: BorderRadius.circular(10),
                      ),
                      child: Icon(
                        isVideo ? Icons.videocam_rounded : Icons.audiotrack_rounded,
                        color: isVideo ? AppColors.primaryViolet : AppColors.secondaryCyan,
                      ),
                    ),
                    title: Text(
                      item['title']!,
                      style: const TextStyle(
                        color: AppColors.textPrimaryDark,
                        fontWeight: FontWeight.w600,
                        fontSize: 14,
                      ),
                    ),
                    subtitle: Text(
                      item['info']!,
                      style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 12),
                    ),
                    trailing: const Icon(Icons.more_vert, color: AppColors.textSecondaryDark),
                  ),
                );
              },
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: DiscreetBannerAd(placementName: 'Bibliothèque'),
          ),
        ],
      ),
    );
  }
}
