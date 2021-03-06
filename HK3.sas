LIBNAME data "E:\SAS_Projects\Users\mitikirim\BenefitManagement\Highmark\Data";
LIBNAME a "E:\SAS_Projects\Users\mitikirim\BenefitManagement\Highmark";
LIBNAME m "E:\SAS_Projects\Users\mitikirim\B_Highmark Claims Data";
/*
DATA data.m3;
SET m.year3_members;
Age = INT(YRDIF(INPUT(DOB,YYMMDD10.),'01JUN2015'd,'ACTUAL'));
LENGTH AgeBucket $7;
IF Age <= 18 THEN AgeBucket = '0-18';
ELSE IF 18 <= Age <= 24 THEN AgeBucket = '18-24';
ELSE IF 25 <= Age <= 34 THEN AgeBucket = '25-34';
ELSE IF 35 <= Age <= 44 THEN AgeBucket = '35-44';
ELSE IF 45 <= Age <= 54 THEN AgeBucket = '44-54';
ELSE IF 55 <= Age <= 64 THEN AgeBucket = '55-64';
ELSE IF 65 <= Age <= 84 THEN AgeBucket = '65-84';
ELSE AgeBucket = '> 84';
*/
PROC SQL;
/* Utilizers, Visits, Paid, Billed, Allowed, Units */
TITLE1 'Approved Claims';
TITLE2 'Insured';
SELECT A.insured AS Insured, SUM(A.PAID_AMOUNT) AS Paid  FORMAT dollar16.2, SUM(A.ALLOWED_AMOUNT) AS Allowed FORMAT dollar16.2, 
SUM(A.BILLED_AMOUNT) AS Billed FORMAT dollar16.2, COUNT(DISTINCT A.visit_id) AS VisitCount FORMAT Comma10.0, 
COUNT(DISTINCT A.unique_id) AS UniqueMembers FORMAT Comma10.0, SUM(A.UNITS) as TotalUnits FORMAT Comma10.0
FROM data.c3chiro A INNER JOIN (SELECT DISTINCT unique_id FROM data.m3) B ON A.unique_id = B.unique_id
WHERE A.CLAIM_LINE_STATUS = 'A'
GROUP BY A.insured;

TITLE2 'Gender';
SELECT A.GENDER AS Gender, SUM(A.PAID_AMOUNT) AS Paid  FORMAT dollar16.2, SUM(A.ALLOWED_AMOUNT) AS Allowed FORMAT dollar16.2, 
SUM(A.BILLED_AMOUNT) AS Billed FORMAT dollar16.2, COUNT(DISTINCT A.visit_id) AS VisitCount FORMAT Comma10.0, 
COUNT(DISTINCT A.unique_id) AS UniqueMembers FORMAT Comma10.0, SUM(A.UNITS) as TotalUnits FORMAT Comma10.0
FROM data.c3chiro A INNER JOIN (SELECT DISTINCT unique_id FROM data.m3) B ON A.unique_id = B.unique_id
WHERE A.CLAIM_LINE_STATUS = 'A'
GROUP BY A.GENDER;

TITLE2 'Age';
SELECT A.AgeBucket, SUM(A.PAID_AMOUNT) AS Paid  FORMAT dollar16.2, SUM(A.ALLOWED_AMOUNT) AS Allowed FORMAT dollar16.2, 
SUM(A.BILLED_AMOUNT) AS Billed FORMAT dollar16.2, COUNT(DISTINCT A.visit_id) AS VisitCount FORMAT Comma10.0, 
COUNT(DISTINCT A.unique_id) AS UniqueMembers FORMAT Comma10.0, SUM(A.UNITS) as TotalUnits FORMAT Comma10.0
FROM data.c3chiro A INNER JOIN (SELECT DISTINCT unique_id FROM data.m3) B ON A.unique_id = B.unique_id
WHERE A.CLAIM_LINE_STATUS = 'A'
GROUP BY A.AgeBucket;

TITLE1 'Approved + Rejected Claims';
TITLE2 'Insured';
SELECT A.insured AS Insured, SUM(A.PAID_AMOUNT) AS Paid  FORMAT dollar16.2, SUM(A.ALLOWED_AMOUNT) AS Allowed FORMAT dollar16.2, 
SUM(A.BILLED_AMOUNT) AS Billed FORMAT dollar16.2, COUNT(DISTINCT A.visit_id) AS VisitCount FORMAT Comma10.0, 
COUNT(DISTINCT A.unique_id) AS UniqueMembers FORMAT Comma10.0, SUM(A.UNITS) as TotalUnits FORMAT Comma10.0
FROM data.c3chiro A INNER JOIN (SELECT DISTINCT unique_id FROM data.m3) B ON A.unique_id = B.unique_id
GROUP BY A.insured;

