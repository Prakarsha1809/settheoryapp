import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';
import 'dart:math';

class MinusSetGame extends StatefulWidget {
  const MinusSetGame({Key? key}) : super(key: key);

  @override
  State<MinusSetGame> createState() => _MinusSetGameState();
}

class GameItem {
  final String name;
  final String imagePath;
  final bool inMinusSet;

  GameItem(this.name, this.imagePath, this.inMinusSet);
}

class _MinusSetGameState extends State<MinusSetGame> with TickerProviderStateMixin {
  final List<GameItem> setA = [
    GameItem('Apple', 'assets/images/apple2.png', true),
    GameItem('Banana', 'assets/images/banana.png', false),
  ];

  final List<GameItem> setB = [
    GameItem('Banana', 'assets/images/banana.png', false),
    GameItem('Strawberry', 'assets/images/strawberry2.png', false),
  ];

  final List<GameItem> allItems = [
    GameItem('Apple', 'assets/images/apple2.png', true),
    GameItem('Banana', 'assets/images/banana.png', false),
    GameItem('Strawberry', 'assets/images/strawberry2.png', false),
    GameItem('Car', 'assets/images/car.png', false),
    GameItem('Cat', 'assets/images/cat.png', false),
  ];

  final List<Map<String, dynamic>> gridTiles = List.generate(6, (index) => {});
  final List<GameItem> whackedItems = [];
  final Random random = Random();
  late Timer spawnTimer;
  final FlutterTts flutterTts = FlutterTts();
  bool showHint = false;
  bool showTick = false;

  @override
  void initState() {
    super.initState();
    flutterTts.setSpeechRate(0.3);
    spawnTimer = Timer.periodic(const Duration(seconds: 2), (_) => spawnItem());
  }

  void spawnItem() {
    int index = random.nextInt(6);
    final item = allItems[random.nextInt(allItems.length)];
    setState(() {
      gridTiles[index] = {
        "item": item,
        "controller": AnimationController(
          duration: const Duration(milliseconds: 300),
          vsync: this,
        )..forward(),
        "wrong": null,
      };
    });
    Timer(const Duration(seconds: 4), () {
      setState(() {
        if (gridTiles[index]["wrong"] == null) {
          gridTiles[index]["controller"].reverse().then((_) {
            setState(() => gridTiles[index] = {});
          });
        }
      });
    });
  }

  void handleWhack(GameItem item, int index) {
    setState(() {
      final isCorrect = item.inMinusSet;
      if (isCorrect) {
        if (!whackedItems.contains(item)) {
          whackedItems.add(item);
        }
        if (whackedItems.length == setA.where((i) => i.inMinusSet).length) {
          showTick = true;
          spawnTimer.cancel();
        }
        gridTiles[index]["controller"].reverse().then((_) => setState(() => gridTiles[index] = {}));
      } else {
        gridTiles[index]["wrong"] = true;
        Future.delayed(const Duration(seconds: 1), () {
          gridTiles[index]["controller"].reverse().then((_) => setState(() => gridTiles[index] = {}));
        });
      }
    });
  }

  void speakMinus() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.speak("Set A minus Set B");
  }

  @override
  void dispose() {
    spawnTimer.cancel();
    for (var tile in gridTiles) {
      tile["controller"]?.dispose();
    }
    flutterTts.stop();
    super.dispose();
  }

  Widget buildSetDisplay(String label, List<GameItem> set) {
    return Row(
      children: [
        Text('$label { ', style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
        ...set.map((e) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Image.asset(e.imagePath, width: 50, height: 50),
        )),
        const Text(' }', style: TextStyle(fontSize: 20)),
      ],
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf0f8ff),
      appBar: AppBar(
        title: const Text('WHACK-A-MOLE'),
        backgroundColor: Colors.orange.shade400,
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              buildSetDisplay('Set A', setA),
              Tooltip(
                message: 'Menos (Spanish for Minus)',
                child: const Text(' − ', style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              buildSetDisplay('Set B', setB),
              Tooltip(
                message: 'Speak',
                child: IconButton(
                  icon: const Icon(Icons.volume_up),
                  onPressed: speakMinus,
                ),
              ),
              Tooltip(
                message: 'Hint',
                child: IconButton(
                  icon: const Icon(Icons.lightbulb_outline),
                  onPressed: () => setState(() => showHint = true),
                ),
              ),
              if (showTick)
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(Icons.check_circle, color: Colors.green, size: 30),
                ),
            ],
          ),
          const SizedBox(height: 10),
          const Text(
            'Whack the moles that belong to Set A − Set B',
            style: TextStyle(fontSize: 20, fontWeight: FontWeight.w500),
          ),
          if (showHint)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text('Golpea los topos que pertenecen a A menos B',
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
            ),
          const SizedBox(height: 16),
          Expanded(
            child: GridView.count(
              crossAxisCount: 3,
              crossAxisSpacing: 20,
              mainAxisSpacing: 20,
              padding: const EdgeInsets.all(16),
              children: List.generate(6, (index) {
                final tile = gridTiles[index];
                final GameItem? item = tile["item"];
                final bool? isWrong = tile["wrong"];
                final AnimationController? controller = tile["controller"];

                return GestureDetector(
                  onTap: item != null ? () => handleWhack(item, index) : null,
                  child: Container(
                    decoration: BoxDecoration(
                      color: Colors.brown[300],
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(color: Colors.black26),
                    ),
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        const Icon(Icons.circle, size: 50, color: Colors.black54),
                        if (item != null && controller != null)
                          AnimatedBuilder(
                            animation: controller,
                            builder: (context, child) {
                              final offsetY = 50 * (1 - controller.value);
                              return Transform.translate(
                                offset: Offset(0, offsetY),
                                child: Column(
                                  mainAxisSize: MainAxisSize.min,
                                  children: [
                                    Image.asset(item.imagePath, width: 70, height: 70),
                                    Image.asset('assets/images/mole_character.png', width: 50, height: 50),
                                    if (isWrong == true)
                                      const Text('❌', style: TextStyle(color: Colors.red, fontSize: 22)),
                                    if (isWrong == false)
                                      const Icon(Icons.check, color: Colors.green, size: 24),
                                  ],
                                ),
                              );
                            },
                          ),
                      ],
                    ),
                  ),
                );
              }),
            ),
          ),
          const Text('Correct Answers:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
          Wrap(
            spacing: 8,
            children: whackedItems
                .map((item) => Image.asset(item.imagePath, width: 50, height: 50))
                .toList(),
          ),
          const SizedBox(height: 20),
        ],
      ),
    );
  }
}