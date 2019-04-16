libname hm "E:\SAS_Projects\Users\mitikirim\Humana\18";


PROC SQL;

CREATE TABLE hm.claims18 AS 

SELECT CAT(a.Subscriber_ID, '', a.Member_Seq) AS UniqueMem, A.Subscriber_ID, A.Member_Seq, C.Service_Date, A.Provider_ID, 
A.ProviderLocation_Seq, D.State AS ProviderState, substr(D.Zip_Code,1,5) AS ZipCode, 
(CASE WHEN A.Group_ID = 'HumMCareDC' THEN 'Medicare' ELSE '' END) AS Report_Market,  A.Group_ID AS Market,
A.Group_ID, A.Plan_ID, A.Network_ID, A.Claim_Number, C.Claim_Seq, A.New_Claim_Number, A.Old_Claim_Number, 
C.ClaimReviewSetID, A.Entry_Date AS ClaimEntry_Date, A.Records_Requested_Date, A.Received_Date, A.Update_Date,
C.Procedure_Code, C.Ex_Code, A.Diagnostic_Code1, C.Billed_Price, C.Plan_Price, C.Svc_Count, 
A.Ex_Code1, A.Ex_Code2, A.Batch_Number, A.Batch_Claim, A.From_Batch, A.From_Claim

FROM 
(   (CHPA.Claim A
    INNER JOIN CHPA.Groups B
    ON A.Group_ID = B.Group_ID) 
    INNER JOIN CHPA.ClaimDetail C
    ON A.Claim_Number = C.Claim_Number
)
INNER JOIN CHPA.ProviderAddress D
ON (A.ProviderLocation_Seq = D.Location_Seq) 
AND (A.Provider_ID = D.Provider_ID)

WHERE (
    ((B.ClientId)=124) 
    AND ((A.Group_ID)='HumFIDC' Or (A.Group_ID)='HumFIDC_TXGF') 
    AND ((A.Plan_ID)='HumDCMNec') 
    AND ((C.Service_Date) Between '01JAN2018'd And '31DEC2018'd)
    AND ((A.New_Claim_Number IS NULL) )
    )
    
OR (
    ((B.ClientId)=124) 
    AND ((A.Group_ID)='HumMCareDC') 
    AND ((A.Plan_ID)='HumDCMNecRetro') 
    AND ((C.Service_Date) Between '01JAN2018'd And '31DEC2018'd) 
    AND ((A.New_Claim_Number IS NULL) )
        /*AND ((C.ClaimReviewSetID) Is Null)*/
    )
;
QUIT;


/*Get County*/
PROC SQL;
CREATE TABLE hm.h1d AS
SELECT DISTINCT(B.ZipCode), A.CountyName
FROM hm.claims18 B LEFT JOIN CHPA.ZipCodes A ON B.ZipCode = A.ZIPCode
ORDER BY CountyName
;
QUIT;

PROC SQL;

CREATE TABLE hm.h1e AS
SELECT A.*, B.CountyName AS ProviderCounty
FROM hm.claims18 A 
LEFT JOIN hm.h1d B ON
A.ZipCode = B.ZipCode;
QUIT;


PROC SQL;

CREATE TABLE hm.h1f AS
SELECT DISTINCT(B.Network_ID), A.OON
FROM hm.h1e B INNER JOIN CHPA.Networks A ON B.Network_ID = A.Network_ID
;
QUIT;
/*Set OON*/
PROC SQL;

CREATE TABLE hm.h1g AS
SELECT A.*, B.OON AS OON_Flag
FROM hm.h1e A 
LEFT JOIN hm.h1f B ON
A.Network_ID = B.Network_ID
;
QUIT;

PROC SQL;
UPDATE hm.h1g
SET Market = 'HumFIDC'
WHERE Market = 'HumFIDC_TXGF'
;
QUIT;

PROC SQL;

UPDATE hm.h1g
SET Report_Market = 'CL'
WHERE (

((Report_Market IS NULL) OR (Report_Market = ''))
AND (Market = 'HumFIDC')
AND (ProviderState IN ('AZ','IL','GA','OH','KY'))
)
OR
(
((Report_Market IS NULL) OR (Report_Market = ''))
AND (Market = 'HumFIDC')
AND (ProviderState = 'FL')
AND (ProviderCounty IN ('BROWARD', 'MIAMI-DADE','PALM BEACH'))
)
OR
(
((Report_Market IS NULL) OR (Report_Market = ''))
AND (Market = 'HumFIDC')
AND (ZipCode LIKE '470%' OR ZipCode LIKE '471%' OR ZipCode LIKE '472%' 
OR ZipCode LIKE '473%' OR ZipCode LIKE '463%' OR ZipCode LIKE '464%')
)
;
QUIT;

PROC SQL;
UPDATE hm.h1g
SET Report_Market = 'CNL'
WHERE(
((Report_Market IS NULL) OR (Report_Market = ''))
AND (Market = 'HumFIDC')
)
;
QUIT;


PROC SQL;
SELECT Report_Market, COUNT(*) FROM hm.h1g
GROUP BY Report_Market

;
QUIT;


PROC SQL;
SELECT ProviderCounty, COUNT(*) FROM hm.h1g
WHERE ProviderState = 'WA'
GROUP BY ProviderCounty
;QUIT;

PROC SQL;

CREATE TABLE hm.h1gmz AS

SELECT DISTINCT(A.UniqueMem), B.Zip_Code AS MemZipCode

FROM hm.h1g A LEFT JOIN CHPA.Members B ON

A.UniqueMem = (CAT(B.Subscriber_ID, '', B.Member_Seq))

ORDER BY UniqueMem

;QUIT;

PROC SQL;

CREATE TABLE hm.h1g18 AS

SELECT A.*, substr(B.MemZipCode,1,5)  AS MemZipCode

FROM hm.h1g A LEFT JOIN hm.h1gmz B ON A.UniqueMem = B.UniqueMem

;QUIT;