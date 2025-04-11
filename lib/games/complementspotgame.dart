import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';

class ComplementSetGame extends StatefulWidget {
  const ComplementSetGame({Key? key}) : super(key: key);

  @override
  State<ComplementSetGame> createState() => _ComplementSetGameState();
}

class GameItem {
  final String name;
  final String imagePath;
  final bool inSetA;

  GameItem(this.name, this.imagePath, this.inSetA);
}

class _ComplementSetGameState extends State<ComplementSetGame> {
  final List<GameItem> universalSet = [
    GameItem('Apple', 'assets/images/apple2.png', true),
    GameItem('Banana', 'assets/images/banana.png', true),
    GameItem('Strawberry', 'assets/images/strawberry2.png', true),
    GameItem('Car', 'assets/images/car.png', false),
    GameItem('Cat', 'assets/images/cat.png', false),
  ];

  final List<GameItem> itemsInA = [];
  final List<GameItem> itemsInComplement = [];
  bool showHint = false;
  bool showTick = false;
  bool highlightComplement = false;
  final FlutterTts flutterTts = FlutterTts();
  GameItem? lastWrongItem;

  void speakComplement() async {
    await flutterTts.setSpeechRate(0.3);
    await flutterTts.setLanguage("en-US");
    await flutterTts.speak("Complement of Set A");
  }

  void checkCompletion() {
    final correctComplement = universalSet.where((e) => !e.inSetA).map((e) => e.name).toSet();
    final correctInA = universalSet.where((e) => e.inSetA).map((e) => e.name).toSet();
    final selectedComplement = itemsInComplement.map((e) => e.name).toSet();
    final selectedA = itemsInA.map((e) => e.name).toSet();

    if (selectedComplement.containsAll(correctComplement) &&
        selectedComplement.length == correctComplement.length &&
        selectedA.containsAll(correctInA) &&
        selectedA.length == correctInA.length) {
      setState(() => showTick = true);
    }
  }

