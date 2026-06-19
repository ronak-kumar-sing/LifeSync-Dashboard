import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'dart:io';
import '../../core/theme/app_colors.dart';
import '../../core/models/app_state.dart';
import '../../platforms/macos/macos_app.dart';
import '../../platforms/android/android_app.dart';
import 'floating_ai_button.dart';

class AdaptiveLayout extends StatefulWidget {
  const AdaptiveLayout({super.key});

  @override
  State<AdaptiveLayout> createState() => _AdaptiveLayoutState();
}

class _AdaptiveLayoutState extends State<AdaptiveLayout> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AppState>().setPlatform(Platform.isMacOS);
    });
  }

  @override
  Widget build(BuildContext context) {
    return LayoutBuilder(
      builder: (context, constraints) {
        final isDesktop = constraints.maxWidth > 800 || Platform.isMacOS;
        
        return Scaffold(
          backgroundColor: AppColors.background,
          body: isDesktop
              ? const MacOSAppLayout()
              : const AndroidAppLayout(),
          floatingActionButton: !isDesktop ? const FloatingAIButton() : null,
        );
      },
    );
  }
}
