USE testDB;
GO

-- 1. ������� ������ ���� ����� � ���������� �� ����������� ��� � NULL ������ �������� ����������� ���� ��� �������� �� ������� �����������
SELECT p.name, o.name FROM test.tPerson p
LEFT JOIN test.tOrg o ON o.oid = p.oid;

-- 2. ������ ����  �����������, � ������� ����� �� ��������
SELECT o.name FROM test.tOrg o 
LEFT JOIN test.tPerson p ON o.oid = p.oid
WHERE p.oid IS NULL;

-- ��� 
SELECT o.name FROM test.tOrg o
LEFT JOIN test.tPerson p ON o.oid = p.oid
GROUP BY o.name
HAVING COUNT(p.oid) = 0;

-- 3. �������� ���� ����������� � ����������� ��������������� � ��� �����
-- ���1 � ������ �����������, � ������� ���-�� ���� 
SELECT o.name, COUNT(p.oid) FROM test.tOrg o
LEFT JOIN test.tPerson p ON o.oid = p.oid
GROUP BY o.name
HAVING COUNT(p.oid) > 0;

-- ���2 � ������ ������ 
SELECT o.name, COUNT(p.oid) FROM test.tOrg o
LEFT JOIN test.tPerson p ON o.oid = p.oid
GROUP BY o.name

GO

-- 4. ������� test.tOrg ������ ������������� ��������� ����������� �.�. poid � ������ �� ������������ oid. 
-- ������ �������� �������, ������� �� ����������� oid ������ ������, ���������� ������ �� ����� �� ����������� oid, 
-- �������� getFullOrgName(9) ������ /Lukoil/OOO Perm NP/Accounting
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


-- 5. �������� �� excel � ������� ������ ������ � Management Studio


-- 6. ������, ������� ������ �������� �� ������ �.�  ��� ������� �� ������ ������� ��� 
--    ��������, ���� ���������� ��������� ����� �� ����� � ������� �� ����� 
SELECT a.accNumber, b.stDate, b.balance FROM test.tAccount a
LEFT JOIN (
	SELECT * FROM test.tAccountRest ar 
	WHERE ar.stDate = (SELECT MAX(ar2.stDate) FROM test.tAccountRest ar2 WHERE ar2.aid = ar.aid)
) AS b on a.aid = b.aid
