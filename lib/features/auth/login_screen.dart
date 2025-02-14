import 'package:blood_sea/features/auth/bloc/auth_bloc.dart';
import 'package:blood_sea/features/auth/donor_registration_screen.dart';
import 'package:blood_sea/features/auth/client_signup_screen.dart';
import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class LoginScreen extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();

  LoginScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocListener<AuthBloc, AuthState>(listener: (context, state) {
      if (state is AuthError) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Text(state.message),
            backgroundColor: Colors.red,
          ),
        );
      }
    }, child: Scaffold(
      body: BlocBuilder<AuthBloc, AuthState>(builder: (context, state) {
        return SingleChildScrollView(
          child: Center(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 24.0),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  // Company logo placeholder
                  CircleAvatar(
                    radius: 50,
                    backgroundColor: Colors.white,
                    child: Image.asset('assets/logotx.png'),
                  ),
                  const SizedBox(height: 20),
                  // Blood donation symbol
                  // Icon(
                  //   Icons.bloodtype, // Blood donation symbol
                  //   color: Colors.red[800],
                  //   size: 80,
                  // ),
                  const SizedBox(height: 20),
                  Text(
                    "Blood Donation App",
                    style: TextStyle(
                      color: Colors.red[800],
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 20),
                  // Email text field
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
                  const SizedBox(height: 10),
                  // Password text field
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
                  const SizedBox(
                    height: 10,
                  ),

                  Container(
                    height: 40,
                    width: double.infinity,
                    padding: const EdgeInsets.symmetric(horizontal: 5.0),
                    child: RichText(
                      text: TextSpan(
                        style: const TextStyle(
                          fontWeight: FontWeight.bold,
                          fontStyle: FontStyle.italic,
                          color: Colors.blue, // Default color for the main text
                          fontSize: 12,
                        ),
                        children: <TextSpan>[
                          const TextSpan(
                              text: "If you are not a registered member, "),
                          TextSpan(
                              text: "please sign up",
                              style: const TextStyle(
                                  color: Colors.red), // Color for "sign up"
                              recognizer: TapGestureRecognizer()
                                ..onTap = () {
                                  Navigator.push(
                                    context,
                                    MaterialPageRoute(
                                        builder: (context) =>
                                            ClientSignUpScreen()),
                                    //MaterialPageRoute(builder: (context)=>userRegistration()),
                                  );
                                }),
                        ],
                      ),
                      textAlign: TextAlign.right, // Align the text to the right
                    ),
                  ),

                  //SizedBox(height: 10),
                  // Login button with logic
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: state is AuthLoading
                          ? null
                          : () {
                              final String email = _emailController.text.trim();
                              final String password =
                                  _passwordController.text.trim();

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
                  const SizedBox(
                    height: 30,
                  ),

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
                  )
                ],
              ),
            ),
          ),
        );
      }),
    ));
  }
}
