import 'dart:async';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'dart:convert';

// Adresse IP du Raspberry Pi
const String raspberryIp = "10.192.10.135";

// Fonction pour envoyer une requête HTTP (Démarrer/Arrêter)
Future<void> _sendRequestToRaspberry(String command) async {
  final Uri url = Uri.parse(
      "http://$raspberryIp:5000/${command == "STOP" ? "stop" : "run"}");

  try {
    final response = await http.post(
      url,
      headers: {"Content-Type": "application/json"},
      body: command == "STOP" ? null : jsonEncode({"script": command}),
    );

    if (response.statusCode == 200) {
      print(
          "✅ Commande ${command == "STOP" ? "d'arrêt" : "d'exécution"} envoyée !");
    } else {
      print("❌ Erreur : ${response.body}");
    }
  } catch (e) {
    print("⚠ Impossible de contacter la Raspberry : $e");
  }
}

// Fonction pour récupérer les répétitions depuis Flask
Future<Map<String, dynamic>> _getRepsFromRaspberry() async {
  final Uri url = Uri.parse("http://$raspberryIp:5000/get_reps");

  try {
    final response = await http.get(url);
    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("❌ Erreur lors de la récupération des répétitions");
      return {};
    }
  } catch (e) {
    print("⚠ Impossible de récupérer les répétitions : $e");
    return {};
  }
}

class ExercisePage extends StatelessWidget {
  const ExercisePage({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final isLandscape =
        MediaQuery.of(context).orientation == Orientation.landscape;
    final exercises = [
      {'title': 'Squat', 'script': 'Squat', 'image': 'assets/images/squat.gif'},
      {
        'title': 'Pull-ups',
        'script': 'PullUp',
        'image': 'assets/images/pullup.gif'
      },
      {
        'title': 'Deadlift',
        'script': 'Deadlift',
        'image': 'assets/images/deadlift.gif'
      },
      {
        'title': 'Bench press',
        'script': 'benchPress',
        'image': 'assets/images/bench.gif'
      },
      {
        'title': 'Biceps Curls',
        'script': 'biceps',
        'image': 'assets/images/biceps_curl.gif'
      },
      {
        'title': 'Treadmill',
        'script': 'treadmill',
        'image': 'assets/images/treadmill.gif'
      },
    ];
    return Scaffold(
      appBar: AppBar(title: Text('Exercises')),
      body: Container(
        padding: const EdgeInsets.all(16.0),
        color: Colors.blue[100],
        child: Center(
          child: GridView.builder(
            shrinkWrap: true,
            gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
              crossAxisCount: isLandscape ? 2 : 1,
              mainAxisSpacing: 20,
              crossAxisSpacing: 20,
              childAspectRatio: 3,
            ),
            itemCount: exercises.length,
            itemBuilder: (context, index) {
              return ElevatedButton(
                onPressed: () => _showExerciseDialog(
                    context,
                    exercises[index]['title']!,
                    exercises[index]['script']!,
                    exercises[index]['image']!),
                child: Row(
                  children: [
                    // Affiche le GIF sur la gauche
                    Image.asset(
                      exercises[index]['image']!,
                      width: 50,
                      height: 50,
                      fit: BoxFit.cover,
                    ),
                    SizedBox(width: 10),
                    // Affiche le titre de l'exercice
                    Text(
                      exercises[index]['title']!,
                      style: TextStyle(fontSize: 18),
                    ),
                  ],
                ),
              );
            },
          ),
        ),
      ),
    );
  }

  void _showExerciseDialog(
      BuildContext context, String title, String script, String image) {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (BuildContext context) {
        return _ExerciseDialog(title: title, script: script, image: image);
      },
    );
  }
}

class _ExerciseDialog extends StatefulWidget {
  final String title;
  final String script;
  final String image;

  const _ExerciseDialog(
      {required this.title, required this.script, required this.image});

  @override
  State<_ExerciseDialog> createState() => _ExerciseDialogState();
}

class _ExerciseDialogState extends State<_ExerciseDialog> {
  int secondsElapsed = 0;
  Timer? timer;
  bool isRunning = false;

  @override
  void dispose() {
    _stopTimer();
    super.dispose();
  }

  void _startTimer() {
    setState(() => isRunning = true);
    timer = Timer.periodic(Duration(seconds: 1), (Timer t) {
      setState(() => secondsElapsed++);
    });
  }

  void _stopTimer() {
    timer?.cancel();
    setState(() {
      isRunning = false;
      secondsElapsed = 0;
    });
  }

  Future<void> _startScriptExecution() async {
    await _sendRequestToRaspberry(widget.script);
    _startTimer();
  }

  Future<void> _stopScriptExecution() async {
    await _sendRequestToRaspberry("STOP");
    _stopTimer();
    Map<String, dynamic> repsData = await _getRepsFromRaspberry();
    _showRepsDialog(repsData);
  }

  void _showRepsDialog(Map<String, dynamic> repsData) {
    String message = "Répétitions : ${repsData[widget.script] ?? 0}";

    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Résultats de l'exercice"),
          content: Text(message),
          actions: [
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child: Text("Fermer"),
            ),
          ],
        );
      },
    ).then((_) {
      Navigator.of(context).pop();
    });
  }

  @override
  Widget build(BuildContext context) {
    return AlertDialog(
      contentPadding: EdgeInsets.all(20),
      content: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Image.asset(widget.image, height: 100, width: 100, fit: BoxFit.cover),
          SizedBox(height: 20),
          Text('Exécution : ${widget.title}',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          SizedBox(height: 10),
          Text('Timer : $secondsElapsed secondes',
              style: TextStyle(fontSize: 20)),
          SizedBox(height: 20),
          ElevatedButton(
            onPressed: isRunning ? _stopScriptExecution : _startScriptExecution,
            child: Text(isRunning ? 'Arrêter' : 'Démarrer'),
          ),
        ],
      ),
    );
  }
}
