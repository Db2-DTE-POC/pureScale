-- Author Vikram Khatri (vikram.khatri@us.ibm.com)
-- The elapsed time for the CrossInvalidate command 

SELECT DEC(CAST(SUM(TOTAL_CF_WAIT_TIME_MICRO) AS FLOAT) /
       CAST(SUM(TOTAL_CF_REQUESTS) AS FLOAT),5,0) AS AVG_XI_WAIT_TIME_MICRO
FROM   TABLE (SYSPROC.MON_GET_CF_WAIT_TIME(-2))
WHERE  ID = (select ID from sysibmadm.db2_cf where STATE = 'PRIMARY')
AND CF_CMD_NAME = 'CrossInvalidate'
;
