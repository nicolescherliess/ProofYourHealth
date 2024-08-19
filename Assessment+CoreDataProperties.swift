import Foundation
import CoreData

extension Assessment {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Assessment> {
        return NSFetchRequest<Assessment>(entityName: "Assessment")
    }

    @NSManaged public var date: Date?
    @NSManaged public var id: UUID?
    @NSManaged public var overallRecommendation: String?
    @NSManaged public var overallScore: Int32
    @NSManaged public var categoryResults: NSSet?   // Die Beziehung zu CategoryResult
    @NSManaged public var user: User?
    @NSManaged public var questions: NSSet?

    // Zugriff auf Fragen als Array
    var questionsArray: [Question] {
        let set = questions as? Set<Question> ?? []
        return set.sorted { $0.order < $1.order }
    }

    // MARK: Generated accessors for categoryResults
    @objc(addCategoryResultsObject:)
    @NSManaged public func addToCategoryResults(_ value: CategoryResult)

    @objc(removeCategoryResultsObject:)
    @NSManaged public func removeFromCategoryResults(_ value: CategoryResult)

    @objc(addCategoryResults:)
    @NSManaged public func addToCategoryResults(_ values: NSSet)

    @objc(removeCategoryResults:)
    @NSManaged public func removeFromCategoryResults(_ values: NSSet)

    // MARK: Generated accessors for questions
    @objc(addQuestionsObject:)
    @NSManaged public func addToQuestions(_ value: Question)

    @objc(removeQuestionsObject:)
    @NSManaged public func removeFromQuestions(_ value: Question)

    @objc(addQuestions:)
    @NSManaged public func addToQuestions(_ values: NSSet)

    @objc(removeQuestions:)
    @NSManaged public func removeFromQuestions(_ values: NSSet)
}

extension Assessment: Identifiable { }

