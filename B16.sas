LIBNAME data "E:\SAS_Projects\Users\mitikirim\BenefitManagement\BCBSMA\Data";
LIBNAME a "E:\SAS_Projects\Users\mitikirim\BenefitManagement\BCBSMA";

DATA data.m16;
SET data.m16all;
Age = INT(YRDIF(mem_birth_dt,'01JAN2016'd,'ACTUAL'));
LENGTH AgeBucket $7;
IF Age <= 18 THEN AgeBucket = '0-18';
ELSE IF 18 <= Age <= 24 THEN AgeBucket = '18-24';
ELSE IF 25 <= Age <= 34 THEN AgeBucket = '25-34';
ELSE IF 35 <= Age <= 44 THEN AgeBucket = '35-44';
ELSE IF 45 <= Age <= 54 THEN AgeBucket = '44-54';
ELSE IF 55 <= Age <= 64 THEN AgeBucket = '55-64';
ELSE IF 65 <= Age <= 84 THEN AgeBucket = '65-84';
ELSE AgeBucket = '> 84';
WHERE netwk_prod_cd = '0750' OR netwk_prod_cd = '0850' OR netwk_prod_cd = '0950' OR netwk_prod_cd = '1550';

DATA data.c16;
SET data.c16;
Age = INT(YRDIF(mem_birth_dt,'01JAN2016'd,'ACTUAL'));
LENGTH AgeBucket $7;
IF Age <= 18 THEN AgeBucket = '0-18';
ELSE IF 18 <= Age <= 24 THEN AgeBucket = '18-24';
ELSE IF 25 <= Age <= 34 THEN AgeBucket = '25-34';
ELSE IF 35 <= Age <= 44 THEN AgeBucket = '35-44';
ELSE IF 45 <= Age <= 54 THEN AgeBucket = '44-54';
ELSE IF 55 <= Age <= 64 THEN AgeBucket = '55-64';
ELSE IF 65 <= Age <= 84 THEN AgeBucket = '65-84';
ELSE AgeBucket = '> 84';

/* Member Count 784,159 */ 
PROC SQL;
SELECT netwk_prod_cd, COUNT(DISTINCT MEM_NUM) AS UniqueMembers FROM data.m16 GROUP BY netwk_prod_cd
;QUIT;
/* Allowed, Paid */
PROC SQL;
CREATE TABLE cm AS 
SELECT A.* FROM data.c16 A INNER JOIN 
(SELECT DISTINCT mem_num, netwk_prod_cd FROM data.m16) B ON 
A.mem_num_n = B.mem_num
AND A.NTWK_PROD_CD = B.netwk_prod_cd;
QUIT;
/* Allowed, Paid */
PROC SQL;
TITLE1 'Product';
SELECT NTWK_PROD_CD, SUM(dw_prv_paid_amt) AS PaidAmount FORMAT = dollar16.2,
SUM(allow_amt) AS AllowedAmount FORMAT = dollar16.2, 
SUM(subm_charge_amt) AS BilledAmount FORMAT = dollar16.2 FROM cm group by NTWK_PROD_CD;

TITLE1 'Gender';
SELECT mem_gender, SUM(dw_prv_paid_amt) AS PaidAmount FORMAT = dollar16.2,
SUM(allow_amt) AS AllowedAmount FORMAT = dollar16.2, 
SUM(subm_charge_amt) AS BilledAmount FORMAT = dollar16.2 FROM cm group by mem_gender;

TITLE1 'Age';
SELECT AgeBucket, SUM(dw_prv_paid_amt) AS PaidAmount FORMAT = dollar16.2,
SUM(allow_amt) AS AllowedAmount FORMAT = dollar16.2, 
SUM(subm_charge_amt) AS BilledAmount FORMAT = dollar16.2 FROM cm group by AgeBucket;
QUIT;

/* Correct Visits  */
PROC SQL;
TITLE1 'Product';
SELECT A.NTWK_PROD_CD, COUNT(DISTINCT CATX('',A.mem_num_n,A.sprv_tax_id,A.INCURRED_DT_DAY)) AS VisitCount format Comma10.0 FROM data.c16 A
INNER JOIN data.m16 B ON A.mem_num_n = B.mem_num
AND A.NTWK_PROD_CD = B.netwk_prod_cd
GROUP BY A.NTWK_PROD_CD;

TITLE1 'Gender';
SELECT A.mem_gender, COUNT(DISTINCT CATX('',A.mem_num_n,A.sprv_tax_id,A.INCURRED_DT_DAY)) AS VisitCount format Comma10.0 FROM data.c16 A
INNER JOIN data.m16 B ON A.mem_num_n = B.mem_num
AND A.NTWK_PROD_CD = B.netwk_prod_cd
GROUP BY A.mem_gender;

TITLE1 'Age';
SELECT A.AgeBucket, COUNT(DISTINCT CATX('',A.mem_num_n,A.sprv_tax_id,A.INCURRED_DT_DAY)) AS VisitCount format Comma10.0 FROM data.c16 A
INNER JOIN data.m16 B ON A.mem_num_n = B.mem_num
AND A.NTWK_PROD_CD = B.netwk_prod_cd
GROUP BY A.AgeBucket
;QUIT;
/* Total */
PROC SQL;
SELECT SUM(allow_amt) AS AllowedAmount FORMAT = dollar16.2, 
SUM(dw_prv_paid_amt) AS PaidAmount FORMAT = dollar16.2, 
SUM(subm_charge_amt) AS BilledAmount FORMAT = dollar16.2 FROM cm
;QUIT;

/* Correct Visits  */
PROC SQL;
SELECT COUNT(DISTINCT CATX('',A.mem_num_n,A.sprv_tax_id,A.INCURRED_DT_DAY)) AS VisitCount format Comma10.0 FROM data.c16 A
INNER JOIN data.m16 B ON A.mem_num_n = B.mem_num
AND A.NTWK_PROD_CD = B.netwk_prod_cd
;QUIT;

/* Member Count */
PROC SQL;
SELECT netwk_prod_cd, COUNT(DISTINCT MEM_NUM) AS UniqueMembers  FROM data.m16all WHERE 
netwk_prod_cd = '0750'
OR netwk_prod_cd = '0850'
OR netwk_prod_cd = '0950'
OR netwk_prod_cd = '1550'
GROUP BY netwk_prod_cd;

SELECT COUNT(DISTINCT MEM_NUM) AS UniqueMembers  FROM data.m16all WHERE 
netwk_prod_cd = '0750'
OR netwk_prod_cd = '0850'
OR netwk_prod_cd = '0950'
OR netwk_prod_cd = '1550'
;QUIT;

/* Visit Count */
PROC SQL;
SELECT NTWK_PROD_CD, COUNT(DISTINCT CATX('',MEM_NUM,CLM_SPRV_NUM,INCURRED_DT_DAY)) AS VisitCount 
FROM data.c16 WHERE NTWK_PROD_CD IN ('0750', '0850', '0950', '1550')
GROUP BY NTWK_PROD_CD;
;QUIT;

PROC SQL;
SELECT NTWK_PROD_CD, COUNT(DISTINCT CATX('',MEM_NUM,CLM_SPRV_NUM,INCURRED_DT_DAY)) AS Visits FROM data.c16
GROUP BY NTWK_PROD_CD
;QUIT;

PROC SQL;
SELECT COUNT(DISTINCT CATX('',MEM_NUM,CLM_SPRV_NUM,INCURRED_DT_DAY)) AS Visits FROM data.c16

;QUIT;