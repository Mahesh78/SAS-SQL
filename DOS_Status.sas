libname hm "E:\SAS_Projects\Users\mitikirim\Humana\18";

PROC SQL;
CREATE TABLE hm.ds AS SELECT * FROM hm.HumanaClaims18
ORDER BY Subscriber_ID
;QUIT;

/*Visits Denied*/
PROC SQL;
CREATE TABLE hm.vd AS
SELECT Subscriber_ID, Member_Seq, Provider_ID, Service_Date, Ex_Code FROM hm.ds
WHERE (Ex_Code IS NOT NULL OR Ex_Code <> '')
ORDER BY Subscriber_ID, Member_Seq
;QUIT;

/*Visits Paid*/
PROC SQL;
CREATE TABLE hm.vp AS
SELECT Subscriber_ID, Member_Seq, Provider_ID, Service_Date, Ex_Code FROM hm.ds
WHERE (Ex_Code IS NULL OR Ex_Code = '')
ORDER BY Ex_Code, Subscriber_ID, Member_Seq, Provider_ID, Service_Date
;QUIT;


/*DOS Denied*/
PROC SQL;
CREATE TABLE hm.dsd AS
SELECT A.*, 'Denied' AS DOS FROM hm.vd AS A LEFT JOIN hm.vp AS B

ON (A.Service_Date = B.Service_Date)
AND (A.Provider_ID = B.Provider_ID)
AND (A.Member_Seq = B.Member_Seq)                  /* Present in Visits Denied but not in Visits Paid */
AND (A.Subscriber_ID = B.Subscriber_ID)

WHERE (
(B.Subscriber_ID IS NULL)
AND (B.Member_Seq IS NULL)
AND (B.Provider_ID IS NULL)
AND (B.Service_Date IS NULL)
)
ORDER BY Subscriber_ID, Member_Seq
;QUIT;

/*DOS Partially Denied*/
PROC SQL;
CREATE TABLE hm.dspd AS
SELECT A.*, 'Partially Denied' AS DOS FROM hm.vd AS A INNER JOIN hm.vp AS B

ON (A.Service_Date = B.Service_Date)
AND (A.Provider_ID = B.Provider_ID)
AND (A.Member_Seq = B.Member_Seq)
AND (A.Subscriber_ID = B.Subscriber_ID)
;QUIT;


/*DOS Approved*/
PROC SQL;
CREATE TABLE hm.dsa AS
SELECT A.*, 'Approved' AS DOS FROM hm.vp AS A LEFT JOIN hm.vd AS B

ON (A.Service_Date = B.Service_Date)
AND (A.Provider_ID = B.Provider_ID)
AND (A.Member_Seq = B.Member_Seq)
AND (A.Subscriber_ID = B.Subscriber_ID)

WHERE (
(B.Subscriber_ID IS NULL)
AND (B.Member_Seq IS NULL)
AND (B.Provider_ID IS NULL)
AND (B.Service_Date IS NULL)
)
;QUIT;