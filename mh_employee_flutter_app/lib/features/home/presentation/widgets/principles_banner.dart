import 'package:flutter/material.dart';

// Updated colors class with new color scheme
class PrincipleColors {
  static const Map<String, List<Color>> gradients = {
    'en': [Color(0xFF2E7D32), Color(0xFF4CAF50)],  // Green theme
    'cn': [Color(0xFFBD6D0E), Color(0xFFCCB57C)],  // Orange theme
    'my': [Color(0xFF1565C0), Color(0xFF42A5F5)],  // Blue theme
  };

  static Color getAppBarColor(String language) {
    switch (language) {
      case 'en':
        return Color(0xFF2E7D32);  // Dark green
      case 'my':
        return Color(0xFF1565C0);  // Blue
      default:  // Chinese (default)
        return Color(0xFFD67F01);  // Orange
    }
  }

  static Color getAccentColor(String language) {
    switch (language) {
      case 'en':
        return Color(0xFF4CAF50);  // Light green
      case 'my':
        return Color(0xFF42A5F5);  // Light blue
      default:  // Chinese (default)
        return Color(0xFFFFA747);  // Light orange
    }
  }
}

class PrinciplesBanner extends StatefulWidget {
  final Function(String language) onTap;

  const PrinciplesBanner({
    Key? key,
    required this.onTap,
  }) : super(key: key);

  @override
  _PrinciplesBannerState createState() => _PrinciplesBannerState();
}

class _PrinciplesBannerState extends State<PrinciplesBanner> {
  // Changed initial language to Chinese (1)
  int _currentLanguage = 1; // 0: English, 1: Chinese, 2: Malay

  final List<Map<String, dynamic>> _content = [
    {
      'language': 'en',
      'title': 'The Six Endeavours',
      'subtitle': 'Live a fulfilling life > ',
    },
    {
      'language': 'cn',
      'title': '六项精进',
      'subtitle': '实现美好人生 > ',
    },
    {
      'language': 'my',
      'title': 'Enam Prinsip Hidup',
      'subtitle': 'Hidup sejahtera > ',
    },
  ];

  void _cycleLanguage() {
    setState(() {
      _currentLanguage = (_currentLanguage + 1) % 3;
    });
  }

  @override
  Widget build(BuildContext context) {
    final currentLanguageCode = _content[_currentLanguage]['language'];
    final gradientColors = PrincipleColors.gradients[currentLanguageCode]!;

    return InkWell(
      onTap: () => widget.onTap(currentLanguageCode),
      child: Container(
        margin: const EdgeInsets.symmetric(horizontal: 25, vertical: 10),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: gradientColors,
          ),
          borderRadius: BorderRadius.circular(15),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.1),
              blurRadius: 10,
              offset: const Offset(0, 4),
            ),
          ],
        ),
        child: Stack(
          children: [
            Positioned(
              right: -20,
              top: -20,
              child: Icon(
                Icons.auto_awesome,
                size: 100,
                color: Colors.white.withOpacity(0.1),
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(20),
              child: Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: Colors.white.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: IconButton(
                      icon: const Icon(Icons.language),
                      iconSize: 28,
                      color: Colors.white,
                      onPressed: _cycleLanguage,
                    ),
                  ),
                  const SizedBox(width: 20),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          _content[_currentLanguage]['title'],
                          style: const TextStyle(
                            color: Colors.white,
                            fontSize: 20,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 4),
                        Text(
                          _content[_currentLanguage]['subtitle'],
                          style: TextStyle(
                            color: Colors.white.withOpacity(0.9),
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Icon(
                    Icons.arrow_forward_ios,
                    color: Colors.white.withOpacity(0.7),
                    size: 20,
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
