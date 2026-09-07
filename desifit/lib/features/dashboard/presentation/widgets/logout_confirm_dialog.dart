import 'package:flutter/material.dart';

import '../../../../core/state/app_state.dart';
import '../../../../core/theme/theme.dart';

/// Logout confirmation for the home profile trigger.
/// Static entry point matching the BadgesDialog.show convention.
class LogoutConfirmDialog {
  const LogoutConfirmDialog._();

  static void show(BuildContext context, AppState state) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          backgroundColor: AppColors.background,
          title: const Text('Log Out', style: TextStyle(fontWeight: FontWeight.bold)),
          content: Text('Hey ${state.currentUser!.displayName}, do you want to log out of your session?'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text('CANCEL', style: TextStyle(color: Colors.grey, fontWeight: FontWeight.bold)),
            ),
            TextButton(
              onPressed: () {
                state.logout();
                Navigator.pop(context);
              },
              child: const Text('LOG OUT', style: TextStyle(color: AppColors.primary, fontWeight: FontWeight.bold)),
            ),
          ],
        );
      },
    );
  }
}
