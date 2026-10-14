import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/ad_service.dart';

class LibraryScreen extends StatelessWidget {
  const LibraryScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Bibliothèque')),
      body: const Column(
        children: [
          Expanded(child: Center(child: Text('Fichiers locaux ici', style: TextStyle(color: Colors.white)))),
          DiscreetBannerAd(placementName: 'Bibliothèque'),
        ],
      ),
    );
  }
}
