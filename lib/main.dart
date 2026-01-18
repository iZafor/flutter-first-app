import 'dart:collection';

import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main(List<String> args) {
  runApp(MyApp());
}

class MyApp extends StatefulWidget {
  @override
  State<MyApp> createState() => _MyApp();
}

class _MyApp extends State<MyApp> {
  int _selectedIndex = 0;

  Widget get currentPage => switch (_selectedIndex) {
    0 => HomePage(),
    1 => FavoritesPage(),
    _ => throw UnimplementedError('no page for $_selectedIndex'),
  };

  @override
  Widget build(BuildContext context) => ChangeNotifierProvider(
    create: (BuildContext context) => MyAppState(),
    child: MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData.from(
        colorScheme: ColorScheme.fromSeed(seedColor: Colors.orangeAccent),
      ),
      home: LayoutBuilder(
        builder: (context, constraints) => SafeArea(
          child: Row(
            children: [
              NavigationRail(
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
                selectedIndex: _selectedIndex,
                onDestinationSelected: (newIndex) => setState(() {
                  _selectedIndex = newIndex;
                }),
              ),
              Expanded(child: currentPage),
            ],
          ),
        ),
      ),
    ),
  );
}

class HomePage extends StatelessWidget {
  HomePage({super.key});

  final ScrollController _scrollController = ScrollController();

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final currentPair = appState.current;
    final theme = Theme.of(context);
    final textStyle = theme.textTheme.displayMedium!;

    _scrollToBottom(duration: Duration(milliseconds: 500));

