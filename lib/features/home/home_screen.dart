import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/ad_service.dart';
import '../browser/browser_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final TextEditingController _searchController = TextEditingController();

  void _openBrowser(String url) {
    if (url.trim().isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BrowserScreen(initialUrl: url)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      // Le dégradé Violet -> Noir s'applique ici sur toute la page
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [
              AppColors.primaryViolet.withOpacity(0.35), // Violet lumineux en haut à gauche
              AppColors.backgroundDark,                  // Se fond dans le noir anthracite
              AppColors.backgroundDark,
            ],
            stops: const [0.0, 0.4, 1.0],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // En-tête transparent (Titre YMediSave)
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 12.0),
                child: Row(
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
                    const Text('YMediSave', style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 0.5)),
                  ],
                ),
              ),
              
              Expanded(
                child: SingleChildScrollView(
                  child: Column(
                    children: [
                      // Barre de recherche type Navigateur
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Container(
                          padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 2),
                          decoration: BoxDecoration(
                            color: AppColors.cardDark.withOpacity(0.85), // Légère transparence
                            borderRadius: BorderRadius.circular(24),
                            border: Border.all(color: AppColors.primaryViolet.withOpacity(0.3)),
                          ),
                          child: Row(
                            children: [
                              const Icon(Icons.search, color: AppColors.textSecondaryDark),
                              const SizedBox(width: 10),
                              Expanded(
                                child: TextField(
                                  controller: _searchController,
                                  style: const TextStyle(color: AppColors.textPrimaryDark),
                                  decoration: const InputDecoration(
                                    border: InputBorder.none,
                                    hintText: 'Recherchez ou entrez une URL...',
                                    hintStyle: TextStyle(color: AppColors.textSecondaryDark, fontSize: 14),
                                  ),
                                  onSubmitted: (value) => _openBrowser(value),
                                ),
                              ),
                              IconButton(
                                icon: const Icon(Icons.language, color: AppColors.secondaryCyan),
                                onPressed: () => _openBrowser(_searchController.text),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Raccourcis Rapides Connectés
                      Padding(
                        padding: const EdgeInsets.symmetric(horizontal: 16.0),
                        child: Row(
                          mainAxisAlignment: MainAxisAlignment.spaceAround,
                          children: [
                            _buildShortcutIcon(Icons.video_collection, 'YouTube', AppColors.error, 'youtube.com'),
                            _buildShortcutIcon(Icons.chat_rounded, 'WhatsApp', AppColors.success, 'web.whatsapp.com'),
                            _buildShortcutIcon(Icons.facebook_rounded, 'Facebook', Colors.blue, 'facebook.com'),
                            _buildShortcutIcon(Icons.music_note_rounded, 'TikTok', Colors.pinkAccent, 'tiktok.com'),
                          ],
                        ),
                      ),
                      const SizedBox(height: 24),

                      // Zone de flux
                      Container(
                        width: double.infinity,
                        padding: const EdgeInsets.all(16),
                        margin: const EdgeInsets.symmetric(horizontal: 16),
                        decoration: BoxDecoration(
                          color: AppColors.surfaceDark.withOpacity(0.5),
                          borderRadius: BorderRadius.circular(16),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text('Sponsorisé ou Flux', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12, fontWeight: FontWeight.bold)),
                            const SizedBox(height: 12),
                            Container(
                              height: 200,
                              width: double.infinity,
                              decoration: BoxDecoration(color: AppColors.cardDark.withOpacity(0.8), borderRadius: BorderRadius.circular(12)),
                              child: const Center(child: Icon(Icons.image_outlined, size: 64, color: AppColors.textSecondaryDark)),
                            ),
                          ],
                        ),
                      ),
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
