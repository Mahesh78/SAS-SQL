LIBNAME data "E:\SAS_Projects\Users\mitikirim\BenefitManagement\Highmark\Data";
LIBNAME a "E:\SAS_Projects\Users\mitikirim\BenefitManagement\Highmark";
LIBNAME m "E:\SAS_Projects\Users\mitikirim\B_Highmark Claims Data";
/*
DATA data.m5;
SET m.year5_members;
Age = INT(YRDIF(INPUT(DOB,YYMMDD10.),'01JUN2017'd,'ACTUAL'));
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

/* Subset */
/*
DATA data.c5chiro;
SET data.c5;
Age = INT(YRDIF(INPUT(DOB,YYMMDD10.),'01JUN2017'd,'ACTUAL'));
LENGTH AgeBucket $7;
IF Age <= 18 THEN AgeBucket = '0-18';
ELSE IF 18 <= Age <= 24 THEN AgeBucket = '18-24';
ELSE IF 25 <= Age <= 34 THEN AgeBucket = '25-34';
ELSE IF 35 <= Age <= 44 THEN AgeBucket = '35-44';
ELSE IF 45 <= Age <= 54 THEN AgeBucket = '44-54';
ELSE IF 55 <= Age <= 64 THEN AgeBucket = '55-64';
ELSE IF 65 <= Age <= 84 THEN AgeBucket = '65-84';
ELSE AgeBucket = '> 84';
WHERE category = 'CHIRO'; COUNT(DISTINCT CATX('',unique_id, DATE_FROM, Provider_ID)) AS VisCount length = 1024,*/

/* Utilizers, Visits, Paid, Billed, Allowed, Units */
PROC SQL;
SELECT insured AS Insured, COUNT(DISTINCT unique_id) AS UniqueMembers FORMAT Comma10.0, 
COUNT(DISTINCT CATX('',unique_id, DATE_FROM, Provider_ID)) AS VisitCount FORMAT Comma10.0,
COUNT(DISTINCT visit_id) AS VisitCount2 FORMAT Comma10.0, SUM(PAID_AMOUNT) AS Paid 
FORMAT = dollar16.2, SUM(BILLED_AMOUNT) AS Billed FORMAT = dollar16.2, SUM(ALLOWED_AMOUNT) 
AS Allowed FORMAT = dollar16.2, SUM(UNITS) as TotalUnits FORMAT Comma10.0
FROM data.c5chiro
WHERE CLAIM_LINE_STATUS = 'A'
GROUP BY insured;
QUIT;
/* PAID + DENIED Utilizers, Visits, Paid, Billed, Allowed, Units */
PROC SQL;
SELECT insured AS Insured, COUNT(DISTINCT unique_id) AS UniqueMembers FORMAT Comma10.0, 
COUNT(DISTINCT CATX('',unique_id, DATE_FROM, Provider_ID)) AS VisitCount FORMAT Comma10.0,
COUNT(DISTINCT visit_id) AS VisitCount2 FORMAT Comma10.0, SUM(PAID_AMOUNT) AS Paid 
FORMAT = dollar16.2, SUM(BILLED_AMOUNT) AS Billed FORMAT = dollar16.2, SUM(ALLOWED_AMOUNT) 
AS Allowed FORMAT = dollar16.2, SUM(UNITS) as TotalUnits FORMAT Comma10.0
FROM data.c5chiro
GROUP BY insured;
;QUIT;
/* Start */
/* With member table join */
PROC SQL;
TITLE1 'Approved Claims';
TITLE2 'Insured';
SELECT A.insured AS Insured, COUNT(DISTINCT A.unique_id) AS UniqueMembers FORMAT Comma10.0,
COUNT(DISTINCT A.visit_id) AS VisitCount FORMAT Comma10.0, SUM(A.PAID_AMOUNT) AS Paid 
FORMAT = dollar16.2, SUM(A.BILLED_AMOUNT) AS Billed FORMAT = dollar16.2, SUM(A.ALLOWED_AMOUNT) 
AS Allowed FORMAT = dollar16.2, SUM(A.UNITS) as TotalUnits FORMAT Comma10.0
FROM data.c5chiro A INNER JOIN (SELECT DISTINCT unique_id FROM data.m5) B ON A.unique_id = B.unique_id
WHERE A.CLAIM_LINE_STATUS = 'A'
GROUP BY A.insured;

