CREATE DATABASE Video_Game

USE Video_Game

SELECT * FROM GAMES

SELECT * FROM VGSALES

-- Drop column column1

ALTER TABLE GAMES
DROP COLUMN column1

-- Primary key creation in vgsales table

ALTER TABLE VGSALES 
ALTER COLUMN games_id INT NOT NULL

ALTER TABLE VGSALES
ADD CONSTRAINT PK1 PRIMARY KEY (games_id);

-- foreign key creation in games table

ALTER TABLE GAMES 
ALTER COLUMN games_id INT NOT NULL

ALTER TABLE GAMES
ADD CONSTRAINT FK1
FOREIGN KEY (games_id)
REFERENCES VGSALES(games_id);

-- 📁 games.csv (Game Metadata Only)

-- 1.	🌟 What are the top-rated games by user reviews?

SELECT DISTINCT Top 10 Title,Number_of_Reviews FROM GAMES
ORDER BY Number_of_Reviews DESC

-- 2.	🧑🤝🧑 Which developers (Teams) have the highest average ratings?

SELECT Team,round(AVG(Rating),1) AS Avg_rating FROM GAMES
GROUP BY Team
ORDER BY Avg_rating desc

-- 3.	🧩 What are the most common genres in the dataset?

SELECT TOP 10 Genre,COUNT(Genre) AS Count_gen FROM GAMES
GROUP BY Genre
ORDER BY Count_gen desc

-- 4.	⏳ Which games have the highest backlog compared to wishlist?

SELECT DISTINCT Title,Backlogs,Wishlist,(Backlogs - Wishlist) AS Bac_Wis FROM GAMES
WHERE Backlogs > Wishlist
ORDER BY Bac_Wis DESC

-- 5.	🗓️ What is the game release trend across years?

SELECT YEAR(Release_Date) AS Release_Year,
COUNT(*) AS num_games
FROM GAMES
GROUP BY YEAR(Release_Date)
ORDER BY Release_Year;

-- 6.	🔎 What is the distribution of user ratings?


SELECT
    CASE
        WHEN Rating >= 0 AND Rating < 1 THEN 0
        WHEN rating >= 1 AND rating < 2 THEN 1
        WHEN rating >= 2 AND rating < 3 THEN 2
        WHEN rating >= 3 AND rating < 4 THEN 3
        WHEN rating >= 4 AND rating < 5 THEN 4
        ELSE 5
    END AS rating_group,
    COUNT(Rating) AS RATI_CNT
FROM GAMES
GROUP BY CASE
        WHEN Rating >= 0 AND Rating < 1 THEN 0
        WHEN rating >= 1 AND rating < 2 THEN 1
        WHEN rating >= 2 AND rating < 3 THEN 2
        WHEN rating >= 3 AND rating < 4 THEN 3
        WHEN rating >= 4 AND rating < 5 THEN 4
        ELSE 5
        END
ORDER BY rating_group 


-- 7.	🧑 What are the top 10 most wishlisted games?

SELECT DISTINCT TOP 10  Title,Wishlist FROM GAMES
ORDER BY Wishlist DESC

-- 8.	🔬 What’s the average number of plays per genre?

SELECT Genre,AVG(Plays) AS Avg_plays FROM GAMES
GROUP BY Genre
ORDER BY Avg_plays DESC

-- 9.	🏢 Which developer studios are the most productive and impactful?

SELECT Top 10 Team,sum(Backlogs) AS High_backlogs,sum(Plays) AS High_plays,sum(Playing) AS High_playing,
sum(Wishlist) AS High_wishlist,count(Title) as no_of_games  FROM GAMES
GROUP BY Team
ORDER BY High_plays desc,High_playing desc,High_wishlist desc


-- Table 2 VGSALES

-- 10.	🌍 Which region generates the most game sales?

SELECT ROUND(SUM(NA_Sales),2) AS 'North America Sales',
ROUND(SUM(JP_Sales),2) AS 'Japan Sales', ROUND(SUM(EU_Sales),2) AS 'Europe_Sales',
ROUND(SUM(Other_Sales),2) AS 'Other_Sales'
FROM VGSALES

-- 11.	🕹️ What are the best-selling platforms?

SELECT TOP 5 [Platform],ROUND(SUM(Global_Sales),1) AS Total_sales FROM VGSALES
GROUP BY [Platform]
ORDER BY Total_sales DESC

-- 12.	📅 What’s the trend of game releases and sales over years?

SELECT Year,ROUND(SUM(Global_Sales),1) AS Total_sales,COUNT(distinct Name) AS Total_games FROM VGSALES
GROUP BY Year
ORDER BY Year

-- 13.	🏢 Who are the top publishers by sales?

SELECT TOP 5 Publisher,ROUND(SUM(Global_Sales),1) AS Total_sales FROM VGSALES
GROUP BY Publisher
ORDER BY Total_sales DESC

-- 14.	🔝 Which games are the top 10 best-sellers globally?

