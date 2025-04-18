import 'package:flutter/material.dart';
import 'dart:math';

void main() {
  runApp(const GameScreen());
}

class GameScreen extends StatelessWidget {
  const GameScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Square Border Circle Pattern',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const CirclePatternPage(),
      debugShowCheckedModeBanner: false,
    );
  }
}

class CirclePatternPage extends StatelessWidget {
  const CirclePatternPage({Key? key}) : super(key: key);

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
            child: CirclePattern(),
          ),
        ),
      ),
    );
  }
}

class CirclePattern extends StatefulWidget {
  CirclePattern({Key? key}) : super(key: key);

  @override
  _CirclePatternState createState() => _CirclePatternState();
}

class _CirclePatternState extends State<CirclePattern> with SingleTickerProviderStateMixin {
  final Color darkNavyColor = const Color(0xFF0E1625);

  // Animation controller for dice rolling
  late AnimationController _animationController;

  // Random dice values
  int player1Dice1 = 1;
  int player1Dice2 = 6;
  int player2Dice1 = 1;
  int player2Dice2 = 6;
  int player3Dice1 = 1;
  int player3Dice2 = 6;
  int player4Dice1 = 1;
  int player4Dice2 = 6;

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
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  // Method to roll dice for a player
  void _rollDice(int playerNumber) {
    setState(() {
      activePlayer = playerNumber;

      // Start the animation
      _animationController.forward();

      // Generate random dice values between 1 and 6
      switch (playerNumber) {
        case 1:
          player1Dice1 = _random.nextInt(6) + 1;
          player1Dice2 = _random.nextInt(6) + 1;
          break;
        case 2:
          player2Dice1 = _random.nextInt(6) + 1;
          player2Dice2 = _random.nextInt(6) + 1;
          break;
        case 3:
          player3Dice1 = _random.nextInt(6) + 1;
          player3Dice2 = _random.nextInt(6) + 1;
          break;
        case 4:
          player4Dice1 = _random.nextInt(6) + 1;
          player4Dice2 = _random.nextInt(6) + 1;
          break;
      }
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
  Widget _buildPlayerSection(String playerName, Color playerColor, int playerNumber, int dice1Value, int dice2Value) {
    return GestureDetector(
      onTap: () => _rollDice(playerNumber),
      child: Container(
        width: 100,
        height: 72, // Increased height to avoid overflow
        decoration: BoxDecoration(
          border: Border.all(
              color: playerColor,
              width: activePlayer == playerNumber ? 4 : 3
          ),
          borderRadius: BorderRadius.circular(10),
          color: Colors.white.withOpacity(0.8),
        ),
        child: Padding(
          padding: EdgeInsets.symmetric(vertical: 2),
          child: Column(
            mainAxisSize: MainAxisSize.min, // Use minimum space needed
            mainAxisAlignment: MainAxisAlignment.center, // Center items instead of spaceEvenly
            children: [
              // Player name
              Text(
                playerName,
                style: TextStyle(
                  color: playerColor,
                  fontWeight: FontWeight.bold,
                  fontSize: 14, // Reduced font size
                ),
              ),

              SizedBox(height: 4), // Small fixed space between name and dice

              // Dice row
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  // Use AnimatedBuilder to rotate the dice
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: activePlayer == playerNumber ? _animationController.value * 4 * pi : 0,
                        child: _buildDice(dice1Value, activePlayer == playerNumber),
                      );
                    },
                  ),
                  SizedBox(width: 10),
                  AnimatedBuilder(
                    animation: _animationController,
                    builder: (context, child) {
                      return Transform.rotate(
                        angle: activePlayer == playerNumber ? _animationController.value * 4 * pi : 0,
                        child: _buildDice(dice2Value, activePlayer == playerNumber),
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
      width: 32, // Reduced size
      height: 32, // Reduced size
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
          width: 10,
          height: 10,
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
      width: 5, // Smaller dot
      height: 5, // Smaller dot
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

    // Note: We're now using specific image names for each shape
    // instead of a list of inner box images

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
                _buildPlayerSection("Player 1", Colors.red, 1, player1Dice1, player1Dice2),
                _buildPlayerSection("Player 2", Colors.blue, 2, player2Dice1, player2Dice2),
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
                _buildPlayerSection("Player 3", Colors.green, 3, player3Dice1, player3Dice2),
                _buildPlayerSection("Player 4", Colors.orange, 4, player4Dice1, player4Dice2),
              ],
            ),
          ),
        ],
      ),
    );
  }
}