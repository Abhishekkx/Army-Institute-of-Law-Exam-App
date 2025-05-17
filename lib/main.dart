import 'package:flutter/material.dart';
import 'package:flutter_gemini/flutter_gemini.dart';
import 'dart:async';
import 'models/question.dart';
import 'widgets/question_widget.dart';
import 'widgets/sidebar_widget.dart';

// Updated API key for Gemini 2.0 Flash
const String apiKey = 'AIzaSyCl6b-m1JISa8QHErTntuohcL0CFrBZgRk';

void main() {
  // Initialize Gemini with the API key
  Gemini.init(
    apiKey: apiKey,
    enableDebugging: true,
  );
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        primarySwatch: Colors.blue,
        textTheme: const TextTheme(
          bodyMedium: TextStyle(fontSize: 16),
          headlineSmall: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
          bodySmall: TextStyle(fontSize: 14, color: Colors.grey),
        ),
        elevatedButtonTheme: ElevatedButtonThemeData(
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 16),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(8)),
          ),
        ),
      ),
      home: const StartScreen(),
    );
  }
}

class StartScreen extends StatelessWidget {
  const StartScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final padding = screenWidth * 0.05;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Army Institute of Law Entrance Exam'),
        backgroundColor: Colors.blue,
      ),
      body: Center(
        child: Padding(
          padding: EdgeInsets.all(padding),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                'Welcome to the Practice Test',
                style: TextStyle(
                  fontSize: screenWidth * 0.07,
                  fontWeight: FontWeight.bold,
                ),
                textAlign: TextAlign.center,
              ),
              SizedBox(height: padding),
              Text(
                'This test includes sections on English, General Knowledge, Legal Aptitude, and Logical Reasoning.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: screenWidth * 0.045,
                ),
              ),
              SizedBox(height: padding * 2),
              ElevatedButton(
                onPressed: () {
                  Navigator.pushReplacement(
                    context,
                    MaterialPageRoute(builder: (context) => const QuizScreen()),
                  );
                },
                style: ElevatedButton.styleFrom(
                  padding: EdgeInsets.symmetric(
                    vertical: padding,
                    horizontal: padding * 2,
                  ),
                  textStyle: TextStyle(
                    fontSize: screenWidth * 0.05,
                  ),
                ),
                child: const Text('Start Test'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class QuizScreen extends StatefulWidget {
  const QuizScreen({Key? key}) : super(key: key);

  @override
  State<QuizScreen> createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  int currentSection = 0;
  int currentQuestion = 0;
  int score = 0;
  int questionsAttempted = 0; // Track attempted questions
  int timeLeft = 1800;
  Timer? timer;
  String? selectedOption;
  bool isSubmitted = false;
  String? correctAnswer;
  String? explanation;
  bool isLoading = true;
  final List<Section> sections = [
    Section(name: 'English', questions: []),
    Section(name: 'General Knowledge', questions: []),
    Section(name: 'Legal Aptitude', questions: []),
    Section(name: 'Logical Reasoning', questions: []),
  ];
  final GlobalKey<ScaffoldState> _scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _loadQuestions();
  }

  void _startTimer() {
    timer?.cancel();
    timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      setState(() {
        if (timeLeft > 0) {
          timeLeft--;
        } else {
          _nextSection();
        }
      });
    });
  }

  Future<void> _loadQuestions() async {
    setState(() {
      isLoading = true;
    });

    try {
      print('Starting to load questions for all sections');
      List<Future> loadingFutures = [];
      for (final section in sections) {
        print('Loading questions for ${section.name}');
        loadingFutures.add(section.loadQuestions());
      }

      await Future.wait(loadingFutures);
      print('All sections loaded successfully');

      setState(() {
        isLoading = false;
        _startTimer();
      });
    } catch (e, stackTrace) {
      print('Error loading questions: $e');
      print('Stack trace: $stackTrace');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(
          content: Text('Error loading questions: $e'),
          backgroundColor: Colors.red,
        ),
      );

      setState(() {
        isLoading = false;
      });
    }
  }

  void _selectOption(String option) {
    setState(() {
      selectedOption = option;
      // Auto-submit on selection for immediate feedback
      _submitAnswer();
    });
  }

  void _submitAnswer() {
    if (selectedOption == null) return;

    setState(() {
      isSubmitted = true;
      questionsAttempted++;
      if (selectedOption == sections[currentSection].questions[currentQuestion].correct) {
        score++;
      } else {
        correctAnswer = sections[currentSection].questions[currentQuestion].correct;
        explanation = sections[currentSection].questions[currentQuestion].explanation;
      }
    });
  }

  void _nextQuestion() {
    if (!isSubmitted && selectedOption != null) {
      _submitAnswer();
    }
    setState(() {
      if (currentQuestion < sections[currentSection].questions.length - 1) {
        currentQuestion++;
        selectedOption = null;
        isSubmitted = false;
        correctAnswer = null;
        explanation = null;
      } else {
        _nextSection();
      }
    });
  }

  void _nextSection() {
    setState(() {
      if (currentSection < sections.length - 1) {
        currentSection++;
        currentQuestion = 0;
        timeLeft = 1800;
        selectedOption = null;
        isSubmitted = false;
        correctAnswer = null;
        explanation = null;
        _startTimer();
      } else {
        _endTest();
      }
    });
  }

  void _endTest() {
    timer?.cancel();
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Test Ended'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text('Your Score: $score/$questionsAttempted'),
            Text('Total Questions: ${sections.length * 50}'),
            Text('Sections Completed: $currentSection/${sections.length}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              Navigator.pushReplacement(
                context,
                MaterialPageRoute(builder: (context) => const StartScreen()),
              );
            },
            child: const Text('Return to Start'),
          ),
          TextButton(
            onPressed: () {
              Navigator.pop(context);
              setState(() {
                currentSection = 0;
                currentQuestion = 0;
                score = 0;
                questionsAttempted = 0;
                timeLeft = 1800;
                selectedOption = null;
                isSubmitted = false;
                correctAnswer = null;
                explanation = null;
                _loadQuestions();
              });
            },
            child: const Text('Restart Test'),
          ),
        ],
      ),
    );
  }

  void _jumpToQuestion(int sectionIndex, int questionIndex) {
    if (sectionIndex > currentSection) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(
          content: Text('Complete the current section first!'),
          backgroundColor: Colors.orange,
        ),
      );
      return;
    }

    setState(() {
      currentSection = sectionIndex;
      currentQuestion = questionIndex;
      selectedOption = null;
      isSubmitted = false;
      correctAnswer = null;
      explanation = null;
      if (questionIndex == 0) {
        timeLeft = 1800;
        _startTimer();
      }
    });

    Navigator.pop(context);
  }

  @override
  void dispose() {
    timer?.cancel();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;

    return Scaffold(
      key: _scaffoldKey,
      appBar: AppBar(
        title: Text(
          '${sections[currentSection].name} - Time: ${timeLeft ~/ 60}:${(timeLeft % 60).toString().padLeft(2, '0')}',
          style: TextStyle(
            fontWeight: FontWeight.bold,
            fontSize: screenWidth * 0.045,
          ),
        ),
        backgroundColor: Colors.blue,
        leading: IconButton(
          icon: Icon(
            Icons.menu,
            size: screenWidth * 0.07,
          ),
          onPressed: () => _scaffoldKey.currentState?.openDrawer(),
        ),
        actions: [
          IconButton(
            icon: Icon(
              Icons.refresh,
              size: screenWidth * 0.07,
            ),
            onPressed: isLoading ? null : _loadQuestions,
            tooltip: 'Reload Questions',
          ),
          IconButton(
            icon: Icon(
              Icons.stop,
              size: screenWidth * 0.07,
            ),
            onPressed: _endTest,
            tooltip: 'End Test',
          ),
        ],
      ),
      drawer: SidebarWidget(
        sections: sections,
        currentSection: currentSection,
        currentQuestion: currentQuestion,
        onJumpToQuestion: _jumpToQuestion,
      ),
      body: isLoading
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            SizedBox(height: screenWidth * 0.04),
            Text(
              'Loading questions...',
              style: TextStyle(fontSize: screenWidth * 0.045),
            ),
          ],
        ),
      )
          : sections[currentSection].questions.isEmpty
          ? Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              'No questions loaded for this section.',
              style: TextStyle(fontSize: screenWidth * 0.045),
            ),
            SizedBox(height: screenWidth * 0.04),
            ElevatedButton(
              onPressed: _loadQuestions,
              child: Text(
                'Retry Loading Questions',
                style: TextStyle(fontSize: screenWidth * 0.04),
              ),
            ),
          ],
        ),
      )
          : QuestionWidget(
        question: sections[currentSection].questions[currentQuestion],
        questionNumber: currentQuestion + 1,
        selectedOption: selectedOption,
        isSubmitted: isSubmitted,
        correctAnswer: correctAnswer,
        explanation: explanation,
        onSelectOption: _selectOption,
        onNext: _nextQuestion,
      ),
    );
  }
}