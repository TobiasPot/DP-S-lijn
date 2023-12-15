-- ------------------------------------------------------------------------
-- Data & Persistency
-- Opdracht S6: Views
--
-- (c) 2020 Hogeschool Utrecht
-- Tijmen Muller (tijmen.muller@hu.nl)
-- André Donk (andre.donk@hu.nl)
-- ------------------------------------------------------------------------


-- S6.1.
--
-- 1. Maak een view met de naam "deelnemers" waarmee je de volgende gegevens uit de tabellen inschrijvingen en uitvoering combineert:
--    inschrijvingen.cursist, inschrijvingen.cursus, inschrijvingen.begindatum, uitvoeringen.docent, uitvoeringen.locatie
	CREATE VIEW deelnemers AS
		SELECT i.cursist, i.cursus, i.begindatum, u.docent, u.locatie
		FROM inschrijvingen i
		LEFT JOIN uitvoeringen u
		ON i.cursus = u.cursus AND i.begindatum = u.begindatum
-- 2. Gebruik de view in een query waarbij je de "deelnemers" view combineert met de "personeels" view (behandeld in de les):
--     CREATE OR REPLACE VIEW personeel AS
-- 	     SELECT mnr, voorl, naam as medewerker, afd, functie
--       FROM medewerkers;
	SELECT d.cursist, d.cursus, d.begindatum,  p.medewerker AS docent, d.locatie
	FROM deelnemers d
	LEFT JOIN personeel p
	ON p.mnr = d.docent;

-- 3. Is de view "deelnemers" updatable ? Waarom ?
-- Nog niet omdat volgens de PGADMIN console: Views that do not select from a single table or view are not automatically updatable.



-- S6.2.
--
-- 1. Maak een view met de naam "dagcursussen". Deze view dient de gegevens op te halen: 
--      code, omschrijving en type uit de tabel curssussen met als voorwaarde dat de lengte = 1. Toon aan dat de view werkt. 
	CREATE VIEW dagcursussen AS
		SELECT code, omschrijving, type
		FROM cursussen
		WHERE lengte = 1;
-- 2. Maak een tweede view met de naam "daguitvoeringen". 
--    Deze view dient de uitvoeringsgegevens op te halen voor de "dagcurssussen" (gebruik ook de view "dagcursussen"). Toon aan dat de view werkt
	CREATE VIEW daguitvoeringen AS
		SELECT cursus, begindatum, docent, locatie
		FROM uitvoeringen
		WHERE cursus IN (
						SELECT code
						FROM dagcursussen
						);

-- 3. Verwijder de views en laat zien wat de verschillen zijn bij DROP view <viewnaam> CASCADE en bij DROP view <viewnaam> RESTRICT
	DROP view dagcursussen RESTRICT
	-- ERROR:  cannot drop view dagcursussen because other objects depend on it
	DROP view dagcursussen CASCADE
	-- NOTICE:  drop cascades to view daguitvoeringen. Deze dropt ook de view die de view gebruikt