SELECT TOP 10 Name,ROUND(SUM(Global_Sales),1) AS Total_sales FROM VGSALES
GROUP BY Name
ORDER BY Total_sales DESC

-- 15.	🧭 How do regional sales compare for specific platforms?

SELECT [Platform],
ROUND(SUM(NA_Sales),1)    AS NA_sales,
ROUND(SUM(EU_Sales),1)    AS EU_sales,
ROUND(SUM(JP_Sales),1)    AS JP_sales,
ROUND(SUM(Other_Sales),1) AS Other_sales
FROM VGSALES
GROUP BY [Platform]
ORDER BY [Platform]

-- 16.	📈 How has the market evolved by platform over time?

SELECT  [Year],count(distinct Platform) as No_of_platforms,ROUND(SUM(Global_Sales),1) AS TS FROM VGSALES
GROUP BY Year
ORDER BY Year,TS

-- 17.	📍 What are the regional genre preferences?

SELECT Genre,
ROUND(SUM(NA_Sales),1)    AS NA_sales,
ROUND(SUM(EU_Sales),1)    AS EU_sales,
ROUND(SUM(JP_Sales),1)    AS JP_sales,
ROUND(SUM(Other_Sales),1) AS Other_sales
FROM VGSALES
GROUP BY Genre
ORDER BY Genre

-- 18.	🔄 What’s the yearly sales change per region?

SELECT
    [Year],
    SUM(NA_Sales) - LAG(SUM(NA_Sales)) OVER (ORDER BY Year) AS NA_Sales_Change,
    SUM(EU_Sales) - LAG(SUM(EU_Sales)) OVER (ORDER BY Year) AS EU_Sales_Change,
    SUM(JP_Sales) - LAG(SUM(JP_Sales)) OVER (ORDER BY Year) AS JP_Sales_Change,
    SUM(Other_Sales) - LAG(SUM(Other_Sales)) OVER (ORDER BY Year) AS Other_Sales_Change
FROM VGSALES
GROUP BY [Year]
ORDER BY [Year];


-- 19.	🧮 What is the average sales per publisher?

SELECT Publisher,ROUND(AVG(Global_Sales),1) AS Avg_sales FROM VGSALES
GROUP BY Publisher
ORDER BY Avg_sales desc

-- 20.	🏆 What are the top 5 best-selling games per platform?

WITH CTE AS
(SELECT Platform,NAME,Global_sales,
ROW_NUMBER() OVER (PARTITION BY Platform ORDER BY Global_Sales DESC) AS RNK
FROM VGSALES)
SELECT Platform,NAME,ROUND(Global_sales,1) AS TS FROM CTE
WHERE RNK<6

-- Rename Genre column in games data AS column with same names not allowed

EXEC sp_rename 'GAMES.Genre', 'Genre_x', 'COLUMN';

--Merged Dataset (Sales + Engagement + Ratings)

SELECT G.Title,G.Release_Date,G.Team,G.Rating,G.Times_Listed,G.Number_of_Reviews,
G.Genre_x,G.Plays,G.Playing,G.Backlogs,G.Wishlist,S.[Platform],S.Genre,
S.Publisher,S.NA_Sales,S.JP_Sales,S.EU_Sales,S.Other_Sales,S.Global_Sales
INTO Merged_games_data
FROM GAMES G
INNER JOIN VGSALES S
ON G.Title =  S.[Name]

-- REPLACING UNKNOWN PUBLISHER NAMES FROM TEAM COLUMN

UPDATE Merged_games_data SET Publisher =
CASE WHEN Publisher = 'UNKNOWN' THEN Team ELSE Publisher END
FROM Merged_games_data

-- DROPPING COLUMNS WHERE TEAM = NIS America,Atlus USA,Sonic Team,Headup Games

DELETE FROM Merged_games_data
WHERE TEAM IN ('NIS America','Atlus USA','Sonic Team','Headup Games')

select * from Merged_games_data

-- MERGING GENRE_X AND GENRE AND CREATING NEW COLUMN

ALTER TABLE Merged_games_data
ADD genre_combined VARCHAR(50);  -- adjust length as needed

UPDATE Merged_games_data
SET genre_combined = 
CASE WHEN Genre_x LIKE CONCAT('%', Genre, '%') THEN Genre_x
     ELSE CONCAT(Genre_x, ', ', Genre) END;

--SPLITTING THE COMBINED GENRE COLUMN AND CREATING A NEW TABLE

SELECT Title, [Release_Date], Rating, [Times_Listed],Number_of_Reviews,Plays,
      Playing, Backlogs, Wishlist, [Platform],Publisher, NA_Sales, 
      EU_Sales, JP_Sales,Other_Sales, Global_Sales,
    LTRIM(RTRIM(value)) AS genre_new
INTO game_genres
FROM Merged_games_data
CROSS APPLY STRING_SPLIT(genre_combined, ',');


-- CHECKING FOR DUPLICATES

