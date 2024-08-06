import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_qiblah/flutter_qiblah.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:math';
import 'package:intl/intl.dart';
import 'package:lottie/lottie.dart';
import 'package:permission_handler/permission_handler.dart';
import 'package:services_ksa/consts.dart';
import 'package:translator/translator.dart';
import 'package:weather/weather.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:http/http.dart' as http;

class HomePage extends StatefulWidget {
  const HomePage({super.key});

  @override
  State<HomePage> createState() => _HomePageState();
}

String _selectedCity = 'Riyadh';

List<Weather>? _weatherForecast;

class _HomePageState extends State<HomePage> {
  final List<String> _cities = [
    'Riyadh',
    'Jeddah',
    'Mecca',
    'Medina',
    'Dammam',
    'Khobar',
    'Dhahran',
    'Tabuk',
    'Buraidah',
    'Khamis Mushait',
    'Abha',
    'Hofuf',
    'Al-Mubarraz',
    'Hail',
    'Najran',
    'Jubail',
    'Al-Kharj',
    'Yanbu',
    'Al Qatif',
    'Al Khafji',
    'Al Jubail',
    'Taif',
    'Qatif',
    'Al Bahah',
    'Arar',
    'Sakakah',
    'Jizan',
    'Rabigh',
    'Khafji',
    'Ras Tanura'
  ];

  Weather? _weather;
  final WeatherFactory _wf = WeatherFactory(OPENWEATHER_API_KEY);

  @override
  void initState() {
    super.initState();
    _fetchWeather();
  }

  void _fetchWeather() {
    setState(() {
      _weather = _weatherForecast = null;
    });

    _wf.fiveDayForecastByCityName(_selectedCity).then((wf) {
      setState(() {
        _weatherForecast = wf;
      });
    });

    _wf.currentWeatherByCityName(_selectedCity).then((w) {
      setState(() {
        _weather = w;
      });
    });
  }

