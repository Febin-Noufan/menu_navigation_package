import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:menu_navigation/menu_navigation.dart';

void main() {
  runApp(const MyApp());
}

class AppColors {
  static const Color appThemeColorLight = Color.fromARGB(255, 22, 54, 123);
  static const Color surface = Color(0xFFF5F7FA);
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Menu Navigation Demo',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: AppColors.appThemeColorLight,
          primary: AppColors.appThemeColorLight,
          surface: AppColors.surface,
        ),
        scaffoldBackgroundColor: Colors.white,
        textTheme: GoogleFonts.poppinsTextTheme(),
      ),
      home: const DemoHomePage(),
    );
  }
}

class DemoHomePage extends StatefulWidget {
  const DemoHomePage({super.key});

  @override
  State<DemoHomePage> createState() => _DemoHomePageState();
}

class _DemoHomePageState extends State<DemoHomePage> {
  @override
  Widget build(BuildContext context) {
    final List<MenuSection> menuData = [
      MenuSection(
        title: 'Actions',
        items: [
          MenuItem(
            shortcut: 'S',
            label: 'Save',
            onTap: () {
              showCustomSnackBar(
                context: context,
                message: 'Save action triggered',
                type: SnackBarType.success,
              );
            },
          ),
          MenuItem(
            shortcut: 'P',
            label: 'Print',
            onTap: () {
              showCustomSnackBar(
                context: context,
                message: 'Print action triggered',
                type: SnackBarType.normal,
              );
            },
          ),
        ],
      ),
      MenuSection(
        title: 'Navigation',
        items: [
          MenuItem(
            shortcut: 'G',
            label: 'Settings',
            subMenu: [
              MenuSection(
                title: 'General Settings',
                items: [
                  MenuItem(shortcut: 'T', label: 'Theme', onTap: () {}),
                  MenuItem(shortcut: 'L', label: 'Language', onTap: () {}),
                ],
              ),
            ],
          ),
          MenuItem(
            shortcut: 'A',
            label: 'About',
            navigateTo: () => const AboutScreen(),
          ),
        ],
      ),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      body: Row(
        children: [
          Expanded(
            flex: 2,
            child: Container(
              color: Colors.white,
              child: const Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      "BookKeeper Mock",
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.bold,
                        color: AppColors.appThemeColorLight,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "V 1.0.0",
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
          const VerticalDivider(width: 1),
          SizedBox(
            width: 450,
            child: DynamicMenu(
              title: 'Main Menu',
              menuData: menuData,
              onMenuItemSelected: (item) {
                debugPrint('Selected: ${item.label}');
              },
            ),
          ),
        ],
      ),
    );
  }
}

class AboutScreen extends StatelessWidget {
  const AboutScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('About')),
      body: const Center(
        child: Text('This is the About Screen. Double-tap Escape to go back.'),
      ),
    );
  }
}
