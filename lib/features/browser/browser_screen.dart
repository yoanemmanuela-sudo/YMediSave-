import 'package:flutter/material.dart';
import 'package:webview_flutter/webview_flutter.dart';
import '../../core/constants/app_colors.dart';

class BrowserScreen extends StatefulWidget {
  final String initialUrl;
  const BrowserScreen({super.key, required this.initialUrl});

  @override
  State<BrowserScreen> createState() => _BrowserScreenState();
}

class _BrowserScreenState extends State<BrowserScreen> {
  late final WebViewController _controller;
  bool _isLoading = true;
  String _currentTitle = 'Chargement...';

  @override
  void initState() {
    super.initState();
    
    // Le Moteur "Sniffer" Yo'art Tech
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      ..setNavigationDelegate(
        NavigationDelegate(
          onPageStarted: (String url) {
            setState(() => _isLoading = true);
          },
          onPageFinished: (String url) async {
            final title = await _controller.getTitle();
            setState(() {
              _isLoading = false;
              _currentTitle = title ?? url;
            });
          },
          onNavigationRequest: (NavigationRequest request) {
            final url = request.url.toLowerCase();
            // Détection magique des fichiers médias !
            if (url.endsWith('.mp4') || url.endsWith('.mp3') || url.endsWith('.webm')) {
              _showDownloadDialog(request.url);
              return NavigationDecision.prevent; // Bloque la page et propose de télécharger
            }
            return NavigationDecision.navigate;
          },
        ),
      )
      ..loadRequest(Uri.parse(_formatUrl(widget.initialUrl)));
  }

  String _formatUrl(String url) {
    if (url.startsWith('http://') || url.startsWith('https://')) return url;
    if (url.contains('.') && !url.contains(' ')) return 'https://$url';
    return 'https://www.google.com/search?q=$url';
  }

  void _showDownloadDialog(String url) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: AppColors.surfaceDark,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        title: const Row(
          children: [
            Icon(Icons.download_rounded, color: AppColors.secondaryCyan),
            SizedBox(width: 10),
            Text('Média détecté !', style: TextStyle(color: Colors.white, fontSize: 18)),
          ],
        ),
        content: Text(
          "Le Sniffer Yo'art Tech a trouvé un fichier multimédia.\nVoulez-vous le télécharger ?\n\nLien : $url",
          style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 13),
          maxLines: 5,
          overflow: TextOverflow.ellipsis,
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('Annuler', style: TextStyle(color: Colors.grey)),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.primaryViolet),
            onPressed: () {
              Navigator.pop(context);
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text('Le fichier a été ajouté aux téléchargements.'),
                  backgroundColor: AppColors.success,
                ),
              );
            },
            child: const Text('Télécharger', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.backgroundDark,
      appBar: AppBar(
        backgroundColor: AppColors.surfaceDark,
        title: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(_currentTitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: Colors.white)),
            if (_isLoading) 
              const LinearProgressIndicator(color: AppColors.primaryViolet, minHeight: 2),
          ],
        ),
        leading: IconButton(
          icon: const Icon(Icons.close_rounded, color: Colors.white),
          onPressed: () => Navigator.pop(context),
        ),
        actions: [
          IconButton(
            icon: const Icon(Icons.arrow_back_ios_new_rounded, size: 18, color: Colors.white),
            onPressed: () async {
              if (await _controller.canGoBack()) _controller.goBack();
            },
          ),
          IconButton(
            icon: const Icon(Icons.refresh_rounded, color: Colors.white),
            onPressed: () => _controller.reload(),
          ),
        ],
      ),
      body: SafeArea(
        child: WebViewWidget(controller: _controller),
      ),
    );
  }
}
