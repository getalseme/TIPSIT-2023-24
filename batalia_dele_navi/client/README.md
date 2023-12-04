## Classe Principale:

### `TestualClient`

- **Descrizione**: Rappresenta un client testuale per il gioco della battaglia navale. Si connette al server e gestisce l'interazione tra il giocatore e il server tramite input/output testuali sulla console.

- **Attributi Principali**:
  - `_ready`: Indica se il client è pronto per giocare.
  - `_playing`: Indica se il client è attualmente coinvolto in una partita.

- **Metodi Principali**:
  - `start()`: Avvia la connessione con il server.
  - `startConnection()`: Avvia la connessione del client al server e gestisce la comunicazione attraverso i socket.
  - `dataHandler(data)`: Gestisce i messaggi ricevuti dal server, interpretando e stampando informazioni relative allo stato di gioco.
  - `errorHandler(error, StackTrace trace)`: Gestisce gli errori durante la connessione.
  - `doneHandler()`: Gestisce la chiusura della connessione quando il client termina.

I metodi `startConnection()`, `dataHandler(data)`, `errorHandler(error, StackTrace trace)`, e `doneHandler()` si occupano rispettivamente di stabilire la connessione al server, gestire i dati in ingresso e in uscita, gestire gli errori e terminare la connessione quando necessario.

Il metodo `dataHandler(data)` è responsabile della gestione dei messaggi ricevuti dal server, interpretando i vari tipi di messaggi e stampandoli sulla console del client per informare l'utente dello stato del gioco e delle azioni che possono essere eseguite.

Questo client testuale si concentra sulla gestione dell'interazione tra l'utente e il server attraverso messaggi testuali, rendendo l'esperienza di gioco più comprensibile e interattiva per l'utente.