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

  // Add turn tracking
  int turnsCompleted = 0;

  int lapsCompleted = 0;

  // Add question history tracking
  List<QuestionHistoryItem> questionHistory = [];

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

  // Method to add completed turn
  void completeTurn() {
    turnsCompleted++;
  }

  // Method to add question to history
  void addQuestionToHistory(
    EducationQuestion question,
    int answeredIndex,
    bool wasCorrect,
  ) {
    questionHistory.add(
      QuestionHistoryItem(
        question: question,
        answeredIndex: answeredIndex,
        wasCorrect: wasCorrect,
      ),
    );
  }
}

// Class to store question history items
class QuestionHistoryItem {
  final EducationQuestion question;
  final int answeredIndex;
  final bool wasCorrect;

  QuestionHistoryItem({
    required this.question,
    required this.answeredIndex,
    required this.wasCorrect,
  });
}

// Add this code right after your imports

// Define reward types
enum ChoreRewardType {
  collectFromBank, // Collect money from the bank
  collectFromPlayers, // Collect money from all players
  collectFromParents, // Collect money from parents
  collectFromPlayerAhead, // Collect from players ahead of you
}

// Chore card model
class ChoreCard {
  final String title = "CHORES";
  final String instruction;
  final String firstImagePath; // First image (cleaning supplies)
  final ChoreRewardType rewardType;
  final int rewardAmount;
  final String targetType;

  ChoreCard({
    required this.instruction,
    required this.firstImagePath,
    required this.rewardType,
    required this.rewardAmount,
    required this.targetType,
  });
}

// Create map of positions to chore cards
Map<int, ChoreCard> choreCards = {
  2: ChoreCard(
    instruction: "Do the laundry and earn \$7 from each player ahead of you.",
    firstImagePath: "assets/rewards/chores_02.png",
    rewardType: ChoreRewardType.collectFromPlayerAhead,
    rewardAmount: 7,
    targetType: "each player ahead of you",
  ),

  6: ChoreCard(
    instruction: "Take the trash out home and earn \$3 from each player.",
    firstImagePath: "assets/rewards/chores_03.png",
    rewardType: ChoreRewardType.collectFromPlayers,
    rewardAmount: 3,
    targetType: "each player",
  ),

  12: ChoreCard(
    instruction: "Mop and sweep the floor and earn \$12 from the bank.",
    firstImagePath: "assets/rewards/chores_04.png",
    rewardType: ChoreRewardType.collectFromBank,
    rewardAmount: 12,
    targetType: "the bank",
  ),

  16: ChoreCard(
    instruction: "You washed the car, you earn \$10 from each player.",
    firstImagePath: "assets/rewards/chores_05.png",
    rewardType: ChoreRewardType.collectFromPlayers,
    rewardAmount: 10,
    targetType: "each player",
  ),

  22: ChoreCard(
    instruction: "Clean your refrigerator and earn \$5 from the bank.",
    firstImagePath: "assets/rewards/chores_06.png",
    rewardType: ChoreRewardType.collectFromBank,
    rewardAmount: 5,
    targetType: "the bank",
  ),

  26: ChoreCard(
    instruction: "Vacuum your bedroom and earn \$1 from each parent.",
    firstImagePath: "assets/rewards/chores_07.png",
    rewardType: ChoreRewardType.collectFromParents,
    rewardAmount: 1,
    targetType: "each parent",
  ),

  32: ChoreCard(
    instruction: "Clean bathroom and earn \$4 from the bank.",
    firstImagePath: "assets/rewards/chores_08.png",
    rewardType: ChoreRewardType.collectFromBank,
    rewardAmount: 4,
    targetType: "the bank",
  ),

  36: ChoreCard(
    instruction: "Clean kitchen and earn \$2 from parents.",
    firstImagePath: "assets/rewards/chores_09.png",
    rewardType: ChoreRewardType.collectFromParents,
    rewardAmount: 2,
    targetType: "parents",
  ),
};

enum QuestionCategory { history, science, math, english, spelling }

// Education Review question model
class EducationQuestion {
  final String question;
  final List<String> options;
  final int correctAnswerIndex; // Index of the correct answer in options list
  final QuestionCategory category;
  final String imagePath; // Path to the image file (edu_01.png, etc.)

  EducationQuestion({
    required this.question,
    required this.options,
    required this.correctAnswerIndex,
    required this.category,
    required this.imagePath,
  });
}

class EducationQuestionBank {
  // Random generator for questions
  static final Random _random = Random();

