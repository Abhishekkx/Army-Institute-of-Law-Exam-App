import 'package:flutter/material.dart';
import '../models/question.dart';

class SidebarWidget extends StatelessWidget {
  final List<Section> sections;
  final int currentSection;
  final int currentQuestion;
  final Function(int, int) onJumpToQuestion;

  const SidebarWidget({
    Key? key,
    required this.sections,
    required this.currentSection,
    required this.currentQuestion,
    required this.onJumpToQuestion,
  }) : super(key: key);

  @override
  Widget build(BuildContext context) {
    final mediaQuery = MediaQuery.of(context);
    final screenWidth = mediaQuery.size.width;
    final crossAxisCount = (screenWidth / 50).floor().clamp(5, 10);

    return Drawer(
      width: screenWidth * 0.75,
      child: Column(
        children: [
          DrawerHeader(
            decoration: const BoxDecoration(color: Colors.blue),
            child: Text(
              'Sections',
              style: TextStyle(
                color: Colors.white,
                fontSize: screenWidth * 0.06,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          Expanded(
            child: ListView(
              padding: EdgeInsets.zero,
              children: [
                for (int i = 0; i < sections.length; i++)
                  ListTile(
                    title: Text(
                      sections[i].name,
                      style: TextStyle(
                        fontWeight: i == currentSection ? FontWeight.bold : FontWeight.normal,
                        color: i == currentSection ? Colors.blue : Colors.black87,
                        fontSize: screenWidth * 0.045,
                      ),
                    ),
                    tileColor: i == currentSection ? Colors.blue[50] : null,
                    onTap: i == currentSection
                        ? () {
                      onJumpToQuestion(i, 0);
                      Navigator.pop(context);
                    }
                        : null,
                  ),
                const Divider(),
                Padding(
                  padding: EdgeInsets.all(screenWidth * 0.02),
                  child: Text(
                    'Questions',
                    style: TextStyle(
                      fontSize: screenWidth * 0.05,
                      fontWeight: FontWeight.bold,
                      color: Colors.black87,
                    ),
                  ),
                ),
                GridView.builder(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  gridDelegate: SliverGridDelegateWithFixedCrossAxisCount(
                    crossAxisCount: crossAxisCount,
                    childAspectRatio: 1,
                    crossAxisSpacing: screenWidth * 0.01,
                    mainAxisSpacing: screenWidth * 0.01,
                  ),
                  itemCount: sections.length * 50,
                  itemBuilder: (context, index) {
                    final sectionIndex = index ~/ 50;
                    final questionIndex = index % 50;
                    final isCurrent = sectionIndex == currentSection && questionIndex == currentQuestion;
                    final isEnabled = sectionIndex == currentSection;
                    return GestureDetector(
                      onTap: isEnabled
                          ? () {
                        onJumpToQuestion(sectionIndex, questionIndex);
                        Navigator.pop(context);
                      }
                          : null,
                      child: AnimatedContainer(
                        duration: const Duration(milliseconds: 200),
                        decoration: BoxDecoration(
                          color: isCurrent ? Colors.blue : (isEnabled ? Colors.grey[100] : Colors.grey[300]),
                          border: Border.all(color: isCurrent ? Colors.blue : Colors.grey),
                          borderRadius: BorderRadius.circular(4),
                          boxShadow: isCurrent
                              ? [
                            const BoxShadow(
                              color: Colors.black12,
                              blurRadius: 4,
                              offset: Offset(0, 2),
                            ),
                          ]
                              : [],
                        ),
                        child: Center(
                          child: Text(
                            '${questionIndex + 1}',
                            style: TextStyle(
                              color: isCurrent ? Colors.white : (isEnabled ? Colors.black87 : Colors.grey),
                              fontSize: screenWidth * 0.035,
                              fontWeight: isCurrent ? FontWeight.bold : FontWeight.normal,
                            ),
                          ),
                        ),
                      ),
                    );
                  },
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}