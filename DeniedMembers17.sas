libname hm "E:\SAS_Projects\Users\mitikirim\BenefitManagement";

PROC SQL;
CREATE TABLE hm.ds AS SELECT * FROM hm.hbook17
ORDER BY Subscriber
;QUIT;

/*Visits Denied*/
PROC SQL;
CREATE TABLE hm.vd AS
SELECT Subscriber, Ex_Code FROM hm.ds
WHERE (Ex_Code IS NOT NULL OR Ex_Code <> '')
ORDER BY Subscriber
;QUIT;

/*Visits Paid*/
PROC SQL;
CREATE TABLE hm.vp AS
SELECT Subscriber, Ex_Code FROM hm.ds
WHERE (Ex_Code IS NULL OR Ex_Code = '')
ORDER BY Subscriber
;QUIT;

/*DOS Denied*/
PROC SQL;
CREATE TABLE hm.dsd AS
SELECT A.*, 'Denied' AS DOS FROM hm.vd AS A LEFT JOIN hm.vp AS B

ON 
(A.Subscriber = B.Subscriber)

WHERE (
(B.Subscriber IS NULL)

)
;QUIT;

PROC SQL;
CREATE TABLE hm.DeniedMem AS
SELECT DISTINCT Subscriber FROM hm.dsd
;QUIT;

/* Random Sample */
proc surveyselect DATA = hm.DeniedMem OUT = hm.want SEED = 7 OUTHITS
                  METHOD = urs SAMPSIZE=10 rep=1;
run;
/* Partially Denied */
PROC SQL;
CREATE TABLE hm.dspd AS
SELECT A.*, 'Partially Denied' AS DOS FROM hm.vd AS A INNER JOIN hm.vp AS B

ON (A.Subscriber = B.Subscriber)
;QUIT;
/*DOS Approved*/
PROC SQL;
CREATE TABLE hm.dsa AS
SELECT A.*, 'Approved' AS DOS FROM hm.vp AS A INNER JOIN hm.vd AS B

ON (A.Subscriber = B.Subscriber)

WHERE (
(B.Subscriber IS NULL)

)
;QUIT;