  // List of all history questions
  static final List<EducationQuestion> historyQuestions = [
    // Your existing history questions here...
    EducationQuestion(
      question:
          'What producer, director, screenplay writer and actor established their own production company on the former Army Military base, Fort McPherson in Atlanta, Georgia?',
      options: [
        'Ava Duvernay',
        'John Singleton',
        'Antoine Fuqua',
        'Tyler Perry',
        'Will Packer',
      ],
      correctAnswerIndex: 3,
      category: QuestionCategory.history,
      imagePath: 'assets/education/edu_02.png',
    ),

    EducationQuestion(
      question:
          'Name the female rapper, singer and actress who played in movies as a physical therapist and cab driver.',
      options: [
        'Dana Owens',
        'Cardi B',
        'Gloria “Glorilla” Woods',
        'Megan The Stallion',
        'Nicki Minaj',
      ],
      correctAnswerIndex: 0,
      category: QuestionCategory.history,
      imagePath: 'assets/education/edu_03.png',
    ),

    EducationQuestion(
      question:
          'What is the name of the country/pop singer who was a member of a female group who later became an actress in Dreamgirls and Obsessed movie?',
      options: [
        'Aretha Franklin',
        'Kelly Rowland',
        'Dolly Parton',
        'Beyonce Knowles-Carter',
      ],
      correctAnswerIndex: 3,
      category: QuestionCategory.history,
      imagePath: 'assets/education/edu_04.png',
    ),

    EducationQuestion(
      question:
          'Name three NBA players who played on the Los Angeles Lakers team and won championships.',
      options: [
        'Shaquille “Shaq” O’Neal, Kobe Bryant and Larry Bird',
        'LeBron James, Kobe Bryant and Michael Jordan',
        'Scottie Pippen Sr., Earvin “Magic” Johnson Jr., and Kobe Bryant',
        'Kobe Bryant, Shaquille “Shaq” O\'Neal and LeBron James',
      ],
      correctAnswerIndex: 3,
      category: QuestionCategory.history,
      imagePath: 'assets/education/edu_05.png',
    ),

    EducationQuestion(
      question:
          'Name the first black female gymnast that won gold medal awards during the 2012 and 2016 team and All-around Olympic Games in London and Rio de Janeiro.',
      options: [
        'Gabby Douglas',
        'Simone Biles',
        'Dianne Durham',
        'Jordyn Wieber',
      ],
      correctAnswerIndex: 0,
      category: QuestionCategory.history,
      imagePath: 'assets/education/edu_06.png',
    ),

    EducationQuestion(
      question:
          'Name two sisters from California who played professional American tennis and won double title championship gold medals awards in London in 2012.',
      options: [
        'Venus and Serena Jackson',
        'Manuela and Katerina Maleeva',
        'Serena and Venus Williams',
        'Agnieszka Radwanska and Serena Williams',
      ],
      correctAnswerIndex: 2,
      category: QuestionCategory.history,
      imagePath: 'assets/education/edu_07.png',
    ),

    EducationQuestion(
      question:
          'Who was born in Mississippi, employed as a writer, news anchor, actress, producer, and created OWN and founder of a leadership academy for young women in Africa?',
      options: [
        'Viola Davis',
        'Caroline Kennedy',
        'Oprah “Opah” Winfrey',
        'Melinda French Gates',
      ],
      correctAnswerIndex: 2,
      category: QuestionCategory.history,
      imagePath: 'assets/education/edu_08.png',
    ),

    EducationQuestion(
      question:
          'Who was a great writer, poet, actress, dancer, and recipient of the Pulitzer Prize and Presidential Medal of Freedom Award?',
      options: [
        'Shirley Caesar',
        'Angela Bassett',
        'Cicely Tyson',
        'Maya Angelo',
      ],
      correctAnswerIndex: 3,
      category: QuestionCategory.history,
      imagePath: 'assets/education/edu_09.png',
    ),

    EducationQuestion(
      question:
          'Who served as the district attorney in 2004, elected attorney general of California and became the 46th Vice President of the USA in 2021?',
      options: [
        'Barbara Bush',
        'Mary Jane McLeod Bethune',
        'Betty White',
        'Kamala Devi Harris',
        'Marilyn Monroe',
      ],
      correctAnswerIndex: 3,
      category: QuestionCategory.history,
      imagePath: 'assets/education/edu_10.png',
    ),

    EducationQuestion(
      question:
          'Who was the first black woman born in Brooklyn, New York to be elected to the United States Congress in 1968 and later became the first candidate to run for a major-party nomination for President of the USA?',
      options: [
        'Madam C. J. Walker',
        'Rosa Parks',
        'Shirley Chisholm',
        'Michelle Obama',
        'Eleanor Roosevelt',
      ],
      correctAnswerIndex: 2,
      category: QuestionCategory.history,
      imagePath: 'assets/education/edu_11.png',
    ),

    EducationQuestion(
      question: 'Who was the first black president of the United States?',
      options: [
        'President John Lewis',
        'President James Jefferson',
        'President Barack Obama',
        'None of the above.',
      ],
      correctAnswerIndex: 2,
      category: QuestionCategory.history,
      imagePath: 'assets/education/edu_12.png',
    ),

    EducationQuestion(
      question:
          'What are the names of four sororities belonging to the Divine Nine Black Greek Sororities and Fraternities?',
      options: [
        'Alpha Phi Alpha, Zeta Phi Beta, Delta Sigma Theta and Sigma Gamma Rho',
        'Delta Sigma Theta, Alpha Kappa Alpha, Omega Psi Phi and Kappa Alpha Psi',
        'Alpha Phi Alpha, Iota Phi Theta, Delta Sigma Theta and Alpha Kappa Alpha',
        'Alpha Kappa Alpha, Delta Sigma Theta, Sigma Gamma Rho and Zeta Phi Beta.',
      ],
      correctAnswerIndex: 3,
      category: QuestionCategory.history,
      imagePath: 'assets/education/edu_13.png',
    ),

    EducationQuestion(
      question: 'Who were the first person to create and fly an airplane?',
      options: [
        'The Simpsons sisters',
        'Johnson Brothers',
        'Wright Brothers',
        'None of the above',
      ],
      correctAnswerIndex: 2,
      category: QuestionCategory.history,
      imagePath: 'assets/education/edu_14.png',
    ),

    EducationQuestion(
      question: 'Who was Dr. Martin Luther King Jr?',
      options: [
        'A lawyer',
        'A Civil Rights Leader',
        'A pastor',
        'A Nobel Peace prize winner',
        'Both B, C, and D',
        'None of the above.',
      ],
      correctAnswerIndex: 4,
      category: QuestionCategory.history,
      imagePath: 'assets/education/edu_15.png',
    ),

    EducationQuestion(
      question:
          'What politician was born in Georgia and served as a veteran, governor and president of the USA?',
      options: [
        'President Ronald Regan',
        'President Andrew Jackson',
        'President James Earl Carter Jr.',
        'President Franklin Roosevelt',
      ],
      correctAnswerIndex: 2,
      category: QuestionCategory.history,
      imagePath: 'assets/education/edu_16.png',
    ),

    EducationQuestion(
      question: 'Who was the first astronaut to walk on the moon for NASA?',
      options: [
        'Andrew Jackson',
        'Thomas Wilson',
        'Neil Armstrong',
        'All the above.',
      ],
      correctAnswerIndex: 2,
      category: QuestionCategory.history,
      imagePath: 'assets/education/edu_17.png',
    ),
  ];

  // List of all science questions
  static final List<EducationQuestion> scienceQuestions = [
    EducationQuestion(
      question: 'What makes up a cloud in the sky?',
      options: [
        'Rain and snow particle on the ground.',
        'Dirt particles and rain floating in the sky.',
        'Water drops and ice crystals floating in the sky.',
        'None of the above.',
      ],
      correctAnswerIndex: 2,
      category: QuestionCategory.science,
      imagePath: 'assets/education/edu_18.png',
    ),

    EducationQuestion(
      question: 'What is the chemical compound name for NaCl?',
      options: ['Sugar', 'Salt', 'Water', 'All the above.'],
      correctAnswerIndex: 1,
      category: QuestionCategory.science,
      imagePath: 'assets/education/edu_19.png',
    ),

    EducationQuestion(
      question: 'What is the chemical compound name for H2O?',
      options: ['Sugar', 'Soap', 'Water', 'All the above.'],
      correctAnswerIndex: 2,
      category: QuestionCategory.science,
      imagePath: 'assets/education/edu_20.png',
    ),

    EducationQuestion(
      question: 'What are the two elements’ names for Ag and Na?',
      options: [
        'Gold and Sodium',
        'Silver and Sodium',
        'Gold and Nitrogen',
        'None of the above.',
      ],
      correctAnswerIndex: 1,
      category: QuestionCategory.science,
      imagePath: 'assets/education/edu_21.png',
    ),

    EducationQuestion(
      question: 'What is biology?',
      options: [
        'Study of musical instruments.',
        'Study of dance.',
        'Study of living things and their vital processes of life.',
        'None of the above.',
      ],
      correctAnswerIndex: 2,
      category: QuestionCategory.science,
      imagePath: 'assets/education/edu_22.png',
    ),

    EducationQuestion(
      question: 'What is an atom?',
      options: [
        'Smallest part of a substance that cannot be broken down chemically.',
        'Is a particle that consists of a nucleus and electrons surrounded by electrons.',
        'Both A and B.',
        'None of the above',
      ],
      correctAnswerIndex: 2,
      category: QuestionCategory.science,
      imagePath: 'assets/education/edu_23.png',
    ),
  ];

