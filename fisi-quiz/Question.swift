import Foundation

struct Question: Codable, Identifiable {
    let id: String
    let kategorie: String
    let frage: String
    let typ: String
    let hinweis: String
    var antwortOptionen: [AnswerOption]
}

struct AnswerOption: Codable, Hashable {
    let text: String
    let istKorrekt: Bool
    let loesungsweg: String
}
