import 'package:flutter/material.dart';
import 'dart:math';
import 'dart:async';
import 'dart:math' show min;

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
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: showWelcome
            ? WelcomeScreen()
            : showCharacterSelection
                ? CharacterSelectionScreen(onGameStart: startGame)
                : CirclePatternPage(players: _selectedPlayers),
      ),
    );
  }
}

// Data class to hold player information
class PlayerData {
  final String name;
  final Color color;
  final int characterIndex;
  final String imagePath; // Added image path
  
  const PlayerData({
    required this.name,
    required this.color,
    required this.characterIndex,
    required this.imagePath,
  });
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

  const CharacterSelectionScreen({
    Key? key,
    required this.onGameStart,
  }) : super(key: key);

  @override
  _CharacterSelectionScreenState createState() => _CharacterSelectionScreenState();
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
    'Player ',
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
           !selectedPlayers.any((player) => player.characterIndex == selectedCharacterIndex);
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
                    bool isUsed = selectedPlayers.any((player) => player.characterIndex == index);
                    
                    return GestureDetector(
                      onTap: isUsed ? null : () {
                        setState(() {
                          selectedCharacterIndex = index;
                        });
                      },
                      child: Container(
                        decoration: BoxDecoration(
                          color: isUsed 
                            ? Colors.grey.withOpacity(0.5) 
                            : isSelected 
                              ? Colors.white.withOpacity(0.3) 
                              : Colors.white.withOpacity(0.1),
                          borderRadius: BorderRadius.circular(10),
                          border: isSelected
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
                        contentPadding: EdgeInsets.symmetric(horizontal: 12, vertical: 12),
                      ),
                    ),
                  ),
                  const SizedBox(width: 8),
                  ElevatedButton(
                    onPressed: canAddPlayer() ? () {
                      setState(() {
                        // Add the current player with selected character
                        selectedPlayers.add(
                          PlayerData(
                            name: nameController.text.trim(),
                            color: characterColors[selectedCharacterIndex],
                            characterIndex: selectedCharacterIndex,
                            imagePath: characterImagePaths[selectedCharacterIndex],
                          ),
                        );
                        nameController.clear();
                        
                        // Find next available character
                        int nextAvailableIndex = -1;
                        for (int i = 0; i < 8; i++) {
                          if (!selectedPlayers.any((player) => player.characterIndex == i)) {
                            nextAvailableIndex = i;
                            break;
                          }
                        }
                        
                        if (nextAvailableIndex != -1) {
                          selectedCharacterIndex = nextAvailableIndex;
                          
                          // Auto-scroll to the next available character
                          WidgetsBinding.instance.addPostFrameCallback((_) {
                            _scrollToCharacter(nextAvailableIndex);
                          });
                        }
                      });
                    } : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
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
                        child: selectedPlayers.isEmpty 
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
                                          borderRadius: BorderRadius.circular(8),
                                          border: Border.all(
                                            color: player.color,
                                            width: 2,
                                          ),
                                        ),
                                        child: ClipRRect(
                                          borderRadius: BorderRadius.circular(6),
                                          child: Image.asset(
                                            player.imagePath,
                                            fit: BoxFit.cover,
                                          ),
                                        ),
                                      ),
                                      const SizedBox(width: 8),
                                      Expanded(
                                        child: Text(
                                          '${player.name} (${characterNames[player.characterIndex]})',
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
                onPressed: selectedPlayers.length < 3
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
                  'Start Game (${selectedPlayers.length}/3-8 Players)',
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

  const CirclePatternPage({
    Key? key,
    required this.players,
  }) : super(key: key);

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
        child: SafeArea(
          child: Center(
            child: CirclePattern(players: players),
          ),
        ),
      ),
    );
  }
}

// Modified CirclePattern to use player data
class CirclePattern extends StatefulWidget {
  final List<PlayerData> players;

  CirclePattern({
    Key? key,
    required this.players,
  }) : super(key: key);

  @override
  _CirclePatternState createState() => _CirclePatternState();
}