  // List of all math questions
  static final List<EducationQuestion> mathQuestions = [
    EducationQuestion(
      question:
          'If a is equal to 2 and b is equal to 3 solve the algebra problem.\n6a (2x3+2)=__',
      options: ['91', '95', '96', '89'],
      correctAnswerIndex: 2,
      category: QuestionCategory.math,
      imagePath: 'assets/education/edu_24.png',
    ),
    EducationQuestion(
      question:
          'If a is equal to 2 and b is equal to 3 solve the algebra problem.\n7 - a + 3 = __',
      options: ['7', '8', '9', '5'],
      correctAnswerIndex: 1,
      category: QuestionCategory.math,
      imagePath: 'assets/education/edu_25.png',
    ),
    EducationQuestion(
      question:
          'If a is equal to 2 and b is equal to 3 solve the algebra problem.\n4(b + 3 + 7) = __',
      options: ['15', '52', '49', '28'],
      correctAnswerIndex: 1,
      category: QuestionCategory.math,
      imagePath: 'assets/education/edu_26.png',
    ),
    EducationQuestion(
      question: 'What is the square root of the math problem?\n√96 = __',
      options: ['9.251', '9.797', '8.976', '9.716'],
      correctAnswerIndex: 1,
      category: QuestionCategory.math,
      imagePath: 'assets/education/edu_27.png',
    ),
    EducationQuestion(
      question: 'What is the square root of the math problem?\n√27 = __',
      options: ['3.876', '5.197', '5.297', '5.196'],
      correctAnswerIndex: 3,
      category: QuestionCategory.math,
      imagePath: 'assets/education/edu_28.png',
    ),
    EducationQuestion(
      question: 'What is the square root of the math problem?\n√900 = __',
      options: ['27', '30', '60', '10'],
      correctAnswerIndex: 1,
      category: QuestionCategory.math,
      imagePath: 'assets/education/edu_29.png',
    ),
    EducationQuestion(
      question:
          'What is the sum of the math multiplication problems?\n11 × 14 = __',
      options: ['104', '165', '154', '151'],
      correctAnswerIndex: 2,
      category: QuestionCategory.math,
      imagePath: 'assets/education/edu_30.png',
    ),
    EducationQuestion(
      question:
          'What is the sum of the math multiplication problems?\n105 × 13 = __',
      options: ['1264', '1345', '1367', '1365'],
      correctAnswerIndex: 3,
      category: QuestionCategory.math,
      imagePath: 'assets/education/edu_31.png',
    ),
    EducationQuestion(
      question:
          'What is the sum of the math multiplication problems?\n60 × 24 = __',
      options: ['978', '1141', '1139', '1140'],
      correctAnswerIndex: 3,
      category: QuestionCategory.math,
      imagePath: 'assets/education/edu_32.png',
    ),
    EducationQuestion(
      question:
          'What is the sum of the math multiplication problems?\n333 × 12 = __',
      options: ['4132', '3997', '3996', '3101'],
      correctAnswerIndex: 2,
      category: QuestionCategory.math,
      imagePath: 'assets/education/edu_33.png',
    ),

    EducationQuestion(
      question:
          'What is the sum of the math subtraction problem?\n1,967-652=__',
      options: ['1123', '2318', '1314', '1315'],
      correctAnswerIndex: 3,
      category: QuestionCategory.math,
      imagePath: 'assets/education/edu_34.png',
    ),

    EducationQuestion(
      question: 'What is the sum of the math subtraction problem?\n897-241=__',
      options: ['616', '687', '646', '656'],
      correctAnswerIndex: 3,
      category: QuestionCategory.math,
      imagePath: 'assets/education/edu_35.png',
    ),

    EducationQuestion(
      question: 'What is the sum of the math subtraction problem?\n719-501=__',
      options: ['309', '218', '123', 'None of the above'],
      correctAnswerIndex: 1,
      category: QuestionCategory.math,
      imagePath: 'assets/education/edu_36.png',
    ),

    EducationQuestion(
      question: 'What is the sum of the math addition problem?\n4317+ 1,241=__',
      options: ['7154', '6514', '5,558', '5517'],
      correctAnswerIndex: 2,
      category: QuestionCategory.math,
      imagePath: 'assets/education/edu_37.png',
    ),

    EducationQuestion(
      question: 'What is the sum of the math addition problem?\n114+231+347=__',
      options: ['567', '628', '692', '680'],
      correctAnswerIndex: 2,
      category: QuestionCategory.math,
      imagePath: 'assets/education/edu_38.png',
    ),

    EducationQuestion(
      question:
          'What is the sum of the following math multiplication problem?\n9x6=__',
      options: ['53', '54', '57', 'None of the above'],
      correctAnswerIndex: 1,
      category: QuestionCategory.math,
      imagePath: 'assets/education/edu_39.png',
    ),

    EducationQuestion(
      question:
          'What is the sum of the following math multiplication problem?\n12x10=__',
      options: ['130', '121', '120', 'None of the above'],
      correctAnswerIndex: 2,
      category: QuestionCategory.math,
      imagePath: 'assets/education/edu_40.png',
    ),

    EducationQuestion(
      question:
          'What is the sum of the following math multiplication problem?\n9x4=__',
      options: ['36', '45', '27', 'None of the above'],
      correctAnswerIndex: 0,
      category: QuestionCategory.math,
      imagePath: 'assets/education/edu_41.png',
    ),

    EducationQuestion(
      question:
          'What is the sum of the following math multiplication problem?\n8x7=__',
      options: ['36', '54', '56', 'None of the above'],
      correctAnswerIndex: 2,
      category: QuestionCategory.math,
      imagePath: 'assets/education/edu_42.png',
    ),

    EducationQuestion(
      question:
          'What is the sum of the following math subtraction problem?\n12-4=__',
      options: ['8', '6', '7', 'None of the above'],
      correctAnswerIndex: 0,
      category: QuestionCategory.math,
      imagePath: 'assets/education/edu_43.png',
    ),

    EducationQuestion(
      question:
          'What is the sum of the following math subtraction problem?\n89-31=__',
      options: ['47', '48', '50', 'None of the above'],
      correctAnswerIndex: 3,
      category: QuestionCategory.math,
      imagePath: 'assets/education/edu_44.png',
    ),

    EducationQuestion(
      question:
          'What is the sum of the following math subtraction problem?\n21-16=__',
      options: ['7', '4', '5', 'None of the above'],
      correctAnswerIndex: 2,
      category: QuestionCategory.math,
      imagePath: 'assets/education/edu_45.png',
    ),

    EducationQuestion(
      question:
          'What is the sum of the following math addition problem?\n19+67=__',
      options: ['83', '71', '86', 'None of the above'],
      correctAnswerIndex: 2,
      category: QuestionCategory.math,
      imagePath: 'assets/education/edu_46.png',
    ),

    EducationQuestion(
      question:
          'What is the sum of the following math addition problem?\n16+35=__',
      options: ['53', '51', '50', 'None of the above'],
      correctAnswerIndex: 1,
      category: QuestionCategory.math,
      imagePath: 'assets/education/edu_47.png',
    ),

    EducationQuestion(
      question:
          'What is the sum of the following math addition problem?\n22+13=__',
      options: ['37', '29', '35', 'None of the above'],
      correctAnswerIndex: 2,
      category: QuestionCategory.math,
      imagePath: 'assets/education/edu_48.png',
    ),
  ];

  // List of all English questions
  static final List<EducationQuestion> englishQuestions = [
    EducationQuestion(
      question: 'Jessica walked to the park. What is the verb in the sentence?',
      options: ['Walked', 'Jessica', 'To', 'None of the above'],
      correctAnswerIndex: 0,
      category: QuestionCategory.english,
      imagePath: 'assets/education/edu_49.png',
    ),

    EducationQuestion(
      question:
          'She crossed the street by herself. What are the pronouns in the sentence?',
      options: ['She', 'herself', 'by', 'Both A and B', 'None of the above'],
      correctAnswerIndex: 3,
      category: QuestionCategory.english,
      imagePath: 'assets/education/edu_50.png',
    ),

    EducationQuestion(
      question:
          'Would you like to come to my party? Is this sentence asking a question or making a statement?',
      options: ['Statement', 'Question', 'Both A and B', 'None of the above'],
      correctAnswerIndex: 1,
      category: QuestionCategory.english,
      imagePath: 'assets/education/edu_51.png',
    ),

    EducationQuestion(
      question:
          'Jaime is going to the store. What are the nouns in the sentence?',
      options: ['Store', 'Jaime', 'Jaime and store', 'None of the above'],
      correctAnswerIndex: 2,
      category: QuestionCategory.english,
      imagePath: 'assets/education/edu_52.png',
    ),

    EducationQuestion(
      question:
          'Mitchell won the basketball game. What are the nouns in the sentence?',
      options: [
        'Mitchell',
        'basketball and game',
        'A and B',
        'None of the above',
      ],
      correctAnswerIndex: 2,
      category: QuestionCategory.english,
      imagePath: 'assets/education/edu_53.png',
    ),

    EducationQuestion(
      question:
          'Place the correct word to make a complete sentence structure.\nDavid won the mathematics _______ award.',
      options: ['acheevement', 'achievement', 'archievement'],
      correctAnswerIndex: 1,
      category: QuestionCategory.english,
      imagePath: 'assets/education/edu_54.png',
    ),

    EducationQuestion(
      question:
          'Place the correct word to make a complete sentence structure.\nAnn _______ what dress she wanted to wear to the dance.',
      options: ['know', 'knew', 'knows'],
      correctAnswerIndex: 1,
      category: QuestionCategory.english,
      imagePath: 'assets/education/edu_55.png',
    ),

    EducationQuestion(
      question:
          'Place the correct word to make a complete sentence structure.\nChrissy _______ her package in the mail.',
      options: ['recieved', 'received', 'receved'],
      correctAnswerIndex: 1,
      category: QuestionCategory.english,
      imagePath: 'assets/education/edu_56.png',
    ),

    EducationQuestion(
      question:
          'Place the correct word to make a complete sentence structure.\nRalph _______ the yellow and red truck.',
      options: ['chose', 'choice', 'choose'],
      correctAnswerIndex: 0,
      category: QuestionCategory.english,
      imagePath: 'assets/education/edu_57.png',
    ),

    EducationQuestion(
      question:
          'Place the correct word to make a complete sentence structure.\nWendy _______ a new computer.',
      options: ['brought', 'buys', 'bought'],
      correctAnswerIndex: 2,
      category: QuestionCategory.english,
      imagePath: 'assets/education/edu_58.png',
    ),
  ];

