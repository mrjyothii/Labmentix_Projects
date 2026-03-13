CREATE DATABASE ITUNES

USE ITUNES

ALTER TABLE album
ADD CONSTRAINT FK1 FOREIGN KEY(artist_id) REFERENCES artist(artist_id)

ALTER TABLE track
ADD CONSTRAINT FK2 FOREIGN KEY(album_id) REFERENCES album(album_id)

ALTER TABLE track
ADD CONSTRAINT FK3 FOREIGN KEY(genre_id) REFERENCES genre(genre_id)

ALTER TABLE track
ADD CONSTRAINT FK4 FOREIGN KEY(media_type_id) REFERENCES media_type(media_type_id)

ALTER TABLE playlist_track
ADD CONSTRAINT FK5 FOREIGN KEY(track_id) REFERENCES track(track_id)

ALTER TABLE playlist_track
ADD CONSTRAINT FK6 FOREIGN KEY(playlist_id) REFERENCES playlist(playlist_id)

ALTER TABLE invoice_line
ADD CONSTRAINT FK7 FOREIGN KEY(invoice_id) REFERENCES invoice(invoice_id)

ALTER TABLE invoice_line
ADD CONSTRAINT FK8 FOREIGN KEY(track_id) REFERENCES track(track_id)

ALTER TABLE invoice
ADD CONSTRAINT FK9 FOREIGN KEY(customer_id) REFERENCES customer(customer_id)

ALTER TABLE customer
ADD CONSTRAINT FK10 FOREIGN KEY(support_rep_id) REFERENCES employee(employee_id)


-- 1. Customer Analytics
-- ●	Which customers have spent the most money on music?

SELECT c.first_name +' ' +c.last_name AS Customer_name,ROUND(SUM(i.total),2) AS Total_spent
FROM customer c 
INNER JOIN invoice i 
ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name,  c.last_name
ORDER BY Total_spent DESC

-- ●	What is the average customer lifetime value?

SELECT ROUND(SUM(i.total)/ COUNT(c.customer_id),2) as Average_CLV
FROM customer c 
INNER JOIN invoice i 
ON c.customer_id = i.customer_id

-- ●	How many customers have made repeat purchases versus one-time purchases?

WITH CTE AS
(SELECT customer_id,COUNT(invoice_id) AS no_of_purchases FROM invoice
GROUP BY customer_id)
SELECT 
COUNT(CASE WHEN no_of_purchases > 1 THEN 1 END) AS 'Repeat purchases',
COUNT(CASE WHEN no_of_purchases = 1 THEN 0 END) AS 'One-time purchases'
FROM CTE

-- ●	Which country generates the most revenue per customer?

SELECT c.country,ROUND(SUM(i.total),2) as Total_Revenue,COUNT(DISTINCT c.customer_id) as Total_customers,
ROUND(SUM(i.total) / COUNT(DISTINCT c.customer_id),2) AS Revenue_per_customer
FROM customer c 
INNER JOIN invoice i 
ON c.customer_id = i.customer_id
GROUP BY c.country
ORDER BY Revenue_per_customer DESC

-- ●	Which customers haven't made a purchase in the last 6 months?

SELECT c.first_name + ' ' + c.last_name AS Customer_name,MAX(i.invoice_date) AS Last_purchase_date
FROM customer c 
INNER JOIN invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id, c.first_name,c.last_name
HAVING MAX(i.invoice_date) < DATEADD(M,-6,GETDATE());

-- 2. Sales & Revenue Analysis
-- ●	What are the monthly revenue trends for the last two years?

SELECT YEAR(invoice_date) as [year] ,MONTH(invoice_date) as [Month],ROUND(SUM(total),2) as Total_revenue FROM invoice
WHERE YEAR(invoice_date) < DATEADD(Y,-2,getdate())
GROUP BY YEAR(invoice_date),MONTH(invoice_date)


-- ●	What is the average value of an invoice (purchase)?

SELECT ROUND(AVG(total),2) AS Avg_invoice_value FROM invoice

-- ●	Which payment methods are used most frequently?

-- No able with payment method information

-- ●	How much revenue does each sales representative contribute?

