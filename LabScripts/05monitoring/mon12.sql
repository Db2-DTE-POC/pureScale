-- Author Vikram Khatri (vikram.khatri@us.ibm.com)
-- Monitor CF Bottleneck

-- AVG_CF_WT_MICRO is an indication if CF is the bottleneck
-- This is an average over all CF calls
-- Best way to judge good or bad number - Look for a change
-- from what is normal for your system

-- For example, this values should be less than 200 micro seconds
-- Adding more CF adapters will help to reduce this number    

SELECT  INT(SUM(RECLAIM_WAIT_TIME)) RECLAIMTIME_MILLI,
        INT(SUM(CF_WAITS)) AS NUM_CF_WAITS,
	INT(SUM(CF_WAIT_TIME)) CF_WAIT_MILLI,	 
	INT(1000 * DEC(SUM(CAST(CF_WAIT_TIME AS FLOAT))/
                       SUM(CAST(CF_WAITS AS FLOAT)),5,4)) AVG_CF_WT_MICRO 
FROM    TABLE(SYSPROC.MON_GET_WORKLOAD('',-2)) AS t
;
