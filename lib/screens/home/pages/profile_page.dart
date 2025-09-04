import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:katholiks/utils/app_colors.dart';
import '../../../providers/theme_provider.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: const Text('Perfil'),
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          children: [
            // Profile Header
            Container(
              padding: const EdgeInsets.all(24),
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  Container(
                    width: 80,
                    height: 80,
                    decoration: const BoxDecoration(
                      gradient: LinearGradient(
                        colors: [AppColors.primary, AppColors.secondary],
                      ),
                      shape: BoxShape.circle,
                    ),
                    child: const Icon(
                      Icons.person,
                      color: Colors.white,
                      size: 40,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'Católico Devoto',
                    style: Theme.of(context).textTheme.headlineSmall,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Membro desde hoje',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: Theme.of(context)
                              .colorScheme
                              .onSurface
                              .withOpacity(0.7),
                        ),
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Settings Section
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildSectionHeader(context, 'Configurações'),
                  _buildThemeMenuItem(context),
                  _buildMenuItem(
                    context,
                    icon: Icons.notifications_outlined,
                    title: 'Notificações',
                    subtitle: 'Lembretes de oração',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.language_outlined,
                    title: 'Idioma',
                    subtitle: 'Português (Brasil)',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Statistics Section
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildSectionHeader(context, 'Estatísticas'),
                  _buildMenuItem(
                    context,
                    icon: Icons.analytics_outlined,
                    title: 'Progresso',
                    subtitle: 'Ver estatísticas detalhadas',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.history_outlined,
                    title: 'Histórico',
                    subtitle: 'Orações realizadas',
                    onTap: () {},
                  ),
                ],
              ),
            ),

            const SizedBox(height: 24),

            // Support Section
            Container(
              decoration: BoxDecoration(
                color: Theme.of(context).cardColor,
                borderRadius: BorderRadius.circular(20),
                boxShadow: [
                  BoxShadow(
                    color: Theme.of(context).shadowColor.withOpacity(0.1),
                    blurRadius: 20,
                    offset: const Offset(0, 8),
                  ),
                ],
              ),
              child: Column(
                children: [
                  _buildSectionHeader(context, 'Suporte'),
                  _buildMenuItem(
                    context,
                    icon: Icons.help_outline,
                    title: 'Ajuda',
                    subtitle: 'FAQ e suporte',
                    onTap: () {},
                  ),
                  _buildMenuItem(
                    context,
                    icon: Icons.info_outline,
                    title: 'Sobre',
                    subtitle: 'Versão 1.0.0',
                    onTap: () {},
                    isLast: true,
                  ),
                ],
              ),
            ),

            const SizedBox(height: 40),
          ],
        ),
      ),
    );
  }

  Widget _buildSectionHeader(BuildContext context, String title) {
    return Padding(
      padding: const EdgeInsets.all(20),
      child: Row(
        children: [
          Text(
            title,
            style: Theme.of(context).textTheme.titleLarge,
          ),
        ],
      ),
    );
  }

  Widget _buildThemeMenuItem(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        String themeText = 'Sistema';
        IconData themeIcon = Icons.brightness_auto;

        switch (themeProvider.themeMode) {
          case ThemeMode.light:
            themeText = 'Claro';
            themeIcon = Icons.light_mode;
            break;
          case ThemeMode.dark:
            themeText = 'Escuro';
            themeIcon = Icons.dark_mode;
            break;
          case ThemeMode.system:
            themeText = 'Sistema';
            themeIcon = Icons.brightness_auto;
            break;
        }

        return _buildMenuItem(
          context,
          icon: themeIcon,
          title: 'Tema',
          subtitle: themeText,
          onTap: () => _showThemeMenu(context),
        );
      },
    );
  }

  Widget _buildMenuItem(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required VoidCallback onTap,
    bool isLast = false,
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
        decoration: BoxDecoration(
          border: isLast
              ? null
              : Border(
                  bottom: BorderSide(
                    color: Theme.of(context).dividerColor,
                    width: 0.5,
                  ),
                ),
        ),
        child: Row(
          children: [
            Container(
              width: 40,
              height: 40,
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(10),
              ),
              child: Icon(
                icon,
                color: AppColors.primary,
                size: 20,
              ),
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium,
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            Icon(
              Icons.chevron_right,
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.5),
            ),
          ],
        ),
      ),
    );
  }

  void _showThemeMenu(BuildContext context) {
    showModalBottomSheet(
      context: context,
      backgroundColor: Colors.transparent,
      builder: (BuildContext context) {
        return Container(
          decoration: BoxDecoration(
            color: Theme.of(context).cardColor,
            borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
          ),
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Container(
                width: 40,
                height: 4,
                decoration: BoxDecoration(
                  color: Theme.of(context).dividerColor,
                  borderRadius: BorderRadius.circular(2),
                ),
              ),
              const SizedBox(height: 20),
              Text(
                'Escolha o Tema',
                style: Theme.of(context).textTheme.headlineSmall,
              ),
              const SizedBox(height: 20),
              Consumer<ThemeProvider>(
                builder: (context, themeProvider, child) {
                  return Column(
                    children: [
                      _buildThemeOption(
                        context,
                        icon: Icons.light_mode,
                        title: 'Tema Claro',
                        subtitle: 'Interface clara e brilhante',
                        isSelected: themeProvider.themeMode == ThemeMode.light,
                        onTap: () async {
                          await themeProvider.setThemeMode(ThemeMode.light);
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildThemeOption(
                        context,
                        icon: Icons.dark_mode,
                        title: 'Tema Escuro',
                        subtitle: 'Interface escura e suave',
                        isSelected: themeProvider.themeMode == ThemeMode.dark,
                        onTap: () async {
                          await themeProvider.setThemeMode(ThemeMode.dark);
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                      ),
                      const SizedBox(height: 12),
                      _buildThemeOption(
                        context,
                        icon: Icons.brightness_auto,
                        title: 'Seguir Sistema',
                        subtitle: 'Usa o tema do dispositivo',
                        isSelected: themeProvider.themeMode == ThemeMode.system,
                        onTap: () async {
                          await themeProvider.setThemeMode(ThemeMode.system);
                          if (context.mounted) {
                            Navigator.pop(context);
                          }
                        },
                      ),
                    ],
                  );
                },
              ),
              const SizedBox(height: 20),
            ],
          ),
        );
      },
    );
  }

  Widget _buildThemeOption(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String subtitle,
    required bool isSelected,
    required VoidCallback onTap,
  }) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.all(16),
        decoration: BoxDecoration(
          color: isSelected
              ? AppColors.primary.withOpacity(0.1)
              : Colors.transparent,
          borderRadius: BorderRadius.circular(12),
          border: Border.all(
            color: isSelected 
                ? AppColors.primary 
                : Theme.of(context).dividerColor,
            width: isSelected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Icon(
              icon,
              color: isSelected
                  ? AppColors.primary
                  : Theme.of(context).colorScheme.onSurface,
              size: 24,
            ),
            const SizedBox(width: 16),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    title,
                    style: Theme.of(context).textTheme.titleMedium?.copyWith(
                      color: isSelected
                          ? AppColors.primary
                          : Theme.of(context).colorScheme.onSurface,
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    subtitle,
                    style: Theme.of(context).textTheme.bodySmall,
                  ),
                ],
              ),
            ),
            if (isSelected)
              const Icon(
                Icons.check_circle,
                color: AppColors.primary,
                size: 20,
              ),
          ],
        ),
      ),
    );
  }
}
