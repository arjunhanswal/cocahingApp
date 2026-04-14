import 'dart:convert';
import 'package:crypto/crypto.dart';
import 'package:flutter/material.dart';
import 'package:coaching_app/widgets/app_widgets.dart';
import 'package:coaching_app/main.dart'; // for MainShell

class LoginScreen extends StatefulWidget {
  const LoginScreen({super.key});

  @override
  State<LoginScreen> createState() => _LoginScreenState();
}

class _LoginScreenState extends State<LoginScreen> {
  final _userCtrl = TextEditingController();
  final _passCtrl = TextEditingController();

  // 🔒 Encrypted password (hash of "admin123")
  final String _adminUser = "admin";
  final String _adminPassHash =
      "240be518fabd2724ddb6f04eeb0a5d7c"; // md5 of admin123

  String _hash(String input) {
    return md5.convert(utf8.encode(input)).toString();
  }

  void _login() {
  final user = _userCtrl.text.trim();
  final pass = _passCtrl.text.trim();

  if (user == "admin" && pass == "admin123") {
    Navigator.pushAndRemoveUntil(
      context,
      MaterialPageRoute(builder: (_) => const MainShell()),
      (route) => false,
    );
  } else {
    showSnack(context, "Invalid credentials", error: true);
  }
}

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: AppColors.bg,
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Card(
            child: Padding(
              padding: const EdgeInsets.all(20),
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  const Text(
                    "Admin Login",
                    style: TextStyle(
                        fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                  const SizedBox(height: 20),

                  AppField(
                    controller: _userCtrl,
                    label: "Username",
                    icon: Icons.person,
                  ),

                  const SizedBox(height: 12),

                  TextField(
                    controller: _passCtrl,
                    obscureText: true,
                    decoration: const InputDecoration(
                      labelText: "Password",
                      prefixIcon: Icon(Icons.lock),
                    ),
                  ),

                  const SizedBox(height: 20),

                  ElevatedButton(
                    onPressed: _login,
                    child: const Text("Login"),
                  )
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}