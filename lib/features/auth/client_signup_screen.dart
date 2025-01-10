import 'package:blood_sea/features/donors/donors_area_screen.dart';
import 'package:blood_sea/features/auth/donor_registration_screen.dart';
import 'package:blood_sea/features/home/home.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';

class ClientSignUpScreen extends StatelessWidget {
  final _formKey = GlobalKey<FormState>();

  // Controllers to retrieve user input
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _passwordController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  final TextEditingController _addressController = TextEditingController();

  ClientSignUpScreen({super.key});

  // Function to handle sign-up
  Future<void> _handleSignUp(BuildContext context) async{
    if(_formKey.currentState!.validate()){
      try{
        // Create Firebase Authentication user
        UserCredential userCredential = await FirebaseAuth.instance
            .createUserWithEmailAndPassword(
            email: _emailController.text.trim(),
            password: _passwordController.text.trim(),
        );

        // Store additional user details in Firestore
        await FirebaseFirestore.instance
        .collection('clients')
        .doc(userCredential.user! .uid)
        .set({
          'name' : _nameController.text.trim(),
          'email' : _emailController.text.trim(),
          // 'password' : _passwordController.text,
          'phone' : _phoneController.text.trim(),
          'address' : _addressController.text.trim(),
          'created_at' : Timestamp.now(),
        });
        // Success feedback
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Succesfully Signed Up")),
        );

        _formKey.currentState!.reset();
        _nameController.clear();
        _emailController.clear();
        _passwordController.clear();
        _phoneController.clear();
        _addressController.clear();

        // Optionally navigate to another page
        Navigator.push(
          context,
          MaterialPageRoute(builder: (context) => homeFragment()),
        );

      } catch(e){
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text("Something went wrong, please try again: $e")),
        );
      }
    }

  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.red,
        foregroundColor: Colors.white,
        title: const Text("Client Sign Up",
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Form(
          key: _formKey,
          child: ListView(
            children: [
              // Full Name Input
              TextFormField(
                controller: _nameController,
                decoration: const InputDecoration(
                  labelText: "Full Name",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.person,  color: Colors.red),
                ),
                validator: (value) {
                  if (value == null || value.isEmpty) {
                    return 'Please enter your full name';
                  }
                  return null;
                },
              ),
              const SizedBox(height: 16),

              // Email Address Input
              TextFormField(
                controller: _emailController,
                decoration: const InputDecoration(
                  labelText: "Email Address",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.email, color: Colors.red),
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

              // Password Input
              TextFormField(
                controller: _passwordController,
                decoration: InputDecoration(
                  labelText: "Password",
                  border: const OutlineInputBorder(),
                  prefixIcon: const Icon(Icons.lock, color: Colors.red),
                  suffixIcon: IconButton(
                    icon: const Icon(
                      Icons.visibility,
                      color: Colors.red,
                    ),
                    onPressed: () {
                      // Add logic to toggle visibility if needed
                    },
                  ),
                ),
                obscureText: true, // Hides the password as user types
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

              // Mobile Number Input
              TextFormField(
                controller: _phoneController,
                decoration: const InputDecoration(
                  labelText: "Mobile Number",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.phone, color: Colors.red),
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

              // Address Input
              TextFormField(
                controller: _addressController,
                decoration: const InputDecoration(
                  labelText: "Address",
                  border: OutlineInputBorder(),
                  prefixIcon: Icon(Icons.location_on, color: Colors.red,),
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

              // Submit Button
              ElevatedButton(
                onPressed:  () => _handleSignUp(context),
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                  minimumSize: const Size(double.infinity, 50),
                ),
                //{
                  // if (_formKey.currentState!.validate()) {
                  //   ScaffoldMessenger.of(context).showSnackBar(
                  //     SnackBar(content: Text('Form Submitted Successfully!')),
                  //   );
                  // }
                //},
                child: Text("Submit",
                style: TextStyle(
                  fontSize: 16,
                ),),
              ),
              const SizedBox(height: 35,),
          GestureDetector(
            onTap: (){
              Navigator.push(context, MaterialPageRoute(builder: (context)=>const donorRegistration()));
            },
            child: const Text("Want to be a donor? Please Register",
            style: TextStyle(
              fontSize: 20,
              fontStyle: FontStyle.italic,
              fontWeight: FontWeight.bold,
              color: Colors.blue
            ),),
          )

            ],
          ),
        ),

      ),

    );
  }
}
