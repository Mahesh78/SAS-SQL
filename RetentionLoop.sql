
DECLARE @i int = 201800

WHILE @i < 201905
BEGIN
SET @i = @i+1
	SELECT A.EndYrMo, (COUNT(DISTINCT InitialOrderId)) AS [Termed]--, (3669-COUNT(DISTINCT InitialOrderId)) AS [Count] --A.StartDate, 
	FROM [RDS].[Membership].[vw_TrxMonthMember] A
	WHERE A.ProductID = '226'
	AND A.ClientID = 5771
	AND A.StartYrMo = @i
	AND (A.EndYrMo BETWEEN @i AND 201905)
	AND A.TrxType = 'Subscriptions'
	GROUP BY A.EndYrMo
	ORDER BY A.EndYrMo
END