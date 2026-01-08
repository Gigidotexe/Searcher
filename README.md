# Search Tool
Questo documento descrive il funzionamento di uno script **Batch per Windows** che consente di cercare un termine all’interno di un file di testo organizzato in **blocchi logici**, delimitati da una stringa specifica (`===BLOCK===`).

Lo script restituisce interi blocchi contenenti il termine cercato e gestisce in modo controllato l’input dell’utente e l’uscita dal programma.

---

## Inizializzazione dello script

```bat
@echo off
setlocal EnableDelayedExpansion
chcp 65001 >nul
```
All’avvio vengono disattivati i comandi a schermo per mantenere l’output pulito. <br>
La `Delayed Expansion` è necessaria per gestire correttamente le variabili aggiornate all’interno dei cicli. <br>
La code page UTF-8 (`chcp 65001 >nul`) permette la visualizzazione corretta di caratteri speciali e accentati. <br>

---

## Definizione delle variabili principali

```bat
set FILE=C:\Path\File.txt
set DELIM===BLOCK===
set TOTAL_LINES=30
set EMPTY=""
set TMP=%CD%\temp.txt
```
Questa sezione definisce i parametri fondamentali dello script. <br>
`FILE` indica il file di testo da analizzare. <br>
`DELIM` rappresenta la stringa che separa i blocchi logici. <br>
`TOTAL_LINES` serve per mantenere il prompt sempre in fondo alla console. <br>
`EMPTY` viene usata per intercettare input vuoti. <br>
`TMP` è il file temporaneo che contiene il blocco corrente e viene creato nella directory corrente. <br>

---

## Verifica del file

```bat
if not exist "%FILE%" (
    echo File non trovato!
    pause
    exit /b
)
```
Prima di iniziare la ricerca, lo script controlla che il file specificato esista. <br>
In caso contrario, mostra un messaggio di errore e termina l’esecuzione in modo controllato. <br>

---

## Input dell’utente

```bat
:INPUT
echo Cerca:
set /p QUERY=

if "!QUERY!"==%EMPTY% goto INPUT
if /I "!QUERY!"=="exit" goto CLEAN_EXIT
```
Questa etichetta segna l’inizio del ciclo principale. <br>
L’utente inserisce il termine da cercare, che viene salvato nella variabile `QUERY`. <br>
Se l’utente preme Invio senza scrivere nulla, lo script torna a richiedere l’input. <br>
Il comando `exit` consente di terminare il programma in modo controllato. <br>

---

## Inizializzazione delle variabili di stato

```bat
cls
set INBLOCK=0
set FOUND=0
set LINE_COUNT=0
del "%TMP%" 2>nul
```
La console viene pulita prima di mostrare i risultati. <br>
`INBLOCK` indica se lo script si trova all’interno di un blocco. <br>
`FOUND` segnala se almeno un blocco corrispondente è stato trovato. <br>
`LINE_COUNT` tiene traccia delle righe stampate. <br>
Il file temporaneo viene eliminato se presente da esecuzioni precedenti. <br>

---

## Parsing del file e gestione dei blocchi

```bat
for /f "usebackq delims=" %%A in ("%FILE%") do (
    echo %%A | findstr /C:"%DELIM%" >nul
)
```
Il file viene letto riga per riga mentendo ogni riga dentro la variabile temporanea `A`. <br>
Ogni riga viene analizzata per verificare se rappresenta un delimitatore di blocco. <br>
Quando un delimitatore viene trovato, lo script gestisce la chiusura del blocco precedente e l’apertura di uno nuovo. <br>

---

## Ricerca del termine all’interno dei blocchi

```bat
findstr /I /C:"!QUERY!" "%TMP%" >nul
```
Il termine inserito dall’utente viene cercato all’interno dell’intero blocco corrente. <br>
La ricerca è case-insensitive e non limitata a singole righe, garantendo risultati coerenti. <br>

---

## Output dei risultati

```bat
for /f "usebackq delims=" %%B in ("%TMP%") do (
    echo %%B
)
```
Quando un blocco contiene il termine cercato, il suo contenuto viene stampato integralmente a schermo, preservando la struttura originale.

---

## Gestione dell’assenza di risultati

```bat
if "%FOUND%"=="0" (
    echo Nessuna corrispondenza trovata nel file.
)
```
Se nessun blocco soddisfa la ricerca, viene mostrato un messaggio informativo all’utente.

---

## Ciclo continuo di ricerca

```bat
goto INPUT
```
Al termine dell’output, lo script torna alla richiesta di input, permettendo ricerche successive senza riavviare il programma.

---

## Uscita pulita e rimozione del file temporaneo

```bat
:CLEAN_EXIT
if exist "%TMP%" del "%TMP%"
exit /b
```
L’uscita dal programma è centralizzata in un’unica sezione che garantisce l’eliminazione del file temporaneo e una chiusura ordinata dello script.

---