  void _showCityDropdown() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          backgroundColor: Colors.deepPurple,
          content: _cityDropdown(),
        );
      },
    );
  }

  Widget _cityDropdown() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16.0),
      decoration: BoxDecoration(
        color: Colors.transparent,
        borderRadius: BorderRadius.circular(8.0),
      ),
      child: DropdownButtonHideUnderline(
        child: DropdownButton<String>(
          dropdownColor: Colors.deepPurpleAccent,
          iconEnabledColor: Colors.white,
          value: _selectedCity,
          focusColor: Colors.transparent,
          items: _cities.map((String city) {
            return DropdownMenuItem<String>(
              value: city,
              child: Text(
                city,
                style: const TextStyle(color: Colors.white),
              ),
            );
          }).toList(),
          onChanged: (String? newValue) {
            setState(() {
              _selectedCity = newValue!;
              _fetchWeather();
            });
            Navigator.of(context).pop(); // Close the dialog
          },
        ),
      ),
    );
  }

  Widget _buildUI() {
    if (_weather == null || _weatherForecast == null) {
      return Center(
        child: Lottie.asset('assets/lottie/weather_animation.json'),
      );
    }
    return SizedBox(
      child: Column(
        mainAxisSize: MainAxisSize.max,
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          _locationHeader(),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.05,
          ),
          _dateTimeInfo(),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.03,
          ),
          _weatherIcon(),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.02,
          ),
          _currentTemp(),
          SizedBox(
            height: MediaQuery.sizeOf(context).height * 0.02,
          ),
          _extraInfo(),
        ],
      ),
    );
  }

  Widget _locationHeader() {
    return Text(
      _weather?.areaName ?? "",
      style: const TextStyle(
        fontSize: 24,
        fontWeight: FontWeight.bold,
        color: Colors.black,
      ),
    );
  }

  Widget _dateTimeInfo() {
    DateTime now = _weather!.date!;
    return Column(
      children: [
        Text(
          DateFormat("h:mm a").format(now),
          style: const TextStyle(
            fontSize: 35,
            color: Colors.black,
          ),
        ),
        const SizedBox(
          height: 10,
        ),
        Row(
          mainAxisSize: MainAxisSize.max,
          mainAxisAlignment: MainAxisAlignment.center,
          crossAxisAlignment: CrossAxisAlignment.center,
          children: [
            Text(
              DateFormat("EEEE").format(now),
              style: const TextStyle(
                fontWeight: FontWeight.w700,
                color: Colors.black,
              ),
            ),
            Text(
              "  ${DateFormat("d.M.y").format(now)}",
              style: const TextStyle(
                fontWeight: FontWeight.w400,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _weatherIcon() {
    return Column(
      mainAxisSize: MainAxisSize.min,
      mainAxisAlignment: MainAxisAlignment.center,
      crossAxisAlignment: CrossAxisAlignment.center,
      children: [
        Container(
          height: MediaQuery.sizeOf(context).height * 0.20,
          decoration: BoxDecoration(
            image: DecorationImage(
              image: NetworkImage(
                  "http://openweathermap.org/img/wn/${_weather?.weatherIcon}@4x.png"),
            ),
          ),
        ),
        Text(
          _weather?.weatherDescription ?? "",
          style: const TextStyle(
            color: Colors.black,
            fontSize: 20,
          ),
        ),
      ],
    );
  }

  Widget _currentTemp() {
    return Text(
      "${_weather?.temperature?.celsius?.toStringAsFixed(0)}° C",
      style: const TextStyle(
        color: Colors.black,
        fontSize: 90,
        fontWeight: FontWeight.w500,
      ),
    );
  }

  Widget _extraInfo() {
    return Container(
      height: MediaQuery.sizeOf(context).height * 0.15,
      width: MediaQuery.sizeOf(context).width * 0.80,
      decoration: BoxDecoration(
        color: Colors.deepPurple,
        borderRadius: BorderRadius.circular(20),
      ),
      padding: const EdgeInsets.all(16.0),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceEvenly,
        crossAxisAlignment: CrossAxisAlignment.center,
        children: [
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Max: ${_weather?.tempMax?.celsius?.toStringAsFixed(0)}° C",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              Text(
                "Min: ${_weather?.tempMin?.celsius?.toStringAsFixed(0)}° C",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
            ],
          ),
          Row(
            mainAxisSize: MainAxisSize.max,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              Text(
                "Wind: ${_weather?.windSpeed?.toStringAsFixed(0)} m/s",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              ),
              Text(
                "Humidity: ${_weather?.humidity?.toStringAsFixed(0)}%",
                style: const TextStyle(
                  color: Colors.white,
                  fontSize: 15,
                ),
              )
            ],
          )
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      floatingActionButtonLocation: FloatingActionButtonLocation.miniStartTop,
      floatingActionButton: Column(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          FloatingActionButton(
            heroTag: 'fabKerdgy4',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => TranslationScreen()),
              );
            },
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            tooltip: 'ترجمة',
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            child: const Icon(Icons.translate),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'fabKey1',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const WeatherForecastScreen()),
              );
            },
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            tooltip: 'توقعات الطقس',
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            child: const Icon(Icons.sunny),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'fabKey2',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => PrayerTimes()),
              );
            },
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            tooltip: 'مواعيد الصلاة',
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            child: const Icon(Icons.mosque),
          ),
          const SizedBox(height: 10),
          FloatingActionButton(
            heroTag: 'fabKey3',
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => const QiblahScreen()),
              );
            },
            elevation: 0,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(50),
            ),
            tooltip: 'اتجاه القبلة',
            backgroundColor: Colors.deepPurple,
            foregroundColor: Colors.white,
            child: const Icon(Icons.compass_calibration),
          ),
        ],
      ),
      appBar: AppBar(
        title: const Text(
          'Weather App',
          style: TextStyle(
            fontWeight: FontWeight.bold,
          ),
        ),
        actions: [
          IconButton(
            onPressed: () {
              _showCityDropdown();
            },
            icon: const Icon(Icons.location_city_rounded),
          ),
        ],
        foregroundColor: Colors.white,
        centerTitle: true,
        backgroundColor: Colors.deepPurple,
      ),
      body: Column(
        children: [
          Expanded(child: _buildUI()),
        ],
      ),
    );
  }
}

class WeatherForecastScreen extends StatelessWidget {
  const WeatherForecastScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final today = DateTime.now();

    final upcomingWeather = _weatherForecast!
        .where((weather) => weather.date!.difference(today).inDays > 0)
        .toList();

    final uniqueDates = <DateTime>{};
    final uniqueUpcomingWeather = upcomingWeather.where((weather) {
      final dateWithoutTime =
          DateTime(weather.date!.year, weather.date!.month, weather.date!.day);
      return uniqueDates.add(dateWithoutTime);
    }).toList();

    final displayedWeather = uniqueUpcomingWeather.take(5).toList();

