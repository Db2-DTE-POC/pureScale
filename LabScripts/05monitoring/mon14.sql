-- Author Vikram Khatri (vikram.khatri@us.ibm.com)
-- Castout Monitoring

-- Credit: Steve Rees of Toronto Lab
-- Calculate number of writes / transactions (CASTOUTS_PER_TRANSACTION)
-- Calculate time per write (CASTOUT_TIME_MILLI_PER_TRANSACTION)
-- 
-- Bursty write activity many be a sign of SOFTMAX being high
-- Long Write Time (CASTOUT_TIME_MILLI_PER_TRANSACTION) > 10 ms is an
-- indication that I/O subsystem may not be able to keep up
-- 
-- Castout activity is influenced by
-- SOFTMAX - Lower value means faster group crash receovery but more
--           aggressive cleaning
--           Consider setting SOFTMAX higher than equivalent EE system
-- 
-- NUM_IOCLEANERS
--           Number of castout engines.
--           In DB2 10, set one per physical core

SELECT CURRENT_TIME AS "TIME",
       CASE WHEN SUM(W.TOTAL_APP_COMMITS) < 100 THEN NULL ELSE
       CAST( FLOAT(SUM(B.POOL_DATA_WRITES+B.POOL_INDEX_WRITES))
                 / SUM(W.TOTAL_APP_COMMITS) AS DECIMAL(6,1)) END 
           AS "CASTOUTS_PER_TRANSACTION",
       CASE WHEN SUM(B.POOL_DATA_WRITES+B.POOL_INDEX_WRITES) < 1000 THEN NULL ELSE
       CAST( FLOAT(SUM(B.POOL_WRITE_TIME))
                 / SUM(B.POOL_DATA_WRITES+B.POOL_INDEX_WRITES) AS DECIMAL(5,1)) END 
           AS "CASTOUT_TIME_MILLI_PER_TRANSACTION"
FROM TABLE(MON_GET_WORKLOAD(NULL,NULL)) AS W, 
TABLE(MON_GET_BUFFERPOOL(NULL,NULL)) AS B;
