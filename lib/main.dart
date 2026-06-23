import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:hive_ce_flutter/hive_ce_flutter.dart';

import 'app.dart';
import 'services/storage_service.dart';
import 'core/utils/logger.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Initialize Hive for local storage
  await Hive.initFlutter();

  // Initialize storage service (registers adapters, opens boxes)
  await StorageService.initialize();

  AppLogger.info('SignBridge initialized successfully');

  runApp(
    const ProviderScope(
      child: SignBridgeApp(),
    ),
  );
}