SELECT e.employee_id,e.first_name +' ' +e.last_name AS Employee_name,ROUND(SUM(i.total),2) AS Revenue,
COUNT(c.customer_id) AS Customer_handled,COUNT(distinct c.customer_id) AS Unique_customers
FROM customer c 
inner join invoice i
on c.customer_id = i.customer_id
inner join employee e
on c.support_rep_id = e.employee_id
GROUP BY e.employee_id,e.first_name,e.last_name

-- ●	Which months or quarters have peak music sales?

SELECT TOP 5 FORMAT(invoice_date, 'MMMM') AS [Month],ROUND(SUM(total),2) AS Total_sales
FROM invoice
GROUP BY FORMAT(invoice_date, 'MMMM')
ORDER BY Total_sales DESC

SELECT
    DATEPART(QUARTER, invoice_date) AS SalesQuarter,
    ROUND(SUM(Total),2) AS QuarterlyRevenue
FROM Invoice
GROUP BY 
    DATEPART(QUARTER, invoice_date)
ORDER BY 
    SalesQuarter;


--3. Product & Content Analysis
-- ●	Which tracks generated the most revenue?

SELECT t.[name] AS Track, ROUND(SUM(i.total),2) AS Revenue FROM invoice i
INNER JOIN invoice_line ii
ON i.invoice_id = ii.invoice_id
INNER JOIN track t
ON t.track_id = ii.track_id
GROUP BY t.name
ORDER BY Revenue DESC

-- ●	Which albums or playlists are most frequently included in purchases?

SELECT a.title AS Album_name,ROUND(SUM(i.total),2) AS Total_purchases,SUM(il.quantity) AS Quantity FROM invoice i
INNER JOIN invoice_line il
ON i.invoice_id = il.invoice_id
INNER JOIN track t
ON t.track_id = il.track_id
INNER JOIN album a
ON a.album_id = t.album_id
GROUP BY a.title
ORDER BY Total_purchases DESC

SELECT p.name AS Playlist_name,ROUND(SUM(i.total),2) AS Total_purchases,SUM(il.quantity) AS Quantity FROM invoice i
INNER JOIN invoice_line il
ON i.invoice_id = il.invoice_id
INNER JOIN track t
ON t.track_id = il.track_id
INNER JOIN playlist_track pt
ON pt.track_id = t.track_id
INNER JOIN playlist p
ON p.playlist_id = pt.playlist_id
GROUP BY p.name
ORDER BY Total_purchases DESC

-- ●	Are there any tracks or albums that have never been purchased?

SELECT a.album_id, a.title
FROM Album a
LEFT JOIN Track t ON a.album_id = t.album_id
LEFT JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY a.album_id, a.title
HAVING COUNT(il.invoice_line_id) = 0;

SELECT t.track_id, t.name
FROM track t
LEFT JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY t.track_id, t.name
HAVING COUNT(il.invoice_line_id) = 0;

-- ●	What is the average price per track across different genres?

SELECT 
    g.Name AS Genre,
    COUNT(t.track_id) AS TrackCount,
    ROUND(AVG(t.unit_price), 2) AS AvgPrice
FROM Track t
JOIN Genre g ON t.genre_id = g.genre_id
GROUP BY g.Name
ORDER BY AvgPrice DESC;

SELECT 
   DISTINCT ROUND(AVG(t.unit_price), 2) AS AvgPrice
FROM Track t
JOIN Genre g ON t.genre_id = g.genre_id
GROUP BY g.Name
ORDER BY AvgPrice DESC;

-- ●	How many tracks does the store have per genre and how does it correlate with sales?

SELECT 
    g.Name AS Genre,
    COUNT(DISTINCT t.track_id) AS TrackCount,
    SUM(il.quantity) AS UnitsSold,
    ROUND(SUM(il.unit_price * il.quantity), 2) AS Revenue
FROM Genre g
LEFT JOIN Track t ON g.genre_id = t.genre_id
LEFT JOIN invoice_line il ON t.track_id = il.track_id
GROUP BY g.Name
ORDER BY Revenue DESC;


--4. Artist & Genre Performance
-- ●	Who are the top 5 highest-grossing artists?