SELECT Title, [Release_Date], Rating, [Times_Listed],Number_of_Reviews,Plays,
      Playing, Backlogs, Wishlist, [Platform],Publisher, NA_Sales, 
      EU_Sales, JP_Sales,Other_Sales, Global_Sales,genre_new,COUNT(*) FROM game_genres
GROUP BY Title, [Release_Date], Rating, [Times_Listed],Number_of_Reviews,Plays,
      Playing, Backlogs, Wishlist, [Platform],Publisher, NA_Sales, 
      EU_Sales, JP_Sales,Other_Sales, Global_Sales,genre_new
HAVING COUNT(*) >1

-- REMOVING DUPLICATES

WITH CTE AS
(SELECT *,
ROW_NUMBER() OVER (PARTITION BY Title, [Release_Date], [Times_Listed],Number_of_Reviews,Plays,
      Playing, Backlogs, Wishlist, [Platform],Publisher, NA_Sales, 
      EU_Sales, JP_Sales,Other_Sales, Global_Sales,genre_new
ORDER BY Title) AS rn
FROM game_genres) 
DELETE FROM CTE
WHERE rn > 1;

SELECT * FROM game_genres


-- 21.	🎮 Which game genres generate the most global sales?

SELECT genre_new,ROUND(SUM(Global_Sales),2) AS TS FROM game_genres
GROUP BY genre_new
ORDER BY TS DESC

-- 22.	🎯 How does user rating affect global sales?

SELECT
    CASE
        WHEN Rating >= 0 AND Rating <= 1 THEN 1
        WHEN Rating > 1 AND Rating <= 2 THEN 2
        WHEN Rating > 2 AND Rating <= 3 THEN 3
        WHEN Rating > 3 AND Rating <= 4 THEN 4
        ELSE 5
    END AS rating_group,
    SUM(Global_Sales) AS TS
FROM game_genres
GROUP BY CASE
        WHEN Rating >= 0 AND Rating <= 1 THEN 1
        WHEN Rating > 1 AND Rating <= 2 THEN 2
        WHEN Rating > 2 AND Rating <= 3 THEN 3
        WHEN Rating > 3 AND Rating <= 4 THEN 4
        ELSE 5
        END
ORDER BY rating_group 


-- 23.	🕹️ Which platforms have the most games with high ratings (e.g., above 4)?

SELECT [Platform],COUNT(DISTINCT Title) AS Games_cnt FROM game_genres
WHERE Rating > 4
GROUP BY [Platform]
ORDER BY Games_cnt DESC

-- 24.	📈 What’s the trend of releases and sales over time?

SELECT
    YEAR(Release_Date) AS ReleaseYear,COUNT(Distinct Title) AS No_of_games,
    ROUND(SUM(Global_Sales),2) AS Total_sales
FROM
    game_genres
GROUP BY
    YEAR(Release_Date)
ORDER BY
    ReleaseYear;


-- 25.	🧍 Do highly wishlisted games lead to more sales?

SELECT DISTINCT Title,Wishlist,ROUND(Global_Sales,1) AS TS FROM game_genres
ORDER BY Wishlist DESC

-- 26.	🎮 Which genres have the highest engagement but lowest sales?

-- Plays+ 0.5(Playing)/plays + backlogs 

SELECT DISTINCT genre_new,
(SUM(Playing)+0.5*SUM(Plays))/(SUM(Backlogs)+SUM(Plays)) AS Engagement_score,
ROUND(SUM(global_sales),2) AS Total_sales FROM game_genres
GROUP BY genre_new
ORDER BY Engagement_score DESC, Total_sales ASC

--(Misc,sports,fighting,brawler,simulation)

-- 27.	🧠 Do highly listed games (wishlist/backlogs) correlate with better ratings?

SELECT
    Wishlist_corr = (AVG(Wishlist * Rating) - AVG(Wishlist) * AVG(Rating)) / (STDEVP(Wishlist) * STDEVP(Rating)),
    Backlogs_corr = (AVG(Backlogs * Rating) - AVG(Backlogs) * AVG(Rating)) / (STDEVP(Backlogs) * STDEVP(Rating))

FROM
    game_genres;

-- 28.	🏷️ How does user engagement differ across genres?

SELECT DISTINCT genre_new,
(SUM(Playing)+0.5*SUM(Plays))/(SUM(Backlogs)+SUM(Plays)) AS Engagement_score
FROM game_genres
GROUP BY genre_new

-- 29.	🎉 What are the top-performing combinations of Genre + Platform?

SELECT Top 10 genre_new,[Platform],ROUND(SUM(Global_Sales),2) AS TS FROM game_genres
GROUP BY genre_new,[Platform]
ORDER BY TS DESC        

-- 30.	🌐 What does a regional sales heatmap by genre reveal?

SELECT genre_new,ROUND(SUM(NA_Sales),2) AS NA_sales,ROUND(SUM(EU_Sales),2) AS EU_sales ,
ROUND(SUM(JP_Sales),2) AS JP_sales,ROUND(SUM(Other_Sales),2) AS Other_sales FROM game_genres
GROUP BY genre_new
ORDER BY genre_new 


