import 'package:flutter/material.dart';
import 'package:katholiks/utils/app_colors.dart';

class CommunityPage extends StatelessWidget {
  const CommunityPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Icon(Icons.groups_rounded,
                size: 80, color: AppColors.primary),
            const SizedBox(height: 16),
            Text(
              'Comunidade',
              style: TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white
                    : const Color(0xFF2D2D2D),
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Em breve: Grupos de oração,\npedidos e compartilhamento',
              textAlign: TextAlign.center,
              style: TextStyle(
                fontSize: 16,
                color: Theme.of(context).brightness == Brightness.dark
                    ? Colors.white.withOpacity(0.8)
                    : const Color(0xFF666666),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
