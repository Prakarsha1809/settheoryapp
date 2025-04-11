import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'disjointsetgame.dart';

class SubsetSetGame extends StatefulWidget {
  const SubsetSetGame({super.key});

  @override
  State<SubsetSetGame> createState() => _SubsetSetGameState();
}

class _SubsetSetGameState extends State<SubsetSetGame> {
  final List<String> universalSet = [
    'apple2', 'banana', 'strawberry2', 'car', 'cat'
  ];

  final List<String> correctSetA = [
    'apple2', 'banana', 'strawberry2'
  ];
  final List<String> correctSetB = [
    'apple2', 'strawberry2'
  ];

  final String correctSymbol = '⊆';
  final String correctAudio = 'subset';

  final List<String> setA = [];
  final List<String> setB = [];
  String? selectedSymbol;
  String? selectedAudio;
  bool showTick = false;
  bool showWrong = false;
  bool showHint = false;

  final FlutterTts tts = FlutterTts();

  void checkAnswer() {
    final List<String> sortedSetA = List.from(setA)..sort();
    final List<String> sortedSetB = List.from(setB)..sort();

    final isSetACorrect = sortedSetA.join() == (List.from(correctSetA)..sort()).join();
    final isSetBCorrect = sortedSetB.join() == (List.from(correctSetB)..sort()).join();

    if (isSetACorrect && isSetBCorrect && selectedSymbol == correctSymbol && selectedAudio == correctAudio) {
      setState(() {
        showTick = true;
        showWrong = false;
      });
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('✅ Correct!'),
          content: const Text('Great job!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                Navigator.push(context, MaterialPageRoute(builder: (context) => const DisjointSetGame()));
              },
              child: const Text('Next'),
            )
          ],
        ),
      );
    } else {
      setState(() {
        showTick = false;
        showWrong = true;
      });
      showDialog(
        context: context,
        builder: (_) => AlertDialog(
          title: const Text('❌ Wrong'),
          content: const Text('Try again!'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                setState(() {
                  setA.clear();
                  setB.clear();
                  selectedSymbol = null;
                  selectedAudio = null;
                });
              },
              child: const Text('Retry'),
            )
          ],
        ),
      );
    }
  }

  Widget buildDraggableImage(String image) {
    return Draggable<String>(
      data: image,
      feedback: Image.asset('assets/images/$image.png', width: 70, height: 70),
      childWhenDragging: Opacity(
        opacity: 0.4,
        child: Image.asset('assets/images/$image.png', width: 70, height: 70),
      ),
      child: Image.asset('assets/images/$image.png', width: 70, height: 70),
    );
  }

  Widget buildDropZone(String label, List<String> currentList) {
    return DragTarget<String>(
      onAccept: (data) {
        setState(() {
          if (!currentList.contains(data)) {
            currentList.add(data);
          }
        });
      },
      builder: (context, _, __) => Container(
        width: 200,
        height: 200,
        margin: const EdgeInsets.all(8),
        decoration: BoxDecoration(
          color: Colors.blue[50],
          border: Border.all(color: Colors.blue, width: 3),
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
                children: currentList.map((e) => GestureDetector(
                  onTap: () => setState(() => currentList.remove(e)),
                  child: Image.asset('assets/images/$e.png', width: 50, height: 50),
                )).toList(),
              ),
            )
          ],
        ),
      ),
    );
  }

  Widget buildSymbolDropZone() {
    return Column(
      children: [
        const Text('Symbol:', style: TextStyle(fontWeight: FontWeight.bold)),
        if (showHint) const Text('Símbolo', style: TextStyle(fontStyle: FontStyle.italic)),
        const SizedBox(height: 4),
        DragTarget<String>(
          onAccept: (data) => setState(() => selectedSymbol = data),
          builder: (context, _, __) => Container(
            width: 60,
            height: 60,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: Colors.white,
              border: Border.all(color: Colors.deepPurple, width: 2),
              borderRadius: BorderRadius.circular(8),
            ),
            child: Text(selectedSymbol ?? '?', style: const TextStyle(fontSize: 28)),
          ),
        )
      ],
    );
  }

  Widget buildAudioDropZone() {
    return Column(
      children: [
        const Text('Sound:', style: TextStyle(fontWeight: FontWeight.bold)),
        if (showHint) const Text('Sonido', style: TextStyle(fontStyle: FontStyle.italic)),
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
            child: Icon(
              selectedAudio != null ? Icons.volume_up : Icons.help_outline,
              size: 32,
            ),
          ),
        )
      ],
    );
  }

  Widget buildSymbolBox() {
    final symbols = ['⊆', '⊂', '∅', '∪'];
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey[50],
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 6)],
      ),
      child: Wrap(
        spacing: 12,
        children: symbols.map((symbol) => Draggable<String>(
          data: symbol,
          feedback: Material(child: Text(symbol, style: const TextStyle(fontSize: 28))),
          child: Container(
            padding: const EdgeInsets.all(10),
            decoration: BoxDecoration(
              border: Border.all(color: Colors.black),
              borderRadius: BorderRadius.circular(8),
              color: selectedSymbol == symbol ? Colors.orange[100] : Colors.grey[100],
            ),
            child: Text(symbol, style: const TextStyle(fontSize: 26)),
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
        spacing: 10,
        children: audios.map((audio) => Draggable<String>(
          data: audio,
          feedback: const Icon(Icons.volume_up, size: 32),
          child: GestureDetector(
            onTap: () async {
              await tts.setLanguage("en-US");
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

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFf0f8ff),
      appBar: AppBar(
        backgroundColor: Colors.deepPurple.shade300,
        title: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            const Text('SET BUILDER'),
            IconButton(
              icon: const Icon(Icons.lightbulb),
              tooltip: 'Hint',
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
                color: Colors.deepPurple[50],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text(
                    'Set A is all fruits. Set B is subset of red fruits. Drag images from Universal Set.',
                    style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                    textAlign: TextAlign.center,
                  ),
                  if (showHint)
                    const Text(
                      'Conjunto A son todas las frutas. Conjunto B es un subconjunto de frutas rojas.',
                      style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic),
                      textAlign: TextAlign.center,
                    ),
                ],
              ),
            ),
            const SizedBox(height: 16),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                buildDropZone('Set A', setA),
                Column(
                  children: [
                    buildSymbolDropZone(),
                    const SizedBox(height: 16),
                    buildAudioDropZone(),
                  ],
                ),
                buildDropZone('Set B', setB),
              ],
            ),
            const SizedBox(height: 20),
            const Text('Symbols:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (showHint) const Text('Símbolos', style: TextStyle(fontStyle: FontStyle.italic)),
            buildSymbolBox(),
            const SizedBox(height: 16),
            const Text('Sounds:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
            if (showHint) const Text('Sonidos', style: TextStyle(fontStyle: FontStyle.italic)),
            buildAudioBox(),
            const SizedBox(height: 16),
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
                  const Text('Universal Set:', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                  if (showHint) const Text('Conjunto Universal', style: TextStyle(fontStyle: FontStyle.italic)),
                  Wrap(
                    spacing: 10,
                    runSpacing: 10,
                    children: universalSet.map(buildDraggableImage).toList(),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 20),
            ElevatedButton(
              onPressed: checkAnswer,
              child: const Text('Submit'),
            ),
          ],
        ),
      ),
    );
  }
}
