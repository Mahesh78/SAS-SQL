LIBNAME av "E:\SAS_Projects\Users\mitikirim\BenefitManagement\Humana\Data";

PROC SQL;
CREATE TABLE denied18 AS SELECT * FROM av.humanaclaims18
WHERE (Ex_Code IS NOT NULL OR Ex_Code <> '');
QUIT;

PROC SQL;
CREATE TABLE denied17 AS SELECT * FROM av.humanaclaims17
WHERE (Ex_Code IS NOT NULL OR Ex_Code <> '');
QUIT;

PROC SQL;
CREATE TABLE denied16 AS SELECT * FROM av.humanaclaims16
WHERE (Ex_Code IS NOT NULL OR Ex_Code <> '');
QUIT;

PROC SQL;
CREATE TABLE paid18 AS SELECT * FROM av.humanaclaims18
WHERE (Ex_Code IS NULL OR Ex_Code = '');
QUIT;

PROC SQL;
CREATE TABLE paid17 AS SELECT * FROM av.humanaclaims17
WHERE (Ex_Code IS NULL OR Ex_Code = '');
QUIT;

PROC SQL;
CREATE TABLE paid16 AS SELECT * FROM av.humanaclaims16
WHERE (Ex_Code IS NULL OR Ex_Code = '');
QUIT;

PROC SQL;
CREATE TABLE av.accepted18 AS
SELECT A.* FROM paid18 AS A LEFT JOIN denied18 AS B
ON (A.Service_Date = B.Service_Date)
AND (A.Provider_ID = B.Provider_ID)
AND (A.Member_Seq = B.Member_Seq)
AND (A.Subscriber_ID = B.Subscriber_ID)
;QUIT;

PROC SQL;
CREATE TABLE av.accepted17 AS
SELECT A.* FROM paid17 AS A LEFT JOIN denied17 AS B
ON (A.Service_Date = B.Service_Date)
AND (A.Provider_ID = B.Provider_ID)
AND (A.Member_Seq = B.Member_Seq)
AND (A.Subscriber_ID = B.Subscriber_ID)
;QUIT;

PROC SQL;
CREATE TABLE av.accepted16 AS
SELECT A.* FROM paid16 AS A LEFT JOIN denied16 AS B
ON (A.Service_Date = B.Service_Date)
AND (A.Provider_ID = B.Provider_ID)
AND (A.Member_Seq = B.Member_Seq)
AND (A.Subscriber_ID = B.Subscriber_ID)
;QUIT;