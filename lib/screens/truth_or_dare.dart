import 'dart:convert';
import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';


class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key, required List<String> players});

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  String prompt = "";
  Map<String, dynamic> playerHistories = {};
  List<String> players = []; // Assume this is populated as needed or passed in
  String selectedPlayer = "";
  List<String> playerSelectionHistory = [];
  Map<String, int> playerLives = {};
  dynamic gameData; // This will store your game data loaded from JSON

  @override
  void initState() {
    super.initState();
    // TODO: Load your game data from JSON file
    loadGameData();
    // Initialize players based on your requirements
    initializePlayerLives();
    initializePlayerHistories();
  }

  void loadGameData() async {
    final String response = await rootBundle.loadString('assets/data.json');
    final data = await json.decode(response);
    setState(() {
      gameData = data;
    });
  }

  void initializePlayerLives() {
    final lives = { for (var e in players) e : 3 };
    setState(() {
      playerLives = lives.cast<String, int>();
    });
  }

  void initializePlayerHistories() {
    final histories = { for (var e in players) e : {"truths": [], "dares": []} };
    setState(() {
      playerHistories = histories.cast<String, int>();
    });
  }

  void selectPlayer() {
    Random rnd = Random();
    String potentialPlayer;
    int attempts = 0;
    do {
      potentialPlayer = players[rnd.nextInt(players.length)];
      attempts++;
      if (attempts > 10) break;
    } while (playerSelectionHistory.take(3).contains(potentialPlayer));

    setState(() {
      selectedPlayer = potentialPlayer;
      playerSelectionHistory =
          [...playerSelectionHistory, potentialPlayer].take(3).toList();
    });
  }

  String getUniqueItem(List<dynamic> items, String type) {
    Random rnd = Random();
    String potentialItem;
    int attempts = 0;
    do {
      potentialItem = items[rnd.nextInt(items.length)];
      attempts++;
      if (attempts > 10) break;
    } while (playerHistories[selectedPlayer][type].contains(potentialItem));
    return potentialItem;
  }

  void handleTruthOrDareSelection(String type) {
    if (gameData == null) {
      print("Game data not loaded yet");
      return;
    }
    if (playerLives[selectedPlayer]! > 0) {
      final uniqueItem = getUniqueItem(gameData["${type}s"], "${type}s");
      setState(() {
        prompt = "$type: $uniqueItem";
        playerHistories[selectedPlayer]["${type}s"].add(uniqueItem);
      });
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Game Over"),
            content: Text("$selectedPlayer has lost all lives!"),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    }
  }

  void handleSkip(String type) {
    setState(() {
      playerLives[selectedPlayer] = max(playerLives[selectedPlayer]! - 1, 0);
    });
    if (playerLives[selectedPlayer]! > 1) {
      handleTruthOrDareSelection(type);
    } else {
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return AlertDialog(
            title: const Text("Game Over"),
            content: Text("$selectedPlayer has lost all lives!"),
            actions: [
              TextButton(
                child: const Text("OK"),
                onPressed: () => Navigator.of(context).pop(),
              ),
            ],
          );
        },
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Home Screen"),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.edit),
            onPressed: () {
              // Navigate to EditQuestions screen
            },
          ),
        ],
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            const Text("Spin to select who's next:"),
            ElevatedButton(
              onPressed: selectPlayer,
              child: const Text("Spin"),
            ),
            if (selectedPlayer.isNotEmpty)
              Column(
                children: [
                  Text(
                      "Selected Player: $selectedPlayer - Lives: ${playerLives[selectedPlayer]}"),
                  ElevatedButton(
                    onPressed: () => handleTruthOrDareSelection("Truth"),
                    child: const Text("Truth"),
                  ),
                  ElevatedButton(
                    onPressed: () => handleTruthOrDareSelection("Dare"),
                    child: const Text("Dare"),
                  ),
                  ElevatedButton(
                    onPressed: () => handleSkip(
                        prompt.startsWith("Truth") ? "Truth" : "Dare"),
                    child: const Text("Skip"),
                  ),
                  if (prompt.isNotEmpty) Text(prompt),
                ],
              ),
          ],
        ),
      ),
    );
  }
}
