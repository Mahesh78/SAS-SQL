libname CSNL "E:\SAS_Projects\Users\mitikirim\HumanaRequests";

PROC SQL;

CREATE TABLE csnl.CNL_002_CCD AS

SELECT 
    M.Group_ID, M.Plan_ID, M.Claim_Number, M.Subscriber_ID, M.Member_Seq, M.Provider_ID, 
    H.Claim_Seq, H.Service_Date, H.Procedure_Code, H.Svc_Count AS Units, 
    H.Billed_Price, H.Plan_Price, H.Ex_Code, H.Diagnosis_Code, M.Diagnostic_Code1, 
    M.Diagnostic_Code2, M.Diagnostic_Code3, M.Diagnostic_Code4, M.Diagnostic_Code5, M.Diagnostic_Code6, 
    M.Diagnostic_Code7, M.Diagnostic_Code8, M.Diagnostic_code9, M.Diagnostic_code10, M.Diagnostic_code11, 
    M.Diagnostic_code12, (CASE WHEN A.OON = 'Y' THEN 'Non-Par' ELSE 'Par' END) AS OON, M.Network_ID, M.New_Claim_Number, 
    M.EDI_Claim_ID, I.State, I.County, I.Zip_Code AS ProviderZipCode

FROM 
(
    (CHPA.Claim M
    LEFT JOIN 
        CHPA.Networks A
            ON 
                M.Network_ID = A.Network_ID) 

INNER JOIN 
    CHPA.ClaimDetail H
        ON 
            M.Claim_Number = H.Claim_Number   
) 

INNER JOIN 
    CHPA.ProviderAddress I

ON 
    (M.ProviderLocation_Seq = I.Location_Seq)
        AND 
            (M.Provider_ID = I.Provider_ID)

GROUP BY 
    M.Group_ID, M.Plan_ID, M.Claim_Number, M.Subscriber_ID, M.Member_Seq, M.Provider_ID, 
    H.Claim_Seq, H.Service_Date, H.Procedure_Code, H.Svc_Count, H.Billed_Price, 
    H.Plan_Price, H.Ex_Code, H.Diagnosis_Code, M.Diagnostic_Code1, M.Diagnostic_Code2, 
    M.Diagnostic_Code3, M.Diagnostic_Code4, M.Diagnostic_Code5, M.Diagnostic_Code6, M.Diagnostic_Code7, 
    M.Diagnostic_Code8, M.Diagnostic_code9, M.Diagnostic_code10, M.Diagnostic_code11, M.Diagnostic_code12, 
    (CASE WHEN A.OON = 'Y' THEN 'Non-Par' ELSE 'Par' END), M.Network_ID, M.New_Claim_Number, M.EDI_Claim_ID, I.State, 
    I.County, I.Zip_Code

HAVING 

(
    ((M.Group_ID)='HumFIDC') 
	/*AND (H.Billed_Price = 400)
	AND (H.Procedure_Code IN ('99201','99202','99203','99204','99205','99211','99212','99213','99214','99215'))*/
    AND ((M.Plan_ID)='HumDCMNec') 
    AND ((H.Service_Date) Between '01JAN2017'd And '31DEC2017'd) 
    AND ((M.New_Claim_Number) Is Null) 
    AND ((M.EDI_Claim_ID) Is Not Null And (M.EDI_Claim_ID)<>'')
    AND ((I.State)<>'AZ' And (I.State)<>'GA' And (I.State)<>'IL' And (I.State)<>'OH' And (I.State)<>'KY' And (I.State)<>'IN' And (I.State)<>'FL')
) 
    
OR 

(
	((M.Group_ID)='HumFIDC') 
	/*AND (H.Billed_Price = 400)
	AND (H.Procedure_Code IN ('99201','99202','99203','99204','99205','99211','99212','99213','99214','99215'))*/
    AND ((M.Plan_ID)='HumDCMNec') 
    AND ((H.Service_Date) Between '01JAN2017'd And '31DEC2017'd) 
    AND ((M.New_Claim_Number) Is Null) 
    AND ((M.EDI_Claim_ID) Is Not Null And (M.EDI_Claim_ID)<>'') 
    AND ((I.State)='IN')
	AND ((I.Zip_Code) Not Like '470%' And (I.Zip_Code) Not Like '471%' And (I.Zip_Code) Not Like '472%' And (I.Zip_Code) Not Like '473%' And (I.Zip_Code) Not Like '463%' And (I.Zip_Code) Not Like '464%')

) 

OR 

(
    ((M.Group_ID)='HumFIDC') 
	/*AND (H.Billed_Price = 400)
	AND (H.Procedure_Code IN ('99201','99202','99203','99204','99205','99211','99212','99213','99214','99215'))*/
    AND ((M.Plan_ID)='HumDCMNec') 
    AND ((H.Service_Date) Between '01JAN2017'd And '31DEC2017'd) 
    AND ((M.New_Claim_Number) Is Null) 
    AND ((M.EDI_Claim_ID) Is Not Null And (M.EDI_Claim_ID)<>'') 
    AND ((I.State)='FL') 
    AND ((I.County)<>'Miami-Dade' And (I.County)<>'Broward' And (I.County)<>'Palm Beach')
)
ORDER BY Claim_Number;

QUIT;