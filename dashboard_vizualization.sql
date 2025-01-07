-- 1. Najzárobkovejší interpreti

SELECT  
    a.ArtistName,  
    SUM(fs.Quantity * t.Price) AS TotalRevenue  
FROM  
    Fact_Sales fs  
    JOIN Dim_Track t ON fs.TrackID = t.TrackID  
    JOIN Dim_Album al ON t.AlbumID = al.AlbumID  
    JOIN Dim_Artist a ON al.ArtistID = a.ArtistID   
GROUP BY  
    a.ArtistName  
ORDER BY  
    TotalRevenue DESC;  


-- 2. Najzárobkovejšie žánre 

SELECT   
    g.GenreName,  
    SUM(fs.Quantity * t.Price) AS TotalRevenue  
FROM   
    Fact_Sales fs  
JOIN   
    Dim_Track t ON fs.TrackID = t.TrackID  
JOIN   
    Dim_Genre g ON t.GenreID = g.GenreID  
GROUP BY   
    g.GenreName  
ORDER BY   
    TotalRevenue DESC;  


-- 3. Predaj v jednotlivých štvrťrokoch

SELECT   
    EXTRACT(QUARTER, d.FullDate) AS Quarter,  
    SUM(fs.TotalAmount) AS TotalRevenue  
FROM   
    Fact_Sales fs  
JOIN   
    Dim_Date d ON fs.DateKey = d.DateKey  
GROUP BY   
    EXTRACT(QUARTER, d.FullDate)  
ORDER BY   
    Quarter;  


-- 4. Porovnanie predaných trackov cez víkend a cez týždeň

SELECT  
    dd.DayType AS DayType,  
    SUM(fs.Quantity) AS TotalSongsSold  
FROM Fact_Sales fs  
JOIN Dim_Date dd ON fs.DateKey = dd.DateKey  
GROUP BY dd.DayType  
ORDER BY dd.DayType;  


-- 5. Priemerná dĺžka pesničiek daných žánrov

SELECT   
    g.GenreName AS Genre,  
    ROUND(AVG(t.DurationMilliseconds) / 60000, 2) AS AvgTrackLengthInMinutes  
FROM   
    Dim_Track t   
JOIN   
    Dim_Genre g ON t.GenreId = g.GenreID  
GROUP BY   
    g.GenreName  
ORDER BY   
    AvgTrackLengthInMinutes DESC;  
