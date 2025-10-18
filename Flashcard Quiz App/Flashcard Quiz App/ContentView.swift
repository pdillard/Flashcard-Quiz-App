import SwiftUI
import Combine
import FirebaseCore
import FirebaseFirestore

// Category enumeration
enum Category: String, CaseIterable {
    case math = "Math"
    case science = "Science"
    case history = "History"
    case geography = "Geography"
    case literature = "Literature"
    case all = "All"
    
    var icon: String {
        switch self {
        case .math: return "function"
        case .science: return "atom"
        case .history: return "clock"
        case .geography: return "globe"
        case .literature: return "book"
        case .all: return "square.grid.2x2"
        }
    }
}

// Flashcard structure - Updated for Firebase
struct Flashcard: Identifiable, Codable {
    @DocumentID var id: String?
    let question: String
    let answer: String
    let category: String
    
    var categoryEnum: Category {
        Category(rawValue: category) ?? .all
    }
}

class FlashcardQuizViewModel: ObservableObject {
    @Published var currentScreen: Screen = .setup
    @Published var selectedCategory: Category = .all
    @Published var totalQuestions: Int = 5
    @Published var currentQuestionIndex: Int = 0
    @Published var userAnswer: String = ""
    @Published var score: Int = 0
    @Published var showingResult: Bool = false
    @Published var isCorrect: Bool = false
    @Published var quizFlashcards: [Flashcard] = []
    @Published var isLoading: Bool = false
    @Published var errorMessage: String?
    
    // Firebase Firestore reference
    private let db = Firestore.firestore()
    private var allFlashcards: [Flashcard] = []
    
    enum Screen {
        case setup
        case quiz
        case results
        case addFlashcard
    }
    
    init() {
        fetchFlashcards()
    }
    
    // Fetch flashcards from Firebase
    func fetchFlashcards() {
        isLoading = true
        errorMessage = nil
        
        db.collection("flashcards").getDocuments { [weak self] snapshot, error in
            guard let self = self else { return }
            
            DispatchQueue.main.async {
                self.isLoading = false
                
                if let error = error {
                    self.errorMessage = "Error loading flashcards: \(error.localizedDescription)"
                    self.loadFallbackFlashcards()
                    return
                }
                
                guard let documents = snapshot?.documents else {
                    self.errorMessage = "No flashcards found"
                    self.loadFallbackFlashcards()
                    return
                }
                
                self.allFlashcards = documents.compactMap { doc in
                    try? doc.data(as: Flashcard.self)
                }
                
                if self.allFlashcards.isEmpty {
                    self.errorMessage = "No flashcards available. Using default set."
                    self.loadFallbackFlashcards()
                }
            }
        }
    }
    
    // Fallback flashcards if Firebase fails
    private func loadFallbackFlashcards() {
        allFlashcards = [
            Flashcard(question: "What is 5 + 7?", answer: "12", category: "Math"),
            Flashcard(question: "What is the smallest prime number?", answer: "2", category: "Math"),
            Flashcard(question: "What is 10 x 9?", answer: "90", category: "Math"),
            Flashcard(question: "What is the largest planet in our solar system?", answer: "Jupiter", category: "Science"),
            Flashcard(question: "What is the chemical symbol for water?", answer: "H2O", category: "Science"),
            Flashcard(question: "What year did World War II end?", answer: "1945", category: "History"),
            Flashcard(question: "Who was the first President of the United States?", answer: "Washington", category: "History"),
            Flashcard(question: "What is the capital of France?", answer: "Paris", category: "Geography"),
            Flashcard(question: "What is the capital of Japan?", answer: "Tokyo", category: "Geography"),
            Flashcard(question: "How many continents are there?", answer: "7", category: "Geography"),
            Flashcard(question: "Who wrote Romeo and Juliet?", answer: "Shakespeare", category: "Literature"),
            Flashcard(question: "What programming language are we using?", answer: "Swift", category: "Literature")
        ]
    }
    
    func startQuiz() {
        var filtered = allFlashcards
        if selectedCategory != .all {
            filtered = allFlashcards.filter { $0.category == selectedCategory.rawValue }
        }
        
        guard !filtered.isEmpty else {
            errorMessage = "No flashcards available for this category"
            return
        }
        
        quizFlashcards = Array(filtered.shuffled().prefix(min(totalQuestions, filtered.count)))
        currentQuestionIndex = 0
        score = 0
        userAnswer = ""
        showingResult = false
        errorMessage = nil
        currentScreen = .quiz
    }
    
    func submitAnswer() {
        let currentFlashcard = quizFlashcards[currentQuestionIndex]
        let trimmedUserAnswer = userAnswer.trimmingCharacters(in: .whitespacesAndNewlines)
        let trimmedCorrectAnswer = currentFlashcard.answer.trimmingCharacters(in: .whitespacesAndNewlines)
        
        isCorrect = trimmedUserAnswer.lowercased() == trimmedCorrectAnswer.lowercased()
        if isCorrect {
            score += 1
        }
        showingResult = true
    }
    
