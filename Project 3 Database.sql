DROP DATABASE IF EXISTS Festival;
CREATE DATABASE Festival;
USE Festival;
SET FOREIGN_KEY_CHECKS = 0;

DROP TABLE IF EXISTS FestivalEdities;
CREATE TABLE FestivalEdities(
Id INT AUTO_INCREMENT PRIMARY KEY,
TitelEditie VARCHAR(45),
StartDatum DATE,
EindDatum DATE);

DROP TABLE IF EXISTS Artiesten;
CREATE TABLE Artiesten(
Id INT AUTO_INCREMENT PRIMARY KEY,
Naam VARCHAR(100),
GENRE ENUM("Hiphop", "Rap"),
Herkomst VARCHAR(2));

DROP TABLE IF EXISTS Songs;
CREATE TABLE Songs(
Id INT AUTO_INCREMENT PRIMARY KEY,
Titel VARCHAR(100),
Artiesten_Id INT,
CONSTRAINT fk_Songs_Artiesten
FOREIGN KEY (Artiesten_id) REFERENCES Artiesten(Id));

DROP TABLE IF EXISTS Cadeau;
CREATE TABLE Cadeau(
Id INT AUTO_INCREMENT PRIMARY KEY,
GepersonaliseerdeCadeau VARCHAR(50));
SET FOREIGN_KEY_CHECKS = 1;
 
DROP TABLE IF EXISTS DagIndelingen;
CREATE TABLE DagIndelingen(
StartOptreden DATETIME,
Id INT AUTO_INCREMENT PRIMARY KEY,
FestivalEdities_Id INT,
Artiesten_Id INT,
CONSTRAINT fk_DagIndeling_FestivalEdities 
FOREIGN KEY (FestivalEdities_Id) REFERENCES FestivalEdities(Id),
CONSTRAINT fk_DagIndeling_Artiesten
FOREIGN KEY (Artiesten_id) REFERENCES Artiesten(Id));

DROP TABLE IF EXISTS Sponsors;
CREATE TABLE Sponsors(
Id INT AUTO_INCREMENT PRIMARY KEY,
BedrijfsNaam VARCHAR(50),
HvlGeld INT,
VrWelkeArtiest VARCHAR(50),
Cadeau_Id INT,
CONSTRAINT fk_Sponsors_Cadeau
FOREIGN KEY (Cadeau_Id) REFERENCES Cadeau(Id));