  // List of all spelling questions
  static final List<EducationQuestion> spellingQuestions = [
    EducationQuestion(
      question: 'What is the correct Spelling word?',
      options: ['Embarrassed', 'Embareassed', 'Emborassed'],
      correctAnswerIndex: 0,
      category: QuestionCategory.spelling,
      imagePath: 'assets/education/edu_59.png',
    ),

    EducationQuestion(
      question: 'What is the correct Spelling word?',
      options: ['Calculater', 'Calkulator', 'Calculator'],
      correctAnswerIndex: 2,
      category: QuestionCategory.spelling,
      imagePath: 'assets/education/edu_60.png',
    ),

    EducationQuestion(
      question: 'What is the correct Spelling word?',
      options: ['Umbrela', 'Umbrilla', 'Umbrella'],
      correctAnswerIndex: 2,
      category: QuestionCategory.spelling,
      imagePath: 'assets/education/edu_61.png',
    ),

    EducationQuestion(
      question: 'What is the correct Spelling word?',
      options: ['Computer', 'Compater', 'Competer'],
      correctAnswerIndex: 0,
      category: QuestionCategory.spelling,
      imagePath: 'assets/education/edu_62.png',
    ),

    EducationQuestion(
      question: 'What is the correct Spelling word?',
      options: ['Refigerator', 'Refrigerator', 'Refragerator'],
      correctAnswerIndex: 1,
      category: QuestionCategory.spelling,
      imagePath: 'assets/education/edu_63.png',
    ),
  ];

  // Get a random history question
  static EducationQuestion getRandomHistoryQuestion() {
    return historyQuestions[_random.nextInt(historyQuestions.length)];
  }

  // Get a random science question
  static EducationQuestion getRandomScienceQuestion() {
    return scienceQuestions[_random.nextInt(scienceQuestions.length)];
  }

  // Get a random math question
  static EducationQuestion getRandomMathQuestion() {
    return mathQuestions[_random.nextInt(mathQuestions.length)];
  }

  // Get a random English question
  static EducationQuestion getRandomEnglishQuestion() {
    return englishQuestions[_random.nextInt(englishQuestions.length)];
  }

  // Get a random spelling question
  static EducationQuestion getRandomSpellingQuestion() {
    return spellingQuestions[_random.nextInt(spellingQuestions.length)];
  }

  // Get a random question from any category
  static EducationQuestion getRandomQuestion() {
    final allQuestions = [
      ...historyQuestions,
      ...scienceQuestions,
      ...mathQuestions,
      ...englishQuestions,
      ...spellingQuestions,
    ];
    return allQuestions[_random.nextInt(allQuestions.length)];
  }

  // Get a random question by specific category
  static EducationQuestion getRandomQuestionByCategory(
    QuestionCategory category,
  ) {
    switch (category) {
      case QuestionCategory.history:
        return getRandomHistoryQuestion();
      case QuestionCategory.science:
        return getRandomScienceQuestion();
      case QuestionCategory.math:
        return getRandomMathQuestion();
      case QuestionCategory.english:
        return getRandomEnglishQuestion();
      case QuestionCategory.spelling:
        return getRandomSpellingQuestion();
    }
  }
}

// Map of board positions that trigger education questions
final Set<int> educationQuestionPositions = {
  1,
  3,
  5,
  7,
  8,
  11,
  13,
  15,
  17,
  18,
  21,
  23,
  25,
  27,
  28,
  31,
  33,
  35,
  37,
  38,
};

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

// First, let's add a new Set to track the penalty square positions
final Set<int> penaltySquarePositions = {4, 14, 24, 34};

// Now, let's create a new PenaltyPopup widget for displaying the penalty message
class PenaltyPopup extends StatefulWidget {
  final VoidCallback onClose;
  final Function() onPenaltyApplied;

  const PenaltyPopup({
    Key? key,
    required this.onClose,
    required this.onPenaltyApplied,
  }) : super(key: key);

  @override
  _PenaltyPopupState createState() => _PenaltyPopupState();
}

