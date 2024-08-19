import SwiftUI
import CoreData

struct LoginView: View {
    @Environment(\.managedObjectContext) private var viewContext
    @FetchRequest(
        sortDescriptors: [NSSortDescriptor(keyPath: \User.name, ascending: true)],
        animation: .default)
    private var users: FetchedResults<User>
    
    @AppStorage("email") var loggedInEmail: String = ""
    @AppStorage("password") var loggedInPassword: String = ""
    @AppStorage("userID") var loggedInUserID: String = ""

    @State private var email = ""
    @State private var password = ""
    @State private var isLoggedIn = false
    @State private var showErrorLoginAlert = false
    @State private var navigateToGreetingView = false
    @State private var navigateToHistoryView = false
    @State private var user: FetchedResults<User>.Element?

    var body: some View {
        NavigationView {
            VStack(spacing: 20) {
                Spacer().frame(height: 50)
                
                logoView
                
                titleView
                
                emailField
                passwordField
                
                loginButton
                
                footerLinks
                
                Spacer()
            }
            .background(Color.customGreen)
            .navigationBarHidden(true)
            .overlay(
                NavigationLink(destination: GreetingView(), isActive: $navigateToGreetingView) {
                    EmptyView()
                }
                .hidden()
            )
            .overlay(
                Group {
                    if let user = user {
                        NavigationLink(destination: HistoryView(user: user), isActive: $navigateToHistoryView) {
                            EmptyView()
                        }
                        .hidden()
                    }
                }
            )
            .alert("Anmeldedaten fehlerhaft", isPresented: $showErrorLoginAlert) {
                Button("OK", role: .cancel) { }
            } message: {
                Text("Bitte prüfen Sie die Anmeldedaten")
            }
            .onAppear(perform: checkAutoLogin)
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    var logoView: some View {
        Image("Logo_frei")
            .resizable()
            .aspectRatio(contentMode: .fit)
            .frame(width: 150, height: 150)
            .padding(.bottom, 30)
    }
    
    var titleView: some View {
        Text("Proof your Health!")
            .font(.title)
            .fontWeight(.bold)
            .foregroundColor(.black)
            .padding(.bottom, 20)
    }
    
    var emailField: some View {
        VStack(alignment: .leading) {
            Text("E-Mail-Adresse")
                .foregroundColor(.black)
            TextField("", text: $email)
                .padding()
                .background(Color.white)
                .cornerRadius(5.0)
                .overlay(
                    RoundedRectangle(cornerRadius: 5.0)
                        .stroke(Color.black, lineWidth: 1)
                )
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textContentType(.emailAddress)
                .keyboardType(.emailAddress)
        }
        .padding(.horizontal, 40)
    }
    
    var passwordField: some View {
        VStack(alignment: .leading) {
            Text("Passwort")
                .foregroundColor(.black)
            SecureField("", text: $password)
                .padding()
                .background(Color.white)
                .cornerRadius(5.0)
                .overlay(
                    RoundedRectangle(cornerRadius: 5.0)
                        .stroke(Color.black, lineWidth: 1)
                )
                .autocapitalization(.none)
                .disableAutocorrection(true)
                .textContentType(.password)
        }
        .padding(.horizontal, 40)
    }
    
    var loginButton: some View {
        Button(action: handleLogin) {
            Text("Anmelden")
                .font(.headline)
                .foregroundColor(.white)
                .padding()
                .frame(maxWidth: .infinity, minHeight: 60)
                .background(Color.black)
                .cornerRadius(15.0)
                .padding(.horizontal, 40)
        }
        .padding(.top, 20)
    }
    
    var footerLinks: some View {
        VStack {
            Button(action: {
                // Passwort vergessen Logik hier
            }) {
                Text("Passwort vergessen?")
                    .foregroundColor(Color.black)
            }
            .padding(.top, 20)
            
            Button(action: {
                // Registrieren Logik hier
            }) {
                Text("Registrieren")
                    .foregroundColor(Color.black)
                    .bold()
            }
            .padding(.top, 5)
        }
    }
    
    func handleLogin() {
        let sanitizedEmail = email.trimmingCharacters(in: .whitespacesAndNewlines).lowercased()
        let sanitizedPassword = password.trimmingCharacters(in: .whitespacesAndNewlines)
        
        if let user = users.first(where: { $0.email?.lowercased() == sanitizedEmail && $0.password == sanitizedPassword }) {
            self.loggedInEmail = sanitizedEmail
            self.loggedInPassword = sanitizedPassword
            if let id = user.id?.uuidString {
                self.loggedInUserID = id
            }
            self.user = user
            self.navigateToNextView(for: user)
        } else {
            showErrorLoginAlert = true
        }
    }
    
    func checkAutoLogin() {
        let sanitizedEmail = loggedInEmail.lowercased()
        let sanitizedPassword = loggedInPassword
        
        if !loggedInEmail.isEmpty && !loggedInPassword.isEmpty {
            if let user = users.first(where: { $0.email?.lowercased() == sanitizedEmail && $0.password == sanitizedPassword }) {
                self.user = user
                self.navigateToNextView(for: user)
            }
        }
    }
    
    private func navigateToNextView(for user: User) {
        if user.assessments?.count ?? 0 > 0 {
            navigateToHistoryView = true
        } else {
            navigateToGreetingView = true
        }
    }
}
