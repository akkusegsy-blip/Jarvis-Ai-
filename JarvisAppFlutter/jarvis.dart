import 'dart:async';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';
import 'package:speech_to_text/speech_to_text.dart' as stt;
import 'package:flutter_tts/flutter_tts.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:android_intent_plus/android_intent.dart';
import 'package:android_intent_plus/flag.dart';
import 'package:intl/intl.dart';
import 'package:audioplayers/audioplayers.dart';

void main() {
  runApp(JarvisApp());
}

class JarvisApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: SplashScreen(),
    );
  }
}

class SplashScreen extends StatefulWidget {
  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {
  late AnimationController _fadeController;
  late Animation<double> _fadeAnimation;
  final AudioPlayer _audioPlayer = AudioPlayer();

  @override
  void initState() {
    super.initState();
    _fadeController = AnimationController(
      duration: Duration(seconds: 3),
      vsync: this,
    );
    _fadeAnimation =
        Tween<double>(begin: 0.0, end: 1.0).animate(_fadeController);
    _fadeController.forward();

    _playStartupSound();

    Timer(Duration(seconds: 5), () {
      Navigator.pushReplacement(
          context, MaterialPageRoute(builder: (context) => JarvisScreen()));
    });
  }

  Future<void> _playStartupSound() async {
    try {
      await _audioPlayer.play(AssetSource('sounds/startup.mp3'));
    } catch (e) {
      print('Error playing startup sound: $e');
    }
  }

  @override
  void dispose() {
    _fadeController.dispose();
    _audioPlayer.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.black,
      body: Stack(
        children: [
          Positioned.fill(
            child: CustomPaint(
              painter: CircuitPatternPainter(),
            ),
          ),
          Center(
            child: FadeTransition(
              opacity: _fadeAnimation,
              child: Container(
                decoration: BoxDecoration(
                  gradient: RadialGradient(
                    colors: [
                      Colors.blue.withOpacity(0.3),
                      Colors.transparent,
                    ],
                    radius: 1.2,
                  ),
                ),
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  children: [
                    Text(
                      'J.A.R.V.I.S',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 52,
                        fontWeight: FontWeight.bold,
                        letterSpacing: 4,
                        shadows: [
                          Shadow(
                            color: Colors.blue.withOpacity(0.9),
                            blurRadius: 20,
                            offset: Offset(0, 0),
                          ),
                          Shadow(
                            color: Colors.white.withOpacity(0.5),
                            blurRadius: 30,
                            offset: Offset(0, 0),
                          ),
                        ],
                      ),
                    ),
                    SizedBox(height: 25),
                    Container(
                      width: 180,
                      height: 180,
                      decoration: BoxDecoration(
                        shape: BoxShape.circle,
                        gradient: RadialGradient(
                          colors: [
                            Colors.blue.withOpacity(0.4),
                            Colors.blue.withOpacity(0.2),
                            Colors.transparent,
                          ],
                        ),
                        boxShadow: [
                          BoxShadow(
                            color: Colors.blue.withOpacity(0.4),
                            blurRadius: 30,
                            spreadRadius: 8,
                          ),
                        ],
                      ),
                      child: Center(
                        child: Icon(
                          Icons.power_settings_new,
                          size: 70,
                          color: Colors.blue.withOpacity(0.9),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class CircuitPatternPainter extends CustomPainter {
  final bool isIdleState;

  CircuitPatternPainter({this.isIdleState = true});

  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..color = Colors.blue.withOpacity(0.2)
      ..strokeWidth = 1.5
      ..style = PaintingStyle.stroke;

    final random = Random();
    final numberOfLines = 120;
    final numberOfNodes = 25;

    final seedRandom = isIdleState ? Random(DateTime.now().millisecondsSinceEpoch ~/ (isIdleState ? 10000 : 1000)) : random;

    final nodes = List.generate(numberOfNodes, (index) {
      return Offset(
        seedRandom.nextDouble() * size.width,
        seedRandom.nextDouble() * size.height,
      );
    });

    for (var i = 0; i < nodes.length; i++) {
      for (var j = i + 1; j < nodes.length; j++) {
        if (seedRandom.nextDouble() < 0.35) {
          final path = Path();
          path.moveTo(nodes[i].dx, nodes[i].dy);
          path.lineTo(nodes[j].dx, nodes[j].dy);
          canvas.drawPath(path, paint);
        }
      }
    }

    for (var i = 0; i < numberOfLines; i++) {
      final startX = seedRandom.nextDouble() * size.width;
      final startY = seedRandom.nextDouble() * size.height;
      final path = Path();
      path.moveTo(startX, startY);

      var currentX = startX;
      var currentY = startY;
      var segments = seedRandom.nextInt(5) + 3; 

      for (var j = 0; j < segments; j++) {
        if (seedRandom.nextBool()) {
          currentX +=
              seedRandom.nextDouble() * 150 - 75; 
        } else {
          currentY += seedRandom.nextDouble() * 150 - 75;
        }
        path.lineTo(currentX, currentY);
      }

      if (seedRandom.nextDouble() < 0.3) {
        final controlPoint = Offset(
          (startX + currentX) / 2 + seedRandom.nextDouble() * 50 - 25,
          (startY + currentY) / 2 + seedRandom.nextDouble() * 50 - 25,
        );
        path.quadraticBezierTo(
          controlPoint.dx,
          controlPoint.dy,
          currentX,
          currentY,
        );
      }

      canvas.drawPath(path, paint);
    }

    final dotPaint = Paint()
      ..color = Colors.blue.withOpacity(0.5)
      ..style = PaintingStyle.fill;

    for (var node in nodes) {
      canvas.drawCircle(node, 3, dotPaint);
    }
  }

  @override
  bool shouldRepaint(CustomPainter oldDelegate) =>
      true; 
}

class JarvisScreen extends StatefulWidget {
  @override
  _JarvisScreenState createState() => _JarvisScreenState();
}

class _JarvisScreenState extends State<JarvisScreen>
    with SingleTickerProviderStateMixin {
  final String apiKey = "get your api";

  late GenerativeModel model;
  late stt.SpeechToText speech;
  late FlutterTts flutterTts;
  bool isListening = false;
  bool isSpeaking = false;
  String responseText = "";
  List<Content> conversationHistory = [];
  late AnimationController _animationController;
  late Animation<double> _bounceAnimation;
  Timer? _timer;
  int? _remainingSeconds;
  bool _isTimerActive = false;
  bool _isWakeWordDetected = false;
  Timer? _wakeWordTimer;
  final AudioPlayer _audioPlayer = AudioPlayer();
  bool _isBackgroundListening = false;
  bool _isInConversationMode =
      false; 

  late AnimationController _colorAnimationController;
  late Animation<Color?> _colorAnimation;
  int _currentColorIndex = 0;
  final List<Color> _ironManColors = [
    Colors.red,
    Colors.blue,
    Color(0xFF00B8D4), // greenish blue (cyan)
    Color(0xFFE91E63), // reddish blue (pink)
    Color(0xFFFFA000), // amber (gold)
  ];

  Timer? _backgroundAnimationTimer;
  int _backgroundAnimationCounter = 0;

  @override
  void initState() {
    super.initState();
    model = GenerativeModel(model: 'put-exact-model-name-here', apiKey: apiKey);
    speech = stt.SpeechToText();
    flutterTts = FlutterTts();

    flutterTts.setLanguage("en-au");
    flutterTts.setPitch(0.8);
    flutterTts.setSpeechRate(0.6);
    flutterTts.awaitSpeakCompletion(true);
    flutterTts.setEngine("com.google.android.tts");

    flutterTts.setCompletionHandler(() {
      setState(() {
        isSpeaking = false;

        if (_isInConversationMode) {
          _continueConversation();
        }
      });
    });

    flutterTts.getVoices.then((voices) {
      if (voices.isNotEmpty) {
        flutterTts.setVoice(voices[0]);
      }
    });

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    )..repeat(reverse: true);
    _bounceAnimation = Tween<double>(begin: 0.95, end: 1.05).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeInOut),
    );

    _colorAnimationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 2000),
    );

    _setupColorAnimation();

    _colorAnimationController.forward();
    _colorAnimationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _currentColorIndex = (_currentColorIndex + 1) % _ironManColors.length;
        _setupColorAnimation();
        _colorAnimationController.reset();
        _colorAnimationController.forward();
      }
    });

    _startWakeWordDetection();

    _wakeWordTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      if (_isBackgroundListening &&
          !speech.isListening &&
          !_isWakeWordDetected &&
          !isSpeaking &&
          !_isInConversationMode) {
        print("Wake word detection not active, restarting...");
        _startWakeWordDetection();
      }
    });

    _startBackgroundAnimationTimer();
  }

