import SwiftUI

struct QuestionSet: Identifiable {
    let id: String
    let title: String
    let subtitle: String
    let filename: String
}

struct ContentView: View {
    @State private var fragen: [Question] = []
    @State private var aktuelleFrageIndex = 0
    @State private var ausgewaehlteAntworten: Set<AnswerOption> = []
    
    @State private var zeigeLoesungsweg = false
    @State private var zeigeHinweis = false
    
    @State private var richtigeAntwortenCount = 0
    @State private var quizBeendet = false
    
    @State private var ausgewaehltesSet: QuestionSet? = nil
    
    // Fehlertraining
    @State private var falschBeantworteteFragen: [Question] = []
    @State private var istFehlertraining = false
    
    private let questionSets = [
        // NEU: Der Zufallsmix-Button als allererstes Element
        QuestionSet(
            id: "random_mix",
            title: "🎲 Zufallsmix (Prüfungssimulation)",
            subtitle: "30 zufällige Fragen aus allen Themen",
            filename: "RANDOM_MIX"
        ),
        QuestionSet(
            id: "wiso_s2020",
            title: "WiSo Sommer 2020",
            subtitle: "Wirtschafts- und Sozialkunde",
            filename: "fragen"
        ),
        QuestionSet(
            id: "ga1_s2020_rechnen",
            title: "GA1 Sommer 2020 - Rechnen",
            subtitle: "MTU, IPv6, RAID, Backup, Übertragungsdauer",
            filename: "fragen_ga1_s2020_rechnen"
        ),
        QuestionSet(
            id: "ga1_s2020_netzwerk",
            title: "GA1 Sommer 2020 - Netzwerk",
            subtitle: "Gateway, DNS, Routing, DMZ, IPv4, IPv6, WLAN",
            filename: "fragen_ga1_s2020_netzwerk"
        ),
        QuestionSet(
            id: "ga1_s2020_cloud_storage",
            title: "GA1 Sommer 2020 - Cloud & Storage",
            subtitle: "Cloud, SaaS/PaaS/IaaS, CIA, RAID, Backup",
            filename: "fragen_ga1_s2020_cloud_storage"
        ),
        QuestionSet(
            id: "ga1_s2020_scripting_systemverwaltung",
            title: "GA1 Sommer 2020 - Scripting & Systemverwaltung",
            subtitle: "PowerShell, E-Mail, GUI, XCOPY, Rechte, Cluster",
            filename: "fragen_ga1_s2020_scripting_systemverwaltung"
        ),
        QuestionSet(
            id: "ap2_w2025_systeme_datenbank",
            title: "AP2 Winter 2025/26 - Systeme & Datenbank",
            subtitle: "Server, Hardware, BIOS/UEFI, Datenbanken",
            filename: "fragen_ap2_w2025_systeme_datenbank"
        ),
        QuestionSet(
            id: "ap2_w2025_programmierung_backup",
            title: "AP2 Winter 2025/26 - Programmierung & Backup",
            subtitle: "Arrays, Tests, RAID, Backup, Archivierung",
            filename: "fragen_ap2_w2025_programmierung_backup"
        ),
        QuestionSet(
            id: "ap2_w2025_netzwerk_ipv6",
            title: "AP2 Winter 2025/26 - IPv6 & Provider",
            subtitle: "DS-Lite, CGN, Portmapper, VPN",
            filename: "fragen_ap2_w2025_netzwerk_ipv6"
        ),
        QuestionSet(
            id: "ap2_w2025_netzwerk_switching",
            title: "AP2 Winter 2025/26 - Switching",
            subtitle: "Broadcast-Storms, STP, Netzwerkperformance",
            filename: "fragen_ap2_w2025_netzwerk_switching"
        ),
        QuestionSet(
            id: "ap2_w2025_netzwerk_glasfaser",
            title: "AP2 Winter 2025/26 - Glasfaser",
            subtitle: "SFP-Module, Wellenlängen, TX/RX, Fehleranalyse",
            filename: "fragen_ap2_w2025_netzwerk_glasfaser"
        )
    ]
    
