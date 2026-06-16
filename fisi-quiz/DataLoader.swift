import Foundation

class DataLoader {
    static func loadQuestions(from filename: String = "fragen") -> [Question] {
        guard let url = Bundle.main.url(forResource: filename, withExtension: "json") else {
            print("Fehler: \(filename).json nicht im App-Bundle gefunden.")
            return []
        }

        do {
            let data = try Data(contentsOf: url)
            let decoder = JSONDecoder()
            let questions = try decoder.decode([Question].self, from: data)
            return questions
        } catch {
            print("Fehler beim Parsen der JSON-Datei \(filename).json: \(error)")
            return []
        }
    }
}
