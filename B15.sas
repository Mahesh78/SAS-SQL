LIBNAME data "E:\SAS_Projects\Users\mitikirim\BenefitManagement\BCBSMA\Data";
LIBNAME a "E:\SAS_Projects\Users\mitikirim\BenefitManagement\BCBSMA";

DATA m1;
SET data.m15all;
FORMAT mem_num best32. mem_birth_dt Z8.;
WHERE netwk_prod_cd = 750  OR netwk_prod_cd = 850 OR netwk_prod_cd = 950 OR netwk_prod_cd = 1550;
RUN;

DATA data.m15;
SET m1;
Age = INT(YRDIF(INPUT(PUT(mem_birth_dt, Z8.), MMDDYY10.),'01JAN2015'd,'ACTUAL'));
LENGTH AgeBucket $7;
IF Age <= 18 THEN AgeBucket = '0-18';
ELSE IF 18 <= Age <= 24 THEN AgeBucket = '18-24';
ELSE IF 25 <= Age <= 34 THEN AgeBucket = '25-34';
ELSE IF 35 <= Age <= 44 THEN AgeBucket = '35-44';
ELSE IF 45 <= Age <= 54 THEN AgeBucket = '44-54';
ELSE IF 55 <= Age <= 64 THEN AgeBucket = '55-64';
ELSE IF 65 <= Age <= 84 THEN AgeBucket = '65-84';
ELSE AgeBucket = '> 84';

DATA data.c15;
SET data.c15;
Age = INT(YRDIF(mem_birth_dt,'01JAN2015'd,'ACTUAL'));
LENGTH AgeBucket $7;
IF Age <= 18 THEN AgeBucket = '0-18';
ELSE IF 18 <= Age <= 24 THEN AgeBucket = '18-24';
ELSE IF 25 <= Age <= 34 THEN AgeBucket = '25-34';
ELSE IF 35 <= Age <= 44 THEN AgeBucket = '35-44';
ELSE IF 45 <= Age <= 54 THEN AgeBucket = '44-54';
ELSE IF 55 <= Age <= 64 THEN AgeBucket = '55-64';
ELSE IF 65 <= Age <= 84 THEN AgeBucket = '65-84';
ELSE AgeBucket = '> 84';

/* Member Count 800,938 */ 
PROC SQL;
SELECT netwk_prod_cd, COUNT(DISTINCT mem_num) AS UniqueMembers FROM data.m15 GROUP BY netwk_prod_cd
;QUIT;

PROC SQL;
CREATE TABLE cm15 AS 
SELECT A.* FROM data.c15 A INNER JOIN 
(SELECT DISTINCT mem_num, netwk_prod_cd FROM data.m15 GROUP BY netwk_prod_cd) B ON 
A.mem_num = B.mem_num
AND A.NTWK_PROD_CD = B.netwk_prod_cd;
QUIT;
/* Allowed, Paid */
PROC SQL;
TITLE1 'Product';
SELECT NTWK_PROD_CD, SUM(dw_prv_paid_amt) AS PaidAmount FORMAT = dollar16.2,
SUM(allow_amt) AS AllowedAmount FORMAT = dollar16.2,  
SUM(subm_charge_amt) AS BilledAmount FORMAT = dollar16.2 FROM cm15 group by NTWK_PROD_CD;

TITLE1 'Gender';
SELECT mem_gender, SUM(dw_prv_paid_amt) AS PaidAmount FORMAT = dollar16.2,
SUM(allow_amt) AS AllowedAmount FORMAT = dollar16.2,  
SUM(subm_charge_amt) AS BilledAmount FORMAT = dollar16.2 FROM cm15 group by mem_gender;

TITLE1 'Age';
SELECT AgeBucket, SUM(dw_prv_paid_amt) AS PaidAmount FORMAT = dollar16.2,
SUM(allow_amt) AS AllowedAmount FORMAT = dollar16.2,  
SUM(subm_charge_amt) AS BilledAmount FORMAT = dollar16.2 FROM cm15 group by AgeBucket;
QUIT;
/* Correct Visits  */
PROC SQL;
TITLE1 'Product';
SELECT A.NTWK_PROD_CD, COUNT(DISTINCT CATX('',A.mem_num,A.sprv_tax_id,A.incurred_dt_yr_mth)) AS VisitCount 
FORMAT Comma10.0 FROM data.c15 A
INNER JOIN data.m15 B ON A.mem_num = B.mem_num
AND A.NTWK_PROD_CD = B.netwk_prod_cd
GROUP BY A.NTWK_PROD_CD;

