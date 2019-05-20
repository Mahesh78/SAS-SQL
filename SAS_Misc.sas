PROC FORMAT;
	VALUE age
	0-18  = '0-18'
	19-44 = '19-44'
	45-64 = '45-64'
	65-84 = '65-84'
	84  = '> 84';
RUN;
/******************************************************************************************************/

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
	WHERE category = 'CHIRO';
RUN;
/******************************************************************************************************/
DATA m1;
    SET data.m15all;
    FORMAT mem_num best32. mem_birth_dt Z8. DOB MMDDYY10.;
    AGE = INT(YRDIF(INPUT(PUT(mem_birth_dt, Z8.), MMDDYY10.),'01JAN2015'd,'ACTUAL')); /* Numeric Date */
    WHERE netwk_prod_cd = 750  OR netwk_prod_cd = 850 OR netwk_prod_cd = 950 OR netwk_prod_cd = 1550;
RUN;
/******************************************************************************************************/
DATA data.m4;
    SET m.year4_members;
    Age = INT(YRDIF(INPUT(DOB,YYMMDD10.),'01JUN2016'd,'ACTUAL')); /* Character Date */
/******************************************************************************************************/
DATA date2;
	INFORMAT A Z8.;
	INPUT A;
	FORMAT A Z8.;
	CARDS;
	11051988 
	07071907 
	1311960
	1011960
RUN;

DATA date1;
	SET date2;
	*A1 = INPUT(PUT(A,Z8.), mmddyy10.);
	*FORMAT A1 mmddyy10.;
	AGE = INT(YRDIF(INPUT(PUT(A,Z8.), mmddyy10.),'01JAN2019'd,'ACTUAL'));
/******************************************************************************************************/