# Battaglia Navale - Descrizione dei File

## 1. **server.dart**

- **Descrizione**: Un server socket per gestire giocatori di Battaglia Navale.
- **Funzionalità Principali**:
  - Gestisce la connessione dei giocatori.
  - Effettua il matchmaking tra giocatori.
  - Gestisce lo svolgimento del gioco di Battaglia Navale.

## 2. **client.dart**

- **Descrizione**: Un client per giocare a Battaglia Navale in modalità testuale.
- **Funzionalità Principali**:
  - Gestisce la connessione al server.
  - Interagisce con il server per giocare a Battaglia Navale.
  - Visualizza le informazioni ricevute dal server durante il gioco.

## 3. **main.dart**

- **Descrizione**: Un'app Flutter per giocare a Battaglia Navale.
- **Funzionalità Principali**:
  - Interfaccia utente per la disposizione delle navi.
  - Gestione del gioco sulla griglia.
  - Visualizzazione delle griglie di gioco e aggiornamenti durante le mosse.

## 4. **land.dart**

- **Descrizione**: Una classe per gestire la rappresentazione della griglia di gioco.
- **Funzionalità Principali**:
  - Creazione e gestione della matrice per il campo di gioco.
  - Conversione dei messaggi del server in rappresentazione della griglia di gioco.