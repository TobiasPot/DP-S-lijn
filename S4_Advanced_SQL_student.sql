-- ------------------------------------------------------------------------
-- Data & Persistency
-- Opdracht S4: Advanced SQL
--
-- (c) 2020 Hogeschool Utrecht
-- Tijmen Muller (tijmen.muller@hu.nl)
-- André Donk (andre.donk@hu.nl)
-- 
--
-- Opdracht: schrijf SQL-queries om onderstaande resultaten op te vragen,
-- aan te maken, verwijderen of aan te passen in de database van de
-- bedrijfscasus.
--
-- Codeer je uitwerking onder de regel 'DROP VIEW ...' (bij een SELECT)
-- of boven de regel 'ON CONFLICT DO NOTHING;' (bij een INSERT)
-- Je kunt deze eigen query selecteren en los uitvoeren, en wijzigen tot
-- je tevreden bent.

-- Vervolgens kun je je uitwerkingen testen door de testregels
-- (met [TEST] erachter) te activeren (haal hiervoor de commentaartekens
-- weg) en vervolgens het hele bestand uit te voeren. Hiervoor moet je de
-- testsuite in de database hebben geladen (bedrijf_postgresql_test.sql).
-- NB: niet alle opdrachten hebben testregels.
--
-- Lever je werk pas in op Canvas als alle tests slagen.
-- ------------------------------------------------------------------------


-- S4.1. 
-- Geef nummer, functie en geboortedatum van alle medewerkers die vóór 1980
-- geboren zijn, en trainer of verkoper zijn.
-- DROP VIEW IF EXISTS s4_1; CREATE OR REPLACE VIEW s4_1 AS                                                     -- [TEST]

	SELECT mnr, functie, gbdatum
	FROM medewerkers 
	WHERE EXTRACT(YEAR FROM gbdatum) < 1980 AND (functie = 'TRAINER' OR functie = 'VERKOPER');

-- S4.2. 
-- Geef de naam van de medewerkers met een tussenvoegsel (b.v. 'van der').
-- DROP VIEW IF EXISTS s4_2; CREATE OR REPLACE VIEW s4_2 AS                                                     -- [TEST]
	SELECT naam
	FROM medewerkers
	WHERE naam like '% %';

-- S4.3. 
-- Geef nu code, begindatum en aantal inschrijvingen (`aantal_inschrijvingen`) van alle
-- cursusuitvoeringen in 2019 met minstens drie inschrijvingen.
-- DROP VIEW IF EXISTS s4_3; CREATE OR REPLACE VIEW s4_3 AS                                                     -- [TEST]
	SELECT u.cursus, u.begindatum, aantal_inschrijvingen
	FROM uitvoeringen u
	JOIN(
		SELECT cursus, COUNT(*) AS aantal_inschrijvingen
	    FROM inschrijvingen i
	    GROUP BY cursus
	)
	i on u.cursus = i.cursus
	WHERE aantal_inschrijvingen >= 3 AND EXTRACT(YEAR FROM u.begindatum) = 2019;

-- S4.4. 
-- Welke medewerkers hebben een bepaalde cursus meer dan één keer gevolgd?
-- Geef medewerkernummer en cursuscode.
-- DROP VIEW IF EXISTS s4_4; CREATE OR REPLACE VIEW s4_4 AS                                                     -- [TEST]
    SELECT i.cursist, i.cursus
    FROM inschrijvingen i
    GROUP BY i.cursist, i.cursus
    HAVING COUNT(*) > 1

-- S4.5. 
-- Hoeveel uitvoeringen (`aantal`) zijn er gepland per cursus?
-- Een voorbeeld van het mogelijke resultaat staat hieronder.
--
--   cursus | aantal   
--  --------+-----------
--   ERM    | 1 
--   JAV    | 4 
--   OAG    | 2 
-- DROP VIEW IF EXISTS s4_5; CREATE OR REPLACE VIEW s4_5 AS                                                     -- [TEST]
	SELECT u.cursus, COUNT(*) AS aantal_uitvoeringen
	FROM uitvoeringen u
	GROUP BY u.cursus

-- S4.6. 
-- Bepaal hoeveel jaar leeftijdsverschil er zit tussen de oudste en de 
-- jongste medewerker (`verschil`) en bepaal de gemiddelde leeftijd van
-- de medewerkers (`gemiddeld`).
-- Je mag hierbij aannemen dat elk jaar 365 dagen heeft.
-- DROP VIEW IF EXISTS s4_6; CREATE OR REPLACE VIEW s4_6 AS                                                     -- [TEST]
WITH leeftijds_verschil AS(
  SELECT
    EXTRACT(EPOCH FROM age(current_date, MIN(gbdatum))) / 60 / 60 / 24 / 365 AS jongste_mdw_leeftijd,
    EXTRACT(EPOCH FROM age(current_date, MAX(gbdatum))) / 60 / 60 / 24 / 365 AS oudste_mdw_leeftijd,
    AVG(EXTRACT(EPOCH FROM age(current_date, gbdatum)) / 60 / 60 / 24 / 365) AS gemiddelde_mdw_leeftijd
  FROM
    medewerkers
)

SELECT
	FLOOR(jongste_mdw_leeftijd) AS jongste_mdw,
	FLOOR(oudste_mdw_leeftijd) AS oudste_mdw,
	FLOOR((jongste_mdw_leeftijd - oudste_mdw_leeftijd)) AS verschil,
	FLOOR(gemiddelde_mdw_leeftijd) AS gemiddeld
FROM
  leeftijds_verschil;


-- S4.7. 
-- Geef van het hele bedrijf een overzicht van het aantal medewerkers dat
-- er werkt (`aantal_medewerkers`), de gemiddelde commissie die ze
-- krijgen (`commissie_medewerkers`), en hoeveel dat gemiddeld
-- per verkoper is (`commissie_verkopers`).
-- DROP VIEW IF EXISTS s4_7; CREATE OR REPLACE VIEW s4_7 AS                                                     -- [TEST]
WITH medewerkers_data AS(
SELECT
	COUNT(*) AS aantal_medewerkers,
	AVG(comm) AS commissie_medewerkers,
	AVG(CASE WHEN functie = 'VERKOPER' THEN comm ELSE NULL END) AS commissie_verkopers
FROM medewerkers
)
SELECT aantal_medewerkers, commissie_medewerkers, commissie_verkopers
FROM medewerkers_data;


-- -------------------------[ HU TESTRAAMWERK ]--------------------------------
-- Met onderstaande query kun je je code testen. Zie bovenaan dit bestand
-- voor uitleg.

SELECT * FROM test_select('S4.1') AS resultaat
UNION
SELECT * FROM test_select('S4.2') AS resultaat
UNION
SELECT * FROM test_select('S4.3') AS resultaat
UNION
SELECT * FROM test_select('S4.4') AS resultaat
UNION
SELECT * FROM test_select('S4.5') AS resultaat
UNION
SELECT 'S4.6 wordt niet getest: geen test mogelijk.' AS resultaat
UNION
SELECT * FROM test_select('S4.7') AS resultaat
ORDER BY resultaat;


