-- Author Vikram Khatri (vikram.khatri@us.ibm.com)
-- Rate at which a CF command occurs

SELECT CF_CMD_NAME,
       SUM(TOTAL_CF_WAIT_TIME_MICRO) AS T1,
       SUM(TOTAL_CF_REQUESTS) AS Q1
FROM   TABLE (SYSPROC.MON_GET_CF_WAIT_TIME(-2))
WHERE  ID = (select ID from sysibmadm.db2_cf where STATE = 'PRIMARY')
GROUP BY CF_CMD_NAME
HAVING SUM(TOTAL_CF_WAIT_TIME_MICRO) > 0
ORDER BY T1 DESC
;
