import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import '../browser/browser_screen.dart';

class MaguyAiScreen extends StatefulWidget {
  final String initialQuery;
  const MaguyAiScreen({super.key, this.initialQuery = ''});

  @override
  State<MaguyAiScreen> createState() => _MaguyAiScreenState();
}

class _MaguyAiScreenState extends State<MaguyAiScreen> {
  late TextEditingController _queryController;

  final List<String> _trendingSearches = [
    '🔥 Nouveautés Afrobeats 2026',
    '🎵 Playlists pour le sport',
    '🎬 Tendances YouTube Actuelles',
    '📱 Vidéos Virales TikTok',
  ];

  @override
  void initState() {
    super.initState();
    _queryController = TextEditingController(text: widget.initialQuery);
  }

  void _search(String query) {
    if (query.trim().isEmpty) return;
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BrowserScreen(initialUrl: query)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        elevation: 0,
        title: const Row(
          children: [
            Icon(Icons.auto_awesome, color: AppColors.secondaryCyan),
            SizedBox(width: 10),
            Text('Maguy IA', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
          ],
        ),
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(16),
            decoration: const BoxDecoration(
              color: AppColors.surfaceDark,
              borderRadius: BorderRadius.only(bottomLeft: Radius.circular(24), bottomRight: Radius.circular(24)),
            ),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.backgroundDark,
                borderRadius: BorderRadius.circular(30),
                border: Border.all(color: AppColors.primaryViolet, width: 1.5),
              ),
              child: Row(
                children: [
                  const Icon(Icons.search, color: AppColors.primaryViolet),
                  const SizedBox(width: 10),
                  Expanded(
                    child: TextField(
                      controller: _queryController,
                      style: const TextStyle(color: Colors.white),
                      autofocus: true,
                      decoration: const InputDecoration(
                        border: InputBorder.none,
                        hintText: 'Demandez à Maguy ou cherchez...',
                        hintStyle: TextStyle(color: AppColors.textSecondaryDark),
                      ),
                      onSubmitted: _search,
                    ),
                  ),
                  IconButton(
                    icon: const Icon(Icons.send_rounded, color: AppColors.secondaryCyan),
                    onPressed: () => _search(_queryController.text),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: const EdgeInsets.all(16),
              children: [
                const Text('MAGUY VOUS SUGGÈRE', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12, fontWeight: FontWeight.bold)),
                const SizedBox(height: 12),
                Wrap(
                  spacing: 8,
                  runSpacing: 8,
                  children: _trendingSearches.map((term) => ActionChip(
                    backgroundColor: AppColors.cardDark,
                    side: BorderSide(color: AppColors.primaryViolet.withOpacity(0.3)),
                    label: Text(term, style: const TextStyle(color: AppColors.textPrimaryDark, fontSize: 12)),
                    onPressed: () {
                      _queryController.text = term;
                      _search(term);
                    },
                  )).toList(),
                ),
                const SizedBox(height: 30),
                Container(
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: AppColors.primaryViolet.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(16),
                    border: Border.all(color: AppColors.primaryViolet.withOpacity(0.3)),
                  ),
                  child: const Row(
                    children: [
                      Icon(Icons.graphic_eq_rounded, color: AppColors.primaryViolet, size: 32),
                      SizedBox(width: 16),
                      Expanded(
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text('Analyse de vos goûts active', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                            Text('Maguy apprend vos styles musicaux pour personnaliser vos flux.', style: TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
                          ],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
