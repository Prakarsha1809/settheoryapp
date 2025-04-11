import 'package:flutter/material.dart';
import 'package:flutter_tts/flutter_tts.dart';
import 'dart:async';
import 'dart:math';

class UniversalSetBasketGame extends StatefulWidget {
  const UniversalSetBasketGame({Key? key}) : super(key: key);

  @override
  State<UniversalSetBasketGame> createState() => _UniversalSetBasketGameState();
}

class FallingItem {
  final String name;
  final String imagePath;
  final bool belongsToUniversalSet;

  FallingItem(this.name, this.imagePath, this.belongsToUniversalSet);
}

class _UniversalSetBasketGameState extends State<UniversalSetBasketGame> {
  final List<FallingItem> allItems = [
    FallingItem('Apple', 'assets/images/apple2.png', true),
    FallingItem('Banana', 'assets/images/banana.png', true),
    FallingItem('Strawberry', 'assets/images/strawberry2.png', true),
    FallingItem('Car', 'assets/images/car.png', false),
    FallingItem('Cat', 'assets/images/cat.png', false),
  ];

  final List<FallingItem> caughtAnswers = [];
  final List<Map<String, dynamic>> recentWrongVisuals = [];
  final List<FallingItem> recentDuplicateFades = [];

  final List<FallingItem> setA = [
    FallingItem('Apple', 'assets/images/apple2.png', true),
    FallingItem('Banana', 'assets/images/banana.png', true),
  ];
  final List<FallingItem> setB = [
    FallingItem('Strawberry', 'assets/images/strawberry2.png', true),
    FallingItem('Banana', 'assets/images/banana.png', true),
  ];

  final double basketWidth = 150;
  final double itemSize = 100;

  double basketX = 100;
  late Timer itemTimer;
  final List<_FallingWidget> fallingWidgets = [];
  bool showHint = false;
  bool showCompletionTick = false;

  final FlutterTts flutterTts = FlutterTts();

  @override
  void initState() {
    super.initState();
    flutterTts.setSpeechRate(0.3);
    WidgetsBinding.instance.addPostFrameCallback((_) => startGame());
  }

  void startGame() {
    itemTimer = Timer.periodic(const Duration(seconds: 2), (timer) {
      final randomItem = allItems[Random().nextInt(allItems.length)];
      final startX = Random().nextDouble() * (MediaQuery.of(context).size.width - itemSize);
      setState(() {
        fallingWidgets.add(
          _FallingWidget(
            key: UniqueKey(),
            item: randomItem,
            startX: startX,
            onCatch: handleCatch,
            basketXCallback: () => basketX,
            basketWidth: basketWidth,
            itemSize: itemSize,
            onRemove: (key) {
              setState(() {
                fallingWidgets.removeWhere((widget) => widget.key == key);
              });
            },
          ),
        );
      });
    });
  }

  void handleCatch(FallingItem item) {
    setState(() {
      if (item.belongsToUniversalSet) {
        final isAlreadyAdded = caughtAnswers.any((e) => e.name == item.name);
        if (isAlreadyAdded) {
          recentDuplicateFades.add(item);
          Future.delayed(const Duration(seconds: 1), () {
            setState(() {
              recentDuplicateFades.remove(item);
            });
          });
        } else {
          caughtAnswers.add(item);
          final unionSet = {...setA.map((e) => e.name), ...setB.map((e) => e.name)};
          final caughtNames = caughtAnswers.where((e) => e.belongsToUniversalSet).map((e) => e.name).toSet();
          if (caughtNames.containsAll(unionSet)) {
            itemTimer.cancel();
            showCompletionTick = true;
          }
        }
      } else {
        recentWrongVisuals.add({'item': item});
        Future.delayed(const Duration(seconds: 1), () {
          setState(() {
            recentWrongVisuals.removeWhere((e) => e['item'] == item);
          });
        });
      }
    });
  }

  @override
  void dispose() {
    itemTimer.cancel();
    flutterTts.stop();
    super.dispose();
  }

