import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'dart:convert';
import 'dart:async';
import 'package:http/http.dart' as http;

// PUBLIC_INTERFACE
void main() {
  runApp(const InspireDailyApp());
}

/// This is the main application widget, managing theme and routes.
class InspireDailyApp extends StatefulWidget {
  // PUBLIC_INTERFACE
  const InspireDailyApp({super.key});

  @override
  State<InspireDailyApp> createState() => _InspireDailyAppState();
}

class _InspireDailyAppState extends State<InspireDailyApp> {
  ThemeMode _themeMode = ThemeMode.light;

  @override
  void initState() {
    super.initState();
    _loadThemeMode();
  }

  Future<void> _loadThemeMode() async {
    final prefs = await SharedPreferences.getInstance();
    final isDark = prefs.getBool('isDarkTheme') ?? false;
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  Future<void> _toggleTheme() async {
    final isDark = _themeMode == ThemeMode.dark;
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkTheme', !isDark);
    setState(() {
      _themeMode = !isDark ? ThemeMode.dark : ThemeMode.light;
    });
  }

  @override
  Widget build(BuildContext context) {
    // System UI setup for immersive feel
    SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
    ));

    return MaterialApp(
      title: 'InspireDaily',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        brightness: Brightness.light,
        primaryColor: const Color(0xff00b3ff),
        scaffoldBackgroundColor: const Color(0xffffffff),
        cardColor: Colors.white,
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Colors.white,
          iconTheme: IconThemeData(color: Color(0xff00b3ff)),
          titleTextStyle: TextStyle(
            color: Color(0xff00b3ff),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xff00b3ff),
        ),
        colorScheme: ColorScheme.light(
          secondary: const Color(0xfffa0057),
          primary: const Color(0xff00b3ff),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.black, fontSize: 18),
          bodyMedium: TextStyle(color: Colors.black87, fontSize: 16),
        ),
      ),
      darkTheme: ThemeData(
        brightness: Brightness.dark,
        primaryColor: const Color(0xff00b3ff),
        scaffoldBackgroundColor: const Color(0xFF181822),
        cardColor: const Color(0xFF23232d),
        appBarTheme: const AppBarTheme(
          elevation: 0,
          backgroundColor: Color(0xFF181822),
          iconTheme: IconThemeData(color: Color(0xff00b3ff)),
          titleTextStyle: TextStyle(
            color: Color(0xff00b3ff),
            fontWeight: FontWeight.bold,
            fontSize: 22,
          ),
        ),
        floatingActionButtonTheme: const FloatingActionButtonThemeData(
          backgroundColor: Color(0xff00b3ff),
        ),
        colorScheme: const ColorScheme.dark(
          secondary: Color(0xfffa0057),
          primary: Color(0xff00b3ff),
        ),
        textTheme: const TextTheme(
          bodyLarge: TextStyle(color: Colors.white, fontSize: 18),
          bodyMedium: TextStyle(color: Colors.white70, fontSize: 16),
        ),
      ),
      themeMode: _themeMode,
      routes: {
        '/': (context) => HomeScreen(toggleTheme: _toggleTheme, themeMode: _themeMode),
        '/favorites': (context) => FavoritesScreen(toggleTheme: _toggleTheme, themeMode: _themeMode),
      },
    );
  }
}

/// Model representing a Quote.
class Quote {
  final String text;
  final String author;
  final String id;

  // PUBLIC_INTERFACE
  Quote({required this.text, required this.author, required this.id});

  // Factory constructor to create a Quote from JSON, handling API formats.
  factory Quote.fromJson(Map<String, dynamic> json) {
    // For API: https://api.quotable.io/random
    return Quote(
      text: json['content'] ?? json['text'] ?? '',
      author: json['author'] ?? 'Unknown',
      id: json['_id'] ?? (json['id'] ?? DateTime.now().toIso8601String()),
    );
  }

  // Convert Quote to JSON (for local storage)
  Map<String, dynamic> toJson() => {
        'text': text,
        'author': author,
        'id': id,
      };

  // PUBLIC_INTERFACE
  // Compare quotes by id
  @override
  bool operator ==(Object other) =>
      identical(this, other) ||
      (other is Quote && text == other.text && author == other.author && id == other.id);

  @override
  int get hashCode => text.hashCode ^ author.hashCode ^ id.hashCode;
}

/// Service to fetch quotes from the public API.
/// Uses: https://api.quotable.io/random
class QuoteService {
  static const _apiUrl = 'https://api.quotable.io/random';

  // PUBLIC_INTERFACE
  static Future<Quote?> fetchQuoteOfTheDay() async {
    try {
      final response = await http.get(Uri.parse(_apiUrl));
      if (response.statusCode == 200) {
        final Map<String, dynamic> data = json.decode(response.body);
        return Quote.fromJson(data);
      }
    } catch (e) {
      // Fail silently and return null
    }
    return null;
  }
}

/// Manages local storage for favorited quotes.
class FavoritesManager {
  static const _favoritesKey = 'favorite_quotes';

