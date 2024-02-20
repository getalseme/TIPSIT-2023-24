# README - Progetto Scolastico

## Descrizione

Questo progetto è stato realizzato come parte di un corso scolastico per dimostrare la comprensione e l'applicazione dei concetti di programmazione Flutter e della gestione di un database SQLite utilizzando la libreria Floor. L'applicazione sviluppata è un semplice gestore di post e commenti che consente agli utenti di creare, visualizzare e interagire con i post e i relativi commenti.

## Funzionamento dell'App

L'applicazione si avvia con una schermata principale che mostra un elenco di post, ognuno con il suo titolo e testo. Gli utenti possono aggiungere nuovi post tramite un pulsante "Aggiungi" nella parte inferiore dello schermo. Cliccando su un post, gli utenti possono visualizzare i relativi commenti e aggiungerne di nuovi.

### Componenti Principali

- **Schermata Principale (`MyHomePage`)**: Questa schermata mostra tutti i post presenti nel database. Ogni post è rappresentato da un widget `Card` contenente il titolo e il testo del post. Gli utenti possono toccare un post per visualizzare i relativi commenti o aggiungere un nuovo commento.
  
- **Finestra di Dialogo per l'Aggiunta di Post (`AddPostForm`)**: Quando gli utenti desiderano aggiungere un nuovo post, viene visualizzata una finestra di dialogo in cui possono inserire il titolo e il testo del nuovo post.

- **Finestra di Dialogo per l'Aggiunta di Commenti (`AddCommentForm`)**: Quando gli utenti toccano un post per visualizzare i commenti o desiderano aggiungere un nuovo commento, viene visualizzata una finestra di dialogo in cui possono inserire il testo del nuovo commento.

## Riferimenti al Codice

- **`main.dart`**: Il file principale dell'applicazione che gestisce l'inizializzazione e il routing dell'applicazione. È qui che viene configurato il database e viene costruita l'interfaccia utente principale.
  
- **`database.dart`**: Questo file definisce la configurazione del database SQLite utilizzando la libreria Floor. Contiene le definizioni delle entità (tabelle) del database e dei DAO (Data Access Objects) per l'accesso e la gestione dei dati nel database.

- **`models.dart`**: Questo file contiene le definizioni dei modelli di dati `Post` e `Comment` utilizzati nell'applicazione. Ogni modello corrisponde a una tabella nel database e viene utilizzato per rappresentare e manipolare i dati.
