import Foundation
import CoreData

extension Question {
    @nonobjc public class func fetchRequest() -> NSFetchRequest<Question> {
        return NSFetchRequest<Question>(entityName: "Question")
    }

    @NSManaged public var id: UUID?
    @NSManaged public var points: Int32
    @NSManaged public var questionText: String?
    @NSManaged public var selectedOption: String?
    @NSManaged public var answerOption3: String?
    @NSManaged public var answerOption2: String?
    @NSManaged public var answerOption1: String?
    @NSManaged public var answerOption0: String?
    @NSManaged public var categoryResult: CategoryResult?
    @NSManaged public var order: Int32
    @NSManaged public var assessment: Assessment?
}

extension Question: Identifiable { }
