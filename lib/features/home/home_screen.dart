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

  void _showDemoMessage(String feature) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('[DÉMO] $feature'), backgroundColor: AppColors.primaryViolet),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('YMediSave - Accueil')),
      body: Column(
        children: [
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('Prototype YMediSave (Étape B)', style: TextStyle(color: Colors.white)),
                ElevatedButton(
                  onPressed: () => AdService.instance.showRewardedAdDialog(context),
                  child: const Text('Tester la pub récompensée'),
                ),
              ],
            ),
          ),
          const DiscreetBannerAd(placementName: 'Accueil'),
        ],
      ),
    );
  }
}
