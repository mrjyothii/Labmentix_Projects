CREATE DATABASE Strava_app

USE Strava_app

ALTER TABLE dailyActivity
ADD MonthName varchar(10);

ALTER TABLE dailyActivity
ADD WeekName varchar(20);

UPDATE dailyActivity
SET [MonthName] = DATENAME(MONTH, ActivityDate)

UPDATE dailyActivity
SET WeekName = DATENAME(WEEKDAY, ActivityDate)

-- Analyzing dailyActivity data

SELECT [MonthName],COUNT(DISTINCT Id) AS No_of_users, COUNT(DISTINCT(ActivityDate)) AS Active_days
FROM dailyActivity
GROUP BY [MonthName]

SELECT DISTINCT Id AS users, COUNT(DISTINCT(ActivityDate)) AS Active_days
FROM dailyActivity
GROUP BY Id
ORDER BY Active_days 


-- 1. Average calories burnt per month

SELECT [MonthName],AVG(Calories) AS Avg_calories_burnt 
FROM dailyActivity
GROUP BY [MonthName]

-- 2. Average Steps per month

SELECT [MonthName],AVG(TotalSteps) AS Avg_Steps_Taken 
FROM dailyActivity
GROUP BY [MonthName]

-- 3. Average Steps per week

SELECT WeekName,AVG(TotalSteps) AS Avg_Steps_Taken 
FROM dailyActivity
GROUP BY WeekName
ORDER BY Avg_Steps_Taken

-- 4. Average Calories per week

SELECT WeekName,AVG(Calories) AS Avg_calories_burnt 
FROM dailyActivity
GROUP BY WeekName
ORDER BY Avg_calories_burnt

-- 5. Average calories burnt per day

SELECT ActivityDate,AVG(Calories) AS Avg_calories_burnt 
FROM dailyActivity
GROUP BY ActivityDate
ORDER BY ActivityDate

-- 6. Active level by distance

SELECT 
    'VeryActiveDistance' AS ActivityType,
    ROUND(SUM(VeryActiveDistance),2) AS TotalDistance,
    ROUND(SUM(VeryActiveDistance) * 100.0 / NULLIF(SUM(VeryActiveDistance + ModeratelyActiveDistance + LightActiveDistance+SedentaryActiveDistance), 0), 2) AS Percentage
FROM dailyActivity

UNION ALL

SELECT 
    'ModeratelyActiveDistance' AS ActivityType,
    ROUND(SUM(ModeratelyActiveDistance),2) AS TotalDistance,
    ROUND(SUM(ModeratelyActiveDistance) * 100.0 / NULLIF(SUM(VeryActiveDistance + ModeratelyActiveDistance + LightActiveDistance+SedentaryActiveDistance), 0), 2) AS Percentage
FROM dailyActivity

UNION ALL

SELECT 
    'LightActiveDistance' AS ActivityType,
    ROUND(SUM(LightActiveDistance),2) AS TotalDistance,
    ROUND(SUM(LightActiveDistance) * 100.0 / NULLIF(SUM(VeryActiveDistance + ModeratelyActiveDistance + LightActiveDistance+SedentaryActiveDistance), 0), 2) AS Percentage
FROM dailyActivity

UNION ALL

SELECT 
    'SedentaryActiveDistance' AS ActivityType,
    ROUND(SUM(SedentaryActiveDistance),2) AS TotalDistance,
    ROUND(SUM(SedentaryActiveDistance) * 100.0 / NULLIF(SUM(VeryActiveDistance + ModeratelyActiveDistance + LightActiveDistance+SedentaryActiveDistance), 0), 2) AS Percentage
FROM dailyActivity;

-- 7. Active level by Minutes

SELECT 
    'VeryActiveMinutes' AS ActivityTime,
    ROUND(SUM(VeryActiveMinutes),2) AS TotalMinutes,
    ROUND(SUM(VeryActiveMinutes) * 100.0 / NULLIF(SUM(VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes+SedentaryMinutes), 0), 2) AS Percentage
FROM dailyActivity

UNION ALL

SELECT 
    'FairlyActiveMinutes' AS ActivityTime,
    ROUND(SUM(FairlyActiveMinutes),2) AS TotalMinutes,
    ROUND(SUM(FairlyActiveMinutes) * 100.0 / NULLIF(SUM(VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes + SedentaryMinutes), 0), 2) AS Percentage
FROM dailyActivity

UNION ALL

