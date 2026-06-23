import 'package:flutter/material.dart';

import '../core/constants/app_constants.dart';

/// Editable text display area for composed sentence.
///
/// Shows the accumulated text from gesture recognition
/// and allows manual editing by the user.
class SentenceDisplay extends StatefulWidget {
  final String text;
  final ValueChanged<String>? onTextChanged;

  const SentenceDisplay({
    super.key,
    required this.text,
    this.onTextChanged,
  });

  @override
  State<SentenceDisplay> createState() => _SentenceDisplayState();
}

class _SentenceDisplayState extends State<SentenceDisplay> {
  late TextEditingController _controller;
  bool _isEditing = false;

  @override
  void initState() {
    super.initState();
    _controller = TextEditingController(text: widget.text);
  }

  @override
  void didUpdateWidget(SentenceDisplay oldWidget) {
    super.didUpdateWidget(oldWidget);
    // Only update if not actively editing
    if (!_isEditing && widget.text != _controller.text) {
      _controller.text = widget.text;
      // Move cursor to end
      _controller.selection = TextSelection.fromPosition(
        TextPosition(offset: _controller.text.length),
      );
    }
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final scheme = Theme.of(context).colorScheme;

    return Container(
      decoration: BoxDecoration(
        color: scheme.surfaceContainerHighest.withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        border: Border.all(
          color: _isEditing
              ? scheme.primary
              : scheme.outlineVariant.withValues(alpha: 0.5),
          width: _isEditing ? 2 : 1,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Label
          Padding(
            padding: const EdgeInsets.only(left: 16, top: 8, right: 16),
            child: Row(
              children: [
                Icon(
                  Icons.text_fields,
                  size: 14,
                  color: scheme.onSurfaceVariant,
                ),
                const SizedBox(width: 4),
                Text(
                  'Composed Text',
                  style: Theme.of(context).textTheme.labelSmall?.copyWith(
                        color: scheme.onSurfaceVariant,
                      ),
                ),
                const Spacer(),
                if (widget.text.isNotEmpty)
                  Text(
                    '${widget.text.length} chars',
                    style: Theme.of(context).textTheme.labelSmall?.copyWith(
                          color: scheme.onSurfaceVariant.withValues(alpha: 0.7),
                        ),
                  ),
              ],
            ),
          ),
          // Text field
          Expanded(
            child: TextField(
              controller: _controller,
              maxLines: null,
              expands: true,
              textAlignVertical: TextAlignVertical.top,
              style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                    letterSpacing: 1.5,
                    height: 1.5,
                  ),
              decoration: const InputDecoration(
                border: InputBorder.none,
                enabledBorder: InputBorder.none,
                focusedBorder: InputBorder.none,
                contentPadding:
                    EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                hintText: 'Start signing to see text here...',
                filled: false,
              ),
              onTap: () => setState(() => _isEditing = true),
              onChanged: (value) {
                widget.onTextChanged?.call(value);
              },
              onEditingComplete: () {
                setState(() => _isEditing = false);
              },
              onTapOutside: (_) {
                setState(() => _isEditing = false);
                FocusScope.of(context).unfocus();
              },
            ),
          ),
        ],
      ),
    );
  }
}
