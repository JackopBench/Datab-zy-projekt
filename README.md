# Databázové technológie - semestrálny projekt

## 1. Úvod a popis zdrojových dát
Cieľom semestrálneho projektu je analyzovať dáta reprezentujúce predaj digitálnej hudby, ktoré zachytávajú informácie o skladbách, albumoch, interpretoch, zákazníkoch, zamestnancoch a faktúrach.
Projekt sa zameriava na sledovanie najpopulárnejšej pesničiek, interpretov a taktiež žánrov. Ťaktiež porovnáva cenové úrovne skladieb a ich predajnosť, pričom identifikuje trendy v preferenciách zákazníkov.

### Databáza Chinook pozostáva z nasledujúcich tabuliek:
* Artist - obsahuje mená interpretov
* Album - zaznamenáva informácie o albumoch a ich interpretoch
* Track - uchováva informácie o skladbách
* Genre - obsahuje rôzne hudobné žánre
* MediaType - zaznamenáva typ médií, v ktorých sú skladby uložené
* Playlist - uchováva zoznam skladieb
* PlaylistTrack - prepája skladby s playlistmi
* Customer - uchováva informácie o zákazníkoch
* Employee - obsahuje údaje o zamestnancoch
* Invoice - uchováva informácie o faktúrach vystavených zákazníkom
* InvoiceLine - obsahuje jednotlivé položky na faktúrach, teda zakúpené skladby


### ERD diagram pôvodných, zdrojových dát:

