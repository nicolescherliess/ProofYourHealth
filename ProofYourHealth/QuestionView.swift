import SwiftUI
import CoreData

struct QuestionView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(sortDescriptors: [NSSortDescriptor(keyPath: \Question.order, ascending: true)],
                  animation: .default)
    private var questions: FetchedResults<Question>

    @State private var currentQuestionIndex: Int = 0
    @State private var selectedOption: String? = nil
    @State private var showExitAlert: Bool = false
    @State private var navigateToResult: Bool = false
    @State private var navigateToGreeting: Bool = false
    @State private var navigateToHistory: Bool = false
    @State private var currentUser: User? = nil
    @State private var currentAssessment: Assessment? = nil
    @State private var assessmentStarted: Bool = false

    @AppStorage("userID") private var loggedInUserID: String = ""

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                ZStack {
                    Color.customGreen
                        .ignoresSafeArea(edges: .top)
                    
                    VStack {
                        Spacer()
                        Image("Logo_frei")
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 80, height: 80)
                        Spacer()
                    }
                }
                .frame(height: 100)
                
                VStack(spacing: 0) {
                    HStack {
                        Text("Frage \(currentQuestionIndex + 1)")
                            .font(.system(size: 26, weight: .bold))
                        
                        Spacer()
                        
                        Text("\(Int(progress() * 100))%")
                            .font(.system(size: 14, weight: .bold))
                            .foregroundColor(Color.customDarkGreen)
                        
                        ProgressView(value: progress())
                            .frame(width: 100)
                            .accentColor(Color.customDarkGreen)
                    }
                    .padding(.horizontal, 20)
                    .padding(.top, 20)
                    
                    Text(categoryName())
                        .font(.system(size: 20, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                    
                    if questions.isEmpty {
                        Text("Keine Fragen verfügbar.")
                            .font(.headline)
                            .padding()
                    } else {
                        VStack {
                            Text(questions[currentQuestionIndex].questionText ?? "Frage")
                                .font(.system(size: 18))
                                .padding()
                                .frame(maxWidth: .infinity, alignment: .leading)
                                .background(Color.white)
                                .padding(.horizontal, 5)
                                .fixedSize(horizontal: false, vertical: true)
                                .onAppear {
                                    selectedOption = questions[currentQuestionIndex].selectedOption
                                    print("Aktualisierte Antwortoption: \(selectedOption ?? "Keine Antwort")")
                                }
                                .gesture(
                                    DragGesture()
                                        .onEnded { value in
                                            if value.translation.width < 0 {
                                                if selectedOption != nil {
                                                    goToNextQuestion()
                                                }
                                            } else if value.translation.width > 0 {
                                                goToPreviousQuestion()
                                            }
                                        }
                                )
                            Spacer()
                        }
                        .frame(maxHeight: .infinity)
                    }
                    
                    VStack(spacing: 10) {
                        ForEach(answers(for: questions[currentQuestionIndex]), id: \.self) { option in
                            AnswerOptionView(option: option, isSelected: selectedOption == option)
                                .onTapGesture {
                                    selectedOption = option
                                    saveAnswer()
                                    DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
                                        goToNextQuestion()
                                    }
                                }
                        }
                    }
                    .padding(.horizontal, 20)
                    .frame(maxWidth: .infinity)
                    .frame(height: 310)
                    
                    Spacer(minLength: 20)
                    
                    HStack {
                        Button(action: goToPreviousQuestion) {
                            Text("zurück")
                                .foregroundColor(.black)
                                .padding()
                        }
                        .opacity(currentQuestionIndex > 0 ? 1.0 : 0.0)

                        Spacer()
                        
                        Button(action: { showExitAlert = true }) {
                            Text("Abbrechen")
                                .foregroundColor(.red)
                                .fontWeight(.bold)
                                .padding()
                        }
                        .alert(isPresented: $showExitAlert) {
                            Alert(
                                title: Text("Abbrechen"),
                                message: Text("Möchten Sie das Assessment wirklich abbrechen? Ihre bisherigen Antworten werden nicht gespeichert."),
                                primaryButton: .destructive(Text("Ja, abbrechen")) {
                                    handleExit()
                                },
                                secondaryButton: .cancel(Text("Nein"))
                            )
                        }
                    }
                    .padding(.horizontal, 20)
                    .padding(.bottom, 20)
                }
                .background(Color.white)
                .foregroundColor(.black)
            }
            .navigationBarHidden(true)
            .navigationTitle("Assessment")
            .navigationBarTitleDisplayMode(.inline)
            .background(Color.white.ignoresSafeArea())
            .fullScreenCover(isPresented: $navigateToResult) {
                if let assessment = currentAssessment, let user = currentUser {
                    ResultView(
                        assessment: assessment,
                        categoryResults: calculateCategoryResults(),
                        currentUser: user
                    )
                    .environment(\.managedObjectContext, viewContext)
                } else {
                    Text("Fehler: Assessment oder Benutzer nicht gefunden.")
                        .foregroundColor(.red)
                }
            }
            .navigationDestination(isPresented: $navigateToGreeting) {
                GreetingView()
            }
            .navigationDestination(isPresented: $navigateToHistory) {
                if let user = currentUser {
                    HistoryView(user: user)
                } else {
                    GreetingView()
                }
            }
        }
        .onAppear {
            if !questions.isEmpty && !assessmentStarted {
                currentUser = getCurrentUser()
                startNewAssessment()
                assessmentStarted = true
            } else {
                print("Keine Fragen verfügbar, Vorschau könnte abstürzen.")
            }
        }
    }
    
    // Berechnung des Fortschritts
    private func progress() -> Double {
        guard !questions.isEmpty else { return 0.0 }
        return Double(currentQuestionIndex + 1) / Double(questions.count)
    }
    
    // Antworten für die aktuelle Frage laden
    private func answers(for question: Question) -> [String] {
        return [
            question.answerOption3 ?? "",
            question.answerOption2 ?? "",
            question.answerOption1 ?? "",
            question.answerOption0 ?? ""
        ]
    }
    
    // Antwort speichern und dem aktuellen Assessment zuordnen
    private func saveAnswer() {
        guard let selectedOption = selectedOption else { return }

        let points = points(for: selectedOption)
        let currentQuestion = questions[currentQuestionIndex]
        currentQuestion.selectedOption = selectedOption
        currentQuestion.points = Int32(points)

        // Sicherstellen, dass jede Frage dem aktuellen Assessment zugeordnet ist
        if currentQuestion.assessment == nil {
            currentQuestion.assessment = currentAssessment
        }

        // Prüfen, ob die Frage bereits dem Assessment hinzugefügt ist
        if !(currentAssessment?.questions?.contains(currentQuestion) ?? false) {
            currentAssessment?.addToQuestions(currentQuestion)
        }

        // Speichern
        do {
            try viewContext.save()
            print("Gespeicherte Antwort: \(selectedOption) mit \(points) Punkten für Frage \(currentQuestion.questionText ?? "")")
        } catch {
            print("Fehler beim Speichern der Antwort: \(error.localizedDescription)")
        }
    }


    private func fetchOrCreateCategoryResult(for question: Question) -> CategoryResult? {
        guard let categoryName = question.categoryResult?.categoryName else { return nil }
        
        if let existingCategoryResult = currentAssessment?.categoryResults?.compactMap({ $0 as? CategoryResult }).first(where: { $0.categoryName == categoryName }) {
            return existingCategoryResult
        }
        
        let newCategoryResult = CategoryResult(context: viewContext)
        newCategoryResult.categoryName = categoryName
        newCategoryResult.assessment = currentAssessment
        currentAssessment?.addToCategoryResults(newCategoryResult)
        return newCategoryResult
    }
    
    // Punkte für die ausgewählte Antwort berechnen
    private func points(for option: String) -> Int {
        let currentQuestion = questions[currentQuestionIndex]
        if option == currentQuestion.answerOption3 {
            return 3
        } else if option == currentQuestion.answerOption2 {
            return 2
        } else if option == currentQuestion.answerOption1 {
            return 1
        } else {
            return 0
        }
    }
    
    // Zur nächsten Frage gehen
    private func goToNextQuestion() {
        // Check if all questions have been answered
        if currentQuestionIndex < questions.count - 1 {
            // Proceed to next question
            currentQuestionIndex += 1
            selectedOption = questions[currentQuestionIndex].selectedOption
            print("Nächste Frage geladen. Index: \(currentQuestionIndex)")
        } else {
            // Am Ende des Assessments Kategorien berechnen und Assessment speichern
            completeAssessment()
        }
    }

    private func completeAssessment() {
        // Kategorie-Ergebnisse berechnen und speichern
        let categoryResults = calculateCategoryResults()
        currentAssessment?.categoryResults = NSSet(array: categoryResults)
        
        // Assessment speichern
        saveAssessment()
        
        // Zur Ergebnissicht navigieren
        navigateToResult = true
        print("Assessment abgeschlossen und gespeichert.")
    }

    
    // Zur vorherigen Frage gehen
    private func goToPreviousQuestion() {
        if currentQuestionIndex > 0 {
            currentQuestionIndex -= 1
            selectedOption = questions[currentQuestionIndex].selectedOption
            print("Vorherige Frage geladen. Index: \(currentQuestionIndex)")
        }
    }
    
    private func categoryName() -> String {
        return questions[currentQuestionIndex].categoryResult?.categoryName ?? "Kategorie"
    }
    
    // Assessment abbrechen
    private func handleExit() {
        if let assessment = currentAssessment {
            viewContext.delete(assessment)
            try? viewContext.save()
            print("Assessment abgebrochen und gelöscht.")
        }
        navigateToGreeting = true
    }
    
    // Aktuellen Benutzer abrufen
    private func getCurrentUser() -> User? {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "id == %@", loggedInUserID)
        fetchRequest.fetchLimit = 1
        
        do {
            let users = try viewContext.fetch(fetchRequest)
            let user = users.first
            print("Aktueller Benutzer geladen: \(user?.name ?? "Unbekannt")")
            return user
        } catch {
            print("Fehler beim Abrufen des aktuellen Benutzers: \(error.localizedDescription)")
            return nil
        }
    }
    
    // Neues Assessment starten
    private func startNewAssessment() {
        guard let user = currentUser else {
            print("Kein Benutzer vorhanden, Assessment kann nicht gestartet werden.")
            return
        }

        selectedOption = nil
        currentQuestionIndex = 0
        assessmentStarted = true

        // Vorherige offene Assessments bereinigen (nur wenn nicht abgeschlossen)
        if let assessmentsSet = user.assessments as? Set<Assessment>,
           let existingAssessment = assessmentsSet.sorted(by: { $0.date ?? Date.distantPast < $1.date ?? Date.distantPast }).last,
           existingAssessment.overallScore == 0 {
            viewContext.delete(existingAssessment)
            print("Altes, nicht abgeschlossenes Assessment gelöscht.")
        }

        // Neues Assessment starten
        let newAssessment = Assessment(context: viewContext)
        newAssessment.id = UUID()
        newAssessment.date = Date()
        user.addToAssessments(newAssessment)
        currentAssessment = newAssessment

        for question in questions {
            question.selectedOption = nil
            question.points = 0
            question.assessment = newAssessment // Sicherstellen, dass alle Fragen zu diesem neuen Assessment gehören
        }

        do {
            try viewContext.save()
            print("Neues Assessment gestartet und Antworten zurückgesetzt.")
        } catch {
            print("Fehler beim Starten des neuen Assessments: \(error.localizedDescription)")
        }
    }

    // Assessment speichern
    private func saveAssessment() {
        currentAssessment?.overallScore = calculateOverallScore()
        currentAssessment?.overallRecommendation = fetchOverallRecommendation()
        currentAssessment?.categoryResults = NSSet(array: calculateCategoryResults())
        do {
            try viewContext.save()
            print("Assessment erfolgreich gespeichert.")
        } catch {
            print("Fehler beim Speichern des Assessments: \(error.localizedDescription)")
        }
    }
    
    // Kategorieergebnisse berechnen
    private func calculateCategoryResults() -> [CategoryResult] {
        var categoryResults: [CategoryResult] = []
        let groupedQuestions = Dictionary(grouping: questions, by: { $0.categoryResult?.categoryName })
        
        for categoryName in ["Ernährungsgewohnheiten", "Mikronährstoffaufnahme", "Risikofaktoren und Prävention", "Lebensstil und Aktivität"] {
            if let questionsInCategory = groupedQuestions[categoryName] {
                let totalScore = questionsInCategory.reduce(0) { $0 + Int($1.points) }
                let categoryResult = CategoryResult(context: viewContext)
                categoryResult.categoryName = categoryName
                categoryResult.score = Int32(totalScore)
                categoryResult.recommendation = fetchCategoryRecommendation(for: categoryResult)
                categoryResult.rating = generateRating(for: Int(totalScore), categoryName: categoryName)
                categoryResults.append(categoryResult)
                print("Kategorie \(categoryName) berechnet: \(totalScore) Punkte")
            } else {
                let categoryResult = CategoryResult(context: viewContext)
                categoryResult.categoryName = categoryName
                categoryResult.recommendation = "Bewertung für diese Kategorie nicht verfügbar."
                categoryResults.append(categoryResult)
            }
        }
        print("Kategorie-Ergebnisse berechnet.")
        return categoryResults
    }
    
    // Empfehlung für die Kategorie basierend auf dem Ergebnis abrufen
    private func fetchCategoryRecommendation(for category: CategoryResult) -> String {
        let score = Int(category.score)
        switch category.categoryName {
        case "Ernährungsgewohnheiten":
            switch score {
            case 36...45:
                return "Ihre allgemeinen Ernährungsgewohnheiten sind hervorragend."
            case 27...35:
                return "Ihre Ernährungsgewohnheiten sind insgesamt gut."
            case 18...26:
                return "Ihre Ernährungsgewohnheiten weisen einige Mängel auf."
            case 10...17:
                return "Ihre Ernährungsgewohnheiten setzen Sie einem erhöhten Risiko aus."
            default:
                return "Ihre Ernährungsgewohnheiten sind ungesund und erfordern dringend Änderungen."
            }
        case "Mikronährstoffaufnahme":
            switch score {
            case 36...45:
                return "Sie nehmen eine ausgezeichnete Menge an Mikronährstoffen zu sich."
            case 27...35:
                return "Ihre Mikronährstoffaufnahme ist gut, aber es gibt Lücken."
            case 18...26:
                return "Es gibt deutliche Lücken in Ihrer Mikronährstoffaufnahme."
            case 10...17:
                return "Ihre derzeitige Mikronährstoffaufnahme ist unzureichend."
            default:
                return "Sie sind stark gefährdet, an Mangelerscheinungen zu leiden."
            }
        case "Risikofaktoren und Prävention":
            switch score {
            case 24...30:
                return "Sie haben einen gesunden Lebensstil und ein geringes Risiko."
            case 18...23:
                return "Einige Präventionsstrategien könnten verstärkt werden."
            case 12...17:
                return "Ihr Lebensstil birgt einige Risiken."
            case 6...11:
                return "Sie haben ein erhöhtes Risiko und sollten Maßnahmen ergreifen."
            default:
                return "Ihr aktueller Lebensstil ist sehr riskant."
            }
        case "Lebensstil und Aktivität":
            switch score {
            case 24...30:
                return "Sie führen einen sehr aktiven Lebensstil."
            case 18...23:
                return "Ihr Lebensstil ist gut, aber es gibt Raum für Verbesserungen."
            case 12...17:
                return "Ihr Lebensstil hat Schwachstellen."
            case 6...11:
                return "Ihr Lebensstil birgt erhebliche Risiken."
            default:
                return "Ihr Lebensstil gefährdet Ihre Gesundheit ernsthaft."
            }
        default:
            return "Bewertung für diese Kategorie nicht verfügbar."
        }
    }
    
    // Bewertung der Kategorie basierend auf der Punktzahl generieren
    private func generateRating(for score: Int, categoryName: String) -> String {
        switch categoryName {
        case "Risikofaktoren und Prävention", "Lebensstil und Aktivität":
            switch score {
            case 24...30:
                return "Optimal"
            case 18...23:
                return "Gut"
            case 12...17:
                return "Verbesserungswürdig"
            case 6...11:
                return "Risiko"
            default:
                return "Kritisch"
            }
        default:
            switch score {
            case 36...45:
                return "Optimal"
            case 27...35:
                return "Gut"
            case 18...26:
                return "Verbesserungswürdig"
            case 10...17:
                return "Risiko"
            default:
                return "Kritisch"
            }
        }
    }
    
    // Gesamtpunktzahl für das Assessment berechnen
    private func calculateOverallScore() -> Int32 {
        let totalScore = questions.reduce(0) { $0 + $1.points }
        print("Gesamtpunktzahl berechnet: \(totalScore)")
        return totalScore
    }
   
    // Gesamt-Empfehlung basierend auf der Punktzahl abrufen
    private func fetchOverallRecommendation() -> String {
        let score = calculateOverallScore()
        switch score {
        case 120...150:
            return "Deine Ernährung und dein Lebensstil sind hervorragend ausbalanciert."
        case 90...119:
            return "Deine Gesundheit ist gut, es gibt jedoch Raum für Verbesserungen."
        case 60...89:
            return "Deine Ernährung und dein Lebensstil sind überwiegend in Ordnung."
        case 30...59:
            return "Dein aktueller Lebensstil könnte dein Risiko erhöhen."
        default:
            return "Es sind wesentliche Änderungen erforderlich, um deine Gesundheit zu verbessern."
        }
    }
}

struct AnswerOptionView: View {
    var option: String
    var isSelected: Bool
    
    var body: some View {
        Text(option)
            .padding()
            .frame(maxWidth: .infinity)
            .background(isSelected ? Color.customDarkGreen : Color.customGreen)
            .cornerRadius(10)
            .foregroundColor(isSelected ? .white : .black)
            .font(.system(size: 18))
    }
}