TITLE1 'Gender';
SELECT A.mem_gender, COUNT(DISTINCT CATX('',A.mem_num,A.sprv_tax_id,A.incurred_dt_yr_mth)) AS VisitCount 
FORMAT Comma10.0 FROM data.c15 A
INNER JOIN data.m15 B ON A.mem_num = B.mem_num
AND A.NTWK_PROD_CD = B.netwk_prod_cd
GROUP BY A.mem_gender;

TITLE1 'Age';
SELECT A.AgeBucket, COUNT(DISTINCT CATX('',A.mem_num,A.sprv_tax_id,A.incurred_dt_yr_mth)) AS VisitCount 
FORMAT Comma10.0 FROM data.c15 A
INNER JOIN data.m15 B ON A.mem_num = B.mem_num
AND A.NTWK_PROD_CD = B.netwk_prod_cd
GROUP BY A.AgeBucket;
QUIT;
/* Total */
PROC SQL;
SELECT SUM(allow_amt) AS AllowedAmount FORMAT = dollar16.2, 
SUM(dw_prv_paid_amt) AS PaidAmount FORMAT = dollar16.2, 
SUM(subm_charge_amt) AS BilledAmount FORMAT = dollar16.2 FROM cm15
;QUIT;
/* Correct Visits  */
PROC SQL;
SELECT COUNT(DISTINCT CATX('',A.mem_num,A.sprv_tax_id,A.incurred_dt_yr_mth)) AS VisitCount 
FORMAT Comma10.0 FROM data.c15 A
INNER JOIN data.m15 B ON A.mem_num = B.mem_num
AND A.NTWK_PROD_CD = B.netwk_prod_cd
;QUIT;

PROC SQL;
SELECT mem_dt_qtr, netwk_prod_cd, COUNT(DISTINCT mem_num) FROM data.m15all
WHERE netwk_prod_cd IN (750, 850, 950, 1550) AND mem_dt_yr = '2015'
GROUP BY mem_dt_qtr, netwk_prod_cd ORDER BY mem_dt_qtr, netwk_prod_cd
;QUIT;

PROC SQL;
SELECT A.NTWK_PROD_CD, (CASE WHEN B.Visits < 13 THEN '1-12' ELSE '13+' END) AS GRP, 
COUNT(DISTINCT A.mem_num) AS ut,
COUNT(DISTINCT CATX('',A.incurred_dt_yr_mth,A.sprv_tax_id,A.mem_num)) AS uv, 
SUM(A.dw_prv_paid_amt) AS ap, SUM(a.srv_units) AS tu FROM data.c15 A,

(SELECT mem_num, COUNT(DISTINCT CATX('',incurred_dt_yr_mth,sprv_tax_id,mem_num)) AS Visits FROM data.c15 WHERE
incurred_dt_yr_mth BETWEEN '01JAN2015:00:00:00'dt And '31MAR2015:00:00:00'dt GROUP BY mem_num) B;QUIT;

WHERE A.mem_num = B.mem_num
AND A.incurred_dt_yr_mth BETWEEN '01JAN2015:00:00:00'dt And '31MAR2015:00:00:00'dt
/*AND EXISTS (SELECT * FROM data.m15all M WHERE A.mem_num = M.mem_num*/
AND mem_dt_mth IN ('1','2','3')
AND netwk_prod_cd IN (750, 850, 950, 1550)
AND netwk_prod_cd = A.NTWK_PROD_CD
AND mem_dt_yr = '2015')
/*GROUP BY A.NTWK_PROD_CD, (CASE WHEN B.Visits < 13 THEN '1-12' ELSE '13+' END)
ORDER BY 1,2*/
;QUIT;

PROC SQL;
SELECT A.NTWK_PROD_CD, (CASE WHEN B.Visits < 13 THEN '1-12' ELSE '13+' END) AS GRP, COUNT(DISTINCT A.mem_num) AS ut,
COUNT(DISTINCT CATX('',A.incurred_dt_yr_mth,A.sprv_tax_id,A.mem_num)) AS uv, SUM(A.dw_prv_paid_amt) AS ap, SUM(a.srv_units) AS tu FROM data.c15 A,
(SELECT mem_num, COUNT(DISTINCT CATX('',incurred_dt_yr_mth,sprv_tax_id,mem_num)) AS Visits FROM data.c15 WHERE
incurred_dt_yr_mth BETWEEN '01JAN2015:00:00:00'dt And '31MAR2015:00:00:00'dt GROUP BY mem_num) B
WHERE A.mem_num = B.mem_num
GROUP BY A.NTWK_PROD_CD, (CASE WHEN B.Visits < 13 THEN '1-12' ELSE '13+' END);
QUIT;

