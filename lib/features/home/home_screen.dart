import 'package:blood_sea/features/auth/auth_service.dart';
import 'package:blood_sea/features/auth/login_screen.dart';
import 'package:blood_sea/features/privacy_policy/privacy_policy_screen.dart';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:blood_sea/features/donors/donor_search_screen.dart';
import 'package:blood_sea/features/contact/contact_screen.dart';
import 'package:blood_sea/features/donors/donor_list_screen.dart';
import '../auth/donor_registration_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  Future<void> _logout() async {
    try {
      await AuthService.signOut();

      if (!mounted) return;

      // Show success message
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Successfully logged out'),
          backgroundColor: Colors.green,
        ),
      );

      // Navigate to login screen and remove all previous routes
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute(builder: (context) => LoginScreen()),
        (Route<dynamic> route) => false,
      );
    } catch (e) {
      // Show error message if logout fails
      if (!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Logout failed: ${e.toString()}'),
          backgroundColor: Colors.red,
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
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
            // Text(
            //   "Welcome to Blood Donation App!",
            //   style: TextStyle(
            //     fontSize: 24,
            //     fontWeight: FontWeight.bold,
            //     color: Colors.redAccent,
            //   ),
            // ),
            const SizedBox(height: 10),
            // Text(
            //   "Save lives by donating blood.",
            //   style: TextStyle(
            //     fontSize: 16,
            //     color: Colors.black54,
            //   ),
            // ),
            const SizedBox(
              height: 20,
            ),
            const Text(
              "Need Blood?",
              style: TextStyle(
                fontSize: 24,
                color: Colors.red,
                fontWeight: FontWeight.bold,
              ),
            ),
            GestureDetector(
              onTap: () {
                // Navigate to privacyPolicyFragment.dart
                Navigator.push(
                  context,
                  MaterialPageRoute(
                      builder: (context) => const PrivacyPolicyScreen()),
                );
              },
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
                onPressed: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => const DonorSearchScreen(),
                    ),
                  );
                },
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
                )),
            const SizedBox(
              height: 10,
            ),
            const Text(
              "Total Donor: .....Dynamic Code",
              style: TextStyle(
                fontSize: 18,
                fontWeight: FontWeight.bold,
                //fontFamily: 'fonts/Lato-Bold.ttf',
                color: Colors.green,
              ),
            ),
            const SizedBox(
              height: 10,
            ),
            OutlinedButton(
              onPressed: () {
                //Navigator.push(context, MaterialPageRoute(builder: (context) => donorList()),);
                Navigator.push(
                  context,
                  MaterialPageRoute(builder: (context) => const DonorListScreen()),
                );
              },
              style: OutlinedButton.styleFrom(
                  side: const BorderSide(
                    color: Colors.blue,
                    width: 2,
                  ),
                  foregroundColor: Colors.blue,
                  padding:
                      const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                  shape: const RoundedRectangleBorder(
                    borderRadius: BorderRadius.all(
                      Radius.circular(10),
                    ),
                  ),
                  minimumSize: const Size(50, 36)),
              child: const Row(
                mainAxisSize: MainAxisSize.min,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.person,
                  ),
                  SizedBox(
                    width: 5,
                  ),
                  Text("See Donor List"),
                ],
              ),
            ),
            const SizedBox(
              width: 5,
            ),
            SingleChildScrollView(
              scrollDirection: Axis.horizontal,
              child: Row(
                mainAxisAlignment:
                    MainAxisAlignment.center, // Center row contents if needed
                children: [
                  const Text(
                    "Want to be a Donor?",
                    style: TextStyle(
                      color: Colors.red,
                    ),
                  ),
                  const SizedBox(width: 8), // Space between text and image
                  Stack(
                    alignment: Alignment.center,
                    children: [
                      GestureDetector(
                        onTap: () {
                          Navigator.push(
                            context,
                            MaterialPageRoute(
                                builder: (context) =>
                                    const DonorRegistrationScreen()),
                          );
                        },
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
                ],
              ),
            ),

            const SizedBox(
              height: 15,
            ),
            //start donor registration text

            //start donor registration text
            Card(
              elevation: 20,
              color: Colors.blue,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Padding(
                padding: EdgeInsets.all(10),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Icon(
                      Icons.people,
                      color: Colors.white,
                      size: 40,
                    ),
                    SizedBox(
                      height: 5,
                    ),
                    Text(
                      "Total Clients: 2145",
                      style: TextStyle(
                          fontWeight: FontWeight.bold, color: Colors.white),
                    ),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
