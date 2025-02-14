import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:blood_sea/features/auth/bloc/auth_bloc.dart';
import 'package:go_router/go_router.dart';

import '../auth/models/user_model.dart';

class HomeScreen extends StatefulWidget {
  final UserModel? userModel;
  const HomeScreen({super.key,this.userModel});  

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthBloc, AuthState>(
      builder: (context, state) {
        if (state is! Authenticated) {
          return const Center(child: CircularProgressIndicator());
        }

        final user = widget.userModel ?? state.userModel;

        return SingleChildScrollView(
          child: Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                const Icon(
                  Icons.favorite,
                  size: 80,
                  color: Colors.redAccent,
                ),
                const SizedBox(height: 20),
                
                // Welcome message with user name
                if (user.name != null)
                  Text(
                    "Welcome, ${user.name}!",
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.redAccent,
                    ),
                  ),
                
                const SizedBox(height: 10),
                
                const SizedBox(height: 20),
                const Text(
                  "Need Blood?",
                  style: TextStyle(
                    fontSize: 24,
                    color: Colors.red,
                    fontWeight: FontWeight.bold,
                  ),
                ),
                GestureDetector(
                  onTap: () => context.pushNamed('privacyPolicy'),
                  child: const Text(
                    "read terms and conditions",
                    style: TextStyle(
                      fontSize: 11,
                      fontStyle: FontStyle.italic,
                      color: Colors.blue,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ElevatedButton(
                  onPressed: () => context.pushNamed('donorSearch'),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.red,
                    foregroundColor: Colors.white,
                    padding: const EdgeInsets.symmetric(vertical: 12),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.zero,
                    ),
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  child: const Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "Send Request",
                        style: TextStyle(
                          fontSize: 14,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      SizedBox(
                        height: 5,
                        width: 8,
                      ),
                      Icon(
                        Icons.arrow_right_alt,
                        size: 30,
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 10),
                
                // Show total donors count
                BlocBuilder<AuthBloc, AuthState>(
                  builder: (context, state) {
                    // You might want to add a separate bloc for donor count
                    return const Text(
                      "Total Donors Available: 150",  // Replace with actual count
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: Colors.green,
                      ),
                    );
                  },
                ),
                
                const SizedBox(height: 10),
                OutlinedButton(
                  onPressed: () => context.pushNamed('donorList'),
                  style: OutlinedButton.styleFrom(
                    side: const BorderSide(
                      color: Colors.blue,
                      width: 2,
                    ),
                    foregroundColor: Colors.blue,
                    padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    shape: const RoundedRectangleBorder(
                      borderRadius: BorderRadius.all(
                        Radius.circular(10),
                      ),
                    ),
                    minimumSize: const Size(50, 36),
                  ),
                  child: const Row(
                    mainAxisSize: MainAxisSize.min,
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.person),
                      SizedBox(width: 5),
                      Text("See Donor List"),
                    ],
                  ),
                ),
                const SizedBox(width: 5),
                
                // Conditional rendering based on user type
                if (user.userType != 'donor')
                  SingleChildScrollView(
                    scrollDirection: Axis.horizontal,
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Want to be a Donor?",
                          style: TextStyle(
                            color: Colors.red,
                          ),
                        ),
                        const SizedBox(width: 8),
                        GestureDetector(
                          onTap: () => context.pushNamed('donorRegistration'),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20),
                            child: Container(
                              height: 50,
                              width: 80,
                              color: Colors.red,
                              child: const Center(
                                child: Text(
                                  "Sign Up",
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontWeight: FontWeight.bold,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                const SizedBox(height: 15),
                
                // Statistics Card
                Card(
                  elevation: 20,
                  color: Colors.blue,
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(8),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(10),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(
                          Icons.people,
                          color: Colors.white,
                          size: 40,
                        ),
                        const SizedBox(height: 5),
                        // Show user type specific information
                        Text(
                          user.userType == 'donor'
                              ? "Last Donation: ${user.lastDonationDate?.toString().split(' ')[0] ?? 'Never'}"
                              : "Total Clients: 2145",
                          style: const TextStyle(
                            fontWeight: FontWeight.bold,
                            color: Colors.white,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
                
                // Add emergency contact button if user is a client
                if (user.userType == 'client')
                  Padding(
                    padding: const EdgeInsets.only(top: 15),
                    child: ElevatedButton.icon(
                      onPressed: () => context.pushNamed('emergency'),
                      icon: const Icon(Icons.emergency, color: Colors.white),
                      label: const Text(
                        "Emergency Contact",
                        style: TextStyle(color: Colors.white),
                      ),
                      style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.red,
                        padding: const EdgeInsets.symmetric(
                          horizontal: 20,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
              ],
            ),
          ),
        );
      },
    );
  }
}