SELECT 
    'LightlyActiveMinutes' AS ActivityTime,
    ROUND(SUM(LightlyActiveMinutes),2) AS TotalMinutes,
    ROUND(SUM(LightlyActiveMinutes) * 100.0 / NULLIF(SUM(VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes + SedentaryMinutes), 0), 2) AS Percentage
FROM dailyActivity

UNION ALL

SELECT 
    'SedentaryMinutes' AS ActivityTime,
    ROUND(SUM(SedentaryMinutes),2) AS TotalMinutes,
    ROUND(SUM(SedentaryMinutes) * 100.0 / NULLIF(SUM(VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes + SedentaryMinutes), 0), 2) AS Percentage
FROM dailyActivity;


-- Merging daily_Activity and weight info to see the relation between distance and weight of respondents

ALTER TABLE weightLogInfo
ADD BMI_Category varchar(20);

UPDATE weightLogInfo
SET BMI_Category = 
CASE 
WHEN BMI < 18.5 THEN 'Underweight' 
WHEN BMI BETWEEN 18.5 AND 24.9 THEN 'Normal' 
WHEN BMI BETWEEN 25 AND 29.9 THEN 'Overweight' 
ELSE 'Obese' END  

Select BMI_Category, COUNT(*) AS 'No. of users' FROM weightLogInfo
GROUP BY BMI_Category

SELECT d.*, w.WeightKg,W.WeightPounds,W.BMI,W.Fat,W.BMI_Category INTO Daily_weight FROM dailyActivity d
INNER JOIN weightLogInfo w 
ON w.Id = d.Id AND d.ActivityDate = CAST(w.Date AS DATE)

-- 8. Analyze dailyActivity data with weight_info data

SELECT Id,ROUND(AVG(WeightKg),0) AS [Weight] , BMI_category,
ROUND(AVG(BMI),0) AS BMI,
ROUND(AVG(Calories),2) AS Avg_calories,
ROUND(AVG(TotalDistance),2) AS 'Avg_Distance(km)',
ROUND(AVG(VeryActiveDistance),2) AS VeryActiveDistance,
ROUND(AVG(LightActiveDistance),2) AS LightActiveDistance,
ROUND(AVG(ModeratelyActiveDistance),2) AS ModeratelyActiveDistance,
ROUND(AVG(SedentaryActiveDistance),2) AS SedentaryActiveDistance,
count(*) AS [Days] FROM Daily_weight
GROUP BY Id,BMI_category
ORDER BY [Weight]



-- Finding duplicates in daily_sleep data


select Id,TotalMinutesAsleep,TotalTimeInBed from sleepDay 
group by Id,TotalMinutesAsleep,TotalTimeInBed
having count(*) > 1

-- Removing duplicates

WITH cte AS 
(SELECT *, 
ROW_NUMBER() OVER (PARTITION BY id,TotalMinutesAsleep,TotalTimeInBed ORDER BY id) AS rn
FROM sleepDay)
DELETE FROM cte
WHERE rn > 1;

-- 9. Analyze daily_sleep data

SELECT Id,
count(*) as No_of_records,
AVG(TotalMinutesAsleep)/60 AS Hrs_Asleep,
AVG(TotalTimeInBed)/60 AS 'TimeInBed(Hr)'
FROM sleepDay
where TotalSleepRecords < 2
GROUP BY Id
ORDER BY No_of_records

-- Merging daily_Activity and daily_sleep to see the relation between distance and sleep of respondents

SELECT d.*, s.TotalMinutesAsleep,s.TotalTimeInBed INTO Daily_sleep FROM dailyActivity d
INNER JOIN sleepDay s 
ON s.Id = d.Id AND d.ActivityDate = CAST(s.SleepDay AS DATE)


-- ALTER TABLE Daily_sleep Add column_sleeping hrs

ALTER TABLE Daily_sleep
ADD sleeping_hrs VARCHAR(20);

ALTER TABLE Daily_sleep
ADD steps_taken VARCHAR(25);

UPDATE Daily_sleep
SET sleeping_hrs =
    CASE 
        WHEN TotalMinutesAsleep < 300 THEN 'Less than 5h'
        WHEN TotalMinutesAsleep BETWEEN 300 AND 480 THEN 'Less than 8h'
        ELSE 'More than 9h'
    END;

