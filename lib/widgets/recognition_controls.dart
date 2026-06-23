import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';

/// Control bar with Start/Stop, Clear, Copy, Share, and Save buttons.
class RecognitionControls extends StatelessWidget {
  final bool isRunning;
  final bool hasText;
  final VoidCallback onToggle;
  final VoidCallback onClear;
  final VoidCallback onCopy;
  final VoidCallback onShare;
  final VoidCallback onSave;

  const RecognitionControls({
    super.key,
    required this.isRunning,
    required this.hasText,
    required this.onToggle,
    required this.onClear,
    required this.onCopy,
    required this.onShare,
    required this.onSave,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Row(
      children: [
        // Start/Stop button (primary action)
        Expanded(
          flex: 2,
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            child: FilledButton.icon(
              onPressed: onToggle,
              icon: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Icon(
                  isRunning ? Icons.stop_rounded : Icons.play_arrow_rounded,
                  key: ValueKey(isRunning),
                ),
              ),
              label: AnimatedSwitcher(
                duration: const Duration(milliseconds: 200),
                child: Text(
                  isRunning ? 'Stop' : 'Start',
                  key: ValueKey(isRunning),
                ),
              ),
              style: FilledButton.styleFrom(
                backgroundColor:
                    isRunning ? scheme.error : scheme.primary,
                foregroundColor:
                    isRunning ? scheme.onError : scheme.onPrimary,
                padding: const EdgeInsets.symmetric(
                  horizontal: 20,
                  vertical: 14,
                ),
                shape: RoundedRectangleBorder(
                  borderRadius:
                      BorderRadius.circular(AppConstants.smallBorderRadius),
                ),
              ),
            ),
          ),
        ),

        const SizedBox(width: 8),

        // Clear button
        _ActionButton(
          icon: Icons.clear_all_rounded,
          tooltip: 'Clear text',
          onPressed: hasText ? onClear : null,
        ),

        const SizedBox(width: 4),

        // Copy button
        _ActionButton(
          icon: Icons.copy_rounded,
          tooltip: 'Copy text',
          onPressed: hasText ? onCopy : null,
        ),

        const SizedBox(width: 4),

        // Share button
        _ActionButton(
          icon: Icons.share_rounded,
          tooltip: 'Share text',
          onPressed: hasText ? onShare : null,
        ),

        const SizedBox(width: 4),

        // Save to history button
        _ActionButton(
          icon: Icons.save_rounded,
          tooltip: 'Save to history',
          onPressed: hasText ? onSave : null,
        ),
      ],
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String tooltip;
  final VoidCallback? onPressed;

  const _ActionButton({
    required this.icon,
    required this.tooltip,
    this.onPressed,
  });

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Tooltip(
      message: tooltip,
      child: IconButton(
        onPressed: onPressed,
        icon: Icon(icon),
        style: IconButton.styleFrom(
          backgroundColor: scheme.surfaceContainerHighest,
          foregroundColor: onPressed != null
              ? scheme.onSurface
              : scheme.onSurface.withValues(alpha: 0.3),
          shape: RoundedRectangleBorder(
            borderRadius:
                BorderRadius.circular(AppConstants.smallBorderRadius),
          ),
        ),
      ),
    );
  }
}
