# Progetto Assembly RISC-V: Valutatore di Espressioni

## Informazioni

- **Autore:** Lorenzo Yang
- **Indirizzo e-mail:** lorenzo.yang@edu.unifi.it
- **Matricola:** 7136074
- **Data di consegna:** 21/8/2024
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

### Convenzione di progetto

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

- **Input:** Indirizzo della stringa contenente l'espressione aritmetica da valutare.
- **Output:** Risultato dell'espressione aritmetica o un codice di errore (0 se non ci sono errori, memorizzato nel registro `a2`).
- **Pseudocodice:**
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
- **Gestione dei registri e dello stack:**
  - `a0` e `a1` sono utilizzati secondo la convenzione di progetto.
  - `a2` e `a3` contengono i parametri necessari per la chiamata di Evaluate, ossia il tipo di errore e il contatore delle parentesi aperte.
  - `t0` e `t1` sono impiegati come variabili temporanee locali seguendo la convenzione di chiamata ([calling convention](https://riscv.org/wp-content/uploads/2015/01/riscv-calling.pdf)) di RISC-V:
    > In addition to the argument and return value registers, seven integer registers t0–t6 and twelve floating-point registers ft0–ft11 are temporary registers that are volatile across calls and must be saved by the caller if later used.
  - l'indirizzo di ritorno (`ra`) viene salvato nello stack, poiché viene sovrascritto durante la chiamata di `Evaluate`.
  - `a1`, contenente l'indirizzo dell'espressione, viene salvato nello stack per poter essere recuperato dopo la chiamata di Evaluate.

### Evaluate：

La funzione Evaluate è quella che effettivamente implementa la valutazione ricorsiva delle espressioni aritmetiche. Utilizza quattro variabili locali: `left`, `right`, `op` (operatore) e `c`, una variabile temporanea. Tra queste, `left`, `right` e `op` vengono inizialmente salvate nello stack, e i loro valori vengono ripristinati prima della fine della funzione, poiché potrebbe essere necessaria una chiamata ricorsiva a se stessa a seconda del risultato della funzione `ReadOperand` (ad esempio, se viene trovata una parentesi aperta). Se queste variabili non fossero salvate nello stack, andrebbero perse dopo l'esecuzione della chiamata ricorsiva. Ad esempio, durante la lettura del valore per `right`, se `ReadOperand` restituisce una parentesi aperta, viene eseguita una chiamata ricorsiva per calcolare il risultato della sotto-espressione, che verrà poi assegnato a `right`. Prima di concludere questa operazione, i valori salvati nello stack vengono recuperati, ripristinando `left`, `right` e `op`. Una volta terminata la chiamata ricorsiva, il flusso del programma riprende dal punto in cui era stata avviata la chiamata ricorsiva, e il valore restituito viene assegnato a `right`. A questo punto, ho i valori originali di `left` e `op`, insieme al valore aggiornato di `right`, e posso quindi procedere con l'esecuzione dell'operazione aritmetica finale.

- **Input:** Indirizzo della stringa contenente l'espressione aritmetica da valutare, tipo di errore inizializzato a 0, contatore delle parentesi aperte inizializzato a 0.
- **Output:** Risultato dell'espressione aritmetica o un codice di errore (0 se non ci sono errori).
- **Pseudocodice:**
  ```python
  Evaluate(espressione, tipo_errore, contatore_parentesi):
      left = 0
      right = 0
      op = 0
      c = ''

      c = ReadOperand(espressione, tipo_errore, contatore_parentesi)
      if tipo_errore != NoError:
          return 0

      left = Evaluate(espressione, tipo_errore, contatore_parentesi) if c == '(' else String2Int(espressione, tipo_errore)
      if tipo_errore != NoError:
          return 0

      op = ReadOperator(espressione, tipo_errore)
      if tipo_errore != NoError:
          return 0
      
      c = ReadOperand(espressione, tipo_errore, contatore_parentesi)
      if tipo_errore != NoError:
          return 0
      
      right = Evaluate(espressione, tipo_errore, contatore_parentesi) if c == '(' else String2Int(espressione, tipo_errore)
      if tipo_errore != NoError:
          return 0

      SkipSpaces(espressione)
      # 'espressione[0]' indica il carattere attuale puntato dall'indirizzo 'espressione' ('espressione' è un puntatore)
      if espressione[0] == ')': 
          contatore_parentesi -= 1
          if contatore_parentesi < 0:
              tipo_errore = parenthesesError
              return 0
          espressione += 1 # incremento l'indirizzo per passare alla prossima posizione
      else if espresseione[0] != '\0':
          tipo_errore = syntaxError
          return 0
      
      return switch(op):
          case '+': Addition(left, right, tipo_errore)
          case '-': Subtraction(left, right, tipo_errore)
          case '*': Mul(left, right, tipo_errore)
          case '/': Div(left, right, tipo_errore)
  ```

- **Gestione dei registri e dello stack:** Inizialmente, in questa funzione ho utilizzato i registri `t_` (registri per valori temporanei) per memorizzare i valori di `left`, `right` e `op`. Tuttavia, ho incontrato una difficoltà: la funzione Evaluate chiama altre funzioni, come `String2Int`, che utilizzano anch'esse i registri `t_` per altri scopi. Di conseguenza, se continuassi a usare i registri `t_` nella funzione `Evaluate`, dovrei salvare i valori di `left`, `right` e `op` nello stack prima di chiamare `String2Int` e ripristinarli successivamente. Inoltre, trattandosi di una funzione ricorsiva, sarebbe necessario salvare nuovamente questi valori all'inizio della funzione (o prima della chiamata ricorsiva) e ripristinarli alla fine (o subito dopo la chiamata ricorsiva). Questo comporterebbe un aumento del codice e una diminuzione delle prestazioni. Per evitare tali problemi, ho scelto di utilizzare i registri `s_`, che, secondo la convenzione di chiamata RISC-V ([calling convention](https://riscv.org/wp-content/uploads/2015/01/riscv-calling.pdf)), sono destinati a conservare valori che devono essere mantenuti attraverso le chiamate di funzione. Ciò implica che, se una funzione utilizza questi registri, deve prima salvarne i valori originali (ad esempio, sullo stack) e poi ripristinarli prima di restituire il controllo alla funzione chiamante. Questi registri sono quindi comunemente utilizzati per memorizzare variabili locali o dati che devono essere preservati durante l'esecuzione di una funzione, soprattutto quando si prevede che la funzione chiamata esegua ulteriori chiamate che potrebbero sovrascrivere altri registri temporanei.
  > Twelve integer registers s0–s11 and twelve floating-point registers fs0–fs11 are preserved across calls and must be saved by the callee if used. ([calling convention](https://riscv.org/wp-content/uploads/2015/01/riscv-calling.pdf))

  - Indirizzo di ritorno (`ra`) salvato nello stack poiché viene sovrascritto durante le altre chiamate di funzione. 

### String2Int:

la funzione riceve in input un puntatore che punta ad un carattere numerico e restituisce il valore numerico rappresentato dalla stringa numerica che inizia da quel carattere. La funzione continua a leggere i caratteri numerici fino a quando non incontra un carattere non numerico o la fine della stringa. Se il numero rappresentato dalla stringa è troppo grande per essere contenuto in un intero a 32 bit, viene generato un errore di overflow.

- **Input:** Indirizzo della stringa contenente il numero da convertire, tipo di errore che viene impostato in caso di errore.
- **Output:** Intero convertito dalla stringa numerica o un codice di errore (0 se non ci sono errori)
- **Pseudocodice:**
  ```python
  String2Int(espressione, tipo_errore):
      risultato = 0
      indice = 0

      while espressione[indice] >= '0' and espressione[indice] <= '9':
          risultato = risultato * 10 + (espressione[indice] - '0')
          indice = indice + 1

          if risultato < 0:
              tipo_errore = overflowErrorString2Int
              return 0

      return risultato
  ```
- **Gestione dei registri e dello stack:** Come accade nella funzione `Evaluate`(dove i registri `s_` vengono utilizzati per lo stesso motivo), anche `String2Int` chiama a sua volta un'altra funzione (`Mul`) che utilizza i registri `t_` per memorizzare i valori temporanei. Per evitare conflitti, ho utilizzato i registri `s_` (`s1`, `s2`) per conservare le due costanti '0' e '9', `s3` per il carattere corrente e `s0` per la somma temporanea.
  - I registri `s_` (`s0`, `s1`, `s2`, `s3`) vengono salvati nello stack, seguendo la convenzione di chiamata RISC-V.
  - I registri `a0`, `a1`, `a2` vengono utilizzati secondo la convenzione di progetto.
  - L'indirizzo di ritorno (`ra`) viene memorizzato nello stack, poiché viene sovrascritto durante la chiamata a Mul.
  - Prima di invocare `Mul`, devo anche salvare i registri `a1`, `a2`, `a3` nello stack, poiché condividono gli stessi registri per i parametri, e ripristinarli dopo la chiamata a `Mul`.

### SkipSpaces:

- **Input:** Indirizzo della stringa contenente l'espressione aritmetica.
- **Output:** Nessuno.
- **Pseudocodice:**
  ```python
  SkipSpaces(espressione):
      while espressione[0] == ' ':
          espressione += 1
  ```
- **Gestione dei registri e dello stack:**
  - `t0` per memorizzare lo spazio (' ').
  - `t1` per il carattere corrente.
  - `a0`,  `a1` secondo la convenzione di chiamata.

### ReadOperand:
La funzione viene chiamata quando nell'espressione aritmetica ci si aspetta un operando (o una parentesi aperta)。 Se non si rileva né un operando né una parentesi aperta, viene generato un errore (syntaxErrorOperand). Se viene rilevata una parentesi aperta, il contatore delle parentesi aperte viene incrementato. Nel caso in cui venga trovato un operando, la funzione restituisce il primo carattere di quest'ultimo.

- **Input:** Indirizzo della stringa contenente l'espressione aritmetica, tipo di errore che viene impostato in caso di errore, contatore delle parentesi aperte.
- **Output:** Primo carattere dell'operando o della parentesi aperta.
- **Pseudocodice:**
  ```python
  ReadOperand(espressione, tipo_errore, contatore_parentesi):
      SkipSpaces(espressione)

      c = espressione[0]
      if(c == '(' or (c >= '0' and c <= '9')):
          if c == '(':
              contatore_parentesi += 1
              espresseione += 1
      else:
          tipo_errore = syntaxErrorOperand
      
      return c
  ```
- **Gestione dei registri e dello stack:**
  - `t0` per parentesi aperta, `t1` per '0', `t2` per '9', `t3` per il carattere corrente.
  - `a0`, `a1`, `a2`, `a3` secondo la convenzione di progetto.
  - Indirizzo di ritorno (`ra`) salvato nello stack, poiché verrà sovrascritto dalla chiamata di `SkipSpaces`.

### ReadOperator:
La funzione viene chiamata quando nell'espressione aritmetica ci si aspetta un operatore. Se non viene trovato alcun operatore, viene generato un errore (syntaxErrorOperator). Altrimenti, la funzione restituisce il carattere corrispondente all'operatore.

- **Input:** Indirizzo della stringa contenente l'espressione aritmetica, tipo di errore che viene impostato in caso di errore.
- **Output:** Carattere dell'operatore.
- **Pseudocodice:**
  ```python
  ReadOperator(espressione, tipo_errore):
      SkipSpaces(espressione)

      c = espressione[0]
      if c != '+' and c != '-' and c != '*' and c != '/':
          tipo_errore = syntaxErrorOperator
      espressione += 1
      return c
  ```
- **Gestione dei registri e dello stack:**
  - `t0`, `t1`, `t2`, `t3` per i caratteri '+', '-', '*', '/', t4 per il carattere corrente.
  - `a0`, `a1`, `a2` secondo la convenzione di progetto.

### Addition:
L'addizione con controllo di overflow.

- **Input:** Due operandi e il tipo di errore che viene impostato in caso di errore.
- **Output:** Risultato dell'addizione o un codice di errore (0 se non ci sono errori).
- **Pseudocodice:**
  ```python
  Addition(a, b, tipo_errore):
      if b > 0 and a > (INT_MAX - b) or b < 0 and a < (INT_MIN - b):
          tipo_errore = overflowErrorAddition
      return a + b
  ```
- **Gestione dei registri e dello stack:**
  - `t0` per INT32_MIN, `t1` per INT32_MAX.
  - `a0`, `a1`, `a2`, `a3` secondo la convenzione di progetto.

### Subtraction:
La sottrazione con controllo di overflow.

- **Input:** Due operandi e il tipo di errore che viene impostato in caso di errore.
- **Output:** Risultato della sottrazione o un codice di errore (0 se non ci sono errori).
- **Pseudocodice:**
  ```python
  Subtraction(a, b, tipo_errore):
      if b > 0 and a < (INT_MIN + b) or b < 0 and a > (INT_MAX + b):
          tipo_errore = overflowErrorSubtraction
      return a - b
  ```
- **Gestione dei registri e dello stack:**
  - `t0` per INT32_MIN, `t1` per INT32_MAX.
  - `a0`, `a1`, `a2`, `a3` secondo la convenzione di progetto.

### Mul:
La moltiplicazione con controllo dell'overflow, implementata attraverso l'algoritmo di Booth, presenta una complessità lineare rispetto al numero di bit del moltiplicatore. Di conseguenza, il numero di istruzioni eseguite è proporzionale al numero di bit utilizzati per rappresentare il moltiplicando o il moltiplicatore.

- **Input:** Due operandi e il tipo di errore che viene impostato in caso di errore.
- **Output:** Risultato della moltiplicazione o un codice di errore (0 se non ci sono errori).
- **Flow-chart:**
  ![flowchart di Booth](./img/Booth_flowchart.png)
- **Gestione dei registri e dello stack:**
  - `t0` usato come accumulatore (A).
  - `t1` rappresenta il registro 'Q_-1', utilizzato per memorizzare il bit nella posizione -1 del registro Q ( Q = moltiplicatore).
  - `t2` registro che contiene il numero di bit del moltiplicatore. (contatore del ciclo for)
  - `t3` complemento a 2 del moltiplicando.
  - `t4` utilizzato per salvare il bit meno singificativo del moltiplicatore (Q).
  - `a0`, `a1`, `a2`, `a3` assegnati secondo la convenzione di progetto.


### Div:
La divisione con controllo di divisione per zero e overflow, realizzata tramite l'algoritmo di Restoring Division, ha una complessità lineare rispetto al numero di bit del dividendo.   Tuttavia, questa implementazione non supporta la divisione tra numeri con segni diversi. Per risolvere questo problema, ho aggiunto un controllo che previene la divisione tra valori con segni opposti. In pratica, conto quanti valori negativi sono presenti (due nel caso in cui sia il dividendo che il divisore siano negativi); se il numero di valori negativi è dispari, il risultato sarà negativo, altrimenti sarà positivo.
  
- **Input:** Due operandi e il tipo di errore che viene impostato in caso di errore.
- **Output:** Risultato della divisione o un codice di errore (0 se non ci sono errori).
- **Flow-chart:**
  ![flowchart di Restoring-Division](./img/RestoringDivision_flowchart.png)
- **Gestione dei registri e dello stack:**
  - `t0` usato come accumulatore (A).
  - `t1` usato come registro contatore (numero di bit del dividendo).
  - `t6` che decide il segno del risultato: se è dispari, il risultato sarà negativo.
  - `t2`, `t3` utilizzati per valori temporanei.
  - `a0`, `a1` (dividendo), `a2` (divisore), `a3` assegnati secondo la convenzione di progetto.

## Test

### ((1+2)\*(3\*2))-(1+(1024/3)):

![test esempio 1](./img/test_esem_1.png)

### ((00000-2)*(1024+1024)) / 2:

![test esempio 2](./img/test_esem_2.png)

### 1+(1+(1+(1+(1+(1+(1+0)))))):

![test esempio 3](./img/test_esem_3.png)

### 2*(2*(2*(2*(2*(2*(2*(2*(2*(2*(2*(1024*1024))))))))))):

![test esempio 4](./img/test_esem_4.png)

### 2147483647+0:

![test esempio 5](./img/test_esem_5.png)

### 2147483647+1:

![test esempio 6](./img/test_esem_6.png)

### (0-2147483647)-1:

![test esempio 7](./img/test_esem_7.png)

### (0-2147483647)-2:

![test esempio 8](./img/test_esem_8.png)

### 5 +:

![test esempio 9](./img/test_esem_9.png)

### 1/(2-2):

![test esempio 10](./img/test_esem_10.png)