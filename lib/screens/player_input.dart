import 'package:flutter/material.dart';
import 'truth_or_dare.dart';

class PlayerInputScreen extends StatefulWidget {
  const PlayerInputScreen({super.key});

  @override
  _PlayerInputScreenState createState() => _PlayerInputScreenState();
}

class _PlayerInputScreenState extends State<PlayerInputScreen> {
  final TextEditingController _playerNameController = TextEditingController();
  final List<String> _players = [];

  void _addPlayer() {
    final String playerName = _playerNameController.text.trim();
    if (playerName.isNotEmpty && !_players.contains(playerName)) {
      setState(() {
        _players.add(playerName);
        _playerNameController.clear();
      });
    }
  }

  void _removePlayer(int index) {
    setState(() {
      _players.removeAt(index);
    });
  }

  void _proceedToGame() {
    Navigator.push(context,
        MaterialPageRoute(builder: (context) => HomeScreen(players: _players)));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Players'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: Column(
          children: <Widget>[
            TextField(
              controller: _playerNameController,
              decoration: const InputDecoration(
                hintText: "Enter player's name",
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addPlayer,
              child: const Text('Add Player'),
            ),
            Expanded(
              child: ListView.builder(
                itemCount: _players.length,
                itemBuilder: (context, index) {
                  return ListTile(
                    title: Text(_players[index]),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _removePlayer(index),
                    ),
                  );
                },
              ),
            ),
            ElevatedButton(
              onPressed: _players.length < 2 ? null : _proceedToGame,
              child: const Text('Start Game'),
            ),
          ],
        ),
      ),
    );
  }
}
