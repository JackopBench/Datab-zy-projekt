Vytvorenie interného úložiska:
CREATE STAGE my_stage;  

Tvorba prázdnych tabuliek (bez dát) datbázy chinook:
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

CREATE TABLE PlaylistTrack (  
    PlaylistId INT,  
    TrackId INT,  
    PRIMARY KEY (PlaylistId, TrackId)  
);  

CREATE TABLE Playlist (  
    PlaylistId INT PRIMARY KEY,  
    Name STRING  
);  

CREATE TABLE MediaType (  
    MediaTypeId INT PRIMARY KEY,  
    Name STRING  
);  

CREATE TABLE InvoiceLine (  
    InvoiceLineId INT PRIMARY KEY,  
    InvoiceId INT,  
    TrackId INT,  
    UnitPrice DECIMAL(10, 2),  
    Quantity INT  
);  


CREATE TABLE Invoice (  
    InvoiceId INT PRIMARY KEY,  
    CustomerId INT,  
    InvoiceDate TIMESTAMP,  
    BillingAddress STRING,  
    BillingCity STRING,  
    BillingState STRING,  
    BillingCountry STRING,  
    BillingPostalCode STRING,  
    Total DECIMAL(10, 2)  
);  

CREATE TABLE Genre (  
    GenreId INT PRIMARY KEY,  
    Name STRING  
);  

CREATE TABLE Employee (  
    EmployeeId INT PRIMARY KEY,  
    LastName STRING,  
    FirstName STRING,  
    Title STRING,  
    ReportsTo INT,  
    BirthDate DATE,  
    HireDate DATE,  
    Address STRING,  
    City STRING,  
    State STRING,  
    Country STRING,  
    PostalCode STRING,  
    Phone STRING,  
    Fax STRING,  
    Email STRING  
);  


CREATE TABLE Customer (  
    CustomerId INT PRIMARY KEY,  
    FirstName STRING,  
    LastName STRING,  
    Company STRING,  
    Address STRING,  
    City STRING,  
    State STRING,  
    Country STRING,  
    PostalCode STRING,  
    Phone STRING,  
    Fax STRING,  
    Email STRING,  
    SupportRepId INT  
);  

CREATE TABLE Artist (  
    ArtistId INT PRIMARY KEY,  
    Name STRING  
);  

CREATE TABLE Album (  
    AlbumId INT PRIMARY KEY,  
    Title STRING,  
    ArtistId INT,  
    FOREIGN KEY (ArtistId) REFERENCES Artist(ArtistId)  
);  


Tvorba súborového formátu s názvom my_file_format, ktorý slúži na importovanie dát vo forme CSV.
CREATE FILE FORMAT my_file_format    
    TYPE = 'CSV'  
    FIELD_OPTIONALLY_ENCLOSED_BY = '"'  
    SKIP_HEADER = 1  
    ERROR_ON_COLUMN_COUNT_MISMATCH = FALSE;  


Takto som nahrával dáta z csv. súborov do predtým vytvorených tabuliek:
COPY INTO TRACK   
    FROM @my_stage/track.csv  
    FILE_FORMAT = (FORMAT_NAME = my_file_format);  

COPY INTO playlisttrack  
    FROM @my_stage/playlisttrack.csv  
    FILE_FORMAT = (FORMAT_NAME = my_file_format);  

COPY INTO playlist  
    FROM @my_stage/playlist.csv  
    FILE_FORMAT = (FORMAT_NAME = my_file_format);  

COPY INTO mediatype  
    FROM @my_stage/mediatype.csv  
    FILE_FORMAT = (FORMAT_NAME = my_file_format);   

COPY INTO INVOICELINE  
    FROM @my_stage/invoiceline.csv  
    FILE_FORMAT = (FORMAT_NAME = my_file_format);  

COPY INTO INVOICE  
    FROM @my_stage/invoice.csv  
    FILE_FORMAT = (FORMAT_NAME = my_file_format);  
 
COPY INTO genre  
    FROM @my_stage/genre.csv  
    FILE_FORMAT = (FORMAT_NAME = my_file_format);  

COPY INTO employee  
    FROM @my_stage/employee.csv  
    FILE_FORMAT = (FORMAT_NAME = my_file_format1);  

COPY INTO customer  
    FROM @my_stage/customer.csv  
    FILE_FORMAT = (FORMAT_NAME = my_file_format1);  

COPY INTO ARTIST  
    FROM @my_stage/artist.csv  
    FILE_FORMAT = (FORMAT_NAME = my_file_format1);  

COPY INTO album  
    FROM @my_stage/album.csv  
    FILE_FORMAT = (FORMAT_NAME = my_file_format1);  


Tvorba dimenzionálnych tabuliek:
CREATE TABLE Dim_Artist AS  
SELECT DISTINCT  
    a.ArtistId AS ArtistID,  
    a.Name AS ArtistName  
FROM Artist a;  
 
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
 
CREATE TABLE Dim_Genre AS  
SELECT DISTINCT  
    g.GenreId AS GenreID,  
    g.Name AS GenreName  
FROM Genre g;  

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

CREATE TABLE Dim_Album AS  
SELECT DISTINCT  
    a.AlbumId AS AlbumID,  
    a.Title AS AlbumTitle,  
FROM Album a;  


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

tvorba centrálnej faktovej tabuľky:
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


Odstránenie staging tabulek:
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

Spätná kontrola:
SHOW TABLES;
