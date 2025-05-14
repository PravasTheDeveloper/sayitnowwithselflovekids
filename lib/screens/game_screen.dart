import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'dart:math' show min;
import 'package:flutter/services.dart';
import 'dart:async';

// Main GameScreen widget that manages the game flow
class GameScreen extends StatefulWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  _GameScreenState createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  // Game state
  bool showWelcome = true;
  bool showCharacterSelection = false;
  bool showGameBoard = false;
  List<PlayerData> _selectedPlayers = [];

  @override
  void initState() {
    super.initState();
    // Start with welcome screen and navigate to character selection after 2 seconds
    Timer(const Duration(seconds: 2), () {
      setState(() {
        showWelcome = false;
        showCharacterSelection = true;
      });
    });
  }

  void startGame(List<PlayerData> selectedPlayers) {
    setState(() {
      _selectedPlayers = selectedPlayers;
      showCharacterSelection = false;
      showGameBoard = true;
    });
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Board Game',
      theme: ThemeData(primarySwatch: Colors.blue),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body:
            showWelcome
                ? WelcomeScreen()
                : showCharacterSelection
                ? CharacterSelectionScreen(onGameStart: startGame)
                : CirclePatternPage(players: _selectedPlayers),
      ),
    );
  }
}

// Data class to hold player information with money
class PlayerData {
  final String name;
  final Color color;
  final int characterIndex;
  final String imagePath;

  // Money properties
  int totalMoney = 100; // Starting money
  int ones = 5; // $1 x 5
  int fives = 3; // $5 x 3
  int tens = 1; // $10 x 1
  int twenties = 1; // $20 x 1
  int fifties = 1; // $50 x 1
  int hundreds = 0; // $100 x 0

  // Add player position property
  int position = 0; // Starting position (0 = first square)

  PlayerData({
    required this.name,
    required this.color,
    required this.characterIndex,
    required this.imagePath,
  });

  // Calculate total money based on denominations
  void recalculateTotal() {
    totalMoney =
        ones * 1 +
        fives * 5 +
        tens * 10 +
        twenties * 20 +
        fifties * 50 +
        hundreds * 100;
  }

  // Add money by denomination
  void addMoney(int amount) {
    // Add money in the most efficient way (largest denominations first)
    while (amount >= 100 && amount > 0) {
      hundreds++;
      amount -= 100;
    }

    while (amount >= 50 && amount > 0) {
      fifties++;
      amount -= 50;
    }

    while (amount >= 20 && amount > 0) {
      twenties++;
      amount -= 20;
    }

    while (amount >= 10 && amount > 0) {
      tens++;
      amount -= 10;
    }

    while (amount >= 5 && amount > 0) {
      fives++;
      amount -= 5;
    }

    while (amount >= 1 && amount > 0) {
      ones++;
      amount -= 1;
    }

    recalculateTotal();
  }

  // Subtract money
  bool subtractMoney(int amount) {
    if (amount > totalMoney) {
      return false; // Not enough money
    }

    // Make a copy of current denominations
    int tempOnes = ones;
    int tempFives = fives;
    int tempTens = tens;
    int tempTwenties = twenties;
    int tempFifties = fifties;
    int tempHundreds = hundreds;

    // Take money from largest denominations first
    while (amount >= 100 && tempHundreds > 0) {
      tempHundreds--;
      amount -= 100;
    }

    while (amount >= 50 && tempFifties > 0) {
      tempFifties--;
      amount -= 50;
    }

    while (amount >= 20 && tempTwenties > 0) {
      tempTwenties--;
      amount -= 20;
    }

    while (amount >= 10 && tempTens > 0) {
      tempTens--;
      amount -= 10;
    }

    while (amount >= 5 && tempFives > 0) {
      tempFives--;
      amount -= 5;
    }

    while (amount >= 1 && tempOnes > 0) {
      tempOnes--;
      amount -= 1;
    }

    // If we couldn't subtract the full amount, we need to make change
    if (amount > 0) {
      // Try to make change
      // This is a simplified algorithm and might not work for all cases
      // In a real game, you'd want a more sophisticated change-making algorithm

      // For example, if we need 3 more $1 bills but only have $5 bills
      if (amount <= 5 && tempFives > 0) {
        tempFives--;
        tempOnes += 5 - amount;
        amount = 0;
      }

      // Similar logic for other denominations...
    }

    if (amount == 0) {
      // Apply the changes
      ones = tempOnes;
      fives = tempFives;
      tens = tempTens;
      twenties = tempTwenties;
      fifties = tempFifties;
      hundreds = tempHundreds;
      recalculateTotal();
      return true;
    }

    return false; // Couldn't make exact change
  }
}

