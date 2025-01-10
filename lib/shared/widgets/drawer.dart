import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

Drawer appDrawer({
  required BuildContext context,
  required Map<String, dynamic>? userProfile,
  required VoidCallback logoutCallback,
}) {
  return Drawer(
    child: ListView(
      padding: EdgeInsets.zero,
      children: [
        UserAccountsDrawerHeader(
          decoration: const BoxDecoration(color: Colors.redAccent),
          accountName: Text(
            userProfile != null ? userProfile['name'] ?? 'Loading...' : 'Loading...',
          ),
          accountEmail: Text(
            userProfile != null ? userProfile['email'] ?? 'Loading...' : 'Loading...',
          ),
          currentAccountPicture: CircleAvatar(
            backgroundImage: userProfile != null && userProfile['photoUrl'] != null
                ? NetworkImage(userProfile['photoUrl'])
                : const AssetImage('assets/ssbf.png') as ImageProvider,
          ),
        ),
        ListTile(
          leading: const Icon(Icons.home),
          title: const Text("Home"),
          onTap: () {
            context.go('/home');
          },
        ),
        ListTile(
          leading: const Icon(Icons.person),
          title: const Text("Profile"),
          onTap: () {
            context.go('/profile');
          },
        ),
        ListTile(
          leading: const Icon(Icons.search),
          title: const Text("Search"),
          onTap: () {
            context.go('/search');
          },
        ),
        ListTile(
          leading: const Icon(Icons.contact_emergency),
          title: const Text("Contact"),
          onTap: () {
            context.go('/contact');
          },
        ),
        const Divider(height: 2),
        ListTile(
          leading: const Icon(Icons.arrow_back),
          title: const Text("Privacy Policy"),
          onTap: () {
            context.go('/privacy-policy');
          },
        ),
        ListTile(
          leading: const Icon(Icons.logout),
          title: const Text("Logout"),
          onTap: logoutCallback,
        ),
        ListTile(
          leading: const Icon(Icons.arrow_back),
          title: const Text("Back"),
          onTap: () {
            Navigator.pop(context); // Close the drawer
          },
        ),
      ],
    ),
  );
}
