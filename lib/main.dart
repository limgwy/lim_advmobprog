import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (context) => Favorites(),
      child: const MyApp(),
    ),
  );
}

class Favorites extends ChangeNotifier {
  final List<String> _favoriteMovies = [];

  List<String> get items => _favoriteMovies;
  int get itemCount => _favoriteMovies.length;

  /// Returns true if added, false if the movie was already in favorites.
  bool add(String movie) {
    if (_favoriteMovies.contains(movie)) {
      return false;
    }
    _favoriteMovies.add(movie);
    notifyListeners();
    return true;
  }

  void clear() {
    _favoriteMovies.clear();
    notifyListeners();
  }
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Movie Favorites App',
      theme: ThemeData(
        useMaterial3: true,
        colorSchemeSeed: Colors.indigo,
      ),
      home: const MovieListScreen(),
    );
  }
}

class MovieListScreen extends StatelessWidget {
  const MovieListScreen({super.key});

  static const List<String> movies = [
    'Everything Everywhere All at Once',
    'Lalaland',
    'Hail Mary',
    'Uptown Girls',
    'Avengers Endgame',
    'Devil Wears Prada',
    'White Chicks',
  ];

  void _showNotification(BuildContext context, String message, bool isSuccess) {
    final messenger = ScaffoldMessenger.of(context);
    messenger.clearSnackBars();
    messenger.showSnackBar(
      SnackBar(
        content: Row(
          children: [
            Icon(
              isSuccess ? Icons.check_circle : Icons.info_outline,
              color: Colors.white,
            ),
            const SizedBox(width: 12),
            Expanded(
              child: Text(
                message,
                style: const TextStyle(fontWeight: FontWeight.w500),
              ),
            ),
          ],
        ),
        backgroundColor: isSuccess ? Colors.green.shade700 : Colors.orange.shade800,
        behavior: SnackBarBehavior.floating,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
        duration: const Duration(seconds: 2),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Trending Movies', style: TextStyle(fontWeight: FontWeight.bold)),
        actions: [
          Consumer<Favorites>(
            builder: (context, favorites, child) {
              return Padding(
                padding: const EdgeInsets.only(right: 8.0),
                child: Badge(
                  label: Text('${favorites.itemCount}'),
                  isLabelVisible: favorites.itemCount > 0,
                  child: IconButton(
                    icon: const Icon(Icons.favorite),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (_) => const FavoritesScreen()),
                      );
                    },
                  ),
                ),
              );
            },
          ),
        ],
      ),
      body: ListView.builder(
        padding: const EdgeInsets.all(16.0),
        itemCount: movies.length,
        itemBuilder: (context, index) {
          final movie = movies[index];
          return Card(
            elevation: 0,
            margin: const EdgeInsets.only(bottom: 14.0),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(20),
              side: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.7)),
            ),
            child: ListTile(
              contentPadding: const EdgeInsets.symmetric(horizontal: 18, vertical: 14),
              leading: Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: Theme.of(context).colorScheme.primaryContainer,
                  borderRadius: BorderRadius.circular(14),
                ),
                child: Icon(
                  Icons.movie_creation_outlined,
                  color: Theme.of(context).colorScheme.primary,
                  size: 28,
                ),
              ),
              title: Text(
                movie,
                style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              trailing: IconButton.filledTonal(
                icon: const Icon(Icons.favorite_border),
                onPressed: () {
                  final isAdded = Provider.of<Favorites>(context, listen: false).add(movie);
                  if (isAdded) {
                    _showNotification(context, '$movie added to favorites!', true);
                  } else {
                    _showNotification(context, '$movie is already in favorites', false);
                  }
                },
                
              ),
            ),
          );
        },
      ),
    );
  }
}

class FavoritesScreen extends StatelessWidget {
  const FavoritesScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Your Favorites', style: TextStyle(fontWeight: FontWeight.bold)),
      ),
      body: Consumer<Favorites>(
        builder: (context, favorites, child) {
          if (favorites.items.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(Icons.favorite_outline, size: 88, color: Colors.grey.shade400),
                  const SizedBox(height: 16),
                  Text(
                    'No favorites yet',
                    style: TextStyle(fontSize: 18, color: Colors.grey.shade600),
                  ),
                ],
              ),
            );
          }

          return Padding(
            padding: const EdgeInsets.all(16.0),
            child: Column(
              children: [
                Card(
                  elevation: 0,
                  color: Theme.of(context).colorScheme.surfaceVariant,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
                  child: Padding(
                    padding: const EdgeInsets.all(18.0),
                    child: Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Total Saved: ${favorites.itemCount}',
                          style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
                        ),
                        TextButton.icon(
                          onPressed: favorites.clear,
                          icon: const Icon(Icons.delete_outline, color: Colors.red),
                          label: const Text('Clear All', style: TextStyle(color: Colors.red)),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 16),
                Expanded(
                  child: ListView.builder(
                    itemCount: favorites.items.length,
                    itemBuilder: (context, index) {
                      final movie = favorites.items[index];
                      return Card(
                        elevation: 0,
                        margin: const EdgeInsets.only(bottom: 12.0),
                        shape: RoundedRectangleBorder(
                          borderRadius: BorderRadius.circular(16),
                          side: BorderSide(color: Theme.of(context).colorScheme.outline.withOpacity(0.6)),
                        ),
                        child: ListTile(
                          leading: const Icon(Icons.star, color: Colors.amber),
                          title: Text(movie, style: const TextStyle(fontWeight: FontWeight.w600)),
                        ),
                      );
                    },
                  ),
                ),
              ],
            ),
          );
        },
      ),
    );
  }
}
