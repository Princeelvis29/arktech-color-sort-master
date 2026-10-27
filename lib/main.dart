import 'package:flutter/material.dart';
import 'ui/home_screen.dart';
import 'ui/brand_theme.dart';

void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(const ArktechColorSortApp());
}

class ArktechColorSortApp extends StatelessWidget {
  const ArktechColorSortApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'ARKTECH COLOR SORT MASTER',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        scaffoldBackgroundColor: Brand.navy,
        colorScheme: ColorScheme.fromSeed(seedColor: Brand.purple, brightness: Brightness.dark),
      ),
      home: const HomeScreen(),
    );
  }
}
