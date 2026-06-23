import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../core/constants/app_constants.dart';
import '../providers/language_provider.dart';

/// Screen displaying metadata about the currently loaded TFLite model.
class ModelInfoScreen extends ConsumerWidget {
  const ModelInfoScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final language = ref.watch(languageProvider);
    final tfliteService = ref.read(tfliteServiceProvider);
    final modelInfo = tfliteService.getModelInfo();
    final scheme = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Model Information'),
      ),
      body: ListView(
        padding: const EdgeInsets.all(AppConstants.defaultPadding),
        children: [
          // Model header card
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.largePadding),
              child: Column(
                children: [
                  Container(
                    width: 72,
                    height: 72,
                    decoration: BoxDecoration(
                      color: scheme.primaryContainer,
                      borderRadius: BorderRadius.circular(20),
                    ),
                    child: Icon(
                      Icons.model_training,
                      size: 36,
                      color: scheme.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                    modelInfo.modelName,
                    style: Theme.of(context).textTheme.headlineSmall?.copyWith(
                          fontWeight: FontWeight.w700,
                        ),
                    textAlign: TextAlign.center,
                  ),
                  const SizedBox(height: 4),
                  Text(
                    '${language.flagEmoji}  ${language.displayName}',
                    style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                          color: scheme.onSurfaceVariant,
                        ),
                  ),
                ],
              ),
            ),
          ),

          const SizedBox(height: 16),

          // Model details
          Card(
            child: Column(
              children: [
                _buildInfoTile(
                  context,
                  icon: Icons.tag,
                  title: 'Version',
                  value: modelInfo.version,
                ),
                const Divider(height: 1),
                _buildInfoTile(
                  context,
                  icon: Icons.category,
                  title: 'Number of Classes',
                  value: '${modelInfo.numClasses}',
                ),
                const Divider(height: 1),
                _buildInfoTile(
                  context,
                  icon: Icons.input,
                  title: 'Input Size',
                  value: '${modelInfo.inputSize} features',
                ),
                const Divider(height: 1),
                _buildInfoTile(
                  context,
                  icon: Icons.storage,
                  title: 'File Size',
                  value: modelInfo.fileSizeFormatted,
                ),
                const Divider(height: 1),
                _buildInfoTile(
                  context,
                  icon: Icons.memory,
                  title: 'TFLite Runtime',
                  value: modelInfo.tfliteVersion,
                ),
              ],
            ),
          ),

          const SizedBox(height: 16),

          // Supported gestures
          Card(
            child: Padding(
              padding: const EdgeInsets.all(AppConstants.defaultPadding),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Row(
                    children: [
                      Icon(Icons.gesture, size: 20, color: scheme.primary),
                      const SizedBox(width: 8),
                      Text(
                        'Supported Gestures',
                        style:
                            Theme.of(context).textTheme.titleSmall?.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                      ),
                    ],
                  ),
                  const SizedBox(height: 12),
                  Wrap(
                    spacing: 8,
                    runSpacing: 8,
                    children: modelInfo.outputClasses.map((label) {
                      return Chip(
                        label: Text(
                          label,
                          style: Theme.of(context).textTheme.labelMedium,
                        ),
                        materialTapTargetSize:
                            MaterialTapTargetSize.shrinkWrap,
                        visualDensity: VisualDensity.compact,
                      );
                    }).toList(),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoTile(
    BuildContext context, {
    required IconData icon,
    required String title,
    required String value,
  }) {
    final scheme = Theme.of(context).colorScheme;
    return ListTile(
      leading: Icon(icon, color: scheme.primary),
      title: Text(title),
      trailing: Text(
        value,
        style: Theme.of(context).textTheme.bodyMedium?.copyWith(
              fontWeight: FontWeight.w600,
              color: scheme.onSurface,
            ),
      ),
    );
  }
}
