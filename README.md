# Flashcard Quiz App

A modern iOS quiz application built with SwiftUI that tests your knowledge across multiple subjects with an interactive and intuitive interface, powered by Firebase Firestore for cloud storage and user-generated content. Includes a Python-based multiplayer server for competitive quiz sessions.

## 📋 Description

The Flashcard Quiz App is a comprehensive educational platform featuring both a single-player iOS app and a multiplayer server component. Users can quiz themselves with randomized questions from various categories, create custom flashcards stored in Firebase Firestore, and compete with others in real-time multiplayer quiz sessions. The iOS app features a beautiful SwiftUI interface with smooth animations, while the Python server enables competitive gameplay with automatic scoring, time limits, and live leaderboards.

## 🎥 Video

This is the [link](https://youtu.be/WWNMS0cTSTc/) to module#1.  
This is the [link](https://youtu.be/mC5zO1WXgDA/) to module#2.  
This is the [link](#) to module#3. <!-- Add your new video link here -->

## ✨ Features

### iOS App (SwiftUI)
- **Modern SwiftUI Interface**: Beautiful, native iOS design with smooth animations and transitions
- **Multiple Categories**: Choose from Math, Science, History, Geography, Literature, or All Categories
- **Firebase Firestore Integration**: Cloud storage with real-time synchronization
- **User-Generated Content**: Create and add custom flashcards with validation
- **Randomized Questions**: Questions are randomly selected to ensure variety in each quiz session
- **Score Tracking**: Real-time score tracking throughout the quiz with visual progress indicators
- **Immediate Feedback**: Instant visual feedback on whether your answer is correct or incorrect
- **Performance Ratings**: Receive a performance rating based on your final score percentage
- **Case-Insensitive Answers**: Smart answer matching that ignores case and whitespace
- **Customizable Quiz Length**: Choose how many questions you want to answer (1-20)
- **Persistent Data**: Flashcards are saved to the cloud and available across all sessions
- **Offline Support**: Fallback flashcards when Firebase is unavailable
- **Responsive Design**: Optimized for all iOS devices (iPhone and iPad)
- **Dark Mode Support**: Seamless integration with iOS dark mode
- **Memory Optimized**: Proper memory management with `[weak self]` to prevent leaks

### Python Multiplayer Server
- **Real-Time Multiplayer**: Multiple players can join and compete simultaneously
- **Thread-Safe Architecture**: Proper locking mechanisms prevent data corruption
- **Automatic Game Management**: Game starts when all players are ready
- **Answer Time Limits**: 30-second countdown per question with auto-progression
- **Live Leaderboards**: Real-time score updates broadcast to all players
- **Smart Question Handling**: Prevents duplicate answers and tracks who has responded
- **JSON-Based Protocol**: Simple, universal message format for easy client integration
- **Concurrent Connections**: Each player handled in separate thread for smooth gameplay
- **Auto-Progression**: Automatically moves to next question when all players answer or time expires
- **19 Built-in Flashcards**: Diverse question pool across all categories

## 🎯 Learning Objectives

This project was created as part of CSE 310 – Applied Programming to:
- Learn and apply Swift programming fundamentals
- Implement data structures (arrays, structs, enums, dictionaries)
- Practice object-oriented programming with classes
- Build a native iOS application with SwiftUI
- Implement user input validation and string manipulation
- Integrate Firebase Firestore for cloud storage
- Work with asynchronous operations and completion handlers
- Design intuitive user interfaces with modern iOS patterns
- Implement MVVM architecture for clean code structure
- **Master multithreading and concurrency in Python**
- **Implement TCP socket programming for networking**
- **Handle race conditions and thread safety**
- **Design client-server architecture**
- **Work with JSON serialization/deserialization**
- **Implement real-time multiplayer game logic**
- **Understand blocking vs non-blocking operations**
- **Apply proper error handling and validation**

## 🚀 How to Run

### Prerequisites
- **For iOS App:**
  - Xcode 14.0 or later
  - iOS 16.0+ deployment target
  - Swift 5.0 or later
  - Firebase account and project setup
  - Swift Package Manager (included with Xcode)

- **For Python Server:**
  - Python 3.7 or later
  - No external dependencies required (uses standard library)

### Firebase Setup
1. Create a Firebase project at [Firebase Console](https://console.firebase.google.com/)
2. Add an iOS app to your Firebase project
3. Download the `GoogleService-Info.plist` file
4. Enable **Firestore Database** (not Realtime Database) in the Firebase Console
5. Set database rules for read/write access:
```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    match /flashcards/{flashcard} {
      allow read: if true;
      allow write: if true; // Change to require authentication in production
    }
  }
}
```
6. Add initial flashcards to the `flashcards` collection

### Running the iOS App in Xcode
1. Open Xcode
2. Open `Flashcard Quiz App.xcodeproj`
3. Add Firebase SDK via Swift Package Manager (if not already added):
   - File → Add Package Dependencies
   - Enter: `https://github.com/firebase/firebase-ios-sdk`
   - Select **FirebaseFirestore** and **FirebaseCore**
4. Ensure `GoogleService-Info.plist` is in your project
5. Build and run with `⌘ + R`
6. The app will load flashcards from Firebase (or use fallback if unavailable)

### Running the Python Multiplayer Server
1. Open Terminal
2. Navigate to your project directory:
```bash
cd "/Users/preston/Desktop/Flashcard-Quiz-App/Flashcard Quiz App/Flashcard Quiz App"
```
3. Run the server:
```bash
python3 FlashcardServer.py
```
4. You should see:
```
============================================================
🎮 FLASHCARD QUIZ SERVER
============================================================
Server listening on 0.0.0.0:5555
Minimum players: 2
Questions per game: 5
Answer time limit: 30 seconds
Total flashcards available: 19
Waiting for connections...
============================================================
```

### Testing the Multiplayer Server
**Simple Test with Telnet:**
```bash
# Terminal 1 (Server)
python3 FlashcardServer.py

# Terminal 2 (Player 1)
telnet localhost 5555
{"type": "JOIN", "player_name": "Alice"}
{"type": "READY"}

# Terminal 3 (Player 2)
telnet localhost 5555
{"type": "JOIN", "player_name": "Bob"}
{"type": "READY"}
# Game starts automatically!

# Answer questions:
{"type": "ANSWER", "answer": "12"}
```

### Running on iOS Device
1. Connect your iPhone or iPad via USB
2. Select your device in Xcode's device menu
3. Configure signing & capabilities with your Apple Developer account
4. Press `⌘ + R` to install and run on your device

## 📖 How to Use

### Single-Player Mode (iOS App)

1. **Home Screen**: Launch the app to see the main menu with beautiful card-based interface
2. **Create Flashcards**:
   - Tap "Add New Flashcard" button
   - Enter your question (minimum 3 characters)
   - Enter the answer (minimum 1 character)
   - Select a category from the grid
   - Tap "Save Flashcard" to upload to Firebase
   - Receive success confirmation
3. **Take Quiz**:
   - Select a category from the grid
   - Set the number of questions (1-20) using the stepper
   - Tap "Start Quiz" to begin
   - Read each question and type your answer
   - Tap "Submit" to check your answer
   - See visual feedback (green checkmark for correct, red X for incorrect)
   - View correct answer if you were wrong
   - Tap "Next Question" to continue
   - Review final results with performance rating
   - Tap "Start New Quiz" to play again

### Multiplayer Mode (Python Server)

1. **Start Server**: Run `python3 FlashcardServer.py`
2. **Players Connect**: Each player connects to server IP:5555
3. **Join Game**: Send JOIN message with player name
4. **Ready Up**: Send READY message when ready to play
5. **Game Starts**: Automatically starts when all players ready (minimum 2)
6. **Answer Questions**: 
   - Server broadcasts questions to all players
   - Players have 30 seconds to answer
   - Submit answers via ANSWER message
   - Server validates and updates scores
7. **View Results**: After 5 questions, final scores and winner are announced
8. **Leaderboard**: Real-time score updates throughout the game

### Multiplayer Protocol (JSON Messages)

**Client → Server:**
```json
{"type": "JOIN", "player_name": "Alice"}
{"type": "READY"}
{"type": "ANSWER", "answer": "42"}
{"type": "PING"}
```

**Server → Client:**
```json
{"type": "JOINED", "status": "success", "players_count": 2}
{"type": "GAME_STARTING", "message": "Get ready! Game starting..."}
{"type": "QUESTION", "question": "What is 2+2?", "category": "Math", "number": 1, "total": 5, "time_limit": 30}
{"type": "ANSWER_RESULT", "correct": true, "correct_answer": "4", "your_score": 10}
{"type": "SCORE_UPDATE", "scores": [{"name": "Alice", "score": 30}, {"name": "Bob", "score": 20}]}
{"type": "GAME_END", "winner": "Alice", "final_scores": [...]}
```

### Example User Flow
```
iOS App Launch
   ↓
Home Screen
   ├─→ [Add New Flashcard]
   │      ↓
   │   Enter Question: "What is the capital of France?"
   │      ↓
   │   Enter Answer: "Paris"
   │      ↓
   │   Select Category: Geography
   │      ↓
   │   Tap Save → ✓ Firebase Upload Success
   │      ↓
   │   Return to Setup
   │
   └─→ [Start Quiz]
          ↓
       Select Category: All
          ↓
       Choose Questions: 5
          ↓
       Tap Start → Quiz Begins
          ↓
       Question 1/5: [Geography]
       "What is the capital of France?"
       Answer: Paris → ✓ Correct! Score: 1/5
          ↓
       [Continue through questions...]
          ↓
       Quiz Complete Screen
       Score: 5/5 (100%)
       🌟 Excellent! Outstanding work!
          ↓
       [Start New Quiz]

Multiplayer Server
   ↓
Server Started (Port 5555)
   ↓
Alice Connects → Joins Game
   ↓
Bob Connects → Joins Game
   ↓
Both Players Ready → Game Starts
   ↓
Question 1: "What is 2+2?"
   ├─→ Alice answers "4" (Correct! +10 points)
   └─→ Bob answers "5" (Incorrect)
   ↓
Leaderboard: Alice: 10, Bob: 0
   ↓
[Continue for 5 questions...]
   ↓
Game Ends
Winner: Alice with 40 points!
```

## 📊 Performance Ratings

- **90-100%**: 🌟 Excellent! Outstanding work!
- **70-89%**: 👍 Good job! Keep it up!
- **50-69%**: 📚 Not bad, but there's room for improvement.
- **Below 50%**: 💪 Keep studying and try again!

## 🗂️ Code Structure

### iOS App Structure

**Main Files:**
- **`Flashcard_Quiz_AppApp.swift`**: App entry point with Firebase initialization
- **`ContentView.swift`**: Main view controller with all UI components and logic

**Key Components:**

- **`Category` enum**: Defines available categories with icons and colors
```swift
enum Category: String, CaseIterable {
    case math, science, history, geography, literature, all
    var icon: String { /* SF Symbols icons */ }
}
```

- **`Flashcard` struct**: Codable data model for Firebase integration
```swift
struct Flashcard: Identifiable, Codable {
    @DocumentID var id: String?
    let question: String
    let answer: String
    let category: String
}
```

- **`FlashcardQuizViewModel`**: ObservableObject managing app state
  - `@Published` properties for reactive UI updates
  - `fetchFlashcards()`: Loads flashcards from Firestore with error handling
  - `loadFallbackFlashcards()`: Provides offline fallback data
  - `startQuiz()`: Initializes quiz with filtered, shuffled questions
  - `submitAnswer()`: Validates answers with case-insensitive matching
  - `addFlashcard()`: Creates new flashcards with validation
  - Proper memory management with `[weak self]` in closures

**SwiftUI Views:**
- **`SetupView`**: Home screen with category selection and quiz configuration
- **`QuizView`**: Quiz interface with question display, answer input, and feedback
- **`ResultsView`**: Final score display with performance rating and emoji
- **`AddFlashcardView`**: Form for creating custom flashcards with validation
- **`CategoryButton`**: Reusable category selection component

### Python Server Structure

**Main File:** `FlashcardServer.py`

**Key Components:**

- **Configuration Constants:**
```python
HOST = '0.0.0.0'  # Listen on all interfaces
PORT = 5555
MIN_PLAYERS = 2
TOTAL_QUESTIONS = 5
ANSWER_TIME_LIMIT = 30
```

- **Data Structures:**
```python
FLASHCARD_POOL = [...]  # 19 flashcards across all categories
players = []  # List of connected player dictionaries
players_lock = threading.Lock()  # Thread safety for player data
game_lock = threading.Lock()  # Thread safety for game state
```

- **Core Functions:**
  - `start_server()`: Creates TCP socket and accepts connections
  - `handle_client()`: Manages individual client communication in separate thread
  - `send_message()`: JSON serialization and transmission
  - `broadcast()`: Sends messages to all connected players
  - `initialize_game()`: Starts new game with random questions
  - `send_next_question()`: Broadcasts questions with time limits
  - `handle_answer()`: Validates answers and updates scores (thread-safe)
  - `broadcast_scores()`: Sends live leaderboard updates
  - `end_game()`: Calculates winner and final rankings
  - `auto_next_question()`: Timer callback for automatic progression

**Threading Architecture:**
- Main thread: Accepts new connections
- Per-client threads: Handle individual player communication
- Thread locks: Prevent race conditions on shared data
- Daemon threads: Clean shutdown when server stops

**Network Protocol:**
- TCP sockets for reliable, ordered delivery
- JSON messages with newline delimiters
- Stateful connections (players stay connected throughout game)
- Broadcast system for game events

## 🔧 Technical Improvements (Module 3)

### Bug Fixes Implemented:
✅ **Fixed missing `FLASHCARD_POOL`** - Added 19 flashcards that were referenced but never defined  
✅ **Fixed race conditions** - Proper locking when multiple threads access game state  
✅ **Implemented answer timeout** - 30-second timer with auto-progression  
✅ **Fixed thread safety** - Added locks for all shared data structures  
✅ **Prevented duplicate answers** - Players can only answer each question once  
✅ **Better memory management** - Used `[weak self]` in iOS closures  
✅ **Improved error handling** - Specific error messages based on error types  
✅ **Added validation** - Input validation for flashcard creation  

### Performance Enhancements:
- **Memory leak prevention** with proper weak references
- **Thread-safe operations** with granular locking
- **Efficient Firebase queries** with proper async handling
- **Optimized UI updates** on main thread only
- **Smart auto-progression** reduces waiting time

### Code Quality:
- Comprehensive inline documentation explaining concepts
- Consistent error handling patterns
- Modular, reusable components
- Clear separation of concerns
- Professional logging and debugging output

## 🎓 Technologies & Concepts Learned

### iOS Development:
- **SwiftUI**: Declarative UI framework
- **MVVM Pattern**: Model-View-ViewModel architecture
- **Combine Framework**: Reactive programming with `@Published`
- **Firebase Firestore**: NoSQL cloud database
- **Async/Await**: Asynchronous operation handling
- **Memory Management**: ARC, retain cycles, weak references
- **Property Wrappers**: `@Published`, `@StateObject`, `@ObservedObject`

### Python Server Development:
- **Socket Programming**: TCP client-server communication
- **Threading**: Concurrent handling of multiple connections
- **Thread Safety**: Locks, mutexes, race condition prevention
- **JSON Protocol**: Serialization/deserialization for network communication
- **Event-Driven Design**: Callback-based game flow
- **Networking Concepts**: Ports, IP addresses, blocking/non-blocking I/O

### Software Engineering Principles:
- **Error Handling**: Graceful degradation and recovery
- **Input Validation**: Sanitization and verification
- **State Management**: Complex game state tracking
- **Code Documentation**: Clear comments explaining "why" not just "what"
- **Testing**: Manual testing protocols for multiplayer systems

## 🔐 Security Considerations

### Firebase Security:
- Configure proper Firestore security rules in production
- Implement user authentication for write operations
- Rate limiting to prevent abuse
- Content moderation for user-generated flashcards
- Input validation and sanitization

### Server Security:
- Validate all JSON input before processing
- Sanitize player names to prevent injection
- Rate limit connections to prevent DoS
- Consider adding authentication for production
- Use TLS/SSL for encrypted communication in production

## 🐛 Troubleshooting

### Common Issues:

**iOS App:**
- **"Module 'Firebase' not found"**: Resolve packages in Xcode
- **"No flashcards found"**: Check Firebase connection and rules
- **UI not updating**: Ensure `@Published` properties and `DispatchQueue.main.async`
- **Memory warnings**: Check for retain cycles in closures

**Python Server:**
- **"Address already in use"**: Kill process using port 5555 or change port
- **Clients can't connect**: Check firewall settings
- **Race condition crashes**: Verify all shared data uses locks
- **JSON decode errors**: Validate message format

See `INSTALLATION_GUIDE.md` for detailed troubleshooting steps.

## 📚 Documentation

- **`INSTALLATION_GUIDE.md`**: Complete setup instructions
- **`PROGRAMMING_CONCEPTS.md`**: Comprehensive concept explanations with examples
- **`QUICK_START.md`**: Fast setup guide for your specific project
- Inline code comments: Detailed explanations throughout codebase

## 👤 Author

**Preston Dillard**  
CSE 310 – Applied Programming

---

## 🔮 Future Enhancements

### Planned Features:
- [ ] Connect iOS app to Python multiplayer server
- [ ] User authentication with Firebase Auth
- [ ] Personal flashcard collections and favorites
- [ ] Spaced repetition algorithm (Leitner system)
- [ ] Study streaks and achievement badges
- [ ] Audio pronunciation for language flashcards
- [ ] Image support in flashcards
- [ ] Export/import flashcard decks
- [ ] Statistics dashboard with progress charts
- [ ] iOS Widget for quick daily quizzes
- [ ] Apple Watch companion app
- [ ] iPad-optimized layouts
- [ ] Haptic feedback and accessibility features
- [ ] Multiplayer matchmaking system
- [ ] Tournament mode with brackets
- [ ] Chat system for multiplayer games
- [ ] Spectator mode for watching games

### Technical Improvements:
- [ ] WebSocket protocol for better real-time communication
- [ ] Redis for game state caching
- [ ] Load balancing for multiple server instances
- [ ] Comprehensive unit and integration tests
- [ ] CI/CD pipeline for automated deployment
- [ ] Analytics and crash reporting
- [ ] A/B testing framework

---

**Note**: This project demonstrates full-stack development skills including native iOS development with SwiftUI, backend server programming with Python, cloud database integration, networking protocols, multithreading, and software architecture design. All code has been optimized for performance, security, and maintainability.

## 📄 License

This project is created for educational purposes as part of CSE 310.

## 🙏 Acknowledgments

- Firebase for cloud infrastructure
- Apple Developer documentation
- Python socket programming community
- CSE 310 course materials and instruction
