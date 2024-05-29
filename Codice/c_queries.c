#include <stdio.h>
#include <stdlib.h>
#include <string.h>
#include <libpq-fe.h>

#define PG_HOST    "localhost"
#define PG_USER    "albertocanavese"
#define PG_DB      "plane_manager"
#define PG_PASS    ""
#define PG_PORT    5432

void checkCommand(PGresult *res, const PGconn *conn) {
    if (PQresultStatus(res) != PGRES_COMMAND_OK) {
        printf("Comando fallito %s\n", PQerrorMessage(conn));
        PQclear(res);
        exit(1);
    }
}

void checkResults(PGresult *res, const PGconn *conn) {
    if (PQresultStatus(res) != PGRES_TUPLES_OK) {
        printf("Risultati inconsistenti %s\n", PQerrorMessage(conn));
        PQclear(res);
        exit(1);
    }
}

void execute_and_print_query(PGconn *conn, const char *query) {
    PGresult *res;
    int nFields;
    int i, j;

    // Esegui la query
    res = PQexec(conn, query);
    checkResults(res, conn);

    // Ottieni il numero di campi nella query
    nFields = PQnfields(res);

    // Stampa i nomi delle colonne
    for (i = 0; i < nFields; i++) {
        printf("%-25s", PQfname(res, i));
    }
    printf("\n");

    // Stampa i valori delle righe
    for (i = 0; i < PQntuples(res); i++) {
        for (j = 0; j < nFields; j++) {
            printf("%-25s", PQgetvalue(res, i, j));
        }
        printf("\n");
    }

    // Pulisci i risultati
    PQclear(res);
}

int main() {
    char conninfo[500];
    sprintf(conninfo, "postgresql://%s:%s@%s:%d/%s", PG_USER, PG_PASS, PG_HOST, PG_PORT, PG_DB);

    // Eseguo la connessione al database
    PGconn *conn;
    conn = PQconnectdb(conninfo);

    // Verifico lo stato di connessione
    if (PQstatus(conn) != CONNECTION_OK) {
        printf("Errore di connessione: %s\n", PQerrorMessage(conn));
        PQfinish(conn);
        exit(1);
    }

    // Query 1: Compagnie aeree con più di 77 voli
    const char *query1 = "SELECT c.Nome AS CompagniaAerea, COUNT(v.NumeroVolo) AS NumeroVoli "
                         "FROM Volo v "
                         "JOIN CompagniaAerea c ON v.CompagniaICAO = c.ICAO "
                         "JOIN AssegnazioneEquipaggio ae ON v.NumeroVolo = ae.NumeroVolo AND v.DataOraPartenza = ae.DataVolo "
                         "JOIN Personale p ON ae.PersonaleID = p.ID "
                         "GROUP BY c.Nome "
                         "HAVING COUNT(v.NumeroVolo) > 77;";
    printf("Query 1:\n");
    execute_and_print_query(conn, query1);

    // Query 2: Numero di passeggeri per volo
    const char *query2 = "SELECT v.NumeroVolo, v.DataOraPartenza, COUNT(p.ID) AS NumeroPasseggeri "
                         "FROM Volo v "
                         "JOIN Prenotazione pr ON v.NumeroVolo = pr.NumeroVolo AND v.DataOraPartenza = pr.DataVolo "
                         "JOIN Passeggero p ON pr.PasseggeroID = p.ID "
                         "GROUP BY v.NumeroVolo, v.DataOraPartenza;";
    printf("\nQuery 2:\n");
    execute_and_print_query(conn, query2);

    // Query 3: Nomi e cognomi dei piloti che hanno pilotato un Airbus A320
    const char *query3 = "SELECT p.Nome, p.Cognome "
                         "FROM Piloti pi "
                         "JOIN Personale p ON pi.ID = p.ID "
                         "JOIN AssegnazioneEquipaggio ae ON pi.ID = ae.PersonaleID "
                         "JOIN Volo v ON ae.NumeroVolo = v.NumeroVolo AND ae.DataVolo = v.DataOraPartenza "
                         "JOIN Aeromobile a ON v.AircraftID = a.ID "
                         "WHERE a.Modello = 'A320' "
                         "GROUP BY p.Nome, p.Cognome;";
    printf("\nQuery 3:\n");
    execute_and_print_query(conn, query3);

    // Query 4: Media delle entrate per ciascuna compagnia aerea
    const char *query4 = "SELECT c.Nome AS CompagniaAerea, AVG(EntratePerVolo) AS MediaEntrate "
                         "FROM ( "
                         "    SELECT v.CompagniaICAO, SUM(pr.Prezzo) AS EntratePerVolo "
                         "    FROM Volo v "
                         "    JOIN Prenotazione pr ON v.NumeroVolo = pr.NumeroVolo AND v.DataOraPartenza = pr.DataVolo "
                         "    GROUP BY v.CompagniaICAO, v.NumeroVolo, v.DataOraPartenza "
                         ") AS VoliCompagnia "
                         "JOIN CompagniaAerea c ON VoliCompagnia.CompagniaICAO = c.ICAO "
                         "GROUP BY c.Nome;";
    printf("\nQuery 4:\n");
    execute_and_print_query(conn, query4);

    // Query 5: Assistenti di volo che sono stati a Venezia
    const char *query5 = "SELECT DISTINCT p.Nome, p.Cognome "
                         "FROM AssistentiDiVolo adv "
                         "JOIN Personale p ON adv.ID = p.ID "
                         "JOIN AssegnazioneEquipaggio ae ON adv.ID = ae.PersonaleID "
                         "JOIN Volo v ON ae.NumeroVolo = v.NumeroVolo AND ae.DataVolo = v.DataOraPartenza "
                         "WHERE v.AeroportoPartenzaICAO = 'LIPZ' OR v.AeroportoArrivoICAO = 'LIPZ';";
    printf("\nQuery 5:\n");
    execute_and_print_query(conn, query5);

    PQfinish(conn);
    return 0;
}
