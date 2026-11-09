import 'dart:async';
import 'dart:math' as math;
import 'package:flutter/material.dart';
import 'package:just_audio/just_audio.dart';

class SplashScreen extends StatefulWidget {
  final Widget nextScreen;
  const SplashScreen({super.key, required this.nextScreen});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> with SingleTickerProviderStateMixin {
  late AnimationController _controller;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 3),
    )..repeat(reverse: true);

    _playStartupSound();

    Timer(const Duration(seconds: 4), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          MaterialPageRoute(builder: (_) => widget.nextScreen),
        );
      }
    });
  }

  Future<void> _playStartupSound() async {
    try {
      await _audioPlayer.setUrl(
        'https://actions.google.com/sounds/v1/cartoon/clang_and_wobble.ogg',
      );
      await _audioPlayer.play();
    } catch (_) {}
  }

  @override
  void dispose() {
    _controller.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF0F0F14),
      body: SafeArea(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const SizedBox(height: 40),
            Center(
              child: AnimatedBuilder(
                animation: _controller,
                builder: (context, child) {
                  return SizedBox(
                    width: 260,
                    height: 260,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        CustomPaint(
                          size: const Size(220, 220),
                          painter: YoartLogoPainter(progress: _controller.value),
                        ),
                        _buildOrbitIcon(Icons.music_note, const Color(0xFFEC4899), 0, _controller.value),
                        _buildOrbitIcon(Icons.play_arrow_rounded, const Color(0xFFEF4444), math.pi / 2, _controller.value),
                        _buildOrbitIcon(Icons.language, const Color(0xFF0EA5E9), math.pi, _controller.value),
                        _buildOrbitIcon(Icons.download_rounded, const Color(0xFF22C55E), 3 * math.pi / 2, _controller.value),
                      ],
                    ),
                  );
                },
              ),
            ),
            Padding(
              padding: const EdgeInsets.only(bottom: 32.0),
              child: Column(
                children: const [
                  Text(
                    'YMediSave',
                    style: TextStyle(
                      color: Colors.white,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 1.5,
                    ),
                  ),
                  SizedBox(height: 8),
                  Text(
                    'Créé par Yo\'art Tech',
                    style: TextStyle(
                      color: Color(0xFF0891B2),
                      fontSize: 14,
                      fontWeight: FontWeight.w600,
                      letterSpacing: 1.2,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildOrbitIcon(IconData icon, Color color, double baseAngle, double progress) {
    final angle = baseAngle + (progress * 0.4);
    const radius = 95.0;
    return Transform.translate(
      offset: Offset(radius * math.cos(angle), radius * math.sin(angle)),
      child: Container(
        padding: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: color.withOpacity(0.18),
          shape: BoxShape.circle,
          border: Border.all(color: color, width: 1.5),
        ),
        child: Icon(icon, color: color, size: 20),
      ),
    );
  }
}

class YoartLogoPainter extends CustomPainter {
  final double progress;
  YoartLogoPainter({required this.progress});

  @override
  void paint(Canvas canvas, Size size) {
    final center = Offset(size.width / 2, size.height / 2);
    final paintViolet = Paint()
      ..color = const Color(0xFF7C3AED)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 6;

    final paintCyan = Paint()
      ..color = const Color(0xFF0891B2)
      ..style = PaintingStyle.stroke
      ..strokeWidth = 4;

    final pathOuter = Path()
      ..moveTo(center.dx, 20)
      ..lineTo(size.width - 20, size.height - 30)
      ..lineTo(20, size.height - 30)
      ..close();
    canvas.drawPath(pathOuter, paintViolet);

    final pathInner = Path()
      ..moveTo(center.dx, size.height - 20)
      ..lineTo(size.width - 30, 40)
      ..lineTo(30, 40)
      ..close();
    canvas.drawPath(pathInner, paintCyan);

    final yPaint = Paint()
      ..shader = const LinearGradient(
        colors: [Color(0xFF7C3AED), Color(0xFF0891B2)],
        begin: Alignment.topLeft,
        end: Alignment.bottomRight,
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height))
      ..style = PaintingStyle.stroke
      ..strokeCap = StrokeCap.round
      ..strokeWidth = 14 + (progress * 3);

    canvas.drawLine(Offset(center.dx - 28, center.dy - 35), center, yPaint);
    canvas.drawLine(Offset(center.dx + 28, center.dy - 35), center, yPaint);
    canvas.drawLine(center, Offset(center.dx, center.dy + 45), yPaint);
  }

  @override
  bool shouldRepaint(covariant YoartLogoPainter oldDelegate) => oldDelegate.progress != progress;
}
