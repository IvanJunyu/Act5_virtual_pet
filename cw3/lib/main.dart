//by Ivan loh and Yikai Liu
import 'package:flutter/material.dart';
import 'dart:async';

void main() {
  runApp(MaterialApp(
    home: DigitalPetApp(),
  ));
}

class DigitalPetApp extends StatefulWidget {
  @override
  _DigitalPetAppState createState() => _DigitalPetAppState();
}

class _DigitalPetAppState extends State<DigitalPetApp> {
  String petName = "Your Pet";
  int happinessLevel = 50;
  int hungerLevel = 50;
  String petImage = 'assets/img_yellow.png';
  String petMood = "Happy";
  String moodEmoji = "😊";
  Timer? _hungerTimer;
  Timer? _winTimer;
  Timer? _lossTimer;
  bool hasWon = false;

  @override
  void initState() {
    super.initState();
    _startHungerTimer();
    _startConditionTimers();
  }

  @override
  void dispose() {
    _hungerTimer?.cancel();
    _winTimer?.cancel();
    _lossTimer?.cancel();
    super.dispose();
  }

  void _startHungerTimer() {
    _hungerTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      _increaseHungerAutomatically();
    });
  }

  void _startConditionTimers() {
    _lossTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (hungerLevel >= 100 && happinessLevel <= 10) {
        _showGameOver();
        timer.cancel();
      }
    });

    _winTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (happinessLevel >= 80) {
        hasWon = true;
      } else {
        hasWon = false;
      }

      if (hasWon && timer.tick >= 180) {
        _showWinMessage();
        timer.cancel();
      }
    });
  }

  void _increaseHungerAutomatically() {
    setState(() {
      hungerLevel = (hungerLevel + 5).clamp(0, 100);
      if (hungerLevel >= 100) {
        happinessLevel = (happinessLevel - 20).clamp(0, 100);
      }
      updatePetImage(happinessLevel);
      updatePetMood(happinessLevel);
    });
  }

  void _showGameOver() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("Game Over"),
          content: Text("Your pet's hunger reached 100 and happiness dropped to 10. Try again!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _showWinMessage() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title: Text("You Win!"),
          content: Text("You kept your pet's happiness above 80 for 3 minutes!"),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
                _resetGame();
              },
              child: Text("OK"),
            ),
          ],
        );
      },
    );
  }

  void _resetGame() {
    setState(() {
      petName = "Your Pet";
      happinessLevel = 50;
      hungerLevel = 50;
      hasWon = false;
    });
    _startConditionTimers();
  }

  void _changePetName() async {
    final String? newName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String name = petName;
        return AlertDialog(
          title: Text('Change Pet Name'),
          content: TextField(
            onChanged: (value) {
              name = value;
            },
            decoration: InputDecoration(hintText: "Enter new pet name"),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(name);
              },
              child: Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );

    if (newName != null && newName.isNotEmpty) {
      setState(() {
        petName = newName;
      });
    }
  }

  void _playWithPet() {
    setState(() {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
      _updateHunger();
      updatePetImage(happinessLevel);
      updatePetMood(happinessLevel);
    });
  }

  void _updateHunger() {
    setState(() {
      hungerLevel = (hungerLevel + 5).clamp(0, 100);
      if (hungerLevel >= 100) {
        happinessLevel = (happinessLevel - 20).clamp(0, 100);
      }
    });
  }

  void updatePetMood(int happinessLevel) {
    setState(() {
      if (happinessLevel > 70) {
        petMood = "Happy";
        moodEmoji = "😊";
      } else if (happinessLevel >= 30 && happinessLevel <= 70) {
        petMood = "Neutral";
        moodEmoji = "😐";
      } else {
        petMood = "Unhappy";
        moodEmoji = "😟";
      }
    });
  }

  void _feedPet() {
    setState(() {
      hungerLevel = (hungerLevel - 10).clamp(0, 100);
      _updateHappiness();
      updatePetImage(happinessLevel);
      updatePetMood(happinessLevel);
    });
  }

  void _updateHappiness() {
    if (hungerLevel > 0 && hungerLevel < 30) {
      happinessLevel = (happinessLevel - 20).clamp(0, 100);
    } else {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
    }
    updatePetImage(happinessLevel);
    updatePetMood(happinessLevel);
  }

  void updatePetImage(int happinessLevel) {
    setState(() {
      if (happinessLevel > 70) {
        petImage = 'assets/img_green.png';
      } else if (happinessLevel >= 30 && happinessLevel <= 70) {
        petImage = 'assets/img_yellow.png';
      } else {
        petImage = 'assets/img_red.png';
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Digital Pet'),
      ),
      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: <Widget>[
            Text(
              'Name: $petName',
              style: TextStyle(fontSize: 32.0),
            ),
            SizedBox(height: 16.0),
            Text(
              '$petMood $moodEmoji',
              style: TextStyle(fontSize: 24.0),
            ),
            SizedBox(height: 8.0),
            Image.asset(
              petImage,
              height: 150,
              width: 150,
            ),
            SizedBox(height: 16.0),
            Text(
              'Happiness Level: $happinessLevel',
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 16.0),
            Text(
              'Hunger Level: $hungerLevel',
              style: TextStyle(fontSize: 20.0),
            ),
            SizedBox(height: 32.0),
            ElevatedButton(
              onPressed: _playWithPet,
              child: Text('Play with Your Pet'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _feedPet,
              child: Text('Feed Your Pet'),
            ),
            SizedBox(height: 16.0),
            ElevatedButton(
              onPressed: _changePetName,
              child: Text('Change Pet Name'),
            ),
          ],
        ),
      ),
    );
  }
}
