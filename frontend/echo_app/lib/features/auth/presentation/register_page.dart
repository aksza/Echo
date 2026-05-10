import 'package:echo_app/features/assessment/presentation/assessment_intro_page.dart';
import 'package:echo_app/features/auth/presentation/auth_controller.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

class RegisterPage extends ConsumerWidget {
  RegisterPage({super.key});

  final email = TextEditingController();
  final password = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (previous, next) {
      next.whenOrNull(
        data: (token) {
          final action = ref.read(lastAuthActionProvider);

          if (token != null && action == 'register') {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                builder: (_) => const AssessmentIntroPage(),
              ),
            );
          }
        },
        error: (error, _) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text("Registration failed: $error")),
          );
        },
      );
    });

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text("Register", style: TextStyle(fontSize: 28)),
            const SizedBox(height: 24),
            TextField(
              controller: email,
              decoration: const InputDecoration(hintText: "Email"),
            ),
            const SizedBox(height: 12),
            TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(hintText: "Password"),
            ),
            const SizedBox(height: 24),
            state.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () {
                      ref
                          .read(authControllerProvider.notifier)
                          .register(email.text, password.text);
                    },
                    child: const Text("Register"),
                  ),
          ],
        ),
      ),
    );
  }
}