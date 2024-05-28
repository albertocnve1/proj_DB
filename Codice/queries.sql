-- QUERY 1: Numero totale di passeggeri ospitati da ciascuna compagnia aerea
SELECT 
    ca.Nome AS CompagniaAerea,
    COUNT(p.PasseggeroID) AS NumeroTotalePasseggeri
FROM 
    CompagnieAeree ca
JOIN 
    Voli v ON ca.AirlineID = v.CompagniaAereaID
JOIN 
    Prenotazioni pr ON v.FlightID = pr.FlightID
JOIN 
    Passeggeri p ON pr.PasseggeroID = p.PasseggeroID
GROUP BY 
    ca.Nome
ORDER BY 
    NumeroTotalePasseggeri DESC;


-- QUERY 2:  Piloti che hanno pilotato un Airbus A380
SELECT 
    p.Nome, 
    p.Cognome, 
    pt.OreDiVolo,
    pt.Ruolo
FROM 
    Personale p
JOIN 
    Piloti pt ON p.ID = pt.ID
JOIN 
    AssegnazioneEquipaggio ae ON p.ID = ae.CrewID
JOIN 
    Voli v ON ae.FlightID = v.FlightID
JOIN 
    Aerei a ON v.AircraftID = a.AircraftID
WHERE 
    a.Modello = 'Airbus A380'
GROUP BY 
    p.Nome, 
    p.Cognome, 
    pt.OreDiVolo, 
    pt.Ruolo
ORDER BY 
    p.Cognome, 
    p.Nome;



-- QUERY 3:  Assistenti di volo che si sono imbarcati su un Boeing 787 da Malpensa
SELECT 
    adf.ID AS AssistenteDiVoloID,
    p.Nome,
    p.Cognome
FROM 
    AssistentiDiVolo adf
JOIN 
    Personale p ON adf.ID = p.ID
JOIN 
    AssegnazioneEquipaggio ae ON adf.ID = ae.CrewID
JOIN 
    Voli v ON ae.FlightID = v.FlightID
JOIN 
    Aerei a ON v.AircraftID = a.AircraftID
JOIN 
    Aeroporti ap ON v.AeroportoPartenzaID = ap.AirportID
WHERE 
    a.Modello = 'Boeing 787'
    AND ap.Nome = 'Aeroporto di Milano-Malpensa';





-- QUERY 4: Numero di passeggeri per ogni volo, mostrando solo i voli con almeno 5 passeggeri
SELECT 
    v.NumeroVolo, 
    COUNT(pr.PasseggeroID) AS NumeroPasseggeri
FROM 
    Voli v
JOIN 
    Prenotazioni pr ON v.FlightID = pr.FlightID
GROUP BY 
    v.NumeroVolo
HAVING 
    COUNT(pr.PasseggeroID) >= 5
ORDER BY 
    NumeroPasseggeri DESC;





-- QUERY 5: Numero di assistenti di volo per compagnia aerea
SELECT 
    ca.Nome AS CompagniaAerea, 
    COUNT(ad.ID) AS NumeroAssistentiDiVolo
FROM 
    AssistentiDiVolo ad
JOIN 
    Personale p ON ad.ID = p.ID
JOIN 
    CompagnieAeree ca ON p.CompagniaAereaID = ca.AirlineID
GROUP BY 
    ca.Nome
ORDER BY 
    NumeroAssistentiDiVolo DESC;


