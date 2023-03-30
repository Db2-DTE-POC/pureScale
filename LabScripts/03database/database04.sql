--#SET TERMINATOR ;
connect to PSDB;
-- --------------------------------------------------------------------- 
-- Create a table (PS_TABLE) that uses the TS32 table space
-- --------------------------------------------------------------------- 
CREATE TABLE PS_TABLE
( 
	PS_TABLE_ID  INTEGER NOT NULL GENERATED ALWAYS AS IDENTITY 
                   (START WITH 100000, INCREMENT BY 5),
   	SSN            CHAR(11)      NOT NULL,
   	FIRST_NAME     VARCHAR(20)   NOT NULL,
   	LAST_NAME      VARCHAR(20)   NOT NULL,
   	JOB_CODE       CHAR(4) 	     NOT NULL,
   	DEPT           SMALLINT      NOT NULL,
   	SALARY         DECIMAL(12,2) NOT NULL,
   	DOB            DATE          NOT NULL WITH DEFAULT,
   	CONSTRAINT     PK_PS_TABLE PRIMARY KEY (PS_TABLE_ID)
) IN TS32
;

ALTER TABLE PS_TABLE ADD COLUMN curmem SMALLINT 
    DEFAULT CURRENT MEMBER IMPLICITLY HIDDEN
;

-- --------------------------------------------------------------------- 
-- Generate records into the PS_TABLE in order to "prime it"
-- --------------------------------------------------------------------- 
INSERT INTO PS_TABLE 
	(SSN,FIRST_NAME,LAST_NAME,JOB_CODE,DEPT,SALARY,DOB)
	WITH TEMP1 (s1,r1,r2,r3,r4) AS
	(VALUES (0
	,RAND(2)
	,RAND()+(RAND()/1E5)
	,RAND()* RAND()
	,RAND()* RAND()* RAND())
	  UNION ALL
	SELECT s1 + 1
	,RAND()
	,RAND()+(RAND()/1E5)
	,RAND()* RAND()
	,RAND()* RAND()* RAND()
	FROM TEMP1
	WHERE s1 < 49999
	)
	SELECT  SUBSTR(DIGITS(INT(r2*988+10)),8) ||'-'||
       		SUBSTR(DIGITS(INT(r1*88+10)),9) || '-' ||
       		TRANSLATE(SUBSTR(DIGITS(s1),7),'9873450126','0123456789'),
       		CHR(INT(r1*26+65))|| CHR(INT(r2*26+97))|| CHR(INT(r3*26+97)) ||
                CHR(INT(r4*26+97))|| CHR(INT(r3*10+97))|| CHR(INT(r3*11+97)),
                CHR(INT(r2*26+65))||TRANSLATE(CHAR(INT(r2*1E7)),'aaeeiibmty','0123456789'),
       		CASE
         		WHEN INT(r4*9) > 7 THEN 'MGR'
         		WHEN INT(r4*9) > 5 THEN 'SUPR'
         		WHEN INT(r4*9) > 3 THEN 'PGMR'
         		WHEN INT(R4*9) > 1 THEN 'SEC'
         		ELSE 'WKR'
       		END,
       		INT(r3*98+1),
       		DECIMAL(r4*99999,7,2),
       		DATE('1930-01-01') + INT(50-(r4*50)) YEARS + INT(r4*11) MONTHS + 
                    INT(r4*27) DAYS
	FROM TEMP1
;

-- --------------------------------------------------------------------- 
-- Create HISTORY TABLE 
-- --------------------------------------------------------------------- 
CREATE TABLE PS_HISTORY
( 
   	FIRSTNAME     VARCHAR(20)   NOT NULL,
   	LASTNAME      VARCHAR(20)   NOT NULL,
   	JOBCODE       CHAR(4) 	     NOT NULL
) IN TS32
;

ALTER TABLE PS_HISTORY ADD COLUMN curmem SMALLINT 
    DEFAULT CURRENT MEMBER IMPLICITLY HIDDEN
;

grant all on ps_table to public;
grant all on ps_history to public;
connect reset;
