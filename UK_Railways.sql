--# UK_Railways Analysis

-- Total Tickets 

select
count (Transaction_ID) as total_tickets
from Transactions
------------------------------------------------------------------------------------------------
-- Successful Rides

select
count(Transaction_ID) as Successful_ride
from Transactions
where Journey_Status in ('On Time', 'Delayed')
------------------------------------------------------------------------------------------------
-- Cancelled rides

select
count(Transaction_ID) as Cancelled_ride
From Transactions
where Journey_Status = 'Cancelled'
--------------------------------------------------------------------------------------------------
-- Top 10 most used route

SELECT TOP 10
    CONCAT(t.Departure_Station, ' ---> ', t.Arrival_Destination) AS Route_Name,
    COUNT(tr.Transaction_ID) AS Total_Rides
FROM 
    Transactions tr
JOIN 
    Tickets t ON tr.Ticket_ID = t.Ticket_ID
WHERE 
    tr.Journey_Status <> 'Cancelled'
GROUP BY 
    t.Departure_Station, 
    t.Arrival_Destination
ORDER BY 
    Total_Rides DESC
--------------------------------------------------------------------------------------------------------------
--  Peak Tavel Times (By Hour)
SELECT TOP 5
    DATEPART(HOUR, Departure_Time) AS Hour_of_Day,
    COUNT(Transaction_ID) AS Total_Departures
FROM 
    Transactions
WHERE 
    Journey_Status <> 'Cancelled'
GROUP BY 
    DATEPART(HOUR, Departure_Time)
ORDER BY 
    Total_Departures DESC
------------------------------------------------------------------------------------------------------------
-- Distribution of Passengers by Purchase Type and Payment Method

SELECT 
    p.Purchase_Type,
    p.Payment_Method,
    COUNT(t.Transaction_ID) AS Total
FROM 
    Transactions t
JOIN 
    Purchases p ON t.Purchase_ID = p.Purchase_ID
WHERE 
    t.Journey_Status <> 'Cancelled'
GROUP BY 
    p.Purchase_Type, 
    p.Payment_Method
ORDER BY 
    p.Purchase_Type, 
    Total DESC
---------------------------------------------------------------------------------------------------
-- Distribution of Passengers by Ticket Class and Ticket Type

SELECT 
    t.Ticket_Class,
    t.Ticket_Type,
    COUNT(tr.Transaction_ID) AS Total
FROM 
    Transactions tr
JOIN 
    Tickets t ON tr.Ticket_ID = t.Ticket_ID
WHERE 
    tr.Journey_Status <> 'Cancelled'
GROUP BY 
    t.Ticket_Class, 
    t.Ticket_Type
ORDER BY 
    Total DESC
-------------------------------------------------------------------------------------------------------
-- Journey Status

SELECT 
    Journey_Status, 
    COUNT(Transaction_ID) AS Total_Trips,
    CAST(COUNT(Transaction_ID) * 100.0 / (SELECT COUNT(*) FROM Transactions) AS DECIMAL(2)) AS Percentage
FROM 
    Transactions
GROUP BY 
    Journey_Status
ORDER BY 
    Total_Trips DESC
----------------------------------------------------------------------------------------------------------------
-- Reasons for (Delays & Cancellations)

SELECT TOP 5
Reason_for_Delay, 
COUNT(Transaction_ID) AS Incident_Count
FROM 
    Transactions
WHERE 
    Journey_Status IN ('Delayed','Cancelled')
GROUP BY 
    Reason_for_Delay
ORDER BY 
    Incident_Count DESC
---------------------------------------------------------------------------------------------------------
-- Delay reasons cause the longest wait times
SELECT 
    Reason_for_Delay,
    AVG(DATEDIFF(MINUTE, Arrival_Time, Actual_Arrival_Time)) AS Avg_Delay_Minutes
FROM Transactions
WHERE Journey_Status = 'Delayed'
  AND Actual_Arrival_Time IS NOT NULL
GROUP BY Reason_for_Delay
ORDER BY Avg_Delay_Minutes DESC
---------------------------------------------------------------------------------------------------------------
-- Top 10 Most Delayed Route

SELECT TOP 10
    CONCAT(t.Departure_Station, ' ---> ', t.Arrival_Destination) AS Route_Name,
    COUNT(tr.Transaction_ID) AS Delayed_Count
FROM 
    Transactions tr
JOIN 
    Tickets t ON tr.Ticket_ID = t.Ticket_ID
WHERE 
    tr.Journey_Status = 'Delayed'
GROUP BY 
    t.Departure_Station, 
    t.Arrival_Destination
ORDER BY 
    Delayed_Count DESC
-----------------------------------------------------------------------------------------------------------------
-- Total Revenue, Refunds and Net Revenue
SELECT 
    SUM(t.Price) AS Total_Revenue,
    SUM(CASE WHEN tr.Refund_Request = 1 THEN t.Price ELSE 0 END) AS  Total_Refunds ,
    (SUM(t.Price) - SUM(CASE WHEN tr.Refund_Request = 1 THEN t.Price ELSE 0 END)) AS Net_Revenue
FROM 
    Transactions tr
JOIN 
    Tickets t ON tr.Ticket_ID = t.Ticket_ID
------------------------------------------------------------------------------------------------------------------------------
-- Which routes are costing us the most in refunds?
SELECT TOP 5
    t.Departure_Station,
    t.Arrival_Destination,
    SUM(t.Price) AS Lost_Revenue
FROM Transactions tr
JOIN Tickets t ON tr.Ticket_ID = t.Ticket_ID
WHERE tr.Refund_Request = 1
GROUP BY t.Departure_Station, t.Arrival_Destination
ORDER BY Lost_Revenue DESC
--------------------------------------------------------------------------------------------------------------------
-- Revenue By Ticket Class & Type

SELECT 
    t.Ticket_Class,
    t.Ticket_Type,
    (SUM(t.Price) - SUM(CASE WHEN tr.Refund_Request = 1 THEN t.Price ELSE 0 END)) AS Net_Revenue
FROM 
    Transactions tr
JOIN 
    Tickets t ON tr.Ticket_ID = t.Ticket_ID
GROUP BY 
    t.Ticket_Class,
    t.Ticket_Type
ORDER BY 
    Net_Revenue DESC
----------------------------------------------------------------------------------------------------------------------
-- Top 5 Route by Revenue

SELECT TOP 5
    CONCAT(t.Departure_Station, ' ---> ', t.Arrival_Destination) AS Route_Name,
    (SUM(t.Price) - SUM(CASE WHEN tr.Refund_Request = 1 THEN t.Price ELSE 0 END)) AS Net_Revenue
FROM 
    Transactions tr
JOIN 
    Tickets t ON tr.Ticket_ID = t.Ticket_ID
GROUP BY 
    t.Departure_Station, 
    t.Arrival_Destination
ORDER BY 
    Net_Revenue DESC
    ---------------------------------------------------------------------------------------------------