import 'package:flutter/material.dart';
import '../theme/theme_app.dart';

class CustomAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final bool showBackButton;
  final VoidCallback? onMenuPressed;

  const CustomAppBar({
    super.key,
    required this.title,
    this.actions,
    this.showBackButton = false,
    this.onMenuPressed,
  });

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);

  @override
  Widget build(BuildContext context) {
    return AppBar(
      flexibleSpace: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topLeft,
            end: Alignment.bottomRight,
            colors: [AppTheme.primaryDark, AppTheme.primary],
          ),
        ),
      ),
      title: Text(title),
      centerTitle: true,
      foregroundColor: Colors.white,
      backgroundColor: Colors.transparent,
      elevation: 0,
      automaticallyImplyLeading: showBackButton,
      leading: showBackButton
          ? null
          : onMenuPressed != null
              ? IconButton(
                  icon: const Icon(Icons.menu_rounded),
                  onPressed: onMenuPressed,
                ) // IconButton
              : null,
      actions: actions,
    ); // AppBar
  }
}