SELECT TOP 5 ar.name AS Artist_name,ROUND(SUM(il.unit_price*il.quantity),2) AS highest_grossing from invoice i
INNER JOIN invoice_line il
ON i.invoice_id = il.invoice_id
INNER JOIN track t
ON t.track_id = il.track_id
INNER JOIN album a
ON a.album_id = t.album_id
INNER JOIN artist ar
ON ar.artist_id = a.artist_id
GROUP BY ar.name
ORDER BY highest_grossing DESC

-- ●	Which music genres are most popular in terms of:
-- ○	Number of tracks sold
-- ○	Total revenue

SELECT g.name,COUNT(t.track_id) as No_of_units_sold,ROUND(SUM(il.unit_price*il.quantity),2) AS Revenue 
from invoice_line il
INNER JOIN track t
ON t.track_id = il.track_id
INNER JOIN genre g
ON g.genre_id = t.genre_id
GROUP BY g.name
ORDER BY Revenue DESC

-- ●	Are certain genres more popular in specific countries?

WITH CTE AS
(SELECT 
RANK() OVER (PARTITION BY c.country ORDER BY SUM(il.quantity) Desc) AS RNK,
c.country,g.name AS Genre, SUM(il.quantity) AS TracksSold
FROM Customer c
INNER JOIN invoice i ON c.customer_id = i.customer_id
INNER JOIN invoice_line il ON i.invoice_id = il.invoice_id
INNER JOIN track t ON il.track_id = t.track_id
INNER JOIN genre g ON t.genre_id = g.genre_id
GROUP BY c.country, g.name)
SELECT * FROM CTE
WHERE RNK < = 1
ORDER BY TracksSold DESC


--5. Employee & Operational Efficiency
-- ●	Which employees (support representatives) are managing the highest-spending customers?

WITH CTE1 AS
(SELECT TOP 10 c.support_rep_id AS emp_id,c.first_name+' '+c.last_name AS customer_name,ROUND(SUM(i.total),2) AS MAX_SPEND
from customer c
INNER JOIN invoice i ON i.customer_id = c.customer_id
GROUP BY c.first_name+' '+c.last_name,c.support_rep_id
ORDER BY MAX_SPEND DESC)
SELECT emp_id,COUNT(customer_name) AS No_of_customers, SUM(MAX_SPEND) AS Revenue
FROM CTE1
GROUP BY emp_id


-- ●	What is the average number of customers per employee?

WITH CTE2 AS
(SELECT c.support_rep_id AS Empl_id,e.first_name +' '+ e.last_name AS Employee_name, COUNT(c.customer_id) AS cnt FROM customer c
INNER JOIN employee e
ON c.support_rep_id = e.employee_id
GROUP BY e.first_name +' '+ e.last_name,c.support_rep_id)
SELECT Empl_id,Employee_name,AVG(cnt) AS avg_customers FROM CTE2
GROUP BY Employee_name,Empl_id

-- ●	Which employee regions bring in the most revenue?

SELECT e.employee_id,e.first_name +' '+ e.last_name AS Employee_name,c.country as region,ROUND(SUM(i.total),2) as Revenue 
FROM employee e
INNER JOIN customer c ON c.support_rep_id = e.employee_id
INNER JOIN invoice i ON i.customer_id = c.customer_id
GROUP BY e.employee_id,e.first_name +' '+ e.last_name,c.country
ORDER BY Revenue DESC

--6. Geographic Trends
-- ●	Which countries or cities have the highest number of customers?

SELECT c.country,COUNT(i.customer_id) AS no_of_customers FROM customer c
INNER JOIN invoice i
ON c.customer_id = i.customer_id
GROUP BY c.country
ORDER BY no_of_customers DESC

SELECT c.city,COUNT(i.customer_id) AS no_of_customers FROM customer c
INNER JOIN invoice i
ON c.customer_id = i.customer_id
GROUP BY c.city
ORDER BY no_of_customers DESC

-- ●	How does revenue vary by region?

SELECT 
    c.Country AS Region,
    ROUND(SUM(i.Total), 2) AS TotalRevenue,
    COUNT(DISTINCT c.customer_id) AS CustomerCount,
    COUNT(i.invoice_id) AS InvoiceCount
FROM Customer c
JOIN Invoice i ON c.customer_id = i.customer_id
GROUP BY c.Country
ORDER BY TotalRevenue DESC;

SELECT 
    c.State AS Region,
    ROUND(SUM(i.Total), 2) AS TotalRevenue,
    COUNT(DISTINCT c.customer_id) AS CustomerCount,
    COUNT(i.invoice_id) AS InvoiceCount