  void _startBackgroundAnimationTimer() {
    _backgroundAnimationTimer = Timer.periodic(Duration(seconds: 5), (timer) {
      if (!_isWakeWordDetected && !isSpeaking && !_isInConversationMode) {
        setState(() {
          _backgroundAnimationCounter++;
        });
      }
    });
  }

  void _setupColorAnimation() {
    final nextColorIndex = (_currentColorIndex + 1) % _ironManColors.length;
    _colorAnimation = ColorTween(
      begin: _ironManColors[_currentColorIndex],
      end: _ironManColors[nextColorIndex],
    ).animate(_colorAnimationController);
  }

  void _startWakeWordDetection() async {
    bool available = await speech.initialize();
    if (available) {
      setState(() => _isBackgroundListening = true);

      speech.statusListener = (status) {
        if (status == stt.SpeechToText.doneStatus ||
            status == stt.SpeechToText.notListeningStatus) {
          if (_isBackgroundListening &&
              !_isWakeWordDetected &&
              !_isInConversationMode) {
            Future.delayed(Duration(milliseconds: 300), () {
              if (mounted &&
                  _isBackgroundListening &&
                  !_isWakeWordDetected &&
                  !_isInConversationMode) {
                print("Restarting wake word detection...");
                _startListeningForWakeWord();
              }
            });
          }
        }
      };

      _startListeningForWakeWord();
    } else {
      print("Speech recognition not available");

      Future.delayed(Duration(seconds: 3), _startWakeWordDetection);
    }
  }