    return Container(
      color: theme.colorScheme.primaryContainer,
      alignment: Alignment.center,
      child: Column(
        spacing: 8,
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Expanded(
            child: Container(
              alignment: AlignmentDirectional.bottomCenter,
              child: SizedBox(
                height: 250,
                child: ListView.builder(
                  reverse: true,
                  controller: _scrollController,
                  physics: BouncingScrollPhysics(),
                  itemCount: appState.pairs.length,
                  itemBuilder: (context, index) {
                    final currentPair = appState.pairs[index];

                    return appState.isFavorite(currentPair)
                        ? Row(
                            spacing: 8,
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              Icon(Icons.favorite),
                              Text(
                                currentPair.toString(),
                                style: theme.textTheme.bodyLarge,
                              ),
                            ],
                          )
                        : Text(
                            currentPair.toString(),
                            style: theme.textTheme.bodyLarge,
                            textAlign: TextAlign.center,
                          );
                  },
                ),
              ),
            ),
          ),
          Expanded(
            child: Column(
              spacing: 10,
              children: [
                Card(
                  color: theme.colorScheme.inversePrimary,
                  elevation: 4,
                  child: Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: AnimatedSize(
                      curve: Curves.easeInOut,
                      duration: Duration(milliseconds: 200),
                      child: Text.rich(
                        TextSpan(
                          style: textStyle,
                          children: [
                            TextSpan(text: currentPair.first),
                            TextSpan(
                              text: currentPair.second,
                              style: textStyle.copyWith(
                                color: theme.colorScheme.onPrimary,
                              ),
                            ),
                          ],
                        ),
                      ),
                    ),
                  ),
                ),
                Row(
                  mainAxisSize: MainAxisSize.min,
                  spacing: 8,
                  children: [
                    FavoriteButton(theme: theme),
                    IconButton.filled(
                      style: IconButton.styleFrom(
                        elevation: 4,
                        shadowColor: theme.colorScheme.secondary,
                      ),
                      onPressed: () {
                        appState.next();
                        _scrollToBottom();
                      },
                      icon: Icon(Icons.navigate_next),
                      tooltip: 'Next Word Pair',
                    ),
                  ],
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  void _scrollToBottom({
    Duration duration = const Duration(milliseconds: 100),
  }) {
    Future.delayed(
      Duration(milliseconds: 100),
      () => _scrollController.animateTo(
        _scrollController.position.maxScrollExtent,
        duration: duration,
        curve: Curves.easeOut,
      ),
    );
  }
}

class FavoriteButton extends StatefulWidget {
  const FavoriteButton({super.key, required this.theme});

  final ThemeData theme;

  @override
  State<FavoriteButton> createState() => _FavoriteButtonState();
}

class _FavoriteButtonState extends State<FavoriteButton>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<Color?> _iconColor;
  AnimationStatus _animationStatus = AnimationStatus.dismissed;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      duration: Duration(milliseconds: 200),
      vsync: this,
    );

    _iconColor = ColorTween(
      begin: widget.theme.colorScheme.onPrimary,
      end: widget.theme.colorScheme.scrim,
    ).animate(_animationController);

    _animationController.addStatusListener((newStatus) {
      _animationStatus = newStatus;
    });
  }

  @override
  void dispose() {
    super.dispose();

    _animationController.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final theme = widget.theme;

    if (!appState.isFavorite(appState.current)) {
      _animationController.reverse();
    } else {
      _animationController.forward();
    }

    return AnimatedBuilder(
      animation: _animationController,
      builder: (context, _) => IconButton.filled(
        style: IconButton.styleFrom(
          elevation: 4,
          shadowColor: theme.colorScheme.secondary,
        ),
        onPressed: () {
          if (_animationStatus case AnimationStatus.completed) {
            _animationController.reverse();
          } else {
            _animationController.forward();
          }
          appState.toggleFavorite();
        },
        icon: Icon(Icons.favorite, color: _iconColor.value),
        tooltip: 'Toggle Favorite',
      ),
    );
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    final appState = context.watch<MyAppState>();
    final favorites = appState.favorites;
    final theme = Theme.of(context);
    final noFavTextStyle = theme.textTheme.displayLarge!.copyWith(
      color: theme.colorScheme.secondary,
      fontWeight: FontWeight.bold,
    );
    final textStyle = theme.textTheme.displaySmall!.copyWith(fontSize: 24);

    return Container(
      color: theme.colorScheme.primaryContainer,
      padding: EdgeInsets.all(16),
      child: favorites.isEmpty
          ? Center(child: Text('No favorites', style: noFavTextStyle))
          : GridView.count(
              crossAxisCount: 2,
              mainAxisSpacing: 4,
              crossAxisSpacing: 4,
              childAspectRatio: 4,
              clipBehavior: Clip.hardEdge,
              children: favorites.map((currentPair) {
                return TweenAnimationBuilder(
                  key: UniqueKey(),
                  tween: Tween<double>(begin: 0, end: 1),
                  duration: Duration(seconds: 1),
                  curve: Curves.elasticOut,
                  builder: (context, value, _) => Transform.scale(
                    scale: value,
                    child: Card(
                      color: theme.colorScheme.inversePrimary,
                      elevation: 4,
                      clipBehavior: Clip.hardEdge,
                      child: Row(
                        spacing: 2,
                        children: [
                          SizedBox(width: 10),
                          MouseRegion(
                            cursor: SystemMouseCursors.click,
                            child: GestureDetector(
                              onTap: () => appState.removeFavorite(currentPair),
                              child: Icon(Icons.delete_forever),
                            ),
                          ),
                          Flexible(
                            child: Text.rich(
                              overflow: TextOverflow.ellipsis,
                              TextSpan(
                                style: textStyle,
                                children: [
                                  TextSpan(text: currentPair.first),
                                  TextSpan(
                                    text: currentPair.second,
                                    style: textStyle.copyWith(
                                      color: theme.colorScheme.onPrimary,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                );
              }).toList(),
            ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  final List<WordPair> _pairs;
  final Set<WordPair> _favorites;

  MyAppState() : _pairs = [WordPair.random()], _favorites = HashSet();

  WordPair get current => _pairs.last;

  List<WordPair> get pairs => _pairs;

  Set<WordPair> get favorites => _favorites;

  void next() {
    _pairs.add(WordPair.random());
    notifyListeners();
  }

  bool isFavorite(WordPair pair) => _favorites.contains(pair);

  void toggleFavorite() {
    if (_favorites.contains(current)) {
      _favorites.remove(current);
    } else {
      _favorites.add(current);
    }
    notifyListeners();
  }

  void removeFavorite(WordPair pair) {
    _favorites.remove(pair);
    notifyListeners();
  }
}
