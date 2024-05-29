-- QUERY 1: Compagnie aeree con più di 77 voli
SELECT c.Nome AS CompagniaAerea, COUNT(v.NumeroVolo) AS NumeroVoli
FROM Volo v
JOIN CompagniaAerea c ON v.CompagniaICAO = c.ICAO
JOIN AssegnazioneEquipaggio ae ON v.NumeroVolo = ae.NumeroVolo AND v.DataOraPartenza = ae.DataVolo
JOIN Personale p ON ae.PersonaleID = p.ID
GROUP BY c.Nome
HAVING COUNT(v.NumeroVolo) > 77;


-- QUERY 2: Numero di passeggeri per volo
SELECT v.NumeroVolo, v.DataOraPartenza, COUNT(p.ID) AS NumeroPasseggeri
FROM Volo v
JOIN Prenotazione pr ON v.NumeroVolo = pr.NumeroVolo AND v.DataOraPartenza = pr.DataVolo
JOIN Passeggero p ON pr.PasseggeroID = p.ID
GROUP BY v.NumeroVolo, v.DataOraPartenza;



-- QUERY 3: Nomi e cognomi dei piloti che hanno pilotato un Airbus A380
SELECT p.Nome, p.Cognome
FROM Piloti pi
JOIN Personale p ON pi.ID = p.ID
JOIN AssegnazioneEquipaggio ae ON pi.ID = ae.PersonaleID
JOIN Volo v ON ae.NumeroVolo = v.NumeroVolo AND ae.DataVolo = v.DataOraPartenza
JOIN Aeromobile a ON v.AircraftID = a.ID
WHERE a.Modello = 'A380'
GROUP BY p.Nome, p.Cognome;


-- QUERY 4: Media delle entrate per ciascuna compagnia aerea
SELECT c.Nome AS CompagniaAerea, AVG(EntratePerVolo) AS MediaEntrate
FROM (
    SELECT v.CompagniaICAO, SUM(pr.Prezzo) AS EntratePerVolo
    FROM Volo v
    JOIN Prenotazione pr ON v.NumeroVolo = pr.NumeroVolo AND v.DataOraPartenza = pr.DataVolo
    GROUP BY v.CompagniaICAO, v.NumeroVolo, v.DataOraPartenza
) AS VoliCompagnia
JOIN CompagniaAerea c ON VoliCompagnia.CompagniaICAO = c.ICAO
GROUP BY c.Nome;


-- QUERY 5: Assistenti di volo che sono stati a venezia
SELECT DISTINCT p.Nome, p.Cognome
FROM AssistentiDiVolo adv
JOIN Personale p ON adv.ID = p.ID
JOIN AssegnazioneEquipaggio ae ON adv.ID = ae.PersonaleID
JOIN Volo v ON ae.NumeroVolo = v.NumeroVolo AND ae.DataVolo = v.DataOraPartenza
WHERE v.AeroportoPartenzaICAO = 'LIPZ' OR v.AeroportoArrivoICAO = 'LIPZ';



-- QUERY 2 CON INDICE SIGNIFICATIVO 
/*
    Motivazione:
    Nella Query 2, le colonne NumeroVolo e DataOraPartenza vengono utilizzate 
    frequentemente per i join e sono parte del GROUP BY. Creare un indice su queste 
    colonne nella tabella Prenotazione può migliorare significativamente le prestazioni
    delle operazioni di join e aggregazione.
*/

-- Creazione dell'indice: 
CREATE INDEX idx_prenotazione_volo
ON Prenotazione (NumeroVolo, DataVolo);

/*
    Effetti dell'indice:
    Velocizza i Join: Poiché i join tra le tabelle Volo e Prenotazione utilizzano le colonne NumeroVolo e DataVolo, l'indice consente al database di trovare rapidamente le righe corrispondenti.
    Ottimizza il Group By: Le operazioni di aggregazione nel GROUP BY beneficiano dell'ordine già presente nell'indice, rendendo più efficienti le scansioni e le aggregazioni dei dati.
    iduce il Tempo di Risposta: Le query che utilizzano queste colonne nei join e nei GROUP BY avranno tempi di risposta più rapidi, migliorando le prestazioni complessive del database.
*/