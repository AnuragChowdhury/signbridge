import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../models/sign_language.dart';
import '../providers/language_provider.dart';
import '../providers/settings_provider.dart';
import '../providers/theme_provider.dart';
import '../services/camera_service.dart';
import 'about_screen.dart';
import 'history_screen.dart';
import 'model_info_screen.dart';

/// Settings screen for configuring the application.
///
/// Provides controls for:
/// - Sign language selection
/// - Confidence threshold
/// - Landmark overlay toggle
/// - FPS display toggle
/// - Theme selection
/// - Camera resolution
/// - Navigation to model info, history, and about screens
class SettingsScreen extends ConsumerWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final settings = ref.watch(settingsProvider);
    final language = ref.watch(languageProvider);
    final themeNotifier = ref.watch(themeModeProvider.notifier);
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Settings'),
      ),
      body: ListView(
        padding: const EdgeInsets.symmetric(
          vertical: AppConstants.defaultPadding,
        ),
        children: [
          // ── Sign Language Section ──
          _buildSectionHeader(context, 'Sign Language', Icons.language),
          const SizedBox(height: 8),
          ...SignLanguage.values.map((lang) {
            return RadioListTile<SignLanguage>(
              value: lang,
              groupValue: language,
              onChanged: (value) async {
                if (value != null) {
                  try {
                    await ref
                        .read(languageProvider.notifier)
                        .switchLanguage(value);
                  } catch (e) {
                    if (context.mounted) {
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Text('Failed to load ${value.displayName} model'),
                          backgroundColor: scheme.error,
                        ),
                      );
                    }
                  }
                }
              },
              title: Text('${lang.flagEmoji}  ${lang.displayName}'),
              subtitle: Text(lang.shortName),
              secondary: language == lang
                  ? Icon(Icons.check_circle, color: scheme.primary)
                  : null,
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.smallBorderRadius),
              ),
            );
          }),

          const Divider(height: 32),

          // ── Recognition Section ──
          _buildSectionHeader(context, 'Recognition', Icons.psychology),
          const SizedBox(height: 8),

          // Confidence threshold slider
          ListTile(
            title: const Text('Confidence Threshold'),
            subtitle: Text(
              '${(settings.confidenceThreshold * 100).toStringAsFixed(0)}%',
            ),
            leading: const Icon(Icons.tune),
          ),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 16),
            child: Slider(
              value: settings.confidenceThreshold,
              min: 0.3,
              max: 0.95,
              divisions: 13,
              label:
                  '${(settings.confidenceThreshold * 100).toStringAsFixed(0)}%',
              onChanged: (value) {
                ref
                    .read(settingsProvider.notifier)
                    .setConfidenceThreshold(value);
              },
            ),
          ),

          const Divider(height: 32),

          // ── Display Section ──
          _buildSectionHeader(context, 'Display', Icons.visibility),
          const SizedBox(height: 8),

          SwitchListTile(
            title: const Text('Show Hand Landmarks'),
            subtitle: const Text('Draw landmark overlay on camera preview'),
            value: settings.showLandmarks,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setShowLandmarks(value);
            },
            secondary: const Icon(Icons.back_hand_outlined),
          ),

          SwitchListTile(
            title: const Text('Show FPS Counter'),
            subtitle: const Text('Display frames per second'),
            value: settings.showFps,
            onChanged: (value) {
              ref.read(settingsProvider.notifier).setShowFps(value);
            },
            secondary: const Icon(Icons.speed),
          ),

          const Divider(height: 32),

          // ── Theme Section ──
          _buildSectionHeader(context, 'Appearance', Icons.palette),
          const SizedBox(height: 8),

          ...['System', 'Light', 'Dark'].asMap().entries.map((entry) {
            final index = entry.key;
            final name = entry.value;
            final icon = [
              Icons.brightness_auto,
              Icons.light_mode,
              Icons.dark_mode,
            ][index];

            return RadioListTile<int>(
              value: index,
              groupValue: themeNotifier.themeIndex,
              onChanged: (value) {
                if (value != null) {
                  ref.read(themeModeProvider.notifier).setThemeMode(
                        [ThemeMode.system, ThemeMode.light, ThemeMode.dark][value],
                      );
                }
              },
              title: Text(name),
              secondary: Icon(icon),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.smallBorderRadius),
              ),
            );
          }),

          const Divider(height: 32),

          // ── Camera Section ──
          _buildSectionHeader(context, 'Camera', Icons.camera_alt),
          const SizedBox(height: 8),

          ...CameraResolution.values.map((res) {
            return RadioListTile<CameraResolution>(
              value: res,
              groupValue: settings.cameraResolution,
              onChanged: (value) {
                if (value != null) {
                  ref
                      .read(settingsProvider.notifier)
                      .setCameraResolution(value);
                }
              },
              title: Text(res.displayName),
              shape: RoundedRectangleBorder(
                borderRadius:
                    BorderRadius.circular(AppConstants.smallBorderRadius),
              ),
            );
          }),

          const Divider(height: 32),

          // ── Navigation Section ──
          _buildSectionHeader(context, 'Information', Icons.info_outline),
          const SizedBox(height: 8),

          ListTile(
            leading: const Icon(Icons.model_training),
            title: const Text('Model Information'),
            subtitle: const Text('View details about the loaded model'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const ModelInfoScreen()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.history),
            title: const Text('Recognition History'),
            subtitle: const Text('View and manage past recognitions'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const HistoryScreen()),
              );
            },
          ),

          ListTile(
            leading: const Icon(Icons.info_outline),
            title: const Text('About SignBridge'),
            subtitle: const Text('Version and developer information'),
            trailing: const Icon(Icons.chevron_right),
            onTap: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (_) => const AboutScreen()),
              );
            },
          ),

          const SizedBox(height: 32),
        ],
      ),
    );
  }

  Widget _buildSectionHeader(
    BuildContext context,
    String title,
    IconData icon,
  ) {
    final scheme = Theme.of(context).colorScheme;
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
      ),
      child: Row(
        children: [
          Icon(icon, size: 20, color: scheme.primary),
          const SizedBox(width: 8),
          Text(
            title,
            style: Theme.of(context).textTheme.titleSmall?.copyWith(
                  color: scheme.primary,
                  fontWeight: FontWeight.w700,
                ),
          ),
        ],
      ),
    );
  }
}
