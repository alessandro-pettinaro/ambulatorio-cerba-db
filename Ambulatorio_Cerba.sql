DROP DATABASE IF EXISTS Ambulatorio_Cerba;
CREATE DATABASE Ambulatorio_Cerba
  CHARACTER SET utf8mb4
  COLLATE utf8mb4_0900_ai_ci;
USE Ambulatorio_Cerba;

SET FOREIGN_KEY_CHECKS = 0;

-- =====================================================================
--  STRUTTURA DELLE TABELLE
-- =====================================================================

-- ---------- Anagrafiche di base (senza dipendenze) -------------------

CREATE TABLE Macchina (
  CodMac    char(4)       NOT NULL,
  Nome      varchar(10)   NOT NULL,
  Info      varchar(100)  DEFAULT NULL,
  T_Analisi decimal(3,0)  NOT NULL,
  PRIMARY KEY (CodMac),
  CONSTRAINT macchina_chk_1 CHECK (char_length(CodMac) = 4),
  CONSTRAINT macchina_chk_2 CHECK (T_Analisi > 0)
) ENGINE=InnoDB;

CREATE TABLE Laboratorio (
  CodLab char(5)      NOT NULL,
  Nome   varchar(10)  NOT NULL,
  Piano  decimal(1,0) NOT NULL,
  Stanza varchar(10)  NOT NULL,
  PRIMARY KEY (CodLab),
  CONSTRAINT laboratorio_chk_1 CHECK (char_length(CodLab) = 5),
  CONSTRAINT laboratorio_chk_2 CHECK (Piano = 1 OR Piano = 2)
) ENGINE=InnoDB;

CREATE TABLE Dipendente (
  CodOp        char(5)      NOT NULL,
  Nome         varchar(16)  NOT NULL,
  Cognome      varchar(16)  NOT NULL,
  CF           char(16)     NOT NULL,
  Sesso        char(1)      NOT NULL,
  DataNascita  date         NOT NULL,
  Citta        varchar(20)  NOT NULL,
  CAP          char(5)      NOT NULL,
  Via          varchar(100) NOT NULL,
  N_Civ        varchar(4)   NOT NULL,
  LuogoNascita varchar(20)  NOT NULL,
  PRIMARY KEY (CodOp),
  CONSTRAINT dipendente_chk_1 CHECK (char_length(CodOp) = 5),
  CONSTRAINT dipendente_chk_2 CHECK (char_length(CF) = 16),
  CONSTRAINT dipendente_chk_3 CHECK (Sesso = 'M' OR Sesso = 'F'),
  CONSTRAINT dipendente_chk_4 CHECK (char_length(CAP) = 5)
) ENGINE=InnoDB;

CREATE TABLE Paziente (
  CF           char(16)     NOT NULL,
  Nome         varchar(16)  NOT NULL,
  Cognome      varchar(16)  NOT NULL,
  Sesso        char(1)      NOT NULL,
  DataNascita  date         NOT NULL,
  Citta        varchar(20)  NOT NULL,
  CAP          char(5)      NOT NULL,
  Via          varchar(100) NOT NULL,
  N_Civ        varchar(4)   NOT NULL,
  LuogoNascita varchar(20)  NOT NULL,
  PRIMARY KEY (CF),
  CONSTRAINT paziente_chk_1 CHECK (char_length(CF) = 16),
  CONSTRAINT paziente_chk_2 CHECK (Sesso = 'M' OR Sesso = 'F'),
  CONSTRAINT paziente_chk_3 CHECK (char_length(CAP) = 5)
) ENGINE=InnoDB;

CREATE TABLE ProdottoSanitario (
  CodProd char(4)      NOT NULL,
  Nome    varchar(16)  NOT NULL,
  Qnt     decimal(4,0) DEFAULT NULL,
  PRIMARY KEY (CodProd),
  CONSTRAINT prodottosanitario_chk_1 CHECK (char_length(CodProd) = 4),
  CONSTRAINT prodottosanitario_chk_2 CHECK (Qnt >= 0)
) ENGINE=InnoDB;

