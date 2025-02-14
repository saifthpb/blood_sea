import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'package:blood_sea/features/auth/bloc/signup_bloc.dart';
import 'package:blood_sea/features/auth/bloc/auth_bloc.dart';

class ClientSignUpScreen extends StatefulWidget {
  const ClientSignUpScreen({super.key});

  @override
  State<ClientSignUpScreen> createState() => _ClientSignUpScreenState();
}

class _ClientSignUpScreenState extends State<ClientSignUpScreen> {
  final _formKey = GlobalKey<FormState>();
  final _nameController = TextEditingController();
  final _emailController = TextEditingController();
  final _passwordController = TextEditingController();
  final _phoneController = TextEditingController();
  final _addressController = TextEditingController();

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _passwordController.dispose();
    _phoneController.dispose();
    _addressController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (context) => SignUpBloc(),
      child: Scaffold(
        appBar: AppBar(
          title: const Text('Client Sign Up'),
          backgroundColor: Colors.redAccent,
        ),
        body: BlocConsumer<SignUpBloc, SignUpState>(
          listener: (context, state) {
            if (state is SignUpSuccess) {
              // Show success message
              ScaffoldMessenger.of(context).showSnackBar(
                const SnackBar(
                  content: Text("Successfully Signed Up"),
                  backgroundColor: Colors.green,
                ),
              );

              // Update AuthBloc state with the new user
              context.read<AuthBloc>().add(
                    AuthStateChanged(state.user as User?),
                  );

              // Navigate to home screen
              context.go('/home');
            }

            if (state is SignUpFailure) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text(state.error),
                  backgroundColor: Colors.red,
                  duration: const Duration(seconds: 5),
                  action: SnackBarAction(
                    label: 'Retry',
                    onPressed: () {
                      // Retry signup
                      context.read<SignUpBloc>().add(
                            SignUpRequested(
                              name: _nameController.text.trim(),
                              email: _emailController.text.trim(),
                              password: _passwordController.text.trim(),
                              phone: _phoneController.text.trim(),
                              address: _addressController.text.trim(),
                            ),
                          );
                    },
                  ),
                ),
              );
            }
          },
          builder: (context, state) {
            return SingleChildScrollView(
              child: Container(
                padding: const EdgeInsets.all(16.0),
                child: Form(
                  key: _formKey,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Logo or Icon
                      const Icon(
                        Icons.person_add,
                        size: 100,
                        color: Colors.redAccent,
                      ),
                      const SizedBox(height: 24),

                      TextFormField(
                        controller: _nameController,
                        decoration: InputDecoration(
                          labelText: "Full Name",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon:
                              const Icon(Icons.person, color: Colors.red),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your full name';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _emailController,
                        decoration: InputDecoration(
                          labelText: "Email Address",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon:
                              const Icon(Icons.email, color: Colors.red),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        keyboardType: TextInputType.emailAddress,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your email address';
                          }
                          if (!RegExp(r'^[^@]+@[^@]+\.[^@]+').hasMatch(value)) {
                            return 'Please enter a valid email address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _passwordController,
                        decoration: InputDecoration(
                          labelText: "Password",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon: const Icon(Icons.lock, color: Colors.red),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        obscureText: true,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your password';
                          }
                          if (value.length < 6) {
                            return 'Password must be at least 6 characters long';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _phoneController,
                        decoration: InputDecoration(
                          labelText: "Mobile Number",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon:
                              const Icon(Icons.phone, color: Colors.red),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        keyboardType: TextInputType.phone,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your mobile number';
                          }
                          if (!RegExp(r'^\d+$').hasMatch(value)) {
                            return 'Please enter a valid mobile number';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 16),

                      TextFormField(
                        controller: _addressController,
                        decoration: InputDecoration(
                          labelText: "Address",
                          border: OutlineInputBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                          prefixIcon:
                              const Icon(Icons.location_on, color: Colors.red),
                          filled: true,
                          fillColor: Colors.grey[100],
                        ),
                        maxLines: 3,
                        validator: (value) {
                          if (value == null || value.isEmpty) {
                            return 'Please enter your address';
                          }
                          return null;
                        },
                      ),
                      const SizedBox(height: 24),

                      ElevatedButton(
                        onPressed: state is SignUpLoading
                            ? null
                            : () {
                                if (_formKey.currentState!.validate()) {
                                  context.read<SignUpBloc>().add(
                                        SignUpRequested(
                                          name: _nameController.text.trim(),
                                          email: _emailController.text.trim(),
                                          password:
                                              _passwordController.text.trim(),
                                          phone: _phoneController.text.trim(),
                                          address:
                                              _addressController.text.trim(),
                                        ),
                                      );
                                }
                              },
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.red,
                          foregroundColor: Colors.white,
                          padding: const EdgeInsets.symmetric(vertical: 15),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(10),
                          ),
                        ),
                        child: state is SignUpLoading
                            ? const SizedBox(
                                height: 20,
                                width: 20,
                                child: CircularProgressIndicator(
                                  color: Colors.white,
                                  strokeWidth: 2,
                                ),
                              )
                            : const Text(
                                "Sign Up",
                                style: TextStyle(fontSize: 16),
                              ),
                      ),
                      const SizedBox(height: 16),

                      TextButton(
                        onPressed: () => context.go('/donor-registration'),
                        child: const Text(
                          "Want to be a donor? Register here",
                          style: TextStyle(
                            fontSize: 16,
                            color: Colors.blue,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ),
                    ],
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
