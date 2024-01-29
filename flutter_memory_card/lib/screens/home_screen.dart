import 'dart:async';
import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart'; // Import the Flutter SVG package

class MemoryCardGame extends StatefulWidget {
  @override
  _MemoryCardGameState createState() => _MemoryCardGameState();
}

class _MemoryCardGameState extends State<MemoryCardGame> {
  List<String> symbols = [
    '🐶',
    '🐱',
    '🐰',
    '🦊',
  ];

  List<String> shuffledSymbols = [];
  List<String> visibleCards = [];
  bool canFlip = true;
  int attempts = 0;
  int matchedPairs = 0;
  List<int> flippedIndices = [];
  Timer? timer;
  int secondsElapsed = 0;
  bool isTimerRunning = false;

  @override
  void initState() {
    super.initState();
    initializeGame();
  }

  void initializeGame() {
    timer?.cancel();
    timer = null;
    setState(() {
      shuffledSymbols = List.from(symbols)..addAll(symbols);
      shuffledSymbols.shuffle();
      visibleCards = List.filled(shuffledSymbols.length, '');
      canFlip = true;
      attempts = 0;
      matchedPairs = 0;
      flippedIndices = [];
      secondsElapsed = 0;
      isTimerRunning = false;
    });
  }

  void startTimer() {
    timer = Timer.periodic(Duration(seconds: 1), (t) {
      setState(() {
        secondsElapsed++;
      });

      if (flippedIndices.length == 2) {
        canFlip = false;
        checkForMatch();
      }
    });
    isTimerRunning = true;
  }

  void handleCardTap(int index) {
    if (!canFlip || visibleCards[index] == 'visible' || flippedIndices.length >= 2) {
      return;
    }

    if (!isTimerRunning) {
      startTimer();
    }

    setState(() {
      visibleCards[index] = shuffledSymbols[index];
      flippedIndices.add(index);
    });

    if (flippedIndices.length == 2) {
      canFlip = false;
      Future.delayed(Duration(seconds: 1), () {
        checkForMatch();
      });
    }
  }

  void checkForMatch() {
    if (shuffledSymbols[flippedIndices[0]] == shuffledSymbols[flippedIndices[1]]) {
      matchedPairs++;
      if (matchedPairs == symbols.length) {
        showGameWonDialog();
      }
    } else {
      resetVisibleCards(flippedIndices);
    }

    flippedIndices = [];
    canFlip = true;
  }

  void resetVisibleCards(List<int> indicesToReset) {
    setState(() {
      for (int index in indicesToReset) {
        visibleCards[index] = '';
      }
    });
  }

  void showGameWonDialog() {
    timer?.cancel();
    if (Navigator.of(context).canPop()) {
      return;
    }
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text('Congratulations!'),
          content: Text('You won the game in $attempts attempts and $secondsElapsed seconds'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                initializeGame();
              },
              child: Text('Play Again'),
            ),
          ],
        );
      },
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Memory Card Game'),
      ),
      body: Column(
        children: [
          Padding(
            padding: EdgeInsets.all(8.0),
            child: Container(
              padding: EdgeInsets.all(8.0),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(10.0),
                border: Border.all(
                  color: const Color.fromARGB(255, 91, 91, 91),
                  width: 2.0,
                ),
                color: Color.fromARGB(255, 255, 238, 162),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Use the SvgPicture.asset to display the SVG file
                  SvgPicture.asset(
                    'assets/time-svgrepo-com.svg', // Adjust the path accordingly
                    width: 24.0,
                    height: 24.0,
                  ),
                  SizedBox(width: 8.0),
                  Text(
                    'TIME: $secondsElapsed seconds',
                    style: TextStyle(fontSize: 18),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            child: Padding(
              padding: const EdgeInsets.all(8.0),
              child: GridView.builder(
                gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                  crossAxisCount: 3,
                  crossAxisSpacing: 8.0,
                  mainAxisSpacing: 8.0,
                ),
                itemBuilder: (context, index) {
                  return GestureDetector(
                    onTap: () {
                      setState(() {
                        attempts++;
                      });
                      handleCardTap(index);
                    },
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(10.0),
                      child: Container(
                        color: visibleCards[index] == 'visible' ? Colors.white : Color.fromARGB(255, 246, 255, 81),
                        child: Center(
                          child: Text(
                            visibleCards[index],
                            style: TextStyle(fontSize: 24),
                          ),
                        ),
                      ),
                    ),
                  );
                },
                itemCount: visibleCards.length,
              ),
            ),
          ),
        ],
      ),
    );
  }
}
