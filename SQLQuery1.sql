-- DROP database IF EXISTS testPdclDB;
-- go
-- create database testPdclDB
-- go

use testPdclDB;
go
/*
-- DROP table IF EXISTS PDCL;
-- go
create table PDCL (
	Date	date, -- дата 
	Customer int, -- Номер клиента
	Deal	int, -- Номер кредита
	Currency nvarchar(20), -- Валюта кредита
	Sum	money,-- сумма, вынесенная на просрочку ("+") или выплаченная ("-")
);
go

insert into PDCL([Date], Customer, Deal, Currency, [Sum]) 
values (CONVERT(date,'12.12.2009',104),	111110,	111111,	'RUR',	12000),
(CONVERT(date,'25.12.2009',104),	111110,	111111,	'RUR',	5000),
(CONVERT(date,'12.12.2009',104),	111110,	122222,	'RUR',	10000),
(CONVERT(date,'12.01.2010',104),	111110,	111111,	'RUR',	-10100),
(CONVERT(date,'20.11.2009',104),	220000,	222221,	'RUR',	25000),
(CONVERT(date,'20.12.2009',104),	220000,	222221,	'RUR',	20000),
(CONVERT(date,'21.12.2009',104),	220000,	222221,	'RUR',	-25000),
(CONVERT(date,'29.12.2009',104),	111110,	122222,	'RUR',	-10000)
go
*/
/*
7.	Получить список кредитов, которые на момент расчета имеют непогашенную задолженность, и рассчитать для каждого такого кредита:
1.	Общую (накопленную) сумму просроченного долга непогашенную (не выплаченную) к моменту расчета.
2.	Дату начала текущей просрочки. Под датой начала просрочки, в данной задаче понимается 
    первая дата непрерывного периода, в котором общая сумма просроченного непогашенного долга > 0.
3.	Кол-во дней текущей просрочки.
*/
DECLARE @date DATE;
SET @date = GETDATE();
-- SET @date = CONVERT(date,'28.12.2009',104);

WITH cte AS (
    SELECT 
	  p.[Date],
	  p.Customer,
	  p.Deal,
	  p.[Sum],
	  SUM(p.[Sum]) OVER(PARTITION BY p.Deal ORDER BY p.[Date] ROWS BETWEEN UNBOUNDED PRECEDING AND CURRENT ROW) AS amount,
	  ROW_NUMBER() OVER(ORDER BY p.Deal, p.[Date]) AS rowNumber
	FROM PDCL p
	WHERE p.Date <= @date
)
SELECT 
	c1.Customer,
	c1.Deal,
	SUM(c1.[Sum]) AS amount,
	ISNULL(MAX(c2.[Date]), MIN(c1.[DATE])) AS startDate,
	DATEDIFF(DAY, ISNULL(MAX(c2.[Date]), MIN(c1.[DATE])), @date) as diffDay
FROM cte c1 
LEFT JOIN cte c2 ON c1.amount<=0 AND c1.Deal=c2.Deal AND c2.rowNumber=c1.rowNumber + 1
GROUP BY c1.Customer, c1.Deal
HAVING SUM(c1.[Sum])>0