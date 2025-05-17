import 'package:flutter_gemini/flutter_gemini.dart';
import 'dart:convert';
import '../services/gemini_service.dart';

class Question {
  final String question;
  final List<String> options;
  final String correct;
  final String explanation;

  Question({
    required this.question,
    required this.options,
    required this.correct,
    required this.explanation,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      question: json['question'],
      options: List<String>.from(json['options']),
      correct: json['correct'],
      explanation: json['explanation'],
    );
  }
}

class Section {
  final String name;
  List<Question> questions;

  Section({required this.name, required this.questions});

  Future<void> loadQuestions() async {
    // Initialize with empty list to avoid stale data
    questions = [];

    // Load mock questions temporarily
    questions = List.generate(50, (index) => Question(
      question: 'Sample $name Question ${index + 1}',
      options: ['Option A', 'Option B', 'Option C', 'Option D'],
      correct: 'Option A',
      explanation: 'This is a sample explanation for $name Question ${index + 1}.',
    ));

    print('Initialized ${questions.length} mock questions for $name');

    // Load real questions in the background
    try {
      final loadedQuestions = await GeminiService.loadQuestions(name);
      if (loadedQuestions.isNotEmpty) {
        // Replace mock questions with real ones
        questions = loadedQuestions;
        print('Successfully loaded ${questions.length} real questions for $name');
      } else {
        print('No real questions loaded for $name; retaining mock questions');
      }
    } catch (e, stackTrace) {
      print('Error loading questions for $name: $e');
      print('Stack trace: $stackTrace');
      // Retain mock questions as fallback
    }
  }
}