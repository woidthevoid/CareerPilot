import 'package:flutter/material.dart';

class LoginButton extends StatelessWidget {
  final VoidCallback onPressed;
  final String text;

  const LoginButton({
    super.key,
    required this.onPressed,
    this.text = 'Login',
  });

  @override
  Widget build(BuildContext context) {
    return SizedBox(
      width: double.infinity, // takes full width of parent
      height: 50,             // fixed height
      child: FilledButton(
        onPressed: onPressed,
        style: FilledButton.styleFrom(
          enableFeedback: true,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(16),
          ),
        ),
        child: Text(
          text,
          style: const TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
    );
  }
}