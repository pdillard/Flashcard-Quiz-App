import Foundation


struct Flashcard {
    let question: String
    let answer: String
}

class FlashcardQuiz {
    private var flashcards: [Flashcard] = []
    private var score: Int = 0
    private var questionsAsked: Int = 0
    private let totalQuestions: Int
    
    init(totalQuestions: Int = 5) {
        self.totalQuestions = totalQuestions
        loadFlashcards()
    }
    

    private func loadFlashcards() {
        flashcards = [
            Flashcard(question: "What is the capital of France?", answer: "Paris"),
            Flashcard(question: "What is 5 + 7?", answer: "12"),
            Flashcard(question: "What programming language are we using?", answer: "Swift"),
            Flashcard(question: "What is the largest planet in our solar system?", answer: "Jupiter"),
            Flashcard(question: "What year did World War II end?", answer: "1945"),
            Flashcard(question: "What is the chemical symbol for water?", answer: "H2O"),
            Flashcard(question: "Who wrote Romeo and Juliet?", answer: "Shakespeare"),
            Flashcard(question: "What is the smallest prime number?", answer: "2"),
            Flashcard(question: "What is the speed of light in m/s (approximate)?", answer: "300000000"),
            Flashcard(question: "What is the capital of Japan?", answer: "Tokyo")
        ]
    }
    

    func startQuiz() {
        print("=================================")
        print("  Welcome to Flashcard Quiz App!")
        print("=================================")
        print("You will be asked \(totalQuestions) random questions.")
        print("Type your answer and press Enter.\n")
        
        var availableIndices = Array(0..<flashcards.count)
        
        while questionsAsked < totalQuestions && !availableIndices.isEmpty {
            let randomIndex = availableIndices.randomElement()!
            availableIndices.removeAll { $0 == randomIndex }
            
            let flashcard = flashcards[randomIndex]
            questionsAsked += 1
            
            print("Question \(questionsAsked)/\(totalQuestions):")
            print(flashcard.question)
            print("Your answer: ", terminator: "")
            
            if let userAnswer = readLine() {
                checkAnswer(userAnswer: userAnswer, correctAnswer: flashcard.answer)
            }
            print()
        }
        
        displayResults()
    }
    
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


print("Enter the number of questions you want to answer (default is 5): ", terminator: "")
var numberOfQuestions = 5

if let input = readLine(), let num = Int(input), num > 0 {
    numberOfQuestions = min(num, 10) // Cap at 10 since we have 10 flashcards
}

let quiz = FlashcardQuiz(totalQuestions: numberOfQuestions)
quiz.startQuiz()
