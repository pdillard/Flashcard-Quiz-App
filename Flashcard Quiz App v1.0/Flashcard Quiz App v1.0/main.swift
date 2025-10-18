import Foundation

// Category enumeration
enum Category: String, CaseIterable {
    case math = "Math"
    case science = "Science"
    case history = "History"
    case geography = "Geography"
    case literature = "Literature"
    case all = "All Categories"
}

// Flashcard structure to store questions and answers
struct Flashcard {
    let question: String
    let answer: String
    let category: Category
}

class FlashcardQuiz {
    private var flashcards: [Flashcard] = []
    private var score: Int = 0
    private var questionsAsked: Int = 0
    private let totalQuestions: Int
    private let selectedCategory: Category
    
    init(totalQuestions: Int = 5, category: Category = .all) {
        self.totalQuestions = totalQuestions
        self.selectedCategory = category
        loadFlashcards()
    }
    
    // Load flashcards into the array
    private func loadFlashcards() {
        flashcards = [
            Flashcard(question: "What is 5 + 7?", answer: "12", category: .math),
            Flashcard(question: "What is the smallest prime number?", answer: "2", category: .math),
            Flashcard(question: "What is 10 x 9?", answer: "90", category: .math),
            
            Flashcard(question: "What is the largest planet in our solar system?", answer: "Jupiter", category: .science),
            Flashcard(question: "What is the chemical symbol for water?", answer: "H2O", category: .science),
            Flashcard(question: "What is the speed of light in m/s (approximate)?", answer: "300000000", category: .science),
            
            Flashcard(question: "What year did World War II end?", answer: "1945", category: .history),
            Flashcard(question: "Who was the first President of the United States?", answer: "Washington", category: .history),
            
            Flashcard(question: "What is the capital of France?", answer: "Paris", category: .geography),
            Flashcard(question: "What is the capital of Japan?", answer: "Tokyo", category: .geography),
            Flashcard(question: "How many continents are there?", answer: "7", category: .geography),
            
            Flashcard(question: "Who wrote Romeo and Juliet?", answer: "Shakespeare", category: .literature),
            Flashcard(question: "What programming language are we using?", answer: "Swift", category: .literature)
        ]
    }
    
    // Start the quiz
    func startQuiz() {
        // Filter flashcards by category
        var quizFlashcards = flashcards
        if selectedCategory != .all {
            quizFlashcards = flashcards.filter { $0.category == selectedCategory }
        }
        
        guard !quizFlashcards.isEmpty else {
            print("No flashcards available for this category!")
            return
        }
        
        print("=================================")
        print("  Welcome to Flashcard Quiz App!")
        print("=================================")
        print("Category: \(selectedCategory.rawValue)")
        print("You will be asked \(totalQuestions) random questions.")
        print("Type your answer and press Enter.\n")
        
        var availableIndices = Array(0..<quizFlashcards.count)
        let questionsToAsk = min(totalQuestions, quizFlashcards.count)
        
        while questionsAsked < questionsToAsk && !availableIndices.isEmpty {
            // Pick a random flashcard
            let randomIndex = availableIndices.randomElement()!
            availableIndices.removeAll { $0 == randomIndex }
            
            let flashcard = quizFlashcards[randomIndex]
            questionsAsked += 1
            
            print("Question \(questionsAsked)/\(questionsToAsk): [\(flashcard.category.rawValue)]")
            print(flashcard.question)
            print("Your answer: ", terminator: "")
            
            if let userAnswer = readLine() {
                checkAnswer(userAnswer: userAnswer, correctAnswer: flashcard.answer)
            }
            print()
        }
        
        displayResults()
    }
    
    // Check if the user's answer is correct
    private func checkAnswer(userAnswer: String, correctAnswer: String) {
        let trimmedUserAnswer = userAnswer.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCorrectAnswer = correctAnswer.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if trimmedUserAnswer.lowercased() == trimmedCorrectAnswer.lowercased() {
            print("✓ Correct!")
            score += 1
        } else {
            print("✗ Incorrect. The correct answer is: \(correctAnswer)")
        }
    }
    
    // Display final results
    private func displayResults() {
        print("=================================")
        print("          Quiz Complete!")
        print("=================================")
        print("Your Score: \(score)/\(totalQuestions)")
        
        let percentage = Double(score) / Double(totalQuestions) * 100
        print("Percentage: \(String(format: "%.1f", percentage))%")
        
        print("\nPerformance Rating:")
        switch percentage {
        case 90...100:
            print("🌟 Excellent! Outstanding work!")
        case 70..<90:
            print("👍 Good job! Keep it up!")
        case 50..<70:
            print("📚 Not bad, but there's room for improvement.")
        default:
            print("💪 Keep studying and try again!")
        }
        print("=================================")
    }
}

// Main program execution
print("=================================")
print("  FLASHCARD QUIZ - SELECT CATEGORY")
print("=================================")

// Display categories
for (index, category) in Category.allCases.enumerated() {
    print("\(index + 1). \(category.rawValue)")
}

print("\nSelect a category (1-\(Category.allCases.count)): ", terminator: "")
var selectedCategory = Category.all

if let input = readLine(), let choice = Int(input), choice > 0, choice <= Category.allCases.count {
    selectedCategory = Category.allCases[choice - 1]
}

print("\nEnter the number of questions you want to answer (default is 5): ", terminator: "")
var numberOfQuestions = 5

if let input = readLine(), let num = Int(input), num > 0 {
    numberOfQuestions = num
}

let quiz = FlashcardQuiz(totalQuestions: numberOfQuestions, category: selectedCategory)
quiz.startQuiz()
