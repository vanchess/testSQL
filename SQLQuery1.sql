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
	Customer int, -- Ќомер клиента
	Deal	int, -- Ќомер кредита
	Currency nvarchar(20), -- ¬алюта кредита
	Sum	money,-- сумма, вынесенна€ на просрочку ("+") или выплаченна€ ("-")
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
7.	ѕолучить список кредитов, которые на момент расчета имеют непогашенную задолженность, и рассчитать дл€ каждого такого кредита:
1.	ќбщую (накопленную) сумму просроченного долга непогашенную (не выплаченную) к моменту расчета.
2.	ƒату начала текущей просрочки. ѕод датой начала просрочки, в данной задаче понимаетс€ 
    перва€ дата непрерывного периода, в котором обща€ сумма просроченного непогашенного долга > 0.
3.	 ол-во дней текущей просрочки.
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