  void _startListeningForWakeWord() {
    if (!speech.isListening && mounted && !_isInConversationMode) {
      try {
        speech.listen(
          onResult: (result) {
            if (result.finalResult) {
              String userInput = result.recognizedWords.toLowerCase();
              print("Heard: $userInput");
              if (userInput.contains('jarvis') ||
                  userInput.contains('hey jarvis')) {
                setState(() => _isWakeWordDetected = true);
                _playWakeSound();

                _startConversationMode();
              }
            }
          },
          listenFor: Duration(minutes: 10), 
          pauseFor: Duration(seconds: 10), 
          partialResults: true,
          listenMode: stt.ListenMode.deviceDefault,
          cancelOnError: false,
          onSoundLevelChange: (level) {},
        );
      } catch (e) {
        print("Error starting speech recognition: $e");

        Future.delayed(Duration(seconds: 2), () {
          if (mounted && _isBackgroundListening && !_isInConversationMode) {
            _startListeningForWakeWord();
          }
        });
      }
    }
  }

  void _startConversationMode() {
    speech.stop();

    setState(() {
      _isInConversationMode = true;
      _isWakeWordDetected = true;
    });

    speak("I'm listening, sir. How can I assist you?");
  }

  void _continueConversation() {
    if (!mounted || !_isInConversationMode) return;

    print("Continuing conversation...");

    if (!speech.isListening) {
      try {
        speech.listen(
          onResult: (result) async {
            if (result.finalResult) {
              String userInput = result.recognizedWords.toLowerCase();
              print("Conversation heard: $userInput");

              if (userInput.contains("end conversation") ||
                  userInput.contains("goodbye") ||
                  userInput.contains("bye") ||
                  userInput.contains("that's all") ||
                  userInput.contains("exit conversation")) {
                _endConversationMode();
                speak(
                    "Ending conversation mode. Just say 'Hey Jarvis' when you need me again.");
                return;
              }

              processQuery(userInput);
            }
          },
          listenFor: Duration(minutes: 10),
          pauseFor: Duration(seconds: 10),
          partialResults: true,
          listenMode: stt.ListenMode.deviceDefault,
          cancelOnError: false,
          onSoundLevelChange: (level) {},
        );

        speech.statusListener = (status) {
          if ((status == stt.SpeechToText.doneStatus ||
                  status == stt.SpeechToText.notListeningStatus) &&
              _isInConversationMode &&
              !isSpeaking) {
            Future.delayed(Duration(milliseconds: 300), () {
              if (mounted &&
                  _isInConversationMode &&
                  !isSpeaking &&
                  !speech.isListening) {
                print("Restarting conversation listening...");
                _continueConversation();
              }
            });
          }
        };
      } catch (e) {
        print("Error in conversation listening: $e");

        Future.delayed(Duration(seconds: 1), () {
          if (mounted && _isInConversationMode) {
            _continueConversation();
          }
        });
      }
    }
  }

