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
                    active
                        ? 'Bonus Sans Bannière : Actif'
                        : 'Regarder une publicité récompensée',
                    style: const TextStyle(
                      color: AppColors.textPrimaryDark,
                      fontWeight: FontWeight.w600,
                      fontSize: 14,
                    ),
                  ),
                  subtitle: Text(
                    active
                        ? '${AdService.instance.remainingRewardTimeText} (Avantage interne non monétaire)'
                        : 'Débloque 30 min sans bannières (Aucune valeur d\'argent réel)',
                    style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 12),
                  ),
                  trailing: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                      backgroundColor: AppColors.primaryViolet,
                      foregroundColor: Colors.white,
                    ),
                    onPressed: () => AdService.instance.showRewardedAdDialog(context),
                    child: Text(active ? 'Prolonger' : 'Regarder'),
                  ),
                ),
              );
            },
          ),
          _buildSettingTile(
            icon: Icons.privacy_tip_outlined,
            iconColor: AppColors.primaryViolet,
            title: 'Charte publicitaire YMediSave',
            subtitle: 'Bannières discrètes • 0 pub pendant la lecture vidéo',
          ),

          const SizedBox(height: 16),
          _buildSectionTitle('APPARENCE & INTERFACE'),
          _buildSettingTile(
            icon: Icons.dark_mode_rounded,
            iconColor: AppColors.primaryViolet,
            title: 'Thème de l\'application',
            subtitle: 'Sombre (Anthracite / Violet & Cyan)',
          ),
          _buildSettingTile(
            icon: Icons.language_rounded,
            iconColor: AppColors.secondaryCyan,
            title: 'Langue',
            subtitle: 'Français (Par défaut)',
          ),

          const SizedBox(height: 16),
          _buildSectionTitle('TÉLÉCHARGEMENTS & RÉSEAU'),
          _buildSettingTile(
            icon: Icons.wifi_rounded,
            iconColor: AppColors.secondaryCyan,
            title: 'Réseau autorisé',
            subtitle: 'Wi-Fi uniquement (Avertir sur données mobiles)',
          ),
          _buildSettingTile(
            icon: Icons.folder_open_rounded,
            iconColor: AppColors.primaryViolet,
            title: 'Emplacement de stockage',
            subtitle: 'Mémoire interne / Download / YMediSave',
          ),

          const SizedBox(height: 16),
          _buildSectionTitle('SÉCURITÉ & COMPTES'),
          _buildSettingTile(
            icon: Icons.lock_rounded,
            iconColor: AppColors.warning,
            title: 'Coffre-fort privé',
            subtitle: 'Chiffrement AES + Code PIN (Étape F)',
          ),
          _buildSettingTile(
            icon: Icons.account_circle_outlined,
            iconColor: AppColors.success,
            title: 'Comptes et sources officielles',
            subtitle: 'Gérer les autorisations OAuth (Étape G)',
          ),

          const SizedBox(height: 16),
          _buildSectionTitle('À PROPOS & LÉGAL'),
          _buildSettingTile(
            icon: Icons.info_outline_rounded,
            iconColor: AppColors.textSecondaryDark,
            title: 'Version de YMediSave',
            subtitle: 'v1.0.0+3 (Étape B + Système Publicitaire)',
          ),
        ],
      ),
    );
  }

  Widget _buildSectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      child: Text(
        title,
        style: const TextStyle(
          color: AppColors.secondaryCyan,
          fontSize: 11,
          fontWeight: FontWeight.bold,
          letterSpacing: 1.1,
        ),
      ),
    );
  }

  Widget _buildSettingTile({
    required IconData icon,
    required Color iconColor,
    required String title,
    required String subtitle,
  }) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      child: ListTile(
        leading: Icon(icon, color: iconColor),
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
          style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 12),
        ),
        trailing: const Icon(Icons.chevron_right_rounded, color: AppColors.textSecondaryDark),
      ),
    );
  }
}
