# AI Models Implementation Guide

## 1. Disease Detection Model (PlantVillage)
To implement the image-based disease detection, we recommend using a TensorFlow Lite model trained on the PlantVillage dataset.

### Steps to Download & Integrate:

1.  **Download the Model:**
    *   We recommend the **PlantVillage-MobileNetV2** model.
    *   You can find a high-quality pre-trained `.tflite` model and `labels.txt` in these repositories:
        *   [Plant-Disease-Detection-Android](https://github.com/mowael/Plant-Disease-Detection-Android/tree/master/app/src/main/assets) (Check assets folder)
        *   Or search for "PlantVillage MobileNetV2 tflite" on Kaggle.

2.  **Add to Project:**
    *   Create a folder `assets/models/`.
    *   Place `plant_disease_model.tflite` and `labels.txt` inside.

3.  **Update `pubspec.yaml`:**
    ```yaml
    assets:
      - assets/models/
    ```

## 2. Chatbot Model
For the highly accurate chatbot, connecting to an API is recommended over a local model for mobile performance. However, for a self-hosted "backend" approach:

*   **Repository:** [Krishi-Mithra](https://github.com/KeertiVijapur/Krishi-Mithra)
    *   Uses XGBoost for crop recommendation.
    *   Uses ResNet for disease prediction.
*   **Integration:**
    *   You would need to host this Python project (Flask/Django) on a server (Heroku/AWS).
    *   The Flutter app will send HTTP requests to this server.

## 3. Flutter Implementation
The current codebase includes:
*   `DiseaseDetectionScreen`: Handles camera and image selection.
*   `AIService`: A placeholder service ready to connect to TFLite (add `tflite_flutter` package to enable).
*   `AdminDashboard`: A complete UI for managing the system.
