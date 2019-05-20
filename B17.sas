LIBNAME data "E:\SAS_Projects\Users\mitikirim\BenefitManagement\BCBSMA\Data";
LIBNAME a "E:\SAS_Projects\Users\mitikirim\BenefitManagement\BCBSMA";

PROC SQL;
SELECT DISTINCT mem_gender FROM data.c17
;QUIT;

DATA data.m17;
SET data.m17all;
WHERE NTWK_PROD_CD = 750 OR NTWK_PROD_CD = 850 OR NTWK_PROD_CD = 950 OR NTWK_PROD_CD = 1550;

/* Member Count 800,938 */ 
PROC SQL;
SELECT NTWK_PROD_CD, COUNT(DISTINCT MEM_NUM) AS UniqueMembers FROM data.m17 GROUP BY NTWK_PROD_CD
;QUIT;

/* ALLOWED, PAID */
PROC SQL;
CREATE TABLE cm AS 
SELECT A.* FROM data.c17 A INNER JOIN 
(SELECT DISTINCT mem_num, NTWK_PROD_CD FROM data.m17 GROUP BY NTWK_PROD_CD) B ON 
A.mem_num = B.mem_num
AND A.NTWK_PROD_CD = B.NTWK_PROD_CD
;QUIT;
PROC SQL;
/* Allowed, Paid and Total Paid */
SELECT NTWK_PROD_CD, SUM(dw_prv_paid_amt) AS PaidAmount FORMAT = dollar16.2, SUM(subm_charge_amt) AS BilledAmount FORMAT = dollar16.2,
SUM(allow_amt) AS AllowedAmount FORMAT = dollar16.2, SUM(srv_units) AS TotalUnits FORMAT Comma10.0 FROM cm group by NTWK_PROD_CD
/*SELECT SUM(dw_prv_paid_amt) AS PaidAmount FROM cm*/
;QUIT;

/* Correct Visits 249,454 */
PROC SQL;
SELECT A.NTWK_PROD_CD, COUNT(DISTINCT CATX('',A.mem_num,A.sprv_tax_id,A.incurred_dt_yr_mth)) AS VisitCount 
FORMAT Comma10.0 FROM data.c17 A
INNER JOIN data.m17 B ON A.mem_num = B.MEM_NUM
AND A.NTWK_PROD_CD = B.NTWK_PROD_CD
GROUP BY A.NTWK_PROD_CD
;QUIT;

/* Total */
PROC SQL;
/* Allowed, Paid and Total Paid */
SELECT SUM(dw_prv_paid_amt) AS PaidAmount FORMAT = dollar16.2, SUM(subm_charge_amt) AS BilledAmount FORMAT = dollar16.2,
SUM(allow_amt) AS AllowedAmount FORMAT = dollar16.2, SUM(srv_units) AS TotalUnits FORMAT Comma10.0 FROM cm
/*SELECT SUM(dw_prv_paid_amt) AS PaidAmount FROM cm*/
;QUIT;

/* Correct Visits 249,454 */
PROC SQL;
SELECT COUNT(DISTINCT CATX('',A.mem_num,A.sprv_tax_id,A.incurred_dt_yr_mth)) AS VisitCount 
FORMAT Comma10.0 FROM data.c17 A
INNER JOIN data.m17 B ON A.mem_num = B.MEM_NUM
AND A.NTWK_PROD_CD = B.NTWK_PROD_CD
;QUIT;


PROC SQL;
SELECT A.NTWK_PROD_CD, COUNT(DISTINCT CATX('',A.mem_num,A.sprv_tax_id,A.incurred_dt_yr_mth)) AS VisitCount 
FORMAT Comma10.0 FROM data.c17 A
GROUP BY A.NTWK_PROD_CD
;QUIT;

PROC SQL;
SELECT NTWK_PROD_CD, 
SUM(allow_amt) AS AllowedAmount FORMAT = dollar16.0,
SUM(dw_prv_paid_amt) AS PaidAmount FORMAT = dollar16.0 FROM cm group by NTWK_PROD_CD;
;QUIT;

/* Utilizers */
PROC SQL;
SELECT A.NTWK_PROD_CD, COUNT(DISTINCT A.mem_num) AS Utilizers FROM data.c17 A INNER JOIN data.m17 B ON 
A.mem_num = B.MEM_NUM AND A.NTWK_PROD_CD = B.NTWK_PROD_CD GROUP BY A.NTWK_PROD_CD;

SELECT COUNT(DISTINCT mem_num) AS Utilizers FROM data.c17
;QUIT;



