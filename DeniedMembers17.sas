LIBNAME hm "E:\SAS_Projects\Users\mitikirim\DeniedHumana17";

PROC SQL;
CREATE TABLE hm.ds AS SELECT * FROM hm.hbook17
ORDER BY Subscriber
;QUIT;

/* All Denied */
PROC SQL;
CREATE TABLE hm.vd AS                  /* DATA hm.vd; SET hm.hbook17; KEEP Subscriber Ex_Code; WHERE (Ex_Code IS NOT NULL OR Ex_Code <> ''); RUN;*/
SELECT Subscriber, Ex_Code FROM hm.ds  /* SELECT Subscriber, Ex_Code FROM hm.hbook17 */
WHERE (Ex_Code IS NOT NULL OR Ex_Code <> '')
ORDER BY Subscriber
;QUIT;

/* All Paid */
PROC SQL;
CREATE TABLE hm.vp AS
SELECT Subscriber, Ex_Code FROM hm.ds
WHERE (Ex_Code IS NULL OR Ex_Code = '')
ORDER BY Subscriber
;QUIT;

/* Denied */
PROC SQL;
CREATE TABLE hm.dsd AS
SELECT A.*, 'Denied' AS DOS FROM hm.vd AS A LEFT JOIN hm.vp AS B
ON A.Subscriber = B.Subscriber
WHERE B.Subscriber IS NULL
;QUIT;

/* Distinct of Denied Members */
PROC SQL;
CREATE TABLE hm.DeniedMem AS
SELECT DISTINCT Subscriber FROM hm.dsd
;QUIT;

/* Random Sample of Distinct Denied for Validation */
PROC SURVEYSELECT DATA = hm.DeniedMem OUT = hm.SampleDenied SEED = 97 OUTHITS
                  METHOD = URS SAMPSIZE = 10 REP = 1;
RUN;
/* Partially Denied */
PROC SQL;
CREATE TABLE hm.dspd AS
SELECT A.*, 'Partially Denied' AS DOS FROM hm.vd AS A INNER JOIN hm.vp AS B
ON A.Subscriber = B.Subscriber
;QUIT;

/* Paid */
PROC SQL;
CREATE TABLE hm.dsa AS
SELECT A.*, 'Approved' AS DOS FROM hm.vp AS A INNER JOIN hm.vd AS B
ON A.Subscriber = B.Subscriber
WHERE B.Subscriber IS NULL
;QUIT;