import 'package:flutter_gemini/flutter_gemini.dart';
import 'dart:convert';
import 'dart:async';
import '../models/question.dart';

class GeminiService {
  static Future<List<Question>> loadQuestions(String sectionName) async {
    final gemini = Gemini.instance;
    final List<Question> allQuestions = [];
    const int questionsPerBatch = 25;
    const int totalQuestions = 50;
    const int maxRetries = 3;
    const Duration retryDelay = Duration(seconds: 3);

    for (int batch = 0; batch < (totalQuestions / questionsPerBatch).ceil(); batch++) {
      final prompt = '''
Generate $questionsPerBatch multiple-choice questions for the Army Institute of Law entrance exam section "$sectionName".
Each question must be relevant to the section:
- English: Focus on grammar, vocabulary, comprehension, sentence correction.
- General Knowledge: Cover current affairs (2024-2025), history, geography, Indian polity.
- Legal Aptitude: Include legal reasoning, constitutional law, basic legal principles.
- Logical Reasoning: Include puzzles, analogies, syllogisms, critical reasoning.
Each question must have 4 options, one correct answer, and an explanation for the correct answer.
Format the response as a valid JSON array with the following structure:
[
  {
    "question": "Question text here",
    "options": ["Option A", "Option B", "Option C", "Option D"],
    "correct": "Correct option text here",
    "explanation": "Explanation for why the correct answer is correct"
  }
]
Return only the JSON array with no additional text or markdown. Ensure the JSON is properly formatted and valid.
''';

      for (int attempt = 1; attempt <= maxRetries; attempt++) {
        try {
          print('Attempting API call for $sectionName (batch ${batch + 1}, attempt $attempt)');

          final result = await gemini.text(prompt);

          if (result == null || result.content == null) {
            print('Null or empty result for $sectionName (batch ${batch + 1}, attempt $attempt)');
            if (attempt < maxRetries) {
              print('Retrying after $retryDelay...');
              await Future.delayed(retryDelay);
            }
            continue;
          }

          String responseText = '';
          if (result.content is String) {
            responseText = result.content as String;
          } else if (result.content is Content && (result.content as Content).parts != null) {
            final parts = (result.content as Content).parts;
            if (parts != null && parts.isNotEmpty) {
              for (var part in parts) {
                if (part is TextPart) {
                  responseText = part.text ?? '';
                  break;
                }
              }
            }
          }

          if (responseText.isEmpty) {
            print('Empty response text for $sectionName (batch ${batch + 1}, attempt $attempt)');
            if (attempt < maxRetries) {
              print('Retrying after $retryDelay...');
              await Future.delayed(retryDelay);
            }
            continue;
          }
          print('Raw API response: $responseText');

          String? jsonText = _extractJsonFromText(responseText);
          if (jsonText == null) {
            print('No valid JSON found for $sectionName (batch ${batch + 1}, attempt $attempt)');
            if (attempt < maxRetries) {
              print('Retrying after $retryDelay...');
              await Future.delayed(retryDelay);
            }
            continue;
          }

          try {
            final List<dynamic> questions = jsonDecode(jsonText);
            if (_validateQuestions(questions)) {
              final newQuestions = questions.map((q) => Question.fromJson(q as Map<String, dynamic>)).toList();
              // Ensure no duplicate questions
              for (var question in newQuestions) {
                if (!allQuestions.any((q) => q.question == question.question)) {
                  allQuestions.add(question);
                }
              }
              print('Loaded ${newQuestions.length} unique questions for $sectionName (batch ${batch + 1})');
              break; // Success
            } else {
              print('Invalid question format for $sectionName (batch ${batch + 1}, attempt $attempt)');
              if (attempt < maxRetries) {
                print('Retrying after $retryDelay...');
                await Future.delayed(retryDelay);
              }
            }
          } catch (e) {
            print('Error parsing JSON for $sectionName (batch ${batch + 1}, attempt $attempt): $e');
            print('JSON text was: $jsonText');
            if (attempt < maxRetries) {
              print('Retrying after $retryDelay...');
              await Future.delayed(retryDelay);
            }
          }
        } catch (e) {
          print('Error in API call for $sectionName (batch ${batch + 1}, attempt $attempt): $e');
          if (attempt < maxRetries) {
            print('Retrying after $retryDelay...');
            await Future.delayed(retryDelay);
          }
        }
      }
    }

    if (allQuestions.isEmpty) {
      print('No questions loaded for $sectionName; falling back to mock questions');
      return _generateMockQuestions(sectionName, totalQuestions);
    } else {
      print('Total loaded questions for $sectionName: ${allQuestions.length}');
      if (allQuestions.length < totalQuestions) {
        final mockQuestions = _generateMockQuestions(sectionName, totalQuestions - allQuestions.length);
        allQuestions.addAll(mockQuestions);
        print('Added ${mockQuestions.length} mock questions to reach $totalQuestions total');
      }
      return allQuestions.take(totalQuestions).toList();
    }
  }

