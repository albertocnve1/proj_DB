-- Creazione della tabella Aeroporto
CREATE TABLE Aeroporto (
    ICAO CHAR(4) NOT NULL PRIMARY KEY,
    IATA CHAR(3) NOT NULL,
    Nome VARCHAR(100) NOT NULL,
    Città VARCHAR(100) NOT NULL,
    Stato VARCHAR(100) NOT NULL
);

-- Creazione della tabella CompagniaAerea
CREATE TABLE CompagniaAerea (
    ICAO CHAR(4) NOT NULL PRIMARY KEY,
    IATA CHAR(3) NOT NULL,
    Nome VARCHAR(100) NOT NULL,
    Stato VARCHAR(100)
);

-- Creazione della tabella Aeromobile
CREATE TABLE Aeromobile (
    ID VARCHAR(6) NOT NULL PRIMARY KEY,
    Modello VARCHAR(50) NOT NULL,
    Costruttore VARCHAR(50) NOT NULL,
    Capacità INT,
    CompagniaICAO CHAR(4) NOT NULL,
    FOREIGN KEY (CompagniaICAO) REFERENCES CompagniaAerea(ICAO)
);

-- Creazione della tabella Gate
CREATE TABLE Gate (
    AeroportoICAO CHAR(4) NOT NULL,
    Terminal VARCHAR(10) NOT NULL,
    Numero INT NOT NULL,
    PRIMARY KEY (AeroportoICAO, Terminal, Numero),
    FOREIGN KEY (AeroportoICAO) REFERENCES Aeroporto(ICAO)
);

-- Creazione della tabella Passeggero
CREATE TABLE Passeggero (
    ID INT NOT NULL PRIMARY KEY,
    Nome VARCHAR(100),
    Cognome VARCHAR(100),
    Nazionalità VARCHAR(50),
    DataDiNascita DATE
);

-- Creazione della tabella Volo
CREATE TABLE Volo (
    NumeroVolo VARCHAR(255) NOT NULL,
    DataOraPartenza TIMESTAMP NOT NULL,
    DataOraArrivo TIMESTAMP NOT NULL,
    AeroportoPartenzaICAO CHAR(4) NOT NULL,
    AeroportoArrivoICAO CHAR(4) NOT NULL,
    CompagniaICAO CHAR(4) NOT NULL,
    AircraftID VARCHAR(6) NOT NULL,
    TerminalPartenza VARCHAR(10),
    NumeroGatePartenza INT NOT NULL,
    TerminalArrivo VARCHAR(10),
    NumeroGateArrivo INT NOT NULL,
    PRIMARY KEY (NumeroVolo, DataOraPartenza),
    FOREIGN KEY (AeroportoPartenzaICAO) REFERENCES Aeroporto(ICAO),
    FOREIGN KEY (AeroportoArrivoICAO) REFERENCES Aeroporto(ICAO),
    FOREIGN KEY (CompagniaICAO) REFERENCES CompagniaAerea(ICAO),
    FOREIGN KEY (AircraftID) REFERENCES Aeromobile(ID),
    FOREIGN KEY (AeroportoPartenzaICAO, TerminalPartenza, NumeroGatePartenza) REFERENCES Gate(AeroportoICAO, Terminal, Numero),
    FOREIGN KEY (AeroportoArrivoICAO, TerminalArrivo, NumeroGateArrivo) REFERENCES Gate(AeroportoICAO, Terminal, Numero)
);

-- Creazione della tabella Prenotazione
CREATE TABLE Prenotazione (
    Numero VARCHAR(50) NOT NULL PRIMARY KEY,
    PasseggeroID INT,
    NumeroVolo VARCHAR(255) NOT NULL,
    DataVolo TIMESTAMP NOT NULL,
    Classe VARCHAR(10),
    Prezzo DECIMAL(10, 2),
    FOREIGN KEY (PasseggeroID) REFERENCES Passeggero(ID),
    FOREIGN KEY (NumeroVolo, DataVolo) REFERENCES Volo(NumeroVolo, DataOraPartenza)
);

-- Creazione della tabella Personale
CREATE TABLE Personale (
    ID INT NOT NULL PRIMARY KEY,
    Nome VARCHAR(100) NOT NULL,
    Cognome VARCHAR(100) NOT NULL,
    CompagniaICAO CHAR(4) NOT NULL,
    FOREIGN KEY (CompagniaICAO) REFERENCES CompagniaAerea(ICAO)
);

-- Creazione della tabella Piloti
CREATE TABLE Piloti (
    ID INT NOT NULL PRIMARY KEY,
    Ruolo VARCHAR(50) NOT NULL,
    FOREIGN KEY (ID) REFERENCES Personale(ID)
);

-- Creazione della tabella AssistentiDiVolo
CREATE TABLE AssistentiDiVolo (
    ID INT NOT NULL PRIMARY KEY,
    Anzianità INT,
    FOREIGN KEY (ID) REFERENCES Personale(ID)
);

-- Creazione della tabella AssegnazioneEquipaggio con chiave primaria composta
CREATE TABLE AssegnazioneEquipaggio (
    DataVolo TIMESTAMP NOT NULL,
    NumeroVolo VARCHAR(255) NOT NULL,
    PersonaleID INT NOT NULL,
    PRIMARY KEY (DataVolo, NumeroVolo, PersonaleID),
    FOREIGN KEY (NumeroVolo, DataVolo) REFERENCES Volo(NumeroVolo, DataOraPartenza),
    FOREIGN KEY (PersonaleID) REFERENCES Personale(ID)
);
