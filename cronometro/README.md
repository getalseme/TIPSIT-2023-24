# Cronometro App in Dart

Ho creato un'applicazione di cronometro utilizzando il framework Flutter in Dart. Questa app consente agli utenti di avviare, fermare e ripristinare un timer in centesimi di secondo.

## Struttura del Codice

Il codice è diviso in diverse classi per una migliore organizzazione e leggibilità.

### 1. **MyApp**

La classe `MyApp` è la radice dell'app. Definisce il tema generale dell'applicazione e specifica che la schermata principale è `MyHomePage`.

### 2. **TimerBloc**

La classe `TimerBloc` è responsabile della gestione del timer. Utilizza uno stream per inviare i dati del cronometro alla UI e un oggetto `Timer` per contare i centesimi di secondo.

- **Metodi:**
  - `startTimer()`: Avvia il timer.
  - `stopTimer()`: Ferma il timer.
  - `resetTimer()`: Resetta il timer a 0.
  - `dispose()`: Chiude il controller dello stream e annulla il timer quando non è più necessario.

### 3. **MyHomePage**

La classe `MyHomePage` è uno stato modificabile (StatefulWidget) che mostra l'interfaccia utente del cronometro.

- **Metodi:**
  - `formatTime(int centiseconds)`: Converte i centesimi di secondo in un formato leggibile HH:MM:SS.CS.
  
- **Interfaccia Utente:**
  - Mostra il timer nella parte centrale della schermata.
  - Contiene tre pulsanti: "Avvia", "Ferma" e "Resetta" che interagiscono con il `TimerBloc`.

## Utilizzo dell'App

- L'utente può premere il pulsante "Avvia" per avviare il cronometro. Il timer inizierà a contare i centesimi di secondo.
- Premendo il pulsante "Ferma", l'utente può fermare il cronometro al punto in cui si trova.
- Premendo il pulsante "Resetta", l'utente può riportare il cronometro a 0.