TITLE2 'Gender';
SELECT A.GENDER AS Gender, SUM(A.PAID_AMOUNT) AS Paid  FORMAT dollar16.2, SUM(A.ALLOWED_AMOUNT) AS Allowed FORMAT dollar16.2, 
SUM(A.BILLED_AMOUNT) AS Billed FORMAT dollar16.2, COUNT(DISTINCT A.visit_id) AS VisitCount FORMAT Comma10.0, 
COUNT(DISTINCT A.unique_id) AS UniqueMembers FORMAT Comma10.0, SUM(A.UNITS) as TotalUnits FORMAT Comma10.0
FROM data.c3chiro A INNER JOIN (SELECT DISTINCT unique_id FROM data.m3) B ON A.unique_id = B.unique_id
GROUP BY A.GENDER;

TITLE2 'Age';
SELECT A.AgeBucket, SUM(A.PAID_AMOUNT) AS Paid  FORMAT dollar16.2, SUM(A.ALLOWED_AMOUNT) AS Allowed FORMAT dollar16.2, 
SUM(A.BILLED_AMOUNT) AS Billed FORMAT dollar16.2, COUNT(DISTINCT A.visit_id) AS VisitCount FORMAT Comma10.0, 
COUNT(DISTINCT A.unique_id) AS UniqueMembers FORMAT Comma10.0, SUM(A.UNITS) as TotalUnits FORMAT Comma10.0
FROM data.c3chiro A INNER JOIN (SELECT DISTINCT unique_id FROM data.m3) B ON A.unique_id = B.unique_id
GROUP BY A.AgeBucket;
QUIT;
/* Total */
PROC SQL;
/* Utilizers, Visits, Paid, Billed, Allowed, Units */
TITLE 'Approved Claims';
SELECT COUNT(DISTINCT A.unique_id) AS UniqueMembers FORMAT Comma10.0, 
COUNT(DISTINCT A.visit_id) AS VisitCount FORMAT Comma10.0, SUM(A.PAID_AMOUNT) AS Paid  FORMAT dollar16.2, SUM(A.BILLED_AMOUNT) AS Billed  
FORMAT dollar16.2, SUM(A.ALLOWED_AMOUNT) AS Allowed FORMAT dollar16.2, SUM(A.UNITS) as TotalUnits FORMAT Comma10.0
FROM data.c3chiro A INNER JOIN (SELECT DISTINCT unique_id FROM data.m3) B ON A.unique_id = B.unique_id
WHERE A.CLAIM_LINE_STATUS = 'A'
;
TITLE 'Approved + Rejected Claims';
SELECT COUNT(DISTINCT A.unique_id) AS UniqueMembers FORMAT Comma10.0, 
COUNT(DISTINCT A.visit_id) AS VisitCount FORMAT Comma10.0, SUM(A.PAID_AMOUNT) AS Paid  FORMAT dollar16.2, SUM(A.BILLED_AMOUNT) AS Billed  
FORMAT dollar16.2, SUM(A.ALLOWED_AMOUNT) AS Allowed FORMAT dollar16.2, SUM(A.UNITS) as TotalUnits FORMAT Comma10.0
FROM data.c3chiro A INNER JOIN (SELECT DISTINCT unique_id FROM data.m3) B ON A.unique_id = B.unique_id
;
;QUIT;

PROC SQL;
/* Member Count */
SELECT insured AS Insured, COUNT(DISTINCT unique_id) AS MemberCount FORMAT Comma10.0 FROM data.m3
GROUP BY insured;
SELECT COUNT(DISTINCT unique_id) AS MemberCount FORMAT Comma10.0 FROM data.m3
;QUIT;

/*
DATA data.c3chiro;
SET data.c3;
Age = INT(YRDIF(INPUT(DOB,YYMMDD10.),'01JUN2015'd,'ACTUAL'));
LENGTH AgeBucket $7;
IF Age <= 18 THEN AgeBucket = '0-18';
ELSE IF 18 <= Age <= 24 THEN AgeBucket = '18-24';
ELSE IF 25 <= Age <= 34 THEN AgeBucket = '25-34';
ELSE IF 35 <= Age <= 44 THEN AgeBucket = '35-44';
ELSE IF 45 <= Age <= 54 THEN AgeBucket = '44-54';
ELSE IF 55 <= Age <= 64 THEN AgeBucket = '55-64';
ELSE IF 65 <= Age <= 84 THEN AgeBucket = '65-84';
ELSE AgeBucket = '> 84';
WHERE category = 'CHIRO';*/
/*SELECT SUM(PAID_AMOUNT) AS PaidAmt, SUM(UNITS) AS TotalUnits FROM a.c3chiro*/
/*SELECT COUNT(DISTINCT CAT(Subscriber_ID, '', Member_Seq, DATE_FROM, Provider_ID)) AS Visits FROM a.c3chiro */
/*SELECT COUNT(DISTINCT CAT(Subscriber_ID, '', Member_Seq)) AS Utilizers FROM a.c3chiro*/