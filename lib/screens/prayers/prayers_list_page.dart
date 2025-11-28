import 'package:flutter/material.dart';

class PrayersListPage extends StatelessWidget {
  final List<Map<String, String>> prayers = [
    {'title': 'Sinal da cruz', 'content': ''},
    {'title': 'Glória', 'content': ''},
    {'title': 'Pai-nosso', 'content': ''},
    {'title': 'Ave-maria', 'content': ''},
    {'title': 'Credo I - Símbolo dos apóstolos', 'content': ''},
    {'title': 'Credo Niceno-constantinopolitano', 'content': ''},
    {'title': 'Oração da manhã (I)', 'content': ''},
    {'title': 'Oração da manhã (II)', 'content': ''},
    {'title': 'Oferecimento do dia', 'content': ''},
    {'title': 'Consagração a Nossa Senhora', 'content': ''},
    {'title': 'Ao santo anjo da guarda', 'content': ''},
    {'title': 'Ato de fé', 'content': ''},
    {'title': 'Ato de esperança', 'content': ''},
    {'title': 'Ato de caridade', 'content': ''},
    {'title': 'Oração do Meio-dia', 'content': ''},
  ];

  PrayersListPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Orações'),
      ),
      body: ListView.separated(
        itemCount: prayers.length,
        separatorBuilder: (context, index) => const Divider(height: 1),
        itemBuilder: (context, index) {
          final prayer = prayers[index];
          return ListTile(
            title: Text(prayer['title'] ?? ''),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => PrayerDetailPage(
                    title: prayer['title'] ?? '',
                    content: prayer['content'] ?? '',
                  ),
                ),
              );
            },
          );
        },
      ),
    );
  }
}

class PrayerDetailPage extends StatelessWidget {
  final String title;
  final String content;

  const PrayerDetailPage(
      {super.key, required this.title, required this.content});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text(title),
      ),
      body: Padding(
        padding: const EdgeInsets.all(24.0),
        child: Text(
          content.isNotEmpty ? content : 'Em breve...',
          style: const TextStyle(fontSize: 16),
        ),
      ),
    );
  }
}