  static List<Question> _generateMockQuestions(String sectionName, int count) {
    List<Question> mockQuestions = [];
    switch (sectionName) {
      case 'English':
        mockQuestions = List.generate(count, (index) => Question(
          question: 'English Question ${index + 1}: Which sentence is correct?',
          options: [
            'She don\'t like ice cream.',
            'They was going to the store.',
            'He has been working here for five years.',
            'The children is playing in the park.'
          ],
          correct: 'He has been working here for five years.',
          explanation: 'Correct subject-verb agreement and tense usage.',
        ));
        break;
      case 'General Knowledge':
        mockQuestions = List.generate(count, (index) => Question(
          question: 'GK Question ${index + 1}: What is the capital of India?',
          options: ['Mumbai', 'New Delhi', 'Kolkata', 'Chennai'],
          correct: 'New Delhi',
          explanation: 'New Delhi is the capital city of India.',
        ));
        break;
      case 'Legal Aptitude':
        mockQuestions = List.generate(count, (index) => Question(
          question: 'Legal Question ${index + 1}: Which article guarantees equality?',
          options: ['Article 14', 'Article 19', 'Article 21', 'Article 32'],
          correct: 'Article 14',
          explanation: 'Article 14 ensures equality before the law.',
        ));
        break;
      case 'Logical Reasoning':
        mockQuestions = List.generate(count, (index) => Question(
          question: 'Logic Question ${index + 1}: If all A are B, and all B are C, then?',
          options: [
            'All A are C',
            'Some A are not C',
            'No A is C',
            'Cannot be determined'
          ],
          correct: 'All A are C',
          explanation: 'Transitive property of syllogisms.',
        ));
        break;
      default:
        mockQuestions = List.generate(count, (index) => Question(
          question: 'Sample $sectionName Question ${index + 1}',
          options: ['Option A', 'Option B', 'Option C', 'Option D'],
          correct: 'Option A',
          explanation: 'Sample explanation for $sectionName Question ${index + 1}.',
        ));
    }
    return mockQuestions;
  }

  static String? _extractJsonFromText(String text) {
    String cleanedText = text.trim();
    try {
      jsonDecode(cleanedText);
      return cleanedText;
    } catch (_) {}

    if (cleanedText.contains('```')) {
      cleanedText = cleanedText
          .replaceAll(RegExp(r'```json\s*'), '')
          .replaceAll(RegExp(r'```'), '')
          .trim();
      try {
        jsonDecode(cleanedText);
        return cleanedText;
      } catch (_) {}
    }

    final regexJsonArray = RegExp(r'\[\s*\{.*\}\s*\]', dotAll: true);
    final match = regexJsonArray.firstMatch(cleanedText);
    if (match != null) {
      final jsonText = match.group(0);
      try {
        jsonDecode(jsonText!);
        return jsonText;
      } catch (_) {}
    }

    final lines = cleanedText.split('\n');
    for (final line in lines) {
      final trimmedLine = line.trim();
      if (trimmedLine.startsWith('[') && trimmedLine.endsWith(']')) {
        try {
          jsonDecode(trimmedLine);
          return trimmedLine;
        } catch (_) {}
      }
    }

    print('Failed to extract JSON from text: $cleanedText');
    return null;
  }

  static bool _validateQuestions(List<dynamic> questions) {
    return questions.isNotEmpty &&
        questions.every((q) =>
        q is Map &&
            q.containsKey('question') &&
            q.containsKey('options') &&
            q.containsKey('correct') &&
            q.containsKey('explanation') &&
            q['options'] is List &&
            (q['options'] as List).length == 4);
  }
}