    var body: some View {
        NavigationStack {
            VStack {
                if ausgewaehltesSet == nil {
                    auswahlBildschirm
                } else if fragen.isEmpty {
                    ProgressView("Lade Fragen...")
                } else if quizBeendet {
                    ergebnisBildschirm
                } else {
                    let aktuelleFrage = fragen[aktuelleFrageIndex]
                    
                    ScrollView {
                        VStack(alignment: .leading, spacing: 20) {
                            
                            HStack {
                                Text(aktuelleFrage.kategorie)
                                    .font(.subheadline)
                                    .fontWeight(.bold)
                                    .foregroundColor(.blue)
                                    .textCase(.uppercase)
                                
                                Spacer()
                                
                                Text("Frage \(aktuelleFrageIndex + 1) / \(fragen.count)")
                                    .font(.subheadline)
                                    .foregroundColor(.secondary)
                            }
                            
                            HStack {
                                Spacer()
                                
                                Text(aktuelleFrage.typ == "multiple-choice" ? "Mehrere Antworten möglich" : "1 Antwort")
                                    .font(.caption)
                                    .fontWeight(.bold)
                                    .padding(.horizontal, 10)
                                    .padding(.vertical, 5)
                                    .background(aktuelleFrage.typ == "multiple-choice" ? Color.purple.opacity(0.2) : Color.blue.opacity(0.2))
                                    .foregroundColor(aktuelleFrage.typ == "multiple-choice" ? .purple : .blue)
                                    .cornerRadius(8)
                            }
                            
                            Text(aktuelleFrage.frage)
                                .font(.title2)
                                .fontWeight(.semibold)
                            
                            if !aktuelleFrage.hinweis.isEmpty {
                                Button(action: {
                                    withAnimation {
                                        zeigeHinweis.toggle()
                                    }
                                }) {
                                    HStack {
                                        Image(systemName: zeigeHinweis ? "lightbulb.fill" : "lightbulb")
                                        Text(zeigeHinweis ? "Hinweis ausblenden" : "Tipp anzeigen")
                                    }
                                    .foregroundColor(.orange)
                                    .font(.subheadline)
                                }
                                
                                if zeigeHinweis {
                                    Text(aktuelleFrage.hinweis)
                                        .font(.callout)
                                        .italic()
                                        .padding()
                                        .frame(maxWidth: .infinity, alignment: .leading)
                                        .background(Color.orange.opacity(0.1))
                                        .cornerRadius(10)
                                }
                            }
                            
                            Divider()
                            
                            ForEach(aktuelleFrage.antwortOptionen, id: \.self) { option in
                                Button(action: {
                                    if !zeigeLoesungsweg {
                                        if aktuelleFrage.typ == "single-choice" {
                                            ausgewaehlteAntworten = [option]
                                        } else {
                                            if ausgewaehlteAntworten.contains(option) {
                                                ausgewaehlteAntworten.remove(option)
                                            } else {
                                                ausgewaehlteAntworten.insert(option)
                                            }
                                        }
                                    }
                                }) {
                                    VStack(alignment: .leading, spacing: 8) {
                                        HStack {
                                            Image(
                                                systemName: ausgewaehlteAntworten.contains(option)
                                                ? (aktuelleFrage.typ == "single-choice" ? "largecircle.fill.circle" : "checkmark.square.fill")
                                                : (aktuelleFrage.typ == "single-choice" ? "circle" : "square")
                                            )
                                            .foregroundColor(ausgewaehlteAntworten.contains(option) ? .blue : .gray)
                                            .font(.title3)
                                            
                                            Text(option.text)
                                                .multilineTextAlignment(.leading)
                                                .foregroundColor(.primary)
                                            
                                            Spacer()
                                            
                                            if zeigeLoesungsweg {
                                                if option.istKorrekt {
                                                    Image(systemName: "checkmark.circle.fill")
                                                        .foregroundColor(.green)
                                                } else if ausgewaehlteAntworten.contains(option) && !option.istKorrekt {
                                                    Image(systemName: "xmark.circle.fill")
                                                        .foregroundColor(.red)
                                                }
                                            }
                                        }
                                        
                                        if zeigeLoesungsweg && (ausgewaehlteAntworten.contains(option) || option.istKorrekt) {
                                            Text(option.loesungsweg)
                                                .font(.footnote)
                                                .foregroundColor(.secondary)
                                                .padding(.top, 4)
                                                .padding(.leading, 32)
                                        }
                                    }
                                    .padding()
                                    .background(hintergrundFarbe(fuer: option))
                                    .cornerRadius(12)
                                    .overlay(
                                        RoundedRectangle(cornerRadius: 12)
                                            .stroke(
                                                ausgewaehlteAntworten.contains(option) ? Color.blue : Color.gray.opacity(0.3),
                                                lineWidth: ausgewaehlteAntworten.contains(option) && !zeigeLoesungsweg ? 2 : 1
                                            )
                                    )
                                }
                                .buttonStyle(.plain)
                            }
                            
                            if !zeigeLoesungsweg {
                                Button(action: {
                                    withAnimation {
                                        zeigeLoesungsweg = true
                                        auswerten(frage: aktuelleFrage)
                                    }
                                }) {
                                    Text("Antwort auswerten")
                                        .fontWeight(.bold)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(ausgewaehlteAntworten.isEmpty ? Color.gray : Color.blue)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                }
                                .disabled(ausgewaehlteAntworten.isEmpty)
                                .padding(.top, 20)
                            } else {
                                Button(action: naechsteFrage) {
                                    Text(aktuelleFrageIndex < fragen.count - 1 ? "Nächste Frage" : "Ergebnis anzeigen")
                                        .fontWeight(.bold)
                                        .frame(maxWidth: .infinity)
                                        .padding()
                                        .background(Color.green)
                                        .foregroundColor(.white)
                                        .cornerRadius(12)
                                }
                                .padding(.top, 20)
                            }
                        }
                        .padding()
                    }
                }
            }
            .navigationTitle(istFehlertraining ? "Fehlertraining" : (ausgewaehltesSet?.title ?? "FiSi Prüfung"))
            .toolbar {
                if ausgewaehltesSet != nil {
                    Button("Auswahl") {
                        zurueckZumMenue()
                    }
                }
            }
        }
    }
    
