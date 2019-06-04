SELECT DISTINCT B.callreferenceID, B.MincreatedON, B.MaxCreatedON, A.[status], Diff 
FROM [RDS].[Membership].[vw_CallHistory] A, 
(	SELECT DISTINCT CallReferenceID, MIN(CreatedON) AS MincreatedON, MAX(CreatedON) AS MaxCreatedON, 
	DATEDIFF(DAY, MIN(CreatedON), MAX(CreatedON)) AS Diff
	FROM [RDS].[Membership].[vw_CallHistory] 
	WHERE
	PersonID =  3072375 AND
	Result = 'Escalation'
	GROUP BY callreferenceID) B
--------------------------------------------------------------------------------------
SELECT T.CallReferenceID, A.MincreatedON, A.MaxCreatedON, [Status], A.Diff
FROM [RDS].[Membership].[vw_CallHistory] T
INNER JOIN 
(	SELECT CallReferenceID, min(CreatedON) AS MincreatedON, MAX(CreatedON) AS MaxCreatedON, 
	DATEDIFF(DAY,MIN(CreatedON), MAX(CreatedON)) AS Diff
	FROM [RDS].[Membership].[vw_CallHistory] WHERE
	PersonID =  3072375 AND
	Result = 'Escalation'
	GROUP BY CallReferenceID) A 
ON T.CallReferenceID = A.CallReferenceID 
	AND A.MaxCreatedON = T.CreatedON