# Ambulatorio Cerba DB

![MySQL](https://img.shields.io/badge/MySQL-8.0-4479A1?logo=mysql&logoColor=white)
![SQL](https://img.shields.io/badge/Language-SQL-336791)
![InnoDB](https://img.shields.io/badge/Engine-InnoDB-F29111)
![Normalization](https://img.shields.io/badge/Normalization-BCNF-success)
![Status](https://img.shields.io/badge/Status-Completato-brightgreen)
![License](https://img.shields.io/badge/License-Educational-lightgrey)

Base di dati relazionale (MySQL / InnoDB) per la gestione di un laboratorio di analisi del sangue. Il sistema modella l'intero flusso operativo dell'ambulatorio: dall'arrivo del paziente alla prenotazione degli esami, dall'esecuzione del prelievo all'emissione del referto firmato dal medico, fino alla gestione del magazzino dei prodotti sanitari e degli ordini ai fornitori.

Progetto sviluppato per il corso di **Basi di Dati** — Università Politecnica delle Marche, A.A. 2023/2024 (Gruppo 1707).

---

## Descrizione

Il laboratorio "Centro Medico Cerba – Ortona" gestiva i propri dati manualmente tramite fogli Excel. Questo progetto sostituisce quella gestione con una base di dati strutturata che copre:

- **Pazienti** — anagrafica completa e recapiti telefonici multipli
- **Prenotazioni** — esami richiesti, stato, importo, laboratorio assegnato e segretaria che la registra
- **Esami** — listino con codice, prezzo, unità di misura, valori di riferimento e provetta associata
- **Referti** — documento con gli esiti, firmato e validato da un medico
- **Personale** — gerarchia di dipendenti (segretarie, infermieri, medici)
- **Magazzino** — prodotti sanitari (provette, guanti, lacci emostatici, sistemi di aghi) con relativa disponibilità
- **Fornitori e ordini** — rifornimento del magazzino
- **Macchine** — strumenti che analizzano gli esami in base al colore della provetta

## Struttura del repository

```
.
├── README.md                  # questo file
├── Ambulatorio_Cerba.sql      # dump MySQL: schema (DDL) + dati di test
└── docs/
    └── relazione.pdf          # relazione completa di progetto
```

## Modello dei dati

Lo schema deriva da un modello ER ristrutturato e normalizzato (3NF / BCNF). Tabelle principali:

| Area | Tabelle |
|------|---------|
| Pazienti | `Paziente`, `TelefonoP` |
| Prenotazioni | `Prenotazione`, `ElencazionePrenotazione`, `Referto` |
| Esami e strumenti | `Esame`, `Macchina`, `Laboratorio` |
| Personale | `Dipendente`, `Segretaria`, `Infermiere`, `Medico`, `TelefonoD` |
| Magazzino | `ProdottoSanitario`, `Provetta`, `Guanti`, `LaccioEmostatico`, `SistemaDiAghi`, `ElencazioneProdotti` |
| Fornitori | `Fornitore`, `Ordine`, `ElencazioneOrdine`, `Email`, `TelefonoF`, `Tipologia`, `Rifornimento` |

Scelte progettuali rilevanti:

- La gerarchia **Esame** è stata accorpata nell'entità padre (le sottoclassi non avevano attributi propri).
- Le gerarchie **Dipendente** e **Prodotto Sanitario** sono state tradotte per partizionamento: entità padre + figlie collegate da chiave esterna condivisa.
- Gli attributi multivalore (telefoni, email, tipologie) sono stati estratti in tabelle dedicate.
- Sono mantenute due ridondanze derivate per efficienza: `Prenotazione.Importo` e `ProdottoSanitario.Qnt`.

## Requisiti

- MySQL 8.0 o superiore (il dump usa `utf8mb4_0900_ai_ci`)
- Engine InnoDB (per il supporto alle chiavi esterne)

## Installazione

Il dump non contiene il comando di creazione dello schema, quindi va creato prima:

```bash
# 1. crea il database
mysql -u root -p -e "CREATE DATABASE Ambulatorio_Cerba CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;"

# 2. importa schema e dati
mysql -u root -p Ambulatorio_Cerba < Ambulatorio_Cerba.sql
```

In alternativa, da client MySQL:

```sql
CREATE DATABASE Ambulatorio_Cerba CHARACTER SET utf8mb4 COLLATE utf8mb4_0900_ai_ci;
USE Ambulatorio_Cerba;
SOURCE Ambulatorio_Cerba.sql;
```

## Esempi di interrogazione

**Esami di una prenotazione con relativo esito**

```sql
SELECT ep.Pren, e.Nome, ep.Esito, ep.D_Es
FROM ElencazionePrenotazione ep
JOIN Esame e ON ep.CodEs = e.CodEs
WHERE ep.Pren = 1;
```

**Prenotazioni valide (prelievo non ancora effettuato)**

```sql
SELECT N_Pren, Paziente, Stato
FROM Prenotazione
WHERE DataPrelievo >= CURRENT_DATE;
```

**Esame, prezzo, colore della provetta e macchina che lo analizza**

```sql
SELECT e.CodEs, e.Nome, e.Prezzo, p.Colore, m.Nome AS Macchina
FROM Esame e
JOIN Provetta p ON e.Provetta = p.CodProv
JOIN Macchina m ON p.Macchina = m.CodMac;
```

## Operazioni supportate

Lo schema è progettato per supportare 51 operazioni applicative documentate nella relazione: inserimento/modifica/cancellazione delle entità principali, inserimento esiti, e numerose consultazioni (prenotazioni per periodo, referti per medico, disponibilità prodotti, ecc.).


## Note

Progetto a scopo didattico. I dati presenti nel dump sono fittizi e generati per il testing.