// Welcome Screen that shows for 2 seconds
class WelcomeScreen extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            Color(0xFFFFC080), // Lighter orange-yellow (center)
            Color(0xFFFCB366), // Middle orange-yellow
            Color(0xFFFD8D3C), // Darker orange (outer)
          ],
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Image.asset(
              'assets/images/circle.png', // Use your game logo here
              width: 180, // Reduced size
              height: 180, // Reduced size
              fit: BoxFit.contain,
            ),
            const SizedBox(height: 15), // Reduced spacing
            const Text(
              'Board Game',
              style: TextStyle(
                fontSize: 30, // Slightly reduced font size
                fontWeight: FontWeight.bold,
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 10.0,
                    color: Colors.black45,
                    offset: Offset(2.0, 2.0),
                  ),
                ],
              ),
            ),
            const SizedBox(height: 8), // Reduced spacing
            const Text(
              'Get ready for an exciting journey!',
              style: TextStyle(
                fontSize: 16, // Reduced font size
                color: Colors.white,
                shadows: [
                  Shadow(
                    blurRadius: 5.0,
                    color: Colors.black45,
                    offset: Offset(1.0, 1.0),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Character Selection Screen with auto-scrolling
class CharacterSelectionScreen extends StatefulWidget {
  final Function(List<PlayerData>) onGameStart;

  const CharacterSelectionScreen({Key? key, required this.onGameStart})
    : super(key: key);

  @override
  _CharacterSelectionScreenState createState() =>
      _CharacterSelectionScreenState();
}

class _CharacterSelectionScreenState extends State<CharacterSelectionScreen> {
  // List of available characters
  final List<Color> characterColors = [
    Colors.red,
    Colors.blue,
    Colors.green,
    Colors.orange,
    Colors.purple,
    Colors.teal,
    Colors.pink,
    Colors.amber,
  ];

  final List<String> characterNames = [
    'Player 1',
    'Player 2',
    'Player 3',
    'Player 4',
    'Player 5',
    'Player 6',
    'Player 7',
    'Player 8',
  ];

  // Character image paths
  final List<String> characterImagePaths = [
    'assets/images/ch1.png',
    'assets/images/ch2.png',
    'assets/images/ch3.png',
    'assets/images/ch4.png',
    'assets/images/ch5.png',
    'assets/images/ch6.png',
    'assets/images/ch7.png',
    'assets/images/ch8.png',
  ];

  // Selected players
  List<PlayerData> selectedPlayers = [];

  // Controller for adding new players
  final TextEditingController nameController = TextEditingController();
  int selectedCharacterIndex = 0;

  // Add scroll controller for grid
  final ScrollController _gridScrollController = ScrollController();

  @override
  void initState() {
    super.initState();
    // Add listener to the text controller to update UI when text changes
    nameController.addListener(() {
      setState(() {
        // This will rebuild the widget when text changes, enabling/disabling the button
      });
    });
  }

  @override
  void dispose() {
    nameController.dispose();
    _gridScrollController.dispose(); // Dispose the scroll controller
    super.dispose();
  }

  // Check if the Add Player button should be enabled
  bool canAddPlayer() {
    return nameController.text.trim().isNotEmpty &&
        selectedPlayers.length < 8 &&
        !selectedPlayers.any(
          (player) => player.characterIndex == selectedCharacterIndex,
        );
  }

  // Method to scroll to the specified character index
  void _scrollToCharacter(int index) {
    // Calculate position in grid
    // For a grid with 3 items per row, we need to calculate the row
    int row = index ~/ 3; // Integer division to get the row

    // Estimate the scroll position (adjust these values based on your layout)
    double itemHeight = 100.0; // Approximate height of each grid row
    double targetPosition = row * itemHeight;

    // Animate to the position
    if (_gridScrollController.hasClients) {
      _gridScrollController.animateTo(
        targetPosition,
        duration: Duration(milliseconds: 300),
        curve: Curves.easeInOut,
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: BoxDecoration(
        gradient: RadialGradient(
          center: Alignment.center,
          radius: 1.0,
          colors: [
            Color(0xFFFFC080), // Lighter orange-yellow (center)
            Color(0xFFFCB366), // Middle orange-yellow
            Color(0xFFFD8D3C), // Darker orange (outer)
          ],
        ),
      ),
      child: SafeArea(
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              const Text(
                'Select Your Characters',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                  shadows: [
                    Shadow(
                      blurRadius: 5.0,
                      color: Colors.black45,
                      offset: Offset(1.0, 1.0),
                    ),
                  ],
                ),
                textAlign: TextAlign.center,
              ),
              const SizedBox(height: 12),

              // Character selection
              Text(
                'Choose a character:',
                style: TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                  color: Colors.white,
                ),
              ),
              const SizedBox(height: 8),

              // Character grid - Now with auto-scrolling
              Container(
                height: 190, // Increased height for larger characters
                child: GridView.builder(
                  controller: _gridScrollController, // Add the controller here
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: 3, // 3 characters per row
                    childAspectRatio: 0.8, // Taller cards for characters
                    crossAxisSpacing: 8,
                    mainAxisSpacing: 8,
                  ),
                  itemCount: 8, // 8 characters
                  itemBuilder: (context, index) {
                    bool isSelected = selectedCharacterIndex == index;
                    bool isUsed = selectedPlayers.any(
                      (player) => player.characterIndex == index,
                    );

                    return GestureDetector(
                      onTap:
                          isUsed
                              ? null
                              : () {
                                setState(() {
                                  selectedCharacterIndex = index;
                                });
                              },
                      child: Container(
                        decoration: BoxDecoration(
                          color:
                              isUsed
                                  ? Colors.grey.withOpacity(0.5)
                                  : isSelected
                                  ? Colors.white.withOpacity(0.3)
                                  : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border:
                              isSelected
                                  ? Border.all(color: Colors.white, width: 2)
                                  : null,
                        ),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            // Character image - now larger
                            Container(
                              width: 60, // Larger image
                              height: 60, // Larger image
                              decoration: BoxDecoration(
                                borderRadius: BorderRadius.circular(10),
                                border: Border.all(
                                  color: characterColors[index],
                                  width: 2,
                                ),
                                color: Colors.white,
                              ),
                              child: ClipRRect(
                                borderRadius: BorderRadius.circular(8),
                                child: Image.asset(
                                  characterImagePaths[index],
                                  fit: BoxFit.cover,
                                ),
                              ),
                            ),
                            SizedBox(height: 8),
                            Text(
                              characterNames[index],
                              style: TextStyle(
                                color: Colors.white,
                                fontWeight: FontWeight.bold,
                                fontSize: 14,
                              ),
                            ),
                            if (isUsed)
                              Container(
                                margin: EdgeInsets.only(top: 4),
                                padding: EdgeInsets.symmetric(
                                  horizontal: 8,
                                  vertical: 2,
                                ),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.5),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                                child: Text(
                                  'Used',
                                  style: TextStyle(
                                    color: Colors.white,
                                    fontSize: 10,
                                  ),
                                ),
                              ),
                          ],
                        ),
                      ),
                    );
                  },
                ),
              ),

              const SizedBox(height: 12),

              // Name input
              Row(
                children: [
                  Expanded(
                    child: TextField(
                      controller: nameController,
                      decoration: InputDecoration(
                        labelText: 'Player Name',
                        filled: true,
                        fillColor: Colors.white.withOpacity(0.8),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(10),
                        ),
                        contentPadding: EdgeInsets.symmetric(
                          horizontal: 12,
                          vertical: 12,
                        ),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed:
                        canAddPlayer()
                            ? () {
                              setState(() {
                                // Add the current player with selected character
                                selectedPlayers.add(
                                  PlayerData(
                                    name: nameController.text.trim(),
                                    color:
                                        characterColors[selectedCharacterIndex],
                                    characterIndex: selectedCharacterIndex,
                                    imagePath:
                                        characterImagePaths[selectedCharacterIndex],
                                  ),
                                );
                                nameController.clear();

                                // Find next available character
                                int nextAvailableIndex = -1;
                                for (int i = 0; i < 8; i++) {
                                  if (!selectedPlayers.any(
                                    (player) => player.characterIndex == i,
                                  )) {
                                    nextAvailableIndex = i;
                                    break;
                                  }
                                }

                                if (nextAvailableIndex != -1) {
                                  selectedCharacterIndex = nextAvailableIndex;

                                  // Auto-scroll to the next available character
                                  WidgetsBinding.instance.addPostFrameCallback((
                                    _,
                                  ) {
                                    _scrollToCharacter(nextAvailableIndex);
                                  });
                                }
                              });
                            }
                            : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(
                        vertical: 12,
                        horizontal: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: const Text(
                      'Add Player',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 14,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 12),

              // Selected players list
              Expanded(
                child: Container(
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    borderRadius: BorderRadius.circular(10),
                  ),
                  padding: const EdgeInsets.all(8),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Selected Players (${selectedPlayers.length}/8):',
                        style: TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                      const SizedBox(height: 8),
                      Expanded(
                        child:
                            selectedPlayers.isEmpty
                                ? Center(
                                  child: Text(
                                    'Add at least 3 players to start',
                                    style: TextStyle(
                                      color: Colors.white70,
                                      fontStyle: FontStyle.italic,
                                    ),
                                  ),
                                )
                                : ListView.builder(
                                  itemCount: selectedPlayers.length,
                                  itemBuilder: (context, index) {
                                    final player = selectedPlayers[index];
                                    return Container(
                                      margin: const EdgeInsets.only(bottom: 8),
                                      padding: const EdgeInsets.all(8),
                                      decoration: BoxDecoration(
                                        color: Colors.white.withOpacity(0.8),
                                        borderRadius: BorderRadius.circular(8),
                                        border: Border.all(
                                          color: player.color,
                                          width: 2,
                                        ),
                                      ),
                                      child: Row(
                                        children: [
                                          // Show character image
                                          Container(
                                            width: 36,
                                            height: 36,
                                            decoration: BoxDecoration(
                                              borderRadius:
                                                  BorderRadius.circular(8),
                                              border: Border.all(
                                                color: player.color,
                                                width: 2,
                                              ),
                                            ),
                                            child: ClipRRect(
                                              borderRadius:
                                                  BorderRadius.circular(6),
                                              child: Image.asset(
                                                player.imagePath,
                                                fit: BoxFit.cover,
                                              ),
                                            ),
                                          ),
                                          const SizedBox(width: 8),
                                          Expanded(
                                            child: Text(
                                              '${player.name}',
                                              style: TextStyle(
                                                fontSize: 14,
                                                fontWeight: FontWeight.bold,
                                              ),
                                              overflow: TextOverflow.ellipsis,
                                            ),
                                          ),
                                          IconButton(
                                            icon: Icon(Icons.delete, size: 20),
                                            color: Colors.red,
                                            padding: EdgeInsets.all(4),
                                            constraints: BoxConstraints(),
                                            onPressed: () {
                                              setState(() {
                                                selectedPlayers.removeAt(index);
                                              });
                                            },
                                          ),
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

              const SizedBox(height: 12),

              // Start game button
              ElevatedButton(
                onPressed:
                    selectedPlayers.length < 2
                        ? null
                        : () {
                          widget.onGameStart(selectedPlayers);
                        },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: const EdgeInsets.symmetric(vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Start Game (${selectedPlayers.length}/2-8 Players)',
                  style: const TextStyle(
                    color: Colors.white,
                    fontSize: 16,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

// Modified CirclePatternPage to accept player data
class CirclePatternPage extends StatelessWidget {
  final List<PlayerData> players;

  const CirclePatternPage({Key? key, required this.players}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        // Orange radial gradient background
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.0,
            colors: [
              Color(0xFFFFC080), // Lighter orange-yellow (center)
              Color(0xFFFCB366), // Middle orange-yellow
              Color(0xFFFD8D3C), // Darker orange (outer)
            ],
          ),
        ),
        child: SafeArea(child: Center(child: CirclePattern(players: players))),
      ),
    );
  }
}

// Modified CirclePattern to use player data and money system
class CirclePattern extends StatefulWidget {
  final List<PlayerData> players;

  CirclePattern({Key? key, required this.players}) : super(key: key);

  @override
  _CirclePatternState createState() => _CirclePatternState();
}

class _CirclePatternState extends State<CirclePattern>
    with SingleTickerProviderStateMixin {
  final Color darkNavyColor = const Color(0xFF0E1625);

  // Animation controller for dice rolling
  late AnimationController _animationController;

  // Current dice values
  List<int> diceValues = [1, 6];

  // Current active player index
  int activePlayerIndex = 0;

  // Random for dice rolls
  final Random _random = Random();

  // Add these new properties for board positions
  final int totalBoardSquares = 40; // 4 corners + 36 squares (9 per side)
  Map<int, List<PlayerData>> boardPositions = {};

  // For action messages
  String? actionMessage;
  Timer? messageTimer;

  @override
  void initState() {
    super.initState();

    // Initialize animation controller
    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 500),
    );

    // Add status listener for when animation completes
    _animationController.addStatusListener((status) {
      if (status == AnimationStatus.completed) {
        _animationController.reset();

        // Calculate move after dice roll animation completes
        _movePlayer();
      }
    });

    // Initialize all players at the starting position (position 0)
    _initializePlayerPositions();
  }

  // New method to initialize player positions
  void _initializePlayerPositions() {
    // Clear existing positions
    boardPositions.clear();

    // Place all players at the starting position (0)
    boardPositions[0] = [];
    for (var player in widget.players) {
      boardPositions[0]?.add(player);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    messageTimer?.cancel();
    super.dispose();
  }

  // Updated dice roll method
  void _rollDice() {
    setState(() {
      // Start the animation
      _animationController.forward();

      // Generate random dice values between 1 and 6
      diceValues = [_random.nextInt(6) + 1, _random.nextInt(6) + 1];

      // The actual movement happens after animation completes in the listener
    });
  }

  // void _movePlayer() {
  //   // Get the current active player
  //   PlayerData activePlayer = widget.players[activePlayerIndex];

  //   // For testing purposes, we move the player by 1 step (incrementing the position)
  //   int diceTotal =
  //       1; // For testing, we are incrementing by 1 position at a time

  //   // Remove player from current position
  //   if (boardPositions.containsKey(activePlayer.position)) {
  //     boardPositions[activePlayer.position]?.remove(activePlayer);

  //     // If list is empty, remove the key
  //     if (boardPositions[activePlayer.position]?.isEmpty ?? true) {
  //       boardPositions.remove(activePlayer.position);
  //     }
  //   }

  //   // Increment the position by 1 for testing
  //   int newPosition = (activePlayer.position + diceTotal) % totalBoardSquares;
  //   activePlayer.position = newPosition;

  //   // Add player to new position
  //   if (!boardPositions.containsKey(newPosition)) {
  //     boardPositions[newPosition] = [];
  //   }
  //   boardPositions[newPosition]?.add(activePlayer);

  //   // Handle special actions based on landing square (you can customize this)
  //   _handleLandingAction(newPosition);

  //   setState(() {});
  // }

  void _movePlayer() {
    PlayerData activePlayer = widget.players[activePlayerIndex];

    int diceTotal = diceValues[0] + diceValues[1];

    // Remove player from current position
    if (boardPositions.containsKey(activePlayer.position)) {
      boardPositions[activePlayer.position]?.remove(activePlayer);

      // If list is empty, remove the key
      if (boardPositions[activePlayer.position]?.isEmpty ?? true) {
        boardPositions.remove(activePlayer.position);
      }
    }

    // Calculate new position and wrap around the board
    int newPosition = (activePlayer.position + diceTotal) % totalBoardSquares;
    activePlayer.position = newPosition;

    // Add player to new position
    if (!boardPositions.containsKey(newPosition)) {
      boardPositions[newPosition] = [];
    }
    boardPositions[newPosition]?.add(activePlayer);

    // Handle special actions based on landing square
    _handleLandingAction(newPosition);

    setState(() {});
  }

  void _handleLandingAction(int position) {
    PlayerData activePlayer = widget.players[activePlayerIndex];
    String message = '';

    // Just show a message based on where the player landed
    message = "${activePlayer.name} landed on square ${position}!";

    // Special case for jail square
    if (position == 20) {
      // Go to jail - move player to position 10
      _movePlayerToPosition(activePlayer, 10);
      message = "${activePlayer.name} is sent to Jail!";
    }

    if (position == 2) {
      // Show the popup when the player lands on position 2
      showDialog(
        context: context,
        builder: (BuildContext context) {
          return GamePopup(
            firstImagePath:
                'assets/rewards/chores_01.png', // Replace with your first image path
            secondImagePath:
                'assets/rewards/chores_02.png', // Replace with your second image path
            onClose: () {
              Navigator.of(context).pop(); // Close the dialog
              _movePlayerToPosition(
                activePlayer,
                10,
              ); // Optional: Move player to jail
              message =
                  "${activePlayer.name} fuck you!"; // Optional: Update message for jail
            },
          );
        },
      );
    }

    // Show the message for a few seconds
    if (message.isNotEmpty) {
      _showActionMessage(message);
    }

    // Update the UI
    setState(() {});
  }

  // Helper method to show an action message
  void _showActionMessage(String message) {
    setState(() {
      actionMessage = message;
    });

    // Clear the message after 3 seconds
    messageTimer?.cancel();
    messageTimer = Timer(Duration(seconds: 3), () {
      setState(() {
        actionMessage = null;
      });
    });
  }

  // Widget to display action messages
  Widget _buildActionMessage() {
    if (actionMessage == null) return SizedBox.shrink();

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      padding: EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      decoration: BoxDecoration(
        color: Colors.black87,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Text(
        actionMessage!,
        style: TextStyle(
          color: Colors.white,
          fontSize: 16,
          fontWeight: FontWeight.bold,
        ),
        textAlign: TextAlign.center,
      ),
    );
  }

  // Helper method to force-move a player to a specific position
  void _movePlayerToPosition(PlayerData player, int newPosition) {
    // Remove from current position
    if (boardPositions.containsKey(player.position)) {
      boardPositions[player.position]?.remove(player);
      if (boardPositions[player.position]?.isEmpty ?? true) {
        boardPositions.remove(player.position);
      }
    }

    // Update player position
    player.position = newPosition;

    // Add to new position
    if (!boardPositions.containsKey(newPosition)) {
      boardPositions[newPosition] = [];
    }
    boardPositions[newPosition]?.add(player);
  }

  // Updated method to move to next player's turn
  void _nextPlayerTurn() {
    setState(() {
      activePlayerIndex = (activePlayerIndex + 1) % widget.players.length;
    });
  }

  // New method to render player tokens on the board
  Widget _buildPlayerTokens() {
    return Stack(
      children: [
        for (var posEntry in boardPositions.entries)
          _positionPlayersOnBoard(posEntry.key, posEntry.value),
      ],
    );
  }

  // Method to calculate player token positions on the board
  Widget _positionPlayersOnBoard(int position, List<PlayerData> players) {
  // Get available board size
  final size = MediaQuery.of(context).size;
  final availableHeight = size.height - 240;
  final availableWidth = size.width - 10;
  final boardSize = availableWidth < availableHeight ? availableWidth : availableHeight;

  // Sizes for reference
  final regularSquareSize = boardSize / 14;
  final cornerSquareSize = boardSize / 8;

  // Calculate x and y coordinates based on position
  double x = 0;
  double y = 0;

  if (position == 0) {
    // Bottom right corner
    x = boardSize - cornerSquareSize / 2;
    y = boardSize - cornerSquareSize / 2;
  } else if (position < 10) {
    // Bottom row (moving left)
    int offset = position;
    double squareWidth = (boardSize - 2 * cornerSquareSize) / 9;
    
    // Center the player in each square
    x = boardSize - cornerSquareSize - (offset * squareWidth) - squareWidth / 2;
    y = boardSize - regularSquareSize / 2;
  } else if (position == 10) {
    // Bottom left corner
    x = cornerSquareSize / 2;
    y = boardSize - cornerSquareSize / 2;
  } else if (position < 20) {
    // Left column (moving up)
    int offset = position - 10;
    double squareHeight = (boardSize - 2 * cornerSquareSize) / 9;
    
    // Center the player in each square
    x = regularSquareSize / 2;
    y = boardSize - cornerSquareSize - (offset * squareHeight) - squareHeight / 2;
  } else if (position == 20) {
    // Top left corner
    x = cornerSquareSize / 2;
    y = cornerSquareSize / 2;
  } else if (position < 30) {
    // Top row (moving right)
    int offset = position - 20;
    double squareWidth = (boardSize - 2 * cornerSquareSize) / 9;
    
    // Center the player in each square
    x = cornerSquareSize + (offset * squareWidth) + squareWidth / 2;
    y = regularSquareSize / 2;
  } else if (position == 30) {
    // Top right corner
    x = boardSize - cornerSquareSize / 2;
    y = cornerSquareSize / 2;
  } else {
    // Right column (moving down)
    int offset = position - 30;
    double squareHeight = (boardSize - 2 * cornerSquareSize) / 9;
    
    // Center the player in each square
    x = boardSize - regularSquareSize / 2;
    y = cornerSquareSize + (offset * squareHeight) + squareHeight / 2;
  }

  // Calculate player token layout based on number of players
  // Center the row of player tokens
  double rowWidth = players.length * 24; // Each token is 20px wide with 2px margin on each side
  double startX = x - rowWidth / 2;

  // Render player tokens at the position
  return Positioned(
    left: startX,
    top: y - 10, // Keep the vertical offset to display above square center
    child: Row(
      mainAxisSize: MainAxisSize.min,
      children: players.map((player) {
        return Container(
          margin: EdgeInsets.symmetric(horizontal: 2),
          width: 20,
          height: 20,
          decoration: BoxDecoration(
            color: player.color,
            shape: BoxShape.circle,
            border: Border.all(color: Colors.white, width: 2),
            boxShadow: [
              BoxShadow(
                color: Colors.black26,
                blurRadius: 2,
                offset: Offset(1, 1),
              ),
            ],
          ),
          child: Center(
            child: Container(
              width: 14,
              height: 14,
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                image: DecorationImage(
                  image: AssetImage(player.imagePath),
                  fit: BoxFit.cover,
                ),
              ),
            ),
          ),
        );
      }).toList(),
    ),
  );
}

  // Helper method to create a border square with an image
  Widget _buildBorderSquare(
    String imagePath,
    double size, [
    bool isCorner = false,
  ]) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.cyan, width: 1.5),
        borderRadius: BorderRadius.circular(4),
        image: DecorationImage(image: AssetImage(imagePath), fit: BoxFit.cover),
        boxShadow:
            isCorner
                ? [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 2,
                    offset: Offset(0, 1),
                  ),
                ]
                : null,
      ),
    );
  }

  // Helper method to create active player display with character and dice
  Widget _buildActivePlayerDisplay(PlayerData player) {
    return Container(
      padding: EdgeInsets.all(8),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.7),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: player.color, width: 3),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          // Player character image
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(8),
              border: Border.all(color: player.color, width: 2),
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(6),
              child: Image.asset(player.imagePath, fit: BoxFit.cover),
            ),
          ),
          SizedBox(width: 10),
          // Player name
          Text(
            player.name,
            style: TextStyle(
              color: player.color,
              fontWeight: FontWeight.bold,
              fontSize: 16,
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to create a money display for a player
  Widget _buildMoneyDisplay(PlayerData player) {
    return Container(
      padding: EdgeInsets.all(12),
      margin: EdgeInsets.symmetric(horizontal: 10),
      width: double.infinity,
      decoration: BoxDecoration(
        color: Color(0xFFFFA07A), // Light salmon color
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white, width: 2),
        boxShadow: [
          BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(0, 2)),
        ],
      ),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Total money display
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(
                'Bank: \$${player.totalMoney}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                  color: Colors.black,
                ),
              ),
            ],
          ),
          SizedBox(height: 8),
          // Money denominations
          SingleChildScrollView(
            scrollDirection: Axis.horizontal,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceAround,
              children: [
                if (player.ones > 0) _buildMoneyItem(player.ones, 1),
                SizedBox(width: 8),
                if (player.fives > 0) _buildMoneyItem(player.fives, 5),
                SizedBox(width: 8),
                if (player.tens > 0) _buildMoneyItem(player.tens, 10),
                SizedBox(width: 8),
                if (player.twenties > 0) _buildMoneyItem(player.twenties, 20),
                SizedBox(width: 8),
                if (player.fifties > 0) _buildMoneyItem(player.fifties, 50),
                SizedBox(width: 8),
                if (player.hundreds > 0) _buildMoneyItem(player.hundreds, 100),
              ],
            ),
          ),
        ],
      ),
    );
  }

  // Helper method to display money denomination with image
  Widget _buildMoneyItem(int count, int value) {
    return Column(
      children: [
        Stack(
          alignment: Alignment.topRight,
          children: [
            // Money image
            Container(
              width: 50,
              height: 30,
              decoration: BoxDecoration(
                border: Border.all(color: Colors.black26),
                borderRadius: BorderRadius.circular(4),
              ),
              child: Image.asset(
                'assets/money/${value}.png',
                fit: BoxFit.cover,
              ),
            ),
            // Count badge
            Container(
              padding: EdgeInsets.all(4),
              decoration: BoxDecoration(
                color: Colors.red,
                shape: BoxShape.circle,
              ),
              child: Text(
                '$count',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          ],
        ),
        Text(
          '\$$value × $count',
          style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  // Helper method to create clickable dice
  Widget _buildDice(int value, bool isAnimating) {
    return GestureDetector(
      onTap: () => _rollDice(),
      child: Container(
        width: 60, // Larger size
        height: 60, // Larger size
        decoration: BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.circular(10),
          border: Border.all(color: Colors.black, width: 1),
          boxShadow: [
            BoxShadow(
              color: Colors.black26,
              blurRadius: 4,
              offset: Offset(2, 2),
            ),
          ],
        ),
        child: Center(child: _buildDiceDots(value)),
      ),
    );
  }

  // Helper method to draw dice dots based on value
  Widget _buildDiceDots(int value) {
    switch (value) {
      case 1:
        return Container(
          width: 12, // Larger dot
          height: 12, // Larger dot
          decoration: BoxDecoration(
            color: Colors.black,
            shape: BoxShape.circle,
          ),
        );
      case 2:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: _buildDot(),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(padding: EdgeInsets.only(left: 12), child: _buildDot()),
              ],
            ),
          ],
        );
      case 3:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.end,
              children: [
                Padding(
                  padding: EdgeInsets.only(right: 12),
                  child: _buildDot(),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [_buildDot()],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(padding: EdgeInsets.only(left: 12), child: _buildDot()),
              ],
            ),
          ],
        );
      case 4:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [_buildDot(), _buildDot()],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [_buildDot(), _buildDot()],
            ),
          ],
        );
      case 5:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [_buildDot(), _buildDot()],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [_buildDot()],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [_buildDot(), _buildDot()],
            ),
          ],
        );
      case 6:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [_buildDot(), _buildDot()],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [_buildDot(), _buildDot()],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [_buildDot(), _buildDot()],
            ),
          ],
        );
      default:
        return Container();
    }
  }

  // Helper method to create a single dot
  Widget _buildDot() {
    return Container(
      width: 8, // Larger dot
      height: 8, // Larger dot
      decoration: BoxDecoration(color: Colors.black, shape: BoxShape.circle),
    );
  }

  // Helper method to create inner square boxes with images
  Widget _buildInnerSquare({required String imagePath}) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        border: Border.all(color: Colors.red.withOpacity(0.8), width: 1.5),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: EdgeInsets.all(4),
        child: Image.asset(imagePath, fit: BoxFit.contain),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // Get active player
    final activePlayer = widget.players[activePlayerIndex];

    // For responsive sizing based on screen size
    final size = MediaQuery.of(context).size;

    // Calculate maximum width/height for a square board
    final availableHeight =
        size.height - 240; // Additional space for money display and dice
    final availableWidth = size.width - 10; // Account for horizontal padding

    // Use the smaller dimension to ensure board is square
    final boardSize =
        availableWidth < availableHeight ? availableWidth : availableHeight;

    // Calculate sizes for the grid layout
    final regularSquareSize =
        boardSize / 14; // Smaller size for regular squares
    final cornerSquareSize = boardSize / 8; // Larger size for corner squares
    final circleSize =
        boardSize * 0.2; // Smaller center image (reduced from 0.3)
    final gap = 2.0;
    final horizontalPadding = 1.0;

    // Define the image paths
    final List<String> cornerImages = [
      'assets/images/corner1.png',
      'assets/images/corner2.png',
      'assets/images/corner3.png',
      'assets/images/corner4.png',
    ];

    // Define images for all sides
    final List<String> topRowImages = List.generate(
      9,
      (index) => 'assets/images/top_${index + 1}.png',
    );

    final List<String> leftColImages = List.generate(
      9,
      (index) => 'assets/images/left_${index + 1}.png',
    );

    final List<String> rightColImages = List.generate(
      9,
      (index) => 'assets/images/right_${index + 1}.png',
    );

    final List<String> bottomRowImages = List.generate(
      9,
      (index) => 'assets/images/bottom_${index + 1}.png',
    );

    final String circleImage = 'assets/images/circle.png';

    return Padding(
      padding: EdgeInsets.symmetric(
        horizontal: horizontalPadding,
        vertical: 10,
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Current player display at top
          _buildActivePlayerDisplay(activePlayer),

          SizedBox(height: 8),

          // Game board container - explicitly square with fixed size
          Container(
            width: boardSize,
            height: boardSize,
            color: Colors.transparent,
            child: Stack(
              fit: StackFit.expand,
              children: [
                // TOP ROW
                Positioned(
                  top: 0,
                  left: 0,
                  right: 0,
                  height: cornerSquareSize,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      // Top-left corner (single larger square with image)
                      _buildBorderSquare(
                        cornerImages[0],
                        cornerSquareSize,
                        true,
                      ),
                      SizedBox(width: gap),

                      // Top middle (9 squares with images)
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(
                            9,
                            (index) => Expanded(
                              child: Container(
                                height: regularSquareSize,
                                margin: EdgeInsets.only(
                                  right: index < 8 ? gap : 0,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.cyan,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  image: DecorationImage(
                                    image: AssetImage(topRowImages[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: gap),
                      // Top-right corner (single larger square with image)
                      _buildBorderSquare(
                        cornerImages[1],
                        cornerSquareSize,
                        true,
                      ),
                    ],
                  ),
                ),

                // MIDDLE SECTION
                Positioned(
                  top: cornerSquareSize + gap,
                  left: 0,
                  right: 0,
                  bottom: cornerSquareSize + gap,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // Left column (9 squares with images)
                      Container(
                        width: regularSquareSize,
                        child: Column(
                          children: List.generate(
                            9,
                            (index) => Expanded(
                              child: Container(
                                margin: EdgeInsets.only(
                                  bottom: index < 8 ? gap : 0,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.cyan,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  image: DecorationImage(
                                    image: AssetImage(leftColImages[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      // Center space (for circle)
                      Expanded(
                        child: Container(
                          color: Colors.transparent,
                          child: Stack(
                            children: [
                              // Four square boxes inside the board with images
                              Positioned(
                                top: regularSquareSize,
                                left: regularSquareSize * 2,
                                child: _buildInnerSquare(
                                  imagePath: 'assets/images/box_image1.png',
                                ),
                              ),
                              Positioned(
                                top: regularSquareSize,
                                right: regularSquareSize * 2,
                                child: _buildInnerSquare(
                                  imagePath: 'assets/images/box_image2.png',
                                ),
                              ),
                              Positioned(
                                bottom: regularSquareSize,
                                left: regularSquareSize * 2,
                                child: _buildInnerSquare(
                                  imagePath: 'assets/images/box_image3.png',
                                ),
                              ),
                              Positioned(
                                bottom: regularSquareSize,
                                right: regularSquareSize * 2,
                                child: _buildInnerSquare(
                                  imagePath: 'assets/images/box_image4.png',
                                ),
                              ),

                              // Center circle with image (smaller)
                              Center(
                                child: Container(
                                  width: circleSize,
                                  height: circleSize,
                                  decoration: BoxDecoration(
                                    shape: BoxShape.circle,
                                    image: DecorationImage(
                                      image: AssetImage(circleImage),
                                      fit: BoxFit.cover,
                                    ),
                                    boxShadow: [
                                      BoxShadow(
                                        color: Colors.black.withOpacity(0.2),
                                        spreadRadius: 1,
                                        blurRadius: 4,
                                        offset: Offset(0, 2),
                                      ),
                                    ],
                                  ),
                                ),
                              ),
                            ],
                          ),
                        ),
                      ),

                      // Right column (9 squares with images)
                      Container(
                        width: regularSquareSize,
                        child: Column(
                          children: List.generate(
                            9,
                            (index) => Expanded(
                              child: Container(
                                margin: EdgeInsets.only(
                                  bottom: index < 8 ? gap : 0,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.cyan,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  image: DecorationImage(
                                    image: AssetImage(rightColImages[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),

                // BOTTOM ROW
                Positioned(
                  bottom: 0,
                  left: 0,
                  right: 0,
                  height: cornerSquareSize,
                  child: Row(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      // Bottom-left corner (single larger square with image)
                      _buildBorderSquare(
                        cornerImages[2],
                        cornerSquareSize,
                        true,
                      ),
                      SizedBox(width: gap),

                      // Bottom middle (9 squares with images)
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(
                            9,
                            (index) => Expanded(
                              child: Container(
                                height: regularSquareSize,
                                margin: EdgeInsets.only(
                                  right: index < 8 ? gap : 0,
                                ),
                                decoration: BoxDecoration(
                                  border: Border.all(
                                    color: Colors.cyan,
                                    width: 1.5,
                                  ),
                                  borderRadius: BorderRadius.circular(4),
                                  image: DecorationImage(
                                    image: AssetImage(bottomRowImages[index]),
                                    fit: BoxFit.cover,
                                  ),
                                ),
                              ),
                            ),
                          ),
                        ),
                      ),

                      SizedBox(width: gap),
                      // Bottom-right corner (single larger square with image)
                      _buildBorderSquare(
                        cornerImages[3],
                        cornerSquareSize,
                        true,
                      ),
                    ],
                  ),
                ),

                // ADD THIS: Player tokens overlay
                _buildPlayerTokens(),
              ],
            ),
          ),

          // ADD THIS: Action message
          _buildActionMessage(),

          SizedBox(height: 8),

          // Money display at the bottom
          _buildMoneyDisplay(activePlayer),

          SizedBox(height: 10),

          // Game controls - dice and next player button
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Dice container
              Expanded(
                child: Container(
                  margin: EdgeInsets.symmetric(horizontal: 10),
                  padding: EdgeInsets.symmetric(vertical: 10, horizontal: 16),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.8),
                    borderRadius: BorderRadius.circular(15),
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: Column(
                    children: [
                      Text(
                        "${activePlayer.name}'s Turn",
                        style: TextStyle(
                          fontWeight: FontWeight.bold,
                          fontSize: 16,
                          color: activePlayer.color,
                        ),
                      ),
                      SizedBox(height: 10),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          // Animated dice display - now clickable
                          AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: _animationController.value * 4 * pi,
                                child: _buildDice(diceValues[0], true),
                              );
                            },
                          ),
                          SizedBox(width: 20),
                          AnimatedBuilder(
                            animation: _animationController,
                            builder: (context, child) {
                              return Transform.rotate(
                                angle: _animationController.value * 4 * pi,
                                child: _buildDice(diceValues[1], true),
                              );
                            },
                          ),
                        ],
                      ),
                      SizedBox(height: 10),
                      // Tap hint
                      Text(
                        "Tap dice to roll",
                        style: TextStyle(
                          fontSize: 12,
                          color: Colors.black54,
                          fontStyle: FontStyle.italic,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Next player button
              Container(
                margin: EdgeInsets.only(right: 10),
                child: ElevatedButton(
                  onPressed: () => _nextPlayerTurn(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.green,
                    padding: EdgeInsets.symmetric(horizontal: 20, vertical: 15),
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(10),
                    ),
                  ),
                  child: Column(
                    children: [
                      Icon(Icons.arrow_forward, color: Colors.white),
                      SizedBox(height: 5),
                      Text(
                        "Next",
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class GamePopup extends StatefulWidget {
  final String firstImagePath;
  final String secondImagePath;
  final VoidCallback onClose;

  const GamePopup({
    Key? key,
    required this.firstImagePath,
    required this.secondImagePath,
    required this.onClose,
  }) : super(key: key);

  @override
  _GamePopupState createState() => _GamePopupState();
}

class _GamePopupState extends State<GamePopup> {
  double opacity1 = 0.0;
  double opacity2 = 0.0;

  @override
  void initState() {
    super.initState();
    // Show the first image immediately
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        opacity1 = 1.0;
      });
    });

    // Show the second image after 2 seconds
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        opacity2 = 1.0;
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent, // Transparent background for Dialog
      child: AnimatedContainer(
        duration: Duration(milliseconds: 500),
        curve: Curves.easeInOut,
        width: double.infinity, // Full width
        height:
            MediaQuery.of(context).size.height *
            0.5, // 50% of the screen height
        padding: EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: Colors.black.withOpacity(0.7), // Semi-transparent background
          borderRadius: BorderRadius.circular(12),
        ),
        child: Stack(
          children: [
            // First Image with Animation
            AnimatedOpacity(
              opacity: opacity1,
              duration: Duration(seconds: 1),
              child: Positioned.fill(
                child: Center(
                  child: Image.asset(
                    widget.firstImagePath,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            // Second Image with Animation (appears after 2 seconds)
            AnimatedOpacity(
              opacity: opacity2,
              duration: Duration(seconds: 1),
              child: Positioned.fill(
                child: Center(
                  child: Image.asset(
                    widget.secondImagePath,
                    fit: BoxFit.contain,
                  ),
                ),
              ),
            ),
            // Cross Icon Button (for closing the popup)
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.white, size: 30),
                onPressed: widget.onClose,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
