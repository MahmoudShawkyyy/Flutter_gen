import 'dart:io';
import 'package:flutter/material.dart';
import 'package:file_picker/file_picker.dart';
import 'package:genome/src/theme/app_background.dart';
import '../../main.dart'; // ← عشان AutoTranslateText
import 'package:provider/provider.dart';
import '../utils/language_provider.dart';

class DiseaseDetectionScreen extends StatefulWidget {
  const DiseaseDetectionScreen({super.key});

  @override
  State<DiseaseDetectionScreen> createState() => _DiseaseDetectionScreenState();
}

class _DiseaseDetectionScreenState extends State<DiseaseDetectionScreen> {
  File? selectedFile;
  bool isLoading = false;

  String? disease;
  double? probability;
  String? risk;

  void generateStaticPrediction() {
    List<String> diseases = [
      "Breast Cancer",
      "Type 2 Diabetes",
      "Cardiovascular Disorder",
      "Alzheimer's Disease",
      "Asthma",
      "Celiac Disease"
    ];

    List<String> risks = ["High", "Medium", "Low"];

    disease = (diseases..shuffle()).first;
    risk = (risks..shuffle()).first;
    probability = (50 + (50 * (1 - risks.indexOf(risk!) * 0.4))) / 100;

    setState(() {});
  }

  Future<void> pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['csv', 'txt'],
    );

    if (result != null && result.files.single.path != null) {
      setState(() {
        selectedFile = File(result.files.single.path!);
        disease = null;
        probability = null;
        risk = null;
      });
    }
  }

  Future<void> analyzeFake() async {
    if (selectedFile == null) return;
    setState(() => isLoading = true);

    await Future.delayed(const Duration(seconds: 2));

    generateStaticPrediction();

    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: AutoTranslateText("✅ DNA successfully analyzed!")),
    );

    setState(() => isLoading = false);
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDark = theme.brightness == Brightness.dark;

    return AppBackground(
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 40),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            AutoTranslateText(
              "🧬 Disease Detection",
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.bold,
                color: isDark ? Colors.white : const Color(0xFF1E2046),
              ),
            ),
            const SizedBox(height: 10),
            AutoTranslateText(
              "Upload DNA SNP file (.CSV)",
              style: theme.textTheme.bodyMedium?.copyWith(
                color: isDark ? Colors.white70 : Colors.black54,
              ),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 25),

            GestureDetector(
              onTap: pickFile,
              child: Container(
                width: double.infinity,
                height: 150,
                decoration: BoxDecoration(
                  border: Border.all(
                      color: isDark ? Colors.white30 : Colors.black26),
                  borderRadius: BorderRadius.circular(14),
                  color: isDark ? Colors.white10 : Colors.white.withOpacity(0.8),
                ),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.upload_file,
                          size: 55,
                          color: isDark
                              ? Colors.purpleAccent
                              : const Color(0xFF1E2046)),
                      const SizedBox(height: 10),
                      AutoTranslateText(
                        selectedFile == null
                            ? "Tap to select File"
                            : selectedFile!.path.split('/').last,
                        style: TextStyle(
                          fontWeight: FontWeight.w500,
                          color: isDark ? Colors.white : Colors.black87,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),

            const SizedBox(height: 30),

            ElevatedButton.icon(
              onPressed: isLoading ? null : analyzeFake,
              icon: isLoading
                  ? const SizedBox(
                      height: 18,
                      width: 18,
                      child: CircularProgressIndicator(
                          color: Colors.white, strokeWidth: 2))
                  : const Icon(Icons.medical_information_rounded),
              label: AutoTranslateText(isLoading ? "Analyzing..." : "Detect Disease"),
              style: ElevatedButton.styleFrom(
                padding:
                    const EdgeInsets.symmetric(horizontal: 30, vertical: 14),
                backgroundColor: isDark
                    ? Colors.purpleAccent
                    : const Color(0xFF1E2046),
                shape: const StadiumBorder(),
              ),
            ),

            const SizedBox(height: 30),

            if (disease != null)
              AnimatedOpacity(
                opacity: 1.0,
                duration: const Duration(milliseconds: 500),
                child: Container(
                  width: double.infinity,
                  padding: const EdgeInsets.all(20),
                  decoration: BoxDecoration(
                    gradient: isDark
                        ? LinearGradient(
                            colors: [Colors.white10, Colors.white12],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          )
                        : LinearGradient(
                            colors: [Colors.white, Colors.white70],
                            begin: Alignment.topLeft,
                            end: Alignment.bottomRight,
                          ),
                    borderRadius: BorderRadius.circular(18),
                    boxShadow: [
                      BoxShadow(
                        blurRadius: 12,
                        spreadRadius: 1,
                        offset: const Offset(0, 4),
                        color: Colors.black.withOpacity(0.12),
                      ),
                    ],
                    border: Border.all(
                      color: isDark ? Colors.white12 : Colors.black12,
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.health_and_safety_rounded,
                          size: 50,
                          color: risk == "High"
                              ? Colors.redAccent
                              : risk == "Medium"
                                  ? Colors.orangeAccent
                                  : Colors.green),
                      const SizedBox(height: 8),
                      AutoTranslateText(
                        "Disease Prediction 🔍",
                        style: theme.textTheme.titleMedium?.copyWith(
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : const Color(0xFF1E2046),
                        ),
                      ),
                      const SizedBox(height: 14),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.coronavirus_rounded,
                              color: Colors.pink),
                          const SizedBox(width: 10),
                          AutoTranslateText(
                            "Disease: $disease",
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.warning_amber_rounded,
                              color: Colors.amber),
                          const SizedBox(width: 10),
                          Chip(
                            label: AutoTranslateText(
                              risk!,
                              style: const TextStyle(
                                  color: Colors.white,
                                  fontWeight: FontWeight.bold),
                            ),
                            backgroundColor: risk == "High"
                                ? Colors.redAccent
                                : risk == "Medium"
                                    ? Colors.orangeAccent
                                    : Colors.green,
                          ),
                        ],
                      ),

                      const SizedBox(height: 10),

                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.percent_rounded,
                              color: Colors.blueAccent),
                          const SizedBox(width: 10),
                          AutoTranslateText(
                            "Probability: ${(probability! * 100).toStringAsFixed(1)}%",
                            style: theme.textTheme.bodyLarge
                                ?.copyWith(fontWeight: FontWeight.w600),
                          ),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
          ],
        ),
      ),
    );
  }
}
