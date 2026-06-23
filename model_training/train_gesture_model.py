"""
Training script for sign language gesture classifier.

Trains a lightweight MLP classifier on hand landmark features:
- Input: 63 features (21 landmarks × 3 coordinates)
- Architecture: Dense(128) → Dense(64) → Dense(32) → Dense(N classes)
- Output: Softmax probability distribution

Usage:
    python train_gesture_model.py --data path/to/landmarks.csv --language asl

The CSV file should have columns:
    x0, y0, z0, x1, y1, z1, ..., x20, y20, z20, label
"""

import argparse
import json
import os
import sys

import numpy as np
import pandas as pd

try:
    import tensorflow as tf
    from sklearn.model_selection import train_test_split
    from sklearn.preprocessing import LabelEncoder
except ImportError as e:
    print(f"Missing dependency: {e}")
    print("Install with: pip install -r requirements.txt")
    sys.exit(1)


INPUT_SIZE = 63  # 21 * 3


def load_data(csv_path: str):
    """Loads landmark data from CSV."""
    print(f"Loading data from: {csv_path}")
    df = pd.read_csv(csv_path)

    # Expect 63 feature columns + 1 label column
    feature_cols = [col for col in df.columns if col != 'label']
    if len(feature_cols) != INPUT_SIZE:
        print(f"Warning: Expected {INPUT_SIZE} feature columns, got {len(feature_cols)}")

    X = df[feature_cols[:INPUT_SIZE]].values.astype(np.float32)
    y = df['label'].values

    print(f"  Samples: {len(X)}")
    print(f"  Features: {X.shape[1]}")
    print(f"  Unique labels: {len(np.unique(y))}")

    return X, y


def normalize_landmarks(X: np.ndarray) -> np.ndarray:
    """Normalizes landmarks relative to wrist and scales."""
    normalized = np.zeros_like(X)

    for i in range(len(X)):
        landmarks = X[i].reshape(21, 3)

        # Center relative to wrist (landmark 0)
        wrist = landmarks[0].copy()
        centered = landmarks - wrist

        # Scale by max distance
        distances = np.linalg.norm(centered, axis=1)
        max_dist = np.max(distances)
        if max_dist > 1e-6:
            centered = centered / max_dist

        normalized[i] = centered.flatten()

    return normalized


def build_model(num_classes: int) -> tf.keras.Model:
    """Builds the gesture classifier model."""
    model = tf.keras.Sequential([
        tf.keras.layers.Input(shape=(INPUT_SIZE,)),
        tf.keras.layers.Dense(128, activation='relu',
                              kernel_regularizer=tf.keras.regularizers.l2(0.001)),
        tf.keras.layers.BatchNormalization(),
        tf.keras.layers.Dropout(0.3),
        tf.keras.layers.Dense(64, activation='relu',
                              kernel_regularizer=tf.keras.regularizers.l2(0.001)),
        tf.keras.layers.BatchNormalization(),
        tf.keras.layers.Dropout(0.2),
        tf.keras.layers.Dense(32, activation='relu'),
        tf.keras.layers.Dense(num_classes, activation='softmax'),
    ])

    model.compile(
        optimizer=tf.keras.optimizers.Adam(learning_rate=0.001),
        loss='sparse_categorical_crossentropy',
        metrics=['accuracy'],
    )

    return model


def train(X: np.ndarray, y: np.ndarray, num_epochs: int = 100):
    """Trains the model and returns the trained model + label encoder."""
    # Encode labels
    le = LabelEncoder()
    y_encoded = le.fit_transform(y)
    num_classes = len(le.classes_)

    print(f"\nTraining with {num_classes} classes:")
    for i, label in enumerate(le.classes_):
        count = np.sum(y_encoded == i)
        print(f"  [{i:2d}] {label}: {count} samples")

    # Split data
    X_train, X_val, y_train, y_val = train_test_split(
        X, y_encoded, test_size=0.2, random_state=42, stratify=y_encoded,
    )

    print(f"\nTrain set: {len(X_train)} samples")
    print(f"Val set:   {len(X_val)} samples")

    # Normalize
    X_train = normalize_landmarks(X_train)
    X_val = normalize_landmarks(X_val)

    # Build model
    model = build_model(num_classes)
    model.summary()

    # Callbacks
    callbacks = [
        tf.keras.callbacks.EarlyStopping(
            monitor='val_accuracy', patience=15, restore_best_weights=True,
        ),
        tf.keras.callbacks.ReduceLROnPlateau(
            monitor='val_loss', factor=0.5, patience=5, min_lr=1e-6,
        ),
    ]

    # Train
    history = model.fit(
        X_train, y_train,
        validation_data=(X_val, y_val),
        epochs=num_epochs,
        batch_size=32,
        callbacks=callbacks,
        verbose=1,
    )

    # Evaluate
    val_loss, val_acc = model.evaluate(X_val, y_val, verbose=0)
    print(f"\nFinal Validation Accuracy: {val_acc:.4f}")
    print(f"Final Validation Loss: {val_loss:.4f}")

    return model, le, history


def export_tflite(model: tf.keras.Model, output_path: str):
    """Exports model to TFLite format with quantization."""
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]

    tflite_model = converter.convert()

    with open(output_path, 'wb') as f:
        f.write(tflite_model)

    size_kb = len(tflite_model) / 1024
    print(f"TFLite model saved: {output_path} ({size_kb:.1f} KB)")

    return tflite_model


def save_labels(le: LabelEncoder, output_path: str):
    """Saves label mapping to JSON."""
    labels = {str(i): label for i, label in enumerate(le.classes_)}
    with open(output_path, 'w') as f:
        json.dump(labels, f, indent=2)
    print(f"Labels saved: {output_path}")


def save_config(le: LabelEncoder, model_name: str, output_path: str):
    """Saves model configuration to JSON."""
    config = {
        "model_name": model_name,
        "version": "1.0.0",
        "num_classes": len(le.classes_),
        "input_size": INPUT_SIZE,
        "gesture_labels": list(le.classes_),
        "recommended_threshold": 0.7,
    }
    with open(output_path, 'w') as f:
        json.dump(config, f, indent=2)
    print(f"Config saved: {output_path}")


def main():
    parser = argparse.ArgumentParser(description='Train sign language gesture classifier')
    parser.add_argument('--data', type=str, required=True, help='Path to CSV data file')
    parser.add_argument('--language', type=str, default='asl', help='Language code (asl, bsl, ipsl, csl)')
    parser.add_argument('--epochs', type=int, default=100, help='Number of training epochs')
    parser.add_argument('--output', type=str, default=None, help='Output directory')
    args = parser.parse_args()

    # Set output directory
    if args.output:
        output_dir = args.output
    else:
        output_dir = os.path.join(
            os.path.dirname(os.path.abspath(__file__)),
            '..', 'assets', 'models', args.language,
        )
    os.makedirs(output_dir, exist_ok=True)

    # Load and train
    X, y = load_data(args.data)
    model, le, history = train(X, y, args.epochs)

    # Export
    model_name = f"{args.language.upper()} Gesture Classifier"
    export_tflite(model, os.path.join(output_dir, 'model.tflite'))
    save_labels(le, os.path.join(output_dir, 'labels.json'))
    save_config(le, model_name, os.path.join(output_dir, 'config.json'))

    print(f"\n✅ Training complete for {args.language.upper()}")
    print(f"   Output: {output_dir}")


if __name__ == "__main__":
    main()
