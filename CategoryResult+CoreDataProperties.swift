import Foundation
import CoreData

extension CategoryResult {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<CategoryResult> {
        return NSFetchRequest<CategoryResult>(entityName: "CategoryResult")
    }

    @NSManaged public var categoryName: String?
    @NSManaged public var id: UUID?
    @NSManaged public var rating: String?
    @NSManaged public var recommendation: String?
    @NSManaged public var score: Int32
    @NSManaged public var assessment: Assessment?
    @NSManaged public var questions: NSSet?
    
    // Zugriff auf Fragen als Array
    var questionsArray: [Question] {
        let set = questions as? Set<Question> ?? []
        return set.sorted { $0.order < $1.order }
    }

}

// MARK: Generated accessors for questions
extension CategoryResult {

    @objc(addQuestionsObject:)
    @NSManaged public func addToQuestions(_ value: Question)

    @objc(removeQuestionsObject:)
    @NSManaged public func removeFromQuestions(_ value: Question)

    @objc(addQuestions:)
    @NSManaged public func addToQuestions(_ values: NSSet)

    @objc(removeQuestions:)
    @NSManaged public func removeFromQuestions(_ values: NSSet)
}

extension CategoryResult: Identifiable {}
