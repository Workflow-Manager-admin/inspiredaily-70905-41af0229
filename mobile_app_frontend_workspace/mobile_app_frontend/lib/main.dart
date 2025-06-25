import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';

// PUBLIC_INTERFACE
void main() {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(MyApp());
}

// ===== Models and Persistence =====

// Quote model
class Quote {
  final String text;
  final String author;

  Quote({required this.text, required this.author});

  // Serialization for storage
  Map<String, dynamic> toJson() => {'text': text, 'author': author};

  static Quote fromJson(Map<String, dynamic> json) => Quote(
        text: json['text'],
        author: json['author'],
      );

  // Equality for searching and removal
  @override
  bool operator ==(Object other) =>
      other is Quote && text == other.text && author == other.author;
  @override
  int get hashCode => text.hashCode ^ author.hashCode;
}

// Persistence helper using shared_preferences
class FavoriteRepository {
  static const _key = 'favorites';

  Future<List<Quote>> loadFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = prefs.getStringList(_key) ?? [];
    return encoded
        .map((e) => Quote.fromJson(json.decode(e)))
        .toList();
  }

  Future<void> saveFavorites(List<Quote> favorites) async {
    final prefs = await SharedPreferences.getInstance();
    final encoded = favorites.map((q) => json.encode(q.toJson())).toList();
    await prefs.setStringList(_key, encoded);
  }
}

// App state for current quote and favorites
class AppState extends ChangeNotifier {
  final FavoriteRepository repo = FavoriteRepository();
  List<Quote> favorites = [];
  // In a real app, current quote is fetched from API; for demo, it's static.
  Quote currentQuote = Quote(
    text: "Success is not final, failure is not fatal: It is the courage to continue that counts.",
    author: "Winston Churchill",
  );

  bool get isCurrentFavorite =>
      favorites.any((q) => q == currentQuote);

  AppState() {
    _init();
  }

  void _init() async {
    favorites = await repo.loadFavorites();
    notifyListeners();
  }

  void toggleFavorite() async {
    if (isCurrentFavorite) {
      favorites.removeWhere((q) => q == currentQuote);
    } else {
      favorites.add(currentQuote);
    }
    await repo.saveFavorites(favorites);
    notifyListeners();
  }
}

// PUBLIC_INTERFACE
class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  ThemeMode _themeMode = ThemeMode.light;
  final AppState appState = AppState();

  void _toggleTheme() {
    setState(() {
      _themeMode =
          _themeMode == ThemeMode.light ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    // Pass appState to HomeScreen and all descendants that need it
    return MaterialApp(
      title: 'InspireDaily',
      theme: AppThemes.lightTheme,
      darkTheme: AppThemes.darkTheme,
      themeMode: _themeMode,
      home: HomeScreen(
        onToggleTheme: _toggleTheme,
        themeMode: _themeMode,
        appState: appState,
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

// HomeScreen now takes appState
class HomeScreen extends StatefulWidget {
  final VoidCallback onToggleTheme;
  final ThemeMode themeMode;
  final AppState appState;

  const HomeScreen({
    super.key,
    required this.onToggleTheme,
    required this.themeMode,
    required this.appState,
  });

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  @override
  void initState() {
    super.initState();
    widget.appState.addListener(_handleStateChange);
  }

  void _handleStateChange() => setState(() {});

  @override
  void dispose() {
    widget.appState.removeListener(_handleStateChange);
    super.dispose();
  }

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
              onPressed: widget.onToggleTheme,
            ),
            IconButton(
              icon: Icon(
                Icons.favorite,
                color: widget.appState.favorites.isNotEmpty
                    ? Theme.of(context).colorScheme.tertiary
                    : null,
              ),
              tooltip: 'Favorites',
              onPressed: () {
                Navigator.of(context).push(
                  MaterialPageRoute(
                    builder: (_) =>
                        FavoritesScreen(appState: widget.appState),
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
          child: QuoteCard(
            isDark: isDark,
            appState: widget.appState,
          ),
        ),
      ),
    );
  }
}

// Widget for displaying quote in a gradient card, uses actual appState
class QuoteCard extends StatelessWidget {
  final bool isDark;
  final AppState appState;

  const QuoteCard({super.key, required this.isDark, required this.appState});

  @override
  Widget build(BuildContext context) {
    final gradient =
        isDark ? AppThemes.darkCardGradient : AppThemes.lightCardGradient;
    final quote = appState.currentQuote;

    return Container(
      width: MediaQuery.of(context).size.width * 0.88,
      padding: const EdgeInsets.all(24),
      decoration: BoxDecoration(
        gradient: gradient,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: isDark
                ? Color(0x80000000)
                : Color(0x4D9E9E9E),
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
            quote.text,
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
                "- ${quote.author}",
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
                icon: Icon(
                  appState.isCurrentFavorite
                      ? Icons.favorite
                      : Icons.favorite_border,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                tooltip: appState.isCurrentFavorite ? "Unfavorite" : "Favorite",
                onPressed: () {
                  appState.toggleFavorite();
                  final msg = appState.isCurrentFavorite
                      ? "Quote added to favorites!"
                      : "Quote removed from favorites!";
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(content: Text(msg)),
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

// Favorites screen with themed gradient background, reads from appState
class FavoritesScreen extends StatefulWidget {
  final AppState appState;

  const FavoritesScreen({super.key, required this.appState});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  @override
  void initState() {
    super.initState();
    widget.appState.addListener(_handleStateChange);
  }

  void _handleStateChange() => setState(() {});

  @override
  void dispose() {
    widget.appState.removeListener(_handleStateChange);
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final gradient = isDark
        ? AppThemes.darkFavoritesGradient
        : AppThemes.lightFavoritesGradient;

    final favorites = widget.appState.favorites;

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
        child: favorites.isEmpty
            ? Center(
                child: Text('No favorites yet!',
                    style: Theme.of(context)
                        .textTheme
                        .titleMedium!
                        .copyWith(color: Theme.of(context).colorScheme.secondary)),
              )
            : ListView.builder(
                padding: const EdgeInsets.symmetric(vertical: 24),
                itemCount: favorites.length,
                itemBuilder: (context, idx) {
                  final q = favorites[idx];
                  final cardGradient = isDark
                      ? AppThemes.darkCardGradient
                      : AppThemes.lightCardGradient;
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
                        q.text,
                        style: Theme.of(context).textTheme.bodyLarge!.copyWith(
                            fontWeight: FontWeight.w600),
                      ),
                      subtitle: Text(
                        "- ${q.author}",
                        style: Theme.of(context).textTheme.bodyMedium!.copyWith(
                            color: Theme.of(context).colorScheme.secondary),
                      ),
                      trailing: IconButton(
                        icon: Icon(Icons.delete_outline,
                            color: Theme.of(context).colorScheme.secondary),
                        tooltip: "Remove from favorites",
                        onPressed: () {
                          setState(() {
                            widget.appState.favorites.removeAt(idx);
                            widget.appState.repo
                                .saveFavorites(widget.appState.favorites);
                            widget.appState.notifyListeners();
                          });
                        },
                      ),
                    ),
                  );
                },
              ),
      ),
    );
  }
}