PROC SQL;
SELECT netwk_prod_cd, COUNT(DISTINCT mem_num) AS UniqueMembers  FROM data.m15all WHERE 
netwk_prod_cd = 750
OR netwk_prod_cd = 850
OR netwk_prod_cd = 950
OR netwk_prod_cd = 1550
GROUP BY netwk_prod_cd;
;QUIT;

/* Allowed, Paid */


PROC SQL;
SELECT MAX(incurred_dt_yr_mth) format DATETIME22.3 AS Start15, MIN(incurred_dt_yr_mth) AS f15 format DATETIME22.3 FROM data.c15;
SELECT MAX(INCURRED_DT_DAY) format DATETIME22.3 AS Start16, MIN(INCURRED_DT_DAY) AS f16 format DATETIME22.3 FROM data.c16;
SELECT MAX(incurred_dt_yr_mth) format DATETIME22.3 AS Start17, MIN(incurred_dt_yr_mth) AS f17 format DATETIME22.3 FROM data.c17;
;QUIT;

PROC SQL;
SELECT MAX(incurred_dt_yr_mth) FROM data.c15
;QUIT;

PROC SQL;
SELECT curr_clm_ind, COUNT(*) from data.c15 GROUP BY curr_clm_ind;
SELECT curr_clm_ind, COUNT(*) from data.c16 GROUP BY curr_clm_ind;
;QUIT;

/*
/Member Count/
PROC SQL;
SELECT netwk_prod_cd, COUNT(DISTINCT mem_num) AS UniqueMembers  FROM data.m15all WHERE 
netwk_prod_cd = 750
OR netwk_prod_cd = 0850
OR netwk_prod_cd = 0950
OR netwk_prod_cd = 1550
GROUP BY netwk_prod_cd;

SELECT COUNT(DISTINCT mem_num) AS UniqueMembers  FROM data.m15 WHERE 
netwk_prod_cd = 0750
OR netwk_prod_cd = 0850
OR netwk_prod_cd = 0950
OR netwk_prod_cd = 1550
;QUIT;

/Visit Count/
PROC SQL;
SELECT NTWK_PROD_CD, COUNT(DISTINCT CATX('',mem_num,sprv_num,incurred_dt_yr_mth)) AS VisitCount FROM data.c15
WHERE NTWK_PROD_CD IN (750, 850, 950, 1550)
GROUP BY NTWK_PROD_CD;

SELECT NTWK_PROD_CD, COUNT(DISTINCT CATX('',mem_num,sprv_num,incurred_dt_yr_mth)) AS VisitCount FROM data.c15
WHERE NTWK_PROD_CD IN (750, 850, 950, 1550)
;QUIT;
*/

PROC SQL;
SELECT A.NTWK_PROD_CD, (CASE WHEN B.Visits < 13 THEN '1-12' ELSE '13+' END) AS GRP, COUNT(DISTINCT A.mem_num) AS ut,
COUNT(DISTINCT CATX('',A.incurred_dt_yr_mth,A.sprv_tax_id,A.mem_num)) AS uv, SUM(A.dw_prv_paid_amt) AS ap, SUM(a.srv_units) AS tu FROM data.c15 A,
(SELECT mem_num, COUNT(DISTINCT CATX('',incurred_dt_yr_mth,sprv_tax_id,mem_num)) AS Visits FROM data.c15 WHERE
incurred_dt_yr_mth BETWEEN '01JAN2015:00:00:00'dt And '31MAR2015:00:00:00'dt GROUP BY mem_num) B

WHERE A.mem_num = B.mem_num
AND A.incurred_dt_yr_mth BETWEEN '01JAN2015:00:00:00'dt And '31MAR2015:00:00:00'dt
AND EXISTS (SELECT * FROM data.m15 M 
WHERE A.mem_num = M.mem_num
AND mem_dt_mth IN ('1','2','3')
AND netwk_prod_cd = A.NTWK_PROD_CD
AND mem_dt_yr = '2015')
GROUP BY A.NTWK_PROD_CD, (CASE WHEN B.Visits < 13 THEN '1-12' ELSE '13+' END)
ORDER BY 1,2;QUIT;
