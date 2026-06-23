import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';

import '../core/constants/app_constants.dart';
import '../core/utils/permission_utils.dart';
import '../providers/history_provider.dart';
import '../providers/language_provider.dart';
import '../providers/recognition_provider.dart';
import '../providers/settings_provider.dart';
import '../themes/color_schemes.dart';
import '../widgets/camera_preview.dart';
import '../widgets/fps_counter.dart';
import '../widgets/landmark_overlay.dart';
import '../widgets/prediction_card.dart';
import '../widgets/recognition_controls.dart';
import '../widgets/sentence_display.dart';
import 'settings_screen.dart';

/// Main home screen with camera preview and recognition UI.
///
/// Contains:
/// - Full-screen camera preview
/// - Hand landmark overlay
/// - Prediction card with confidence
/// - FPS counter
/// - Editable text area
/// - Control buttons
class HomeScreen extends ConsumerStatefulWidget {
  const HomeScreen({super.key});

  @override
  ConsumerState<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends ConsumerState<HomeScreen>
    with WidgetsBindingObserver {
  bool _permissionGranted = false;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addObserver(this);
    _checkPermissionAndInit();
  }

  @override
  void dispose() {
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    // Handle app lifecycle for camera
    final recognitionNotifier = ref.read(recognitionProvider.notifier);
    if (state == AppLifecycleState.paused) {
      recognitionNotifier.stopRecognition();
    }
  }

  Future<void> _checkPermissionAndInit() async {
    final granted = await PermissionUtils.requestCameraPermission(context);
    setState(() => _permissionGranted = granted);

    if (granted) {
      await ref.read(recognitionProvider.notifier).initialize();
    }
  }

