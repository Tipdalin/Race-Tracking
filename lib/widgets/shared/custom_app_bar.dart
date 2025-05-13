import 'package:flutter/material.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showProfile;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showProfile = false,
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: true,
      actions: [
        if (actions != null) ...actions!,
        if (showProfile)
          PopupMenuButton<String>(
            icon: const CircleAvatar(child: Icon(Icons.person)),
            onSelected: (value) {
              if (value == 'about') {
                _showAboutDialog(context);
              }
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'profile',
                    enabled: false,
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          'Admin User',
                          style: TextStyle(fontWeight: FontWeight.bold),
                        ),
                        Text(
                          'Race Manager',
                          style: TextStyle(fontSize: 12, color: Colors.grey),
                        ),
                      ],
                    ),
                  ),
                  const PopupMenuDivider(),
                  const PopupMenuItem(
                    value: 'about',
                    child: Row(
                      children: [
                        Icon(Icons.info),
                        SizedBox(width: 8),
                        Text('About'),
                      ],
                    ),
                  ),
                ],
          ),
      ],
    );
  }

  void _showAboutDialog(BuildContext context) {
    showDialog(
      context: context,
      builder:
          (context) => AlertDialog(
            title: const Text('Race Tracking App'),
            content: const Text(
              'A simple race tracking application for managing triathlon and other sporting events.\n\nVersion 1.0.0',
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('OK'),
              ),
            ],
          ),
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