  Widget buildImageSet(List<FallingItem> set) {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text("{ ", style: TextStyle(fontSize: 18)),
        ...set.map((item) => Padding(
          padding: const EdgeInsets.symmetric(horizontal: 4),
          child: Image.asset(item.imagePath, width: 40, height: 40),
        )),
        const Text(" }", style: TextStyle(fontSize: 18)),
      ],
    );
  }

  Widget buildAnswerDisplay() {
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        const Text('= { ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        Wrap(
          spacing: 8,
          children: [
            ...caughtAnswers.map((item) => Image.asset(item.imagePath, width: 40, height: 40)),
            ...recentWrongVisuals.map((entry) => Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                Image.asset(entry['item'].imagePath, width: 40, height: 40),
                const Text('❌', style: TextStyle(fontSize: 18, color: Colors.red)),
              ],
            )),
            ...recentDuplicateFades.map((item) => Opacity(
              opacity: 0.5,
              child: Image.asset(item.imagePath, width: 40, height: 40),
            )),
          ],
        ),
        const Text(' }', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
        if (showCompletionTick)
          const Padding(
            padding: EdgeInsets.only(left: 8),
            child: Icon(Icons.check_circle, color: Colors.green),
          ),
      ],
    );
  }

  void speakUnion() async {
    await flutterTts.setSpeechRate(0.3);
    await flutterTts.setLanguage("en-US");
    await flutterTts.speak("Set A union Set B");
  }

  @override
  Widget build(BuildContext context) {
    final screenWidth = MediaQuery.of(context).size.width;

    return Scaffold(
      backgroundColor: const Color(0xFFf0f8ff),
      appBar: AppBar(
        backgroundColor: Colors.amber.shade400,
        title: const Text('BASKET CATCHER'),
        actions: [
          IconButton(
            icon: const Icon(Icons.lightbulb_outline),
            tooltip: 'Hint',
            onPressed: () => setState(() => showHint = true),
          )
        ],
      ),
      body: GestureDetector(
        onPanUpdate: (details) {
          setState(() {
            basketX = (basketX + details.delta.dx).clamp(0, screenWidth - basketWidth);
          });
        },
        child: Stack(
          children: [
            ...fallingWidgets,
            Positioned(
              top: 10,
              left: 10,
              right: 10,
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.center,
                children: [
                  Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      const Text('Set A ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      buildImageSet(setA),
                      Tooltip(
                        message: 'Unión (Spanish for Union)',
                        child: GestureDetector(
                          onTap: speakUnion,
                          child: const Text(' ∪ ', style: TextStyle(fontSize: 24)),
                        ),
                      ),
                      const Text('Set B ', style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold)),
                      buildImageSet(setB),
                      const Text(' ', style: TextStyle(fontSize: 18)),
                      buildAnswerDisplay(),
                      IconButton(
                        icon: const Icon(Icons.volume_up),
                        onPressed: speakUnion,
                      ),
                    ],
                  ),
                  if (showHint)
                    const Padding(
                      padding: EdgeInsets.only(top: 4),
                      child: Text('¿Cuál es el conjunto universal?', style: TextStyle(fontSize: 16, fontStyle: FontStyle.italic)),
                    ),
                ],
              ),
            ),
            Positioned(
              bottom: 0,
              left: basketX,
              child: Image.asset(
                'assets/images/basket.png',
                width: basketWidth,
                height: 100,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class _FallingWidget extends StatefulWidget {
  final FallingItem item;
  final double startX;
  final double Function() basketXCallback;
  final double basketWidth;
  final double itemSize;
  final Function(FallingItem) onCatch;
  final Function(Key key) onRemove;

  const _FallingWidget({
    required Key key,
    required this.item,
    required this.startX,
    required this.basketXCallback,
    required this.basketWidth,
    required this.itemSize,
    required this.onCatch,
    required this.onRemove,
  }) : super(key: key);

  @override
  State<_FallingWidget> createState() => _FallingWidgetState();
}

class _FallingWidgetState extends State<_FallingWidget> with SingleTickerProviderStateMixin {
  late final AnimationController _controller;
  late final Animation<double> _animation;
  bool isCaught = false;

  @override
  void initState() {
    super.initState();

    final screenHeight = WidgetsBinding.instance.window.physicalSize.height /
        WidgetsBinding.instance.window.devicePixelRatio;

    _controller = AnimationController(
      duration: const Duration(seconds: 4),
      vsync: this,
    );

    _animation = Tween<double>(begin: 0, end: screenHeight - 120).animate(_controller)
      ..addListener(() {
        if (!mounted || isCaught) return;

        setState(() {});

        final itemBottom = _animation.value + widget.itemSize;
        final basketTop = screenHeight - 120;
        final basketBottom = screenHeight;
        final itemCenterX = widget.startX + widget.itemSize / 2;
        final basketLeft = widget.basketXCallback();
        final basketRight = basketLeft + widget.basketWidth;

        final verticalOverlap = itemBottom >= basketTop && itemBottom <= basketBottom;
        final horizontalOverlap = itemCenterX >= basketLeft && itemCenterX <= basketRight;

        if (verticalOverlap && horizontalOverlap) {
          isCaught = true;
          widget.onCatch(widget.item);
          widget.onRemove(widget.key!);
          _controller.stop();
        }
      })
      ..addStatusListener((status) {
        if (status == AnimationStatus.completed && !isCaught) {
          widget.onRemove(widget.key!);
        }
      });

    _controller.forward();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    if (isCaught) return const SizedBox.shrink();
    return Positioned(
      left: widget.startX,
      top: _animation.value,
      child: Image.asset(
        widget.item.imagePath,
        width: widget.itemSize,
        height: widget.itemSize,
      ),
    );
  }
}
