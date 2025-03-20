import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'screens/stopwatch_page.dart';
import 'screens/home_page.dart';
import 'screens/favorites_page.dart';
import 'screens/google_fit_page.dart';
import 'screens/exercise_page.dart';

Future<void> main() async {
  try {
    await dotenv.load(fileName: ".env");
  } catch (e) {
    // Gérer l'erreur de chargement des variables d'environnement
  }
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'SyncUp Fitness',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
          // Assure-toi d'utiliser ici la police (font) que tu souhaites pour toute l'application
        ),
        // Ajout de la propriété routes pour définir les routes nommées
        routes: {
          '/': (context) => const MyHomePage(),
          '/exercise_page': (context) => const ExercisePage(),
          // Tu peux ajouter d'autres routes ici si nécessaire
        },
        initialRoute: '/',
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();
  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  var favorites = <WordPair>[];

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key});

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = const HomePage();
        break;
      case 1:
        page = const StopwatchPage();
        break;
      case 2:
        page = const BluetoothHeartRatePage();
        break;
      case 3:
        page = const ExercisePage();
        break;
      default:
        throw UnimplementedError('no widget for $selectedIndex');
    }

    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            SafeArea(
              child: NavigationRail(
                extended: constraints.maxWidth >= 600,
                leading: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Image.asset(
                    'assets/images/logo.png',
                    width: 50,
                    height: 50,
                  ),
                ),
                destinations: const [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.timer),
                    label: Text('Stopwatch'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.fitness_center),
                    label: Text('Google Fit'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.directions_run),
                    label: Text('Exercises'),
                  ),
                ],
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}
