import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/ad_service.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Paramètres'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(12),
        children: [
          // En-tête Yo'art Tech
          Container(
            padding: const EdgeInsets.all(16),
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: AppColors.cardDark,
              borderRadius: BorderRadius.circular(16),
              border: Border.all(color: AppColors.primaryViolet.withOpacity(0.3)),
            ),
            child: Row(
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: AppColors.primaryViolet.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: const Icon(Icons.rocket_launch_rounded, color: AppColors.secondaryCyan),
                ),
                const SizedBox(width: 16),
                const Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Une création Yo'art Tech",
                        style: TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.bold, fontSize: 16),
                      ),
                      Text(
                        'Navigateur, Téléchargeur & Lecteur Multimédia',
                        style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),

          _buildSectionTitle('MONÉTISATION & PUBLICITÉS ÉTHIQUES'),
          ListenableBuilder(
            listenable: AdService.instance,
            builder: (context, _) {
              final active = AdService.instance.isRewardActive;
              return Card(
                margin: const EdgeInsets.only(bottom: 8),
                child: ListTile(
                  leading: Icon(
                    Icons.redeem_rounded,
                    color: active ? AppColors.success : AppColors.secondaryCyan,
                  ),
                  title: Text(
                    active ? 'Bonus Sans Bannière : Actif' : 'Regarder une publicité récompensée',
                    style: const TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w600, fontSize: 14),
                  ),
                  subtitle: Text(
                    active
                        ? '${AdService.instance.remainingRewardTimeText}'
                        : 'Débloque 30 min sans bannières',
                    style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 12),
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryViolet, foregroundColor: Colors.white),
                    onPressed: () => AdService.instance.showRewardedAdDialog(context),
                    child: Text(active ? 'Prolonger' : 'Regarder'),
                  ),
                ),
              );
            },
          ),
          
          const SizedBox(height: 16),
          _buildSectionTitle('APPARENCE & INTERFACE'),
          _buildSettingTile(icon: Icons.dark_mode_rounded, iconColor: AppColors.primaryViolet, title: 'Thème de l\'application', subtitle: 'Sombre (Anthracite / Violet & Cyan)'),
          
          const SizedBox(height: 16),
          _buildSectionTitle('TÉLÉCHARGEMENTS & RÉSEAU'),
          _buildSettingTile(icon: Icons.folder_open_rounded, iconColor: AppColors.secondaryCyan, title: 'Emplacement de stockage', subtitle: 'Mémoire interne / Download / YMediSave'),
          
          const SizedBox(height: 16),
          _buildSectionTitle('À PROPOS & LÉGAL'),
          _buildSettingTile(icon: Icons.info_outline_rounded, iconColor: AppColors.textSecondaryDark, title: 'Version', subtitle: 'YMediSave v1.0.0+4 par Yo\'art Tech'),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(title, style: const TextStyle(color: AppColors.secondaryCyan, fontSize: 11, fontWeight: FontWeight.bold, letterSpacing: 1.1)),
    );
  }

  Widget _buildSettingTile({required IconData icon, required Color iconColor, required String title, required String subtitle}) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
        title: Text(title, style: const TextStyle(color: AppColors.textPrimaryDark, fontWeight: FontWeight.w600, fontSize: 14)),
        subtitle: Text(subtitle, style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondaryDark),
      ),
    );
  }
}
