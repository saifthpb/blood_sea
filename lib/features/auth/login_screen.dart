import 'package:blood_sea/features/auth/bloc/auth_bloc.dart';
import 'package:blood_sea/features/auth/donor_registration_screen.dart';
import 'package:blood_sea/features/auth/client_signup_screen.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginScreen({super.key}) {
    // Set default values for local development
    if (kDebugMode) {
      _emailController.text = 'roquib03@gmail.com';
      _passwordController.text = '12345678';
    }
  }

  @override
  Widget build(BuildContext context) {
    // Get the screen height
    final screenHeight = MediaQuery.of(context).size.height;

    return BlocListener<AuthBloc, AuthState>(
      listener: (context, state) {
        if (state is AuthError) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text(state.message),
              backgroundColor: Colors.red,
            ),
          );
        }
      },
      child: Scaffold(
        body: BlocBuilder<AuthBloc, AuthState>(
          builder: (context, state) {
            return SingleChildScrollView(
              child: Container(
                // Set minimum height to screen height
                constraints: BoxConstraints(
                  minHeight: screenHeight,
                ),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 24.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center, // Center vertically
                      crossAxisAlignment: CrossAxisAlignment.center,
                      children: [
                        // Company logo
                        CircleAvatar(
                          radius: 50,
                          backgroundColor: Colors.white,
                          child: Image.asset('assets/logotx.png'),
                        ),
                        const SizedBox(height: 20),

                        Text(
                          "Blood Donation App",
                          style: TextStyle(
                            color: Colors.red[800],
                            fontSize: 24,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        const SizedBox(height: 40), // Increased spacing

                        // Email field
                        TextField(
                          controller: _emailController,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.email, color: Colors.red[800]),
                            labelText: 'Email',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 16), // Increased spacing

                        // Password field
                        TextField(
                          controller: _passwordController,
                          obscureText: true,
                          decoration: InputDecoration(
                            prefixIcon: Icon(Icons.lock, color: Colors.red[800]),
                            labelText: 'Password',
                            filled: true,
                            fillColor: Colors.white,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(10),
                              borderSide: BorderSide.none,
                            ),
                          ),
                        ),
                        const SizedBox(height: 24), // Increased spacing

                        // Sign up text
                        Container(
                          width: double.infinity,
                          padding: const EdgeInsets.symmetric(horizontal: 5.0),
                          child: RichText(
                            text: TextSpan(
                              style: const TextStyle(
                                fontWeight: FontWeight.bold,
                                fontStyle: FontStyle.italic,
                                color: Colors.blue,
                                fontSize: 12,
                              ),
                              children: <TextSpan>[
                                const TextSpan(
                                  text: "If you are not a registered member, ",
                                ),
                                TextSpan(
                                  text: "please sign up",
                                  style: const TextStyle(color: Colors.red),
                                  recognizer: TapGestureRecognizer()
                                    ..onTap = () {
                                      Navigator.push(
                                        context,
                                        MaterialPageRoute(
                                          builder: (context) => ClientSignUpScreen(),
                                        ),
                                      );
                                    },
                                ),
                              ],
                            ),
                            textAlign: TextAlign.right,
                          ),
                        ),
                        const SizedBox(height: 24), // Increased spacing

                        // Login button
                        SizedBox(
                          width: double.infinity,
                          child: ElevatedButton(
                            onPressed: state is AuthLoading
                                ? null
                                : () {
                                    final String email = _emailController.text.trim();
                                    final String password = _passwordController.text.trim();

                                    if (email.isEmpty || password.isEmpty) {
                                      ScaffoldMessenger.of(context).showSnackBar(
                                        const SnackBar(
                                          content: Text("Please fill in all fields"),
                                        ),
                                      );
                                      return;
                                    }

                                    context.read<AuthBloc>().add(
                                          LoginRequested(email, password),
                                        );
                                  },
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.red[800],
                              padding: const EdgeInsets.symmetric(vertical: 15),
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(10),
                              ),
                            ),
                            child: state is AuthLoading
                                ? const CircularProgressIndicator(color: Colors.white)
                                : const Text(
                                    "Login",
                                    style: TextStyle(
                                      fontSize: 18,
                                      color: Colors.white,
                                    ),
                                  ),
                          ),
                        ),
                        const SizedBox(height: 30),

                        // Donor registration card
                        GestureDetector(
                          onTap: () {
                            Navigator.push(
                              context,
                              MaterialPageRoute(
                                builder: (context) => const DonorRegistrationScreen(),
                              ),
                            );
                          },
                          child: Card(
                            elevation: 5,
                            color: Colors.blue,
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(8),
                            ),
                            child: const Padding(
                              padding: EdgeInsets.all(5.0),
                              child: Column(
                                mainAxisAlignment: MainAxisAlignment.center,
                                mainAxisSize: MainAxisSize.min,
                                children: [
                                  Text(
                                    "Want to be a Donor?",
                                    style: TextStyle(
                                      fontSize: 10,
                                      color: Colors.yellow,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                  SizedBox(height: 5),
                                  Icon(
                                    Icons.people_outline,
                                    color: Colors.white,
                                  ),
                                  Text(
                                    "Go Donor Registration",
                                    style: TextStyle(
                                      color: Colors.white,
                                      fontWeight: FontWeight.bold,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