FROM Customer c
JOIN Invoice i ON c.customer_id = i.customer_id
WHERE c.State IS NOT NULL
GROUP BY c.State
ORDER BY TotalRevenue DESC;


-- ●	Are there any underserved geographic regions (high users, low sales)?

SELECT c.country,COUNT(DISTINCT c.customer_id) AS Customer_cnt,
ROUND(SUM(i.total),2) AS Total_revenue,
ROUND(SUM(i.total) / COUNT(DISTINCT c.customer_id), 2) AS RevenuePerCustomer
FROM customer c
INNER JOIN invoice i ON i.customer_id = c.customer_id
GROUP BY c.country
ORDER BY Total_revenue DESC

WITH RegionStats AS (
    SELECT 
        c.country,
        COUNT(DISTINCT c.customer_id) AS CustomerCount,
        SUM(i.Total) AS TotalRevenue
    FROM Customer c
    LEFT JOIN Invoice i ON c.customer_id = i.customer_id
    GROUP BY c.country
)
SELECT *,
       RANK() OVER (ORDER BY CustomerCount DESC) AS CustomerRank,
       RANK() OVER (ORDER BY TotalRevenue DESC) AS RevenueRank
FROM RegionStats
ORDER BY CustomerRank;

--7. Customer Retention & Purchase Patterns
-- ●	What is the distribution of purchase frequency per customer?

SELECT 
    PurchaseCount,
    COUNT(*) AS NumberOfCustomers
FROM (
    SELECT 
        c.customer_id,
        COUNT(i.invoice_id) AS PurchaseCount
    FROM Customer c
    LEFT JOIN Invoice i 
        ON c.customer_id = i.customer_id
    GROUP BY c.customer_id
) sub
GROUP BY PurchaseCount
ORDER BY PurchaseCount;

SELECT 
    ROUND(AVG(PurchaseCount), 2) AS AvgPurchases,
    MIN(PurchaseCount) AS MinPurchases,
    MAX(PurchaseCount) AS MaxPurchases
FROM (
    SELECT 
        c.customer_id,
        COUNT(i.invoice_id) AS PurchaseCount
    FROM Customer c
    LEFT JOIN Invoice i 
        ON c.customer_id = i.customer_id
    GROUP BY c.customer_id
) sub;

-- ●	How long is the average time between customer purchases?

SELECT c.customer_id,DATEDIFF(D,MIN(i.invoice_date),MAX(i.invoice_date))/COUNT(i.invoice_id) as cnt
FROM invoice i
INNER JOIN customer c ON c.customer_id = i.customer_id
GROUP BY c.customer_id

WITH PurchaseIntervals AS (
    SELECT c.customer_id, DATEDIFF(D,MIN(i.invoice_date),MAX(i.invoice_date))/COUNT(i.invoice_id) AS DaysBetween
    FROM invoice i
    INNER JOIN customer c ON c.customer_id = i.customer_id
    GROUP BY c.customer_id)
SELECT ROUND(AVG(CustomerAvgGap), 2) AS AvgDaysBetweenPurchases
FROM (SELECT customer_id, AVG(DaysBetween) AS CustomerAvgGap
    FROM PurchaseIntervals
    WHERE DaysBetween IS NOT NULL
    GROUP BY customer_id) sub;

-- ●	What percentage of customers purchase tracks from more than one genre?

WITH CustomerGenres AS (
    SELECT 
        c.customer_id,
        COUNT(DISTINCT t.genre_id) AS GenreCount
    FROM Customer c
    JOIN Invoice i      ON c.customer_id = i.customer_id
    JOIN invoice_line il ON i.invoice_id = il.invoice_id
    JOIN Track t        ON il.track_id = t.track_id
    GROUP BY c.customer_id
)
SELECT 
    ROUND(
        100.0 * SUM(CASE WHEN GenreCount > 1 THEN 1 ELSE 0 END) 
        / COUNT(*),
        2
    ) AS PercentMultiGenreCustomers
FROM CustomerGenres;

--8. Operational Optimization
-- ●	What are the most common combinations of tracks purchased together?

