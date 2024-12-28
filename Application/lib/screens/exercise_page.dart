import 'package:flutter/material.dart';
import 'dart:async';

class ExercisePage extends StatelessWidget {
  const ExercisePage({super.key});

  @override
  Widget build(BuildContext context) {
    // Détecter l'orientation de l'écran
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;

    return Scaffold(
      body: Container(
        color: Theme.of(context).colorScheme.primaryContainer, // Fond bleu
        padding: const EdgeInsets.all(16.0),
        child: Center(
          child: GridView.builder(
            shrinkWrap: true, // Important pour centrer GridView
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isLandscape
                  ? 2
                  : 1, // 2 boutons par ligne en paysage, 1 en portrait
              mainAxisSpacing: 20, // Espacement vertical entre les boutons
              crossAxisSpacing: 20, // Espacement horizontal entre les boutons
              childAspectRatio: 3, // Ratio largeur/hauteur pour les boutons
            ),
            itemCount: 4, // Nombre total de boutons
            itemBuilder: (context, index) {
              // Liste des exercices et images associées
              final exercises = [
                {'title': 'Squat', 'image': 'assets/images/squat.gif'},
                {'title': 'Pull-ups', 'image': 'assets/images/pullup.gif'},
                {'title': 'Deadlift', 'image': 'assets/images/deadlift.gif'},
                {'title': 'Bench press', 'image': 'assets/images/bench.gif'},
              ];

              return _buildExerciseButton(
                context,
                exercises[index]['title']!,
                exercises[index]['image']!,
              );
            },
          ),
        ),
      ),
    );
  }

  Widget _buildExerciseButton(
      BuildContext context, String title, String imagePath) {
    return ElevatedButton(
      onPressed: () {
        // Afficher la popup au clic
        _showExerciseDialog(context, title);
      },
      style: ElevatedButton.styleFrom(
        padding: EdgeInsets.symmetric(vertical: 20, horizontal: 20),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          Image.asset(imagePath, width: 50, height: 50),
          SizedBox(width: 20), // Espacement entre l'image et le texte
          Expanded(child: Text(title, style: TextStyle(fontSize: 18))),
        ],
      ),
    );
  }

  void _showExerciseDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      barrierDismissible:
          false, // Désactiver la fermeture en cliquant en dehors
      builder: (BuildContext context) {
        return _ExerciseDialog(title: title);
      },
    );
  }
}

class _ExerciseDialog extends StatefulWidget {
  final String title;

  const _ExerciseDialog({required this.title});

  @override
  State<_ExerciseDialog> createState() => _ExerciseDialogState();
}

class _ExerciseDialogState extends State<_ExerciseDialog> {
  int secondsElapsed = 0;
  Timer? timer;

  @override
  void initState() {
    super.initState();
    _startTimer();
  }

  // Démarrage du timer
  void _startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() {
        secondsElapsed++;
      });
    });
  }

  // Arrêter le timer
  void _stopTimer() {
    if (timer != null) {
      timer!.cancel();
      timer = null;
    }
  }

  @override
  void dispose() {
    _stopTimer(); // Assurez-vous d'annuler le timer lorsque le widget est supprimé
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.all(20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          CircularProgressIndicator(), // Spinner de chargement
          SizedBox(height: 20),
          Text(
            'Recovery of data',
            style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
          ),
          SizedBox(height: 20),
          Text(
            'Timer: $secondsElapsed seconds',
            style: TextStyle(fontSize: 20),
          ),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: () {
              _stopTimer(); // Arrêter le timer
              Navigator.of(context).pop(); // Fermer la popup
            },
            child: Text('Stop'),
          ),
        ],
      ),
    );
  }
}
