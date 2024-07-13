# Progetto Assembly RISC-V: Valutatore di Espressioni

## Informazioni
- **Autore:** Lorenzo Yang
- **Indirizzo e-mail:** lorenzo.yang@edu.unifi.it
- **Matricola:** 7136074
- **Data di consegna:** ...TODO...
- **Versione RIPES usata:** 2.2.6


## Descrizione del progetto

Il progetto si basa principalmente su due funzioni, *Eval* e *Evaluate*. La funzione Eval prende in input l'indirizzo della stringa contenente l'espressione da valutare e restituisce il risultato di tale espressione, la funzione Eval non dipende quindi da alcuna variabile globale, quindi se si modifica il nome della variabile che contiene l'espressione, la funzione continuerà a funzionare. Tuttavia, *Eval* non valuta direttamente l'espressione ma chiama la funzione **Evaluate (ricorsiva)**. *Eval* prepara gli argomenti per *Evaluate* e gestisce eventuali errori di parentesi dopo la chiamata di *Evaluate*.

*Evaluate* è la funzione (ricorsiva) che effettivamente valuta l'espressione. Utilizza tre "variabili" locali `left`, `op`, `right`. la logica della funzione è la seguente: un'espressione aritmetica è considerata composta da tre componenti, un operando (`left`), un operatore (`op`) e un altro operando (`right`). Per valutarla, è necessario effettuare tre letture dall'espressione: una dell'operando (se non è un operando si genera un errore), una dell'operatore (se non è un operatore si genera un errore), e così via. 

  1. Per prima cosa, si chiama la funzione *ReadOperand* che restituisce il primo carattere letto (ignorando gli spazi bianchi). Se il carattere non è né un numero né una parentesi aperta si genera un errore. In caso di parentesi aperta si effettua una chiamata ricorsiva a *Evaluate*, il cui risultato è considerato come un operando e salvato in `left`: `left = Evaluate(...)`. Se si tratta di un numero, si usa la funzione *String2Int* per convertirlo in un intero, salvandolo in `left`: `left = String2Int(...)`. Dopo ogni chiamata di funzione si controlla se il registro "tipo di errore" è diverso da 0 (0 indica nessun errore), in caso affermativo la funzione viene interrotta.
  2. Successivamente, si legge un operatore con la funzione *ReadOperator*. Se il carattere letto non è un operatore si genera un errore, altrimenti, l'operatore viene salvato in `op`: `op = ReadOperator(...)`.
  3. Si ripete il primo punto per il secondo operando, salvando il risultato in `right`. A seconda dei casi, si chiama *Evaluate* o *String2Int*: `right = Evaluate(...)` oppure `right = String2Int(...)`.

**`left`, `op`, `right` devono essere salvate nella memoria stack prima di chiamare *Evaluate*, e devono essere recuperate dopo la chiamata.** Ad esempio durante la terza fase (punto 3) dopo le prime due fasi, se si richiama Evaluate senza aver salvato `left`, `op` e `right`, al termine della chiamata ricorsiva per valutare la sotto-espressione non sarà possibile recuperare left e op, perdendo così i loro valori e impedendo di effettuare l'operazione aritmetica finale.

  1. Prima di effettuare l'operazione aritmetica finale si controlla se il carattere attuale (indicato dall'indirizzo attuale della stringa) è una parentesi chiusa o il carattere \0 (0) che indica la fine della stringa, in caso contrario si genera un errore. In caso di parentesi chiusa si procede con il controllo delle parentesi e la gestione dell'eventuale errore.
  2. Infine si effettua l'operazione aritmetica tra `left` e `right` in base all'operatore `op`, Il risultato viene salvato in `a0`, e restituito alla funzione chiamante.