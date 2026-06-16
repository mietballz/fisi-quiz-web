// --- Konfiguration und State ---
const alleJsonFiles = [
    'fragen.json', 
    'fragen_ga1_s2020_rechnen.json', 
    'fragen_ga1_s2020_netzwerk.json',
    'fragen_ga1_s2020_cloud_storage.json', 
    'fragen_ga1_s2020_scripting_systemverwaltung.json',
    'fragen_ap2_w2025_systeme_datenbank.json', 
    'fragen_ap2_w2025_programmierung_backup.json',
    'fragen_ap2_w2025_nat_vpn.json',
    'fragen_ap2_w2025_vlan_switching.json',
    'fragen_ap2_w2025_berechnungen_troubleshooting.json'
];

let fragen = [];
let aktuelleFrageIndex = 0;
let ausgewaehlteAntworten = []; 
let zeigeLoesungsweg = false;
let zeigeHinweisAktuell = false;
let richtigeAntwortenCount = 0;

// --- Modus starten (Zufallsmix oder Einzel-Set) ---
async function starteModus(modus) {
    fragen = [];
    richtigeAntwortenCount = 0;
    aktuelleFrageIndex = 0;

    if (modus === 'RANDOM') {
        let alleFragenPool = [];
        for (const file of alleJsonFiles) {
            try {
                const response = await fetch(file);
                const data = await response.json();
                alleFragenPool.push(...data);
            } catch (e) {
                console.error("Fehler beim Laden von " + file, e);
            }
        }
        alleFragenPool.sort(() => Math.random() - 0.5);
        fragen = alleFragenPool.slice(0, 30);
    } else {
        try {
            const response = await fetch(modus);
            fragen = await response.json();
        } catch (e) {
            alert("Fehler beim Laden des Fragensets!");
            return;
        }
    }

    // Antworten mischen
    fragen.forEach(f => {
        if (f.antwortOptionen) {
            f.antwortOptionen.sort(() => Math.random() - 0.5);
        }
    });

    document.getElementById('menu-view').style.display = 'none';
    document.getElementById('quiz-card').style.display = 'block';
    
    zeigeFrage();
}

// --- Eine Frage anzeigen ---
function zeigeFrage() {
    const aktuelleFrage = fragen[aktuelleFrageIndex];
    zeigeHinweisAktuell = false;
    zeigeLoesungsweg = false;
    ausgewaehlteAntworten = [];

    document.getElementById('fortschritt').innerText = `Frage ${aktuelleFrageIndex + 1} / ${fragen.length}`;
    document.getElementById('kategorie').innerText = aktuelleFrage.kategorie;
    document.getElementById('frage-text').innerText = aktuelleFrage.frage;

    // Typ-Badge (mit Failsafe)
    const badgeContainer = document.getElementById('typ-badge-container');
    const badge = document.getElementById('typ-badge');
    if (badgeContainer && badge) {
        badgeContainer.style.display = 'block';
        if (aktuelleFrage.typ === 'multiple-choice') {
            badge.innerText = 'Mehrere Antworten möglich';
            badge.className = 'badge multiple-choice';
        } else {
            badge.innerText = '1 Antwort';
            badge.className = 'badge single-choice';
        }
    }

    // Hinweis-Box (mit Failsafe)
    const hinweisContainer = document.getElementById('hinweis-container');
    if (hinweisContainer) {
        const hinweisBox = document.getElementById('hinweis-box');
        const hinweisBtn = document.getElementById('hinweis-btn');
        
        if (aktuelleFrage.hinweis && aktuelleFrage.hinweis.trim() !== "") {
            hinweisContainer.style.display = 'block';
            hinweisBox.style.display = 'none';
            hinweisBtn.innerText = '💡 Tipp anzeigen';
            document.getElementById('hinweis-text').innerText = aktuelleFrage.hinweis;
        } else {
            hinweisContainer.style.display = 'none';
        }
    }

    // Antworten rendern
    const antwortenBox = document.getElementById('antworten-box');
    antwortenBox.innerHTML = '';

    aktuelleFrage.antwortOptionen.forEach((option, index) => {
        const optDiv = document.createElement('div');
        optDiv.className = 'antwort-option';
        optDiv.id = `option-${index}`;
        
        const icon = aktuelleFrage.typ === 'single-choice' ? '○' : '❑';

        optDiv.innerHTML = `
            <div class="option-content">
                <span class="option-icon">${icon}</span>
                <span class="option-text">${option.text}</span>
                <span class="feedback-icon"></span>
            </div>
            <div class="loesungsweg-box" style="display: none;">${option.loesungsweg}</div>
        `;

        optDiv.onclick = () => waehleAntwort(index);
        antwortenBox.appendChild(optDiv);
    });

    const actionBtn = document.getElementById('action-btn');
    actionBtn.innerText = "Antwort auswerten";
    actionBtn.disabled = true;
    actionBtn.onclick = auswerten;
}

