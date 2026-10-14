import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../../core/services/ad_service.dart';

class DownloadsScreen extends StatelessWidget {
  const DownloadsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Téléchargements')),
      body: const Column(
        children: [
          Expanded(child: Center(child: Text('Progression', style: TextStyle(color: Colors.white)))),
          DiscreetBannerAd(placementName: 'Téléchargements'),
        ],
      ),
    );
  }
}
