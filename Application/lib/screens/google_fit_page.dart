import 'dart:async';
import 'package:flutter/material.dart';
import 'package:googleapis/fitness/v1.dart' as fitness;
import 'package:googleapis_auth/auth_io.dart';
import 'package:flutter_dotenv/flutter_dotenv.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:google_sign_in/google_sign_in.dart';
import 'package:http/http.dart' as http;

class GoogleFitPage extends StatefulWidget {
  const GoogleFitPage({super.key});

  @override
  _GoogleFitPageState createState() => _GoogleFitPageState();
}

class _GoogleFitPageState extends State<GoogleFitPage> {
  bool _isAuthorized = false;
  List<FlSpot> _heartRateData = [];
  List<FlSpot> _caloriesData = [];
  String _selectedTimeRange = '2h';

  final _scopes = [
    'https://www.googleapis.com/auth/fitness.activity.read',
    'https://www.googleapis.com/auth/fitness.body.read',
    'https://www.googleapis.com/auth/fitness.heart_rate.read',
    'https://www.googleapis.com/auth/fitness.nutrition.read',
  ];

  late GoogleSignIn _googleSignIn;
  Timer? _dataFetchTimer;
  late AuthClient _client;

  @override
  void initState() {
    super.initState();
    _googleSignIn = GoogleSignIn(scopes: _scopes);
    _authorizeAndFetchData();
  }

  Future<void> _authorizeAndFetchData() async {
    await dotenv.load(fileName: ".env");
    try {
      final GoogleSignInAccount? googleUser = await _googleSignIn.signIn();
      if (googleUser == null) {
        setState(() {
          _isAuthorized = false;
        });
        return;
      }

      final GoogleSignInAuthentication googleAuth =
          await googleUser.authentication;

      // Créer un client AuthClient
      final AccessCredentials credentials = AccessCredentials(
        AccessToken('Bearer', googleAuth.accessToken!,
            DateTime.now().toUtc().add(Duration(seconds: 3600))),
        null,
        _scopes,
      );

      _client = authenticatedClient(http.Client(), credentials);

      setState(() {
        _isAuthorized = true;
      });

      final fitnessApi = fitness.FitnessApi(_client);

      // Démarrer la mise à jour des données à intervalle régulier
      _dataFetchTimer = Timer.periodic(Duration(seconds: 30), (timer) {
        _fetchLatestData(fitnessApi);
      });

      _fetchLatestData(fitnessApi);
    } catch (error) {
      print('Authorization failed: $error');
      setState(() {
        _isAuthorized = false;
      });
    }
  }

  // Fonction pour récupérer les données en fonction du range de temps
  Future<void> _fetchLatestData(fitness.FitnessApi fitnessApi) async {
    try {
      final dataSources = await fitnessApi.users.dataSources.list('me');

      final heartRateSource = dataSources.dataSource?.firstWhere(
        (source) => source.dataType?.name == 'com.google.heart_rate.bpm',
        orElse: () => fitness.DataSource(),
      );

      final caloriesSource = dataSources.dataSource?.firstWhere(
        (source) => source.dataType?.name == 'com.google.calories.expended',
        orElse: () => fitness.DataSource(),
      );

      // Définir la fenêtre de temps selon la plage de temps sélectionnée
      int timeWindow;
      switch (_selectedTimeRange) {
        case '1d':
          timeWindow = 24 * 60 * 60; // 1 jour en secondes
          break;
        case '7d':
          timeWindow = 7 * 24 * 60 * 60; // 7 jours en secondes
          break;
        case '1m':
          timeWindow = 30 * 24 * 60 * 60; // 1 mois en secondes
          break;
        case '2h':
        default:
          timeWindow = 2 * 60 * 60; // 2 heures en secondes
          break;
      }

      final endTime = DateTime.now().millisecondsSinceEpoch ~/ 1000;
      final startTime = endTime - timeWindow;

      // Récupérer les données du cœur
      if (heartRateSource != null && heartRateSource.dataStreamId != null) {
        final heartRateData = await fitnessApi.users.dataSources.datasets.get(
          'me',
          heartRateSource.dataStreamId!,
          '$startTime-$endTime',
        );

        List<FlSpot> heartRatePoints = [];
        heartRateData.point?.forEach((point) {
          final timestamp = point.startTimeNanos ?? 0;
          final value = point.value?.first.fpVal ?? 0.0;
          heartRatePoints.add(FlSpot(
            ((timestamp as int) / 1000000).toDouble(),
            value,
          ));
        });

        setState(() {
          _heartRateData = heartRatePoints;
        });
      }

      // Récupérer les données de calories
      if (caloriesSource != null && caloriesSource.dataStreamId != null) {
        final caloriesData = await fitnessApi.users.dataSources.datasets.get(
          'me',
          caloriesSource.dataStreamId!,
          '$startTime-$endTime',
        );

        List<FlSpot> caloriesPoints = [];
        caloriesData.point?.forEach((point) {
          final timestamp = point.startTimeNanos ?? 0;
          final value = point.value?.first.fpVal ?? 0.0;
          caloriesPoints.add(FlSpot(
            ((timestamp as int) / 1000000).toDouble(),
            value,
          ));
        });

        setState(() {
          _caloriesData = caloriesPoints;
        });
      }
    } catch (error) {
      print('Error fetching data: $error');
      setState(() {
        _heartRateData = [];
        _caloriesData = [];
      });
    }
  }

  @override
  void dispose() {
    _dataFetchTimer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Scaffold(
      body: Container(
        color: theme.colorScheme.primaryContainer,
        child: Center(
          child: _isAuthorized
              ? Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    DropdownButton<String>(
                      value: _selectedTimeRange,
                      onChanged: (String? newValue) {
                        setState(() {
                          _selectedTimeRange = newValue!;
                        });
                        _fetchLatestData(fitness.FitnessApi(
                            _client)); // Utilisation du client authentifié
                      },
                      items: <String>['2h', '1d', '7d', '1m']
                          .map<DropdownMenuItem<String>>((String value) {
                        return DropdownMenuItem<String>(
                          value: value,
                          child: Text(value),
                        );
                      }).toList(),
                    ),
                    Expanded(
                      child: Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: LineChart(
                          LineChartData(
                            gridData: FlGridData(show: true),
                            titlesData: FlTitlesData(show: true),
                            borderData: FlBorderData(show: true),
                            minX: 0,
                            maxX:
                                24, // Max x value could be adjusted based on the time window
                            lineBarsData: [
                              LineChartBarData(
                                spots: _heartRateData,
                                isCurved: true,
                                color: Colors.blue,
                                belowBarData: BarAreaData(show: false),
                                aboveBarData: BarAreaData(show: false),
                              ),
                              LineChartBarData(
                                spots: _caloriesData,
                                isCurved: true,
                                color: Colors.green,
                                belowBarData: BarAreaData(show: false),
                                aboveBarData: BarAreaData(show: false),
                              ),
                            ],
                          ),
                        ),
                      ),
                    ),
                  ],
                )
              : Text('Not authorized'),
        ),
      ),
    );
  }
}
