import 'package:flutter/material.dart';
import '../../core/constants/app_colors.dart';
import 'browser_screen.dart';

class SitesDirectoryScreen extends StatelessWidget {
  const SitesDirectoryScreen({super.key});

  void _openSite(BuildContext context, String url) {
    Navigator.push(
      context,
      MaterialPageRoute(builder: (context) => BrowserScreen(initialUrl: url)),
    );
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 4,
      child: Scaffold(
        backgroundColor: AppColors.backgroundDark,
        appBar: AppBar(
          backgroundColor: AppColors.surfaceDark,
          title: const Text('Annuaire des sites', style: TextStyle(fontWeight: FontWeight.bold)),
          bottom: const TabBar(
            isScrollable: true,
            indicatorColor: AppColors.primaryViolet,
            labelColor: AppColors.primaryViolet,
            unselectedLabelColor: AppColors.textSecondaryDark,
            tabs: [
              Tab(text: 'Social'),
              Tab(text: 'Informatif'),
              Tab(text: 'Favoris'),
              Tab(text: 'Adultes (+18)'),
            ],
          ),
        ),
        body: TabBarView(
          children: [
            // Onglet SOCIAL
            _buildSiteList(context, [
              {'name': 'Facebook', 'url': 'https://facebook.com', 'icon': Icons.facebook},
              {'name': 'TikTok', 'url': 'https://tiktok.com', 'icon': Icons.music_note},
              {'name': 'Instagram', 'url': 'https://instagram.com', 'icon': Icons.camera_alt},
            ]),
            
            // Onglet INFORMATIF
            _buildSiteList(context, [
              {'name': 'Google Actualités', 'url': 'https://news.google.com', 'icon': Icons.article},
              {'name': 'Wikipédia', 'url': 'https://fr.wikipedia.org', 'icon': Icons.public},
            ]),
            
            // Onglet FAVORIS
            _buildSiteList(context, [
              {'name': 'YouTube', 'url': 'https://youtube.com', 'icon': Icons.video_library},
              {'name': 'Mon site préféré', 'url': 'https://google.com', 'icon': Icons.star},
            ]),
            
            // Onglet ADULTES (À remplir par tes soins)
            _buildSiteList(context, [
              {'name': 'Site Adulte 1', 'url': 'https://www.pornhub.com/', 'icon': Icons.warning_amber_rounded},
              {'name': 'Site Adulte 2', 'url': 'https://www.xv-videos.com/', 'icon': Icons.warning_amber_rounded},
              {'name': 'Site Adulte 3', 'url': 'https://www.youporn.com/', 'icon': Icons.warning_amber_rounded},
              // Ajoute tes 7 autres sites ici en copiant la ligne ci-dessus
            ]),
          ],
        ),
      ),
    );
  }

  Widget _buildSiteList(BuildContext context, List<Map<String, dynamic>> sites) {
    return ListView.builder(
      padding: const EdgeInsets.all(12),
      itemCount: sites.length,
      itemBuilder: (context, index) {
        final site = sites[index];
        return Card(
          color: AppColors.cardDark,
          margin: const EdgeInsets.only(bottom: 8),
          child: ListTile(
            leading: Icon(site['icon'], color: AppColors.secondaryCyan),
            title: Text(site['name'], style: const TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            subtitle: Text(site['url'], style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 12)),
            trailing: const Icon(Icons.arrow_forward_ios_rounded, size: 14, color: AppColors.textSecondaryDark),
            onTap: () => _openSite(context, site['url']),
          ),
        );
      },
    );
  }
}