  void _endConversationMode() {
    setState(() {
      _isInConversationMode = false;
      _isWakeWordDetected = false;
    });

    if (_isBackgroundListening) {
      _startWakeWordDetection();
    }
  }

  void _processWakeWordCommand() {
    speech.stop();

    speech.listen(
      onResult: (result) async {
        if (result.finalResult) {
          String userInput = result.recognizedWords.toLowerCase();
          print("Command heard: $userInput");
          processQuery(userInput);
          setState(() => _isWakeWordDetected = false);

          Future.delayed(Duration(milliseconds: 500), () {
            if (mounted && _isBackgroundListening) {
              _startWakeWordDetection();
            }
          });
        }
      },
      listenFor: Duration(minutes: 10), 
      pauseFor: Duration(seconds: 10), 
      partialResults: true,
      listenMode: stt.ListenMode.deviceDefault,
      cancelOnError: false,
    );
  }

  void processQuery(String query) async {
    try {
      if (query.isEmpty || query.trim().isEmpty) {
        if (_isInConversationMode) {
          _continueConversation();
        }
        return;
      }

      if (query.contains("weather")) {
        _searchWeather();
        return;
      } else if (query.contains("time")) {
        _tellTime();
        return;
      } else if (query.contains("open")) {
        _openApp(query);
        return;
      } else if (query.contains("set timer")) {
        _handleTimerCommand(query);
        return;
      } else if (query.contains("set alarm")) {
        _handleAlarmCommand(query);
        return;
      }
      final chat = model.startChat(history: conversationHistory);
      conversationHistory.add(Content.text(query));

      String initialInstruction = '''
      From now onwards, talk like Jarvis from Iron Man.
      If asked what your name is, just say that you're Jarvis and if they ask who made you just tell that you were made by Tony Stark.
      Talk like JARVIS AI made by Tony Stark in IRON MAN.
      Ask the user for their name and then respond accordingly.
      Keep your responses fairly concise since they'll be spoken aloud.
      ''';

      await chat.sendMessage(Content.text(initialInstruction));
      final response = await chat.sendMessage(Content.text(query));
      conversationHistory.add(Content.text(response.text ?? "No response"));

      setState(() => responseText = "");
      speak(response.text ?? "I didn't get that.");
    } catch (e) {
      setState(() => responseText = "");
      speak("Sorry, something went wrong.");
    }
  }

  void _searchWeather() async {
    final Uri url = Uri.parse("https://www.google.com/search?q=weather+today");
    try {
      await launchUrl(url, mode: LaunchMode.externalApplication);
    } catch (e) {
      speak(
          "I couldn't open the browser. Please check your internet connection.");
    }
  }

  void _tellTime() {
    String time = DateFormat.jm().format(DateTime.now());
    speak("The current time is $time");
  }

  void _openApp(String query) async {
    Map<String, String> appMap = {
      "chrome": "com.android.chrome",
      "whatsapp": "com.whatsapp",
      "camera": "com.android.camera",
      "gallery": "com.android.gallery3d",
      "photos": "com.google.android.apps.photos",
      "youtube": "com.google.android.youtube",
      "maps": "com.google.android.apps.maps",
      "gmail": "com.google.android.gm",
      "settings": "com.android.settings",
      "play store": "com.android.vending",
      "calculator": "com.android.calculator2",
      "calendar": "com.google.android.calendar",
      "clock": "com.android.deskclock",
      "contacts": "com.android.contacts",
      "phone": "com.android.dialer",
      "messages": "com.android.mms",
      "file manager": "com.android.documentsui",
      "files": "com.android.documentsui",
      "music": "com.android.music",
      "sound recorder": "com.android.soundrecorder",
      "notes": "com.android.notes",
      "notepad": "com.android.notes",
      "browser": "com.android.chrome",
      "internet": "com.android.chrome",
      "email": "com.google.android.gm",
      "mail": "com.google.android.gm",
      "camera app": "com.android.camera",
      "gallery app": "com.android.gallery3d",
      "photos app": "com.google.android.apps.photos",
      "youtube app": "com.google.android.youtube",
      "maps app": "com.google.android.apps.maps",
      "gmail app": "com.google.android.gm",
      "settings app": "com.android.settings",
      "play store app": "com.android.vending",
      "calculator app": "com.android.calculator2",
     
