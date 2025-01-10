import 'package:flutter/material.dart';

class PrivacyPolicyScreen extends StatefulWidget {
  const PrivacyPolicyScreen({super.key});

  @override
  State<PrivacyPolicyScreen> createState() => _PrivacyPolicyScreen();
}

class _PrivacyPolicyScreen extends State<PrivacyPolicyScreen> {
  @override
  Widget build(BuildContext context) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Card(
            elevation: 5,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(10),
            ),
            child: const Padding(
              padding: EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "Privacy Policy",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "1. Data Collection: We collect personal information such as name, contact details, and blood group to facilitate donation and connection.\n"
                    "2. Data Usage: Your data is used solely for connecting donors and recipients. We do not sell or share your data with third parties.\n"
                    "3. Security: We implement secure measures to protect your information, but no system is 100% secure.\n"
                    "4. User Consent: By signing up, you consent to our collection and use of your information for app purposes.",
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                  SizedBox(height: 20),
                  Text(
                    "Terms & Conditions",
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.red,
                    ),
                  ),
                  SizedBox(height: 10),
                  Text(
                    "1. Eligibility: Donors must be healthy and meet the standard donation criteria.\n"
                    "2. Accuracy: Users must provide accurate and truthful information.\n"
                    "3. No Guarantees: We facilitate connections but do not guarantee the availability or compatibility of donors.\n"
                    "4. Responsibility: Users are responsible for their interactions and agreements outside the app.\n"
                    "5. Compliance: All users must comply with local laws regarding blood donation and medical practices.",
                    style: TextStyle(fontSize: 16, height: 1.5),
                  ),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}
