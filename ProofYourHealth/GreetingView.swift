import SwiftUI

struct GreetingView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \User.id, ascending: true)],
        animation: .default)
    private var users: FetchedResults<User>

    @State private var navigateToQuestions = false
    
    var body: some View {
        NavigationView {
            VStack {
                // Oberer grüner Bereich mit Logo und Text
                VStack(spacing: 20) {
                    Image("Logo_frei")
                        .resizable()
                        .aspectRatio(contentMode: .fit)
                        .frame(width: 100, height: 100)
                        .padding(.top, 50)

                    Text("Willkommen zu deinem persönlichen Gesundheits-Check!")
                        .font(.system(size: 30))
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .padding(.bottom, 20)

                    Text("Entdecke, wie deine Ernährungs- und Lebensgewohnheiten deine Gesundheit beeinflussen – und erhalte maßgeschneiderte Tipps, um dein Wohlbefinden zu verbessern.")
                        .font(.system(size: 20))
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .padding(.bottom, 30)


                    Text("Nimm dir ein paar Minuten Zeit und erfahre, ob du auf dem richtigen Weg bist oder wo noch Potenzial steckt. Starte jetzt und mache den ersten Schritt zu einem gesünderen Leben!")
                        .font(.system(size: 20))
                        .fontWeight(.medium)
                        .multilineTextAlignment(.center)
                        .padding(.horizontal, 30)
                        .padding(.bottom, 30)
                }
                .background(Color.customGreen)
                .foregroundColor(.black)

                Spacer()

                // Button zum Starten des Fragebogens
                Button(action: {
                    if let user = users.first {
                        navigateToQuestions = user.lastAssessment == nil
                    } else {
                        navigateToQuestions = true
                    }
                }) {
                    Text("Los geht's!")
                        .foregroundColor(.white)
                        .padding()
                        .frame(maxWidth: .infinity)
                        .background(Color.customDarkGreen)
                        .cornerRadius(10)
                }
                .padding(.horizontal, 20)
                .padding(.bottom, 30)

                // Navigation
                NavigationLink(
                    destination: QuestionView()
                        .environment(\.managedObjectContext, viewContext),
                    isActive: $navigateToQuestions) {
                        EmptyView()
                }
            }
            .background(Color.customGreen)
            .navigationBarHidden(true)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
}
