import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/ad_service.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _urlController = TextEditingController();

  @override
  void dispose() {
    _urlController.dispose();
    super.dispose();
  }

  void _showDemoMessage(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text('[DÉMO] $feature sera activé dans les prochaines étapes.'),
        backgroundColor: AppColors.primaryViolet,
        behavior: SnackBarBehavior.floating,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            Container(
              width: 34,
              height: 34,
              decoration: BoxDecoration(
                gradient: const LinearGradient(
                  colors: [AppColors.accentGradientStart, AppColors.accentGradientEnd],
                ),
                borderRadius: BorderRadius.circular(10),
              ),
              child: const Icon(Icons.play_arrow_rounded, color: Colors.white, size: 22),
            ),
            const SizedBox(width: 10),
            const Text('YMediSave'),
          ],
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.lock_outline, color: AppColors.secondaryCyan),
            tooltip: 'Coffre-fort privé',
            onPressed: () => _showDemoMessage('Le Coffre-fort privé chiffré (Étape F)'),
          ),
        ],
      ),
      body: Column(
        children: [
          Expanded(
            child: SingleChildScrollView(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  // Carte Publicité Récompensée
                  ListenableBuilder(
                    listenable: AdService.instance,
                    builder: (context, _) {
                      final active = AdService.instance.isRewardActive;
                      return Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(12),
                        decoration: BoxDecoration(
                          color: active
                              ? AppColors.success.withOpacity(0.15)
                              : AppColors.primaryViolet.withOpacity(0.15),
                          borderRadius: BorderRadius.circular(14),
                          border: Border.all(
                            color: active
                                ? AppColors.success.withOpacity(0.5)
                                : AppColors.primaryViolet.withOpacity(0.5),
                          ),
                        ),
                        child: Row(
                          children: [
                            Icon(
                              active ? Icons.verified_rounded : Icons.redeem_rounded,
                              color: active ? AppColors.success : AppColors.secondaryCyan,
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    active
                                        ? 'Mode Sans Bannière Actif'
                                        : 'Débloquer 30 min sans bannières',
                                    style: const TextStyle(
                                      color: AppColors.textPrimaryDark,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 13,
                                    ),
                                  ),
                                  Text(
                                    active
                                        ? AdService.instance.remainingRewardTimeText
                                        : 'Regarder 1 courte vidéo (Avantage fonctionnel)',
                                    style: const TextStyle(
                                      color: AppColors.textSecondaryDark,
                                      fontSize: 11,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            if (!active)
                              TextButton(
                                onPressed: () => AdService.instance.showRewardedAdDialog(context),
                                child: const Text(
                                  'Voir',
                                  style: TextStyle(
                                    color: AppColors.secondaryCyan,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      );
                    },
                  ),
                  const SizedBox(height: 20),

                  const Text(
                    'Téléchargement & Lecture directe',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  const SizedBox(height: 10),
                  Container(
                    padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
                    decoration: BoxDecoration(
                      color: AppColors.cardDark,
                      borderRadius: BorderRadius.circular(16),
                      border: Border.all(color: AppColors.primaryViolet.withOpacity(0.4)),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.link_rounded, color: AppColors.secondaryCyan),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            controller: _urlController,
                            style: const TextStyle(color: AppColors.textPrimaryDark),
                            decoration: const InputDecoration(
                              border: InputBorder.none,
                              hintText: 'Coller un lien média autorisé (MP4, MP3...)',
                              hintStyle: TextStyle(color: AppColors.textSecondaryDark, fontSize: 13),
                            ),
                          ),
                        ),
                        ElevatedButton(
                          style: ElevatedButton.styleFrom(
                            backgroundColor: AppColors.primaryViolet,
                            foregroundColor: Colors.white,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12),
                            ),
                          ),
                          onPressed: () => _showDemoMessage('Analyse et téléchargement du lien (Étape D)'),
                          child: const Text('Go'),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 26),

                  const Text(
                    'Accès rapides',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  Row(
                    children: [
                      _buildQuickAction(
                        icon: Icons.video_library_rounded,
                        label: 'Vidéos',
                        color: AppColors.primaryViolet,
                        onTap: () => _showDemoMessage('Ouverture des vidéos locales (Étape C)'),
                      ),
                      const SizedBox(width: 12),
                      _buildQuickAction(
                        icon: Icons.headphones_rounded,
                        label: 'Audio',
                        color: AppColors.secondaryCyan,
                        onTap: () => _showDemoMessage('Lecteur audio arrière-plan (Étape C)'),
                      ),
                      const SizedBox(width: 12),
                      _buildQuickAction(
                        icon: Icons.explore_rounded,
                        label: 'Sources',
                        color: AppColors.success,
                        onTap: () => _showDemoMessage('Explorateur de sources légales (Étape G)'),
                      ),
                      const SizedBox(width: 12),
                      _buildQuickAction(
                        icon: Icons.shield_rounded,
                        label: 'Coffre-fort',
                        color: AppColors.warning,
                        onTap: () => _showDemoMessage('Coffre-fort privé chiffré (Étape F)'),
                      ),
                    ],
                  ),
                  const SizedBox(height: 26),

                  const Text(
                    'Médias récents [DÉMO]',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color: AppColors.textPrimaryDark,
                    ),
                  ),
                  const SizedBox(height: 12),
                  _buildRecentMediaCard(
                    title: '[DÉMO] Documentaire Nature Libre.mp4',
                    subtitle: 'Vidéo MP4 • 1080p • 45.2 Mo • Libre de droits',
                    icon: Icons.movie_creation_outlined,
                    accent: AppColors.primaryViolet,
                  ),
                  const SizedBox(height: 10),
                  _buildRecentMediaCard(
                    title: '[DÉMO] Podcast Tech Afrique #12.mp3',
                    subtitle: 'Audio MP3 • 320 kbps • 18.4 Mo • Hors-ligne',
                    icon: Icons.graphic_eq_rounded,
                    accent: AppColors.secondaryCyan,
                  ),
                ],
              ),
            ),
          ),
          const Padding(
            padding: EdgeInsets.symmetric(horizontal: 12.0),
            child: DiscreetBannerAd(placementName: 'Accueil'),
          ),
        ],
      ),
    );
  }

  Widget _buildQuickAction({
    required IconData icon,
    required String label,
    required Color color,
    required VoidCallback onTap,
  }) {
    return Expanded(
      child: InkWell(
        onTap: onTap,
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(vertical: 16),
          decoration: BoxDecoration(
            color: AppColors.cardDark,
            borderRadius: BorderRadius.circular(14),
          ),
          child: Column(
            children: [
              Icon(icon, color: color, size: 28),
              const SizedBox(height: 8),
              Text(
                label,
                style: const TextStyle(
                  fontSize: 12,
                  fontWeight: FontWeight.w600,
                  color: AppColors.textPrimaryDark,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRecentMediaCard({
    required String title,
    required String subtitle,
    required IconData icon,
    required Color accent,
  }) {
    return Card(
      child: ListTile(
        leading: Container(
          width: 48,
          height: 48,
          decoration: BoxDecoration(
            color: accent.withOpacity(0.15),
            borderRadius: BorderRadius.circular(10),
          ),
          child: Icon(icon, color: accent),
        ),
        title: Text(
          title,
          style: const TextStyle(
            color: AppColors.textPrimaryDark,
            fontWeight: FontWeight.w600,
            fontSize: 14,
          ),
        ),
        subtitle: Text(
          subtitle,
          style: const TextStyle(
            color: AppColors.textSecondaryDark,
            fontSize: 12,
          ),
        ),
        trailing: const Icon(Icons.play_circle_fill_rounded, color: AppColors.secondaryCyan, size: 32),
        onTap: () => _showDemoMessage('Lecture multimédia sans pub intrusive (Étape C)'),
      ),
    );
  }
}
