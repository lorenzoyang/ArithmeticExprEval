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

### Definizioni delle costanti:

Le costanti per la gestione degli errori sono dei valori interi definiti nella memoria RAM (sezione .data) e servono per rappresentare vari tipi di errori che possono verificarsi durante l'esecuzione di un programma, specialmente in operazioni matematiche o nella valutazione di espressioni. Tra queste:
  - syntaxError: Questo errore si verifica quando l'espressione non rispetta le regole di sintassi generali.
  - syntaxErrorOperand: Indica un errore di sintassi dovuto alla presenza di un operatore in una posizione inappropriata. Viene lanciato quando, ad esempio, c'è un operatore all'inizio di un'espressione o subito dopo un altro operatore senza un operando valido.
  - syntaxErrorOperator: Questo errore si riferisce alla presenza di un operando in una posizione non corretta. Può verificarsi se c'è un operando dove ci si aspetta un operatore, ad esempio tra parentesi chiuse senza un operatore in mezzo.
  - divisionByZeroError: Questo errore si verifica quando si tenta di dividere un numero per zero
  - overflowErrorAddition: Si verifica un errore di overflow durante un'operazione di somma, quando il risultato supera la capacità del tipo di dato utilizzato (intero con segno da 32 bit).
  - overflowErrorSubtraction: Questo errore si manifesta durante un'operazione di sottrazione che causa un overflow.
  - overflowErrorMul: Si verifica un overflow durante un'operazione di moltiplicazione.
  - overflowErrorDiv: Un overflow si verifica durante una divisione, ad esempio quando si tenta di dividere il valore più piccolo rappresentabile per -1.
  - overflowErrorString2Int: Si verifica un errore di overflow durante la conversione di una stringa in un intero, quando la stringa rappresenta un numero troppo grande per essere contenuto nel tipo di dato utilizzato.
  - parenthesesError: Questo errore indica che le parentesi in un'espressione non sono bilanciate, cioè c'è una differenza nel numero di parentesi aperte e chiuse.

Le costanti per i messaggi di errore:
  - syntaxErrorMsg
  - syntaxErrorOperandMsg
  - syntaxErrorOperatorMsg
  - divisionByZeroErrorMsg
  - overflowErrorAdditionMsg
  - overflowErrorSubtractionMsg
  - overflowErrorMulMsg
  - overflowErrorDivMsg
  - overflowErrorString2IntMsg
  - parenthesesErrorMsg

Due costanti per definire i valori massimi e minimi rappresentabili da un intero con segno da 32 bit:
  - INT32_MIN
  - INT32_MAX

### Main:

La funzione `Main` ha il compito di preparare gli argomenti necessari per chiamare la funzione `Eval`. Una volta eseguita quest'ultima, l'errore restituito viene gestito tramite uno switch: a seconda del tipo di errore, viene stampato un messaggio di errore adeguato. Se non si verifica alcun errore, viene visualizzato il risultato dell'espressione aritmetica.

### Convenzione di chiamata

Convenzione stabilita per questo progetto di assembly RISC-V, applicata alle seguenti funzioni: `Eval`, `Evaluate`, `String2Int`, `SkipSpaces`, `ReadOperand`, `ReadOperator`:
- Il registro `a0` viene utilizzato per restituire il risultato della funzione (output).
- Il registro `a1` contiene l'indirizzo dell'espressione aritmetica.
- Il registro `a2` contiene il tipo di errore che viene impostato in caso di errore.
- Il registro `a3` (utilizzato solo da ReadOperand) è il contatore delle parentesi aperte.

Per quanto riguarda le funzioni di operazioni aritmetiche (`Addition`, `Subtraction`, `Mul`, `Div`):
- Il registro `a0` serve per restituire il risultato dell'operazione aritmetica.
- Il registro `a3` contiene il tipo di errore che viene impostato in caso di errore.

Poiché le funzioni condividono gli stessi registri, possiamo dire che i parametri sono passati per riferimento. Ad esempio, quando `Evaluate` chiama `String2Int`, poiché entrambe le funzioni condividono lo stesso indirizzo dell'espressione, dopo l'esecuzione di `String2Int`, `Evaluate` è in grado di riprendere la valutazione esattamente dal punto in cui `String2Int` si era fermata.

### Eval:

La funzione `Eval` si occupa di valutare l'espressione aritmetica ricevuta come input, affidando questa operazione a un'altra funzione ricorsiva chiamata `Evaluate`, che implementa la valutazione vera e propria dell'espressione. Prima di invocare `Evaluate`, `Eval` prepara gli argomenti necessari e salva nello stack l'indirizzo iniziale dell'espressione aritmetica fornita come argomento, poiché durante l'esecuzione di `Evaluate` l'indirizzo dell'espressione potrebbe essere modificato. Dopo l'esecuzione di `Evaluate`, riprende l'indirizzo iniziale dell'espressione e lo sottrae dall'indirizzo attuale per determinare la posizione in cui si è fermata la valutazione. Questa posizione viene quindi memorizzata nella variabile globale `error_location`. Infine, la funzione gestisce eventuali errori di parentesi verificando se le parentesi dell'espressione sono bilanciate.

- Pseudocodice:
  ```python
  error_location = 0

  Eval(espressione):
      espressione_iniziale = espressione
      
      tipo_errore = 0
      contatore_parentesi = 0
      risultato = Evaluate(espressione, tipo_errore, contatore_parentesi)

      error_location = espressione - espressione_iniziale

      if contatore_parentesi != 0:
          tipo_errore = parenthesesError
      
      return risultato, tipo_errore
  ```

- Input: Indirizzo della stringa contenente l'espressione aritmetica da valutare.
- Output: Risultato dell'espressione aritmetica o un codice di errore (0 se non ci sono errori), memorizzato nel registro `a2`.
- Gestione dei registri e dello stack:
  - `a0` e `a1` sono utilizzati secondo la convenzione di chiamata.
  - `a2` e `a3` contengono i parametri necessari per la chiamata di Evaluate, ossia il tipo di errore e il contatore delle parentesi aperte.
  - `t0` e `t1` sono impiegati come variabili temporanee locali.
  - l'indirizzo di ritorno (`ra`) viene salvato nello stack, poiché viene sovrascritto durante la chiamata di `Evaluate`.
  - `a1`, contenente l'indirizzo dell'espressione, viene salvato nello stack per poter essere recuperato dopo la chiamata di Evaluate.

### Evaluate：

### String2Int:

### SkipSpaces:

### ReadOperand:

### ReadOperator:

### Addition:

### Subtraction:

### Mul:

### Div: