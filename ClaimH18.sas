libname hm "E:\SAS_Projects\Users\mitikirim\Humana\18";
libname Mem "E:\SAS_Projects\Users\mitikirim\BenefitManagement\Humana\Data";

PROC SQL;
CREATE TABLE claims18 AS 
SELECT CATX('',a.Subscriber_ID, a.Member_Seq) AS UniqueMem, A.Subscriber_ID, A.Member_Seq, C.Service_Date, A.Provider_ID, 
A.ProviderLocation_Seq, D.State AS ProviderState, substr(D.Zip_Code,1,5) AS ZipCode, 
(CASE WHEN A.Group_ID = 'HumMCareDC' THEN 'Medicare' ELSE '' END) AS Report_Market length = 24,  A.Group_ID AS Market,
A.Group_ID, A.Plan_ID, A.Network_ID, A.Claim_Number, C.Claim_Seq, A.New_Claim_Number, A.Old_Claim_Number, 
C.ClaimReviewSetID, A.Entry_Date AS ClaimEntry_Date, A.Records_Requested_Date, A.Received_Date, A.Update_Date,
C.Procedure_Code, C.Ex_Code, A.Diagnostic_Code1, C.Paid_Amt AS Paid, C.Plan_Price AS Allowed, C.Billed_Price AS Billed, C.Svc_Count, 
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
    AND ((A.Group_ID)='HumFIDC' Or (A.Group_ID)='HumFIDC_TXGF' OR (A.Group_ID)='HumMCareDC') 
   	AND ((A.Plan_ID)='HumDCMNec' OR 'HumDCMNecRetro')
    AND ((C.Service_Date) Between '01JAN2018'd And '31DEC2018'd)
    AND ((A.New_Claim_Number IS NULL OR A.New_Claim_Number = .))
    )
;QUIT;
/*Get County*/
PROC SQL;
CREATE TABLE h1d AS
SELECT DISTINCT(B.ZipCode), A.CountyName
FROM claims18 B LEFT JOIN CHPA.ZipCodes A ON B.ZipCode = A.ZIPCode
ORDER BY CountyName
;QUIT;
/* Set County */
PROC SQL;
CREATE TABLE h1e AS
SELECT A.*, B.CountyName AS ProviderCounty
FROM claims18 A 
LEFT JOIN h1d B ON
A.ZipCode = B.ZipCode;
QUIT;
/* Get OON */
PROC SQL;
CREATE TABLE h1d AS
SELECT DISTINCT(B.Network_ID), A.OON
FROM h1e B INNER JOIN CHPA.Networks A ON B.Network_ID = A.Network_ID
;QUIT;
/* Set OON */
PROC SQL;
CREATE TABLE h1f AS
SELECT A.*, B.OON AS OON_Flag
FROM h1e A 
LEFT JOIN h1d B ON
A.Network_ID = B.Network_ID
;QUIT;
/* Update HumFIDC_TXGF to HumFIDC */
PROC SQL;
UPDATE h1f
SET Market = 'HumFIDC'
WHERE Market = 'HumFIDC_TXGF'
;QUIT;
/* Set CL */
PROC SQL;
UPDATE h1f
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
;QUIT;
/* Set CNL */
PROC SQL;
UPDATE h1f
SET Report_Market = 'CNL'
WHERE(
((Report_Market IS NULL) OR (Report_Market = ''))
AND (Market = 'HumFIDC')
)
;QUIT;

/* Get MemZip */
PROC SQL;
CREATE TABLE h1gmz AS
SELECT DISTINCT(A.UniqueMem), B.MemZipCode, B.Birth_Date AS DOB, B.Gender, B.State AS MemberState, B.City AS MemberCity
FROM h1f A INNER JOIN Mem.humanamembers18 B ON
A.UniqueMem = B.Unique_Member
ORDER BY Gender
;QUIT;
/* Set MemZip */
PROC SQL;
CREATE TABLE humanaclaims18 AS
SELECT A.*, substr(B.MemZipCode,1,5)  AS MemZipCode, B.DOB, B.Gender, B.MemberState, B.MemberCity
FROM h1f A INNER JOIN h1gmz B ON A.UniqueMem = B.UniqueMem
;QUIT;
/* Age Bucket */
DATA Mem.humanaclaims18;
	SET humanaclaims18;
	Age = INT(YRDIF(DATEPART(DOB),'01JAN2018'd,'ACTUAL'));
	LENGTH AgeBucket $7;
		IF Age <= 18 THEN AgeBucket = '0-18';
		ELSE IF 18 <= Age <= 24 THEN AgeBucket = '18-24';
		ELSE IF 25 <= Age <= 34 THEN AgeBucket = '25-34';
		ELSE IF 35 <= Age <= 44 THEN AgeBucket = '35-44';
		ELSE IF 45 <= Age <= 54 THEN AgeBucket = '44-54';
		ELSE IF 55 <= Age <= 64 THEN AgeBucket = '55-64';
		ELSE IF 65 <= Age <= 84 THEN AgeBucket = '65-84';
		ELSE AgeBucket = '> 84';
RUN;

/* Random Tests */

PROC SQL;
SELECT DISTINCT Gender FROM hm.humanaClaims18
;QUIT;

/* Paid <> Allowed */
PROC SQL;
CREATE TABLE PaidAllowed AS
SELECT * FROM hm.humanaclaims18
WHERE ((Ex_Code IS NULL OR Ex_Code = '') AND (Plan_Price <> Paid_Amt));
SELECT SUM(Paid_Amt) AS PaidSum, SUM(Plan_Price) AS AllowedSum FROM PaidAllowed;
SELECT (SUM(Paid_Amt) - SUM(Plan_Price)) AS Difference FROM PaidAllowed
;QUIT;

/* */
PROC SQL;
SELECT Report_Market, COUNT(*) FROM hm.h1f
GROUP BY Report_Market
;QUIT;
/*  */
PROC SQL;
SELECT ProviderCounty, COUNT(*) FROM hm.h1f
WHERE ProviderState = 'WA'
GROUP BY ProviderCounty
;QUIT;
PROC SQL;
SELECT COUNT(*), Network_ID FROM hm.claims18
GROUP BY Network_ID
;QUIT;

PROC SQL;
SELECT COUNT(*), Network_ID FROM hm.h1f
GROUP BY Network_ID
;QUIT;

libname hhh "E:\SAS_Projects\Users\mitikirim\BenefitManagement\Humana\Data";
PROC SQL;
SELECT COUNT(*), Network_ID FROM hhh.humanaclaims18
GROUP BY Network_ID
;QUIT;