/*-*/
PROC SQL;
CREATE TABLE ab AS
SELECT * FROM data.c17 A INNER JOIN data.m17 B ON A.mem_num = B.mem_num AND B.NTWK_PROD_CD = A.NTWK_PROD_CD
GROUP BY A.mem_num, A.NTWK_PROD_CD;

SELECT NTWK_PROD_CD, COUNT(DISTINCT mem_num) AS UniqueMembers FROM ab GROUP BY NTWK_PROD_CD
;QUIT;

PROC SQL;
CREATE TABLE outt AS
SELECT A.mem_num, A.NTWK_PROD_CD, SUM(A.dw_prv_paid_amt) AS PAID, COUNT(DISTINCT CATX('',A.mem_num,A.sprv_num,A.incurred_dt_yr_mth)) AS VisitCount, 
sum(A.srv_units) AS Units FROM data.c17 A
INNER JOIN data.m17 B ON A.mem_num = B.MEM_NUM
AND A.NTWK_PROD_CD = B.NTWK_PROD_CD
GROUP BY A.mem_num, A.NTWK_PROD_CD
;QUIT;

PROC SQL;
SELECT NTWK_PROD_CD, SUM(VisitCount), SUM(PAID) FROM work.outt GROUP BY NTWK_PROD_CD
;QUIT;

PROC SQL;
CREATE TABLE mems_ann AS SELECT mem_num, NTWK_PROD_CD, mem_mth_cnt FROM data.m17
WHERE NTWK_PROD_CD IN (750, 850, 950, 1550);
CREATE TABLE mems1_ann AS SELECT mem_num, NTWK_PROD_CD, SUM(mem_mth_cnt) AS mem_mos
FROM mems_ann GROUP BY mem_num, NTWK_PROD_CD;

CREATE TABLE mems3_ann AS SELECT a.* FROM data.c17 A INNER JOIN mems1_ann B ON A.mem_num = B.mem_num AND A.NTWK_PROD_CD = B.NTWK_PROD_CD;

CREATE TABLE visit_ann AS SELECT mem_num , NTWK_PROD_CD, COUNT(DISTINCT CATX('',mem_num,sprv_num,incurred_dt_yr_mth)) AS visits, 
SUM(dw_prv_paid_amt) AS paid_amt, SUM(srv_units) AS units FROM mems3_ann GROUP BY mem_num, NTWK_PROD_CD
;QUIT;

PROC SQL;
SELECT DISTINCT NTWK_PROD_CD FROM data.m17
;QUIT;
/* 
				Member Count
PROC SQL;
SELECT NTWK_PROD_CD, COUNT(DISTINCT MEM_NUM) AS UniqueMembers  FROM data.m17all WHERE 
NTWK_PROD_CD = 750
OR NTWK_PROD_CD = 0850
OR NTWK_PROD_CD = 0950
OR NTWK_PROD_CD = 1550
GROUP BY NTWK_PROD_CD;

SELECT COUNT(DISTINCT MEM_NUM) AS UniqueMembers  FROM data.m17all WHERE 
NTWK_PROD_CD = 0750
OR NTWK_PROD_CD = 0850
OR NTWK_PROD_CD = 0950
OR NTWK_PROD_CD = 1550
;QUIT;
				Visit Count
PROC SQL;
SELECT NTWK_PROD_CD, COUNT(DISTINCT CATX('',mem_num,sprv_num,incurred_dt_yr_mth)) AS VisitCount FROM data.c17
WHERE NTWK_PROD_CD IN (750, 850, 950, 1550)
GROUP BY NTWK_PROD_CD;
SELECT COUNT(DISTINCT CATX('',mem_num,sprv_num,incurred_dt_yr_mth)) AS VisitCount FROM data.c17
WHERE NTWK_PROD_CD IN (750, 850, 950, 1550)
;QUIT;
PROC SQL;
SELECT MAX(incurred_dt_yr_mth) AS MaxDate format DATETIME22.3, MIN(incurred_dt_yr_mth) format DATETIME16. AS MinDate FROM data.c17
;QUIT;
*/

data _NULL_;
mu = 1; sigma = 2; x = 0.5; 
pdf = pdf("Normal", x, mu, sigma);
y = exp(-(x-mu)**2 / (2*sigma**2)) / sqrt(2*constant('pi')*sigma**2);
put (pdf y) (=5.3);
run;

data _null_;
a = divide(1,0);
PUT a = ;
run;

PROC SQL;
SELECT COUNT(mem_num) FROM data.m17
;QUIT;