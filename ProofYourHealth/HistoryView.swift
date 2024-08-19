import SwiftUI
import CoreData

struct HistoryView: View {
    var user: User
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(entity: Assessment.entity(), sortDescriptors: [NSSortDescriptor(keyPath: \Assessment.date, ascending: false)])
    private var assessments: FetchedResults<Assessment>
    
    @State private var selectedAssessment: Assessment?
    @State private var navigateToResultView = false
    @State private var navigateToQuestionView = false

    var body: some View {
        VStack(spacing: 0) {
            // Header
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

            // Begrüßung und Überschrift
            Text("Hallo, \(user.name ?? "Benutzer")")
                .font(.system(size: 22, weight: .medium))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 20)

            Text("Deine Ergebnisse")
                .font(.system(size: 26, weight: .bold))
                .frame(maxWidth: .infinity, alignment: .leading)
                .padding(.horizontal, 20)
                .padding(.top, 10)
            
            // Dynamische Liste der Ergebnisse
            if assessments.isEmpty {
                Text("Keine Ergebnisse verfügbar.")
                    .font(.system(size: 18))
                    .padding(.top, 20)
            } else {
                List {
                    ForEach(assessments, id: \.self) { assessment in
                        Button(action: {
                            selectedAssessment = assessment
                            navigateToResultView = true
                        }) {
                            HStack {
                                Text(formattedDate(assessment.date))
                                    .font(.system(size: 18))
                                
                                Spacer()
                                
                                Text("\(calculatePercentage(for: assessment)) %")
                                    .font(.system(size: 18, weight: .bold))
                                
                                Image(iconName(for: assessment.overallScore))
                                    .resizable()
                                    .frame(width: 24, height: 24)
                                    .foregroundColor(Color.customGreen)
                            }
                            .padding(.horizontal, 10)
                            .padding(.vertical, 7)
                        }
                    }
                }
                .listStyle(PlainListStyle())
            }

            Spacer()

            // Button zum Starten eines neuen Tests
            Button(action: {
                startNewAssessment(for: user)
            }) {
                Text("Test durchführen")
                    .font(.headline)
                    .foregroundColor(.white)
                    .padding()
                    .frame(maxWidth: .infinity)
                    .background(Color.customDarkGreen)
                    .cornerRadius(10)
                    .padding(.horizontal, 20)
            }
            .padding(.bottom, 20)
        }
        .background(
            NavigationLink(
                destination: ResultView(
                    assessment: selectedAssessment ?? assessments.first!,
                    categoryResults: calculateCategoryResults(for: selectedAssessment ?? assessments.first!),
                    currentUser: user
                ).environment(\.managedObjectContext, viewContext),
                isActive: $navigateToResultView
            ) {
                EmptyView()
            }
            .hidden()
        )
        .background(
            NavigationLink(
                destination: QuestionView().environment(\.managedObjectContext, viewContext),
                isActive: $navigateToQuestionView
            ) {
                EmptyView()
            }
            .hidden()
        )
    }
    
    private func formattedDate(_ date: Date?) -> String {
        guard let date = date else { return "Unbekanntes Datum" }
        let formatter = DateFormatter()
        formatter.dateStyle = .short
        formatter.timeStyle = .short
        return formatter.string(from: date)
    }

    private func calculatePercentage(for assessment: Assessment) -> Int {
        let maxScore: Int32 = 150
        return Int((Double(assessment.overallScore) / Double(maxScore)) * 100)
    }

    private func iconName(for score: Int32) -> String {
        switch score {
        case 120...150:
            return "Cat1"
        case 90...119:
            return "Cat2"
        case 60...89:
            return "Cat3"
        case 30...59:
            return "Cat4"
        default:
            return "Cat5"
        }
    }

    // Start eines neuen Assessments
    private func startNewAssessment(for user: User) {
        // Vorherige nicht abgeschlossene Assessments löschen
        if let assessmentsSet = user.assessments as? Set<Assessment>,
           let lastAssessment = assessmentsSet.sorted(by: { $0.date ?? Date.distantPast < $1.date ?? Date.distantPast }).last,
           lastAssessment.overallScore == 0 {
            viewContext.delete(lastAssessment)
            print("Nicht abgeschlossenes Assessment gelöscht.")
        }
        
        // Neues Assessment erstellen
        let newAssessment = Assessment(context: viewContext)
        newAssessment.id = UUID()
        newAssessment.date = Date()
        newAssessment.user = user
        
        // Leere CategoryResults und Fragen initialisieren
        initializeCategoryResults(for: newAssessment)

        // Speichern und Navigation zur QuestionView
        do {
            try viewContext.save()
            selectedAssessment = newAssessment
            navigateToQuestionView = true
        } catch {
            print("Fehler beim Speichern des neuen Assessments: \(error)")
        }
    }

    // Kategorieresultate initialisieren
    private func initializeCategoryResults(for assessment: Assessment) {
        let categories = ["Ernährungsgewohnheiten", "Mikronährstoffaufnahme", "Risikofaktoren und Prävention", "Lebensstil und Aktivität"]
        for categoryName in categories {
            let categoryResult = CategoryResult(context: viewContext)
            categoryResult.id = UUID()
            categoryResult.categoryName = categoryName
            categoryResult.assessment = assessment
            assessment.addToCategoryResults(categoryResult)

            // Alle Fragen und Antworten für diese Kategorie zurücksetzen
            initializeQuestions(for: categoryResult)
        }
    }

    // Fragen zurücksetzen oder initialisieren
    private func initializeQuestions(for categoryResult: CategoryResult) {
        let questions = categoryResult.questionsArray
        if questions.isEmpty {
            // Initialisiere Standardfragen, falls keine vorhanden sind
            // Hier könntest du eine Logik hinzufügen, um neue Fragen zu generieren
        } else {
            print("Fragen bereits vorhanden. Antworten und Punkte zurücksetzen.")
            for question in questions {
                question.selectedOption = nil
                question.points = 0
            }
        }
    }

    private func calculateCategoryResults(for assessment: Assessment) -> [CategoryResult] {
        guard let categoryResultsSet = assessment.categoryResults as? Set<CategoryResult> else {
            return []
        }
        return Array(categoryResultsSet).sorted { $0.categoryName ?? "" < $1.categoryName ?? "" }
    }
}
