import 'package:flutter/material.dart';
import '../../core/constants/colors.dart';

Future<void> showCustomDialog({
  required BuildContext context,
  required String title,
  required String message,
  bool showSettings = false,
  VoidCallback? onSettings,
}) {
  return showDialog(
    context: context,
    builder: (_) => AlertDialog(
      backgroundColor: Colors.grey[900],
      title: Text(title, style: const TextStyle(color: AppColors.primary)),
      content: Text(message, style: const TextStyle(color: AppColors.secondary)),
      actions: [
        TextButton(
          onPressed: () => Navigator.pop(context),
          child: const Text('إلغاء', style: TextStyle(color: AppColors.secondary)),
        ),
        if (showSettings)
          TextButton(
            onPressed: onSettings,
            child: const Text('الإعدادات', style: TextStyle(color: AppColors.accent)),
          ),
      ],
    ),
  );
}