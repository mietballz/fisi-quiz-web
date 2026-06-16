const alleJsonFiles = [
    'fragen.json', 'fragen_ga1_s2020_rechnen.json', 'fragen_ga1_s2020_netzwerk.json',
    'fragen_ga1_s2020_cloud_storage.json', 'fragen_ga1_s2020_scripting_systemverwaltung.json',
    'fragen_ap2_w2025_systeme_datenbank.json', 'fragen_ap2_w2025_programmierung_backup.json'
];

let aktuelleFragen = [];
let currentIndex = 0;
let gewaehlteOptionen = new Set();
let richtigeAntwortenCount = 0;
let aktuellerModus = '';

function starteModus(modus) {
    aktuellerModus = modus;
    document.getElementById('menu-view').style.display = 'none';
    document.getElementById('quiz-card').style.display = 'block';
    document.getElementById('frage-text').innerText = "Lade Fragen...";

    if (modus === 'RANDOM') {
        Promise.all(alleJsonFiles.map(file => fetch(file).then(res => res.json())))
            .then(results => {
                let pool = results.flat();
                pool.sort(() => Math.random() - 0.5);
                aktuelleFragen = pool.slice(0, 30);
                startQuiz();
            });
    } else {
        // Lädt nur genau das ausgewählte Set
        fetch(modus)
            .then(res => res.json())
            .then(data => {
                aktuelleFragen = data;
                startQuiz();
            });
    }
}

function startQuiz() {
    currentIndex = 0;
    richtigeAntwortenCount = 0;
    // Antworten einmal mischen
    aktuelleFragen.forEach(f => {
        f.antwortOptionen.sort(() => Math.random() - 0.5);
    });
    zeigeFrage();
}

function zurueckZumMenue() {
    document.getElementById('quiz-card').style.display = 'none';
    document.getElementById('menu-view').style.display = 'block';
}

function zeigeFrage() {
    let frage = aktuelleFragen[currentIndex];
    document.getElementById('kategorie').innerText = frage.kategorie;
    document.getElementById('fortschritt').innerText = `Frage ${currentIndex + 1} / ${aktuelleFragen.length}`;
    document.getElementById('frage-text').innerText = frage.frage;
    
    let box = document.getElementById('antworten-box');
    box.innerHTML = '';
    gewaehlteOptionen.clear();
    
    let btn = document.getElementById('action-btn');
    btn.disabled = true;
    btn.innerText = "Antwort auswerten";
    btn.onclick = auswerten;

    frage.antwortOptionen.forEach(opt => {
        let optDiv = document.createElement('div');
        
        let optBtn = document.createElement('button');
        optBtn.className = 'option-btn';
        optBtn.innerText = opt.text;
        
        let loesung = document.createElement('div');
        loesung.className = 'loesungsweg';
        loesung.innerText = opt.loesungsweg;

        optBtn.onclick = () => {
            if (frage.typ === "single-choice") {
                document.querySelectorAll('.option-btn').forEach(b => b.classList.remove('selected'));
                gewaehlteOptionen.clear();
            }
            optBtn.classList.toggle('selected');
            
            if(optBtn.classList.contains('selected')) gewaehlteOptionen.add(opt);
            else gewaehlteOptionen.delete(opt);
            
            btn.disabled = gewaehlteOptionen.size === 0;
        };

        optDiv.appendChild(optBtn);
        optDiv.appendChild(loesung);
        box.appendChild(optDiv);
    });
}

function auswerten() {
    let frage = aktuelleFragen[currentIndex];
    let korrekteOptionen = frage.antwortOptionen.filter(o => o.istKorrekt);
    
    let istRichtig = true;
    if (gewaehlteOptionen.size !== korrekteOptionen.length) istRichtig = false;

    document.querySelectorAll('.option-btn').forEach(btn => {
        btn.disabled = true;
        let originalOpt = frage.antwortOptionen.find(o => o.text === btn.innerText);
        
        if (originalOpt.istKorrekt) btn.classList.add('correct');
        else if (btn.classList.contains('selected')) { btn.classList.add('wrong'); istRichtig = false; }
        
        if (btn.classList.contains('selected') || originalOpt.istKorrekt) btn.nextElementSibling.style.display = 'block';
    });

    if (istRichtig) richtigeAntwortenCount++;

    let actionBtn = document.getElementById('action-btn');
    actionBtn.innerText = currentIndex < aktuelleFragen.length - 1 ? "Nächste Frage" : "Ergebnis anzeigen";
    actionBtn.onclick = naechsteFrage;
}

function naechsteFrage() {
    currentIndex++;
    if (currentIndex < aktuelleFragen.length) {
        zeigeFrage();
    } else {
        let prozent = Math.round((richtigeAntwortenCount / aktuelleFragen.length) * 100);
        document.getElementById('quiz-card').innerHTML = `
            <div style="text-align:center;">
                <h2>Prüfung beendet!</h2>
                <h1 style="color: ${prozent >= 50 ? '#28a745' : '#dc3545'}; font-size: 48px;">${prozent}%</h1>
                <p>${richtigeAntwortenCount} von ${aktuelleFragen.length} richtig beantwortet.</p>
                <button class="menu-btn random-btn" onclick="starteModus(aktuellerModus)" style="margin-top:20px;">Quiz wiederholen</button>
                <button class="menu-btn" onclick="location.reload()" style="margin-top:10px;">Zurück zum Menü</button>
            </div>
        `;
    }
}