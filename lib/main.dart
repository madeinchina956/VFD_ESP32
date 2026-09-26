// Flutter Material Design package
import 'package:flutter/material.dart';

// Main VFD application screen
import 'screens/vfd_home_page.dart';

// Starting point of the Flutter app
void main() {

  // Makes sure Flutter is fully initialized
  WidgetsFlutterBinding.ensureInitialized();

  // Starts the application
  runApp(
    const VfdApp(),
  );
}

// Main application widget
class VfdApp extends StatelessWidget {
  const VfdApp({
    super.key,
  });

  @override
  Widget build(BuildContext context) {

    // Sets up the main app settings and theme
    return MaterialApp(

      // Application title
      title: "VFD Controller",

      // Removes the debug banner
      debugShowCheckedModeBanner: false,

      // Main app theme
      theme: ThemeData(
        useMaterial3: true,
        brightness: Brightness.dark,
        colorSchemeSeed: Colors.blue,
      ),

      // First screen shown when the app starts
      home: const VfdHomePage(),
    );
  }
}