    func nextQuestion() {
        currentQuestionIndex += 1
        userAnswer = ""
        showingResult = false
        
        if currentQuestionIndex >= quizFlashcards.count {
            currentScreen = .results
        }
    }
    
    func resetQuiz() {
        currentScreen = .setup
        selectedCategory = .all
        totalQuestions = 5
        currentQuestionIndex = 0
        userAnswer = ""
        score = 0
        showingResult = false
        quizFlashcards = []
        errorMessage = nil
    }
    
    var percentage: Double {
        guard !quizFlashcards.isEmpty else { return 0 }
        return Double(score) / Double(quizFlashcards.count) * 100
    }
    
    var performanceMessage: (emoji: String, message: String) {
        switch percentage {
        case 90...100:
            return ("🌟", "Excellent! Outstanding work!")
        case 70..<90:
            return ("👍", "Good job! Keep it up!")
        case 50..<70:
            return ("📚", "Not bad, but there's room for improvement.")
        default:
            return ("💪", "Keep studying and try again!")
        }
    }
    
    // Add new flashcard to Firebase
    func addFlashcard(question: String, answer: String, category: String, completion: @escaping (Bool, String) -> Void) {
        guard !question.isEmpty && !answer.isEmpty && !category.isEmpty else {
            completion(false, "All fields are required")
            return
        }
        
        let newFlashcard: [String: Any] = [
            "question": question,
            "answer": answer,
            "category": category
        ]
        
        db.collection("flashcards").addDocument(data: newFlashcard) { error in
            if let error = error {
                completion(false, "Error adding flashcard: \(error.localizedDescription)")
            } else {
                completion(true, "Flashcard added successfully!")
                self.fetchFlashcards()
            }
        }
    }
}

struct ContentView: View {
    @StateObject private var viewModel = FlashcardQuizViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue.opacity(0.6), Color.purple.opacity(0.6)]),
                             startPoint: .topLeading,
                             endPoint: .bottomTrailing)
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    VStack(spacing: 20) {
                        ProgressView()
                            .scaleEffect(1.5)
                            .tint(.white)
                        Text("Loading flashcards from Firebase...")
                            .foregroundColor(.white)
                            .font(.headline)
                    }
                } else {
                    switch viewModel.currentScreen {
                    case .setup:
                        SetupView(viewModel: viewModel)
                    case .quiz:
                        QuizView(viewModel: viewModel)
                    case .results:
                        ResultsView(viewModel: viewModel)
                    case .addFlashcard:
                        AddFlashcardView(viewModel: viewModel)
                    }
                }
            }
        }
    }
}

struct SetupView: View {
    @ObservedObject var viewModel: FlashcardQuizViewModel
    
    var body: some View {
        ScrollView {
        VStack(spacing: 30) {
            VStack(spacing: 10) {
                Image(systemName: "brain.head.profile")
                    .font(.system(size: 80))
                    .foregroundColor(.white)
                
                Text("Flashcard Quiz")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
                
                Text("Test your knowledge!")
                    .font(.title3)
                    .foregroundColor(.white.opacity(0.9))
            }
            .padding(.bottom, 20)
            
            if let error = viewModel.errorMessage {
                HStack {
                    Image(systemName: "exclamationmark.triangle.fill")
                    Text(error)
                        .font(.subheadline)
                }
                .foregroundColor(.yellow)
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(10)
            }
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Select Category")
                    .font(.headline)
                    .foregroundColor(.white)
                
                LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                    ForEach(Category.allCases, id: \.self) { category in
                        CategoryButton(category: category, isSelected: viewModel.selectedCategory == category) {
                            viewModel.selectedCategory = category
                        }
                    }
                }
            }
            .padding()
            .background(Color.white.opacity(0.2))
            .cornerRadius(15)
            
            VStack(alignment: .leading, spacing: 15) {
                Text("Number of Questions")
                    .font(.headline)
                    .foregroundColor(.white)
                
                Stepper(value: $viewModel.totalQuestions, in: 1...20) {
                    Text("\(viewModel.totalQuestions) questions")
                        .font(.title2)
                        .foregroundColor(.white)
                }
            }
            .padding()
            .background(Color.white.opacity(0.2))
            .cornerRadius(15)
            
            Button(action: {
                viewModel.startQuiz()
            }) {
                Text("Start Quiz")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
            }
            
            Button(action: {
                viewModel.fetchFlashcards()
            }) {
                HStack {
                    Image(systemName: "arrow.clockwise")
                    Text("Refresh Flashcards")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(15)
            }
            
            Button(action: {
                viewModel.currentScreen = .addFlashcard
            }) {
                HStack {
                    Image(systemName: "plus.circle.fill")
                    Text("Add New Flashcard")
                }
                .font(.headline)
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.green.opacity(0.6))
                .cornerRadius(15)
            }
            
            Spacer()
        }
        .padding()
        }
    }
}

