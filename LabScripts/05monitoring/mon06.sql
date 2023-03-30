-- Author Vikram Khatri (vikram.khatri@us.ibm.com)
-- SQL to find Group Buffer Pool Full Condition
-- Buffer Pool Hit Ratios

-- Group Buffer Pool Full Condition
-- Occurs when no free locations in GBP to host incoming pages
-- It causes a sync write for dirty pages to create more space
-- It is not member specific so sum across all members to get cluster view
-- How many times GBP was full

SELECT SUM(GBP.NUM_GBP_FULL) AS NUM_GBP_FULL 
FROM TABLE(MON_GET_GROUP_BUFFERPOOL(-2)) as GBP
;

-- GBP Full Condition
--  Good value: < 5 per 10000 transactions
-- If higher, GBP is small
--            The castout engines might not be keeping up
--            SOFTMAX is set too high

-- Credit Steve Rees of Toronto Lab.

WITH GBPC AS ( 
   SELECT 10000.0 * SUM(GBP.NUM_GBP_FULL) / SUM(COMMIT_SQL_STMTS) AS GBP_FULL_CONDITION 
   FROM   TABLE(MON_GET_GROUP_BUFFERPOOL(-2)) as GBP, SYSIBMADM.SNAPDB
) SELECT CASE WHEN GBP_FULL_CONDITION < 5.0 THEN 'GOOD VALUE' 
         ELSE 'GBP FULL CONDITION' END AS RESULT,
         CASE WHEN GBP_FULL_CONDITION < 5.0 THEN 'NO GBP FULL CONDITION' 
		 ELSE 'INCREASE CF_GBP_SZ OR DECREASE SOFTMAX OR INCREASE NUM_IOSERVERS' 
		 END AS RECOMMENDATION
  FROM GBPC 
;