![Chinook_ERD (3)](https://github.com/user-attachments/assets/4cfcd804-1932-4987-982f-7472a1a30d80)

## 2. Multi-dimenzionálny model
Multidimenzionálny model sa používa na organizovanie a analýzu dát v dátových skladoch, pričom umožňuje zobraziť dáta z rôznych perspektív (dimenzií). Tento model je ideálny pre analýzu a reportovanie, 
pretože zjednodušuje analýzu dát, zrýchľuje dotazy a je flexibilný. Skladá sa z centrálnej tabuľky a jej dimenzií (dimenzionálne tabuľky).

Môj navrhnutý multi-dimenzionálny (hviezdicový) model sa skladá z centrálnej tabulky Fact_Sales a z nasledujúcih dimenzionálnych tabuliek:
* Dim_Artist - obsahuje mená interpretov
* Dim_Date - obsahuje informácie o dátume (rok, mesiac, deň, štvrťrok)
* Dim_Genre - obsahuje názvy žánrov
* Dim_Customer - obsahuje informácie o zákazníkoch
* Dim_Album - obsahuje názov albumu a informáciu o interpretovi, ktorému patrí
* Dim_Track - obsahuje všetky informácie o jednotlivých pesničkách

Štruktúra hviezdicového modelu je znázornená na diagrame nižšie:
![ssss](https://github.com/user-attachments/assets/1db4ed3c-173a-4007-89d2-e5bb5a8c1397)


## 3. ETL proces v Snowflake
Tento proces bol implementovaný v Snowflake s cieľom pripraviť zdrojové dáta zo staging vrstvy do viacdimenzionálneho modelu vhodného na analýzu a vizualizáciu.

### V prvom kroku som nahral pôvodné dáta vo formáte csv. do interného stage úložiska, ktoré som vytvoril príkazom:

CREATE STAGE my_stage;

### Následne som vytvoril jednotlivé tabuľky(zatiaľ neobsahujú žiadne dáta)

Príklad príkazu, ktorý som použil na tvorbu tabuľky Track:  
CREATE TABLE Track (  
    TrackId INT PRIMARY KEY,  
    Name STRING,  
    AlbumId INT,  
    MediaTypeId INT,  
    GenreId INT,  
    Composer STRING,  
    Milliseconds INT,  
    Bytes INT,  
    UnitPrice DECIMAL(10, 2)  
);  

Týmto spôsobom som vytvoril aj zvyšné tabuľky.

### V ďaľšom kroku som pomocou príkazu uvedeného nižšie vytvoril súborový formát s názvom my_file_format, ktorý slúži na importovanie dát vo forme CSV.

CREATE FILE FORMAT my_file_format 
    TYPE = 'CSV'
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'
    SKIP_HEADER = 1
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE;

### Následne som importoval dáta do staging tabuliek pomocou nasledujúceho príkazu:

COPY INTO (názov tabulky)
    FROM @my_stage/(názov csv. súboru)
    FILE_FORMAT = (FORMAT_NAME = my_file_format);

Takto som importoval dáta z csv. súboru postupne do každej tabuľky.

### Teraz, keď už mám vytvorené tabuľky, ktoré obsahujú pôvodné dáta, tak som začal vytvárať multi-dimenzionálny model.
### Prvý krok je vytvoriť dimenzionálne tabuľky. Uvediem príkaz pre tvorbu každej tabuľky zvlášť:

Prvá dimenzia bola vytvorená týmto príkazom:

CREATE TABLE Dim_Date AS
SELECT DISTINCT
    DATEDIFF(DAY, '1970-01-01', i.InvoiceDate) AS DateKey,
    i.InvoiceDate AS FullDate,
    EXTRACT(YEAR FROM i.InvoiceDate) AS Year,
    EXTRACT(MONTH FROM i.InvoiceDate) AS Month,
    EXTRACT(DAY FROM i.InvoiceDate) AS Day,
    TO_CHAR(i.InvoiceDate, 'Month') AS MonthName,
    EXTRACT(QUARTER FROM i.InvoiceDate) AS Quarter,
    CASE
        WHEN EXTRACT(DAYOFWEEK FROM i.InvoiceDate) IN (1, 7) THEN 'Weekend'
        ELSE 'Weekday'
    END AS DayType
FROM Invoice i;
...................................................................................................................
Druhá dimenzia:

CREATE TABLE Dim_Genre AS
SELECT DISTINCT
    g.GenreId AS GenreID,
    g.Name AS GenreName
FROM Genre g;
....................................................................................................................
Tretia dimenzia:

CREATE TABLE Dim_Customer AS
SELECT DISTINCT
    c.CustomerId AS CustomerID,
    c.FirstName AS FirstName,
    c.LastName AS LastName,
    c.Company AS Company,
    c.Address AS Address,
    c.City AS City,
    c.State AS State,
    c.Country AS Country,
    c.PostalCode AS PostalCode,
    c.Phone AS Phone,
    c.Fax AS Fax,
    c.Email AS Email,
    c.SupportRepId AS SupportRepID
FROM Customer c;
.......................................................................................................................
Štvrtá dimenzia:

CREATE TABLE Dim_Album AS
SELECT DISTINCT
    a.AlbumId AS AlbumID,
    a.Title AS AlbumTitle,
FROM Album a;
........................................................................................................................
Piata dimenzia:

CREATE TABLE Dim_Track AS
SELECT DISTINCT
    t.TrackId AS TrackID,
    t.Name AS TrackName,
    t.AlbumId AS AlbumID,
    t.MediaTypeId AS MediaTypeID,
    t.GenreId AS GenreID,
    t.Composer AS Composer,
    t.Milliseconds AS DurationMilliseconds,
    t.Bytes AS TrackSize,
    t.UnitPrice AS Price
FROM Track t;
.........................................................................................................................
Šiesta dimenzia:

CREATE TABLE Dim_Artist AS
SELECT DISTINCT
    a.ArtistId AS ArtistID,
    a.Name AS ArtistName
FROM Artist a;
.........................................................................................................................
Nakoniec som nasledujúcim príkazom vytvoril centrálnu (faktovú) tabuľku:

CREATE TABLE Fact_Sales AS
SELECT DISTINCT
    i.InvoiceId AS InvoiceID,
    i.CustomerId AS CustomerID,
    i.InvoiceDate AS InvoiceDate,
    il.TrackId AS TrackID,
    il.UnitPrice AS Price,
    il.Quantity AS Quantity,
    il.UnitPrice * il.Quantity AS TotalAmount,
    a.ArtistId AS ArtistID,
    al.AlbumId AS AlbumID,
    g.GenreId AS GenreID,
    mt.MediaTypeId AS MediaTypeID,
    DATEDIFF(DAY, '1970-01-01', i.InvoiceDate) AS DateKey,
    c.CustomerId AS CustomerKey 
FROM Invoice i
JOIN InvoiceLine il ON i.InvoiceId = il.InvoiceId
JOIN Track t ON il.TrackId = t.TrackId
JOIN Album al ON t.AlbumId = al.AlbumId
JOIN Artist a ON al.ArtistId = a.ArtistId
JOIN Genre g ON t.GenreId = g.GenreId
JOIN MediaType mt ON t.MediaTypeId = mt.MediaTypeId
JOIN Customer c ON i.CustomerId = c.CustomerId;
..........................................................................................................................

### Na záver som ešte odstránil staging tabuľky, aby sa optimalizovalo využitie miesta
DROP TABLE IF EXISTS Track;
DROP TABLE IF EXISTS PlaylistTrack;
DROP TABLE IF EXISTS Playlist;
DROP TABLE IF EXISTS MediaType;
DROP TABLE IF EXISTS InvoiceLine;
DROP TABLE IF EXISTS Invoice;
DROP TABLE IF EXISTS Genre;
DROP TABLE IF EXISTS Employee;
DROP TABLE IF EXISTS Customer;
DROP TABLE IF EXISTS Artist;
DROP TABLE IF EXISTS Album;


Výsledný hviezdicový model nám umožňuje efektívne analyzovať dáta z databázy Chinook, ako napríklad predaje skladieb, popularitu žánrov, výnosy jednotlivých interpretov či trendy v 
počúvaní hudby v rôznych obdobiach.
