import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/ad_service.dart';

class DownloadsScreen extends StatefulWidget {
  const DownloadsScreen({super.key});

  @override
  State<DownloadsScreen> createState() => _DownloadsScreenState();
}

class _DownloadsScreenState extends State<DownloadsScreen> {
  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          backgroundColor: AppColors.surfaceDark,
          title: const Text('Mes Téléchargements', style: TextStyle(fontWeight: FontWeight.bold)),
          actions: [
            IconButton(
              icon: const Icon(Icons.cleaning_services_rounded, color: AppColors.textSecondaryDark),
              tooltip: 'Nettoyer la liste',
              onPressed: () {},
            ),
          ],
          bottom: const TabBar(
            indicatorColor: AppColors.primaryViolet,
            labelColor: AppColors.primaryViolet,
            unselectedLabelColor: AppColors.textSecondaryDark,
            tabs: [
              Tab(text: 'En cours', icon: Icon(Icons.downloading_rounded)),
              Tab(text: 'Téléchargés', icon: Icon(Icons.check_circle_outline_rounded)),
            ],
          ),
        ),
        body: Column(
          children: [
            Expanded(
              child: TabBarView(
                children: [
                  // Onglet 1 : En cours
                  _buildInProgressTab(),
                  // Onglet 2 : Téléchargés
                  _buildCompletedTab(),
                ],
              ),
            ),
            const DiscreetBannerAd(placementName: 'Téléchargements'),
          ],
        ),
      ),
    );
  }

  Widget _buildInProgressTab() {
    // Simulation visuelle du gestionnaire de téléchargement
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        Card(
          color: AppColors.cardDark,
          child: Padding(
            padding: const EdgeInsets.all(12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(child: Text('Mix Nouveautés 2026.mp4', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold), maxLines: 1)),
                    Text('45%', style: TextStyle(color: AppColors.secondaryCyan, fontWeight: FontWeight.bold)),
                  ],
                ),
                const SizedBox(height: 8),
                LinearProgressIndicator(
                  value: 0.45,
                  backgroundColor: AppColors.surfaceDark,
                  color: AppColors.secondaryCyan,
                ),
                const SizedBox(height: 12),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    const Text('32 Mo / 75 Mo • 1.2 Mo/s', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
                    Row(
                      children: [
                        IconButton(icon: const Icon(Icons.pause_rounded, color: Colors.white, size: 20), onPressed: () {}),
                        IconButton(icon: const Icon(Icons.close_rounded, color: AppColors.error, size: 20), onPressed: () {}),
                      ],
                    )
                  ],
                )
              ],
            ),
          ),
        ),
      ],
    );
  }

  Widget _buildCompletedTab() {
    return ListView(
      padding: const EdgeInsets.all(12),
      children: [
        ListTile(
          tileColor: AppColors.cardDark,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          leading: Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: AppColors.primaryViolet.withOpacity(0.2), borderRadius: BorderRadius.circular(8)),
            child: const Icon(Icons.music_note_rounded, color: AppColors.primaryViolet),
          ),
          title: const Text('Audio_Maguy_Test.mp3', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
          subtitle: const Text('Terminé • 4.5 Mo', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
          trailing: const Icon(Icons.play_arrow_rounded, color: AppColors.secondaryCyan),
          onTap: () {},
        ),
      ],
    );
  }
}