TITLE3 'Gender';
SELECT A.GENDER AS Gender, SUM(A.PAID_AMOUNT) AS Paid 
FORMAT = dollar16.2, SUM(A.ALLOWED_AMOUNT) AS Allowed FORMAT = dollar16.2, SUM(A.BILLED_AMOUNT) AS Billed FORMAT = dollar16.2, 
COUNT(DISTINCT A.visit_id) AS VisitCount FORMAT Comma10.0, COUNT(DISTINCT A.unique_id) AS UniqueMembers FORMAT Comma10.0, 
SUM(A.UNITS) as TotalUnits FORMAT Comma10.0
FROM data.c5chiro A INNER JOIN (SELECT DISTINCT unique_id FROM data.m5) B ON A.unique_id = B.unique_id
WHERE A.CLAIM_LINE_STATUS = 'A'
GROUP BY A.GENDER;

TITLE4 'Age';
SELECT A.AgeBucket, SUM(A.PAID_AMOUNT) AS Paid 
FORMAT = dollar16.2, SUM(A.ALLOWED_AMOUNT) AS Allowed FORMAT = dollar16.2, SUM(A.BILLED_AMOUNT) AS Billed FORMAT = dollar16.2, 
COUNT(DISTINCT A.visit_id) AS VisitCount FORMAT Comma10.0, COUNT(DISTINCT A.unique_id) AS UniqueMembers FORMAT Comma10.0, 
SUM(A.UNITS) as TotalUnits FORMAT Comma10.0
FROM data.c5chiro A INNER JOIN (SELECT DISTINCT unique_id FROM data.m5) B ON A.unique_id = B.unique_id
WHERE A.CLAIM_LINE_STATUS = 'A'
GROUP BY A.AgeBucket;

TITLE1 'Approved + Rejected Claims';
TITLE2 'Insured';
SELECT A.insured AS Insured, COUNT(DISTINCT A.unique_id) AS UniqueMembers FORMAT Comma10.0,
COUNT(DISTINCT A.visit_id) AS VisitCount FORMAT Comma10.0, SUM(A.PAID_AMOUNT) AS Paid 
FORMAT = dollar16.2, SUM(A.BILLED_AMOUNT) AS Billed FORMAT = dollar16.2, SUM(A.ALLOWED_AMOUNT) 
AS Allowed FORMAT = dollar16.2, SUM(A.UNITS) as TotalUnits FORMAT Comma10.0
FROM data.c5chiro A INNER JOIN (SELECT DISTINCT unique_id FROM data.m5) B ON A.unique_id = B.unique_id
GROUP BY A.insured;

TITLE3 'Gender';
SELECT A.GENDER AS Gender, SUM(A.PAID_AMOUNT) AS Paid 
FORMAT = dollar16.2, SUM(A.ALLOWED_AMOUNT) AS Allowed FORMAT = dollar16.2, SUM(A.BILLED_AMOUNT) AS Billed FORMAT = dollar16.2, 
COUNT(DISTINCT A.visit_id) AS VisitCount FORMAT Comma10.0, COUNT(DISTINCT A.unique_id) AS UniqueMembers FORMAT Comma10.0, 
SUM(A.UNITS) as TotalUnits FORMAT Comma10.0
FROM data.c5chiro A INNER JOIN (SELECT DISTINCT unique_id FROM data.m5) B ON A.unique_id = B.unique_id
GROUP BY A.GENDER;

TITLE4 'Age';
SELECT A.AgeBucket, SUM(A.PAID_AMOUNT) AS Paid 
FORMAT = dollar16.2, SUM(A.ALLOWED_AMOUNT) AS Allowed FORMAT = dollar16.2, SUM(A.BILLED_AMOUNT) AS Billed FORMAT = dollar16.2, 
COUNT(DISTINCT A.visit_id) AS VisitCount FORMAT Comma10.0, COUNT(DISTINCT A.unique_id) AS UniqueMembers FORMAT Comma10.0, 
SUM(A.UNITS) as TotalUnits FORMAT Comma10.0
FROM data.c5chiro A INNER JOIN (SELECT DISTINCT unique_id FROM data.m5) B ON A.unique_id = B.unique_id
GROUP BY A.AgeBucket;
/* Total */
PROC SQL;
SELECT COUNT(DISTINCT unique_id) AS UniqueMembers FORMAT Comma10.0, 
COUNT(DISTINCT CATX('',unique_id, DATE_FROM, Provider_ID)) AS VisitCount FORMAT Comma10.0,
COUNT(DISTINCT visit_id) AS VisitCount2 FORMAT Comma10.0, SUM(PAID_AMOUNT) AS Paid 
FORMAT = dollar16.2, SUM(BILLED_AMOUNT) AS Billed FORMAT = dollar16.2, SUM(ALLOWED_AMOUNT) 
AS Allowed FORMAT = dollar16.2, SUM(UNITS) as TotalUnits FORMAT Comma10.0
FROM data.c5chiro
WHERE CLAIM_LINE_STATUS = 'A'
;QUIT;
/* PAID + DENIED Utilizers, Visits, Paid, Billed, Allowed, Units */
PROC SQL;
SELECT COUNT(DISTINCT unique_id) AS UniqueMembers FORMAT Comma10.0, 
COUNT(DISTINCT CATX('',unique_id, DATE_FROM, Provider_ID)) AS VisitCount FORMAT Comma10.0,
COUNT(DISTINCT visit_id) AS VisitCount2 FORMAT Comma10.0, SUM(PAID_AMOUNT) AS Paid 
FORMAT = dollar16.2, SUM(BILLED_AMOUNT) AS Billed FORMAT = dollar16.2, SUM(ALLOWED_AMOUNT) 
AS Allowed FORMAT = dollar16.2, SUM(UNITS) as TotalUnits FORMAT Comma10.0
FROM data.c5chiro
;QUIT;