SELECT TOP 20
    t1.Name AS Track1,
    t2.Name AS Track2,
    COUNT(*) AS TimesPurchasedTogether
FROM invoice_line il1
JOIN invoice_line il2 
    ON il1.invoice_id = il2.invoice_id
    AND il1.track_id < il2.track_id   -- prevents duplicates & self-pairs
JOIN Track t1 ON il1.track_id = t1.track_id
JOIN Track t2 ON il2.track_id = t2.track_id
GROUP BY t1.Name, t2.Name
ORDER BY TimesPurchasedTogether DESC

-- ●	Are there pricing patterns that lead to higher or lower sales?

SELECT 
    ROUND(t.unit_price,2) AS Unit_price,
    COUNT(DISTINCT t.track_id) AS NumberOfTracks,
    SUM(il.Quantity) AS UnitsSold,
    ROUND(SUM(il.unit_price * il.Quantity), 2) AS Revenue,
    ROUND(SUM(il.Quantity) * 1.0 / COUNT(DISTINCT t.track_id), 2) 
        AS AvgUnitsSoldPerTrack
FROM Track t
LEFT JOIN invoice_line il 
    ON t.track_id = il.track_id
GROUP BY t.unit_price
ORDER BY t.unit_price;


-- ●	Which media types (e.g., MPEG, AAC) are declining or increasing in usage?

SELECT 
    Year(i.invoice_date) AS Years,
    mt.Name AS MediaType,
    SUM(il.Quantity) AS UnitsSold
FROM invoice i
JOIN invoice_line il ON i.invoice_id = il.invoice_id
JOIN Track t ON il.track_id = t.track_id
JOIN media_type mt ON t.media_type_id = mt.media_type_id
GROUP BY Year(i.invoice_date), mt.Name
ORDER BY Years, UnitsSold DESC;

-- Who is the senior most employee based on job title?

SELECT * FROM employee 
WHERE reports_to IS NULL

-- Q2. Which countries have the most Invoices?

SELECT TOP 5 billing_country,COUNT(invoice_id) AS No_of_invoices FROM invoice
GROUP BY billing_country
ORDER BY No_of_invoices DESC

-- Q3. What are top 3 values of total invoice?

SELECT TOP 3 total FROM invoice
ORDER BY total DESC

-- Q4. Which city has the best customers? We would like to throw a promotional Music Festival in the city we made the most money. 
--     Write a query that returns one city that has the highest sum of invoice totals. Return both the city name & sum of all invoice totals.

SELECT TOP 1 billing_city,ROUND(SUM(total),2) AS Invoice_totals FROM invoice
GROUP BY billing_city
ORDER BY Invoice_totals DESC

-- Q5. Who is the best customer? The customer who has spent the most money will be declared the best customer. 

SELECT TOP 1 i.customer_id,c.first_name + ' ' +  c.last_name AS customer_name,SUM(i.total) AS Total_invoice_value FROM invoice i
INNER JOIN customer c
ON i.customer_id = c.customer_id
GROUP BY i.customer_id,c.first_name + ' ' +  c.last_name
ORDER BY Total_invoice_value DESC

-- Q6. Write a query to return the email, first name, last name, & Genre of all Rock Music listeners. Return your list ordered alphabetically by email starting with A 

SELECT DISTINCT c.email,c.first_name,c.last_name,g.name AS Genre_name FROM customer c
INNER JOIN invoice i ON c.customer_id = i.customer_id
INNER JOIN invoice_line il ON i.invoice_id = il.invoice_id
INNER JOIN track t ON il.track_id = t.track_id
INNER JOIN genre g ON g.genre_id = t.genre_id
WHERE g.[name] = 'Rock'
ORDER BY c.email

-- Q7. Let's invite the artists who have written the most rock music in our dataset. 
--     Write a query that returns the Artist name and total track count of the top 10 rock bands.

SELECT TOP 10 a.name AS Artist_name,COUNT(t.track_id) AS Track_count FROM artist a
INNER JOIN album al ON a.artist_id = al.artist_id
INNER JOIN track t ON al.album_id = t.album_id
INNER JOIN genre g ON t.genre_id = g.genre_id
WHERE g.[name] = 'Rock'
GROUP BY a.[name]
ORDER BY Track_count DESC

