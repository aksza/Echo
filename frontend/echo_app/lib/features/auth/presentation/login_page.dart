import 'package:echo_app/features/auth/presentation/register_page.dart';
import 'package:echo_app/shared/app_shell.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../presentation/auth_controller.dart';

class LoginPage extends ConsumerWidget {
  LoginPage({super.key});

  final email = TextEditingController();
  final password = TextEditingController();

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final state = ref.watch(authControllerProvider);

    ref.listen(authControllerProvider, (previous, next) {
      next.when(
        data: (_) {},
        error: (error, stackTrace) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('Error: $error'),
              backgroundColor: Colors.red,
            ),
          );
        },
        loading: () {},
      );
    });

    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(24),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const Text(
              "Login",
              style: TextStyle(fontSize: 28),
            ),

            const SizedBox(height: 32),

            TextField(
              controller: email,
              decoration: const InputDecoration(
                hintText: "Email",
              ),
            ),

            const SizedBox(height: 12),

            TextField(
              controller: password,
              obscureText: true,
              decoration: const InputDecoration(
                hintText: "Password",
              ),
            ),

            const SizedBox(height: 24),

            state.isLoading
                ? const CircularProgressIndicator()
                : ElevatedButton(
                    onPressed: () async {
                      try {
                        await ref
                            .read(authControllerProvider.notifier)
                            .login(
                              email.text,
                              password.text,
                            );

                        if (!context.mounted) return;

                        Navigator.pushReplacement(
                          context,
                          MaterialPageRoute(
                            builder: (_) => const AppShell(),
                          ),
                        );
                      } catch (_) {}
                    },
                    child: const Text("Login"),
                  ),

            TextButton(
              onPressed: () {
                Navigator.push(
                  context,
                  MaterialPageRoute(
                    builder: (_) => RegisterPage(),
                  ),
                );
              },
              child: const Text("Create account"),
            ),
          ],
        ),
      ),
    );
  }
}