    private var auswahlBildschirm: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 20) {
                Text("Wähle ein Fragenset")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                
                Text("Wähle aus, mit welchem Themenbereich du üben möchtest.")
                    .font(.subheadline)
                    .foregroundColor(.secondary)
                
                ForEach(questionSets) { set in
                    Button(action: {
                        starteQuiz(mit: set)
                    }) {
                        VStack(alignment: .leading, spacing: 8) {
                            Text(set.title)
                                .font(.headline)
                                .foregroundColor(.primary)
                            
                            Text(set.subtitle)
                                .font(.subheadline)
                                .foregroundColor(.secondary)
                        }
                        .padding()
                        .frame(maxWidth: .infinity, alignment: .leading)
                        .background(Color.blue.opacity(0.08))
                        .cornerRadius(12)
                        .overlay(
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.blue.opacity(0.25), lineWidth: 1)
                        )
                    }
                    .buttonStyle(.plain)
                }
            }
            .padding()
            .padding(.bottom, 30)
        }
    }
    
    private var ergebnisBildschirm: some View {
        ScrollView {
            VStack(spacing: 30) {
                Text(istFehlertraining ? "Fehlertraining abgeschlossen!" : "Prüfung abgeschlossen!")
                    .font(.largeTitle)
                    .fontWeight(.bold)
                    .multilineTextAlignment(.center)
                
                let prozent = fragen.isEmpty ? 0 : (Double(richtigeAntwortenCount) / Double(fragen.count)) * 100
                
                ZStack {
                    Circle()
                        .stroke(Color.gray.opacity(0.2), lineWidth: 20)
                    
                    Circle()
                        .trim(from: 0, to: CGFloat(prozent / 100))
                        .stroke(
                            prozent >= 50 ? Color.green : Color.red,
                            style: StrokeStyle(lineWidth: 20, lineCap: .round)
                        )
                        .rotationEffect(.degrees(-90))
                        .animation(.easeOut(duration: 1.0), value: prozent)
                    
                    VStack {
                        Text("\(Int(prozent))%")
                            .font(.system(size: 60, weight: .bold))
                        
                        Text("\(richtigeAntwortenCount) von \(fragen.count) Punkten")
                            .font(.title3)
                            .foregroundColor(.secondary)
                    }
                }
                .frame(width: 250, height: 250)
                .padding()
                
                if prozent >= 50 {
                    Text("Glückwunsch! Du hast bestanden. 🎉")
                        .font(.title2)
                        .foregroundColor(.green)
                        .multilineTextAlignment(.center)
                } else {
                    Text("Da ist noch Luft nach oben. Weiter üben! 💪")
                        .font(.title2)
                        .foregroundColor(.red)
                        .multilineTextAlignment(.center)
                }
                
                if !falschBeantworteteFragen.isEmpty {
                    Button(action: starteFehlertraining) {
                        Text("Falsche Fragen wiederholen (\(falschBeantworteteFragen.count))")
                            .fontWeight(.bold)
                            .frame(maxWidth: .infinity)
                            .padding()
                            .background(Color.orange)
                            .foregroundColor(.white)
                            .cornerRadius(12)
                    }
                    .padding(.horizontal)
                }
                
                Button(action: neustart) {
                    Text(istFehlertraining ? "Fehlertraining nochmal starten" : "Quiz nochmal starten")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.blue)
                        .foregroundColor(.white)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
                
                Button(action: zurueckZumMenue) {
                    Text("Zurück zur Auswahl")
                        .fontWeight(.bold)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.gray.opacity(0.25))
                        .foregroundColor(.primary)
                        .cornerRadius(12)
                }
                .padding(.horizontal)
            }
            .padding()
        }
    }
    
    private func starteQuiz(mit set: QuestionSet) {
        ausgewaehltesSet = set
        
        if set.filename == "RANDOM_MIX" {
            var alleFragenPool: [Question] = []
            
            // Sammelt alle Fragen aus allen verfügbaren JSON-Dateien
            for existingSet in questionSets where existingSet.filename != "RANDOM_MIX" {
                let geladeneFragen = DataLoader.loadQuestions(from: existingSet.filename)
                alleFragenPool.append(contentsOf: geladeneFragen)
            }
            
            // Mischt den gesamten Pool
            alleFragenPool.shuffle()
            
            // Nimmt exakt die ersten 30 Fragen (Prüfungssimulation)
            fragen = Array(alleFragenPool.prefix(30))
            
        } else {
            // Standardverhalten: Lade genau die ausgewählte Datei
            fragen = DataLoader.loadQuestions(from: set.filename)
        }
        
        // Antworten für jede Frage mischen
        for i in 0..<fragen.count {
            fragen[i].antwortOptionen.shuffle()
        }
        
        aktuelleFrageIndex = 0
        richtigeAntwortenCount = 0
        ausgewaehlteAntworten.removeAll()
        zeigeLoesungsweg = false
        zeigeHinweis = false
        quizBeendet = false
        falschBeantworteteFragen = []
        istFehlertraining = false
    }
    
    private func starteFehlertraining() {
        var trainingFragen = falschBeantworteteFragen
        
        withAnimation {
            for i in 0..<trainingFragen.count {
                trainingFragen[i].antwortOptionen.shuffle()
            }
            
            fragen = trainingFragen
            falschBeantworteteFragen = []
            
            aktuelleFrageIndex = 0
            richtigeAntwortenCount = 0
            ausgewaehlteAntworten.removeAll()
            zeigeLoesungsweg = false
            zeigeHinweis = false
            quizBeendet = false
            istFehlertraining = true
        }
    }
    
    private func auswerten(frage: Question) {
        let korrekteOptionen = Set(frage.antwortOptionen.filter { $0.istKorrekt })
        
        if ausgewaehlteAntworten == korrekteOptionen {
            richtigeAntwortenCount += 1
        } else {
            if !falschBeantworteteFragen.contains(where: { $0.id == frage.id }) {
                falschBeantworteteFragen.append(frage)
            }
        }
    }
    
    private func hintergrundFarbe(fuer option: AnswerOption) -> Color {
        if zeigeLoesungsweg {
            if option.istKorrekt {
                return Color.green.opacity(0.15)
            } else if ausgewaehlteAntworten.contains(option) {
                return Color.red.opacity(0.15)
            }
        } else if ausgewaehlteAntworten.contains(option) {
            return Color.blue.opacity(0.05)
        }
        
        return Color.clear
    }
    
    private func naechsteFrage() {
        withAnimation {
            if aktuelleFrageIndex < fragen.count - 1 {
                aktuelleFrageIndex += 1
                ausgewaehlteAntworten.removeAll()
                zeigeLoesungsweg = false
                zeigeHinweis = false
            } else {
                quizBeendet = true
            }
        }
    }
    
    private func neustart() {
        if let aktuellesSet = ausgewaehltesSet, aktuellesSet.filename == "RANDOM_MIX" && !istFehlertraining {
            starteQuiz(mit: aktuellesSet)
            return
        }
        
        withAnimation {
            for i in 0..<fragen.count {
                fragen[i].antwortOptionen.shuffle()
            }
            
            aktuelleFrageIndex = 0
            richtigeAntwortenCount = 0
            ausgewaehlteAntworten.removeAll()
            zeigeLoesungsweg = false
            zeigeHinweis = false
            quizBeendet = false
            falschBeantworteteFragen = []
        }
    }
    
    private func zurueckZumMenue() {
        withAnimation {
            ausgewaehltesSet = nil
            fragen = []
            aktuelleFrageIndex = 0
            richtigeAntwortenCount = 0
            ausgewaehlteAntworten.removeAll()
            zeigeLoesungsweg = false
            zeigeHinweis = false
            quizBeendet = false
            falschBeantworteteFragen = []
            istFehlertraining = false
        }
    }
}

#Preview {
    ContentView()
}
