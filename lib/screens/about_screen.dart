import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';
import '../themes/color_schemes.dart';

/// About screen displaying app information and credits.
class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('About'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        children: [
          // App card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.largePadding),
              child: Column(
                children: [
                  // Logo
                  Container(
                    width: 96,
                    height: 96,
                    decoration: BoxDecoration(
                      gradient: const LinearGradient(
                        colors: AppColors.primaryGradient,
                        begin: Alignment.topLeft,
                        end: Alignment.bottomRight,
                      ),
                      borderRadius: BorderRadius.circular(24),
                      boxShadow: [
                        BoxShadow(
                          color: scheme.primary.withValues(alpha: 0.3),
                          blurRadius: 16,
                          offset: const Offset(0, 6),
                        ),
                      ],
                    ),
                    child: const Icon(
                      Icons.sign_language,
                      size: 48,
                      color: Colors.white,
                    ),
                  ),
                  const SizedBox(height: 20),
                  Text(
                    AppConstants.appName,
                    style:
                        Theme.of(context).textTheme.headlineMedium?.copyWith(
                              fontWeight: FontWeight.w700,
                            ),
                  ),
                  const SizedBox(height: 4),
                  Text(
                    'Version ${AppConstants.appVersion}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    AppConstants.appDescription,
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                    textAlign: TextAlign.center,
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Technology Stack
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.build_outlined, size: 20, color: scheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Technology Stack',
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildTechItem(context, '🎯', 'Flutter', 'Cross-platform UI framework'),
                  _buildTechItem(context, '🧠', 'TensorFlow Lite', 'On-device ML inference'),
                  _buildTechItem(context, '✋', 'MediaPipe', 'Hand landmark detection'),
                  _buildTechItem(context, '📱', 'Material Design 3', 'Modern UI components'),
                  _buildTechItem(context, '🔄', 'Riverpod', 'State management'),
                  _buildTechItem(context, '💾', 'Hive CE', 'Local data storage'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Features
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.star_outline, size: 20, color: scheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Key Features',
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(context, '🔒', 'Fully offline — no internet required'),
                  _buildFeatureItem(context, '⚡', 'Real-time gesture recognition'),
                  _buildFeatureItem(context, '🌍', 'Multi-language support (ASL, BSL, IPSL, CSL)'),
                  _buildFeatureItem(context, '📝', 'Automatic text composition'),
                  _buildFeatureItem(context, '🎨', 'Light and dark themes'),
                  _buildFeatureItem(context, '📱', 'Responsive, accessible design'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Supported languages
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.language, size: 20, color: scheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Supported Sign Languages',
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureItem(context, '🇺🇸', 'American Sign Language (ASL)'),
                  _buildFeatureItem(context, '🇬🇧', 'British Sign Language (BSL)'),
                  _buildFeatureItem(context, '🇮🇳', 'Indo-Pakistani Sign Language (IPSL)'),
                  _buildFeatureItem(context, '🇨🇳', 'Chinese Sign Language (CSL)'),
                ],
              ),
            ),
          ),

          const SizedBox(height: 32),

          // Footer
          Center(
            child: Text(
              'Built with ❤️ for accessibility',
              style: Theme.of(context).textTheme.bodySmall?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }

  Widget _buildTechItem(
    BuildContext context,
    String emoji,
    String title,
    String subtitle,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Row(
        children: [
          Text(emoji, style: const TextStyle(fontSize: 20)),
          const SizedBox(width: 12),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                title,
                style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
              ),
              Text(
                subtitle,
                style: Theme.of(context).textTheme.bodySmall?.copyWith(
                      color: Theme.of(context).colorScheme.onSurfaceVariant,
                    ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureItem(
    BuildContext context,
    String emoji,
    String text,
  ) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(emoji, style: const TextStyle(fontSize: 16)),
          const SizedBox(width: 10),
          Expanded(
            child: Text(
              text,
              style: Theme.of(context).textTheme.bodyMedium,
            ),
          ),
        ],
      ),
    );
  }
}
