-- ------------------------------------------------------------------------
-- Data & Persistency
-- Opdracht S9: Aanvullende herkansingsopdracht
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
--
-- Vervolgens kun je je uitwerkingen testen door de testregels
-- (met [TEST] erachter) te activeren (haal hiervoor de commentaartekens
-- weg) en vervolgens het hele bestand uit te voeren. Hiervoor moet je de
-- testsuite in de database hebben geladen (bedrijf_postgresql_test.sql).
-- NB: niet alle opdrachten hebben testregels.
--
-- Lever je werk pas in op Canvas als alle tests slagen.
-- ------------------------------------------------------------------------


-- S9.1  Overstap
--
-- Jan-Jaap den Draaier is per 1 oktober 2020 manager van personeelszaken.
-- Hij komt direct onder de directeur te vallen en gaat 2100 euro per
-- maand verdienen.
-- Voer alle queries uit om deze wijziging door te voeren.
	INSERT INTO medewerkers (mnr, naam, voorl, functie, chef, gbdatum, maandsal, afd)
	VALUES (8003, 'DEN DRAAIER', 'J', 'MANAGER', 7839, '1997-12-22', 2100, 40)
	ON CONFLICT DO NOTHING;                                                                                         -- [TEST]


-- S9.2  Beginjaar
--
-- Voeg een beperkingsregel `h_beginjaar_chk` toe aan de historietabel
-- die controleert of een ingevoerde waarde in de kolom `beginjaar` een
-- correcte waarde heeft, met andere woorden: dat het om het huidige jaar
-- gaat of een jaar dat in het verleden ligt.
-- Test je beperkingsregel daarna met een INSERT die deze regel schendt.
	ALTER TABLE historie
	ADD CONSTRAINT h_beginjaar_chk
	CHECK (
	    beginjaar = EXTRACT(YEAR FROM CURRENT_DATE)
	);

-- S9.3  Opmerkingen
--
-- Geef uit de historietabel alle niet-lege opmerkingen bij de huidige posities
-- van medewerkers binnen het bedrijf. Geef ter referentie ook het medewerkersnummer
-- bij de resultaten.
-- DROP VIEW IF EXISTS s9_3; CREATE OR REPLACE VIEW s9_3 AS                                                     -- [TEST]
	SELECT mnr, opmerkingen
	FROM historie
	WHERE LENGTH(opmerkingen) >= 1;

-- S9.4  Carrièrepad
--
-- Toon van alle medewerkers die nú op het hoofdkantoor werken hun historie
-- binnen het bedrijf: geef van elke positie die ze bekleed hebben de
-- de naam van de medewerker, de begindatum, de naam van hun afdeling op dat
-- moment (`afdeling`) en hun toenmalige salarisschaal (`schaal`).
-- Sorteer eerst op naam en dan op ingangsdatum.
-- DROP VIEW IF EXISTS s9_4; CREATE OR REPLACE VIEW s9_4 AS                                                     -- [TEST]
	SELECT * FROM (
			SELECT a.naam AS afdeling_naam, sub.einddatum, sub.begindatum, m.naam, m.functie
			FROM (
				SELECT mnr, afd, begindatum, einddatum
				FROM historie  
				WHERE mnr IN(
					SELECT mnr
					FROM medewerkers 
					WHERE afd IN(
						SELECT anr 
						FROM afdelingen 
						WHERE naam = 'HOOFDKANTOOR'
				)
			)
		) AS sub
		INNER JOIN medewerkers m
		ON sub.mnr = m.mnr
		INNER JOIN afdelingen a
		ON sub.afd = a.anr
		GROUP BY m.functie, a.naam, sub.afd, sub.mnr, m.naam, sub.begindatum, sub.einddatum, afdeling_naam
	)
	WHERE einddatum IS NOT NULL
	ORDER BY naam, begindatum ASC;



-- S9.5 Aanloop
--
-- Toon voor elke medewerker de naam en hoelang zij in andere functies hebben
-- gewerkt voordat zij op hun huidige positie kwamen (`tijdsduur`).
-- Rond naar beneden af op gehele jaren.
-- DROP VIEW IF EXISTS s9_5; CREATE OR REPLACE VIEW s9_5 AS                                                     -- [TEST]
	SELECT m.naam, sub.tijdsduur_jaar_andere_functies
	FROM (
		SELECT mnr, SUM(((einddatum - begindatum) / 365)) AS tijdsduur_jaar_andere_functies
		FROM historie
		WHERE einddatum IS NOT NULL
		GROUP BY mnr
	) AS sub
	JOIN medewerkers m ON sub.mnr = m.mnr
	ORDER BY m.naam ASC;

-- S9.6 Index
--
-- Maak een index `historie_afd_idx` op afdelingsnummer in de historietabel.



-- -------------------------[ HU TESTRAAMWERK ]--------------------------------
-- Met onderstaande query kun je je code testen. Zie bovenaan dit bestand
-- voor uitleg.

SELECT * FROM test_exists('S9.1', 1) AS resultaat
UNION
SELECT 'S9.2 wordt niet getest: zelf handmatig testen.' AS resultaat
UNION
SELECT * FROM test_select('S9.3') AS resultaat
UNION
SELECT * FROM test_select('S9.4') AS resultaat
UNION
SELECT * FROM test_select('S9.5') AS resultaat
UNION
SELECT 'S9.6 wordt niet getest: geen test mogelijk.' AS resultaat
ORDER BY resultaat;
