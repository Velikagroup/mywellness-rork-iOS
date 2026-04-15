# Rifare la scansione Pantry AI: doppia foto (fronte + retro) + barcode

## Problema attuale
La schermata "Scan with AI" nella Pantry permette di scattare solo **una foto** e non funziona correttamente con l'AI. Il metodo per analizzare due immagini (fronte + retro) esiste già nel codice ma non viene mai utilizzato.

## Cosa cambierà

### **Funzionalità**
- **Due slot fotografici obbligatori**: uno per l'etichetta frontale (nome prodotto, brand, ingredienti) e uno per la tabella nutrizionale sul retro
- **Fotocamera + galleria**: ogni slot può essere riempito scattando una foto o scegliendo dalla galleria
- **Scansione barcode**: un nuovo pulsante per scansionare il codice a barre del prodotto — l'AI riceverà il codice e restituirà le info nutrizionali del prodotto
- **Analisi AI doppia**: le due foto vengono inviate insieme all'AI che legge il nome/brand dalla foto frontale e i valori nutrizionali dalla tabella sul retro
- **Risultati editabili**: dopo l'analisi puoi modificare tutti i valori prima di salvare nella Pantry

### **Design**
- Stessa estetica attuale con gradiente viola/rosa e colori wellness dell'app
- **Step 1 — Cattura foto**: due card affiancate con icone — "Etichetta Frontale" (icona tag) e "Tabella Nutrizionale" (icona chart) — ognuna toccabile per scattare/scegliere foto. Sotto le card, un pulsante secondario "Scansiona Barcode"
- Quando una foto è stata scattata, la card mostra l'anteprima con un badge verde ✓ e un pulsante "Riprendi"
- **Step 2 — Analisi AI**: animazione di caricamento con indicatori "Lettura etichetta…" e "Estrazione valori…"
- **Step 3 — Risultato**: scheda con nome, brand, categoria, porzione e tutti i valori nutrizionali editabili, come già esiste
- Il pulsante "Analizza con AI" si attiva solo quando **entrambe** le foto sono state scattate (o un barcode è stato scansionato)

### **Scansione Barcode**
- Usa la fotocamera del dispositivo per leggere codici a barre (EAN/UPC)
- Il codice a barre viene inviato all'AI che identifica il prodotto e restituisce i valori nutrizionali
- Se il barcode non viene riconosciuto, mostra un messaggio e suggerisce di usare le foto manuali
- Sul simulatore (dove la fotocamera non è disponibile), mostra un placeholder con il messaggio di installare l'app sul dispositivo

### **Schermate**
1. **Intro** — breve spiegazione con 3 step (Foto fronte, Foto retro/Barcode, AI analizza)
2. **Cattura** — due slot foto + pulsante barcode
3. **Analisi** — animazione di caricamento AI
4. **Risultato** — valori editabili + pulsante "Salva nella Pantry"
