import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/ad_service.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Téléchargements'),
      ),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16.0),
              children: [
                Container(
                  padding: const EdgeInsets.all(14),
                  decoration: BoxDecoration(
                    color: AppColors.surfaceDark,
                    borderRadius: BorderRadius.circular(12),
                    border: Border.all(color: AppColors.cardDark),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Row(
                        children: [
                          Icon(Icons.sd_storage_rounded, color: AppColors.secondaryCyan, size: 20),
                          SizedBox(width: 8),
                          Text(
                            'Stockage interne [DÉMO]',
                            style: TextStyle(color: AppColors.textPrimaryDark, fontSize: 13),
                          ),
                        ],
                      ),
                      Text(
                        '24.5 Go libres • Wi-Fi',
                        style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
                const Text(
                  'En cours (1) [DÉMO]',
                  style: TextStyle(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.cardDark,
                    borderRadius: BorderRadius.circular(14),
                  ),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          const Expanded(
                            child: Text(
                              '[DÉMO] Tutoriel_Flutter_Complet.mp4',
                              style: TextStyle(
                                color: AppColors.textPrimaryDark,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.pause_circle_filled, color: AppColors.secondaryCyan),
                            onPressed: () {},
                          ),
                        ],
                      ),
                      const SizedBox(height: 6),
                      const Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text(
                            'Téléchargement... 65% (1.2 Mo/s)',
                            style: TextStyle(color: AppColors.secondaryCyan, fontSize: 12),
                          ),
                          Text(
                            '32.5 Mo / 50.0 Mo',
                            style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12),
                          ),
                        ],
                      ),
                      const SizedBox(height: 10),
                      ClipRRect(
                        borderRadius: BorderRadius.circular(6),
                        child: const LinearProgressIndicator(
                          value: 0.65,
                          minHeight: 7,
                          backgroundColor: AppColors.backgroundDark,
                          color: AppColors.secondaryCyan,
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 24),
                const Text(
                  'Terminés [DÉMO]',
                  style: TextStyle(
                    color: AppColors.textPrimaryDark,
                    fontWeight: FontWeight.bold,
                    fontSize: 15,
                  ),
                ),
                const SizedBox(height: 10),
                const Card(
                  child: ListTile(
                    leading: Icon(Icons.check_circle_rounded, color: AppColors.success),
                    title: Text(
                      '[DÉMO] Musique_Libre_CC0.mp3',
                      style: TextStyle(color: AppColors.textPrimaryDark, fontSize: 14),
                    ),
                    subtitle: Text(
                      'Terminé • 8.4 Mo',
                      style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12),
                    ),
                    trailing: Icon(Icons.play_arrow_rounded, color: AppColors.primaryViolet),
                  ),
                ),
              ],
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: DiscreetBannerAd(placementName: 'Téléchargements'),
          ),
        ],
      ),
    );
  }
}
