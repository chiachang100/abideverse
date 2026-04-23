import 'package:flutter/material.dart';

class AbideAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;

  const AbideAppBar({super.key, required this.title});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title),
      centerTitle: true, // Optional: keeps it balanced with the action icon
      // actions: [
      //   Padding(
      //     padding: const EdgeInsets.symmetric(horizontal: 16.0),
      //     child: Image.asset(
      //       'assets/icons/abideverse-leading-icon.webp',
      //       width: 30,
      //     ),
      //   ),
      // ],
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}
