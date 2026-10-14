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

  // --- VARIABLES POUR LE BOUCLIER ADULTE ---
  bool _showAdultWarning = false;
  bool _adultWarningAccepted = false;
  String _pendingAdultUrl = '';

  // Liste de mots-clés de base pour détecter les sites pour adultes
  final List<String> _adultKeywords = ['porn', 'xvideos', 'xnxx', 'xhamster', 'brazzers', 'sex'];

  bool _isAdultContent(String url) {
    final lowerUrl = url.toLowerCase();
    for (var keyword in _adultKeywords) {
      if (lowerUrl.contains(keyword)) return true;
    }
    return false;
  }
  // ------------------------------------------

  @override
  void initState() {
    super.initState();
    
    _controller = WebViewController()
      ..setJavaScriptMode(JavaScriptMode.unrestricted)
      // Déguisement Chrome pour autoriser les connexions Google
      ..setUserAgent('Mozilla/5.0 (Linux; Android 13; SM-S901B) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/112.0.0.0 Mobile Safari/537.36')
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
            final lowerUrl = request.url.toLowerCase();

            // 1. DÉTECTION DU CONTENU ADULTE (Le Bouclier)
            if (!_adultWarningAccepted && _isAdultContent(lowerUrl)) {
              setState(() {
                _pendingAdultUrl = request.url;
                _showAdultWarning = true; // Affiche l'écran d'avertissement
              });
              return NavigationDecision.prevent; // Bloque le chargement du site
            }

            // 2. DÉTECTION DES FICHIERS MÉDIAS (Le Sniffer)
            if (lowerUrl.endsWith('.mp4') || lowerUrl.endsWith('.mp3') || lowerUrl.endsWith('.webm')) {
              _showDownloadDialog(request.url);
              return NavigationDecision.prevent;
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
          "Voulez-vous télécharger ce fichier ?\n\nLien : $url",
          style: const TextStyle(color: AppColors.textSecondaryDark, fontSize: 13),
          maxLines: 4, overflow: TextOverflow.ellipsis,
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
                const SnackBar(content: Text('Le fichier a été ajouté aux téléchargements.'), backgroundColor: AppColors.success),
              );
            },
            child: const Text('Télécharger', style: TextStyle(color: Colors.white)),
          ),
        ],
      ),
    );
  }

  // --- INTERFACE DE L'AVERTISSEMENT ADULTE (Inspirée de ta capture VidMate) ---
  Widget _buildAdultWarningOverlay() {
    return Container(
      color: const Color(0xFF2C3246), // Couleur bleu nuit de ta capture
      width: double.infinity,
      height: double.infinity,
      padding: const EdgeInsets.symmetric(horizontal: 16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          const SizedBox(height: 16),
          Row(
            children: [
              IconButton(
                icon: const Icon(Icons.arrow_back_ios_new_rounded, color: Colors.white, size: 20),
                onPressed: () {
                  setState(() {
                    _showAdultWarning = false;
                    _pendingAdultUrl = '';
                  });
                  if (Navigator.canPop(context)) Navigator.pop(context);
                },
              ),
              const Expanded(
                child: Text(
                  'WARNING',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: Color(0xFFEF5350), fontSize: 18, fontWeight: FontWeight.w900, letterSpacing: 1.0),
                ),
              ),
              const SizedBox(width: 48), // Equilibre l'icône retour
            ],
          ),
          const SizedBox(height: 40),
          Row(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(color: Colors.black, borderRadius: BorderRadius.circular(12)),
                child: const Icon(Icons.close_rounded, color: Color(0xFFEF5350), size: 36),
              ),
              const SizedBox(width: 16),
              const Expanded(
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'THIS SITE MAY CONTAINS CONTENT THAT SOME MAY FIND DISTURBING',
                      style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 13),
                    ),
                    SizedBox(height: 6),
                    Text(
                      'Make sure your age is above 18.',
                      style: TextStyle(color: Color(0xFFEF5350), fontWeight: FontWeight.bold, fontSize: 13),
                    ),
                  ],
                ),
              ),
            ],
          ),
          const SizedBox(height: 30),
          
          // Fausse Publicité (Identique à la capture)
          Container(
            width: double.infinity,
            padding: const EdgeInsets.all(16),
            decoration: BoxDecoration(color: Colors.white, borderRadius: BorderRadius.circular(8)),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text('Sponsorisé', style: TextStyle(color: Colors.grey, fontSize: 12, fontWeight: FontWeight.bold)),
                    Icon(Icons.close_rounded, color: Colors.grey, size: 18),
                  ],
                ),
                const SizedBox(height: 12),
                Container(
                  height: 120,
                  width: double.infinity,
                  color: Colors.grey[300],
                  child: const Center(child: Icon(Icons.sports_soccer_rounded, size: 50, color: Colors.grey)), // Représente le match de foot
                ),
                const SizedBox(height: 20),
                const Text('Fermer cette publicité ?', style: TextStyle(color: Colors.black, fontWeight: FontWeight.w900, fontSize: 14)),
                const SizedBox(height: 16),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    TextButton(
                      onPressed: () {},
                      child: const Text('Annuler', style: TextStyle(color: Colors.black, fontWeight: FontWeight.bold)),
                    ),
                    ElevatedButton(
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFFE53935), // Rouge bouton VidMate
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
                      ),
                      onPressed: () {},
                      child: const Text('Confirmer', style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
                    ),
                  ],
                )
              ],
            ),
          ),
          
          const Spacer(),
          
          // Bouton Continuer Bleu Clair
          SizedBox(
            width: double.infinity,
            height: 48,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: const Color(0xFF039BE5), // Bleu clair VidMate
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(4)),
              ),
              onPressed: () {
                setState(() {
                  _adultWarningAccepted = true; // On ne demande plus l'âge pour cette session
                  _showAdultWarning = false; // On ferme l'avertissement
                  _controller.loadRequest(Uri.parse(_pendingAdultUrl)); // On charge le site
                });
              },
              child: const Text('CONTINUE(PRIVACY RISK)', style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 14)),
            ),
          ),
          const SizedBox(height: 30),
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
        child: Stack(
          children: [
            WebViewWidget(controller: _controller),
            // Si on détecte un site pour adultes, on affiche ton paravent par-dessus le navigateur !
            if (_showAdultWarning) _buildAdultWarningOverlay(),
          ],
        ),
      ),
    );
  }
}
