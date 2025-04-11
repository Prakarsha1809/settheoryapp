import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';
import 'dart:math';

class IntersectionSetGame extends StatefulWidget {
  const IntersectionSetGame({Key? key}) : super(key: key);

  @override
  State<IntersectionSetGame> createState() => _IntersectionSetGameState();
}

class GameItem {
  final String name;
  final String imagePath;
  final bool inIntersection;

  GameItem(this.name, this.imagePath, this.inIntersection);
}

class _IntersectionSetGameState extends State<IntersectionSetGame> {
  final List<GameItem> setA = [
    GameItem('Apple', 'assets/images/apple2.png', true),
    GameItem('Banana', 'assets/images/banana.png', false),
  ];

  final List<GameItem> setB = [
    GameItem('Apple', 'assets/images/apple2.png', true),
    GameItem('Strawberry', 'assets/images/strawberry2.png', false),
  ];

  final List<GameItem> allItems = [
    GameItem('Apple', 'assets/images/apple2.png', true),
    GameItem('Banana', 'assets/images/banana.png', false),
    GameItem('Strawberry', 'assets/images/strawberry2.png', false),
    GameItem('Car', 'assets/images/car.png', false),
    GameItem('Cat', 'assets/images/cat.png', false),
  ];

  final List<GameItem> beltItems = [];
  final List<Map<String, dynamic>> zoneItems = [];
  late Timer beltTimer;
  final FlutterTts flutterTts = FlutterTts();
  bool showCompletionTick = false;
  bool showHint = false;

  @override
  void initState() {
    super.initState();
    flutterTts.setSpeechRate(0.3);
    startConveyor();
  }

  void startConveyor() {
    beltItems.addAll(List.generate(15, (_) => allItems[Random().nextInt(allItems.length)]));
    beltTimer = Timer.periodic(const Duration(seconds: 1), (_) {
      setState(() {
        beltItems.removeAt(0);
        beltItems.add(allItems[Random().nextInt(allItems.length)]);
      });
    });
  }

  @override
  void dispose() {
    beltTimer.cancel();
    flutterTts.stop();
    super.dispose();
  }

  void speakIntersection() async {
    await flutterTts.setLanguage("en-US");
    await flutterTts.speak("Set A intersection Set B");
  }

  Widget buildSetDisplay(String label, List<GameItem> set) {
    return Row(
      children: [
        Text('$label { ', style: const TextStyle(fontWeight: FontWeight.bold)),
        ...set.map((e) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Image.asset(e.imagePath, width: 40, height: 40),
        )),
        const Text(' }'),
      ],
    );
  }

  void checkCompletion() {
    final correctAnswers = allItems.where((e) => e.inIntersection).map((e) => e.name).toSet();
    final zoneCorrect = zoneItems.where((entry) => entry['wrong'] == false).map((e) => e['item'].name).toSet();
    if (zoneCorrect.containsAll(correctAnswers)) {
      beltTimer.cancel();
      setState(() {
        showCompletionTick = true;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFf0f8ff),
      appBar: AppBar(
        backgroundColor: Colors.blueGrey.shade400,
        title: const Text('BELT SORTER'),
      ),
      body: Column(
        children: [
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Set A ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              buildSetDisplay('', setA),
              Tooltip(
                message: 'Intersección (Spanish for Intersection)',
                child: const Text(' ∩ ', style: TextStyle(fontSize: 24)),
              ),
              const Text(
                'Set B ',
                style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
              ),
              buildSetDisplay('', setB),
              IconButton(
                icon: const Icon(Icons.volume_up),
                tooltip: 'Speak',
                onPressed: speakIntersection,
              ),
              IconButton(
                icon: const Icon(Icons.lightbulb_outline),
                tooltip: 'Hint',
                onPressed: () => setState(() => showHint = true),
              ),
            ],
          ),
          const SizedBox(height: 4),
          const Text(
            'Drag the items that belong to Set A ∩ Set B into the Intersection Zone',
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.w500),
            textAlign: TextAlign.center,
          ),
          if (showHint)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Column(
                children: [
                  Text('¿Cuál es la intersección del conjunto A y B?',
                      style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
                  SizedBox(height: 2),
                  Text('Arrastra los elementos que pertenecen a la intersección',
                      style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
                ],
              ),
            ),
          const SizedBox(height: 10),
          Container(
            width: screenWidth,
            height: 120,
            decoration: BoxDecoration(
              image: DecorationImage(
                image: AssetImage('assets/images/conveyor.png'),
                fit: BoxFit.cover,
              ),
            ),
            child: ListView.builder(
              scrollDirection: Axis.horizontal,
              itemCount: beltItems.length,
              itemBuilder: (context, index) {
                final item = beltItems[index];
                return Draggable<GameItem>(
                  data: item,
                  feedback: Image.asset(item.imagePath, width: 50, height: 50),
                  childWhenDragging: const SizedBox(width: 50, height: 50),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 16.0),
                    child: Image.asset(item.imagePath, width: 50, height: 50),
                  ),
                );
              },
            ),
          ),
          const SizedBox(height: 30),
          DragTarget<GameItem>(
            onAccept: (item) {
              setState(() {
                beltItems.remove(item);
                if (item.inIntersection) {
                  zoneItems.add({"item": item, "wrong": false});
                } else {
                  zoneItems.add({"item": item, "wrong": true});
                  Future.delayed(const Duration(seconds: 1), () {
                    setState(() {
                      zoneItems.removeWhere((element) => element["item"] == item);
                    });
                  });
                }
                checkCompletion();
              });
            },
            builder: (context, candidateData, rejectedData) {
              return Container(
                width: 300,
                height: 150,
                decoration: BoxDecoration(
                  color: Colors.green[100],
                  border: Border.all(color: Colors.green, width: 3),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Row(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        const Text(
                          "Intersection Zone",
                          style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        ),
                        if (showCompletionTick)
                          const Padding(
                            padding: EdgeInsets.only(left: 8.0),
                            child: Icon(Icons.check_circle, color: Colors.green),
                          ),
                      ],
                    ),
                    if (showHint)
                      const Padding(
                        padding: EdgeInsets.only(top: 4),
                        child: Text('Zona de Intersección', style: TextStyle(fontSize: 14, fontStyle: FontStyle.italic)),
                      ),
                    const SizedBox(height: 8),
                    Wrap(
                      spacing: 8,
                      children: zoneItems.map((entry) {
                        final item = entry["item"] as GameItem;
                        final isWrong = entry["wrong"] as bool;
                        return Column(
                          mainAxisSize: MainAxisSize.min,
                          children: [
                            Image.asset(item.imagePath, width: 40, height: 40),
                            if (isWrong)
                              const Text('❌', style: TextStyle(color: Colors.red, fontSize: 18)),
                          ],
                        );
                      }).toList(),
                    ),
                  ],
                ),
              );
            },
          ),
        ],
      ),
    );
  }
}
