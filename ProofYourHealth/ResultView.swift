import SwiftUI

struct ResultView: View {
    @Environment(\.managedObjectContext) private var viewContext
    var assessment: Assessment
    var categoryResults: [CategoryResult]
    var currentUser: User

    @State private var showDetailedResults = false

    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Header mit Logo
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

                VStack(spacing: 20) {
                    // Gesamtbewertung
                    HStack {
                        Text("Dein Ergebnis")
                            .font(.system(size: 26, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                            .padding(.top, 20)
                    }

                    HStack {
                        Text("Bewertung")
                            .font(.system(size: 20, weight: .bold))
                            .frame(maxWidth: .infinity, alignment: .leading)
                            .padding(.horizontal, 20)
                            .padding(.top, 10)
                        
                        Image(iconName(for: assessment.overallScore))
                            .resizable()
                            .aspectRatio(contentMode: .fit)
                            .frame(width: 40, height: 40)
                            .padding(.trailing, 20)
                    }

                    Text(assessment.overallRecommendation ?? "Keine Empfehlung")
                        .font(.system(size: 18))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)

                    // Anzeige der Kategorien und Empfehlungen
                    Text("Bewertung Kategorien")
                        .font(.system(size: 20, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)

                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            ForEach(categoryResults, id: \.self) { category in
                                VStack(alignment: .leading, spacing: 5) {
                                    HStack {
                                        Text("\(category.categoryName ?? "Kategorie"): \(category.rating ?? "Keine Bewertung")")
                                            .font(.system(size: 18, weight: .bold))
                                            .padding(.horizontal, 20)
                                        
                                        Spacer()
                                        
                                        Image(iconName(for: category.rating ?? ""))
                                            .resizable()
                                            .aspectRatio(contentMode: .fit)
                                            .frame(width: 30, height: 30)
                                            .padding(.trailing, 20)
                                    }
                                    
                                    Text(category.recommendation ?? "Keine Empfehlung")
                                        .font(.system(size: 18))
                                        .padding(.horizontal, 20)
                                        .foregroundColor(.gray)
                                }
                            }
                        }
                        .padding(.top, 10)
                    }

                    Spacer()

                    // Link zur DetailedResultsView
                    Text("Detailergebnisse ansehen")
                        .font(.system(size: 20, weight: .bold))
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .padding(.horizontal, 20)
                        .padding(.top, 20)
                        .onTapGesture {
                            showDetailedResults = true
                        }
                        .sheet(isPresented: $showDetailedResults) {
                            DetailedResultsView(categoryResults: categoryResults, assessment: assessment)
                        }

                    // Button zur HistoryView
                    NavigationLink(destination: HistoryView(user: currentUser)) {
                        Text("Meine Ergebnisse")
                            .foregroundColor(.white)
                            .padding()
                            .frame(maxWidth: .infinity)
                            .background(Color.customDarkGreen)
                            .cornerRadius(10)
                            .padding(.horizontal, 20)
                    }
                    .padding(.bottom, 30)
                }
                .background(Color.white)
                .foregroundColor(.black)
            }
            .navigationBarHidden(true)
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    private func iconName(for rating: String) -> String {
        switch rating {
        case "Optimal":
            return "Cat1"
        case "Gut":
            return "Cat2"
        case "Verbesserungswürdig":
            return "Cat3"
        case "Risiko":
            return "Cat4"
        default:
            return "Cat5"
        }
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
}

//Detailansicht der Fragen und Antworten 
struct DetailedResultsView: View {
    @Environment(\.presentationMode) var presentationMode
    var categoryResults: [CategoryResult]
    var assessment: Assessment

    var body: some View {
        NavigationView {
            List {
                ForEach(assessment.questionsArray, id: \.id) { question in
                    VStack(alignment: .leading) {
                        Text("Frage: \(question.questionText ?? "Keine Frage")")
                            .font(.headline)
                        Text("Gewählte Antwort: \(question.selectedOption ?? "Keine Antwort")")
                    }
                    .padding()
                    .cornerRadius(8)
                }
            }
            .navigationTitle("Detail Ergebnisse")
            .navigationBarItems(trailing: Button("Fertig") {
                presentationMode.wrappedValue.dismiss()
            })
        }
    }
}


