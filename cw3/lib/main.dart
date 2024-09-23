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
  String petImage = 'assets/img_yellow.png'; // Default image
  String petMood = "Happy"; // Initial mood
  String moodEmoji = "😊"; // Initial emoji
  Timer? _hungerTimer; // Timer for automatic hunger increase
  Timer? _winTimer; // Timer to track the win condition
  Timer? _lossTimer; // Timer to track the loss condition
  bool hasWon = false;

  @override
  void initState() {
    super.initState();
    _startHungerTimer(); // Start the hunger timer
    _startConditionTimers(); // Start the win/loss condition timers
  }

  @override
  void dispose() {
    _hungerTimer?.cancel(); // Cancel the hunger timer
    _winTimer?.cancel(); // Cancel the win timer
    _lossTimer?.cancel(); // Cancel the loss timer
    super.dispose();
  }

  // Start a timer to increase hunger every 30 seconds
  void _startHungerTimer() {
    _hungerTimer = Timer.periodic(Duration(seconds: 30), (timer) {
      _increaseHungerAutomatically();
    });
  }

  // Start timers to check win and loss conditions every second
  void _startConditionTimers() {
    // Loss condition: Check if hunger reaches 100 and happiness falls to 10
    _lossTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (hungerLevel >= 100 && happinessLevel <= 10) {
        _showGameOver();
        timer.cancel(); // Stop checking once game over is triggered
      }
    });

    // Win condition: Track if happiness stays above 80 for 3 minutes (180 seconds)
    _winTimer = Timer.periodic(Duration(seconds: 1), (timer) {
      if (happinessLevel >= 80) {
        hasWon = true;
      } else {
        hasWon = false; // Reset if happiness drops below 80
      }

      // If happiness has been above 80 for 180 seconds, player wins
      if (hasWon && timer.tick >= 180) {
        _showWinMessage();
        timer.cancel(); // Stop checking once win is triggered
      }
    });
  }

  // Automatically increase hunger level
  void _increaseHungerAutomatically() {
    setState(() {
      hungerLevel = (hungerLevel + 5).clamp(0, 100);
      // Decrease happiness if hunger level is at maximum (but not at 0)
      if (hungerLevel >= 100) {
        happinessLevel = (happinessLevel - 20).clamp(0, 100);
      }
      updatePetImage(happinessLevel); // Ensure the image reflects changes
      updatePetMood(happinessLevel); // Ensure mood is updated
    });
  }

  // Function to display a Game Over message
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

  // Function to display a Win message
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

  // Reset the game state
  void _resetGame() {
    setState(() {
      petName = "Your Pet";
      happinessLevel = 50;
      hungerLevel = 50;
      hasWon = false;
    });
    _startConditionTimers(); // Restart the win/loss timers
  }

  // Function to change the pet's name
  void _changePetName() async {
    final String? newName = await showDialog<String>(
      context: context,
      builder: (BuildContext context) {
        String name = petName; // Default name in the input field
        return AlertDialog(
          title: Text('Change Pet Name'),
          content: TextField(
            onChanged: (value) {
              name = value; // Update the name variable as the user types
            },
            decoration: InputDecoration(hintText: "Enter new pet name"),
          ),
          actions: <Widget>[
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(name); // Return the new name
              },
              child: Text('OK'),
            ),
            TextButton(
              onPressed: () {
                Navigator.of(context).pop(); // Close the dialog without changing the name
              },
              child: Text('Cancel'),
            ),
          ],
        );
      },
    );

    // Update the pet name if a new name was provided
    if (newName != null && newName.isNotEmpty) {
      setState(() {
        petName = newName;
      });
    }
  }

  // Function to increase happiness and update hunger when playing with the pet
  void _playWithPet() {
    setState(() {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
      _updateHunger(); // Increase hunger when playing

      updatePetImage(happinessLevel); // Update the image based on happiness
      updatePetMood(happinessLevel); // Update the mood
    });
  }

  // Update hunger and check if it impacts happiness
  void _updateHunger() {
    setState(() {
      hungerLevel = (hungerLevel + 5).clamp(0, 100);
      // Decrease happiness if hunger level is at maximum, but not if hunger is at 0
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

  // Function to decrease hunger and update happiness when feeding the pet
  void _feedPet() {
    setState(() {
      hungerLevel = (hungerLevel - 10).clamp(0, 100);
      _updateHappiness();
      updatePetImage(happinessLevel); // Update the image based on happiness
      updatePetMood(happinessLevel); // Update the mood
    });
  }

  // Update happiness based on hunger level
  void _updateHappiness() {
    if (hungerLevel > 0 && hungerLevel < 30) {  // Only decrease happiness if hunger is not 0
      happinessLevel = (happinessLevel - 20).clamp(0, 100);
    } else {
      happinessLevel = (happinessLevel + 10).clamp(0, 100);
    }
    updatePetImage(happinessLevel); // Ensure the image reflects changes
    updatePetMood(happinessLevel); // Ensure mood is updated
  }

  // Update the pet image based on happiness level
  void updatePetImage(int happinessLevel) {
    setState(() {
      if (happinessLevel > 70) {
        petImage = 'assets/img_green.png'; // Happy
      } else if (happinessLevel >= 30 && happinessLevel <= 70) {
        petImage = 'assets/img_yellow.png'; // Neutral
      } else {
        petImage = 'assets/img_red.png'; // Unhappy
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
            // Display the pet mood and emoji
            Text(
              '$petMood $moodEmoji',
              style: TextStyle(fontSize: 24.0),
            ),
            SizedBox(height: 8.0),
            Image.asset(
              petImage,
              height: 150,
              width: 150,
            ), // Display the pet image
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
