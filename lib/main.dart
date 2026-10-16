import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'screens/welcome_screen.dart';
import 'state/app_state.dart';

void main() {
  runApp(const SupermercadoApp());
}

class SupermercadoApp extends StatelessWidget {
  const SupermercadoApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (_) => AppState(),
      child: Consumer<AppState>(
        builder: (context, app, _) {
          return MaterialApp(
            title: app.tenant.shopName,
            debugShowCheckedModeBanner: false,
            theme: ThemeData(
              useMaterial3: true,
              colorScheme: ColorScheme.fromSeed(
                seedColor: app.tenant.primaryColor,
                primary: app.tenant.primaryColor,
              ),
              scaffoldBackgroundColor: const Color(0xFFF6F7F9),
              fontFamily: 'Roboto',
            ),
            home: const WelcomeScreen(),
          );
        },
      ),
    );
  }
}