  // PUBLIC_INTERFACE
  static Future<List<Quote>> getFavorites() async {
    final prefs = await SharedPreferences.getInstance();
    final String? jsonString = prefs.getString(_favoritesKey);
    if (jsonString == null) return [];
    final List decoded = json.decode(jsonString);
    return decoded.map((item) => Quote.fromJson(item)).toList().cast<Quote>();
  }

  // PUBLIC_INTERFACE
  static Future<void> saveFavorites(List<Quote> quotes) async {
    final prefs = await SharedPreferences.getInstance();
    final List<Map<String, dynamic>> jsonList = quotes.map((q) => q.toJson()).toList();
    final jsonString = json.encode(jsonList);
    await prefs.setString(_favoritesKey, jsonString);
  }

  // PUBLIC_INTERFACE
  static Future<void> addFavorite(Quote quote) async {
    final favorites = await getFavorites();
    if (!favorites.contains(quote)) {
      favorites.add(quote);
      await saveFavorites(favorites);
    }
  }

  // PUBLIC_INTERFACE
  static Future<void> removeFavorite(Quote quote) async {
    final favorites = await getFavorites();
    favorites.removeWhere((q) => q.id == quote.id);
    await saveFavorites(favorites);
  }

  // PUBLIC_INTERFACE
  static Future<bool> isFavorite(Quote quote) async {
    final favorites = await getFavorites();
    return favorites.any((q) => q.id == quote.id);
  }
}

/// HomeScreen - displays daily quote and navigation.
class HomeScreen extends StatefulWidget {
  final Future<void> Function() toggleTheme;
  final ThemeMode themeMode;

  // PUBLIC_INTERFACE
  const HomeScreen({required this.toggleTheme, required this.themeMode, super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

/// State for HomeScreen, fetches daily quote and manages favorite status.
class _HomeScreenState extends State<HomeScreen> {
  Future<Quote?>? _quoteFuture;
  bool _isFavorite = false;
  Quote? _currentQuote;

  @override
  void initState() {
    super.initState();
    _fetchQuote();
  }

  void _fetchQuote() {
    setState(() {
      _quoteFuture = QuoteService.fetchQuoteOfTheDay();
    });
    _quoteFuture?.then((quote) async {
      _currentQuote = quote;
      if (quote != null) {
        final fav = await FavoritesManager.isFavorite(quote);
        setState(() {
          _isFavorite = fav;
        });
      }
    });
  }

  Future<void> _toggleFavorite() async {
    if (_currentQuote == null) return;
    if (_isFavorite) {
      await FavoritesManager.removeFavorite(_currentQuote!);
    } else {
      await FavoritesManager.addFavorite(_currentQuote!);
    }
    final fav = await FavoritesManager.isFavorite(_currentQuote!);
    setState(() {
      _isFavorite = fav;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: InspireAppBar(
        title: 'InspireDaily',
        actions: [
          IconButton(
            icon: Icon(widget.themeMode == ThemeMode.light ? Icons.dark_mode : Icons.light_mode),
            tooltip: 'Toggle Light/Dark Mode',
            onPressed: widget.toggleTheme,
          ),
        ],
      ),
      body: Center(
        child: FutureBuilder<Quote?>(
          future: _quoteFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return CircularProgressIndicator(
                color: Theme.of(context).colorScheme.secondary,
              );
            }
            if (snapshot.hasError || !snapshot.hasData || snapshot.data == null) {
              return QuoteCard(
                quote: Quote(
                  text: 'Unable to fetch quote for today.\nPlease check your connection and try again.',
                  author: 'InspireDaily',
                  id: 'error',
                ),
                isFavorite: false,
                onFavorite: null,
              );
            }
            final quote = snapshot.data!;
            return QuoteCard(
              quote: quote,
              isFavorite: _isFavorite,
              onFavorite: _toggleFavorite,
            );
          },
        ),
      ),
      bottomNavigationBar: InspireBottomNavBar(
        currentIndex: 0,
        onTabSelected: (idx) {
          if (idx == 1) Navigator.pushReplacementNamed(context, '/favorites');
        },
      ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _fetchQuote();
        },
        tooltip: "Refresh Quote",
        child: const Icon(Icons.refresh, color: Colors.white),
      ),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerDocked,
    );
  }
}

/// QuoteCard - Stylized card for displaying a quote, author, and favorite button.
class QuoteCard extends StatelessWidget {
  final Quote quote;
  final bool isFavorite;
  final VoidCallback? onFavorite;

  // PUBLIC_INTERFACE
  const QuoteCard({required this.quote, required this.isFavorite, this.onFavorite, super.key});

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final accent = theme.colorScheme.secondary;
    final secondary = theme.primaryColor;