// --- Klick-Logik ---
function waehleAntwort(index) {
    if (zeigeLoesungsweg) return; 

    const aktuelleFrage = fragen[aktuelleFrageIndex];
    const optDiv = document.getElementById(`option-${index}`);

    if (aktuelleFrage.typ === 'single-choice') {
        aktuelleFrage.antwortOptionen.forEach((_, i) => {
            document.getElementById(`option-${i}`).classList.remove('selected');
            document.getElementById(`option-${i}`).querySelector('.option-icon').innerText = '○';
        });
        ausgewaehlteAntworten = [index];
        optDiv.classList.add('selected');
        optDiv.querySelector('.option-icon').innerText = '●';
    } else {
        if (ausgewaehlteAntworten.includes(index)) {
            ausgewaehlteAntworten = ausgewaehlteAntworten.filter(i => i !== index);
            optDiv.classList.remove('selected');
            optDiv.querySelector('.option-icon').innerText = '❑';
        } else {
            ausgewaehlteAntworten.push(index);
            optDiv.classList.add('selected');
            optDiv.querySelector('.option-icon').innerText = '☑';
        }
    }

    document.getElementById('action-btn').disabled = ausgewaehlteAntworten.length === 0;
}

// --- Auswertung ---
function auswerten() {
    zeigeLoesungsweg = true;
    const aktuelleFrage = fragen[aktuelleFrageIndex];
    let alleKorrekt = true;

    aktuelleFrage.antwortOptionen.forEach((option, index) => {
        const optDiv = document.getElementById(`option-${index}`);
        const feedbackIcon = optDiv.querySelector('.feedback-icon');
        const loesungswegBox = optDiv.querySelector('.loesungsweg-box');
        const wurdeGewaehlt = ausgewaehlteAntworten.includes(index);

        if (option.istKorrekt) {
            optDiv.classList.add('correct');
            feedbackIcon.innerText = '🟢';
            if (wurdeGewaehlt || (option.loesungsweg && option.loesungsweg.trim() !== "")) {
                loesungswegBox.style.display = 'block'; 
            }
        } else if (wurdeGewaehlt && !option.istKorrekt) {
            optDiv.classList.add('wrong');
            feedbackIcon.innerText = '🔴';
            loesungswegBox.style.display = 'block';
            alleKorrekt = false;
        }

        if (option.istKorrekt && !wurdeGewaehlt) {
            alleKorrekt = false;
        }
    });

    if (alleKorrekt) {
        richtigeAntwortenCount++;
    }

    const actionBtn = document.getElementById('action-btn');
    if (aktuelleFrageIndex < fragen.length - 1) {
        actionBtn.innerText = "Nächste Frage";
        actionBtn.onclick = naechsteFrage;
    } else {
        actionBtn.innerText = "Ergebnis anzeigen";
        actionBtn.onclick = zeigeErgebnis;
    }
}

// --- Navigation ---
function naechsteFrage() {
    aktuelleFrageIndex++;
    zeigeFrage();
}

function toggleHinweis() {
    const hinweisBox = document.getElementById('hinweis-box');
    const hinweisBtn = document.getElementById('hinweis-btn');
    zeigeHinweisAktuell = !zeigeHinweisAktuell;

    if (zeigeHinweisAktuell) {
        hinweisBox.style.display = 'block';
        hinweisBtn.innerText = '🙈 Hinweis ausblenden';
    } else {
        hinweisBox.style.display = 'none';
        hinweisBtn.innerText = '💡 Tipp anzeigen';
    }
}

function zurueckZumMenue() {
    document.getElementById('quiz-card').style.display = 'none';
    document.getElementById('menu-view').style.display = 'block';
}

function zeigeErgebnis() {
    const prozent = Math.round((richtigeAntwortenCount / fragen.length) * 100);
    let feedbackText = prozent >= 50 ? "Glückwunsch! Du hast bestanden. 🎉" : "Da ist noch Luft nach oben. Weiter üben! 💪";
    
    const antwortenBox = document.getElementById('antworten-box');
    antwortenBox.innerHTML = `
        <div style="text-align: center; margin: 30px 0;">
            <h3 style="font-size: 2.5rem; margin-bottom: 10px;">${prozent}%</h3>
            <p style="color: #666; font-size: 1.2rem;">${richtigeAntwortenCount} von ${fragen.length} Punkten erreicht</p>
            <h4 style="margin-top: 20px; color: ${prozent >= 50 ? '#34c759' : '#ff3b30'}">${feedbackText}</h4>
        </div>
    `;

    document.getElementById('kategorie').innerText = "ERGEBNIS";
    document.getElementById('frage-text').innerText = "Prüfung abgeschlossen!";
    
    const badgeContainer = document.getElementById('typ-badge-container');
    const hinweisContainer = document.getElementById('hinweis-container');
    if (badgeContainer) badgeContainer.style.display = 'none';
    if (hinweisContainer) hinweisContainer.style.display = 'none';

    const actionBtn = document.getElementById('action-btn');
    actionBtn.innerText = "Zurück zum Hauptmenü";
    actionBtn.onclick = () => {
        if (badgeContainer) badgeContainer.style.display = 'block';
        zurueckZumMenue();
    };
}