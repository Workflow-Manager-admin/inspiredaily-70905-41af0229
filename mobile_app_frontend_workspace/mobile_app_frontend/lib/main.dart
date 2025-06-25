import 'package:flutter/material.dart';

// PUBLIC_INTERFACE
void main() {
  runApp(const MyApp());
}

// PUBLIC_INTERFACE
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'InspireDaily',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: _themeMode,
      home: HomeScreen(
        onToggleTheme: _toggleTheme,
        themeMode: _themeMode,
      ),
    );
  }
}

// Theme and Gradient Definitions
class AppThemes {
  // Gradients for Light Theme
  static const LinearGradient lightBackgroundGradient = LinearGradient(
    colors: [Color(0xFFB2FEFA), Color(0xFF0ED2F7)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient lightAppBarGradient = LinearGradient(
    colors: [Color(0xFF352384), Color(0xFF6B8DD6)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient lightCardGradient = LinearGradient(
    colors: [Color(0xFFFBC2EB), Color(0xFFA6C1EE)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static const LinearGradient lightFavoritesGradient = LinearGradient(
    colors: [Color(0xFFFFDEE9), Color(0xFFB5FFFC)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  // Gradients for Dark Theme
  static const LinearGradient darkBackgroundGradient = LinearGradient(
    colors: [Color(0xFF0F2027), Color(0xFF2C5364)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient darkAppBarGradient = LinearGradient(
    colors: [Color(0xFF232526), Color(0xFF414345)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );
  static const LinearGradient darkCardGradient = LinearGradient(
    colors: [Color(0xFF434343), Color(0xFF000000)],
    begin: Alignment.topCenter,
    end: Alignment.bottomCenter,
  );
  static const LinearGradient darkFavoritesGradient = LinearGradient(
    colors: [Color(0xFF232526), Color(0xFF414345)],
    begin: Alignment.topLeft,
    end: Alignment.bottomRight,
  );

  static final ThemeData lightTheme = ThemeData(
    brightness: Brightness.light,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF00b3ff),
      brightness: Brightness.light,
      primary: Colors.white,
      secondary: const Color(0xFF00b3ff),
      tertiary: const Color(0xFFfa0057),
    ),
    scaffoldBackgroundColor: Colors.transparent,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.black,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: Colors.transparent,
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
    ),
    useMaterial3: true,
  );
  static final ThemeData darkTheme = ThemeData(
    brightness: Brightness.dark,
    colorScheme: ColorScheme.fromSeed(
      seedColor: const Color(0xFF00b3ff),
      brightness: Brightness.dark,
      primary: const Color(0xFF121212),
      secondary: const Color(0xFF00b3ff),
      tertiary: const Color(0xFFfa0057),
    ),
    scaffoldBackgroundColor: Colors.transparent,
    appBarTheme: const AppBarTheme(
      backgroundColor: Colors.transparent,
      foregroundColor: Colors.white,
      elevation: 0,
    ),
    cardTheme: CardTheme(
      color: Colors.transparent,
      elevation: 4,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.only(
          topLeft: Radius.circular(22),
          topRight: Radius.circular(22),
          bottomLeft: Radius.circular(22),
          bottomRight: Radius.circular(22),
        ),
      ),
    ),
    useMaterial3: true,
  );
}

// HomeScreen with toggle for light/dark mode and navigation to Favorites
class HomeScreen extends StatelessWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;

  const HomeScreen({
    super.key,
    required this.onToggleTheme,
    required this.themeMode,
  });

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    final backgroundGradient = isDark
        ? AppThemes.darkBackgroundGradient
        : AppThemes.lightBackgroundGradient;
    final appBarGradient =
        isDark ? AppThemes.darkAppBarGradient : AppThemes.lightAppBarGradient;

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(
              gradient: appBarGradient,
            ),
          ),
          title: const Text('InspireDaily'),
          actions: [
            IconButton(
              icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
              tooltip: "Toggle theme",
              onPressed: onToggleTheme,
            ),
            IconButton(
              icon: const Icon(Icons.favorite),
              tooltip: 'Favorites',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        FavoritesScreen(),
                  ),
                );
              },
            ),
          ],
        ),
      ),
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(gradient: backgroundGradient),
        child: Center(
          child: QuoteCard(isDark: isDark),
        ),
      ),
    );
  }
}

