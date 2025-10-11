import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_app/models/auth_services.dart';
import 'package:flutter_app/screens/dashboard.dart';
import 'package:flutter_app/screens/signup.dart';
import 'package:flutter_app/styles/app_styles.dart';
import 'package:flutter_app/localization/words.dart';
import 'package:flutter_app/screens/reset_password_page.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _controllerEmail = TextEditingController();
  final TextEditingController _controllerPassword = TextEditingController();
  String errormessage = '';
  bool _isLoading = false;

  @override
  void dispose() {
    _controllerEmail.dispose();
    _controllerPassword.dispose();
    super.dispose();
  }

  void _signIn() async {
    final email = _controllerEmail.text;
    final password = _controllerPassword.text;
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true; // Show loading indicator
      });

      try {
        await authServiceNotifier.value.signIn(
          email: email,
          password: password,
        );
        // If sign-in is successful, navigate to the Home page
        if (mounted) {
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => const DashboardPage()),
          );
        }
      } on FirebaseAuthException catch (e) {
        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(e.message ?? 'An error occurred'),
              backgroundColor: Colors.red,
            ),
          );
        }
      } finally {
        if (mounted) {
          setState(() {
            _isLoading = false; // Hide loading indicator
          });
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(Words.signIn),
        leading: IconButton(
          onPressed: () {
            Navigator.pop(context);
          },
          icon: Icon(
            Icons.arrow_back_ios,
            color: Theme.of(context).colorScheme.primary,
          ),
        ),
      ),
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(15.0),
          child: Column(
            children: [
              const SizedBox(height: 30.0),
              //const Text(Words.signIn, style: AppTextStyles.xxlBold),
              ClipRRect(
                // The value (e.g., 8.0) controls how rounded the corners are.
                borderRadius: BorderRadius.circular(8.0),
                child: Image.asset(
                  'assets/icon/icon.png',
                  width: 100,
                  height: 100,
                  fit: BoxFit
                      .cover, // Optional: ensures the image fills the space
                ),
              ),
              const SizedBox(height: 10.0),
              const Text(
                Words
                    .welcomeMessage, // Added a placeholder for a welcome message
                style: AppTextStyles.icons,
              ),
              const SizedBox(height: 50),
              Form(
                key: _formKey,
                child: Center(
                  child: Column(
                    children: [
                      TextFormField(
                        controller: _controllerEmail,
                        decoration: const InputDecoration(
                          labelText: Words.email,
                        ),
                        validator: (String? value) {
                          if (value == null || value.trim().isEmpty) {
                            return Words.enterSomething;
                          }
                          // Add more email validation if needed
                          return null;
                        },
                      ),
                      const SizedBox(height: 10),
                      TextFormField(
                        controller: _controllerPassword,
                        obscureText: true, // Use this for passwords
                        decoration: const InputDecoration(
                          labelText: Words.password,
                        ),
                        validator: (String? value) {
                          if (value == null || value.trim().isEmpty) {
                            return Words.enterSomething;
                          }
                          return null;
                        },
                        style: AppTextStyles.m,
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            if (_controllerEmail.text.isNotEmpty) {
                              Navigator.push(
                                context,
                                MaterialPageRoute(
                                  builder: (context) {
                                    return ResetPasswordPage(
                                      email: _controllerEmail.text,
                                    );
                                  },
                                ),
                              );
                            } else {
                              ScaffoldMessenger.of(context).showSnackBar(
                                const SnackBar(
                                  content: Text(
                                    'Please enter an email address',
                                  ),
                                ),
                              );
                            }
                          },
                          child: const Text(Words.resetPassword),
                        ),
                      ),
                      Align(
                        alignment: Alignment.centerRight,
                        child: TextButton(
                          onPressed: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) {
                                  return SignUpFormScreen();
                                },
                              ),
                            );
                          },
                          child: const Text(Words.signup),
                        ),
                      ),
                      const SizedBox(height: 20),
                      Text(
                        errormessage,
                        style: TextStyle(backgroundColor: Colors.redAccent),
                      ),

                      ElevatedButton(
                        onPressed: _signIn, // Your sign-in method
                        style: Theme.of(context).elevatedButtonTheme.style,
                        child: const Text(Words.signIn),
                      ),
                      if (_isLoading)
                        const Padding(
                          padding: EdgeInsets.all(16.0),
                          child: CircularProgressIndicator(),
                        ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
