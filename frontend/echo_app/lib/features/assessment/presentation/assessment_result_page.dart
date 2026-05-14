import 'package:echo_app/features/assessment/data/assessment_result.dart';
import 'package:echo_app/features/assessment/presentation/assessment_data_provider.dart';
import 'package:echo_app/features/auth/presentation/auth_controller.dart';
import 'package:echo_app/features/auth/presentation/registration_data_provider.dart';
import 'package:echo_app/core/network/dio_client.dart';
import 'package:echo_app/shared/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:dio/dio.dart';

class AssessmentResultPage extends ConsumerStatefulWidget {
  const AssessmentResultPage({super.key});

  @override
  ConsumerState<AssessmentResultPage> createState() => _AssessmentResultPageState();
}

class _AssessmentResultPageState extends ConsumerState<AssessmentResultPage> {
  bool isLoading = true;
  String? errorMsg;
  AssessmentResult? writingResult;
  AssessmentResult? speakingResult;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (mounted) {
        _callAssessmentAPIs();
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return WillPopScope(
      onWillPop: () async => false,
      child: Scaffold(
        appBar: AppBar(title: const Text("Assessment Results")),
        body: _buildBody(),
      ),
    );
  }

  Widget _buildBody() {
    if (isLoading) {
      return Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            const Text(
              "Processing your assessment...",
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text("This may take a moment"),
          ],
        ),
      );
    }

    if (errorMsg != null) {
      return Center(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.error_outline, size: 64, color: Colors.red),
              const SizedBox(height: 24),
              const Text(
                "Assessment Error",
                style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 12),
              Text(
                errorMsg!,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 14),
              ),
              const SizedBox(height: 32),
              ElevatedButton(
                onPressed: () {
                  setState(() {
                    isLoading = true;
                    errorMsg = null;
                  });
                  _callAssessmentAPIs();
                },
                child: const Text("Retry"),
              ),
            ],
          ),
        ),
      );
    }

    // Success UI
    return SingleChildScrollView(
      padding: const EdgeInsets.all(24),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            "🎉 Assessment Complete!",
            style: TextStyle(
              fontSize: 28,
              fontWeight: FontWeight.bold,
              color: Colors.green,
            ),
          ),
          const SizedBox(height: 32),
          if (writingResult != null) _buildCard("✍️ Writing Assessment", writingResult!),
          const SizedBox(height: 16),
          if (speakingResult != null) _buildCard("🎤 Speaking Assessment", speakingResult!),
          const SizedBox(height: 32),
          SizedBox(
            width: double.infinity,
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.green,
                padding: const EdgeInsets.symmetric(vertical: 16),
              ),
              onPressed: () {
                Navigator.pushAndRemoveUntil(
                  context,
                  MaterialPageRoute(builder: (_) => const AppShell()),
                  (route) => false,
                );
              },
              child: const Text(
                "Go to Home",
                style: TextStyle(fontSize: 16, color: Colors.white),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildCard(String title, AssessmentResult result) {
    return Card(
      elevation: 4,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
              ),
            ),
            const SizedBox(height: 16),
            _levelBadge(result.level),
            const SizedBox(height: 12),
            _infoRow("Score", "${result.score}/100"),
            const SizedBox(height: 8),
            _infoRow("Confidence", "${(result.confidence * 100).toStringAsFixed(1)}%"),
            const SizedBox(height: 16),
            const Divider(),
            const SizedBox(height: 8),
            const Text("Feedback:", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            Text(result.feedback),
          ],
        ),
      ),
    );
  }

  Widget _levelBadge(String level) {
    final colors = {
      "A1": Colors.blue,
      "A2": Colors.blue[300] ?? Colors.blue,
      "B1": Colors.orange,
      "B2": Colors.orange[300] ?? Colors.orange,
      "C1": Colors.red,
      "C2": Colors.red[300] ?? Colors.red,
    };

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
      decoration: BoxDecoration(
        color: colors[level] ?? Colors.grey,
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(
        "Level: $level",
        style: const TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _infoRow(String label, String value) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Text(label),
        Text(value, style: const TextStyle(fontWeight: FontWeight.bold)),
      ],
    );
  }

  Future<void> _callAssessmentAPIs() async {
    try {
      print('[AssessmentResult] Starting assessment API calls');

      // Get all needed data
      final authToken = ref.read(authTokenProvider);
      final assessmentData = ref.read(assessmentDataProvider);
      final registrationData = ref.read(registrationDataProvider);

      if (authToken == null || authToken.isEmpty) {
        throw Exception("Not authenticated - token missing");
      }

      if (assessmentData.writingText.isEmpty) {
        throw Exception("Writing text not provided");
      }

      if (assessmentData.audioFile == null) {
        throw Exception("Audio file not provided");
      }

      if (registrationData == null) {
        throw Exception("Registration data not found");
      }

      final dio = DioClient().dio;

      // 1. Call writing assessment API
      print('[AssessmentResult] 1️⃣ Calling /assessment/text...');
      final writingResponse = await dio.post(
        '/assessment/text',
        data: {
          "text": assessmentData.writingText,
        },
        options: Options(
          headers: {"Authorization": "Bearer $authToken"},
        ),
      );

      if (!mounted) return;
      print('[AssessmentResult] ✅ Writing API response: ${writingResponse.data}');
      writingResult = AssessmentResult.fromJson(writingResponse.data);

      // 2. Call speaking assessment API
      print('[AssessmentResult] 2️⃣ Calling /assessment/speaking...');
      final formData = FormData.fromMap({
        "audioFile": await MultipartFile.fromFile(
          assessmentData.audioFile!.path,
          filename: "recording.wav",
        ),
        "targetLanguage": registrationData.targetLanguage,
      });

      if (!mounted) return;

      final speakingResponse = await dio.post(
        '/assessment/speaking',
        data: formData,
        options: Options(
          headers: {"Authorization": "Bearer $authToken"},
          contentType: "multipart/form-data",
        ),
      );

      if (!mounted) return;
      print('[AssessmentResult] ✅ Speaking API response: ${speakingResponse.data}');
      speakingResult = AssessmentResult.fromJson(speakingResponse.data);

      // Update UI
      if (!mounted) return;
      setState(() {
        isLoading = false;
      });

      print('[AssessmentResult] ✅ All APIs completed successfully');

      // Clear data
      ref.read(assessmentDataProvider.notifier).clear();

    } catch (e) {
      print('[AssessmentResult] ❌ Error: $e');
      if (!mounted) return;
      setState(() {
        isLoading = false;
        errorMsg = e.toString();
      });
    }
  }
}
