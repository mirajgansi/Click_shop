import 'package:click_shop/app/theme/theme_mode_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class ThemeSettingsPage extends ConsumerWidget {
  const ThemeSettingsPage({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final cs = Theme.of(context).colorScheme;

    final current = ref.watch(appThemeModeProvider);

    Widget tile(String title, AppThemeMode mode, String subtitle) {
      final selected = current == mode;

      return Container(
        margin: const EdgeInsets.only(bottom: 10),
        decoration: BoxDecoration(
          color: cs.surface,
          borderRadius: BorderRadius.circular(14),
          border: Border.all(
            color: selected ? cs.primary : cs.outlineVariant.withOpacity(0.6),
            width: selected ? 1.6 : 1,
          ),
        ),
        child: ListTile(
          title: Text(
            title,
            style: TextStyle(fontWeight: FontWeight.w700, color: cs.onSurface),
          ),
          subtitle: Text(
            subtitle,
            style: TextStyle(color: cs.onSurface.withOpacity(0.65)),
          ),
          trailing: Radio<AppThemeMode>(
            value: mode,
            groupValue: current,
            activeColor: cs.primary,
            onChanged: (v) {
              if (v == null) return;
              ref.read(appThemeModeProvider.notifier).setMode(v);
            },
          ),
          onTap: () => ref.read(appThemeModeProvider.notifier).setMode(mode),
        ),
      );
    }

    return Scaffold(
      appBar: AppBar(title: const Text("Theme")),
      backgroundColor: cs.background,
      body: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              "Choose app appearance",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.w800,
                color: cs.onSurface,
              ),
            ),
            const SizedBox(height: 12),

            tile(
              "System (Default)",
              AppThemeMode.system,
              "Follows your phone settings",
            ),
            tile("Light", AppThemeMode.light, "Always use light mode"),
            tile("Dark", AppThemeMode.dark, "Always use dark mode"),

            tile(
              "Auto (Sensor)",
              AppThemeMode.sensor,
              "Changes using room light",
            ),
          ],
        ),
      ),
    );
  }
}
