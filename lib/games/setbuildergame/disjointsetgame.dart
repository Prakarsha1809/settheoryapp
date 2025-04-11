import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import '/games/whackgame.dart';

class DisjointSetGame extends StatefulWidget {
  const DisjointSetGame({super.key});

  @override
  State<DisjointSetGame> createState() => _DisjointSetGameState();
}

class _DisjointSetGameState extends State<DisjointSetGame> {
  final List<String> universalSet = ['apple2', 'banana', 'strawberry2', 'car', 'cat'];
  final String correctName = 'Disjoint Set';
  final String correctAudio = 'disjoint';

  final List<String> setA = [];
  final List<String> setB = [];
  String? selectedName;
  String? selectedAudio;
  bool showHint = false;

  final FlutterTts tts = FlutterTts();

  void checkAnswer() {
    final overlap = setA.toSet().intersection(setB.toSet());
    final onlyFruits = (List.from(setA)..addAll(setB)).every((e) => ['apple2', 'banana', 'strawberry2'].contains(e));
    final bool isDisjoint = overlap.isEmpty && onlyFruits;

    if (isDisjoint && selectedName == correctName && selectedAudio == correctAudio) {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('✅ Correct!'),
          content: const Text('Great job! These sets are disjoint.'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(context, MaterialPageRoute(builder: (context) => const MinusSetGame()));
              },
              child: const Text('Next'),
            )
          ],
        ),
      );
    } else {
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('❌ Wrong'),
          content: const Text('Try again. Make sure both sets are fruits and do not overlap.'),
          actions: [TextButton(onPressed: () => Navigator.of(context).pop(), child: const Text('Retry'))],
        ),
      );
    }
  }

  Widget buildDropBox(String label, List<String> list, ColorSwatch borderColor) {
    return DragTarget<String>(
      onAccept: (item) => setState(() => list.add(item)),
      builder: (context, _, __) => Container(
        width: 200,
        height: 200,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: borderColor[50],
          border: Border.all(color: borderColor, width: 3),
          borderRadius: BorderRadius.circular(12),
          boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
        ),
        child: Column(
          children: [
            const SizedBox(height: 8),
            Text(label, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
            if (showHint)
              Padding(
                padding: const EdgeInsets.only(top: 2),
                child: Text(
                  label == 'Set A' ? 'Conjunto A' : 'Conjunto B',
                  style: const TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                ),
              ),
            const SizedBox(height: 8),
            Expanded(
              child: Wrap(
                spacing: 6,
                runSpacing: 6,
                children: list.map((item) => GestureDetector(
                  onTap: () => setState(() => list.remove(item)),
                  child: Image.asset('assets/images/$item.png', width: 50, height: 50),
                )).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildNameDropZone() {
    return Column(
      children: [
        const Text('What are these sets called?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        if (showHint) const Text('¿Cómo se llama este conjunto?', style: TextStyle(fontStyle: FontStyle.italic)),
        const SizedBox(height: 4),
        DragTarget<String>(
          onAccept: (data) => setState(() => selectedName = data),
          builder: (context, _, __) => Container(
            width: 200,
            height: 50,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.green, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(selectedName ?? '?', style: const TextStyle(fontSize: 22)),
          ),
        )
      ],
    );
  }

  Widget buildAudioDropZone() {
    return Column(
      children: [
        const Text('How are they pronounced?', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 18)),
        if (showHint) const Text('¿Cómo se pronuncia?', style: TextStyle(fontStyle: FontStyle.italic)),
        const SizedBox(height: 4),
        DragTarget<String>(
          onAccept: (data) => setState(() => selectedAudio = data),
          builder: (context, _, __) => Container(
            width: 60,
            height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.orange, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Icon(selectedAudio != null ? Icons.volume_up : Icons.help_outline, size: 28),
          ),
        )
      ],
    );
  }

  Widget buildNameBox() {
    final names = ['Disjoint Set', 'Subset Set', 'Universal Set', 'Power Set'];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Wrap(
        spacing: 12,
        children: names.map((name) => Draggable<String>(
          data: name,
          feedback: Material(
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                color: Colors.grey[50],
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(name, style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold)),
            ),
          ),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(8),
              color: selectedName == name ? Colors.orange[100] : Colors.grey[100],
            ),
            child: Text(name, style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
          ),
        )).toList(),
      ),
    );
  }

  Widget buildAudioBox() {
    final audios = ['subset', 'disjoint', 'equal', 'empty'];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Wrap(
        spacing: 12,
        children: audios.map((audio) => Draggable<String>(
          data: audio,
          feedback: const Icon(Icons.volume_up, size: 32),
          child: GestureDetector(
            onTap: () async {
              await tts.setLanguage('en-US');
              await tts.setSpeechRate(0.4);
              await tts.speak(audio);
            },
            child: Container(
              padding: const EdgeInsets.all(10),
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black),
                borderRadius: BorderRadius.circular(8),
                color: selectedAudio == audio ? Colors.orange[100] : Colors.grey[100],
              ),
              child: const Icon(Icons.volume_up, size: 32),
            ),
          ),
        )).toList(),
      ),
    );
  }

  Widget buildDraggableItem(String item) {
    return Draggable<String>(
      data: item,
      feedback: Image.asset('assets/images/$item.png', width: 70, height: 70),
      childWhenDragging: Opacity(
        opacity: 0.4,
        child: Image.asset('assets/images/$item.png', width: 70, height: 70),
      ),
      child: Image.asset('assets/images/$item.png', width: 70, height: 70),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf0f8ff),
      appBar: AppBar(
        backgroundColor: Colors.teal.shade400,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('SET BUILDER'),
            IconButton(
              icon: const Icon(Icons.lightbulb_outline),
              onPressed: () => setState(() => showHint = !showHint),
            )
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          children: [
            Container(
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.teal[100],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: const [
                      Text(
                        'Set A and Set B are fruits but Set A - Set B = ',
                        style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                        textAlign: TextAlign.center,
                      ),
                      Tooltip(
                        message: 'Empty Set / Null (Conjunto Vacío)',
                        child: Text('∅', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      )
                    ],
                  ),
                  if (showHint)
                    const Padding(
                      padding: EdgeInsets.only(top: 6),
                      child: Text(
                        'Conjunto A y Conjunto B son frutas pero Conjunto A - Conjunto B = ∅',
                        style: TextStyle(fontStyle: FontStyle.italic),
                        textAlign: TextAlign.center,
                      ),
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildDropBox('Set A', setA, Colors.pink),
                Column(
                  children: [
                    buildNameDropZone(),
                    const SizedBox(height: 16),
                    buildAudioDropZone(),
                  ],
                ),
                buildDropBox('Set B', setB, Colors.purple),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Names:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            if (showHint) const Text('Nombres', style: TextStyle(fontStyle: FontStyle.italic)),
            buildNameBox(),
            const SizedBox(height: 16),
            const Text('Sounds:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold), textAlign: TextAlign.center),
            if (showHint) const Text('Sonidos', style: TextStyle(fontStyle: FontStyle.italic)),
            buildAudioBox(),
            const SizedBox(height: 20),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.orange[50],
                border: Border.all(color: Colors.orange, width: 2),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  const Text('Universal Set:', style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold)),
                  if (showHint) const Text('Conjunto Universal', style: TextStyle(fontStyle: FontStyle.italic)),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: universalSet.map(buildDraggableItem).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(onPressed: checkAnswer, child: const Text('Submit')),
          ],
        ),
      ),
    );
  }
}