    return Scaffold(
      appBar: AppBar(
        title: const Text(
          '5-day forecast',
        ),
      ),
      body: SingleChildScrollView(
        child: Column(
          children: displayedWeather.map((weather) {
            return SizedBox(
              height: 110,
              child: Card(
                color: Colors.white,
                child: Padding(
                  padding: const EdgeInsets.all(8.0),
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.center,
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          Row(
                            children: [
                              Text(
                                DateFormat("EEEE").format(weather.date!),
                                style: const TextStyle(
                                  fontWeight: FontWeight.w700,
                                  color: Colors.black,
                                ),
                              ),
                              Text(
                                "  ${DateFormat("d.M.y").format(weather.date!)}",
                                style: const TextStyle(
                                  fontWeight: FontWeight.w400,
                                  color: Colors.black,
                                ),
                              ),
                            ],
                          ),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.wb_sunny, color: Colors.orange),
                          Text(weather.tempMax.toString()),
                        ],
                      ),
                      Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Icon(Icons.nights_stay, color: Colors.blueGrey),
                          Text(weather.tempMin.toString()),
                        ],
                      ),
                    ],
                  ),
                ),
              ),
            );
          }).toList(),
        ),
      ),
    );
  }
}

class PrayerTimes extends StatefulWidget {
  @override
  _PrayerTimesState createState() => _PrayerTimesState();
}

class _PrayerTimesState extends State<PrayerTimes> {
  Map<String, String>? _prayerTimes;

  @override
  void initState() {
    super.initState();

    fetchPrayerTimes();
  }

  Future<void> fetchPrayerTimes() async {
    setState(() {
      _prayerTimes = null;
    });
    final response = await http.get(
      Uri.parse(
          'http://api.aladhan.com/v1/timingsByCity?city=$_selectedCity&country=Saudi Arabia&method=2'),
    );

    if (response.statusCode == 200) {
      final data = json.decode(response.body);
      setState(() {
        _prayerTimes = {
          'Fajr': data['data']['timings']['Fajr'],
          'Dhuhr': data['data']['timings']['Dhuhr'],
          'Asr': data['data']['timings']['Asr'],
          'Maghrib': data['data']['timings']['Maghrib'],
          'Isha': data['data']['timings']['Isha'],
        };
      });
    } else {
      throw Exception('Failed to load prayer times');
    }
  }

  Widget _buildPrayerTimes() {
    return Column(
      children: _prayerTimes!.entries.map((entry) {
        return Padding(
          padding: const EdgeInsets.all(8.0),
          child: Text(
            '${entry.key}: ${entry.value}',
            style: const TextStyle(fontSize: 18),
          ),
        );
      }).toList(),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Prayer Times'),
      ),
      body: Center(
        child: Column(mainAxisAlignment: MainAxisAlignment.center, children: [
          if (_prayerTimes != null) _buildPrayerTimes(),
          _prayerTimes == null
              ? Center(
                  child: Lottie.asset('assets/lottie/weather_animation.json'),
                )
              : const SizedBox(height: 0, width: 0),
        ]),
      ),
    );
  }
}

class QiblahScreen extends StatefulWidget {
  const QiblahScreen({super.key});

  @override
  State<QiblahScreen> createState() => _QiblahScreenState();
}

class _QiblahScreenState extends State<QiblahScreen>
    with SingleTickerProviderStateMixin {
  Animation<double>? animation;
  double begin = 0.0;

  AnimationController? _animationController;

  @override
  void dispose() {
    _animationController?.dispose();
    super.dispose();
  }

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
        vsync: this, duration: const Duration(milliseconds: 500));
    animation = Tween(begin: 0.0, end: 0.0).animate(_animationController!);
  }

  @override
  Widget build(BuildContext context) {
    bool hasPermission = false;

    Future getPermission() async {
      if (await Permission.location.serviceStatus.isEnabled) {
        var status = await Permission.location.status;
        if (status.isGranted) {
          hasPermission = true;
        } else {
          Permission.location.request().then((value) {
            setState(() {
              hasPermission = (value == PermissionStatus.granted);
            });
          });
        }
      }
    }

    return FutureBuilder(
      builder: (context, snapshot) {
        if (hasPermission) {
          return Scaffold(
            backgroundColor: Colors.black,
            body: StreamBuilder(
              stream: FlutterQiblah.qiblahStream,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Container(
                    alignment: Alignment.center,
                    child: const CircularProgressIndicator(
                      color: Colors.white,
                    ),
                  );
                }

                final qiblahDirection = snapshot.data;
                animation = Tween(
                        begin: begin,
                        end: (qiblahDirection!.qiblah * (pi / 180) * -1))
                    .animate(_animationController!);
                begin = (qiblahDirection.qiblah * (pi / 180) * -1);
                _animationController!.forward(from: 0);

                return Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Text(
                        "${qiblahDirection.direction.toInt()}°",
                        style:
                            const TextStyle(color: Colors.white, fontSize: 24),
                      ),
                      const SizedBox(
                        height: 10,
                      ),
                      SizedBox(
                          height: 300,
                          child: AnimatedBuilder(
                            animation: animation!,
                            builder: (context, child) => Transform.rotate(
                                angle: animation!.value,
                                child: Image.asset('assets/icons/qibla.png')),
                          ))
                    ],
                  ),
                );
              },
            ),
          );
        } else {
          return const Scaffold(
            backgroundColor: Color.fromARGB(255, 48, 48, 48),
          );
        }
      },
      future: getPermission(),
    );
  }
}

