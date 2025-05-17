Army Institute of Law Entrance Exam Practice Test

A Flutter-based mobile application designed to help students prepare for the Army Institute of Law (AIL) entrance exam. The app provides a realistic practice test environment with multiple-choice questions across four sections: English, General Knowledge, Legal Aptitude, and Logical Reasoning. Powered by the Gemini API for dynamic question generation, the app offers a responsive, interactive, and user-friendly experience.
Table of Contents

Overview
Features
Tech Stack
Setup and Installation
Usage
Screenshots
Contributing
License

Overview
The AIL Entrance Exam Practice Test app simulates the actual exam format, delivering 50 questions per section (200 total) with a 30-minute timer per section. Questions are fetched in real-time from the Gemini API, with mock questions as a fallback for offline or API failure scenarios. The app is fully responsive, supports large font sizes, and includes features like immediate feedback, an end test option, and a polished UI with animations.
This project was developed to address specific requirements, including reliable question loading, responsive design, and enhanced user interactivity, making it a robust tool for AIL aspirants.
Features
The app includes the following features, implemented and tested as of May 17, 2025:
1. Dynamic Question Loading

Description: Questions are generated using the Gemini 2.0 Flash API for four sections: English (grammar, vocabulary), General Knowledge (current affairs, history), Legal Aptitude (legal reasoning), and Logical Reasoning (puzzles, syllogisms).
Details:
Each section has 50 unique questions, fetched in batches of 25 to optimize performance.
Robust error handling with retries (up to 3 attempts) and fallback to section-specific mock questions if the API fails.
Duplicate question prevention ensures variety.
Detailed logging for debugging in both debug and release builds.


Status: Tested in debug mode; release build testing pending.

2. Responsive UI

Description: The app adapts to various screen sizes, orientations, and font scaling settings for a consistent experience across devices.
Details:
Uses MediaQuery and LayoutBuilder for dynamic padding, text sizes, and button scaling.
Supports portrait and landscape modes, small/large screens, and large font sizes (e.g., maximum device font settings).
Text wrapping prevents overflow in questions and options.
Sidebar grid adjusts column count based on screen width.


Status: Fully functional in debug mode.

3. End Test Feature

Description: Users can end the test at any time and view a scorecard summarizing their performance.
Details:
"End Test" button (stop icon) in the app bar triggers a dialog.
Scorecard shows score (correct/attempted), total questions (200), and sections completed.
Options to return to the start screen or restart the test.
Automatically triggered when all sections are completed.


Status: Working in debug mode.

4. Option Feedback

Description: Immediate visual feedback on option selection with color-coded indicators and correct answer display.
Details:
Selecting an option auto-submits it, coloring the button green (correct) or red (wrong).
Correct answer and explanation appear below options after submission.
UI resets on moving to the next question.
Green border highlights the correct option for clarity.


Status: Fully implemented and tested.

5. Enhanced UI and Interactivity

Description: A modern, engaging UI with animations and consistent styling.
Details:
Timer Visibility: App bar title (section name and timer) scales down with FittedBox to remain visible even with large font sizes.
Colors: Vibrant palette (blue for primary, green for correct, red for wrong) with high contrast.
Animations:
Fade-in effect for new questions.
Smooth color transitions for option buttons and sidebar grid items.


Styling:
Cards with shadows for questions, start screen, and scorecard dialog.
Rounded corners and elevation for buttons and dialogs.
Highlighted active section/question in the sidebar.


Typography: Bold questions, clear options, and readable text across font sizes.


Status: Working in debug mode with no reported glitches.

Tech Stack

Framework: Flutter (Dart) for cross-platform mobile development.
API: Gemini 2.0 Flash (flutter_gemini package) for dynamic question generation.
State Management: Built-in StatefulWidget for simplicity.
UI Components:
Material widgets for native Android/iOS look and feel.
AnimatedContainer, FadeTransition for animations.
MediaQuery, LayoutBuilder for responsiveness.


Tools:
Flutter SDK (v3.x or later).
Dart (v3.x or later).
Android Studio/VS Code for development.


Dependencies:
flutter_gemini: ^0.x.x (check pubspec.yaml for exact version).
Standard Flutter packages (material, async).



Setup and Installation
Follow these steps to set up and run the project locally:
Prerequisites

Flutter SDK (v3.x or later) installed. Install Flutter.
Android Studio or VS Code with Flutter/Dart plugins.
An Android/iOS emulator or physical device for testing.
A valid Gemini API key (replace the placeholder in main.dart).

Steps

Clone the Repository:
git clone https://github.com/your-username/ail-entrance-exam-app.git
cd ail-entrance-exam-app


Install Dependencies:
flutter pub get


Configure API Key:

Open lib/main.dart.
Replace the apiKey constant with your Gemini API key:const String apiKey = 'YOUR_GEMINI_API_KEY';




Run the App:

Connect a device or start an emulator.
Run in debug mode:flutter run


Build a release APK:flutter build apk --release




Test the App:

Ensure questions load correctly (requires internet for Gemini API).
Test on different screen sizes, orientations, and font settings.



Notes

The provided API key in the code may be restricted. Obtain your own key from Google AI Studio.
Debug mode includes detailed logs for question loading; check the console for diagnostics.

Usage

Start the Test:

Launch the app and click "Start Test" on the welcome screen.
The app loads 50 questions per section (English, General Knowledge, Legal Aptitude, Logical Reasoning).


Answer Questions:

Select an option; it auto-submits with green (correct) or red (wrong) feedback.
View the correct answer and explanation below.
Click "Next" to proceed or use the sidebar to jump to questions in the current section.


Navigate Sections:

Each section has a 30-minute timer, displayed in the app bar.
Complete a section to move to the next or end the test early.


End Test:

Click the "End Test" (stop icon) button in the app bar.
View your scorecard with score, questions attempted, and sections completed.
Choose to return to the start screen or restart the test.


Sidebar:

Open the drawer (menu icon) to see sections and questions.
Jump to any question in the current section; future sections are locked until the current one is completed.



Screenshots
Note: Screenshots will be added to the repository soon. Below are placeholders for key screens.

Start Screen: Card-based welcome with a vibrant "Start Test" button.
Quiz Screen: Question with animated buttons, green/red feedback, and visible timer.
Sidebar: Responsive grid with highlighted current question.
Scorecard: Dialog with score and navigation options.

Contributing
Contributions are welcome! To contribute:

Fork the repository.
Create a feature branch (git checkout -b feature/your-feature).
Commit changes (git commit -m "Add your feature").
Push to the branch (git push origin feature/your-feature).
Open a pull request with a clear description.

Please ensure:

Code follows Flutter/Dart conventions.
Features are tested in debug and release modes.
No new dependencies without justification.
