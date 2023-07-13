--Select employee name with its manager name
SELECT e.firstName, e.lastName, m.firstName AS managerFirstName, m.lastName AS managerLastName
FROM employee e
LEFT JOIN employee m ON e.managerId = m.employeeId
ORDER BY e.firstName;

--Sales people with zero sales
SELECT e.firstName, e.lastName, e.title, s.salesAmount
FROM employee e 
LEFT JOIN sales s ON e.employeeId = s.employeeId
WHERE e.title = 'Sales Person' AND s.salesAmount IS NULL;

--Get all customers and sales
SELECT c.customerId, s.salesId, c.firstName, c.lastName, s.salesAmount
FROM customer c
INNER JOIN sales s ON c.customerId = s.customerId
UNION
SELECT c.customerId, s.salesId, c.firstName, c.lastName, s.salesAmount
FROM customer c
LEFT JOIN sales s ON c.customerId = s.customerId
UNION
SELECT c.customerId, s.salesId, c.firstName, c.lastName, s.salesAmount
FROM sales s
LEFT JOIN customer c ON c.customerId = s.customerId
ORDER BY c.customerId, s.salesId;

--Total number of cars sold per employee
SELECT e.employeeId, e.firstName, e.lastName, e.title, count(*) AS totalCarsSold
FROM employee e
INNER JOIN sales s ON e.employeeId = s.employeeId
GROUP BY e.employeeId
ORDER BY totalCarsSold DESC;

--The least and most expensive car sold by employee
SELECT e.employeeId, e.firstName, e.lastName, e.title, 
  min(s.salesAmount) AS leastExpensiveCarSold, max(s.salesAmount) AS mostExpensiveCarSold
FROM employee e
INNER JOIN sales s ON e.employeeId = s.employeeId
GROUP BY e.employeeId;

--Employees who has sold more than 5 cars this year
SELECT e.employeeId, e.firstName, e.lastName, e.title, count(*) AS totalCarsSold
FROM employee e
INNER JOIN sales s ON e.employeeId = s.employeeId
WHERE S.soldDate >= date('now', 'start of year')
GROUP BY e.employeeId
HAVING totalCarsSold >= 5
ORDER BY totalCarsSold DESC;

--Report that shows the sales per year
WITH cte AS (SELECT salesAmount, strftime('%Y', soldDate) AS soldYear
FROM sales)

SELECT soldYear, count(*) AS totalSales, FORMAT ("$%.2f", sum(salesAmount)) AS annualAmount
FROM cte
GROUP BY soldYear
ORDER BY soldYear;

--Report that shows the amount of sales per employee for each month in 2021
WITH cte AS (SELECT employeeId, salesAmount, 
             strftime('%Y', soldDate) AS soldYear, strftime('%m', soldDate) AS soldMonth
FROM sales)

SELECT e.employeeId, e.firstName, e.lastName, c.soldMonth, count(*) AS totalSales, 
       FORMAT ("$%.2f", sum(c.salesAmount)) AS monthlyAmount
FROM employee e
INNER JOIN cte c ON e.employeeId = c.employeeId
WHERE c.soldYear = '2021'
GROUP BY e.employeeId, c.soldMonth
ORDER BY e.employeeId, c.soldMonth;

--All sales where the car purchased was electric
SELECT s.salesId, c.model, c.EngineType, s.salesAmount, s.soldDate
FROM sales s
INNER JOIN (SELECT i.inventoryId AS inventoryId, m.model AS model, m.EngineType AS EngineType 
            FROM inventory i INNER JOIN model m ON i.modelId = m.modelId) c
ON s.inventoryId = c.inventoryId
WHERE c.EngineType = 'Electric';