class TranslationScreen extends StatefulWidget {
  @override
  _TranslationScreenState createState() => _TranslationScreenState();
}

class _TranslationScreenState extends State<TranslationScreen> {
  final translator = GoogleTranslator();
  final TextEditingController _controller = TextEditingController();
  String _translatedText = '';
  stt.SpeechToText? _speech;
  bool _isListening = false;
  FlutterTts? _flutterTts;

  @override
  void initState() {
    super.initState();
    _speech = stt.SpeechToText();
    _flutterTts = FlutterTts();
  }

  void _translateText() async {
    if (_controller.text.isNotEmpty) {
      var translation =
          await translator.translate(_controller.text, from: 'en', to: 'ar');
      setState(() {
        _translatedText = translation.text;
      });
    }
  }

  void _startListening() async {
    if (!_isListening) {
      bool available = await _speech!.initialize();
      if (available) {
        setState(() => _isListening = true);
        _speech!.listen(
            onResult: (val) => setState(() {
                  _controller.text = val.recognizedWords;
                }));
      }
    } else {
      setState(() => _isListening = false);
      _speech!.stop();
    }
  }

  void _speakTranslation() async {
    await _flutterTts!.setLanguage("ar");
    await _flutterTts!.speak(_translatedText);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Translation'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TranslationSection(
              language: 'English',
              controller: _controller,
            ),
            const SizedBox(height: 20),
            TranslationSection(
              language: 'Arabic',
              translation: _translatedText,
            ),
            const SizedBox(height: 40),
            Row(
              children: [
                FloatingActionButton(
                  heroTag: 'tag1',
                  onPressed: _startListening,
                  child: Icon(_isListening ? Icons.mic : Icons.mic_none),
                ),
                const SizedBox(width: 20),
                FloatingActionButton(
                  heroTag: 'tag2',
                  onPressed: _speakTranslation,
                  child: const Icon(Icons.volume_up),
                ),
              ],
            ),
            const SizedBox(height: 20),
            SizedBox(
              width: double.infinity,
              child: FloatingActionButton(
                backgroundColor: Colors.deepPurple,
                foregroundColor: Colors.white,
                onPressed: _translateText,
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Text(
                      'Translate',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        fontSize: 18,
                      ),
                    ),
                    SizedBox(width: 8),
                    Icon(Icons.translate),
                  ],
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class TranslationSection extends StatelessWidget {
  final String language;
  final String? translation;
  final TextEditingController? controller;

  const TranslationSection({
    super.key,
    required this.language,
    this.controller,
    this.translation,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          language,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
        controller != null
            ? TextFormField(
                controller: controller,
                style: const TextStyle(fontSize: 24),
                decoration: const InputDecoration(
                  border: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.deepPurple),
                  ),
                  enabledBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.deepPurple),
                  ),
                  focusedBorder: OutlineInputBorder(
                    borderSide: BorderSide(color: Colors.deepPurple),
                  ),
                ),
                inputFormatters: [
                  FilteringTextInputFormatter.allow(RegExp(r'[a-zA-Z]')),
                ],
              )
            : SizedBox(
                width: double.infinity,
                child: Text(
                  translation!,
                  style: const TextStyle(fontSize: 20),
                  textAlign: TextAlign.right,
                ),
              ),
      ],
    );
  }
}
