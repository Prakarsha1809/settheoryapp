import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'quizquestions.dart';
import 'dart:math';

class SymbolQuiz extends StatefulWidget {
  const SymbolQuiz({super.key});

  @override
  _QuizPageState createState() => _QuizPageState();
}

class _QuizPageState extends State<SymbolQuiz> {
  final FlutterTts tts = FlutterTts();
  int currentQuestionIndex = 0;
  String? selectedAnswer;
  bool showSolution = false;
  int score = 0;
  int highScore = 0;
  late List<Map<String, dynamic>> shuffledQuestions;

  @override
  void initState() {
    super.initState();
    loadHighScore();
    shuffledQuestions = List<Map<String, dynamic>>.from(questions);
    shuffledQuestions.shuffle(Random());
    for (var q in shuffledQuestions) {
      if (q['options'] is List) {
        q['options'].shuffle(Random());
      }
    }
  }

  Future<void> loadHighScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    setState(() {
      highScore = prefs.getInt('symbol_quiz_high_score') ?? 0;
    });
  }

  Future<void> saveHighScore() async {
    SharedPreferences prefs = await SharedPreferences.getInstance();
    if (score > highScore) {
      await prefs.setInt('symbol_quiz_high_score', score);
      setState(() {
        highScore = score;
      });
    }
  }

  void speak(String text) async {
    await tts.setLanguage('en-US');
    await tts.setSpeechRate(0.4);
    await tts.speak(text);
  }

  @override
  Widget build(BuildContext context) {
    final currentQuestion = shuffledQuestions[currentQuestionIndex];
    final bool soundOnly = currentQuestion['soundOptions'] == true;
    final bool isCorrect = selectedAnswer == currentQuestion['answer'];

    return Scaffold(
      backgroundColor: const Color(0xFFf0f8ff),
      appBar: AppBar(
        title: const Text("PRACTICE"),
        backgroundColor: Colors.lightGreen.shade400,
      ),
      body: Stack(
        children: [
          SingleChildScrollView(
            child: Column(
              children: [
                Container(
                  padding: const EdgeInsets.all(16.0),
                  child: Image.asset('assets/images/quizicon.png', width: 100, height: 150),
                ),
                Text(
                  "Score: $score",
                  style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold, color: Colors.teal),
                ),
                Text(
                  "Highest: $highScore",
                  style: const TextStyle(fontSize: 22, fontWeight: FontWeight.bold, color: Colors.orange),
                ),
                const SizedBox(height: 10),
                Container(
                  padding: const EdgeInsets.all(16.0),
                  color: Colors.grey[300],
                  child: Center(
                    child: Text(
                      currentQuestion['question'],
                      textAlign: TextAlign.center,
                      style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 16.0),
                  child: Column(
                    children: List.generate(currentQuestion['options'].length, (index) {
                      final option = currentQuestion['options'][index];
                      final isSelected = selectedAnswer == option;
                      final showCorrectness = showSolution && (isSelected || option == currentQuestion['answer']);
                      Color? tileColor;
                      if (showCorrectness) {
                        tileColor = (option == currentQuestion['answer']) ? Colors.green[100] : Colors.red[100];
                      }
                      return Container(
                        width: double.infinity,
                        margin: const EdgeInsets.only(bottom: 10),
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: tileColor ?? (isSelected ? Colors.grey[400] : Colors.grey[300]),
                          borderRadius: BorderRadius.circular(10),
                          border: Border.all(color: Colors.black),
                        ),
                        child: InkWell(
                          onTap: !showSolution
                              ? () {
                            setState(() {
                              selectedAnswer = option;
                              showSolution = true;
                              if (selectedAnswer == currentQuestion['answer']) {
                                score++;
                              }
                            });
                          }
                              : null,
                          child: Center(
                            child: soundOnly
                                ? IconButton(
                              icon: const Icon(Icons.volume_up),
                              onPressed: () => speak(option),
                            )
                                : Text(
                              option,
                              style: const TextStyle(fontSize: 18),
                              textAlign: TextAlign.center,
                            ),
                          ),
                        ),
                      );
                    }),
                  ),
                ),
                const SizedBox(height: 20),
                if (showSolution)
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 16.0),
                    child: Text(
                      isCorrect ? '✅ Correct!' : '❌ Wrong. ${currentQuestion['solution']}',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                        color: isCorrect ? Colors.green : Colors.red,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ),
                const SizedBox(height: 20),
                Padding(
                  padding: const EdgeInsets.symmetric(horizontal: 20.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      Expanded(
                        child: ElevatedButton(
                          onPressed: () async {
                            await saveHighScore();
                            Navigator.pop(context);
                          },
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.red[300],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "End Quiz",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                      const SizedBox(width: 20),
                      Expanded(
                        child: ElevatedButton(
                          onPressed: showSolution
                              ? () async {
                            if (currentQuestionIndex < shuffledQuestions.length - 1) {
                              setState(() {
                                currentQuestionIndex++;
                                selectedAnswer = null;
                                showSolution = false;
                              });
                            } else {
                              await saveHighScore();
                              showDialog(
                                context: context,
                                builder: (context) => AlertDialog(
                                  title: const Text('Practice Completed'),
                                  content: Text('You scored $score out of ${shuffledQuestions.length}.'),
                                  actions: [
                                    TextButton(
                                      onPressed: () => Navigator.of(context).pop(),
                                      child: const Text('OK'),
                                    )
                                  ],
                                ),
                              );
                            }
                          }
                              : null,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.green[300],
                            padding: const EdgeInsets.symmetric(vertical: 16),
                            shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(30),
                            ),
                          ),
                          child: const Text(
                            "Next",
                            style: TextStyle(fontSize: 20),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 20),
              ],
            ),
          ),
          Positioned(
            bottom: 0,
            right: 0,
            child: Image.asset(
              'assets/images/teacher.png',
              width: 250,
              height: 250,
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Quiz App',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const SymbolQuiz(),
    );
  }
}