/* Member Count */
PROC SQL;
SELECT insured AS Insured, COUNT(DISTINCT unique_id) AS MemberCount FORMAT Comma10.0 FROM data.m5
GROUP BY insured;
SELECT COUNT(DISTINCT unique_id) AS MemberCount FORMAT Comma10.0 FROM data.m5
;QUIT;

PROC SQL;
CREATE TABLE bm AS 
SELECT A.* FROM a.c5chiro A INNER JOIN 
(SELECT DISTINCT unique_id FROM data.m5) B ON 
A.unique_id = B.unique_id
WHERE CLAIM_LINE_STATUS = 'A';
/* Paid */
SELECT insured, COUNT(DISTINCT visit_id) AS Visits, SUM(PAID_AMOUNT) AS PaidAmount FROM bm group by insured
;QUIT;


PROC SQL;
	create table Visits as select
	category, insured, unique_id length = 1024, count(distinct visit_id) as num_visits length = 1024,
	sum(PAID_AMOUNT) as paid_amount, sum(BILLED_AMOUNT) as charged_amount,
	sum(ALLOWED_AMOUNT) as allowed_amount, sum(UNITS) as unit_ct
	from a.c5chiro
	WHERE CLAIM_LINE_STATUS = 'A'
	group by category, insured, unique_id
;QUIT;

PROC SQL;
	create table Visits as select
	category, insured, A.unique_id length = 1024, count(distinct visit_id) as num_visits length = 1024,
	sum(PAID_AMOUNT) as paid_amount, sum(BILLED_AMOUNT) as charged_amount,
	sum(ALLOWED_AMOUNT) as allowed_amount, sum(UNITS) as unit_ct
	from a.c5chiro A INNER JOIN
	(SELECT DISTINCT unique_id FROM data.m5) B ON 
	A.unique_id = B.unique_id
	WHERE CLAIM_LINE_STATUS = 'A'
	group by category, insured, A.unique_id
;QUIT;

data visits2;
	set visits;
	format threshold $3.;
	if num_visits < 9 then threshold = "1-8";
	else if num_visits >= 9 then threshold = "9+";
run;

PROC SQL;
	create table measurement_counts as select
	category, insured, threshold, 
		count(distinct unique_id) as util_members format Comma20., 
		sum(num_visits) as num_visits format comma20., 
		sum(paid_amount) as paid_amount format dollar30.2, 
		sum(charged_amount) as charged_amount format dollar30.2, 
		sum(allowed_amount) as allowed_amount format dollar30.2, 
		sum(unit_ct) as unit_ct format comma20.
	from visits2
	where insured ne ""
	group by category, insured, threshold
;QUIT;

PROC SQL;
SELECT insured, COUNT(*) FROM a.c5chiro
GROUP BY insured
;QUIT;

/*SELECT SUM(PAID_AMOUNT), SUM(UNITS) FROM a.c5chiro*/
/* SELECT COUNT(DISTINCT CAT(Subscriber_ID, '', Member_Seq, DATE_FROM, Provider_ID)) FROM a.c5chiro */
/*DATA a.new;
LENGTH visc $1000;
SET a.c5chiro;
visc = CATX('',unique_id, DATE_FROM, Provider_ID);
run;
PROC SQL;
SELECT COUNT(DISTINCT visc) FROM a.new;
;QUIT;*/


PROC SQL;
SELECT insured AS Insured, COUNT(DISTINCT visit_id) AS VisitCount2 FORMAT Comma10.0
FROM a.c5chiro
WHERE CLAIM_LINE_STATUS = 'A'
GROUP BY insured;
;QUIT;

PROC SQL;
SELECT DISTINCT DEDUCTIBLE_AMOUNT FROM data.c5chiro;
SELECT DISTINCT COPAY_AMOUNT FROM data.c5chiro; 
SELECT DISTINCT CO_INSURANCE_AMOUNT FROM data.c5chiro;
QUIT;



