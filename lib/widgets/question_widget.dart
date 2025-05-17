import 'package:flutter/material.dart';
import '../models/question.dart';

class QuestionWidget extends StatefulWidget {
  final Question question;
  final int questionNumber;
  final String? selectedOption;
  final bool isSubmitted;
  final String? correctAnswer;
  final String? explanation;
  final Function(String) onSelectOption;
  final VoidCallback onNext;

  const QuestionWidget({
    Key? key,
    required this.question,
    required this.questionNumber,
    required this.selectedOption,
    required this.isSubmitted,
    required this.correctAnswer,
    required this.explanation,
    required this.onSelectOption,
    required this.onNext,
  }) : super(key: key);

  @override
  _QuestionWidgetState createState() => _QuestionWidgetState();
}

class _QuestionWidgetState extends State<QuestionWidget> with SingleTickerProviderStateMixin {
  late AnimationController _animationController;
  late Animation<double> _fadeAnimation;

  @override
  void initState() {
    super.initState();
    _animationController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 500),
    );
    _fadeAnimation = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _animationController, curve: Curves.easeIn),
    );
    _animationController.forward();
  }

  @override
  void dispose() {
    _animationController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final textScaleFactor = mediaQuery.textScaleFactor;

    return LayoutBuilder(
      builder: (context, constraints) {
        final padding = screenWidth * 0.04;
        final buttonHeight = screenWidth * 0.12;
        final fontSizeHeadline = screenWidth * 0.05 * textScaleFactor;
        final fontSizeOption = screenWidth * 0.04 * textScaleFactor;

        return FadeTransition(
          opacity: _fadeAnimation,
          child: Padding(
            padding: EdgeInsets.all(padding),
            child: SingleChildScrollView(
              child: Card(
                child: Padding(
                  padding: EdgeInsets.all(padding),
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        'Q${widget.questionNumber}: ${widget.question.question}',
                        style: TextStyle(
                          fontSize: fontSizeHeadline.clamp(16.0, 22.0),
                          fontWeight: FontWeight.bold,
                          color: Colors.black87,
                        ),
                        softWrap: true,
                        overflow: TextOverflow.visible,
                      ),
                      SizedBox(height: padding),
                      ...widget.question.options.map<Widget>((option) {
                        Color? buttonColor;
                        Color? textColor;
                        if (widget.isSubmitted) {
                          if (option == widget.question.correct) {
                            buttonColor = Colors.green[100];
                            textColor = Colors.green[900];
                          } else if (option == widget.selectedOption && option != widget.question.correct) {
                            buttonColor = Colors.red[100];
                            textColor = Colors.red[900];
                          } else {
                            buttonColor = Colors.white;
                            textColor = Colors.blue[700];
                          }
                        } else {
                          buttonColor = widget.selectedOption == option ? Colors.blue[100] : Colors.white;
                          textColor = widget.selectedOption == option ? Colors.blue[900] : Colors.blue[700];
                        }

                        return Padding(
                          padding: EdgeInsets.symmetric(vertical: padding / 2),
                          child: GestureDetector(
                            onTap: widget.isSubmitted ? null : () => widget.onSelectOption(option),
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 200),
                              width: double.infinity,
                              height: buttonHeight.clamp(48.0, 60.0),
                              decoration: BoxDecoration(
                                color: buttonColor,
                                border: Border.all(
                                  color: widget.isSubmitted && option == widget.question.correct
                                      ? Colors.green
                                      : Colors.blue,
                                ),
                                borderRadius: BorderRadius.circular(8),
                                boxShadow: [
                                  BoxShadow(
                                    color: Colors.black12,
                                    blurRadius: 4,
                                    offset: const Offset(0, 2),
                                  ),
                                ],
                              ),
                              child: Center(
                                child: Text(
                                  option,
                                  style: TextStyle(
                                    fontSize: fontSizeOption.clamp(14.0, 18.0),
                                    color: textColor,
                                  ),
                                  softWrap: true,
                                  overflow: TextOverflow.ellipsis,
                                  maxLines: 2,
                                ),
                              ),
                            ),
                          ),
                        );
                      }).toList(),
                      if (widget.isSubmitted) ...[
                        SizedBox(height: padding),
                        Text(
                          'Correct Answer: ${widget.question.correct}',
                          style: TextStyle(
                            fontSize: fontSizeOption.clamp(14.0, 16.0),
                            color: Colors.green[700],
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                        SizedBox(height: padding / 2),
                        Text(
                          'Explanation: ${widget.question.explanation}',
                          style: TextStyle(
                            fontSize: fontSizeOption.clamp(12.0, 14.0),
                            color: Colors.grey[700],
                          ),
                          softWrap: true,
                        ),
                      ],
                      SizedBox(height: padding),
                      Align(
                        alignment: Alignment.centerRight,
                        child: ElevatedButton(
                          onPressed: widget.selectedOption == null ? null : widget.onNext,
                          style: ElevatedButton.styleFrom(
                            backgroundColor: Colors.blue,
                            foregroundColor: Colors.white,
                            padding: EdgeInsets.symmetric(
                              horizontal: padding * 2,
                              vertical: padding,
                            ),
                          ),
                          child: Text(
                            'Next',
                            style: TextStyle(
                              fontSize: fontSizeOption.clamp(14.0, 16.0),
                            ),
                          ),
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }
}