class _PenaltyPopupState extends State<PenaltyPopup>
    with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();

    _animationController = AnimationController(
      vsync: this,
      duration: Duration(milliseconds: 800),
    );

    _scaleAnimation = Tween<double>(begin: 0.7, end: 1.0).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.elasticOut),
    );

    _animationController.forward();

    // Apply the penalty automatically after a short delay
    Future.delayed(Duration(seconds: 2), () {
      widget.onPenaltyApplied();
    });
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: AnimatedBuilder(
        animation: _animationController,
        builder: (context, child) {
          return Transform.scale(scale: _scaleAnimation.value, child: child);
        },
        child: Container(
          width: double.infinity,
          height: MediaQuery.of(context).size.height * 0.4,
          decoration: BoxDecoration(
            color: Color(0xFFFF6347), // Tomato red color
            borderRadius: BorderRadius.circular(12),
            border: Border.all(color: Colors.black, width: 3),
            boxShadow: [
              BoxShadow(color: Colors.black45, blurRadius: 10, spreadRadius: 2),
            ],
          ),
          child: Stack(
            children: [
              // Main content
              Center(
                child: Padding(
                  padding: const EdgeInsets.all(20.0),
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Warning icon
                      Icon(
                        Icons.warning_amber_rounded,
                        size: 80,
                        color: Colors.white,
                      ),

                      SizedBox(height: 20),

                      // Title
                      Text(
                        "OOPS!",
                        style: TextStyle(
                          fontSize: 40,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                          letterSpacing: 2,
                        ),
                      ),

                      SizedBox(height: 20),

                      // Message
                      Text(
                        "You landed on a penalty square.\nYou lose \$10!",
                        textAlign: TextAlign.center,
                        style: TextStyle(
                          fontSize: 22,
                          fontWeight: FontWeight.bold,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

              // Footer
              Positioned(
                bottom: 15,
                left: 0,
                right: 0,
                child: Center(
                  child: Text(
                    "SAY IT NOW SELF-LOVE KIDS LLC GAME",
                    style: TextStyle(
                      fontSize: 12,
                      fontWeight: FontWeight.bold,
                      color: Colors.white70,
                    ),
                  ),
                ),
              ),

              // Close button
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
    with TickerProviderStateMixin {
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

  // For animated movement
  bool isAnimatingMovement = false;
  int currentAnimationPosition = 0;
  int targetPosition = 0;
  Timer? animationTimer;

  // For smooth square scaling animations
  Map<int, AnimationController> squareAnimationControllers = {};
  Map<int, Animation<double>> squareScaleAnimations = {};

  @override
  void initState() {
    super.initState();

    // Initialize animation controller for dice
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

    // Place all players at position 39 (near the end of the board)
    boardPositions[39] = [];
    for (var player in widget.players) {
      player.position = 39; // Set initial position to 39
      boardPositions[39]?.add(player);
    }
  }

  @override
  void dispose() {
    _animationController.dispose();
    messageTimer?.cancel();
    animationTimer?.cancel();

    // Dispose all square animation controllers
    squareAnimationControllers.forEach((_, controller) {
      controller.dispose();
    });

    super.dispose();
  }

  // Updated dice roll method
  void _rollDice() {
    // Don't allow rolling if animation is in progress
    if (isAnimatingMovement) return;

    setState(() {
      // Start the animation
      _animationController.forward();

      // Generate random dice values between 1 and 6
      diceValues = [_random.nextInt(6) + 1, _random.nextInt(6) + 1];

      // The actual movement happens after animation completes in the listener
    });
  }

  // Create a method to handle the square animation
  void _animateSquare(int position, bool scaleUp) {
    // Create animation controller for this position if it doesn't exist
    if (!squareAnimationControllers.containsKey(position)) {
      squareAnimationControllers[position] = AnimationController(
        vsync: this,
        duration: Duration(
          milliseconds: 250,
        ), // Faster for smoother transitions
      );

      // Create animation with curve for smoother scaling
      squareScaleAnimations[position] = Tween<double>(
        begin: 1.0,
        end: 1.5,
      ).animate(
        CurvedAnimation(
          parent: squareAnimationControllers[position]!,
          curve: Curves.easeOutBack, // Bounce slightly for nicer effect
        ),
      );

      // Add listener to update UI when animation changes
      squareAnimationControllers[position]!.addListener(() {
        setState(() {
          // The animation value will be automatically used in build
        });
      });
    }

    // Animate to the target state
    if (scaleUp) {
      squareAnimationControllers[position]!.forward();
    } else {
      squareAnimationControllers[position]!.reverse();
    }
  }

  // Enhanced move player method with animation
  void _movePlayer() {
    if (isAnimatingMovement) return;

    // Get the current active player
    PlayerData activePlayer = widget.players[activePlayerIndex];

    // Calculate dice total
    int diceTotal = diceValues[0] + diceValues[1];

    // Show action message about the roll
    // _showActionMessage("${activePlayer.name} rolled ${diceTotal}!");

    // Store starting position for step counting
    int startPosition = activePlayer.position;

    // Calculate target position
    targetPosition = (startPosition + diceTotal) % totalBoardSquares;

    // Initialize animation position to start position
    currentAnimationPosition = startPosition;

    // Start animation
    isAnimatingMovement = true;

    // Animate the current square up
    _animateSquare(currentAnimationPosition, true);

    // Start the animation process
    _animateNextStep(0, diceTotal);
  }

  void _animateNextStep(int stepsTaken, int totalSteps) {
    // Cancel any existing timer
    animationTimer?.cancel();

    animationTimer = Timer(Duration(milliseconds: 300), () {
      // Animate previous square down
      _animateSquare(currentAnimationPosition, false);

      // Check if we've taken all steps needed
      if (stepsTaken >= totalSteps) {
        // We've reached the destination, end animation
        _finalizeMovement();
        return;
      }

      // Store previous position for lap detection
      int previousPosition = currentAnimationPosition;

      // Move to next position
      currentAnimationPosition =
          (currentAnimationPosition + 1) % totalBoardSquares;

      // Check if player has crossed the start position (0)
      if (previousPosition == totalBoardSquares - 1 &&
          currentAnimationPosition == 0) {
        // Player completed a lap, increment lap counter
        PlayerData activePlayer = widget.players[activePlayerIndex];
        activePlayer.lapsCompleted++;

        // Show notification message
        _showActionMessage(
          "${activePlayer.name} completed lap ${activePlayer.lapsCompleted}!",
        );

        // After completing lap 2, show question summary
        if (activePlayer.lapsCompleted == 2) {
          // Schedule this to happen after movement completes
          Future.delayed(Duration(milliseconds: 500), () {
            showDialog(
              context: context,
              barrierDismissible: false,
              builder: (BuildContext context) {
                return QuestionSummaryPopup(
                  player: activePlayer,
                  onClose: () {
                    Navigator.of(context).pop();
                  },
                );
              },
            );
          });
        }
      }

      // Update player position in the map
      _updatePlayerPositionInMap();

      // Animate new square up
      _animateSquare(currentAnimationPosition, true);

      // Continue animation for next step with incremented steps count
      _animateNextStep(stepsTaken + 1, totalSteps);
    });
  }

  void _updatePlayerPositionInMap() {
    PlayerData activePlayer = widget.players[activePlayerIndex];

    // Remove player from previous position
    if (boardPositions.containsKey(activePlayer.position)) {
      boardPositions[activePlayer.position]?.remove(activePlayer);

      // If list is empty, remove the key
      if (boardPositions[activePlayer.position]?.isEmpty ?? true) {
        boardPositions.remove(activePlayer.position);
      }
    }

    // Update player position
    activePlayer.position = currentAnimationPosition;

    // Add player to new position
    if (!boardPositions.containsKey(currentAnimationPosition)) {
      boardPositions[currentAnimationPosition] = [];
    }
    boardPositions[currentAnimationPosition]?.add(activePlayer);
  }

  void _finalizeMovement() {
    // Handle any special actions at the final position
    _handleLandingAction(targetPosition);

    // Reset animation state
    isAnimatingMovement = false;

    // Update UI
    setState(() {});
  }

  void _handleLandingAction(int position) {
    PlayerData activePlayer = widget.players[activePlayerIndex];

    print("${activePlayer.name} landed on square ${position}!");

    // Check if the position has a chore card
    if (choreCards.containsKey(position)) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return ChoreGamePopup(
            choreCard: choreCards[position]!,
            onChoreComplete: (ChoreCard card) {
              _applyChoreReward(activePlayer, card);
            },
            onClose: () {
              Navigator.of(context).pop();
            },
          );
        },
      );
    }
    // Check if the position has an education question
    else if (educationQuestionPositions.contains(position)) {
      _handleEducationQuestion(position);
    }
    // Check if it's a penalty square
    else if (penaltySquarePositions.contains(position)) {
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return PenaltyPopup(
            onPenaltyApplied: () {
              // Deduct $10 from the player
              activePlayer.subtractMoney(10);
              setState(() {}); // Update UI to reflect the change
            },
            onClose: () {
              Navigator.of(context).pop();
            },
          );
        },
      );
    }
    // Special case for jail square
    else if (position == 20) {
      _movePlayerToPosition(activePlayer, 10);
    }

    // Update the UI
    setState(() {});
  }

  // Add this method to apply chore rewards
  void _applyChoreReward(PlayerData activePlayer, ChoreCard choreCard) {
    int totalCollected = 0;

    switch (choreCard.rewardType) {
      case ChoreRewardType.collectFromBank:
        // Player earns money from the bank
        activePlayer.addMoney(choreCard.rewardAmount);
        totalCollected = choreCard.rewardAmount;
        break;

      case ChoreRewardType.collectFromPlayers:
        // Collect from all other players
        for (var player in widget.players) {
          if (player != activePlayer) {
            if (player.subtractMoney(choreCard.rewardAmount)) {
              activePlayer.addMoney(choreCard.rewardAmount);
              totalCollected += choreCard.rewardAmount;
            }
          }
        }
        break;

      case ChoreRewardType.collectFromPlayerAhead:
        // Collect from players ahead of the active player
        for (var player in widget.players) {
          if (player != activePlayer && _isPlayerAhead(activePlayer, player)) {
            if (player.subtractMoney(choreCard.rewardAmount)) {
              activePlayer.addMoney(choreCard.rewardAmount);
              totalCollected += choreCard.rewardAmount;
            }
          }
        }
        break;

      case ChoreRewardType.collectFromParents:
        // Simplified: Just add money as if from parents
        activePlayer.addMoney(choreCard.rewardAmount * 2); // Assuming 2 parents
        totalCollected = choreCard.rewardAmount * 2;
        break;
    }

    // Update UI to reflect money changes
    setState(() {});
  }

  // Helper method to check if one player is ahead of another on the board
  bool _isPlayerAhead(PlayerData referencePlayer, PlayerData otherPlayer) {
    // For a circular board we need to handle the wrap-around case
    if (otherPlayer.position > referencePlayer.position) {
      // Simple case: other player is at a higher position number
      return true;
    } else if (referencePlayer.position >
            totalBoardSquares - totalBoardSquares / 4 &&
        otherPlayer.position < totalBoardSquares / 4) {
      // Handle wrap-around: reference player near the end, other player near the start
      return true;
    }
    return false;
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
    // Don't allow changing players if animation is in progress
    if (isAnimatingMovement) return;

    // Increment turns completed for the current player
    PlayerData currentPlayer = widget.players[activePlayerIndex];
    currentPlayer.completeTurn();

    // Move to next player
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

  // Updated method to calculate player token positions with larger tokens
  Widget _positionPlayersOnBoard(int position, List<PlayerData> players) {
    // Get available board size
    final size = MediaQuery.of(context).size;
    final availableHeight = size.height - 240;
    final availableWidth = size.width - 10;
    final boardSize =
        availableWidth < availableHeight ? availableWidth : availableHeight;

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
      x =
          boardSize -
          cornerSquareSize -
          (offset * squareWidth) -
          squareWidth / 2;
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
      y =
          boardSize -
          cornerSquareSize -
          (offset * squareHeight) -
          squareHeight / 2;
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

    // INCREASED TOKEN SIZE (by 10px)
    final tokenSize = 30.0; // Was 20
    final innerImageSize = 22.0; // Was 14

    // Calculate player token layout based on number of players
    // Center the row of player tokens
    double rowWidth = players.length * (tokenSize + 4); // Each token + margin
    double startX = x - rowWidth / 2;

    // Render player tokens at the position
    return Positioned(
      left: startX,
      top: y - tokenSize / 2,
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children:
            players.map((player) {
              return Container(
                margin: EdgeInsets.symmetric(horizontal: 2),
                width: tokenSize,
                height: tokenSize,
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
                    width: innerImageSize,
                    height: innerImageSize,
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

  // Updated helper method to create a border square with an image and smooth scaling effect
  Widget _buildBorderSquare(
    String imagePath,
    double size, [
    bool isCorner = false,
    int? position,
  ]) {
    // Get scale factor from animation if available
    double scale = 1.0;

    if (position != null && squareScaleAnimations.containsKey(position)) {
      scale = squareScaleAnimations[position]!.value;
    }

    // Calculate highlight based on animation value
    bool isHighlighted =
        position != null &&
        squareScaleAnimations.containsKey(position) &&
        squareScaleAnimations[position]!.value > 1.1;

    return Transform.scale(
      scale: scale,
      alignment: Alignment.center,
      child: Container(
        width: size,
        height: size,
        decoration: BoxDecoration(
          border: Border.all(
            color:
                isHighlighted
                    ? Colors
                        .yellow // Highlight scaled squares
                    : Colors.cyan,
            width:
                isHighlighted
                    ? 2.5 // Thicker border for highlight
                    : 1.5, // Normal border
          ),
          borderRadius: BorderRadius.circular(4),
          image: DecorationImage(
            image: AssetImage(imagePath),
            fit: BoxFit.cover,
          ),
          boxShadow:
              isCorner || isHighlighted
                  ? [
                    BoxShadow(
                      color:
                          isHighlighted
                              ? Colors.yellow.withOpacity(
                                0.6,
                              ) // Glow effect for highlighted squares
                              : Colors.black.withOpacity(0.2),
                      spreadRadius: isHighlighted ? 2 : 1,
                      blurRadius: isHighlighted ? 6 : 2,
                      offset: Offset(0, 1),
                    ),
                  ]
                  : null,
        ),
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
                        20, // Position 20
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
                                child: Padding(
                                  padding: EdgeInsets.all(
                                    0.2,
                                  ), // Added 0.2 padding
                                  child: _buildBorderSquare(
                                    topRowImages[index],
                                    regularSquareSize,
                                    false,
                                    21 + index, // Positions 21-29
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
                        30, // Position 30
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
                                child: Padding(
                                  padding: EdgeInsets.all(
                                    0.2,
                                  ), // Added 0.2 padding
                                  child: _buildBorderSquare(
                                    leftColImages[index],
                                    regularSquareSize,
                                    false,
                                    19 - index, // Positions 19-11 (in reverse)
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
                                child: Padding(
                                  padding: EdgeInsets.all(
                                    0.2,
                                  ), // Added 0.2 padding
                                  child: _buildBorderSquare(
                                    rightColImages[index],
                                    regularSquareSize,
                                    false,
                                    31 + index, // Positions 31-39
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
                        10, // Position 10
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
                                child: Padding(
                                  padding: EdgeInsets.all(
                                    0.2,
                                  ), // Added 0.2 padding
                                  child: _buildBorderSquare(
                                    bottomRowImages[index],
                                    regularSquareSize,
                                    false,
                                    9 - index, // Positions 9-1 (in reverse)
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
                        0, // Position 0
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
                        isAnimatingMovement
                            ? "Animation in progress..."
                            : "Tap dice to roll",
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
                  onPressed:
                      isAnimatingMovement ? null : () => _nextPlayerTurn(),
                  style: ElevatedButton.styleFrom(
                    backgroundColor:
                        isAnimatingMovement ? Colors.grey : Colors.green,
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

class ChoreGamePopup extends StatefulWidget {
  final ChoreCard choreCard;
  final Function(ChoreCard) onChoreComplete;
  final VoidCallback onClose;

  const ChoreGamePopup({
    Key? key,
    required this.choreCard,
    required this.onChoreComplete,
    required this.onClose,
  }) : super(key: key);

  @override
  _ChoreGamePopupState createState() => _ChoreGamePopupState();
}

class _ChoreGamePopupState extends State<ChoreGamePopup>
    with SingleTickerProviderStateMixin {
  double opacity1 = 0.0;
  double opacity2 = 0.0;
  bool showChoreDetails = false;

  @override
  void initState() {
    super.initState();

    // Show the first image (cleaning supplies)
    Future.delayed(Duration(milliseconds: 500), () {
      setState(() {
        opacity1 = 1.0;
      });
    });

    // Show the second image (full chore card with instruction) after a delay
    Future.delayed(Duration(seconds: 2), () {
      setState(() {
        opacity1 = 0.0; // Fade out first image
        showChoreDetails = true; // Switch to showing chore details
      });

      // After transition, fade in chore details
      Future.delayed(Duration(milliseconds: 300), () {
        setState(() {
          opacity2 = 1.0;
        });
      });

      // Auto apply chore effect after showing the details
      Future.delayed(Duration(seconds: 3), () {
        widget.onChoreComplete(widget.choreCard);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      elevation: 0,
      child: Container(
        width: double.infinity,
        height: MediaQuery.of(context).size.height * 0.5,
        decoration: BoxDecoration(
          color: Color(0xFFFF7F24), // Orange background
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: 3),
        ),
        child: Stack(
          children: [
            // First animation: Cleaning supplies image
            if (!showChoreDetails)
              AnimatedOpacity(
                opacity: opacity1,
                duration: Duration(milliseconds: 500),
                child: Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      // Title
                      Padding(
                        padding: const EdgeInsets.only(bottom: 40.0),
                        child: Text(
                          "CHORES",
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            letterSpacing: 2,
                          ),
                        ),
                      ),

                      // Chore image
                      Container(
                        width: 150,
                        height: 150,
                        child: Image.asset(
                          widget.choreCard.firstImagePath,
                          fit: BoxFit.contain,
                        ),
                      ),
                    ],
                  ),
                ),
              ),

            // Second animation: Chore card with instruction
            if (showChoreDetails)
              AnimatedOpacity(
                opacity: opacity2,
                duration: Duration(milliseconds: 500),
                child: Center(
                  child: Padding(
                    padding: const EdgeInsets.all(20.0),
                    child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: [
                        // Title
                        Text(
                          "CHORES",
                          style: TextStyle(
                            fontSize: 40,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                            letterSpacing: 2,
                          ),
                        ),

                        SizedBox(height: 40),

                        // Instruction
                        Text(
                          widget.choreCard.instruction,
                          textAlign: TextAlign.center,
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.bold,
                            color: Colors.black,
                          ),
                        ),

                        SizedBox(height: 30),

                        // Chore Image
                        Container(
                          width: 120,
                          height: 120,
                          child: Image.asset(
                            widget.choreCard.firstImagePath,
                            fit: BoxFit.contain,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),

            // Footer
            Positioned(
              bottom: 15,
              left: 0,
              right: 0,
              child: Center(
                child: Text(
                  "SAY IT NOW SELF-LOVE KIDS LLC GAME",
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                ),
              ),
            ),

            // Close button
            Positioned(
              top: 10,
              right: 10,
              child: IconButton(
                icon: Icon(Icons.close, color: Colors.black, size: 30),
                onPressed: widget.onClose,
              ),
            ),
          ],
        ),
      ),
    );
  }
}

class EducationReviewPopup extends StatefulWidget {
  final EducationQuestion question;
  final Function(bool isCorrect, int selectedIndex)
  onAnswerSubmitted; // Updated to include selectedIndex
  final VoidCallback onClose;

  const EducationReviewPopup({
    Key? key,
    required this.question,
    required this.onAnswerSubmitted,
    required this.onClose,
  }) : super(key: key);

  @override
  _EducationReviewPopupState createState() => _EducationReviewPopupState();
}

class _EducationReviewPopupState extends State<EducationReviewPopup> {
  int? selectedAnswerIndex;
  bool hasSubmitted = false;
  bool isCorrect = false;
  bool showFeedback = false;

  String _getCategoryDisplayName(QuestionCategory category) {
    switch (category) {
      case QuestionCategory.history:
        return 'History';
      case QuestionCategory.science:
        return 'Science';
      case QuestionCategory.math:
        return 'Math';
      case QuestionCategory.english:
        return 'English Questions';
      case QuestionCategory.spelling:
        return 'Spelling';
      default:
        return 'Education Review';
    }
  }

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          color: Color(0xFF00CED1), // Turquoise color matching the images
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.black, width: 3),
        ),
        child: SingleChildScrollView(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              // Header
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 16),
                decoration: BoxDecoration(
                  color: Color(0xFF00CED1),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(10),
                    topRight: Radius.circular(10),
                  ),
                ),
                child: Column(
                  children: [
                    Text(
                      'EDUCATION REVIEW',
                      style: TextStyle(
                        fontSize: 28,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                    SizedBox(height: 8),
                    Text(
                      _getCategoryDisplayName(widget.question.category),
                      style: TextStyle(
                        fontSize: 22,
                        fontWeight: FontWeight.bold,
                        color: Colors.black,
                      ),
                      textAlign: TextAlign.center,
                    ),
                  ],
                ),
              ),

              // Question
              Padding(
                padding: EdgeInsets.all(16),
                child: Text(
                  widget.question.question,
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),

              // Options
              Padding(
                padding: EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                child: Column(
                  children: List.generate(
                    widget.question.options.length,
                    (index) => _buildOptionItem(index),
                  ),
                ),
              ),

              // Feedback message (shown after submission)
              if (showFeedback)
                Container(
                  margin: EdgeInsets.all(16),
                  padding: EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color:
                        isCorrect ? Colors.green.shade100 : Colors.red.shade100,
                    borderRadius: BorderRadius.circular(8),
                    border: Border.all(
                      color: isCorrect ? Colors.green : Colors.red,
                      width: 2,
                    ),
                  ),
                  child: Text(
                    isCorrect
                        ? 'Correct! You earned \$10.'
                        : 'Incorrect. You lost \$10. The correct answer was: ${widget.question.options[widget.question.correctAnswerIndex]}',
                    style: TextStyle(
                      fontSize: 16,
                      fontWeight: FontWeight.bold,
                      color:
                          isCorrect
                              ? Colors.green.shade800
                              : Colors.red.shade800,
                    ),
                    textAlign: TextAlign.center,
                  ),
                ),

              // Submit button
              if (!hasSubmitted)
                Padding(
                  padding: EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed:
                        selectedAnswerIndex != null ? _submitAnswer : null,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.red,
                      padding: EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                      disabledBackgroundColor: Colors.grey,
                    ),
                    child: Text(
                      'Submit Answer',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              // Continue button (after submission)
              if (hasSubmitted)
                Padding(
                  padding: EdgeInsets.all(16),
                  child: ElevatedButton(
                    onPressed: widget.onClose,
                    style: ElevatedButton.styleFrom(
                      backgroundColor: Colors.blue,
                      padding: EdgeInsets.symmetric(
                        horizontal: 32,
                        vertical: 16,
                      ),
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(10),
                      ),
                    ),
                    child: Text(
                      'Continue Game',
                      style: TextStyle(
                        color: Colors.white,
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                  ),
                ),

              // Footer - Publisher info
              Container(
                width: double.infinity,
                padding: EdgeInsets.symmetric(vertical: 10),
                alignment: Alignment.center,
                child: Text(
                  'SAY IT NOW SELF-LOVE KIDS LLC GAME',
                  style: TextStyle(
                    fontSize: 12,
                    fontWeight: FontWeight.bold,
                    color: Colors.black,
                  ),
                  textAlign: TextAlign.center,
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  // Helper method to build option items
  Widget _buildOptionItem(int index) {
    final isSelected = selectedAnswerIndex == index;
    final isCorrectAnswer = widget.question.correctAnswerIndex == index;
    final showCorrectHighlight = hasSubmitted && isCorrectAnswer;
    final showWrongHighlight = hasSubmitted && isSelected && !isCorrectAnswer;

    return Container(
      margin: EdgeInsets.only(bottom: 10),
      child: InkWell(
        onTap:
            hasSubmitted
                ? null
                : () {
                  setState(() {
                    selectedAnswerIndex = index;
                  });
                },
        child: Container(
          padding: EdgeInsets.all(12),
          decoration: BoxDecoration(
            color:
                showCorrectHighlight
                    ? Colors.green.shade100
                    : showWrongHighlight
                    ? Colors.red.shade100
                    : isSelected
                    ? Colors.white.withOpacity(0.7)
                    : Colors.white.withOpacity(0.3),
            borderRadius: BorderRadius.circular(8),
            border: Border.all(
              color:
                  showCorrectHighlight
                      ? Colors.green
                      : showWrongHighlight
                      ? Colors.red
                      : isSelected
                      ? Colors.blue
                      : Colors.black,
              width: isSelected ? 2 : 1,
            ),
          ),
          child: Row(
            children: [
              Container(
                width: 28,
                height: 28,
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: isSelected ? Colors.blue : Colors.white,
                  border: Border.all(color: Colors.black),
                ),
                child: Center(
                  child: Text(
                    String.fromCharCode(65 + index), // 'A', 'B', 'C', etc.
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isSelected ? Colors.white : Colors.black,
                    ),
                  ),
                ),
              ),
              SizedBox(width: 10),
              Expanded(
                child: Text(
                  widget.question.options[index],
                  style: TextStyle(
                    fontSize: 16,
                    color: Colors.black,
                    fontWeight:
                        isSelected ? FontWeight.bold : FontWeight.normal,
                  ),
                ),
              ),
              if (showCorrectHighlight)
                Icon(Icons.check_circle, color: Colors.green, size: 24),
              if (showWrongHighlight)
                Icon(Icons.cancel, color: Colors.red, size: 24),
            ],
          ),
        ),
      ),
    );
  }

  // Submit answer and check if correct
  void _submitAnswer() {
    if (selectedAnswerIndex != null) {
      setState(() {
        hasSubmitted = true;
        isCorrect = selectedAnswerIndex == widget.question.correctAnswerIndex;
        showFeedback = true;
      });

      // Notify parent about result with the selected index
      widget.onAnswerSubmitted(isCorrect, selectedAnswerIndex!);
    }
  }
}

// Extension to handle education review in the main game
extension EducationReviewHandler on _CirclePatternState {
  // Method to handle education question when landing on specific squares
  void _handleEducationQuestion(int position) {
    if (educationQuestionPositions.contains(position)) {
      // Get the current active player
      PlayerData activePlayer = widget.players[activePlayerIndex];

      // Get a random question
      EducationQuestion question = EducationQuestionBank.getRandomQuestion();

      // Show the education review popup
      showDialog(
        context: context,
        barrierDismissible: false,
        builder: (BuildContext context) {
          return EducationReviewPopup(
            question: question,
            onAnswerSubmitted: (bool isCorrect, int selectedIndex) {
              // Update player's money based on answer
              if (isCorrect) {
                activePlayer.addMoney(10); // Add $10 for correct answer
              } else {
                activePlayer.subtractMoney(10); // Subtract $10 for wrong answer
              }

              // Track this question in player's history
              activePlayer.addQuestionToHistory(
                question,
                selectedIndex, // Now using the parameter passed from the popup
                isCorrect,
              );

              // Update the UI
              setState(() {});
            },
            onClose: () {
              Navigator.of(context).pop(); // Close the dialog
            },
          );
        },
      );
    }
  }
}

class QuestionSummaryPopup extends StatelessWidget {
  final PlayerData player;
  final VoidCallback onClose;

  const QuestionSummaryPopup({
    Key? key,
    required this.player,
    required this.onClose,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Dialog(
      backgroundColor: Colors.transparent,
      insetPadding: EdgeInsets.symmetric(horizontal: 20, vertical: 24),
      child: Container(
        width: double.infinity,
        constraints: BoxConstraints(
          maxHeight: MediaQuery.of(context).size.height * 0.8,
        ),
        decoration: BoxDecoration(
          gradient: LinearGradient(
            begin: Alignment.topCenter,
            end: Alignment.bottomCenter,
            colors: [Color(0xFF00CED1), Color(0xFF008B8B)],
          ),
          borderRadius: BorderRadius.circular(12),
          border: Border.all(color: Colors.white, width: 2),
          boxShadow: [
            BoxShadow(color: Colors.black38, blurRadius: 10, spreadRadius: 1),
          ],
        ),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            // Header
            Container(
              width: double.infinity,
              padding: EdgeInsets.symmetric(vertical: 16),
              decoration: BoxDecoration(
                color: Colors.indigo.withOpacity(0.7),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(10),
                  topRight: Radius.circular(10),
                ),
              ),
              child: Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
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
                  SizedBox(width: 12),
                  Text(
                    '${player.name}\'s Learning Report',
                    style: TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                      color: Colors.white,
                    ),
                  ),
                ],
              ),
            ),

            // Content - Questions History
            Expanded(
              child:
                  player.questionHistory.isEmpty
                      ? Center(
                        child: Padding(
                          padding: const EdgeInsets.all(20.0),
                          child: Text(
                            'No questions answered yet!',
                            style: TextStyle(
                              fontSize: 18,
                              fontWeight: FontWeight.bold,
                              color: Colors.white,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        ),
                      )
                      : ListView.builder(
                        padding: EdgeInsets.all(16),
                        itemCount: player.questionHistory.length,
                        itemBuilder: (context, index) {
                          final item = player.questionHistory[index];
                          return _buildQuestionHistoryItem(item, index);
                        },
                      ),
            ),

            // Performance summary
            _buildPerformanceSummary(),

            // Close button
            Padding(
              padding: EdgeInsets.all(16),
              child: ElevatedButton(
                onPressed: onClose,
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  padding: EdgeInsets.symmetric(horizontal: 32, vertical: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(10),
                  ),
                ),
                child: Text(
                  'Continue Game',
                  style: TextStyle(
                    color: Colors.white,
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // Build individual question history item
  Widget _buildQuestionHistoryItem(QuestionHistoryItem item, int itemIndex) {
    return Container(
      margin: EdgeInsets.only(bottom: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.9),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: item.wasCorrect ? Colors.green : Colors.red,
          width: 2,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Question number and result
          Row(
            children: [
              Container(
                padding: EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: BoxDecoration(
                  color: item.wasCorrect ? Colors.green : Colors.red,
                  borderRadius: BorderRadius.circular(15),
                ),
                child: Text(
                  'Question ${itemIndex + 1}',
                  style: TextStyle(
                    color: Colors.white,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Spacer(),
              Icon(
                item.wasCorrect ? Icons.check_circle : Icons.cancel,
                color: item.wasCorrect ? Colors.green : Colors.red,
                size: 24,
              ),
              SizedBox(width: 4),
              Text(
                item.wasCorrect ? 'Correct' : 'Incorrect',
                style: TextStyle(
                  color: item.wasCorrect ? Colors.green : Colors.red,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),

          SizedBox(height: 12),

          // Question text
          Text(
            item.question.question,
            style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
          ),

          SizedBox(height: 12),

          // Your answer
          _buildAnswerItem(
            'Your answer:',
            item.question.options[item.answeredIndex],
            item.wasCorrect,
          ),

          // If incorrect, show correct answer
          if (!item.wasCorrect)
            _buildAnswerItem(
              'Correct answer:',
              item.question.options[item.question.correctAnswerIndex],
              true,
            ),
        ],
      ),
    );
  }

  // Build answer display
  Widget _buildAnswerItem(String label, String answer, bool isCorrect) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label, style: TextStyle(fontWeight: FontWeight.bold)),
          SizedBox(width: 8),
          Expanded(
            child: Text(
              answer,
              style: TextStyle(
                color: isCorrect ? Colors.green.shade800 : Colors.red.shade800,
                fontWeight: FontWeight.w500,
              ),
            ),
          ),
        ],
      ),
    );
  }

  // Build performance summary
  Widget _buildPerformanceSummary() {
    // Calculate statistics
    int totalQuestions = player.questionHistory.length;
    int correctAnswers =
        player.questionHistory.where((item) => item.wasCorrect).length;
    double percentage =
        totalQuestions > 0 ? (correctAnswers / totalQuestions) * 100 : 0;

    return Container(
      margin: EdgeInsets.symmetric(horizontal: 16),
      padding: EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: Colors.indigo.withOpacity(0.7),
        borderRadius: BorderRadius.circular(10),
      ),
      child: Column(
        children: [
          Text(
            'Performance Summary',
            style: TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.bold,
              color: Colors.white,
            ),
          ),
          SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              _buildStatItem('Total', totalQuestions.toString()),
              _buildStatItem('Correct', correctAnswers.toString()),
              _buildStatItem('Score', '${percentage.toStringAsFixed(0)}%'),
            ],
          ),
        ],
      ),
    );
  }

  // Build stat display
  Widget _buildStatItem(String label, String value) {
    return Column(
      children: [
        Text(label, style: TextStyle(fontSize: 14, color: Colors.white70)),
        SizedBox(height: 4),
        Text(
          value,
          style: TextStyle(
            fontSize: 24,
            fontWeight: FontWeight.bold,
            color: Colors.white,
          ),
        ),
      ],
    );
  }
}