  void _copyText() {
    final text = ref.read(recognitionProvider).composedText;
    if (text.isNotEmpty) {
      Clipboard.setData(ClipboardData(text: text));
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Text copied to clipboard'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  void _shareText() {
    final text = ref.read(recognitionProvider).composedText;
    if (text.isNotEmpty) {
      Share.share(text);
    }
  }

  void _saveToHistory() {
    final state = ref.read(recognitionProvider);
    final language = ref.read(languageProvider);

    if (state.composedText.trim().isNotEmpty) {
      ref.read(historyProvider.notifier).saveEntry(
            text: state.composedText,
            languageCode: language.code,
            languageName: language.displayName,
          );

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Text saved to history'),
          duration: Duration(seconds: 2),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final recognitionState = ref.watch(recognitionProvider);
    final settings = ref.watch(settingsProvider);
    final language = ref.watch(languageProvider);
    final scheme = Theme.of(context).colorScheme;
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: SafeArea(
        child: Column(
          children: [
            // ── Top Bar ──
            _buildTopBar(scheme, language, recognitionState),

            // ── Camera Preview Section ──
            Expanded(
              flex: 3,
              child: _buildCameraSection(
                recognitionState,
                settings,
                scheme,
                isDark,
              ),
            ),

            // ── Prediction Display ──
            _buildPredictionSection(recognitionState, scheme),

            // ── Text Area ──
            Expanded(
              flex: 1,
              child: _buildTextSection(recognitionState, scheme),
            ),

            // ── Control Bar ──
            _buildControlBar(recognitionState, scheme),
          ],
        ),
      ),
    );
  }

  Widget _buildTopBar(
    ColorScheme scheme,
    dynamic language,
    RecognitionState state,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      child: Row(
        children: [
          // App title
          Text(
            'SignBridge',
            style: Theme.of(context).textTheme.titleLarge?.copyWith(
                  fontWeight: FontWeight.w700,
                  color: scheme.primary,
                ),
          ),

          const SizedBox(width: 12),

          // Language badge
          Container(
            padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
            decoration: BoxDecoration(
              color: scheme.primaryContainer,
              borderRadius:
                  BorderRadius.circular(AppConstants.chipBorderRadius),
            ),
            child: Text(
              '${language.flagEmoji} ${language.shortName}',
              style: Theme.of(context).textTheme.labelSmall?.copyWith(
                    color: scheme.onPrimaryContainer,
                    fontWeight: FontWeight.w600,
                  ),
            ),
          ),

          const Spacer(),

          // FPS counter (conditional)
          if (ref.watch(settingsProvider).showFps && state.isRunning)
            FpsCounter(fps: state.fps),

          const SizedBox(width: 8),

          // Settings button
          IconButton(
            icon: const Icon(Icons.settings_outlined),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute(builder: (_) => const SettingsScreen()),
              );
            },
            tooltip: 'Settings',
          ),
        ],
      ),
    );
  }

  Widget _buildCameraSection(
    RecognitionState state,
    AppSettings settings,
    ColorScheme scheme,
    bool isDark,
  ) {
    if (!_permissionGranted) {
      return _buildPermissionDeniedCard(scheme);
    }

    if (!state.isCameraReady) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            CircularProgressIndicator(color: scheme.primary),
            const SizedBox(height: 16),
            Text(
              'Initializing camera...',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
            ),
          ],
        ),
      );
    }

    final cameraService = ref.read(cameraServiceProvider);

    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(AppConstants.cardBorderRadius),
        child: Stack(
          fit: StackFit.expand,
          children: [
            // Camera preview
            if (cameraService.controller != null)
              CameraPreviewWidget(
                controller: cameraService.controller!,
              ),

            // Landmark overlay
            if (settings.showLandmarks && state.currentLandmarks != null)
              LandmarkOverlay(
                landmarks: state.currentLandmarks!,
                imageSize: const Size(480, 640),
              ),

            // No hand detected indicator
            if (state.isRunning && state.currentLandmarks == null)
              Positioned(
                bottom: 12,
                left: 12,
                child: Container(
                  padding:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                  decoration: BoxDecoration(
                    color: AppColors.glassBackground(
                      isDark ? Brightness.dark : Brightness.light,
                    ),
                    borderRadius:
                        BorderRadius.circular(AppConstants.chipBorderRadius),
                    border: Border.all(
                      color: AppColors.glassBorder(
                        isDark ? Brightness.dark : Brightness.light,
                      ),
                    ),
                  ),
                  child: Row(
                    mainAxisSize: MainAxisSize.min,
                    children: [
                      Icon(
                        Icons.pan_tool_outlined,
                        size: 14,
                        color: scheme.onSurfaceVariant,
                      ),
                      const SizedBox(width: 6),
                      Text(
                        'Show your hand',
                        style:
                            Theme.of(context).textTheme.labelSmall?.copyWith(
                                  color: scheme.onSurfaceVariant,
                                ),
                      ),
                    ],
                  ),
                ),
              ),

            // Error overlay
            if (state.errorMessage != null)
              Center(
                child: Container(
                  margin: const EdgeInsets.all(24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: scheme.errorContainer,
                    borderRadius:
                        BorderRadius.circular(AppConstants.smallBorderRadius),
                  ),
                  child: Text(
                    state.errorMessage!,
                    style: TextStyle(color: scheme.onErrorContainer),
                    textAlign: TextAlign.center,
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildPermissionDeniedCard(ColorScheme scheme) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(
              Icons.camera_alt_outlined,
              size: 64,
              color: scheme.onSurfaceVariant,
            ),
            const SizedBox(height: 16),
            Text(
              'Camera access required',
              style: Theme.of(context).textTheme.titleMedium,
            ),
            const SizedBox(height: 8),
            Text(
              'SignBridge needs camera access to detect hand gestures for sign language recognition.',
              style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                    color: scheme.onSurfaceVariant,
                  ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 24),
            FilledButton.icon(
              onPressed: _checkPermissionAndInit,
              icon: const Icon(Icons.camera_alt),
              label: const Text('Grant Permission'),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildPredictionSection(
    RecognitionState state,
    ColorScheme scheme,
  ) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
        vertical: AppConstants.smallPadding,
      ),
      child: AnimatedSwitcher(
        duration: const Duration(milliseconds: 300),
        transitionBuilder: (child, animation) {
          return FadeTransition(
            opacity: animation,
            child: SlideTransition(
              position: Tween<Offset>(
                begin: const Offset(0, 0.1),
                end: Offset.zero,
              ).animate(animation),
              child: child,
            ),
          );
        },
        child: state.currentPrediction != null &&
                state.currentPrediction!.isNotEmpty
            ? PredictionCard(
                key: ValueKey(state.currentPrediction!.label),
                prediction: state.currentPrediction!,
              )
            : const SizedBox(
                key: ValueKey('empty'),
                height: 80,
              ),
      ),
    );
  }

  Widget _buildTextSection(RecognitionState state, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.symmetric(
        horizontal: AppConstants.defaultPadding,
      ),
      child: SentenceDisplay(
        text: state.composedText,
        onTextChanged: (text) {
          ref.read(recognitionProvider.notifier).updateText(text);
        },
      ),
    );
  }

  Widget _buildControlBar(RecognitionState state, ColorScheme scheme) {
    return Padding(
      padding: const EdgeInsets.all(AppConstants.defaultPadding),
      child: RecognitionControls(
        isRunning: state.isRunning,
        hasText: state.composedText.isNotEmpty,
        onToggle: () {
          ref.read(recognitionProvider.notifier).toggleRecognition();
        },
        onClear: () {
          ref.read(recognitionProvider.notifier).clearText();
        },
        onCopy: _copyText,
        onShare: _shareText,
        onSave: _saveToHistory,
      ),
    );
  }
}
