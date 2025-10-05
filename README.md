# Flashcard Quiz App

A command-line quiz application written in Swift that tests your knowledge across multiple subjects with an interactive question-and-answer format.

## 📋 Description

The Flashcard Quiz App is an educational tool that quizzes users with randomized questions from various categories. Users can select their preferred topic, answer questions, and receive immediate feedback on their performance. The program tracks scores and provides detailed results with performance ratings at the end of each quiz session.

## 🎥 Video

This is the [link(https://youtu.be/WWNMS0cTSTc)].

## ✨ Features

- **Multiple Categories**: Choose from Math, Science, History, Geography, Literature, or All Categories
- **Randomized Questions**: Questions are randomly selected to ensure variety in each quiz session
- **Score Tracking**: Real-time score tracking throughout the quiz
- **Immediate Feedback**: Get instant feedback on whether your answer is correct or incorrect
- **Performance Ratings**: Receive a performance rating based on your final score percentage
- **Case-Insensitive Answers**: Answer matching is not case-sensitive for user convenience
- **Customizable Quiz Length**: Choose how many questions you want to answer

## 🎯 Learning Objectives

This project was created as part of CSE 310 – Applied Programming to:
- Learn and apply Swift programming fundamentals
- Implement data structures (arrays, structs, enums)
- Practice object-oriented programming with classes
- Build an interactive command-line application
- Implement user input validation and string manipulation

## 🚀 How to Run

### Prerequisites
- Xcode (macOS)
- Swift 5.0 or later

### Running in Xcode
1. Open Xcode
2. Create a new **macOS Command Line Tool** project
3. Set Language to **Swift**
4. Replace the contents of `main.swift` with the program code
5. Press `⌘ + R` to build and run
6. Interact with the program in the console window

### Running from Terminal
```bash
# Save the code as FlashcardQuiz.swift
swift FlashcardQuiz.swift

# Or compile and run
swiftc FlashcardQuiz.swift -o quiz
./quiz
```

## 📖 How to Use

1. **Select a Category**: Choose from the menu of available categories (1-6)
2. **Set Question Count**: Enter how many questions you want to answer (default is 5)
3. **Answer Questions**: Type your answer and press Enter for each question
4. **View Feedback**: See if your answer was correct and what the right answer was
5. **Review Results**: At the end, view your score, percentage, and performance rating

### Example Session
```
=================================
  FLASHCARD QUIZ - SELECT CATEGORY
=================================
1. Math
2. Science
3. History
4. Geography
5. Literature
6. All Categories

Select a category (1-6): 2

Enter the number of questions you want to answer (default is 5): 3

=================================
  Welcome to Flashcard Quiz App!
=================================
Category: Science
You will be asked 3 random questions.
Type your answer and press Enter.

Question 1/3: [Science]
What is the largest planet in our solar system?
Your answer: Jupiter
✓ Correct!

Question 2/3: [Science]
What is the chemical symbol for water?
Your answer: h2o
✓ Correct!

Question 3/3: [Science]
What is the speed of light in m/s (approximate)?
Your answer: 300000000
✓ Correct!

=================================
          Quiz Complete!
=================================
Your Score: 3/3
Percentage: 100.0%

Performance Rating:
🌟 Excellent! Outstanding work!
=================================
```

## 📊 Performance Ratings

- **90-100%**: 🌟 Excellent! Outstanding work!
- **70-89%**: 👍 Good job! Keep it up!
- **50-69%**: 📚 Not bad, but there's room for improvement.
- **Below 50%**: 💪 Keep studying and try again!

## 🗂️ Code Structure

### Main Components

- **`Category` enum**: Defines available question categories
- **`Flashcard` struct**: Stores individual questions, answers, and categories
- **`FlashcardQuiz` class**: Manages quiz logic, scoring, and user interaction
  - `loadFlashcards()`: Initializes the flashcard database
  - `startQuiz()`: Main quiz loop and user interaction
  - `checkAnswer()`: Validates user answers
  - `displayResults()`: Shows final score and performance rating

### Question Bank

The program includes 13 flashcards across 5 categories:
- **Math**: 3 questions
- **Science**: 3 questions  
- **History**: 2 questions
- **Geography**: 3 questions
- **Literature**: 2 questions

## 🔧 Customization

### Adding New Questions

To add more flashcards, edit the `loadFlashcards()` method:

```swift
flashcards = [
    Flashcard(question: "Your question here?", answer: "Your answer", category: .math),
    // Add more flashcards...
]
```

### Adding New Categories

1. Add the category to the `Category` enum:
```swift
enum Category: String, CaseIterable {
    case yourCategory = "Your Category Name"
    // ...
}
```

2. Add flashcards with the new category

### Changing Performance Thresholds

Modify the switch statement in `displayResults()`:

```swift
switch percentage {
case 95...100:
    print("🏆 Perfect! You're a genius!")
// Customize as needed...
}
```

## 🎓 Technologies Used

- **Language**: Swift 5
- **Platform**: macOS Command Line
- **IDE**: Xcode
- **Data Structures**: Arrays, Structs, Enums, Classes

## 👤 Author

**Preston Dillard**  
---

**Note**: This is a command-line application. An iOS app version with SwiftUI interface is planned for future development.
