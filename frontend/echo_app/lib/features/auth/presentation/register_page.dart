import 'package:echo_app/features/assessment/presentation/assessment_intro_page.dart';
import 'package:echo_app/features/auth/presentation/auth_controller.dart';
import 'package:echo_app/features/auth/presentation/registration_data_provider.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterPage extends ConsumerStatefulWidget {
  RegisterPage({super.key});

  @override
  ConsumerState<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends ConsumerState<RegisterPage> {
  final email = TextEditingController();
  final password = TextEditingController();

  String? selectedTargetLanguage;
  String? selectedNativeLanguage;
  String? selectedLearningGoal;
  bool allowDataSharing = false;

  // Language mapping: display name -> language code
  final Map<String, String> languageCodes = {
    'Hungarian': 'hu',
    'English': 'en',
    'Spanish': 'es',
    'French': 'fr',
    'German': 'de',
    'Italian': 'it',
  };

  final List<String> nativeLanguages = [
    'Hungarian',
    'English',
    'Spanish',
    'French',
    'German',
    'Italian',
  ];

  final List<String> targetLanguages = [
    'English',
    'Spanish',
    'French',
    'German',
    'Italian',
  ];

  final List<String> learningGoals = [
    'Casual Conversation',
    'Business Communication',
    'Travel & Tourism',
    'Academic Study',
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const SizedBox(height: 40),
            const Text("Create Account", style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold)),
            const SizedBox(height: 24),
            
            // Email
            const Text("Email", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: email,
              decoration: InputDecoration(
                hintText: "your@email.com",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            
            // Password
            const Text("Password", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            TextField(
              controller: password,
              obscureText: true,
              decoration: InputDecoration(
                hintText: "Enter password",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            
            // Native Language
            const Text("Native Language", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: selectedNativeLanguage,
              items: nativeLanguages.map((lang) {
                return DropdownMenuItem(value: lang, child: Text(lang));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedNativeLanguage = value;
                });
              },
              decoration: InputDecoration(
                hintText: "Select your native language",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            
            // Target Language
            const Text("Target Language", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: selectedTargetLanguage,
              items: targetLanguages.map((lang) {
                return DropdownMenuItem(value: lang, child: Text(lang));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedTargetLanguage = value;
                });
              },
              decoration: InputDecoration(
                hintText: "Select language",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            
            // Learning Goal
            const Text("Learning Goal", style: TextStyle(fontWeight: FontWeight.w600)),
            const SizedBox(height: 8),
            DropdownButtonFormField<String>(
              initialValue: selectedLearningGoal,
              items: learningGoals.map((goal) {
                return DropdownMenuItem(value: goal, child: Text(goal));
              }).toList(),
              onChanged: (value) {
                setState(() {
                  selectedLearningGoal = value;
                });
              },
              decoration: InputDecoration(
                hintText: "Select goal",
                border: OutlineInputBorder(borderRadius: BorderRadius.circular(8)),
              ),
            ),
            const SizedBox(height: 16),
            
            // Data Sharing Checkbox
            CheckboxListTile(
              contentPadding: EdgeInsets.zero,
              title: const Text("Allow learning data sharing"),
              subtitle: const Text("Help us improve by sharing your learning data"),
              value: allowDataSharing,
              onChanged: (value) {
                setState(() {
                  allowDataSharing = value ?? false;
                });
              },
            ),
            const SizedBox(height: 32),
            
            // Register Button
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                onPressed: _canRegister() ? _register : null,
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 12),
                  child: Text("Create Account"),
                ),
              ),
            ),
            const SizedBox(height: 16),
            Center(
              child: TextButton(
                onPressed: () {
                  Navigator.pop(context);
                },
                child: const Text("Back to Login"),
              ),
            ),
          ],
        ),
      ),
    );
  }

  bool _canRegister() {
    return email.text.isNotEmpty &&
        password.text.isNotEmpty &&
        selectedNativeLanguage != null &&
        selectedTargetLanguage != null &&
        selectedLearningGoal != null;
  }

  void _register() async {
    print('[Register] Starting registration...');
    
    try {
      // 1. Register user
      await ref.read(authControllerProvider.notifier).register(
        email: email.text,
        password: password.text,
        nativeLanguage: languageCodes[selectedNativeLanguage]!,
        targetLanguage: languageCodes[selectedTargetLanguage]!,
        learningGoals: selectedLearningGoal!,
        allowLearningDataSharing: allowDataSharing,
        level: 1,
      );

      print('[Register] ✅ Registration successful, logging in...');

      if (!mounted) return;

      // 2. Login immediately
      await ref.read(authControllerProvider.notifier).login(
        email.text,
        password.text,
      );

      print('[Register] ✅ Login successful');

      if (!mounted) return;

      // 3. Save registration data to provider for assessment
      ref.read(registrationDataProvider.notifier).setData(
        email: email.text,
        password: password.text,
        nativeLanguage: languageCodes[selectedNativeLanguage]!,
        targetLanguage: languageCodes[selectedTargetLanguage]!,
        learningGoals: selectedLearningGoal!,
        allowLearningDataSharing: allowDataSharing,
      );

      print('[Register] ✅ Navigating to Assessment');

      // 4. Navigate to assessment
      if (!mounted) return;
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => const AssessmentIntroPage(),
        ),
      );
    } catch (e) {
      print('[Register] ❌ Error: $e');
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Registration failed: $e')),
      );
    }
  }

  @override
  void dispose() {
    email.dispose();
    password.dispose();
    super.dispose();
  }
}