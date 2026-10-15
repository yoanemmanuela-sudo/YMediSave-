import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../home/home_screen.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  late Animation<double> _pulseAnimation;
  late Animation<double> _spinAnimation;
  
  // Variable pour contrôler l'apparition de la signature
  bool _showSignature = false;

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(vsync: this, duration: const Duration(seconds: 3));
    _pulseAnimation = Tween<double>(begin: 0.8, end: 1.1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    _spinAnimation = Tween<double>(begin: 0, end: 1).animate(CurvedAnimation(parent: _controller, curve: Curves.easeInOut));
    
    _controller.repeat(reverse: true);

    // Fait apparaître Yo'art Tech après 2 secondes
    Future.delayed(const Duration(seconds: 2), () {
      if (mounted) {
        setState(() {
          _showSignature = true;
        });
      }
    });

    // Navigue vers l'accueil après 5 secondes (laisse le temps d'admirer le logo)
    Future.delayed(const Duration(seconds: 5), () {
      if (mounted) {
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => const HomeScreen()));
      }
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Spacer(),
            // L'ANIMATION DU LOGO
            SizedBox(
              width: 250, height: 250,
              child: Stack(
                alignment: Alignment.center,
                children: [
                  // Triangle Externe Violet
                  Icon(Icons.change_history_rounded, size: 200, color: AppColors.primaryViolet.withOpacity(0.8)),
                  // Triangle Interne Bleu
                  const Icon(Icons.change_history_rounded, size: 140, color: AppColors.secondaryCyan),
                  // Le Y au centre
                  ScaleTransition(
                    scale: _pulseAnimation,
                    child: ShaderMask(
                      shaderCallback: (bounds) => const LinearGradient(
                        colors: [AppColors.primaryViolet, AppColors.secondaryCyan],
                        begin: Alignment.topCenter, end: Alignment.bottomCenter,
                      ).createShader(bounds),
                      child: const Text('Y', style: TextStyle(fontSize: 80, fontWeight: FontWeight.w900, color: Colors.white)),
                    ),
                  ),
                  // Les 4 icônes animées autour
                  RotationTransition(
                    turns: _spinAnimation,
                    child: SizedBox(
                      width: 220, height: 220,
                      child: Stack(
                        children: [
                          Positioned(top: 0, left: 93, child: _buildMediaIcon(Icons.music_note_rounded, Colors.pinkAccent)),
                          Positioned(bottom: 0, left: 93, child: _buildMediaIcon(Icons.download_rounded, Colors.green)),
                          Positioned(left: 0, top: 93, child: _buildMediaIcon(Icons.public, Colors.blue)),
                          Positioned(right: 0, top: 93, child: _buildMediaIcon(Icons.play_arrow_rounded, Colors.red)),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            const Text('YMediSave', style: TextStyle(fontSize: 32, fontWeight: FontWeight.bold, color: Colors.white, letterSpacing: 2)),
            const Spacer(),
            
            // BRANDING AUDIO GOOGLE
            const Icon(Icons.verified_rounded, color: AppColors.secondaryCyan, size: 24),
            const SizedBox(height: 8),
            const Text(
              'Son clair et immersif',
              style: TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const Text(
              'Qualité audio signée Google',
              style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 14),
            ),
            const SizedBox(height: 30),

            // L'APPARITION DE TA SIGNATURE YO'ART TECH
            AnimatedOpacity(
              opacity: _showSignature ? 1.0 : 0.0,
              duration: const Duration(seconds: 2), // Effet de fondu très doux
              child: const Padding(
                padding: EdgeInsets.only(bottom: 20),
                child: Text(
                  'Créé par Yo\'art Tech',
                  style: TextStyle(
                    color: AppColors.primaryViolet, 
                    fontSize: 15, 
                    fontWeight: FontWeight.bold, 
                    letterSpacing: 1.5,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildMediaIcon(IconData icon, Color color) {
    return Container(
      padding: const EdgeInsets.all(8),
      decoration: BoxDecoration(color: AppColors.cardDark, shape: BoxShape.circle, border: Border.all(color: color, width: 2)),
      child: Icon(icon, color: color, size: 18),
    );
  }
}