struct CategoryButton: View {
    let category: Category
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 8) {
                Image(systemName: category.icon)
                    .font(.system(size: 30))
                
                Text(category.rawValue)
                    .font(.subheadline)
                    .fontWeight(.medium)
            }
            .foregroundColor(isSelected ? .blue : .white)
            .frame(maxWidth: .infinity)
            .padding()
            .background(isSelected ? Color.white : Color.white.opacity(0.2))
            .cornerRadius(12)
        }
    }
}

struct QuizView: View {
    @ObservedObject var viewModel: FlashcardQuizViewModel
    @FocusState private var isTextFieldFocused: Bool
    
    var body: some View {
        ScrollView {
        VStack(spacing: 25) {
            VStack(spacing: 10) {
                HStack {
                    Text("Question \(viewModel.currentQuestionIndex + 1) of \(viewModel.quizFlashcards.count)")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Spacer()
                    
                    Text("Score: \(viewModel.score)")
                        .font(.headline)
                        .foregroundColor(.white)
                }
                
                ProgressView(value: Double(viewModel.currentQuestionIndex + 1), total: Double(viewModel.quizFlashcards.count))
                    .progressViewStyle(LinearProgressViewStyle(tint: .white))
                    .scaleEffect(x: 1, y: 2, anchor: .center)
            }
            .padding()
            .background(Color.white.opacity(0.2))
            .cornerRadius(15)
            
            if viewModel.currentQuestionIndex < viewModel.quizFlashcards.count {
                let currentFlashcard = viewModel.quizFlashcards[viewModel.currentQuestionIndex]
                
                VStack(spacing: 20) {
                    HStack {
                        Image(systemName: currentFlashcard.categoryEnum.icon)
                        Text(currentFlashcard.category)
                            .font(.subheadline)
                            .fontWeight(.medium)
                    }
                    .foregroundColor(.white.opacity(0.8))
                    
                    Text(currentFlashcard.question)
                        .font(.title2)
                        .fontWeight(.semibold)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                        .padding()
                }
                .frame(maxWidth: .infinity)
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(15)
                
                if !viewModel.showingResult {
                    VStack(spacing: 15) {
                        TextField("Type your answer...", text: $viewModel.userAnswer)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .font(.title3)
                            .focused($isTextFieldFocused)
                            .submitLabel(.done)
                            .onSubmit {
                                if !viewModel.userAnswer.isEmpty {
                                    viewModel.submitAnswer()
                                }
                            }
                        
                        Button(action: {
                            viewModel.submitAnswer()
                        }) {
                            Text("Submit")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                        }
                        .disabled(viewModel.userAnswer.isEmpty)
                        .opacity(viewModel.userAnswer.isEmpty ? 0.6 : 1.0)
                    }
                    .padding()
                } else {
                    VStack(spacing: 20) {
                        HStack {
                            Image(systemName: viewModel.isCorrect ? "checkmark.circle.fill" : "xmark.circle.fill")
                                .font(.system(size: 50))
                                .foregroundColor(viewModel.isCorrect ? .green : .red)
                            
                            VStack(alignment: .leading, spacing: 5) {
                                Text(viewModel.isCorrect ? "Correct!" : "Incorrect")
                                    .font(.title2)
                                    .fontWeight(.bold)
                                    .foregroundColor(.white)
                                
                                if !viewModel.isCorrect {
                                    Text("Answer: \(currentFlashcard.answer)")
                                        .font(.title3)
                                        .foregroundColor(.white.opacity(0.9))
                                }
                            }
                            
                            Spacer()
                        }
                        .padding()
                        .background(viewModel.isCorrect ? Color.green.opacity(0.3) : Color.red.opacity(0.3))
                        .cornerRadius(12)
                        
                        Button(action: {
                            viewModel.nextQuestion()
                        }) {
                            Text(viewModel.currentQuestionIndex < viewModel.quizFlashcards.count - 1 ? "Next Question" : "View Results")
                                .font(.title3)
                                .fontWeight(.semibold)
                                .foregroundColor(.blue)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.white)
                                .cornerRadius(12)
                        }
                    }
                    .padding()
                }
            }
            
            Spacer()
        }
        .padding()
        .onAppear {
            isTextFieldFocused = true
        }
        }
    }
}

struct ResultsView: View {
    @ObservedObject var viewModel: FlashcardQuizViewModel
    