class _CirclePatternState extends State<CirclePattern> with SingleTickerProviderStateMixin {
  final Color darkNavyColor = const Color(0xFF0E1625);

  // Animation controller for dice rolling
  late AnimationController _animationController;

  // Map of dice values for each player
  Map<int, List<int>> playerDiceValues = {};

  // Current active player
  int activePlayer = 0;

  // Random for dice rolls
  final Random _random = Random();

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
      }
    });

    // Initialize dice values for each player
    for (int i = 0; i < widget.players.length; i++) {
      playerDiceValues[i] = [1, 6]; // Default values
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Method to roll dice for a player
  void _rollDice(int playerIndex) {
    setState(() {
      activePlayer = playerIndex;

      // Start the animation
      _animationController.forward();

      // Generate random dice values between 1 and 6
      playerDiceValues[playerIndex] = [
        _random.nextInt(6) + 1,
        _random.nextInt(6) + 1,
      ];
    });
  }

  // Helper method to create a border square with an image
  Widget _buildBorderSquare(String imagePath, double size, [bool isCorner = false]) {
    return Container(
      width: size,
      height: size,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.cyan,
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(4),
        image: DecorationImage(
          image: AssetImage(imagePath),
          fit: BoxFit.cover,
        ),
        boxShadow: isCorner ? [
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            spreadRadius: 1,
            blurRadius: 2,
            offset: Offset(0, 1),
          )
        ] : null,
      ),
    );
  }

  // Helper method to create a player section with dice
  Widget _buildPlayerSection(PlayerData player, int playerIndex) {
    final diceValues = playerDiceValues[playerIndex] ?? [1, 6];
    
    return GestureDetector(
      onTap: () => _rollDice(playerIndex),
      child: Container(
        width: 100,
        height: 70, // Reduced height to avoid overflow
        decoration: BoxDecoration(
          border: Border.all(
              color: player.color,
              width: activePlayer == playerIndex ? 4 : 3
          ),
          borderRadius: BorderRadius.circular(10),
          color: Colors.white.withOpacity(0.8),
        ),
        child: Padding(
          padding: EdgeInsets.all(4), // Reduced padding
          child: Column(
            mainAxisSize: MainAxisSize.min,
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Player character image and name in a row
              Row(
                children: [
                  // Character image
                  Container(
                    width: 22, // Reduced size
                    height: 22, // Reduced size
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                        color: player.color,
                        width: 1,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(3),
                      child: Image.asset(
                        player.imagePath,
                        fit: BoxFit.cover,
                      ),
                    ),
                  ),
                  SizedBox(width: 4), // Reduced spacing
                  // Player name
                  Expanded(
                    child: Text(
                      player.name,
                      style: TextStyle(
                        color: player.color,
                        fontWeight: FontWeight.bold,
                        fontSize: 12, // Reduced font size
                      ),
                      overflow: TextOverflow.ellipsis,
                      maxLines: 1,
                    ),
                  ),
                ],
              ),

              SizedBox(height: 4), // Reduced spacing

              // Dice row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Use AnimatedBuilder to rotate the dice
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: activePlayer == playerIndex ? _animationController.value * 4 * pi : 0,
                        child: _buildDice(diceValues[0], activePlayer == playerIndex),
                      );
                    },
                  ),
                  SizedBox(width: 8), // Reduced spacing
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: activePlayer == playerIndex ? _animationController.value * 4 * pi : 0,
                        child: _buildDice(diceValues[1], activePlayer == playerIndex),
                      );
                    },
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to create a dice
  Widget _buildDice(int value, bool isAnimating) {
    return Container(
      width: 28, // Reduced size
      height: 28, // Reduced size
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(6),
        border: Border.all(color: Colors.black, width: 1),
        boxShadow: [
          BoxShadow(
            color: Colors.black26,
            blurRadius: 3,
            offset: Offset(2, 2),
          ),
        ],
      ),
      child: Center(
        child: _buildDiceDots(value),
      ),
    );
  }

  // Helper method to draw dice dots based on value
  Widget _buildDiceDots(int value) {
    switch (value) {
      case 1:
        return Container(
          width: 8, // Reduced size
          height: 8, // Reduced size
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
                  padding: EdgeInsets.only(right: 8),
                  child: _buildDot(),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: _buildDot(),
                ),
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
                  padding: EdgeInsets.only(right: 8),
                  child: _buildDot(),
                ),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDot(),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.start,
              children: [
                Padding(
                  padding: EdgeInsets.only(left: 8),
                  child: _buildDot(),
                ),
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
              children: [
                _buildDot(),
                _buildDot(),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDot(),
                _buildDot(),
              ],
            ),
          ],
        );
      case 5:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDot(),
                _buildDot(),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                _buildDot(),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDot(),
                _buildDot(),
              ],
            ),
          ],
        );
      case 6:
        return Column(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDot(),
                _buildDot(),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDot(),
                _buildDot(),
              ],
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.spaceEvenly,
              children: [
                _buildDot(),
                _buildDot(),
              ],
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
      width: 4, // Reduced size
      height: 4, // Reduced size
      decoration: BoxDecoration(
        color: Colors.black,
        shape: BoxShape.circle,
      ),
    );
  }

  // Helper method to create inner square boxes with images
  Widget _buildInnerSquare({required String imagePath}) {
    return Container(
      width: 80,
      height: 80,
      decoration: BoxDecoration(
        border: Border.all(
          color: Colors.red.withOpacity(0.8),
          width: 1.5,
        ),
        borderRadius: BorderRadius.circular(4),
      ),
      child: Padding(
        padding: EdgeInsets.all(4),
        child: Image.asset(
          imagePath,
          fit: BoxFit.contain,
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    // For responsive sizing based on screen size
    final size = MediaQuery.of(context).size;

    // Calculate maximum width/height for a square board
    final availableHeight = size.height - 140; // Reduced space for player sections
    final availableWidth = size.width - 10; // Account for horizontal padding

    // Use the smaller dimension to ensure board is square
    final boardSize = availableWidth < availableHeight ? availableWidth : availableHeight;

    // Calculate sizes for the grid layout
    final regularSquareSize = boardSize / 14; // Smaller size for regular squares
    final cornerSquareSize = boardSize / 8; // Larger size for corner squares
    final circleSize = boardSize * 0.3;
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
        9, (index) => 'assets/images/top_${index + 1}.png');

    final List<String> leftColImages = List.generate(
        9, (index) => 'assets/images/left_${index + 1}.png');

    final List<String> rightColImages = List.generate(
        9, (index) => 'assets/images/right_${index + 1}.png');

    final List<String> bottomRowImages = List.generate(
        9, (index) => 'assets/images/bottom_${index + 1}.png');

    final String circleImage = 'assets/images/circle.png';

    // Organize players for display
    final int playerCount = widget.players.length;
    
    // Create lists to hold player references - using indices instead of null
    List<int> topPlayerIndices = [];
    List<int> bottomPlayerIndices = [];
    
    // Add top player indices (0-1)
    for (int i = 0; i < min(2, playerCount); i++) {
      topPlayerIndices.add(i);
    }
    
    // Add bottom player indices (2-3)
    for (int i = 2; i < min(4, playerCount); i++) {
      bottomPlayerIndices.add(i);
    }

    return Padding(
      padding: EdgeInsets.symmetric(horizontal: horizontalPadding),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // Top players row
          Padding(
            padding: EdgeInsets.only(bottom: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                topPlayerIndices.length > 0
                  ? _buildPlayerSection(widget.players[topPlayerIndices[0]], topPlayerIndices[0])
                  : SizedBox(width: 100),
                topPlayerIndices.length > 1
                  ? _buildPlayerSection(widget.players[topPlayerIndices[1]], topPlayerIndices[1])
                  : SizedBox(width: 100),
              ],
            ),
          ),

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
                      _buildBorderSquare(cornerImages[0], cornerSquareSize, true),
                      SizedBox(width: gap),

                      // Top middle (9 squares with images)
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: List.generate(9, (index) =>
                              Expanded(
                                child: Container(
                                  height: regularSquareSize,
                                  margin: EdgeInsets.only(right: index < 8 ? gap : 0),
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
                              )
                          ),
                        ),
                      ),

                      SizedBox(width: gap),
                      // Top-right corner (single larger square with image)
                      _buildBorderSquare(cornerImages[1], cornerSquareSize, true),
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
                          children: List.generate(9, (index) =>
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(bottom: index < 8 ? gap : 0),
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
                              )
                          ),
                        ),
                      ),

                      // Center space (for circle)
                      Expanded(
                        child: Container(
                          color: Colors.transparent,
                        ),
                      ),

                      // Right column (9 squares with images)
                      Container(
                        width: regularSquareSize,
                        child: Column(
                          children: List.generate(9, (index) =>
                              Expanded(
                                child: Container(
                                  margin: EdgeInsets.only(bottom: index < 8 ? gap : 0),
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
                              )
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
                      _buildBorderSquare(cornerImages[2], cornerSquareSize, true),
                      SizedBox(width: gap),

                      // Bottom middle (9 squares with images)
                      Expanded(
                        child: Row(
                          crossAxisAlignment: CrossAxisAlignment.end,
                          children: List.generate(9, (index) =>
                              Expanded(
                                child: Container(
                                  height: regularSquareSize,
                                  margin: EdgeInsets.only(right: index < 8 ? gap : 0),
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
                              )
                          ),
                        ),
                      ),

                      SizedBox(width: gap),
                      // Bottom-right corner (single larger square with image)
                      _buildBorderSquare(cornerImages[3], cornerSquareSize, true),
                    ],
                  ),
                ),

                // Four square boxes inside the board with images
                // Top-left box
                Positioned(
                  top: cornerSquareSize + regularSquareSize,
                  left: regularSquareSize * 2,
                  child: _buildInnerSquare(
                    imagePath: 'assets/images/box_image1.png',
                  ),
                ),

                // Top-right box
                Positioned(
                  top: cornerSquareSize + regularSquareSize,
                  right: regularSquareSize * 2,
                  child: _buildInnerSquare(
                    imagePath: 'assets/images/box_image2.png',
                  ),
                ),

                // Bottom-left box
                Positioned(
                  bottom: cornerSquareSize + regularSquareSize,
                  left: regularSquareSize * 2,
                  child: _buildInnerSquare(
                    imagePath: 'assets/images/box_image3.png',
                  ),
                ),

                // Bottom-right box
                Positioned(
                  bottom: cornerSquareSize + regularSquareSize,
                  right: regularSquareSize * 2,
                  child: _buildInnerSquare(
                    imagePath: 'assets/images/box_image4.png',
                  ),
                ),

                // Center circle with image
                Positioned.fill(
                  child: Center(
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
                          )
                        ],
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Bottom players row
          Padding(
            padding: EdgeInsets.only(top: 2),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                bottomPlayerIndices.length > 0
                  ? _buildPlayerSection(widget.players[bottomPlayerIndices[0]], bottomPlayerIndices[0])
                  : SizedBox(width: 100),
                bottomPlayerIndices.length > 1
                  ? _buildPlayerSection(widget.players[bottomPlayerIndices[1]], bottomPlayerIndices[1])
                  : SizedBox(width: 100),
              ],
            ),
          ),

          // Extra players if more than 4 players
          if (playerCount > 4)
            Padding(
              padding: EdgeInsets.only(top: 8), // Reduced spacing
              child: Container(
                height: 70, // Reduced height
                child: ListView.builder(
                  scrollDirection: Axis.horizontal,
                  itemCount: playerCount - 4,
                  itemBuilder: (context, index) {
                    return Padding(
                      padding: EdgeInsets.symmetric(horizontal: 4), // Reduced spacing
                      child: _buildPlayerSection(widget.players[index + 4], index + 4),
                    );
                  },
                ),
              ),
            ),
        ],
      ),
    );
  }
}