UPDATE Daily_sleep
SET steps_taken =
    CASE 
        WHEN TotalSteps <= 5000 THEN  'Less than 5000 steps'
        WHEN TotalSteps <= 10000 THEN  '5001 to 10000 steps'
        WHEN TotalSteps <= 15000 THEN  '10001 to 15000 steps'
        ELSE 'More than 15000 steps'
    END;

-- 10. Average distance vs. Average steps vs. average sleep per user

SELECT Id,count(*) as Data_present,
AVG(TotalMinutesAsleep)/60 AS Hrs_Asleep,
AVG(TotalTimeInBed)/60 AS 'TimeInBed(Hr)',
ROUND(AVG(TotalDistance),2) AS Distance, 
ROUND(AVG(TotalSteps),2) AS Steps,
ROUND(AVG(Calories),2) AS Calories 
FROM Daily_sleep
GROUP BY Id
ORDER BY Data_present

-- Sleep hours by month

SELECT DATENAME(MONTH,SleepDay) as Months,
AVG(TotalMinutesAsleep)/60 AS Hrs_Asleep
FROM sleepDay
GROUP BY DATENAME(MONTH,SleepDay)

-- Sleep hours by week

SELECT DATENAME(WEEKDAY,SleepDay) as Weekname,
AVG(TotalMinutesAsleep)/60 AS Hrs_Asleep
FROM sleepDay
GROUP BY DATENAME(WEEKDAY,SleepDay)

-- Sleep hours by Id

SELECT Id,
AVG(TotalMinutesAsleep)/60 AS Hrs_Asleep
FROM sleepDay
GROUP BY Id
order by Hrs_Asleep


-- 11. Sleep quality by steps

SELECT * FROM(
SELECT sleeping_hrs, steps_taken, COUNT(*) AS Data_present
FROM Daily_sleep
GROUP BY sleeping_hrs, steps_taken) AS SourceTable
PIVOT (SUM(Data_present)
FOR sleeping_hrs IN ([Less than 5h], [Less than 8h], [More than 9h])) AS PivotTable;

-- 12 struggling to sleep vs. Steps taken

SELECT Id, AVG(TotalSteps) AS Avg_steps_taken,
AVG(TotalMinutesAsleep) AS Avg_sleep,
AVG(TotalTimeInBed - TotalMinutesAsleep)/60.0 AS 'struggling_tosleep (min)'
FROM Daily_sleep
GROUP BY Id


-- HEART_RATE ANALYSIS

ALTER TABLE heartrate_seconds_merged
ALTER COLUMN [Time] Date

-- 13 Average heart_rate per user

select id,count(distinct time) as "days_count",count(*) as "entries",AVG(Value) AS Avg_heartrate from heartrate_seconds_merged
group by id
order by "days_count"

-- 14 Average heart_rate per month per user

SELECT * FROM (SELECT Id,DATENAME(MONTH, Time) AS Months,Value FROM heartrate_seconds_merged) AS src
PIVOT(AVG(Value) FOR Months IN ([April],[May])) AS PVT
ORDER BY Id;

SELECT Datename(month,Time) AS Months,count(distinct time) as "days_count",Avg(Value) AS Avg_heart_rate FROM heartrate_seconds_merged
group by Datename(month,Time)

-- 15 Average heart_rate per week per user

SELECT * FROM (SELECT Id,DATENAME(WEEKDAY, Time) AS [Weekday],Value FROM heartrate_seconds_merged) AS src
PIVOT(AVG(Value) FOR [Weekday] IN ([Sunday],[Monday],[Tuesday],[Wednesday],[Thursday],[Friday],[Saturday])) AS PVT
ORDER BY Id;


SELECT Datename(WEEKDAY,Time) AS 'Weekday',Avg(Value) AS Avg_heart_rate FROM heartrate_seconds_merged
group by Datename(WEEKDAY,Time)

-- Merging daily_Activity and heartrate_seconds_merged to see the relation between distance and hearrate of respondents

SELECT d.*, h.[Value] INTO Daily_heartrate FROM dailyActivity d
INNER JOIN heartrate_seconds_merged h 
ON h.Id = d.Id AND d.ActivityDate = h.[Time]

--16 Total heartrate vs. Total distance vs. calories

Select Id, ROUND(AVG(TotalDistance),2) AS Avg_distance,
ROUND(AVG(Calories),2) AS Avg_calories, 
AVG(Value) AS Avg_heartrate,
COUNT(DISTINCT ActivityDate) AS Days
FROM Daily_heartrate
GROUP BY Id
ORDER BY Avg_heartrate





















