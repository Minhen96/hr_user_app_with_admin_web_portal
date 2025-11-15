import 'package:flutter/material.dart';

import 'package:mh_employee_app/features/home/presentation/widgets/principles_banner.dart';

class PrinciplesDetailScreen extends StatelessWidget {
  final String language;

  const PrinciplesDetailScreen({
    Key? key,
    required this.language,
  }) : super(key: key);

  // Translations map containing principles in different languages
  static const Map<String, List<Map<String, String>>> translations = {
    'cn': [ // Chinese
      {
        'title': '付出不亚于任何人的努力',
        'content': '努力钻研，比谁都刻苦，而且契而不舍，持续不断，精益求精，有闲工夫发牢骚，不如前进一步，哪怕只是一寸，努力向上提升。'
      },
      {
        'title': '要谦虚，不要骄傲',
        'content': '"谦受益"是中国古话，谦虚的心能够唤来幸福，还能赢得他人尊重，提升团队土气 ; 骄傲让人讨厌，失去人心，给人带来懈怠和失败。'
      },
      {
        'title': '要每天反省',
        'content': '每天检点自己的思想和行为，是不是自私自利，有没有卑怯的举止 ，发自内心的反省，有错即改。'
      },
      {
        'title': '活着就要感谢',
        'content': '感谢是万能药，感恩之心治百病，有时间抱怨，不如改变，活着，就已经是幸福，对周围的一切要心怀感恩，经常说"谢谢"。'
      },
      {
        'title': '积善行，思利他',
        'content': '积善之家，必有余庆。凡事要动机至善，以利他之心待人处事，言行之间留意关爱别人，真正为对方好，才是大善。'
      },
      {
        'title': '不要有感性的烦恼',
        'content': '不要烦恼，不要焦躁，不要总是忿忿不平，人生的意义在于不断地磨练灵魂，当困难和挑战来临时，拿出勇气，勇敢面对，不忘初心， 努力做好该做的事。'
      },
    ],
    'en': [ // English
      {
        'title': 'Strive Harder Than Anyone Else.',
        'content': 'Strive harder than anyone else, continue working persistently towards perfection. Avoid wasting time on complaints。 Take a step forward, no matter how small it may be.'
      },
      {
        'title': 'Be Humble, Not to Be Arrogant.',
        'content': 'A Chinese proverb says, “Benefits go to the humble”. Humble attracts happiness, earns respect from others, and raises the morale of the team. Whereas, Arrogance leads to disgust, loses of trust from others, and causes complacency and failure.'
      },
      {
        'title': 'Reflect Upon Yourself Every Day.',
        'content': 'Reflecting upon our thoughts and actions every day. Check for any selfishness or cowardly behavior and make immediate corrections if you find any.'
      },
      {
        'title': 'Being Grateful to Be Alive.',
        'content': 'Gratitude is a powerful remedy for all problems. Complaining won\'t change anything. Be happy to be alive, appreciate everything around you, and always say "thank you."'
      },
      {
        'title': 'Be Kind and Do Good Deeds.',
        'content': 'Do good deeds and serve others with kindness without expectations. A person who is kind towards others will gain joy and prosperity. Acts of kindness restores the faith in humanity and makes the world a better place.'
      },
      {
        'title': 'Don\'t Be Bothered by emotions.',
        'content': 'Stop feeling frustrated and restless. Life may seem unfair, but the purpose is to strengthen our soul. Face challenges with courage, give your best effort. Stay true to your original intention and strive hard to do what is right.'
      },
    ],
    'my': [ // Malay
      {
        'title': 'Sanggup Berusaha Lebih Daripada Orang Lain.',
        'content': 'Berusaha dengan gigih lebih daripada orang lain. Tabah, tidak pernah mengenal erti putus asa dan sentiasa meningkatkan diri sendiri,daripada membazir masa untuk mengadu, baik kita terus maju ke hadapan walaupun hanya selangkah.'
      },
      {
        'title': 'Bersifat Rendah Hati Dan Tidak Sombong.',
        'content': '“Rendah hati akan dapat manfaat” ialah pepatah yang bererti kerendahan hati dapat memiliki kebahagian, dan dapat mematangkan fikiran.Sombong boleh membawa kegagalan. Bakat adalah kurniaan Tuhan. Membantu orang dengan bakat yang ada sebagai keutamaan, dan selepas itu baru membantu diri sendiri.'
      },
      {
        'title': 'Sentiasa Refleksi diri Sendiri.',
        'content': 'Sentiasa mengkaji diri dari segi fikiran dan tingkah laku, focus ke dalam diri sendiri, tenangkan hati serta jangan mengulangi kesilapan yang sama.'
      },
      {
        'title': 'Hidup Dengan Penuh Berterima Kasih.',
        'content': 'Selagi masih hidup, itu adalah satu kebahagian. “Berterima Kasih” seperti air bawah tanah sebagai menyuburkan asas moral saya. Selagi kita masih hidup, kita haruslah berterima kasih.'
      },
      {
        'title': 'Membantu Orang lain Secara Sukarela.',
        'content': 'Apabila kita membuat kerja amal, kita juga akan dapat balasan yang baik. Membantu orang dengan tindakan dan perkataan. Jujur dengan setiap orang sekiranya kita buat demi kebaikan dia.'
      },
      {
        'title': 'Tiada Masalah Emosi.',
        'content': 'Jangan ada perasaan yang gelisah dan risau. Kehidupan memang penuh dengan rintangan, Selagi kita masih hidup pasti akan menghadapi cabaran. Jangan mengelak, menghadapi secara positif. Jangan lupa niat asal dan berusaha untuk melakukan perkara yang betul.'
      },
    ],
    // Add more languages as needed
  };

  @override
  Widget build(BuildContext context) {
    final principles = translations[language] ?? translations['en']!;
    final isRTL = false; // Add RTL support if needed

    return Directionality(
      textDirection: isRTL ? TextDirection.rtl : TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(
          title: Text(_getTitle(language)),
          backgroundColor: PrincipleColors.getAppBarColor(language),
        ),
        body: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: principles.length,
          itemBuilder: (context, index) {
            return Card(
              elevation: 4,
              margin: const EdgeInsets.only(bottom: 16),
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Row(
                      children: [
                        Container(
                          padding: const EdgeInsets.all(8),
                          decoration: BoxDecoration(
                            color: PrincipleColors.getAccentColor(language),
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Text(
                            '${index + 1}',
                            style: const TextStyle(
                              color: Colors.white,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            principles[index]['title']!,
                            style: const TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                            ),
                          ),
                        ),
                      ],
                    ),
                    const SizedBox(height: 12),
                    Text(
                      principles[index]['content']!,
                      style: const TextStyle(
                        fontSize: 16,
                        height: 1.5,
                      ),
                    ),
                  ],
                ),
              ),
            );
          },
        ),
      ),
    );
  }

  String _getTitle(String language) {
    switch (language) {
      case 'cn':
        return '六项精进';
      case 'my':
        return 'Enam Prinsip Hidup';
      default:
        return 'The Six Endeavours';
    }
  }
}
