import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';

class SmartPlayerScreen extends StatefulWidget {
  final String title;
  final String author;
  final bool isVideo;

  const SmartPlayerScreen({
    super.key,
    required this.title,
    required this.author,
    this.isVideo = false,
  });

  @override
  State<SmartPlayerScreen> createState() => _SmartPlayerScreenState();
}

class _SmartPlayerScreenState extends State<SmartPlayerScreen> {
  bool _isPlaying = true;
  bool _isBackgroundMode = true;
  bool _isEqActive = false;
  double _progress = 0.3;

  // Couleurs dynamiques extraites de la jaquette (Simulation)
  final Color _dominantColor = const Color(0xFF6A1B9A); // Violet profond

  void _togglePlay() {
    setState(() => _isPlaying = !_isPlaying);
  }

  void _toggleEq() {
    setState(() => _isEqActive = !_isEqActive);
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(_isEqActive ? 'Maguy : Égaliseur Audio Spatial Activé 🎧' : 'Égaliseur Standard'),
        backgroundColor: AppColors.primaryViolet,
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      // Le fond s'adapte à la couleur de la jaquette !
      backgroundColor: _dominantColor.withOpacity(0.1),
      body: Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [_dominantColor.withOpacity(0.4), AppColors.backgroundDark],
            stops: const [0.0, 0.6],
          ),
        ),
        child: SafeArea(
          child: Column(
            children: [
              // En-tête
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.keyboard_arrow_down_rounded, color: Colors.white, size: 32),
                      onPressed: () => Navigator.pop(context),
                    ),
                    const Column(
                      children: [
                        Text('LECTURE EN COURS', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 10, letterSpacing: 1.5)),
                        SizedBox(height: 4),
                        Text('Playlist Favoris', style: TextStyle(color: Colors.white, fontSize: 12, fontWeight: FontWeight.bold)),
                      ],
                    ),
                    IconButton(
                      icon: const Icon(Icons.more_vert_rounded, color: Colors.white),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Jaquette ou Vidéo
              Container(
                width: MediaQuery.of(context).size.width * 0.85,
                height: MediaQuery.of(context).size.width * 0.85,
                decoration: BoxDecoration(
                  color: AppColors.cardDark,
                  borderRadius: BorderRadius.circular(24),
                  boxShadow: [
                    BoxShadow(color: _dominantColor.withOpacity(0.4), blurRadius: 30, offset: const Offset(0, 10)),
                  ],
                ),
                child: widget.isVideo
                    ? const Center(child: Icon(Icons.play_circle_outline_rounded, size: 80, color: Colors.white))
                    : const Center(child: Icon(Icons.music_note_rounded, size: 80, color: AppColors.secondaryCyan)),
              ),

              const SizedBox(height: 40),

              // Informations et Bouton Favoris
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  crossAxisAlignment: CrossAxisAlignment.center,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            widget.title,
                            style: const TextStyle(color: Colors.white, fontSize: 24, fontWeight: FontWeight.bold),
                            maxLines: 1, overflow: TextOverflow.ellipsis,
                          ),
                          const SizedBox(height: 4),
                          Text(
                            widget.author,
                            style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 16),
                          ),
                        ],
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.favorite_rounded, color: AppColors.error, size: 28),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 30),

              // Barre de progression
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0),
                child: Column(
                  children: [
                    SliderTheme(
                      data: SliderThemeData(
                        trackHeight: 4,
                        thumbShape: const RoundSliderThumbShape(enabledThumbRadius: 6),
                        activeTrackColor: Colors.white,
                        inactiveTrackColor: Colors.white.withOpacity(0.2),
                        thumbColor: Colors.white,
                      ),
                      child: Slider(
                        value: _progress,
                        onChanged: (val) => setState(() => _progress = val),
                      ),
                    ),
                    const Padding(
                      padding: EdgeInsets.symmetric(horizontal: 12.0),
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.spaceBetween,
                        children: [
                          Text('1:14', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
                          Text('3:42', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
                        ],
                      ),
                    ),
                  ],
                ),
              ),

              const Spacer(),

              // Contrôles de lecture
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 32.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    IconButton(
                      icon: const Icon(Icons.shuffle_rounded, color: AppColors.textSecondaryDark),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_previous_rounded, color: Colors.white, size: 36),
                      onPressed: () {},
                    ),
                    GestureDetector(
                      onTap: _togglePlay,
                      child: Container(
                        width: 72, height: 72,
                        decoration: BoxDecoration(color: _dominantColor, shape: BoxShape.circle),
                        child: Icon(_isPlaying ? Icons.pause_rounded : Icons.play_arrow_rounded, color: Colors.white, size: 36),
                      ),
                    ),
                    IconButton(
                      icon: const Icon(Icons.skip_next_rounded, color: Colors.white, size: 36),
                      onPressed: () {},
                    ),
                    IconButton(
                      icon: const Icon(Icons.repeat_rounded, color: AppColors.textSecondaryDark),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),

              const SizedBox(height: 20),

              // Fonctions Spéciales Maguy
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 16.0),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    // Bouton Arrière-plan
                    ActionChip(
                      backgroundColor: _isBackgroundMode ? AppColors.secondaryCyan.withOpacity(0.2) : Colors.transparent,
                      side: BorderSide(color: _isBackgroundMode ? AppColors.secondaryCyan : AppColors.textSecondaryDark),
                      avatar: Icon(Icons.screen_lock_portrait_rounded, size: 16, color: _isBackgroundMode ? AppColors.secondaryCyan : AppColors.textSecondaryDark),
                      label: Text('Fond', style: TextStyle(color: _isBackgroundMode ? AppColors.secondaryCyan : AppColors.textSecondaryDark, fontSize: 12)),
                      onPressed: () {
                        setState(() => _isBackgroundMode = !_isBackgroundMode);
                        ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text('Lecture écran verrouillé : ${_isBackgroundMode ? "Activé" : "Désactivé"}'), backgroundColor: AppColors.cardDark));
                      },
                    ),
                    // Bouton Égaliseur Maguy
                    ActionChip(
                      backgroundColor: _isEqActive ? AppColors.primaryViolet.withOpacity(0.2) : Colors.transparent,
                      side: BorderSide(color: _isEqActive ? AppColors.primaryViolet : AppColors.textSecondaryDark),
                      avatar: Icon(Icons.graphic_eq_rounded, size: 16, color: _isEqActive ? AppColors.primaryViolet : AppColors.textSecondaryDark),
                      label: Text('Maguy EQ', style: TextStyle(color: _isEqActive ? AppColors.primaryViolet : AppColors.textSecondaryDark, fontSize: 12)),
                      onPressed: _toggleEq,
                    ),
                    // Bouton Paroles
                    ActionChip(
                      backgroundColor: Colors.transparent,
                      side: const BorderSide(color: AppColors.textSecondaryDark),
                      avatar: const Icon(Icons.lyrics_rounded, size: 16, color: AppColors.textSecondaryDark),
                      label: const Text('Paroles', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
                      onPressed: () {},
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