-- Q8. Return all the track names that have a song length longer than the average song length. 
--     Return the Name and Milliseconds for each track. Order by the song length with the longest songs listed first.

SELECT [name] AS Track_name,milliseconds FROM track
WHERE milliseconds > (SELECT AVG(milliseconds) FROM track)
ORDER BY milliseconds DESC

-- Q9. Find how much amount spent by each customer on artists. Write a query to return the customer name, artist name, and total spent.

SELECT c.first_name + ' ' + c.last_name AS Customer_name,ar.[name] AS Artist_name,ROUND(SUM(i.total),2) AS Amount_spent FROM customer c
INNER JOIN invoice i ON i.customer_id = c.customer_id
INNER JOIN invoice_line il ON i.invoice_id = il.invoice_id
INNER JOIN track t ON il.track_id = t.track_id
INNER JOIN album a ON a.album_id = t.album_id
INNER JOIN artist ar ON ar.artist_id = a.artist_id
GROUP BY c.first_name + ' ' + c.last_name,ar.[name]
ORDER BY Amount_spent DESC

-- Q10. We want to find out the most popular music Genre for each country. 
--      We determine the most popular genre as the genre with the highest amount of purchases. 
--      Write a query that returns each country along with the top Genre. For countries where the maximum number of purchases is shared (tie) return all Genres.


WITH genre_purchases AS (
SELECT c.country,g.[name] AS Genre_Name,COUNT(il.invoice_id) AS Purchase_Count
FROM Customer c
INNER JOIN invoice i ON c.customer_id = i.customer_id
INNER JOIN invoice_line il ON i.invoice_id = il.invoice_id
INNER JOIN track t ON il.track_id = t.track_id
INNER JOIN genre g ON t.genre_id = g.genre_id
GROUP BY c.country,g.[name]),
ranked_genres AS (
SELECT *,
RANK() OVER (PARTITION BY country ORDER BY Purchase_Count DESC) AS genre_rank
FROM genre_purchases)
SELECT country,Genre_Name,Purchase_Count
FROM ranked_genres
WHERE genre_rank = 1
ORDER BY country;

-- Q11. Write a query that determines the customer that has spent the most on music for each country. Write a query that returns the country along with the top customer and how much they spent. For countries where the top amount spent is shared, provide all customers who spent this amount.

WITH customer_spending AS 
(SELECT c.customer_id,c.first_name + ' '+ c.last_name AS customer_name,c.country,ROUND(SUM(i.total),2) AS Total_Spent
FROM Customer c
INNER JOIN Invoice i ON c.customer_id = i.customer_id
GROUP BY c.customer_id,c.first_name + ' '+ c.last_name,c.country),
ranked_customers AS (
SELECT *,RANK() OVER (PARTITION BY Country ORDER BY Total_Spent DESC) AS spending_rank
FROM customer_spending)
SELECT country,customer_name,Total_Spent
FROM ranked_customers
WHERE spending_rank = 1
ORDER BY country;


-- Q12. Who are the most popular artists?

SELECT TOP 5 ar.[name] AS Artist_Name,ROUND(SUM(il.unit_price * il.quantity),2) AS Total_Revenue
FROM invoice_line il
INNER JOIN Track t ON il.track_id = t.track_id
INNER JOIN Album al ON t.album_id = al.album_id
INNER JOIN Artist ar ON al.artist_id = ar.artist_id
GROUP BY ar.[name]
ORDER BY Total_Revenue DESC

-- Q13. Which is the most popular song?

SELECT TOP 1 t.[name] AS Song_Name, ROUND(SUM(il.unit_price * il.quantity),2) AS Total_Revenue
FROM invoice_line il
INNER JOIN Track t ON il.track_id = t.track_id
GROUP BY t.[name]
ORDER BY Total_Revenue DESC

-- Q14. What are the average prices of different types of music?

SELECT g.[name] AS Music_Type, ROUND(AVG(t.unit_price),2) AS Average_Price
FROM Track t
INNER JOIN Genre g ON t.genre_id = g.genre_id
GROUP BY g.Name
ORDER BY Average_Price DESC;

-- Q15. What are the most popular countries for music purchases?

SELECT i.billing_country,ROUND(SUM(i.Total),2) AS Total_Revenue
FROM Invoice i
GROUP BY i.billing_country
ORDER BY Total_Revenue DESC;