// Widget for displaying quote in a gradient card
class QuoteCard extends StatelessWidget {
  final bool isDark;
  const QuoteCard({super.key, required this.isDark});

  @override
  Widget build(BuildContext context) {
    final gradient =
        isDark ? AppThemes.darkCardGradient : AppThemes.lightCardGradient;

    // Mock quote and author (replace with live data in production)
    const quote =
        "Success is not final, failure is not fatal: It is the courage to continue that counts.";
    const author = "Winston Churchill";

    return Container(
      width: MediaQuery.of(context).size.width * 0.88,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Color(0x80000000) // semi-transparent black (~0.5 opacity)
                : Color(0x4D9E9E9E), // semi-transparent grey (~0.3 opacity)
            blurRadius: 18,
            offset: const Offset(0, 8),
          ),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(
            Icons.format_quote,
            size: 36,
            color: Theme.of(context).colorScheme.tertiary,
          ),
          const SizedBox(height: 10),
          Text(
            quote,
            style: Theme.of(context)
                .textTheme
                .titleLarge!
                .copyWith(fontWeight: FontWeight.w600, height: 1.4),
            textAlign: TextAlign.center,
          ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              Text(
                "- $author",
                style: Theme.of(context)
                    .textTheme
                    .bodyMedium!
                    .copyWith(color: Theme.of(context).colorScheme.secondary),
              ),
            ],
          ),
          const SizedBox(height: 14),
          Row(
            mainAxisAlignment: MainAxisAlignment.end,
            children: [
              IconButton(
                icon: Icon(Icons.favorite_border,
                    color: Theme.of(context).colorScheme.tertiary),
                tooltip: "Favorite",
                onPressed: () {
                  ScaffoldMessenger.of(context).showSnackBar(
                    const SnackBar(content: Text("Quote added to favorites!")),
                  );
                },
              ),
            ],
          )
        ],
      ),
    );
  }
}

// Favorites screen with themed gradient background
class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = isDark
        ? AppThemes.darkFavoritesGradient
        : AppThemes.lightFavoritesGradient;

    // Mock favorites (replace with real state management)
    final favorites = [
      {
        'quote':
            "The only way to do great work is to love what you do.",
        'author': "Steve Jobs"
      },
      {
        'quote': "What you get by achieving your goals is not as important as what you become by achieving your goals.",
        'author': "Zig Ziglar"
      }
    ];

    return Scaffold(
      extendBodyBehindAppBar: true,
      appBar: PreferredSize(
        preferredSize: const Size.fromHeight(56),
        child: AppBar(
          flexibleSpace: Container(
            decoration: BoxDecoration(gradient: gradient),
          ),
          title: const Text('Favorites'),
        ),
      ),
      body: Container(
        width: double.infinity,
        decoration: BoxDecoration(gradient: gradient),
        child: ListView.builder(
          padding: const EdgeInsets.symmetric(vertical: 24),
          itemCount: favorites.length,
          itemBuilder: (context, idx) {
            final q = favorites[idx];
            final cardGradient =
                isDark ? AppThemes.darkCardGradient : AppThemes.lightCardGradient;
            return Container(
              margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 10),
              decoration: BoxDecoration(
                gradient: cardGradient,
                borderRadius: BorderRadius.circular(18),
              ),
              child: ListTile(
                contentPadding:
                    const EdgeInsets.symmetric(vertical: 18, horizontal: 22),
                leading: Icon(Icons.star,
                    color: Theme.of(context).colorScheme.tertiary, size: 30),
                title: Text(
                  q['quote']!,
                  style: Theme.of(context)
                      .textTheme
                      .bodyLarge!
                      .copyWith(fontWeight: FontWeight.w600),
                ),
                subtitle: Text(
                  "- ${q['author']!}",
                  style: Theme.of(context)
                      .textTheme
                      .bodyMedium!
                      .copyWith(color: Theme.of(context).colorScheme.secondary),
                ),
              ),
            );
          },
        ),
      ),
    );
  }
}
