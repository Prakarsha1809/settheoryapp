import 'package:flutter/material.dart';
import 'games/conveyorgame.dart';
import 'games/basketgame.dart';
import 'games/whackgame.dart';
import 'games/universalsetgame.dart';
import 'games/subsetgame.dart';
import 'games/complementspotgame.dart';
import 'games/setbuildergame/subsetsetgame.dart' as setbuildersubset;
import 'games/setbuildergame/disjointsetgame.dart' as setbuilderdisjoint;
import 'games/quiz/symbolquiz.dart';
import 'package:flutter_animate/flutter_animate.dart';

class PlayPage extends StatelessWidget {
  const PlayPage({super.key});

  @override
  Widget build(BuildContext context) {
    final games = [
      {
        'title': 'BASKET CATCHER',
        'image': 'assets/images/basketgame.png',
        'route': const UniversalSetBasketGame(),
        'color': Colors.orange.shade400,
      },
      {
        'title': 'WHACK-A-MOLE',
        'image': 'assets/images/whackgame.png',
        'route': const MinusSetGame(),
        'color': Colors.yellow.shade400,
      },
      {
        'title': 'BELT SORTER',
        'image': 'assets/images/conveyorgame.png',
        'route': const IntersectionSetGame(),
        'color': Colors.green.shade400,
      },
      {
        'title': 'SET BUILDER',
        'image': 'assets/images/setbuildergame.png',
        'route': const setbuildersubset.SubsetSetGame(),
        'color': Colors.blue.shade400,
      },
      {
        'title': 'SYMBOL QUIZ',
        'image': 'assets/images/quizgame.png',
        'route': const SymbolQuiz(),
        'color': Colors.red.shade400,
      },
    ];

    return Scaffold(
      appBar: AppBar(
        title: const Text('GAMES'),
        backgroundColor: const Color(0xFF8dd0f0),
      ),
      backgroundColor: Colors.white,
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(12.0),
            child: Image.asset(
              'assets/images/play.png',
              fit: BoxFit.cover,
              width: 400,
              height: 200,
            ),
          ),
          const SizedBox(height: 10),
          Expanded(
            child: Center(
              child: GridView.count(
                padding: const EdgeInsets.all(20),
                crossAxisCount: 3,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                children: games.map((game) {
                  return GestureDetector(
                    onTap: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => game['route'] as Widget),
                      );
                    },
                    child: MouseRegion(
                      cursor: SystemMouseCursors.click,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 300),
                        decoration: BoxDecoration(
                          color: game['color'] as Color,
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black26,
                              blurRadius: 8,
                              offset: const Offset(2, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Image.asset(
                              game['image'] as String,
                              width: 140,
                              height: 140,
                            ).animate().scale(duration: 500.ms, curve: Curves.easeInOut),
                            const SizedBox(height: 12),
                            Text(
                              game['title'] as String,
                              style: const TextStyle(
                                fontSize: 24,
                                fontWeight: FontWeight.bold,
                                color: Colors.black,
                              ),
                              textAlign: TextAlign.center,
                            ).animate().fadeIn(duration: 400.ms),
                          ],
                        ),
                      ).animate().moveY(begin: 40, duration: 500.ms, curve: Curves.easeOut),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
        ],
      ),
    );
  }
}

void main() {
  runApp(const MaterialApp(
    home: PlayPage(),
  ));
}
