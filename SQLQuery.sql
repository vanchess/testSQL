USE testDB;
GO

-- 1. выводит список всех людей с названиями их организаций или с NULL вместо названия организации если для человека не указана организация
SELECT p.name, o.name FROM test.tPerson p
LEFT JOIN test.tOrg o ON o.oid = p.oid;

-- 2. список всех  организаций, в которых никто не работает
SELECT o.name FROM test.tOrg o 
LEFT JOIN test.tPerson p ON o.oid = p.oid
WHERE p.oid IS NULL;

-- или 
SELECT o.name FROM test.tOrg o
LEFT JOIN test.tPerson p ON o.oid = p.oid
GROUP BY o.name
HAVING COUNT(p.oid) = 0;

-- 3. названий всех организаций с количеством трудоустроенных в них людей
-- Вар1 – только организации, в которых кто-то есть 
SELECT o.name, COUNT(p.oid) FROM test.tOrg o
LEFT JOIN test.tPerson p ON o.oid = p.oid
GROUP BY o.name
HAVING COUNT(p.oid) > 0;

-- Вар2 – полный список 
SELECT o.name, COUNT(p.oid) FROM test.tOrg o
LEFT JOIN test.tPerson p ON o.oid = p.oid
GROUP BY o.name

GO

-- 4. Таблица test.tOrg задает иерархическую структуру организаций т.е. poid – ссылка на родительский oid. 
-- Задача написать функцию, которая по переданному oid вернет строку, содержащую «путь» от корня до переданного oid, 
-- например getFullOrgName(9) вернет /Lukoil/OOO Perm NP/Accounting
DROP function IF EXISTS test.getFullOrgName;
GO
Create function test.getFullOrgName(@oid as int) returns nvarchar(MAX) as
begin
	DECLARE @ret nvarchar(MAX);
	DECLARE @poid int;
	SELECT @poid = o.poid, @ret = ('/' + o.name) FROM test.tOrg o WHERE o.oid = @oid;
	WHILE ( @poid IS NOT NULL)
	BEGIN
		SELECT @poid = o.poid, @ret = ('/' + o.name + @ret) FROM test.tOrg o WHERE o.oid = @poid;
	END
	RETURN @ret;
End
GO
SELECT test.getFullOrgName(9);


-- 5. Загрузил из excel с помошью иморта данных в Management Studio


-- 6. запрос, который вернет «остатки по счетам» т.е  для каждого из счетов выведет его 
--    название, дату последнего «движения денег» по счету и остаток на счету 
SELECT a.accNumber, b.stDate, b.balance FROM test.tAccount a
LEFT JOIN (
	SELECT * FROM test.tAccountRest ar 
	WHERE ar.stDate = (SELECT MAX(ar2.stDate) FROM test.tAccountRest ar2 WHERE ar2.aid = ar.aid)
) AS b on a.aid = b.aid
