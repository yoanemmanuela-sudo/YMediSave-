import 'dart:async';
import 'package:flutter/material.dart';
import '../constants/app_colors.dart';

class AdService extends ChangeNotifier {
  static final AdService instance = AdService._internal();
  AdService._internal();

  DateTime? _rewardExpiryTime;
  int _navigationTransitionCount = 0;
  DateTime? _lastInterstitialTime;

  bool get isRewardActive {
    if (_rewardExpiryTime == null) return false;
    if (DateTime.now().isAfter(_rewardExpiryTime!)) {
      _rewardExpiryTime = null;
      return false;
    }
    return true;
  }

  String get remainingRewardTimeText {
    if (!isRewardActive) return 'Inactif';
    final diff = _rewardExpiryTime!.difference(DateTime.now());
    final minutes = diff.inMinutes;
    final seconds = diff.inSeconds % 60;
    return '${minutes}m ${seconds}s restantes';
  }

  Future<void> showRewardedAdDialog(BuildContext context) async {
    int secondsLeft = 5;
    Timer? timer;

    final bool? completed = await showDialog<bool>(
      context: context,
      barrierDismissible: false,
      builder: (ctx) {
        return StatefulBuilder(
          builder: (context, setDialogState) {
            timer ??= Timer.periodic(const Duration(seconds: 1), (t) {
              if (secondsLeft > 0) {
                setDialogState(() {
                  secondsLeft--;
                });
              } else {
                t.cancel();
              }
            });

            return AlertDialog(
              backgroundColor: AppColors.surfaceDark,
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
              title: const Row(
                children: [
                  Icon(Icons.play_circle_fill_rounded, color: AppColors.secondaryCyan),
                  SizedBox(width: 8),
                  Expanded(
                    child: Text(
                      'Vidéo Sponsorisée [TEST]',
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                    ),
                  ),
                ],
              ),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  Container(
                    height: 140,
                    width: double.infinity,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: [AppColors.accentGradientStart, AppColors.accentGradientEnd],
                      ),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Icon(Icons.stars_rounded, size: 48, color: Colors.white),
                        const SizedBox(height: 8),
                        Text(
                          secondsLeft > 0
                              ? 'Récompense dans $secondsLeft s...'
                              : 'Récompense débloquée !',
                          style: const TextStyle(
                            color: Colors.white,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ],
                    ),
                  ),
                  const SizedBox(height: 14),
                  const Text(
                    'Avantage débloqué : Mode Sans Bannière + Téléchargements rapides pendant 30 minutes.\n\n(Note : Cette récompense est une fonctionnalité interne à l\'application et n\'a aucune valeur monétaire réelle).',
                    style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    timer?.cancel();
                    Navigator.of(ctx).pop(false);
                  },
                  child: const Text('Fermer', style: TextStyle(color: AppColors.textSecondaryDark)),
                ),
                ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: secondsLeft == 0 ? AppColors.success : AppColors.cardDark,
                    foregroundColor: Colors.white,
                  ),
                  onPressed: secondsLeft == 0
                      ? () {
                          timer?.cancel();
                          Navigator.of(ctx).pop(true);
                        }
                      : null,
                  child: Text(secondsLeft == 0 ? 'Activer (30 min)' : 'Patientez ($secondsLeft)'),
                ),
              ],
            );
          },
        );
      },
    );

    timer?.cancel();

    if (completed == true) {
      _rewardExpiryTime = DateTime.now().add(const Duration(minutes: 30));
      notifyListeners();
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Mode Premium temporaire activé pour 30 minutes ! Bannières masquées.'),
            backgroundColor: AppColors.success,
            behavior: SnackBarBehavior.floating,
          ),
        );
      }
    }
  }

  void registerNavigationTransition(BuildContext context) {
    if (isRewardActive) return;

    _navigationTransitionCount++;
    if (_navigationTransitionCount < 6) return;

    if (_lastInterstitialTime != null &&
        DateTime.now().difference(_lastInterstitialTime!).inMinutes < 3) {
      return;
    }

    _navigationTransitionCount = 0;
    _lastInterstitialTime = DateTime.now();

    _showInterstitialAdDialog(context);
  }

  void _showInterstitialAdDialog(BuildContext context) {
    showDialog(
      context: context,
      barrierDismissible: true,
      builder: (ctx) {
        return Dialog.fullscreen(
          backgroundColor: AppColors.backgroundDark,
          child: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Container(
                        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                        decoration: BoxDecoration(
                          color: AppColors.cardDark,
                          borderRadius: BorderRadius.circular(6),
                        ),
                        child: const Text(
                          'Annonce Plein Écran [TEST]',
                          style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12),
                        ),
                      ),
                      IconButton(
                        icon: const Icon(Icons.close_rounded, color: Colors.white, size: 28),
                        onPressed: () => Navigator.of(ctx).pop(),
                      ),
                    ],
                  ),
                  Column(
                    children: [
                      Container(
                        width: 90,
                        height: 90,
                        decoration: BoxDecoration(
                          color: AppColors.primaryViolet.withOpacity(0.2),
                          shape: BoxShape.circle,
                        ),
                        child: const Icon(Icons.campaign_rounded, size: 48, color: AppColors.secondaryCyan),
                      ),
                      const SizedBox(height: 20),
                      const Text(
                        'Publicité de Transition',
                        style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: AppColors.textPrimaryDark,
                        ),
                        textAlign: TextAlign.center,
                      ),
                      const SizedBox(height: 10),
                      const Text(
                        'Affichée occasionnellement lors d\'une transition naturelle entre deux onglets, jamais pendant une lecture vidéo.',
                        style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 13),
                        textAlign: TextAlign.center,
                      ),
                    ],
                  ),
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: AppColors.primaryViolet,
                        foregroundColor: Colors.white,
                        padding: const EdgeInsets.symmetric(vertical: 14),
                      ),
                      onPressed: () => Navigator.of(ctx).pop(),
                      child: const Text('Continuer vers YMediSave'),
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}

class DiscreetBannerAd extends StatelessWidget {
  final String placementName;

  const DiscreetBannerAd({
    super.key,
    required this.placementName,
  });

  @override
  Widget build(BuildContext context) {
    return ListenableBuilder(
      listenable: AdService.instance,
      builder: (context, _) {
        if (AdService.instance.isRewardActive) {
          return const SizedBox.shrink();
        }

        return Container(
          width: double.infinity,
          margin: const EdgeInsets.only(top: 8, bottom: 4),
          padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
          decoration: BoxDecoration(
            color: AppColors.surfaceDark,
            borderRadius: BorderRadius.circular(10),
            border: Border.all(color: AppColors.cardDark),
          ),
          child: Row(
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
                decoration: BoxDecoration(
                  color: AppColors.primaryViolet.withOpacity(0.25),
                  borderRadius: BorderRadius.circular(4),
                ),
                child: const Text(
                  'Ad • Test',
                  style: TextStyle(
                    color: AppColors.secondaryCyan,
                    fontSize: 10,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              const SizedBox(width: 10),
              Expanded(
                child: Text(
                  'Bannière discrète ($placementName) • Soutient YMediSave',
                  style: const TextStyle(
                    color: AppColors.textSecondaryDark,
                    fontSize: 11,
                  ),
                  overflow: TextOverflow.ellipsis,
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
