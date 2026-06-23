# SignBridge 🤟

AI-powered real-time multilingual sign language keyboard for Android.

SignBridge detects hand gestures through the smartphone's front camera, recognizes sign language gestures using on-device TensorFlow Lite models, and converts them into editable text — all fully offline.

---

## ✨ Features

- **Real-time recognition** — Gesture detection at 30+ FPS
- **Fully offline** — No internet required, all inference runs on-device
- **Multi-language support** — ASL, BSL, IPSL, CSL with dynamic switching
- **Smart text composition** — Temporal smoothing, duplicate suppression, auto-spacing
- **Material Design 3** — Modern, accessible UI with light/dark themes
- **History tracking** — Save, reuse, and share recognized text
- **Customizable settings** — Confidence threshold, camera resolution, display options

---

## 🏗️ Architecture

```
┌──────────────────────────────────────────────┐
│                    UI Layer                   │
│  Screens • Widgets • Themes (Material 3)     │
├──────────────────────────────────────────────┤
│              State Management                 │
│              Riverpod Providers               │
├──────────────────────────────────────────────┤
│              Repository Layer                 │
│  ModelRepo • SettingsRepo • HistoryRepo      │
├──────────────────────────────────────────────┤
│               Service Layer                   │
│  Camera • Landmarks • TFLite • Smoothing     │
│  SentenceBuilder • Storage                   │
├──────────────────────────────────────────────┤
│                Core Layer                     │
│  Models • Constants • Errors • Utils         │
└──────────────────────────────────────────────┘
```

### AI Processing Pipeline

```
Front Camera → MediaPipe Hand Landmarks → 21 Points (x,y,z)
    → Feature Normalization (63 floats)
    → TFLite Gesture Classifier
    → Temporal Smoothing (majority voting + EMA)
    → Sentence Builder → Editable Text
```

---

## 📁 Project Structure

```
signbridge/
├── lib/
│   ├── main.dart                   # App entry point
│   ├── app.dart                    # MaterialApp configuration
│   ├── core/
│   │   ├── constants/              # App & model constants
│   │   ├── errors/                 # Custom exceptions & failures
│   │   └── utils/                  # Logger, image utils, permissions
│   ├── models/                     # Data models
│   ├── services/                   # Business logic services
│   ├── repositories/               # Data access layer
│   ├── providers/                  # Riverpod state management
│   ├── screens/                    # App screens
│   ├── widgets/                    # Reusable UI components
│   └── themes/                     # Material Design 3 theme system
├── assets/models/                  # TFLite models per language
│   ├── asl/                        # model.tflite, labels.json, config.json
│   ├── bsl/
│   ├── ipsl/
│   └── csl/
├── model_training/                 # Python ML pipeline
│   ├── train_gesture_model.py      # Model training script
│   ├── create_dummy_models.py      # Placeholder model generator
│   └── requirements.txt            # Python dependencies
└── pubspec.yaml                    # Flutter configuration
```

---

## 🚀 Installation

### Prerequisites

- [Flutter SDK](https://flutter.dev/docs/get-started/install) (3.44+)
- [Android Studio](https://developer.android.com/studio) or Android SDK
- Android device or emulator (API 24+)
- Python 3.10+ (for model training only)

### Setup

1. **Clone and navigate:**
   ```bash
   cd signbridge
   ```

2. **Install Flutter dependencies:**
   ```bash
   flutter pub get
   ```

3. **Generate TFLite models (first time):**
   ```bash
   cd model_training
   python -m venv .venv
   .venv/Scripts/activate    # Windows
   pip install -r requirements.txt
   python create_dummy_models.py
   cd ..
   ```

4. **Run on device:**
   ```bash
   flutter run
   ```

5. **Build release APK:**
   ```bash
   flutter build apk --release
   ```

---

## 🧠 TFLite Model Integration

### Model Format

Each sign language requires three files in `assets/models/{language}/`:

| File | Description |
|------|-------------|
| `model.tflite` | TFLite classifier model |
| `labels.json` | Maps output indices to gesture labels |
| `config.json` | Model metadata and configuration |

### Input/Output

- **Input:** `Float32[1][63]` — 21 hand landmarks × 3 coordinates (x, y, z), normalized
- **Output:** `Float32[1][N]` — Softmax probabilities over N gesture classes

### Replacing Models

1. Train your model to accept 63-float input (normalized landmarks)
2. Export to TFLite format
3. Place files in `assets/models/{language}/`
4. Update `labels.json` with your class mappings
5. Update `config.json` with model metadata
6. Rebuild the app

---

## 🎯 Training Custom Models

### Using the Training Script

```bash
cd model_training
python train_gesture_model.py \
  --data path/to/landmarks.csv \
  --language asl \
  --epochs 100
```

### Data Format

The training CSV should contain:
- 63 feature columns: `x0, y0, z0, x1, y1, z1, ..., x20, y20, z20`
- 1 label column: `label` (gesture name, e.g., "A", "B", "SPACE")

### Recommended Datasets

- [Kaggle: ASL Sign Detection Dataset](https://www.kaggle.com/datasets/sahithi-sss/asl-sign-detection-dataset)
- [Kaggle: ASL Gesture Dataset (MediaPipe)](https://www.kaggle.com/datasets/gti-upm/asl-gesture-dataset-using-media-pipe)
- [Google: Isolated Sign Language Recognition](https://www.kaggle.com/competitions/asl-signs)

---

## 🛠️ Technology Stack

| Component | Technology |
|-----------|-----------|
| Framework | Flutter 3.44+ |
| Language | Dart 3.12+ |
| State Management | Riverpod 3.3.2 |
| ML Inference | TFLite Flutter 0.12.1 |
| Hand Detection | MediaPipe Hand Landmarker |
| Local Storage | Hive CE |
| UI Design | Material Design 3 |
| Camera | Flutter Camera Plugin |

---

## 📋 Supported Sign Languages

| Language | Code | Status |
|----------|------|--------|
| 🇺🇸 American Sign Language | `asl` | Placeholder model |
| 🇬🇧 British Sign Language | `bsl` | Placeholder model |
| 🇮🇳 Indo-Pakistani Sign Language | `ipsl` | Placeholder model |
| 🇨🇳 Chinese Sign Language | `csl` | Placeholder model |

To add a new language, create a folder under `assets/models/` with the three required files and add the language to the `SignLanguage` enum in `lib/models/sign_language.dart`.

---

## 🐛 Troubleshooting

| Issue | Solution |
|-------|----------|
| Camera black screen | Check camera permissions in device settings |
| Model load failure | Verify model files exist in `assets/models/{lang}/` |
| Low FPS | Reduce camera resolution in Settings |
| No hand detected | Ensure good lighting and hand is fully visible |
| App crashes on start | Run `flutter clean` then `flutter pub get` |

---

## 📄 License

This project is for educational and demonstration purposes.

---

## 🙏 Acknowledgements

- [MediaPipe](https://developers.google.com/mediapipe) by Google
- [TensorFlow Lite](https://www.tensorflow.org/lite)
- [Flutter](https://flutter.dev)
- [Riverpod](https://riverpod.dev)