    var body: some View {
        ScrollView {
        VStack(spacing: 30) {
            VStack(spacing: 10) {
                Text("🎉")
                    .font(.system(size: 80))
                
                Text("Quiz Complete!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .foregroundColor(.white)
            }
            
            VStack(spacing: 20) {
                HStack {
                    VStack(alignment: .leading, spacing: 5) {
                        Text("Your Score")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text("\(viewModel.score)/\(viewModel.quizFlashcards.count)")
                            .font(.system(size: 50, weight: .bold))
                            .foregroundColor(.white)
                    }
                    
                    Spacer()
                    
                    VStack(alignment: .trailing, spacing: 5) {
                        Text("Percentage")
                            .font(.headline)
                            .foregroundColor(.white.opacity(0.8))
                        
                        Text(String(format: "%.1f%%", viewModel.percentage))
                            .font(.system(size: 50, weight: .bold))
                            .foregroundColor(.white)
                    }
                }
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(15)
                
                VStack(spacing: 15) {
                    Text(viewModel.performanceMessage.emoji)
                        .font(.system(size: 60))
                    
                    Text(viewModel.performanceMessage.message)
                        .font(.title3)
                        .fontWeight(.medium)
                        .foregroundColor(.white)
                        .multilineTextAlignment(.center)
                }
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(15)
            }
            
            Button(action: {
                viewModel.resetQuiz()
            }) {
                Text("Start New Quiz")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.blue)
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .cornerRadius(15)
            }
            
            Spacer()
        }
        .padding()
        }
    }
}

struct AddFlashcardView: View {
    @ObservedObject var viewModel: FlashcardQuizViewModel
    @State private var question: String = ""
    @State private var answer: String = ""
    @State private var selectedCategory: Category = .math
    @State private var showingAlert: Bool = false
    @State private var alertMessage: String = ""
    @State private var isSuccess: Bool = false
    @State private var isSaving: Bool = false
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                VStack(spacing: 10) {
                    Image(systemName: "plus.circle.fill")
                        .font(.system(size: 80))
                        .foregroundColor(.white)
                    
                    Text("Add New Flashcard")
                        .font(.largeTitle)
                        .fontWeight(.bold)
                        .foregroundColor(.white)
                    
                    Text("Create your own question")
                        .font(.title3)
                        .foregroundColor(.white.opacity(0.9))
                }
                .padding(.bottom, 20)
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("Question")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    TextEditor(text: $question)
                        .frame(height: 100)
                        .padding(8)
                        .background(Color.white)
                        .cornerRadius(8)
                        .overlay(
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.blue, lineWidth: 2)
                        )
                }
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(15)
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("Answer")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    TextField("Enter the answer", text: $answer)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .font(.title3)
                }
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(15)
                
                VStack(alignment: .leading, spacing: 15) {
                    Text("Select Category")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())], spacing: 15) {
                        ForEach(Category.allCases.filter { $0 != .all }, id: \.self) { category in
                            CategoryButton(category: category, isSelected: selectedCategory == category) {
                                selectedCategory = category
                            }
                        }
                    }
                }
                .padding()
                .background(Color.white.opacity(0.2))
                .cornerRadius(15)
                
                if isSaving {
                    ProgressView()
                        .scaleEffect(1.5)
                        .tint(.white)
                        .padding()
                } else {
                    VStack(spacing: 15) {
                        Button(action: {
                            saveFlashcard()
                        }) {
                            HStack {
                                Image(systemName: "checkmark.circle.fill")
                                Text("Save Flashcard")
                            }
                            .font(.title2)
                            .fontWeight(.semibold)
                            .foregroundColor(.white)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.green)
                            .cornerRadius(15)
                        }
                        .disabled(question.isEmpty || answer.isEmpty)
                        .opacity(question.isEmpty || answer.isEmpty ? 0.6 : 1.0)
                        
                        Button(action: {
                            viewModel.currentScreen = .setup
                        }) {
                            Text("Cancel")
                                .font(.headline)
                                .foregroundColor(.white)
                                .frame(maxWidth: .infinity)
                                .padding()
                                .background(Color.red.opacity(0.6))
                                .cornerRadius(15)
                        }
                    }
                }
                
                Spacer()
            }
            .padding()
        }
        .alert(isPresented: $showingAlert) {
            Alert(
                title: Text(isSuccess ? "Success!" : "Error"),
                message: Text(alertMessage),
                dismissButton: .default(Text("OK")) {
                    if isSuccess {
                        question = ""
                        answer = ""
                        selectedCategory = .math
                        viewModel.currentScreen = .setup
                    }
                }
            )
        }
    }
    
    private func saveFlashcard() {
        isSaving = true
        viewModel.addFlashcard(question: question, answer: answer, category: selectedCategory.rawValue) { success, message in
            isSaving = false
            isSuccess = success
            alertMessage = message
            showingAlert = true
        }
    }
}

#Preview {
    ContentView()
}