    return Card(
      color: theme.cardColor,
      margin: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
      elevation: 5,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 30.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(Icons.format_quote, size: 36, color: accent),
            const SizedBox(height: 10),
            Text(
              '"${quote.text}"',
              style: theme.textTheme.bodyLarge?.copyWith(fontStyle: FontStyle.italic, fontWeight: FontWeight.w500, fontSize: 21),
              textAlign: TextAlign.center,
            ),
            const SizedBox(height: 15),
            Align(
              alignment: Alignment.centerRight,
              child: Text(
                '- ${quote.author}',
                style: theme.textTheme.bodyMedium?.copyWith(
                  fontWeight: FontWeight.w500,
                  color: secondary,
                  fontSize: 16,
                ),
                textAlign: TextAlign.end,
              ),
            ),
            const SizedBox(height: 16),
            if (onFavorite != null)
              IconButton(
                icon: Icon(
                  isFavorite ? Icons.favorite : Icons.favorite_border,
                  color: accent,
                  size: 28,
                ),
                tooltip: isFavorite ? 'Remove from Favorites' : 'Mark as Favorite',
                onPressed: onFavorite,
              ),
          ],
        ),
      ),
    );
  }
}

/// FavoritesScreen - shows all favorited quotes in a ListView.
class FavoritesScreen extends StatefulWidget {
  final Future<void> Function() toggleTheme;
  final ThemeMode themeMode;

  // PUBLIC_INTERFACE
  const FavoritesScreen({required this.toggleTheme, required this.themeMode, super.key});

  @override
  State<FavoritesScreen> createState() => _FavoritesScreenState();
}

class _FavoritesScreenState extends State<FavoritesScreen> {
  List<Quote> _favorites = [];

  @override
  void initState() {
    super.initState();
    _loadFavorites();
  }

  Future<void> _loadFavorites() async {
    final favorites = await FavoritesManager.getFavorites();
    setState(() {
      _favorites = favorites;
    });
  }

  Future<void> _removeFavorite(Quote quote) async {
    await FavoritesManager.removeFavorite(quote);
    await _loadFavorites();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: InspireAppBar(
        title: 'My Favorites',
        actions: [
          IconButton(
            icon: Icon(widget.themeMode == ThemeMode.light ? Icons.dark_mode : Icons.light_mode),
            tooltip: 'Toggle Light/Dark Mode',
            onPressed: widget.toggleTheme,
          ),
        ],
        leading: IconButton(
          icon: const Icon(Icons.arrow_back),
          onPressed: () => Navigator.pushReplacementNamed(context, '/'),
        ),
      ),
      body: _favorites.isEmpty
          ? Center(
              child: Text(
                'No favorite quotes yet.\nStart adding some for daily inspiration!',
                style: Theme.of(context).textTheme.bodyLarge,
                textAlign: TextAlign.center,
              ),
            )
          : ListView.builder(
              itemCount: _favorites.length,
              itemBuilder: (context, idx) {
                final quote = _favorites[idx];
                return Dismissible(
                  key: ValueKey(quote.id),
                  background: Container(
                    color: Theme.of(context).colorScheme.secondary.withAlpha((0.8 * 255).toInt()),
                    alignment: Alignment.centerRight,
                    padding: const EdgeInsets.only(right: 32),
                    child: const Icon(Icons.delete, color: Colors.white),
                  ),
                  direction: DismissDirection.endToStart,
                  onDismissed: (direction) {
                    _removeFavorite(quote);
                  },
                  child: QuoteCard(
                    quote: quote,
                    isFavorite: true,
                    onFavorite: () => _removeFavorite(quote),
                  ),
                );
              },
            ),
      bottomNavigationBar: InspireBottomNavBar(
        currentIndex: 1,
        onTabSelected: (idx) {
          if (idx == 0) Navigator.pushReplacementNamed(context, '/');
        },
      ),
    );
  }
}

/// App bar with minimal modern style.
class InspireAppBar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  final List<Widget>? actions;
  final Widget? leading;

  // PUBLIC_INTERFACE
  const InspireAppBar({required this.title, this.actions, this.leading, super.key});

  @override
  Widget build(BuildContext context) {
    return AppBar(
      title: Text(title, style: Theme.of(context).appBarTheme.titleTextStyle),
      centerTitle: true,
      leading: leading,
      actions: actions,
      backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
      elevation: 0,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(56.0);
}

/// Bottom nav bar for Home and Favorites
class InspireBottomNavBar extends StatelessWidget {
  final int currentIndex;
  final Function(int) onTabSelected;

  // PUBLIC_INTERFACE
  const InspireBottomNavBar({required this.currentIndex, required this.onTabSelected, super.key});

  @override
  Widget build(BuildContext context) {
    return BottomAppBar(
      shape: const CircularNotchedRectangle(),
      notchMargin: 8,
      color: Theme.of(context).cardColor,
      child: SizedBox(
        height: 56,
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            _buildTabItem(context, icon: Icons.home, label: "Home", index: 0),
            _buildTabItem(context, icon: Icons.favorite, label: "Favorites", index: 1),
          ],
        ),
      ),
    );
  }

  Widget _buildTabItem(BuildContext context, {required IconData icon, required String label, required int index}) {
    final color = currentIndex == index ? Theme.of(context).colorScheme.secondary : Colors.grey;
    return InkWell(
      onTap: () => onTabSelected(index),
      borderRadius: BorderRadius.circular(40),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 9),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(icon, color: color),
            const SizedBox(height: 2),
            Text(label, style: TextStyle(color: color, fontSize: 13, fontWeight: FontWeight.w500)),
          ],
        ),
      ),
    );
  }
}
