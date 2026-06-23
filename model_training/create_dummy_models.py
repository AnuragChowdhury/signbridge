"""
Script to create dummy/placeholder TFLite models for all sign languages.

These models have the correct input/output shape (63 → N classes) but
contain random weights. Replace with real trained models for production use.

Usage:
    python create_dummy_models.py

Output:
    ../assets/models/{language}/model.tflite
    ../assets/models/{language}/labels.json
    ../assets/models/{language}/config.json
"""

import json
import os
import numpy as np

# Check if TensorFlow is available, use a pure-Python approach if not
try:
    import tensorflow as tf
    HAS_TF = True
except ImportError:
    HAS_TF = False
    print("WARNING: TensorFlow not available. Creating minimal TFLite models using flatbuffers.")


# Language configurations
LANGUAGES = {
    "asl": {
        "name": "ASL Gesture Classifier",
        "display_name": "American Sign Language",
        "labels": list("ABCDEFGHIJKLMNOPQRSTUVWXYZ") + ["SPACE", "DELETE", "NOTHING"],
    },
    "bsl": {
        "name": "BSL Gesture Classifier",
        "display_name": "British Sign Language",
        "labels": list("ABCDEFGHIJKLMNOPQRSTUVWXYZ") + ["SPACE", "DELETE", "NOTHING"],
    },
    "ipsl": {
        "name": "IPSL Gesture Classifier",
        "display_name": "Indo-Pakistani Sign Language",
        "labels": list("ABCDEFGHIJKLMNOPQRSTUVWXYZ") + ["SPACE", "DELETE", "NOTHING"],
    },
    "csl": {
        "name": "CSL Gesture Classifier",
        "display_name": "Chinese Sign Language",
        "labels": list("ABCDEFGHIJKLMNOPQRSTUVWXYZ") + ["SPACE", "DELETE", "NOTHING"],
    },
}

INPUT_SIZE = 63  # 21 landmarks * 3 coordinates


def create_model_tf(num_classes: int) -> bytes:
    """Creates a TFLite model using TensorFlow/Keras."""
    model = tf.keras.Sequential([
        tf.keras.layers.Input(shape=(INPUT_SIZE,)),
        tf.keras.layers.Dense(128, activation='relu'),
        tf.keras.layers.Dropout(0.3),
        tf.keras.layers.Dense(64, activation='relu'),
        tf.keras.layers.Dropout(0.2),
        tf.keras.layers.Dense(32, activation='relu'),
        tf.keras.layers.Dense(num_classes, activation='softmax'),
    ])

    model.compile(
        optimizer='adam',
        loss='sparse_categorical_crossentropy',
        metrics=['accuracy'],
    )

    # Convert to TFLite
    converter = tf.lite.TFLiteConverter.from_keras_model(model)
    converter.optimizations = [tf.lite.Optimize.DEFAULT]
    tflite_model = converter.convert()

    return tflite_model


def create_minimal_tflite(num_classes: int) -> bytes:
    """
    Creates a minimal valid TFLite flatbuffer without TensorFlow.
    This produces a simple model with random weights.
    """
    # For simplicity, we'll create a very small model using numpy
    # and the TFLite flatbuffer format

    # Since creating a raw flatbuffer is complex, let's create
    # a tiny TF model if available, otherwise use a placeholder
    if HAS_TF:
        return create_model_tf(num_classes)

    # Fallback: create a minimal placeholder file that can be
    # replaced with a real model later
    print("  -> Creating placeholder model file (replace with real TFLite model)")

    # Create a minimal valid-looking binary (will need real model for inference)
    header = b'TFL3'  # TFLite flatbuffer magic bytes
    # This is just a placeholder - real model needed for inference
    return header + b'\x00' * 1024


def create_labels_json(labels: list) -> dict:
    """Creates a label mapping JSON."""
    return {str(i): label for i, label in enumerate(labels)}


def create_config_json(name: str, labels: list) -> dict:
    """Creates a model configuration JSON."""
    return {
        "model_name": name,
        "version": "1.0.0",
        "num_classes": len(labels),
        "input_size": INPUT_SIZE,
        "gesture_labels": labels,
        "recommended_threshold": 0.7,
        "description": f"Gesture classifier for {name}",
        "input_description": "21 hand landmarks x 3 coordinates (x, y, z), normalized",
        "output_description": f"Probability distribution over {len(labels)} gesture classes",
    }


def main():
    base_dir = os.path.join(os.path.dirname(os.path.abspath(__file__)), '..', 'assets', 'models')

    for lang_code, lang_config in LANGUAGES.items():
        print(f"\n{'='*60}")
        print(f"Creating model for: {lang_config['display_name']} ({lang_code.upper()})")
        print(f"{'='*60}")

        lang_dir = os.path.join(base_dir, lang_code)
        os.makedirs(lang_dir, exist_ok=True)

        labels = lang_config["labels"]
        num_classes = len(labels)
        print(f"  Classes: {num_classes}")

        # Create TFLite model
        print(f"  Creating TFLite model...")
        tflite_bytes = create_minimal_tflite(num_classes)
        model_path = os.path.join(lang_dir, "model.tflite")
        with open(model_path, "wb") as f:
            f.write(tflite_bytes)
        print(f"  -> Model saved: {model_path} ({len(tflite_bytes)} bytes)")

        # Create labels.json
        labels_data = create_labels_json(labels)
        labels_path = os.path.join(lang_dir, "labels.json")
        with open(labels_path, "w") as f:
            json.dump(labels_data, f, indent=2)
        print(f"  -> Labels saved: {labels_path}")

        # Create config.json
        config_data = create_config_json(lang_config["name"], labels)
        config_path = os.path.join(lang_dir, "config.json")
        with open(config_path, "w") as f:
            json.dump(config_data, f, indent=2)
        print(f"  -> Config saved: {config_path}")

    print(f"\n{'='*60}")
    print("All models created successfully!")
    print(f"{'='*60}")


if __name__ == "__main__":
    main()
