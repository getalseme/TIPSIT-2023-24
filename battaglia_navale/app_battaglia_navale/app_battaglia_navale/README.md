## Classe Principale:

### `ClientGame`

- **Descrizione**: Rappresenta il client del gioco. Gestisce la connessione al server e la comunicazione dei dati tra l'applicazione e il server tramite socket. Contiene le logiche di gioco e i metodi per manipolare i dati di gioco.

- **Attributi Principali**:
  - `socket`: Socket utilizzato per la connessione al server.
  - `_landOp`: Rappresenta la mappa del campo di gioco dell'avversario.
  - `_land`: Rappresenta la mappa del proprio campo di gioco.
  - `_ready`: Indica se il client è pronto per iniziare la partita.
  - `_playing`: Indica se il client è attualmente coinvolto in una partita.
  - `_isTurn`: Indica se è il turno del giocatore.
  - `_finish`: Indica se la partita è finita.
  - `_win`: Indica se il giocatore ha vinto la partita.
  - `serverResponce`: Lista di messaggi ricevuti dal server.

- **Metodi Principali**:
  - `getLand()`: Restituisce la mappa del campo di gioco del giocatore.
  - `getLandOp()`: Restituisce la mappa del campo di gioco dell'avversario.
  - `writeToServer(String message)`: Invia messaggi al server.
  - `startConnection()`: Avvia la connessione al server.
  - `errorHandler(error, StackTrace trace)`: Gestisce gli errori durante la connessione.
  - `doneHandler()`: Gestisce la chiusura della connessione quando il client termina.
  - `dataHandler(data)`: Gestisce i messaggi ricevuti dal server e aggiorna lo stato del gioco.

## Classe `MyApp`:

### `MyApp`

- **Descrizione**: Widget principale dell'app Flutter. Definisce il tema e la struttura dell'applicazione.

- **Metodi Principali**:
  - `build(BuildContext context)`: Costruisce la struttura dell'app con il tema e il widget `BattleshipGame` come home.

## Classe `BattleshipGame`:

### `BattleshipGame` (StatefulWidget)

- **Descrizione**: Rappresenta il gioco della battaglia navale nell'interfaccia utente. Contiene la logica per gestire la disposizione delle navi e visualizza la griglia di gioco.

- **Attributi Principali**:
  - `ships`: Lista delle dimensioni delle navi disponibili.
  - `selectedShip`: Indice della nave selezionata.
  - `selectedOrientation`: Orientazione selezionata per la nave (orizzontale o verticale).
  - `currentGrid`: Indica la griglia attualmente visualizzata (1 o 2).
  - `_timer`: Timer periodico per l'aggiornamento della griglia.
  - `grid1`, `grid2`: Matrici che rappresentano i campi di gioco del giocatore e dell'avversario.

- **Metodi Principali**:
  - `initState()`: Inizializza lo stato del widget.
  - `dispose()`: Pulisce le risorse quando il widget viene rimosso.
  - `switchGrid()`: Cambia la visualizzazione tra la propria griglia e quella dell'avversario.
  - `updateAllGrids(Timer timer)`: Aggiorna entrambe le griglie con nuovi dati.
  - `cellSelected(int row, int col)`: Gestisce la selezione di una cella sulla griglia.
  - `selectOrientation(String orientation)`: Imposta l'orientazione selezionata per posizionare le navi.
  - `buildInitialSetup()`: Costruisce l'interfaccia iniziale per la disposizione delle navi.
  - `build(BuildContext context)`: Costruisce l'interfaccia dell'app basata sullo stato attuale del gioco e della griglia. Mostra le griglie, i messaggi e i popup in base allo stato della partita.

## Classe `Land`:

### `Land`

- **Descrizione**: Rappresenta la matrice del campo di gioco, sia per il campo del giocatore che per quello dell'avversario. Gestisce la creazione, l'inizializzazione e la manipolazione della matrice.

- **Attributi Principali**:
  - `_matrix`: Matrice 10x10 che rappresenta il campo di gioco, inizializzata con spazi vuoti.

- **Metodi Principali**:
  - `Land()`: Costruttore della classe che inizializza la matrice del campo di gioco.
  - `initialize_matrix()`: Inizializza la matrice con spazi vuoti.
  - `getMatrix()`: Restituisce la matrice `_matrix`.
  - `setPoint(int x, int y, String value)`: Imposta il valore specificato nella posizione (x, y) della matrice.
  - `messageToGrid(String msg)`: Converte un messaggio ricevuto dal server in una rappresentazione della griglia di gioco nella matrice `_matrix`, assegnando i valori corrispondenti alle posizioni della matrice in base al messaggio ricevuto.

La classe `Land` svolge un ruolo fondamentale nella gestione della rappresentazione del campo di gioco, consentendo la manipolazione della matrice per visualizzare e modificare la disposizione delle navi e gli eventi di gioco.