import 'package:flutter/material.dart';
import 'package:settheoryapp/quiz.dart';
import 'theory.dart';
import 'solve.dart';
import 'translate.dart';
import 'example.dart';
import 'quiz.dart';
import 'translateempty.dart';
import 'games/universalsetgame.dart';

class EmptyPage extends StatelessWidget {
  const EmptyPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("STUDY"),
        backgroundColor: const Color(0xFF8dd0f0), // Light blue background color
      ),
      // Wrap SingleChildScrollView inside a Container
      body: Container(
        color: const Color(0xFF8dd0f0), // Light yellow background color
        child: SingleChildScrollView(
          child: Column(
            children: [
              const Padding(
                padding: EdgeInsets.symmetric(vertical: 16.0),
                child: Text(
                  "WHAT IS EMPTY SET?",
                  style: TextStyle(
                    fontSize: 82,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
                child: Container(
                  color: Colors.grey[300],
                  height: 200,
                  child: Center(
                    child: Icon(
                      Icons.play_circle_outline,
                      color: Colors.red,
                      size: 100,
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Text(
                  "An empty set is a set that has no elements in it. It's like an empty box with nothing inside.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 42,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildImageWithDescription('assets/images/empty1.png', 'Empty Box'),
                    const SizedBox(width: 20),
                    _buildImageWithDescription('assets/images/empty2.png', 'Empty Container'),
                  ],
                ),
              ),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Text(
                  "We call it Empty set, Null set. We usually write it as ∅ or {}.",
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontSize: 42,
                    color: Colors.black,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                  children: [
                    _buildImageWithDescription('assets/images/nullset1.png', 'empty set/Null set'),
                    const SizedBox(width: 20),
                    _buildImageWithDescription('assets/images/nullset.png', 'empty set/Null set'),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              const Padding(
                padding: EdgeInsets.symmetric(horizontal: 16.0, vertical: 16.0),
                child: Column(
                  children: [
                    Text(
                      "In simple terms, an empty set is a set that doesn't have anything in it",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "A set of Living Dinosaurus: {}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "A set of Numbers Divisible by 0: {}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.black,
                      ),
                    ),
                    SizedBox(height: 10),
                    Text(
                      "A set Prime numbers divsible by 10: {}",
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 30,
                        color: Colors.black,
                      ),
                    ),
                  ],
                ),
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  _buildCustomButton(context, 'EXAMPLE', 'assets/images/example.png', const UniversalSetGamePage()),
                  _buildCustomButton(context, 'TRANSLATE', 'assets/images/translate.png', const TranslateEmptyPage()),
                  _buildCustomButtonWithImage(context, 'PRACTICE', 'assets/images/solveicon.png', const QuizPage()),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildCustomButton(BuildContext context, String title, String imagePath, Widget page) {
    return Container(
      width: 250,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.yellow[700],
        borderRadius: BorderRadius.circular(50),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              title,
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildCustomButtonWithImage(BuildContext context, String title, String imagePath, Widget page) {
    return Container(
      width: 300,
      height: 100,
      decoration: BoxDecoration(
        color: Colors.yellow[700],
        borderRadius: BorderRadius.circular(50),
      ),
      child: ElevatedButton(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.transparent,
          shadowColor: Colors.transparent,
        ),
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (context) => page),
          );
        },
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              imagePath,
              width: 100,
              height: 100,
            ),
            const SizedBox(width: 10),
            Text(
              title,
              style: const TextStyle(
                fontSize: 24,
                fontWeight: FontWeight.bold,
                color: Colors.black,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildImageWithDescription(String imagePath, String description) {
    return Column(
      children: [
        Image.asset(
          imagePath,
          width: 150,
          height: 150,
          fit: BoxFit.cover,
        ),
        const SizedBox(height: 10),
        Text(
          description,
          style: const TextStyle(
            fontSize: 16,
            fontWeight: FontWeight.bold,
          ),
        ),
      ],
    );
  }
}