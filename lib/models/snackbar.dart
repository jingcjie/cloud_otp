import 'package:flutter/material.dart';

class BeautifulSnackBar extends SnackBar {
  BeautifulSnackBar({
    Key? key,
    required String message,
    bool isError = false,
    VoidCallback? onActionPressed,
  }) : super(
    key: key,
    content: BeautifulSnackBarContent(
      message: message,
      isError: isError,
      onActionPressed: onActionPressed,
    ),
    backgroundColor: Colors.transparent,
    elevation: 0,
    behavior: SnackBarBehavior.floating,
    duration: Duration(seconds: 2),
  );
}

class BeautifulSnackBarContent extends StatelessWidget {
  final String message;
  final bool isError;
  final VoidCallback? onActionPressed;

  const BeautifulSnackBarContent({
    Key? key,
    required this.message,
    this.isError = false,
    this.onActionPressed,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      height: 50,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isError
              ? [Colors.red.withOpacity(1), Colors.red.withOpacity(0)]
              : [Colors.green.withOpacity(1), Colors.green.withOpacity(0)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 20,
            offset: Offset(0, 10),
          ),
        ],
      ),
      child: Row(
        children: [
          Icon(
            isError ? Icons.error_outline : Icons.check_circle_outline,
            color: Colors.white,
            size: 28,
          ),
          SizedBox(width: 12),
          Expanded(
            child: Text(
              message,
              style: TextStyle(
                color: Colors.white,
                fontSize: 16,
                fontWeight: FontWeight.w600,
              ),
            ),
          ),
          SizedBox(width: 8),
          // TextButton(
          //   onPressed: onActionPressed ?? () {},
          //   child: Text(
          //     'Dismiss',
          //     style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          //   ),
          // ),
        ],
      ),
    );
  }
}

// Extension method for easy use
extension SnackBarExtension on BuildContext {
  void showBeautifulSnackBar({
    required String message,
    bool isError = false,
    VoidCallback? onActionPressed,
  }) {
    ScaffoldMessenger.of(this).showSnackBar(
      BeautifulSnackBar(
        message: message,
        isError: isError,
        onActionPressed: onActionPressed,
      ),
    );
  }
}