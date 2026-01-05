USE ola

SELECT Booking_ID,Customer_ID,COUNT(*) AS Duplicates FROM OLA_DataSet
GROUP BY Booking_ID,Customer_ID
HAVING COUNT(*) >1

-- 1. Retrieve all successful bookings:

SELECT COUNT(*) AS Successful_booking FROM OLA_DataSet
WHERE Booking_Status = 'Success'

-- 2. Find the average ride distance for each vehicle type:

SELECT Vehicle_Type,ROUND(AVG(Ride_Distance),2) AS Avg_distance from OLA_DataSet
WHERE Booking_Status = 'Success'
GROUP BY Vehicle_Type

-- 3. Get the total number of cancelled rides by customers:

SELECT Count(*) as 'Rides canceled by customer' FROM OLA_DataSet
WHERE Booking_Status = 'Canceled by customer'

-- 4. List the top 5 customers who booked the highest number of rides:

SELECT Customer_ID,COUNT(Customer_ID) AS No_of_rides FROM OLA_DataSet
WHERE Booking_Status = 'success'
GROUP BY Customer_ID
ORDER BY No_of_rides DESC
LIMIT 5

-- 5. Get the number of rides cancelled by drivers due to personal and car-related issues:

SELECT Count(*) as 'Rides canceled by driver' FROM OLA_DataSet
WHERE Booking_Status = 'Canceled by driver' AND Canceled_Rides_by_Driver = 'Personal & Car related issue'

-- 6. Find the maximum and minimum driver ratings for Prime Sedan bookings:

SELECT Vehicle_Type,
MAX(Driver_Ratings) AS Max_Ratings,
MIN(Driver_Ratings) AS Min_Ratings
FROM OLA_DataSet
WHERE Booking_Status = 'Success'
GROUP BY Vehicle_Type
HAVING Vehicle_Type = 'Prime Sedan'; 


-- 7. Retrieve all rides where payment was made using UPI:

SELECT COUNT(*) AS UPI_Payments FROM OLA_DataSet
WHERE Payment_Method = 'UPI'

-- 8. Find the average customer rating per vehicle type:

SELECT Vehicle_Type,ROUND(AVG(Customer_Rating),3) AS Avg_customer_rating from OLA_DataSet
GROUP BY Vehicle_Type

-- 9. Calculate the total booking value of rides completed successfully:

SELECT SUM(Booking_value) as Total_booking_value FROM OLA_DataSet
WHERE Booking_Status = 'Success'

-- 10. List all incomplete rides along with the reason

SELECT DISTINCT(Incomplete_Rides_Reason),
COUNT(*) OVER (PARTITION BY Incomplete_Rides_Reason) AS TOTAL
FROM OLA_DataSet
WHERE Incomplete_Rides = 'yes'
union 
select 'Total' as Total,
COUNT(*) OVER () AS Overall_rides
FROM OLA_DataSet
WHERE Incomplete_Rides = 'yes'
order by TOTAL 




-- 11. List of all rides along with the Booking_status

SELECT 
sum(CASE WHEN Booking_status = 'Success' then 1 else 0 end) AS 'Success',
sum(CASE WHEN Booking_status = 'Canceled by Customer' then 1 else 0 end) AS 'Canceled by Customer',
sum(CASE WHEN Booking_status = 'Canceled by Driver' then 1 else 0 end) AS 'Canceled by Driver',
Sum(CASE WHEN Booking_status = 'Driver Not Found' then 1 else 0 end) AS 'Driver Not Found'
from OLA_DataSet



