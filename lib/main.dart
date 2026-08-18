import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/gender_selection_screen.dart';
import 'services/app_state.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const JordanianSERApp());
}

class JordanianSERApp extends StatelessWidget {
  const JordanianSERApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: MaterialApp(
        title: 'تحدي الصوت الأردني',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        locale: const Locale('ar'),
        builder: (context, child) {
          // Force RTL layout for the Arabic-first UI regardless of device locale.
          return Directionality(
            textDirection: TextDirection.rtl,
            child: child!,
          );
        },
        home: const GenderSelectionScreen(),
      ),
    );
  }
}
