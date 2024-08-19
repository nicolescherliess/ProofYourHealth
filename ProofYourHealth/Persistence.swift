import CoreData

struct PersistenceController {
    static let shared = PersistenceController()

    let container: NSPersistentContainer

    init(inMemory: Bool = false) {
        container = NSPersistentContainer(name: "ProofYourHealth")
        if inMemory {
            container.persistentStoreDescriptions.first?.url = URL(fileURLWithPath: "/dev/null")
        }
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        
        // Initialisiere Benutzer, Kategorien und Fragen
        initializeUsers(context: container.viewContext)
        initializeCategoriesAndQuestions(context: container.viewContext)
    }

    var viewContext: NSManagedObjectContext {
        return container.viewContext
    }

    static var preview: PersistenceController = {
        let controller = PersistenceController(inMemory: true)
        let viewContext = controller.container.viewContext
        controller.initializeUsers(context: viewContext)
        controller.initializeCategoriesAndQuestions(context: viewContext)
        return controller
    }()

    // Initialisiere die Benutzer
    func initializeUsers(context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<User> = User.fetchRequest()
        
        do {
            let count = try context.count(for: fetchRequest)
            if count == 0 {
                let users = [
                    (id: UUID(), name: "Hannah Wagner", email: "hannah.wagner@test.de", password: "%\"{`}7O{"),
                    (id: UUID(), name: "Hannah Müller", email: "hannah.müller@test.de", password: "K*t^YX^#"),
                    (id: UUID(), name: "Lina Schmidt", email: "lina.schmidt@test.de", password: "<t$?','H"),
                    (id: UUID(), name: "Leon Weber", email: "leon.weber@beispiel.de", password: "*j??nUZM"),
                    (id: UUID(), name: "Hannah Meyer", email: "hannah.meyer@mail.de", password: "jdo$:Ua]"),
                    (id: UUID(), name: "Leon Schmidt", email: "leon.schmidt@test.de", password: "ed4mU,uL"),
                    (id: UUID(), name: "Leon Müller", email: "leon.müller@beispiel.de", password: ".Ea1uA4@"),
                    (id: UUID(), name: "Paul Meyer", email: "paul.meyer@test.de", password: "TkC^8XC$"),
                    (id: UUID(), name: "Louise", email: "1", password: "1")
                ]
                
                for userData in users {
                    let user = User(context: context)
                    user.id = userData.id
                    user.name = userData.name
                    user.email = userData.email
                    user.password = userData.password
                }
                
                try context.save()
            }
        } catch {
            print("Die Benutzer konnten nicht abgerufen oder gespeichert werden: \(error)")
        }
    }