  @override
  void dispose() {
    flutterTts.stop();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final insideSetA = universalSet.where((e) => e.inSetA).toList();
    final allItems = List.from(universalSet);

    return Scaffold(
      backgroundColor: Colors.lightBlue[50],
      appBar: AppBar(
        title: const Text('Complement Set Game'),
        backgroundColor: Colors.purple,
      ),
      body: Column(
        children: [
          const SizedBox(height: 12),
          const Text('Drag the items from Universal Set to the appropriate sets A and A′',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
          if (showHint)
            const Padding(
              padding: EdgeInsets.only(top: 4),
              child: Text('Arrastra los elementos al conjunto A o a su complemento A′',
                  style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic), textAlign: TextAlign.center),
            ),
          const SizedBox(height: 12),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text('A = { ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              ...insideSetA.map((item) => Padding(
                padding: const EdgeInsets.symmetric(horizontal: 4),
                child: Image.asset(item.imagePath, width: 40, height: 40),
              )),
              const Text(' }', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            ],
          ),
          const SizedBox(height: 4),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text("A′ = ?", style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
              const SizedBox(width: 20),
              Tooltip(
                message: 'Complemento (Spanish for Complement)',
                child: const Text("A′", style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
              ),
              Tooltip(
                message: 'Speak complement',
                child: IconButton(
                  icon: const Icon(Icons.volume_up),
                  onPressed: speakComplement,
                ),
              ),
              Tooltip(
                message: 'Show hint',
                child: IconButton(
                  icon: const Icon(Icons.lightbulb_outline),
                  onPressed: () => setState(() => showHint = true),
                ),
              ),
              Tooltip(
                message: 'Highlight A′ items',
                child: IconButton(
                  icon: const Icon(Icons.highlight),
                  onPressed: () => setState(() => highlightComplement = !highlightComplement),
                ),
              ),
              if (showTick)
                const Padding(
                  padding: EdgeInsets.only(left: 8.0),
                  child: Icon(Icons.check_circle, color: Colors.green, size: 28),
                )
            ],
          ),
          const SizedBox(height: 12),
          Wrap(
            alignment: WrapAlignment.center,
            crossAxisAlignment: WrapCrossAlignment.center,
            children: [
              const Text('Universal Set = {', style: TextStyle(fontSize: 18)),
              ...allItems.map((item) {
                final isAlreadyUsed = itemsInA.contains(item) || itemsInComplement.contains(item);
                final isComplement = !item.inSetA;
                return Draggable<GameItem>(
                  data: item,
                  feedback: Image.asset(item.imagePath, width: 50, height: 50),
                  childWhenDragging: Opacity(
                    opacity: 0.3,
                    child: Image.asset(item.imagePath, width: 50, height: 50),
                  ),
                  child: Opacity(
                    opacity: isAlreadyUsed ? 0.3 : 1.0,
                    child: Stack(
                      alignment: Alignment.center,
                      children: [
                        Container(
                          decoration: BoxDecoration(
                            border: highlightComplement && isComplement ? Border.all(color: Colors.orange, width: 2) : null,
                            borderRadius: BorderRadius.circular(8),
                          ),
                          child: Image.asset(item.imagePath, width: 50, height: 50),
                        ),
                        if (lastWrongItem == item)
                          const Positioned(
                            right: 0,
                            top: 0,
                            child: Text('❌', style: TextStyle(fontSize: 18, color: Colors.red)),
                          ),
                      ],
                    ),
                  ),
                );
              }).toList(),
              const Text('}', style: TextStyle(fontSize: 18)),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: Center(
              child: Stack(
                alignment: Alignment.center,
                children: [
                  DragTarget<GameItem>(
                    onAccept: (item) {
                      if (!item.inSetA && !itemsInComplement.contains(item)) {
                        setState(() {
                          itemsInComplement.add(item);
                          lastWrongItem = null;
                        });
                        checkCompletion();
                      } else {
                        setState(() => lastWrongItem = item);
                        Future.delayed(const Duration(seconds: 1), () => setState(() => lastWrongItem = null));
                      }
                    },
                    builder: (context, candidateData, rejectedData) {
                      return Container(
                        width: 300,
                        height: 300,
                        decoration: BoxDecoration(
                          color: Colors.orange[50],
                          border: Border.all(color: Colors.orange, width: 4),
                        ),
                        child: Stack(
                          children: [
                            const Positioned(
                              top: 8,
                              left: 8,
                              child: Text("A′", style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
                            ),
                            Align(
                              alignment: Alignment.bottomCenter,
                              child: Wrap(
                                spacing: 8,
                                children: itemsInComplement.map((item) => Column(
                                  children: [
                                    Image.asset(item.imagePath, width: 40, height: 40),
                                    const Icon(Icons.check, color: Colors.green, size: 20),
                                  ],
                                )).toList(),
                              ),
                            )
                          ],
                        ),
                      );
                    },
                  ),
                  Positioned(
                    child: DragTarget<GameItem>(
                      onAccept: (item) {
                        if (item.inSetA && !itemsInA.contains(item)) {
                          setState(() {
                            itemsInA.add(item);
                            lastWrongItem = null;
                          });
                          checkCompletion();
                        } else {
                          setState(() => lastWrongItem = item);
                          Future.delayed(const Duration(seconds: 1), () => setState(() => lastWrongItem = null));
                        }
                      },
                      builder: (context, candidateData, rejectedData) {
                        return Container(
                          width: 160,
                          height: 160,
                          decoration: BoxDecoration(
                            color: Colors.blue[100],
                            border: Border.all(color: Colors.blue, width: 4),
                          ),
                          child: Column(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: [
                              const Text("A", style: TextStyle(fontWeight: FontWeight.bold)),
                              Wrap(
                                spacing: 8,
                                children: itemsInA.map((item) => Column(
                                  children: [
                                    Image.asset(item.imagePath, width: 40, height: 40),
                                    const Icon(Icons.check, color: Colors.green, size: 20),
                                  ],
                                )).toList(),
                              )
                            ],
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
          const SizedBox(height: 16),
        ],
      ),
    );
  }
}
