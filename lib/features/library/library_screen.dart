import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/ad_service.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 3,
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          backgroundColor: AppColors.surfaceDark,
          title: const Text('Ma Bibliothèque', style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.tune_rounded, color: AppColors.secondaryCyan),
              tooltip: 'Égaliseur Intelligent Yo\'art',
              onPressed: () {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('L\'Égaliseur Intelligent sera activé avec le lecteur audio.'), backgroundColor: AppColors.primaryViolet),
                );
              },
            ),
          ],
          bottom: const TabBar(
            indicatorColor: AppColors.primaryViolet,
            labelColor: AppColors.primaryViolet,
            unselectedLabelColor: AppColors.textSecondaryDark,
            tabs: [
              Tab(text: 'Locaux', icon: Icon(Icons.folder_shared_rounded)),
              Tab(text: 'Favoris', icon: Icon(Icons.favorite_rounded)),
              Tab(text: 'Playlists', icon: Icon(Icons.queue_music_rounded)),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  _buildListPlaceholder(Icons.sd_storage_rounded, 'Analyse de la mémoire de l\'appareil...\n(Nécessite les permissions Android)'),
                  _buildListPlaceholder(Icons.favorite_outline_rounded, 'Vos musiques et vidéos favorites apparaîtront ici.'),
                  _buildListPlaceholder(Icons.playlist_add_rounded, 'Créez des playlists pour organiser vos médias.'),
                ],
              ),
            ),
            const DiscreetBannerAd(placementName: 'Bibliothèque'),
          ],
        ),
        floatingActionButton: FloatingActionButton(
          backgroundColor: AppColors.primaryViolet,
          child: const Icon(Icons.add, color: Colors.white),
          onPressed: () {
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Création de Playlist / Ajout de dossier'), backgroundColor: AppColors.secondaryCyan),
            );
          },
        ),
      ),
    );
  }

  Widget _buildListPlaceholder(IconData icon, String message) {
    return Center(
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 64, color: AppColors.textSecondaryDark.withOpacity(0.5)),
          const SizedBox(height: 16),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 32.0),
            child: Text(message, textAlign: TextAlign.center, style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 14)),
          ),
        ],
      ),
    );
  }
}