    // Initialisiere die Kategorien und Fragen
    func initializeCategoriesAndQuestions(context: NSManagedObjectContext) {
        let fetchRequest: NSFetchRequest<CategoryResult> = CategoryResult.fetchRequest()

        do {
            let count = try context.count(for: fetchRequest)
            if count == 0 {
                // Kategorien erstellen
                let categoriesData = [
                    (id: UUID(), name: "Ernährungsgewohnheiten"),
                    (id: UUID(), name: "Mikronährstoffaufnahme"),
                    (id: UUID(), name: "Risikofaktoren und Prävention"),
                    (id: UUID(), name: "Lebensstil und Aktivität")
                ]
                
                var categories = [UUID: CategoryResult]()
                
                for (id, name) in categoriesData {
                    let category = CategoryResult(context: context)
                    category.id = id
                    category.categoryName = name
                    categories[id] = category
                    print("Kategorie erstellt: \(name)")
                }
                
                // Fragen initialisieren und Kategorien zuweisen
                let questionsData = [
                    (UUID(), "Wie oft konsumierst du pro Woche Obst?", "Täglich", "4-6 Mal pro Woche", "2-3 Mal pro Woche", "Seltener", categories[categoriesData[0].id]!, 1),
                    (UUID(), "Wie oft isst du Gemüse pro Tag?", "Mehr als 3 Portionen", "2-3 Portionen", "1 Portion", "Seltener", categories[categoriesData[0].id]!, 2),
                    (UUID(), "Wie häufig konsumierst du Vollkornprodukte?", "Bei jeder Mahlzeit", "Einmal täglich", "Mehrmals pro Woche", "Selten", categories[categoriesData[0].id]!, 3),
                    (UUID(), "Welche Art von Fetten konsumierst du hauptsächlich?", "Ungesättigte Fette", "Mischung aus gesättigten und ungesättigten Fetten", "Gesättigte Fette", "Transfette", categories[categoriesData[0].id]!, 4),
                    (UUID(), "Wie oft isst du verarbeitete Lebensmittel (z.B. Fast Food, Fertiggerichte)?", "Selten", "1-2 Mal pro Woche", "3-4 Mal pro Woche", "Täglich", categories[categoriesData[0].id]!, 5),
                    (UUID(), "Wie häufig konsumierst du zuckerhaltige Getränke?", "Nie", "Einmal pro Woche", "Mehrmals pro Woche", "Täglich", categories[categoriesData[0].id]!, 6),
                    (UUID(), "Wie oft konsumierst du Milchprodukte oder kalziumreiche Lebensmittel?", "Täglich", "4-6 Mal pro Woche", "2-3 Mal pro Woche", "Selten", categories[categoriesData[0].id]!, 7),
                    (UUID(), "Wie häufig konsumierst du rotes Fleisch?", "Selten", "1-2 Mal pro Woche", "3-4 Mal pro Woche", "Täglich", categories[categoriesData[0].id]!, 8),
                    (UUID(), "Wie oft konsumierst du Fisch oder andere Omega-3-reiche Lebensmittel?", "Mehrmals pro Woche", "Einmal pro Woche", "Seltener", "Nie", categories[categoriesData[0].id]!, 9),
                    (UUID(), "Wie oft nimmst du Hülsenfrüchte (z.B. Bohnen, Linsen) in deine Ernährung auf?", "Täglich", "Mehrmals pro Woche", "Einmal pro Woche", "Selten/Nie", categories[categoriesData[0].id]!, 10),
                    (UUID(), "Wie oft isst du Frühstück?", "Täglich", "Mehrmals pro Woche", "Selten", "Nie", categories[categoriesData[0].id]!, 11),
                    (UUID(), "Wie oft konsumierst du Snacks zwischen den Mahlzeiten?", "Nie", "Einmal pro Tag", "Mehrmals pro Tag", "Ständig", categories[categoriesData[0].id]!, 12),
                    (UUID(), "Wie häufig konsumierst du alkoholische Getränke?", "Nie", "Einmal pro Woche", "Mehrmals pro Woche", "Täglich", categories[categoriesData[0].id]!, 13),
                    (UUID(), "Wie oft konsumierst du fettreiche Milchprodukte (z.B. Käse, Butter)?", "Selten/Nie", "1-2 Mal pro Woche", "Mehrmals pro Woche", "Täglich", categories[categoriesData[0].id]!, 14),
                    (UUID(), "Wie oft isst du frisches Obst als Dessert?", "Täglich", "Mehrmals pro Woche", "Einmal pro Woche", "Nie", categories[categoriesData[0].id]!, 15),
                    (UUID(), "Wie oft konsumierst du Vitamin-D-reiche Lebensmittel (z.B. fetter Fisch, angereicherte Produkte)?", "Täglich", "Mehrmals pro Woche", "Einmal pro Woche", "Seltener", categories[categoriesData[1].id]!, 16),
                    (UUID(), "Wie häufig nimmst du eisenreiche Lebensmittel zu dir (z.B. rotes Fleisch, Spinat)?", "Täglich", "Mehrmals pro Woche", "Einmal pro Woche", "Selten", categories[categoriesData[1].id]!, 17),
                    (UUID(), "Wie oft isst du Lebensmittel, die reich an Vitamin C sind (z.B. Zitrusfrüchte, Paprika)?", "Täglich", "Mehrmals pro Woche", "Einmal pro Woche", "Seltener", categories[categoriesData[1].id]!, 18),
                    (UUID(), "Wie häufig konsumierst du Nüsse und Samen?", "Täglich", "Mehrmals pro Woche", "Einmal pro Woche", "Selten", categories[categoriesData[1].id]!, 19),
                    (UUID(), "Wie oft konsumierst du kaliumreiche Lebensmittel (z.B. Bananen, Kartoffeln)?", "Täglich", "Mehrmals pro Woche", "Einmal pro Woche", "Seltener", categories[categoriesData[1].id]!, 20),
                    (UUID(), "Wie häufig nimmst du Magnesium über die Ernährung auf (z.B. durch Nüsse, Vollkornprodukte)?", "Täglich", "Mehrmals pro Woche", "Einmal pro Woche", "Seltener", categories[categoriesData[1].id]!, 21),
                    (UUID(), "Wie oft konsumierst du zinkreiche Lebensmittel (z.B. Fleisch, Hülsenfrüchte)?", "Täglich", "Mehrmals pro Woche", "Einmal pro Woche", "Selten", categories[categoriesData[1].id]!, 22),
                    (UUID(), "Wie oft nimmst du Ballaststoffe zu dir (z.B. durch Obst, Gemüse, Vollkornprodukte)?", "Mehr als 30g täglich", "20-30g täglich", "10-20g täglich", "Weniger als 10g täglich", categories[categoriesData[1].id]!, 23),
                    (UUID(), "Wie oft konsumierst du Produkte, die reich an B-Vitaminen sind (z.B. Vollkorn, Fleisch)?", "Täglich", "Mehrmals pro Woche", "Einmal pro Woche", "Seltener", categories[categoriesData[1].id]!, 24),
                    (UUID(), "Wie häufig nimmst du Calcium-Supplements oder angereicherte Lebensmittel?", "Täglich", "Mehrmals pro Woche", "Einmal pro Woche", "Seltener", categories[categoriesData[1].id]!, 25),
                    (UUID(), "Wie oft konsumierst du Omega-3-Supplements oder angereicherte Lebensmittel?", "Täglich", "Mehrmals pro Woche", "Einmal pro Woche", "Seltener/Nie", categories[categoriesData[1].id]!, 26),
                    (UUID(), "Wie oft isst du eisenhaltige pflanzliche Lebensmittel (z.B. Hülsenfrüchte, grünes Blattgemüse)?", "Täglich", "Mehrmals pro Woche", "Einmal pro Woche", "Seltener", categories[categoriesData[1].id]!, 27),
                    (UUID(), "Wie häufig konsumierst du Lebensmittel, die reich an Antioxidantien sind (z.B. Beeren, Nüsse)?", "Täglich", "Mehrmals pro Woche", "Einmal pro Woche", "Seltener", categories[categoriesData[1].id]!, 28),
                    (UUID(), "Wie oft nimmst du Vitamin B12-Supplements oder angereicherte Lebensmittel?", "Täglich", "Mehrmals pro Woche", "Einmal pro Woche", "Seltener/Nie", categories[categoriesData[1].id]!, 29),
                    (UUID(), "Wie oft konsumierst du jodreiche Lebensmittel (z.B. Meeresfrüchte, jodiertes Salz)?", "Täglich", "Mehrmals pro Woche", "Einmal pro Woche", "Seltener/Nie", categories[categoriesData[1].id]!, 30),
                    (UUID(), "Leidest du unter Bluthochdruck?", "Nein", "Ja, unter Kontrolle durch Ernährung", "Ja, unter Kontrolle durch Medikamente", "Ja, unkontrolliert", categories[categoriesData[2].id]!, 31),
                    (UUID(), "Leidest du unter Hypercholesterinämie?", "Nein", "Ja, unter Kontrolle durch Ernährung", "Ja, unter Kontrolle durch Medikamente", "Ja, unkontrolliert", categories[categoriesData[2].id]!, 32),
                    (UUID(), "Wie oft konsumierst du Lebensmittel mit hohem Salzgehalt?", "Selten", "1-2 Mal pro Woche", "3-4 Mal pro Woche", "Täglich", categories[categoriesData[2].id]!, 33),
                    (UUID(), "Hast du eine familiäre Vorgeschichte von Herz-Kreislauf-Erkrankungen?", "Nein", "Ja, aber ich achte sehr auf meine Ernährung", "Ja, ich mache mir Sorgen, aber tue nicht viel dagegen", "Ja, und ich nehme keine speziellen Maßnahmen", categories[categoriesData[2].id]!, 34),
                    (UUID(), "Wie oft konsumierst du zuckerreiche Lebensmittel?", "Selten", "1-2 Mal pro Woche", "Mehrmals pro Woche", "Täglich", categories[categoriesData[2].id]!, 35),
                    (UUID(), "Wie oft konsumierst du frittierte Lebensmittel?", "Nie", "Einmal pro Woche", "Mehrmals pro Woche", "Täglich", categories[categoriesData[2].id]!, 36),
                    (UUID(), "Wie hoch ist dein BMI (Body Mass Index)?", "Normalgewicht", "Leichtes Übergewicht", "Übergewicht", "Starkes Übergewicht", categories[categoriesData[2].id]!, 37),
                    (UUID(), "Wie oft hast du gesundheitliche Check-ups oder Bluttests, um Nährstoffmängel zu überprüfen?", "Regelmäßig", "Gelegentlich", "Selten", "Nie", categories[categoriesData[2].id]!, 38),
                    (UUID(), "Wie oft rauchst oder trinkst du Alkohol?", "Nie", "Gelegentlich", "Mehrmals pro Woche", "Täglich", categories[categoriesData[2].id]!, 39),
                    (UUID(), "Wie häufig hast du Verdauungsbeschwerden (z.B. Sodbrennen, Blähungen)?", "Nie", "Selten", "Regelmäßig", "Häufig", categories[categoriesData[2].id]!, 40),
                    (UUID(), "Wie oft treibst du körperliche Aktivität (mindestens 30 Minuten pro Tag)?", "Täglich", "4-6 Mal pro Woche", "2-3 Mal pro Woche", "Seltener", categories[categoriesData[3].id]!, 41),
                    (UUID(), "Wie viele Stunden schläfst du durchschnittlich pro Nacht?", "Mehr als 8 Stunden", "7-8 Stunden", "5-6 Stunden", "Weniger als 5 Stunden", categories[categoriesData[3].id]!, 42),
                    (UUID(), "Wie häufig nimmst du Entspannungs- oder Stressbewältigungsmaßnahmen in Anspruch (z.B. Yoga, Meditation)?", "Täglich", "Mehrmals pro Woche", "Einmal pro Woche", "Selten/Nie", categories[categoriesData[3].id]!, 43),
                    (UUID(), "Wie oft isst du in Ruhe ohne Ablenkungen (z.B. Fernsehen, Handy)?", "Immer", "Oft", "Manchmal", "Selten/Nie", categories[categoriesData[3].id]!, 44),
                    (UUID(), "Wie oft kochst du frische Mahlzeiten selbst?", "Täglich", "Mehrmals pro Woche", "Einmal pro Woche", "Selten/Nie", categories[categoriesData[3].id]!, 45),
                    (UUID(), "Wie oft greifst du auf Fast Food oder Lieferdienste zurück?", "Nie", "Einmal pro Woche", "Mehrmals pro Woche", "Täglich", categories[categoriesData[3].id]!, 46),
                    (UUID(), "Wie oft trinkst du Wasser pro Tag (mindestens 1,5 Liter)?", "Mehr als 2 Liter täglich", "1,5-2 Liter täglich", "1-1,5 Liter täglich", "Weniger als 1 Liter täglich", categories[categoriesData[3].id]!, 47),
                    (UUID(), "Wie häufig konsumierst du koffeinhaltige Getränke (z.B. Kaffee, Cola)?", "Nie", "1-2 Tassen täglich", "3-4 Tassen täglich", "Mehr als 4 Tassen täglich", categories[categoriesData[3].id]!, 48),
                    (UUID(), "Wie oft konsumierst du stark verarbeitete Snacks (z.B. Chips, Kekse)?", "Nie", "Einmal pro Woche", "Mehrmals pro Woche", "Täglich", categories[categoriesData[3].id]!, 49),
                    (UUID(), "Wie oft isst du Lebensmittel, die reich an Antioxidantien sind (z.B. Beeren, Nüsse)?", "Täglich", "Mehrmals pro Woche", "Einmal pro Woche", "Seltener", categories[categoriesData[3].id]!, 50)
                ]


                for (id, questionText, option3, option2, option1, option0, category, order) in questionsData {
                    let question = Question(context: context)
                    question.id = id
                    question.questionText = questionText
                    question.answerOption3 = option3
                    question.answerOption2 = option2
                    question.answerOption1 = option1
                    question.answerOption0 = option0
                    question.order = Int32(order)
                    question.categoryResult = category  // Kategorie zuweisen
                    print("Frage erstellt: \(questionText) mit Kategorie: \(category.categoryName ?? "Keine Kategorie")")
                    category.addToQuestions(question)
                }
                
                try context.save()
            }
        } catch {
            print("Kategorien und Fragen konnten nicht abgerufen oder gespeichert werden: \(error)")
        }
    }
}
