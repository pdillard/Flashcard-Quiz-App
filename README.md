# Flashcard Quiz App

A modern iOS quiz application built with SwiftUI that tests your knowledge across multiple subjects with an interactive and intuitive interface, powered by Firebase for cloud storage and user-generated content.

## 📋 Description

The Flashcard Quiz App is an educational tool that quizzes users with randomized questions from various categories. Users can select their preferred topic, answer questions, and receive immediate feedback on their performance. With Firebase integration and a beautiful SwiftUI interface, users can now create and share their own flashcards, which are stored in the cloud and accessible across sessions. The app features smooth animations, an intuitive design, and a native iOS experience.

## 🎥 Video

This is the [link](https://youtu.be/WWNMS0cTSTc/) to module#1.

## ✨ Features

- **Modern SwiftUI Interface**: Beautiful, native iOS design with smooth animations and transitions
- **Multiple Categories**: Choose from Math, Science, History, Geography, Literature, or All Categories
- **Firebase Cloud Storage**: All flashcards are stored in Firebase Realtime Database
- **User-Generated Content**: Create and add your own custom flashcards to the database
- **Randomized Questions**: Questions are randomly selected to ensure variety in each quiz session
- **Score Tracking**: Real-time score tracking throughout the quiz with visual progress indicators
- **Immediate Feedback**: Get instant visual feedback on whether your answer is correct or incorrect
- **Performance Ratings**: Receive a performance rating based on your final score percentage
- **Case-Insensitive Answers**: Answer matching is not case-sensitive for user convenience
- **Customizable Quiz Length**: Choose how many questions you want to answer
- **Persistent Data**: Flashcards are saved to the cloud and available across all sessions
- **Responsive Design**: Optimized for all iOS devices (iPhone and iPad)
- **Dark Mode Support**: Seamless integration with iOS dark mode

## 🎯 Learning Objectives

This project was created as part of CSE 310 – Applied Programming to:
- Learn and apply Swift programming fundamentals
- Implement data structures (arrays, structs, enums)
- Practice object-oriented programming with classes
- Build a native iOS application with SwiftUI
- Implement user input validation and string manipulation
- Integrate Firebase Realtime Database for cloud storage
- Work with asynchronous operations and API calls
- Design intuitive user interfaces with modern iOS patterns
- Implement MVVM architecture for clean code structure

## 🚀 How to Run

### Prerequisites
- Xcode 14.0 or later
- iOS 16.0+ deployment target
- Swift 5.0 or later
- Firebase account and project setup
- Swift Package Manager (included with Xcode)

### Firebase Setup
1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add an iOS app to your Firebase project
3. Download the `GoogleService-Info.plist` file
4. Enable Firebase Realtime Database in the Firebase Console
5. Set database rules for read/write access

### Running in Xcode
1. Open Xcode
2. Create a new **iOS App** project
3. Set Language to **Swift** and Interface to **SwiftUI**
4. Add Firebase SDK via Swift Package Manager:
   - File → Add Package Dependencies
   - Enter: `https://github.com/firebase/firebase-ios-sdk`
   - Select FirebaseDatabase and FirebaseAuth (if using authentication)
5. Add the `GoogleService-Info.plist` to your project
6. Copy the SwiftUI views and models into your project
7. Configure Firebase in your App file
8. Press `⌘ + R` to build and run on simulator or device
9. Interact with the app through the iOS interface

### Running on iOS Device
1. Connect your iPhone or iPad via USB
2. Select your device in Xcode's device menu
3. Configure signing & capabilities with your Apple Developer account
4. Press `⌘ + R` to install and run on your device

## 📖 How to Use

1. **Home Screen**: Launch the app to see the main menu with beautiful card-based interface
2. **Create Flashcards**:
   - Tap "Create New Flashcard" button
   - Enter your question in the text field
   - Enter the answer
   - Select a category from the picker
   - Tap "Save" to upload to Firebase
   - Receive visual confirmation of success
3. **Take Quiz**:
   - Tap "Start Quiz" button
   - Select a category from the list
   - Set the number of questions using the stepper control
   - Tap "Begin" to start
   - Read each question and type your answer
   - Tap "Submit" to check your answer
   - See visual feedback (green for correct, red for incorrect)
   - View your progress bar at the top
   - Review final results with animated score reveal

### App Screenshots
*(Screenshots would typically be included here)*

### Example User Flow
```
App Launch
   ↓
Home Screen
   ├─→ [Create New Flashcard]
   │      ↓
   │   Enter Question: "What is the capital of France?"
   │      ↓
   │   Enter Answer: "Paris"
   │      ↓
   │   Select Category: Geography
   │      ↓
   │   Tap Save → ✓ Success Animation
   │      ↓
   │   Return to Home
   │
   └─→ [Start Quiz]
          ↓
       Select Category: Geography
          ↓
       Choose Questions: 5
          ↓
       Tap Begin → Quiz Screen
          ↓
       Question 1/5: [Geography]
       "What is the capital of France?"
       Answer: Paris → ✓ Correct! (Green feedback)
          ↓
       [Continue through questions...]
          ↓
       Quiz Complete Screen
       Score: 5/5 (100%)
       🌟 Excellent! Outstanding work!
          ↓
       [Retake Quiz] or [Home]
```

## 📊 Performance Ratings

- **90-100%**: 🌟 Excellent! Outstanding work!
- **70-89%**: 👍 Good job! Keep it up!
- **50-69%**: 📚 Not bad, but there's room for improvement.
- **Below 50%**: 💪 Keep studying and try again!

## 🗂️ Code Structure

### Main Components

- **`FlashcardQuizApp`**: Main app entry point with Firebase configuration
- **`ContentView`**: Home screen with navigation to quiz and flashcard creation
- **`Category` enum**: Defines available question categories with color themes
- **`Flashcard` struct**: Data model for questions, answers, and categories (Codable for Firebase)
- **`QuizViewModel`**: ObservableObject managing quiz state and Firebase operations
  - `@Published` properties for reactive UI updates
  - `loadFlashcardsFromFirebase()`: Fetches flashcards from Firebase Realtime Database
  - `createFlashcard()`: Handles flashcard creation logic
  - `saveFlashcardToFirebase()`: Saves new flashcards to the cloud
  - `startQuiz()`: Initializes quiz session
  - `checkAnswer()`: Validates user answers with visual feedback
  - `calculateResults()`: Computes final score and performance rating
- **SwiftUI Views**:
  - `HomeView`: Main navigation hub with animated cards
  - `QuizView`: Quiz interface with question display and answer input
  - `CreateFlashcardView`: Form for creating new flashcards
  - `ResultsView`: Displays final score with animations
  - `CategoryPickerView`: Category selection with visual icons
  - `ProgressBarView`: Custom progress indicator

### Firebase Integration

The app uses Firebase Realtime Database to:
- Store all flashcards in the cloud with real-time synchronization
- Load flashcards dynamically at app launch
- Allow users to contribute new flashcards instantly
- Ensure data persistence across sessions and devices
- Support offline caching for better performance

## 🔧 Customization

### Adding New Questions

Users can add flashcards directly through the app's "Create Flashcard" interface. Alternatively, you can add flashcards directly to Firebase:

1. Open your Firebase Console
2. Navigate to Realtime Database
3. Add new entries under the `flashcards` node with the structure:
```json
{
  "flashcards": {
    "uniqueId": {
      "question": "Your question here?",
      "answer": "Your answer",
      "category": "math"
    }
  }
}
```

### Customizing the UI

The SwiftUI interface can be easily customized:

**Colors**: Edit the category color scheme in the `Category` enum:
```swift
var color: Color {
    switch self {
    case .math: return .blue
    case .science: return .green
    // Add your custom colors
    }
}
```

**Animations**: Modify transition animations in views:
```swift
.transition(.scale.combined(with: .opacity))
.animation(.spring(response: 0.6, dampingFraction: 0.8))
```

**Fonts and Styling**: Update text styles throughout the views:
```swift
.font(.title)
.fontWeight(.bold)
.foregroundColor(.primary)
```

### Adding New Categories

1. Add the category to the `Category` enum:
```swift
enum Category: String, CaseIterable {
    case yourCategory = "Your Category Name"
    // ...
}
```

2. Update the Firebase database structure to support the new category

### Changing Performance Thresholds

Modify the switch statement in the results view or ViewModel:

```swift
switch percentage {
case 95...100:
    return ("🏆", "Perfect! You're a genius!", .yellow)
case 90..<95:
    return ("🌟", "Excellent! Outstanding work!", .green)
// Customize as needed...
}
```

## 🎓 Technologies Used

- **Language**: Swift 5
- **UI Framework**: SwiftUI
- **Architecture**: MVVM (Model-View-ViewModel)
- **Platform**: iOS 16.0+
- **IDE**: Xcode 14.0+
- **Cloud Database**: Firebase Realtime Database
- **Data Structures**: Arrays, Structs, Enums, Classes, ObservableObjects
- **Dependencies**: Firebase iOS SDK
- **Async Programming**: async/await, Combine framework

## 🔐 Security Note

When deploying to production, ensure proper Firebase security rules are configured to prevent unauthorized access and abuse. Consider implementing:
- User authentication
- Rate limiting
- Content moderation for user-generated flashcards
- Input validation and sanitization

## 👤 Author

**Preston Dillard**  

---

**Note**: This app is now fully implemented with SwiftUI! The iOS app features a native, modern interface with smooth animations and intuitive navigation.

## 🔮 Future Enhancements

- User authentication with Firebase Auth for personalized experiences
- Personal flashcard collections and favorites
- Spaced repetition algorithm for optimal learning (Leitner system)
- Study streaks and achievement badges
- Multiplayer quiz mode for competitive learning
- Audio pronunciation for language learning flashcards
- Image support in flashcards
- Export flashcard decks to share with friends
- Statistics dashboard with charts and progress tracking
- Widget support for quick daily quizzes
- Apple Watch companion app
- iPad optimized layouts with multitasking support
- Haptic feedback for better interaction
- Accessibility features (VoiceOver, Dynamic Type)