INSERT INTO FestivalEdities (TitelEditie, StartDatum, EindDatum) 
VALUES 
('Festival 2024', '2024-06-01', '2024-06-03'),
('Festival 2023', '2023-05-01', '2023-05-03'),
('Festival 2022', '2022-06-10', '2022-06-12'),
('Festival 2021', '2021-07-01', '2021-07-03'),
('Festival 2020', '2020-08-01', '2020-08-03');
INSERT INTO Artiesten (Naam, GENRE, Herkomst) 
VALUES 
('Drake', 'Hiphop', 'CA'),
('Kanye West', 'Rap', 'VS'),
('Tyler, the Creator', 'Rap', 'VS'),
('Kendrick Lamar', 'Rap', 'VS'),
('Travis Scott', 'Hiphop', 'VS');
INSERT INTO Cadeau (GepersonaliseerdeCadeau)
VALUES 
('Macbook'),
('Fruitmand'),
('PS5'),
('Koekjes'),
('Iphone 15');
-- Aangepaste dagindelingen, unieke tijden voor "Hotline Bling" en "God's Plan"
INSERT INTO DagIndelingen (StartOptreden, FestivalEdities_Id, Artiesten_Id)
VALUES 
-- Festival 2024
('2024-06-01 14:00:00', 1, 1), -- Drake ("God's Plan" en "Hotling Bling" speelt hier)
('2024-06-01 16:00:00', 1, 2), -- Kanye West
('2024-06-01 18:00:00', 1, 3), -- Tyler, the Creator
('2024-06-02 16:00:00', 1, 4), -- Kendrick Lamar
-- Festival 2023
('2023-05-01 16:00:00', 2, 2), -- Kanye West speelt
('2023-05-01 18:00:00', 2, 4), -- Kendrick Lamar sluit de dag
-- Festival 2022
('2022-06-10 15:00:00', 3, 3), -- Tyler opent Festival 2022
('2022-06-11 15:00:00', 3, 2), -- Kanye West speelt op dag 2
-- Festival 2021
('2021-07-01 14:00:00', 4, 4), -- Kendrick opent Festival 2021
('2021-07-01 16:00:00', 4, 3), -- Tyler, the Creator volgt
('2021-07-01 18:00:00', 4, 2); -- Kanye West sluit de dag
-- Alle performances op chronologische volgorde met alle edities erbij weergegeven
-- met naam van de artiesten
-- Verandering van sponsor zodat function nut heeft
INSERT INTO Sponsors (BedrijfsNaam, HvlGeld, VrWelkeArtiest, Cadeau_Id)
VALUES 
('Nike', 500000, 'Drake', 1),    
('Adidas', 300000, 'Kanye West', 2), 
('Supreme', 200000, 'Tyler, the Creator', 3), 
('Reebok', 400000, 'Kendrick Lamar', 4),
('Nike', 250000, 'Travis Scott', 5);   -- ipv Puma hebben we nu Nike als sponsor voor Travis Scott
INSERT INTO Songs (Titel, Artiesten_Id)
VALUES 
("God's Plan", 1),  
('Stronger', 2),   
('EARFQUAKE', 3),    
('HUMBLE.', 4),
('Hotline Bling', 1);  
-- 1) Schrijf een view die een nuttig overzicht produceert op basis van gegevens uit minstens 3
-- tabellen in je database. Ik ga hier alle performances met elke tijdslot weergeven met de naam van de artiesten en de liedjes die ze gaan spelen.
DROP VIEW IF EXISTS alleperformances;
CREATE 
    ALGORITHM = UNDEFINED 
    DEFINER = `root`@`localhost` 
    SQL SECURITY DEFINER
VIEW `festival`.`alleperformances` AS
    SELECT 
        `festival`.`artiesten`.`Naam` AS `Performer`,
        `festival`.`songs`.`Titel` AS `Song`,
        IF((`festival`.`songs`.`Titel` = 'Gods Plan'),
            '2024-06-01 14:00:00',
            IF((`festival`.`songs`.`Titel` = 'Hotline Bling'),
                '2024-06-01 15:00:00',
                `festival`.`dagindelingen`.`StartOptreden`)) AS `Tijdslot`,
        `festival`.`festivaledities`.`TitelEditie` AS `Editie`
    FROM
        (((`festival`.`artiesten`
        LEFT JOIN `festival`.`songs` ON ((`festival`.`artiesten`.`Id` = `festival`.`songs`.`Artiesten_Id`)))
        LEFT JOIN `festival`.`dagindelingen` ON ((`festival`.`artiesten`.`Id` = `festival`.`dagindelingen`.`Artiesten_Id`)))
        LEFT JOIN `festival`.`festivaledities` ON ((`festival`.`dagindelingen`.`FestivalEdities_Id` = `festival`.`festivaledities`.`Id`)))
    WHERE
        (`festival`.`dagindelingen`.`StartOptreden` IS NOT NULL)
    ORDER BY `festival`.`dagindelingen`.`StartOptreden`;