CREATE TABLE Fornitore (
  CF       char(16)     NOT NULL,
  Nome     varchar(16)  NOT NULL,
  Fax      varchar(15)  DEFAULT NULL,
  Citta    varchar(20)  NOT NULL,
  CAP      char(5)      NOT NULL,
  Via      varchar(100) NOT NULL,
  N_Civico varchar(4)   NOT NULL,
  WebSite  varchar(30)  DEFAULT NULL,
  T_Sped   decimal(3,0) NOT NULL,
  PRIMARY KEY (CF),
  CONSTRAINT fornitore_chk_1 CHECK (char_length(CF) = 16),
  CONSTRAINT fornitore_chk_2 CHECK (char_length(CAP) = 5),
  CONSTRAINT fornitore_chk_3 CHECK (T_Sped > 0)
) ENGINE=InnoDB;

CREATE TABLE Tipologia (
  TipProd varchar(20) NOT NULL,
  PRIMARY KEY (TipProd)
) ENGINE=InnoDB;

-- ---------- Specializzazioni dei dipendenti -------------------------

CREATE TABLE Segretaria (
  CodOpSeg char(5)     NOT NULL,
  Username varchar(16) NOT NULL,
  Password varchar(64) NOT NULL,   -- in produzione: salvare un hash, non la password in chiaro
  PRIMARY KEY (CodOpSeg),
  CONSTRAINT segretaria_ibfk_1 FOREIGN KEY (CodOpSeg) REFERENCES Dipendente (CodOp)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Infermiere (
  CodOpInf    char(5)     NOT NULL,
  Tipo        varchar(16) NOT NULL,
  Laboratorio char(5)     DEFAULT NULL,
  PRIMARY KEY (CodOpInf),
  KEY Laboratorio (Laboratorio),
  CONSTRAINT infermiere_ibfk_1 FOREIGN KEY (CodOpInf) REFERENCES Dipendente (CodOp)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT infermiere_ibfk_2 FOREIGN KEY (Laboratorio) REFERENCES Laboratorio (CodLab)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE Medico (
  CodOpMed char(5)     NOT NULL,
  Spec     varchar(30) NOT NULL,
  PRIMARY KEY (CodOpMed),
  CONSTRAINT medico_ibfk_1 FOREIGN KEY (CodOpMed) REFERENCES Dipendente (CodOp)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------- Specializzazioni dei prodotti sanitari ------------------

CREATE TABLE Provetta (
  CodProv  char(4)     NOT NULL,
  Colore   varchar(10) NOT NULL,
  Macchina char(4)     DEFAULT NULL,
  PRIMARY KEY (CodProv),
  UNIQUE KEY Colore (Colore),
  KEY Macchina (Macchina),
  CONSTRAINT provetta_ibfk_1 FOREIGN KEY (CodProv) REFERENCES ProdottoSanitario (CodProd)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT provetta_ibfk_2 FOREIGN KEY (Macchina) REFERENCES Macchina (CodMac)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE Guanti (
  CodGnt char(4) NOT NULL,
  Taglia char(2) NOT NULL,
  PRIMARY KEY (CodGnt),
  CONSTRAINT guanti_ibfk_1 FOREIGN KEY (CodGnt) REFERENCES ProdottoSanitario (CodProd)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT guanti_chk_1 CHECK (Taglia IN ('S','M','L','XL'))
) ENGINE=InnoDB;

CREATE TABLE LaccioEmostatico (
  CodLac    char(4)      NOT NULL,
  Lunghezza decimal(3,0) NOT NULL,
  PRIMARY KEY (CodLac),
  CONSTRAINT laccioemostatico_ibfk_1 FOREIGN KEY (CodLac) REFERENCES ProdottoSanitario (CodProd)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE SistemaDiAghi (
  CodSis   char(4)      NOT NULL,
  Spessore decimal(3,1) NOT NULL,
  PRIMARY KEY (CodSis),
  CONSTRAINT sistemadiaghi_ibfk_1 FOREIGN KEY (CodSis) REFERENCES ProdottoSanitario (CodProd)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------- Esami ---------------------------------------------------

CREATE TABLE Esame (
  CodEs       varchar(10)  NOT NULL,
  Nome        varchar(30)  NOT NULL,
  Prezzo      decimal(5,2) NOT NULL,
  UnitaMisura varchar(10)  NOT NULL,
  V_Min       decimal(5,2) DEFAULT NULL,
  V_Max       decimal(5,2) DEFAULT NULL,
  Provetta    char(4)      DEFAULT NULL,
  PRIMARY KEY (CodEs),
  KEY Provetta (Provetta),
  CONSTRAINT esame_ibfk_1 FOREIGN KEY (Provetta) REFERENCES Provetta (CodProv)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT esame_chk_1 CHECK (Prezzo > 0)
) ENGINE=InnoDB;

-- ---------- Ordini / fornitura --------------------------------------

CREATE TABLE Ordine (
  CodOrd    int          NOT NULL AUTO_INCREMENT,
  DataOrd   date         NOT NULL,
  Fornitore char(16)     DEFAULT NULL,
  PRIMARY KEY (CodOrd),
  KEY Fornitore (Fornitore),
  CONSTRAINT ordine_ibfk_1 FOREIGN KEY (Fornitore) REFERENCES Fornitore (CF)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB AUTO_INCREMENT=7;

CREATE TABLE ElencazioneOrdine (
  Prodotto char(4) NOT NULL,
  Ordine   int     NOT NULL,
  Qnt      int     NOT NULL,
  PRIMARY KEY (Prodotto, Ordine),
  KEY Ordine (Ordine),
  CONSTRAINT elencazioneordine_ibfk_1 FOREIGN KEY (Prodotto) REFERENCES ProdottoSanitario (CodProd)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT elencazioneordine_ibfk_2 FOREIGN KEY (Ordine) REFERENCES Ordine (CodOrd)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT elencazioneordine_chk_1 CHECK (Qnt > 0)
) ENGINE=InnoDB;

CREATE TABLE Email (
  Email     varchar(50) NOT NULL,
  Fornitore char(16)    DEFAULT NULL,
  PRIMARY KEY (Email),
  KEY Fornitore (Fornitore),
  CONSTRAINT email_ibfk_1 FOREIGN KEY (Fornitore) REFERENCES Fornitore (CF)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

CREATE TABLE Rifornimento (
  Tipologia varchar(20) NOT NULL,
  Fornitore char(16)    NOT NULL,
  PRIMARY KEY (Tipologia, Fornitore),
  KEY Fornitore (Fornitore),
  CONSTRAINT rifornimento_ibfk_1 FOREIGN KEY (Tipologia) REFERENCES Tipologia (TipProd)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT rifornimento_ibfk_2 FOREIGN KEY (Fornitore) REFERENCES Fornitore (CF)
    ON UPDATE CASCADE ON DELETE CASCADE
) ENGINE=InnoDB;

-- ---------- Prenotazioni / referti ----------------------------------

CREATE TABLE Prenotazione (
  N_Pren       int          NOT NULL AUTO_INCREMENT,
  Paziente     char(16)     DEFAULT NULL,
  Stato        varchar(16)  DEFAULT 'non effettuata',
  DataPren     date         NOT NULL,
  DataPrelievo date         NOT NULL,
  Importo      decimal(7,2) DEFAULT NULL,
  Segretaria   char(5)      DEFAULT NULL,
  Laboratorio  char(5)      DEFAULT NULL,
  PRIMARY KEY (N_Pren),
  KEY Paziente (Paziente),
  KEY Segretaria (Segretaria),
  KEY Laboratorio (Laboratorio),
  KEY idx_pren_datapren (DataPren),
  KEY idx_pren_dataprelievo (DataPrelievo),
  KEY idx_pren_stato (Stato),
  CONSTRAINT prenotazione_ibfk_1 FOREIGN KEY (Paziente) REFERENCES Paziente (CF)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT prenotazione_ibfk_2 FOREIGN KEY (Segretaria) REFERENCES Segretaria (CodOpSeg)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT prenotazione_ibfk_3 FOREIGN KEY (Laboratorio) REFERENCES Laboratorio (CodLab)
    ON UPDATE CASCADE ON DELETE SET NULL,
  CONSTRAINT prenotazione_chk_1 CHECK (Importo > 0),
  CONSTRAINT prenotazione_chk_2 CHECK (Stato IN ('eseguita','non effettuata'))
) ENGINE=InnoDB AUTO_INCREMENT=4;

CREATE TABLE Referto (
  NPren  int      NOT NULL,
  Medico char(5)  DEFAULT NULL,
  DataEm date     DEFAULT NULL,
  PRIMARY KEY (NPren),
  KEY Medico (Medico),
  KEY idx_referto_dataem (DataEm),
  CONSTRAINT referto_ibfk_1 FOREIGN KEY (NPren) REFERENCES Prenotazione (N_Pren)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT referto_ibfk_2 FOREIGN KEY (Medico) REFERENCES Medico (CodOpMed)
    ON UPDATE CASCADE ON DELETE SET NULL
) ENGINE=InnoDB;

CREATE TABLE ElencazionePrenotazione (
  Pren  int          NOT NULL,
  CodEs varchar(10)  NOT NULL,
  Esito decimal(5,2) DEFAULT NULL,
  D_Es  date         DEFAULT NULL,
  PRIMARY KEY (Pren, CodEs),
  KEY CodEs (CodEs),
  KEY idx_ep_des (D_Es),
  CONSTRAINT elencazioneprenotazione_ibfk_1 FOREIGN KEY (Pren) REFERENCES Prenotazione (N_Pren)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT elencazioneprenotazione_ibfk_2 FOREIGN KEY (CodEs) REFERENCES Esame (CodEs)
    ON UPDATE CASCADE ON DELETE RESTRICT
) ENGINE=InnoDB;

CREATE TABLE ElencazioneProdotti (
  Pren int     NOT NULL,
  Prod char(4) NOT NULL,
  Qnt  int     NOT NULL,
  PRIMARY KEY (Pren, Prod),
  KEY Prod (Prod),
  CONSTRAINT elencazioneprodotti_ibfk_1 FOREIGN KEY (Pren) REFERENCES Prenotazione (N_Pren)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT elencazioneprodotti_ibfk_2 FOREIGN KEY (Prod) REFERENCES ProdottoSanitario (CodProd)
    ON UPDATE CASCADE ON DELETE RESTRICT,
  CONSTRAINT elencazioneprodotti_chk_1 CHECK (Qnt > 0)
) ENGINE=InnoDB;

-- ---------- Attributi multivalore (telefoni) ------------------------

CREATE TABLE TelefonoD (
  NTel       varchar(10) NOT NULL,
  Dipendente char(5)     DEFAULT NULL,
  PRIMARY KEY (NTel),
  KEY Dipendente (Dipendente),
  CONSTRAINT telefonod_ibfk_1 FOREIGN KEY (Dipendente) REFERENCES Dipendente (CodOp)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT telefonod_chk_1 CHECK (char_length(NTel) = 10)
) ENGINE=InnoDB;

CREATE TABLE TelefonoF (
  NTel      varchar(10) NOT NULL,
  Fornitore char(16)    DEFAULT NULL,
  PRIMARY KEY (NTel),
  KEY Fornitore (Fornitore),
  CONSTRAINT telefonof_ibfk_1 FOREIGN KEY (Fornitore) REFERENCES Fornitore (CF)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT telefonof_chk_1 CHECK (char_length(NTel) = 10)
) ENGINE=InnoDB;

CREATE TABLE TelefonoP (
  NTel     varchar(10) NOT NULL,
  Paziente char(16)    DEFAULT NULL,
  PRIMARY KEY (NTel),
  KEY Paziente (Paziente),
  CONSTRAINT telefonop_ibfk_1 FOREIGN KEY (Paziente) REFERENCES Paziente (CF)
    ON UPDATE CASCADE ON DELETE CASCADE,
  CONSTRAINT telefonop_chk_1 CHECK (char_length(NTel) = 10)
) ENGINE=InnoDB;

-- =====================================================================
--  DATI DI TEST
-- =====================================================================

INSERT INTO Macchina VALUES
  ('MA11','TC01','Macchina che analizza provette azzurre',65),
  ('MO71','TC03','Macchina che analizza provette ocra',50),
  ('MR25','TC01','Macchina che analizza provette rosse',60),
  ('MV16','TC02','Macchina che analizza provette viola',70);

INSERT INTO Laboratorio VALUES
  ('LAB01','Prelievo1',1,'Stanza 4'),
  ('LAB02','Prelievo2',2,'Stanza 5');

INSERT INTO Dipendente VALUES
  ('IN007','Federico','Marchetti','MRCFDR93P12Z346X','M','1978-01-12','Milano','20100','Via Roma','44','Genova'),
  ('IN010','Sofia','Morelli','MRLSFZ80L08D123Y','F','1980-07-08','Ancona','60121','Via Verdi','85','Palermo'),
  ('ME001','Valentina','Ricci','RCCVNT87E05H987W','F','1971-10-17','Padova','35100','Via Dante','28','Venezia'),
  ('ME002','Alessandro','Ferrari','FRRLSN92T20Z123X','M','1969-10-10','Ancona','60100','Via Vittorio','45','Torino'),
  ('SE001','Alessia','Rossi','LSSRSS80H47F205F','F','1980-06-07','Milano','66032','Via delle Rose','123','Milano'),
  ('SE003','Chiara','Esposito','SPTCRA88D25B354L','F','1988-05-25','Ancona','60127','Via Garibaldi','91','Bari');

INSERT INTO Paziente VALUES
  ('CNTLCU87M15H234Y','Luca','Conti','M','2003-10-19','Palermo','90100','Via pane','37','Milano'),
  ('MRTFNC91M56G273Y','Francesca','Moretti','F','1991-01-05','Napoli','50100','Via Roma','78','Bologna'),
  ('PTTLSN03A22G141Q','Chiara','Moretti','F','2000-03-20','Firenze','50120','Via dei Fiori','78','Bologna'),
  ('RZZFBA88M01H234Y','Fabio','Rizzo','M','1997-01-05','Palermo','90100','Via genova','456','Catania'),
  ('SPTLCU88M01H234B','Luca','Esposito','M','1988-01-22','Ortona','80100','Via Roma','45','Palermo');

INSERT INTO Segretaria VALUES
  ('SE001','admin_1','Seg1!'),
  ('SE003','admin_2','Seg1?');

INSERT INTO Infermiere VALUES
  ('IN007','Pediatrico','LAB01'),
  ('IN010','Geriatria','LAB02');

INSERT INTO Medico VALUES
  ('ME001','Medicina interna'),
  ('ME002','Oncologia');

-- Qnt gia' coerente con la regola RD2: Qnt = (somma ordinata) - (somma usata)
INSERT INTO ProdottoSanitario VALUES
  ('GN01','Guanti',29),
  ('GN02','Guanti',29),
  ('GN03','Guanti',29),
  ('GN04','Guanti',50),
  ('LC01','Laccioemostatico',28),
  ('LC02','Laccioemostatico',29),
  ('PR01','Provetta',58),
  ('PR02','Provetta',32),
  ('PR03','Provetta',69),
  ('PR04','Provetta',77),
  ('ST01','Sistema aghi',78),
  ('ST02','Sistema aghi',69);

INSERT INTO Provetta VALUES
  ('PR01','Rosso','MR25'),
  ('PR02','Viola','MV16'),
  ('PR03','Azzurro','MA11'),
  ('PR04','Ocra','MO71');

INSERT INTO Guanti VALUES
  ('GN01','S'),('GN02','M'),('GN03','L'),('GN04','XL');

INSERT INTO LaccioEmostatico VALUES
  ('LC01',30),('LC02',22);

-- CORRETTO: i sistemi di aghi sono ST01/ST02 (non LC01/LC02)
INSERT INTO SistemaDiAghi VALUES
  ('ST01',0.3),('ST02',0.4);

INSERT INTO Esame VALUES
  ('90.05.1','Albumina',1.42,'%',55.80,66.10,'PR01'),
  ('90.05.4','Alfa 1 ANTITRIPSINA',5.30,'%',2.90,4.90,'PR01'),
  ('90.11.4','Calcio',5.00,'ng/mL',8.80,10.40,'PR01'),
  ('90.14.1','Colesterolo HDL',1.43,'mg/dl',40.00,60.00,'PR01'),
  ('90.14.2','Colesterolo LDL',0.67,'mg/dl',0.00,150.00,'PR01'),
  ('90.14.3','Colesterolo TOT',1.04,'mg/dl',0.00,200.00,'PR01'),
  ('90.22.3','Ferritina',6.36,'%',22.00,274.00,'PR01'),
  ('90.22.5','Ferro',1.14,'ng/mL',80.00,170.00,'PR03'),
  ('90.27.1','Glucosio',1.50,'mg/dl',70.00,99.00,'PR01'),
  ('90.29.1','Insulina',15.00,'micUl/ml',4.00,24.00,'PR04'),
  ('90.62.2.1','RBC (Globuli Rossi)',1.15,'*10^6/mmc',4.50,6.50,'PR02'),
  ('90.62.2.2','HGB (Emoglobina)',1.15,'g/dL',13.00,17.00,'PR02'),
  ('90.62.2.3','HCT (Ematocrito)',1.15,'%',40.00,54.00,'PR02'),
  ('90.62.2.4','MCV (volume globulare)',1.15,'fL',30.00,100.00,'PR02'),
  ('90.62.2.5','MCH (cont. Erit. Medio)',1.15,'pg',27.00,32.00,'PR02'),
  ('90.62.2.6','MHCH (Conc media HGB)',1.15,'g/dL',32.00,36.00,'PR02'),
  ('90.62.2.7','PLT (Piastine)',1.15,'*10^3/mmc',150.00,500.00,'PR02'),
  ('90.62.2.8','WBC (Globuli Bianchi)',1.15,'*10^3/µL',4.00,10.00,'PR02');

INSERT INTO Fornitore VALUES
  ('DLCFNC88M45H6734','Laura','02 917 632 321','Citta del porto','57000','Via della liberta','20','www.prodotti_lab.com',7),
  ('DLCFNC88M45H678Y','Francesca','02 987 654 321','Citta del saggio','23100','Via Roma','23','www.prodottisanitari.com',7),
  ('RSSLCA87M02H222B','Luca','02 123 456 789','Citta del Viaggio','45100','Via dell Avventura','10','www.provette.com',5);

INSERT INTO Ordine VALUES
  (1,'2023-02-23','RSSLCA87M02H222B'),
  (2,'2023-03-12','RSSLCA87M02H222B'),
  (3,'2023-03-03','DLCFNC88M45H678Y'),
  (4,'2023-03-24','RSSLCA87M02H222B'),
  (5,'2023-11-23','DLCFNC88M45H678Y'),
  (6,'2023-09-30','DLCFNC88M45H6734');

-- Prenotazioni con referto -> stato 'eseguita'
INSERT INTO Prenotazione VALUES
  (1,'MRTFNC91M56G273Y','eseguita','2023-10-11','2023-10-16',23.75,'SE001','LAB01'),
  (2,'RZZFBA88M01H234Y','eseguita','2023-11-02','2023-11-06',10.85,'SE001','LAB02'),
  (3,'CNTLCU87M15H234Y','eseguita','2023-11-03','2023-11-09', 8.96,'SE003','LAB01');

INSERT INTO Referto VALUES
  (1,'ME001','2023-12-11'),
  (2,'ME002','2023-12-11'),
  (3,'ME002','2023-12-11');

-- Esiti valorizzati (caricati il 10/12, referto firmato il 11/12)
INSERT INTO ElencazionePrenotazione VALUES
  (1,'90.05.4',    3.00,'2023-12-10'),
  (1,'90.29.1',    9.20,'2023-12-10'),
  (1,'90.62.2.1',  5.10,'2023-12-10'),
  (1,'90.62.2.2', 90.00,'2023-12-10'),
  (1,'90.62.2.5', 25.00,'2023-12-10'),
  (2,'90.14.3',  100.00,'2023-12-10'),
  (2,'90.22.3',  103.00,'2023-12-10'),
  (2,'90.62.2.1',  5.60,'2023-12-10'),
  (2,'90.62.2.2', 14.00,'2023-12-10'),
  (2,'90.62.2.7',280.00,'2023-12-10'),
  (3,'90.14.2',   80.00,'2023-12-10'),
  (3,'90.14.3',    9.20,'2023-12-10'),
  (3,'90.27.1',   90.00,'2023-12-10'),
  (3,'90.62.2.1',  5.15,'2023-12-10'),
  (3,'90.62.2.2',  5.50,'2023-12-10'),
  (3,'90.62.2.3', 50.00,'2023-12-10'),
  (3,'90.62.2.4',100.00,'2023-12-10'),
  (3,'90.62.2.6', 35.00,'2023-12-10');

INSERT INTO ElencazioneProdotti VALUES
  (1,'GN01',1),(1,'LC01',1),(1,'PR02',4),(1,'PR03',1),(1,'ST01',1),
  (2,'GN02',1),(2,'LC02',1),(2,'PR01',2),(2,'ST02',1),
  (3,'GN03',1),(3,'LC01',1),(3,'PR02',4),(3,'PR04',3),(3,'ST01',1);

INSERT INTO ElencazioneOrdine VALUES
  ('GN01',1,30),('GN02',1,30),('GN03',1,30),('GN04',3,50),
  ('LC01',1,30),('LC02',1,30),
  ('PR01',2,60),('PR02',2,40),('PR03',2,70),('PR04',2,80),
  ('ST01',3,80),('ST02',3,70);

INSERT INTO Tipologia VALUES
  ('Guanto'),('Laccio emostatico'),('Provetta'),('Sistema di aghi');

INSERT INTO Rifornimento VALUES
  ('Laccio emostatico','DLCFNC88M45H6734'),
  ('Provetta','DLCFNC88M45H6734'),
  ('Guanto','DLCFNC88M45H678Y'),
  ('Provetta','DLCFNC88M45H678Y'),
  ('Sistema di aghi','DLCFNC88M45H678Y'),
  ('Provetta','RSSLCA87M02H222B');

INSERT INTO Email VALUES
  ('elena.nero@emailservice.com','DLCFNC88M45H6734'),
  ('luca.giallo@examplemail.com','DLCFNC88M45H6734'),
  ('anna.verdi@samplemail.org','DLCFNC88M45H678Y'),
  ('marco.rossi@emailprovider.net','RSSLCA87M02H222B'),
  ('rla.bianchi@example.com','RSSLCA87M02H222B');

INSERT INTO TelefonoD VALUES
  ('3339876543','IN007'),
  ('2087654321','IN010'),
  ('5551234567','ME001'),
  ('6987654321','ME002'),
  ('9087654321','SE001'),
  ('3334567890','SE003');

INSERT INTO TelefonoF VALUES
  ('6789023345','DLCFNC88M45H6734'),
  ('3456789012','DLCFNC88M45H678Y'),
  ('1234567890','RSSLCA87M02H222B'),
  ('8901234567','RSSLCA87M02H222B');

-- Tabella ora popolata
INSERT INTO TelefonoP VALUES
  ('2310976548','CNTLCU87M15H234Y'),
  ('7621349805','CNTLCU87M15H234Y'),
  ('3456231789','MRTFNC91M56G273Y'),
  ('6790453128','PTTLSN03A22G141Q'),
  ('6452187039','RZZFBA88M01H234Y'),
  ('8945612073','SPTLCU88M01H234B');

SET FOREIGN_KEY_CHECKS = 1;

DELIMITER $$

-- ---- Importo prenotazione = somma dei prezzi degli esami prenotati ----

CREATE TRIGGER trg_importo_ai
AFTER INSERT ON ElencazionePrenotazione
FOR EACH ROW
BEGIN
  UPDATE Prenotazione
     SET Importo = (
       SELECT SUM(e.Prezzo)
         FROM ElencazionePrenotazione ep
         JOIN Esame e ON ep.CodEs = e.CodEs
        WHERE ep.Pren = NEW.Pren
     )
   WHERE N_Pren = NEW.Pren;
END$$

CREATE TRIGGER trg_importo_ad
AFTER DELETE ON ElencazionePrenotazione
FOR EACH ROW
BEGIN
  UPDATE Prenotazione
     SET Importo = (
       SELECT SUM(e.Prezzo)
         FROM ElencazionePrenotazione ep
         JOIN Esame e ON ep.CodEs = e.CodEs
        WHERE ep.Pren = OLD.Pren
     )
   WHERE N_Pren = OLD.Pren;
END$$

CREATE TRIGGER trg_importo_au
AFTER UPDATE ON ElencazionePrenotazione
FOR EACH ROW
BEGIN
  UPDATE Prenotazione
     SET Importo = (
       SELECT SUM(e.Prezzo)
         FROM ElencazionePrenotazione ep
         JOIN Esame e ON ep.CodEs = e.CodEs
        WHERE ep.Pren = NEW.Pren
     )
   WHERE N_Pren = NEW.Pren;
  IF NEW.Pren <> OLD.Pren THEN
    UPDATE Prenotazione
       SET Importo = (
         SELECT SUM(e.Prezzo)
           FROM ElencazionePrenotazione ep
           JOIN Esame e ON ep.CodEs = e.CodEs
          WHERE ep.Pren = OLD.Pren
       )
     WHERE N_Pren = OLD.Pren;
  END IF;
END$$

-- ---- Magazzino: +Qnt quando si ordina, -Qnt quando si consuma ----

CREATE TRIGGER trg_qnt_ordine_ai
AFTER INSERT ON ElencazioneOrdine
FOR EACH ROW
BEGIN
  UPDATE ProdottoSanitario
     SET Qnt = Qnt + NEW.Qnt
   WHERE CodProd = NEW.Prodotto;
END$$

CREATE TRIGGER trg_qnt_uso_ai
AFTER INSERT ON ElencazioneProdotti
FOR EACH ROW
BEGIN
  UPDATE ProdottoSanitario
     SET Qnt = Qnt - NEW.Qnt
   WHERE CodProd = NEW.Prod;
END$$

DELIMITER ;
