import 'package:camera/camera.dart';
import 'package:flutter/material.dart';

/// Camera preview widget with proper aspect ratio handling.
class CameraPreviewWidget extends StatelessWidget {
  final CameraController controller;

  const CameraPreviewWidget({
    super.key,
    required this.controller,
  });

  @override
  Widget build(BuildContext context) {
    if (!controller.value.isInitialized) {
      return const Center(
        child: CircularProgressIndicator(),
      );
    }

    return LayoutBuilder(
      builder: (context, constraints) {
        // Mirror the front camera preview
        return Transform.flip(
          flipX: true,
          child: SizedBox(
            width: constraints.maxWidth,
            height: constraints.maxHeight,
            child: FittedBox(
              fit: BoxFit.cover,
              child: SizedBox(
                width: controller.value.previewSize?.height ?? 480,
                height: controller.value.previewSize?.width ?? 640,
                child: CameraPreview(controller),
              ),
            ),
          ),
        );
      },
    );
  }
}