-- 2) Schrijf een stored procedure die op een zinvolle manier gebruik maakt van minstens 1 van de
-- tabellen die je zelf definieerde in Deel 2 van de projectopgave. Je stored procedure moet
-- gebruikmaken van minstens 1 input-parameter. Laat je script volgen door een CALL-statement
-- dat voor een zinvolle uitvoering van je stored procedure zorgt.
-- Ik heb hier een procedure gemaakt die je toont wat elke artiest van z'n sponsor heeft gekregen als je z'n naam noteert
DROP PROCEDURE IF EXISTS WatKrijgtDezeArtiest;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `WatKrijgtDezeArtiest`(IN NaamArtiest VARCHAR (50))
BEGIN
SELECT VrWelkeArtiest AS "Artiest", GepersonaliseerdeCadeau AS "Cadeau"
FROM Sponsors
INNER JOIN cadeau
ON cadeau.Id = sponsors.Cadeau_id
WHERE VrWelkeArtiest LIKE CONCAT('%',NaamArtiest,'%');
END$$
DELIMITER ;
-- voorbeeld van een call
call festival.WatKrijgtDezeArtiest('Drake');
-- 3) Schrijf één stored procedure die manipulaties uitvoert op meer dan één tabel in de database.
-- Dat kunnen bv. twee INSERT’s op twee verschillende tabellen zijn, of twee UPDATE’s, of twee
-- DELETE’s, of een combinatie. Denk na over een mogelijke error die kan onstaan tijdens de
-- uitvoering van deze stored procedure, en voeg een gepaste error handler toe. Laat je script
-- volgen door een CALL-statement dat voor een zinvolle uitvoering van je stored procedure
-- zorgt.
-- Ik heb hier een procedure gemaakt die je toelaat om nieuwe artiesten toe te voegen aan een festival,
-- ook kan je de naam van een festival editie veranderen
DROP PROCEDURE IF EXISTS VoegArtiestToeEnVeranderFestivalNaam;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` PROCEDURE `VoegArtiestToeEnVeranderFestivalNaam`(
    IN NieuweArtiestNaam VARCHAR(100),
    IN ArtiestGenre ENUM("Hiphop", "Rap"),
    IN ArtiestHerkomst VARCHAR(2),
    IN FestivalId INT,
    IN NieuweEditie VARCHAR(45)
)
BEGIN
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        -- Bij een fout de transactie terugdraaien en een foutmelding weergeven
        ROLLBACK;
        SELECT 'Er is een fout opgetreden. Transactie is teruggedraaid.' AS Foutmelding;
    END;

    -- Start de transactie
    START TRANSACTION;

    -- Voeg een nieuwe artiest toe
    INSERT INTO Artiesten (Naam, GENRE, Herkomst)
    VALUES (NieuweArtiestNaam, ArtiestGenre, ArtiestHerkomst);

    -- Werk de titel van een specifieke editie bij
    UPDATE FestivalEdities
    SET TitelEditie = NieuweEditie
    WHERE Id = FestivalId;

    -- Commit de transactie als alles goed ging
    COMMIT;

    -- Succesbericht
    SELECT 'De transactie is succesvol uitgevoerd!' AS Succes;
END$$
DELIMITER ;
-- voorbeeld van een call
call festival.VoegArtiestToeEnVeranderFestivalNaam('Michael Jackson', 'Hiphop', 'VS', 3, 'Thriller Editie');
-- 4) Bedenk een nuttige functie die je als stored function kan toevoegen aan je databank. Je
-- functie moet minstens 1 parameter hebben. Laat je script volgen door een statement dat op
-- een zinvolle manier gebruik maakt van je functie.
-- Hier kun je het totale gesponsord geld bekijken van elke sponsor
DROP FUNCTION IF EXISTS BerekenTotaleSponsoring;
DELIMITER $$
CREATE DEFINER=`root`@`localhost` FUNCTION `BerekenTotaleSponsoring`(SponsorNaam VARCHAR(50)) RETURNS int
    DETERMINISTIC
BEGIN
    DECLARE TotaleSponsoring INT;

    -- Bereken de totale hoeveelheid geld gesponsord door de opgegeven sponsor
    SELECT SUM(HvlGeld)
    INTO TotaleSponsoring
    FROM Sponsors
    WHERE BedrijfsNaam = SponsorNaam;

    -- Als de sponsor niet bestaat, retourneer 0
    RETURN IFNULL(TotaleSponsoring, 0);
END$$
DELIMITER ;
-- voorbeeld van een select
select festival.BerekenTotaleSponsoring('Nike') AS "Totaal gesponsord geld van Nike";
