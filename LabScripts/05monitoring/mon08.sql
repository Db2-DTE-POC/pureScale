-- Author Vikram Khatri (vikram.khatri@us.ibm.com)
-- Monitor DB2 pureScale page negotiation (or reclaim)

-- For example: If Member 'A' acquires a page P and modifies a row on it.
--              'A' holds an exclusive page lock on page until 'A' commits
--              Member 'B' wants to modify a different row on the same page.
--              'B' does not have to wait until 'A' commits
--              CF will negotiate the page back from 'A' on 'B's behalf.
--              Provides better concurrency - Good but excessive can cause
--              contention, low CPU usage, reduced throughput.

--              Recoomendations to reduce excessive page reclaim
--              What is excessive is debatable and sort it in desc order 
--              for all tables and pick top 5 tables
--              If excessive page reclaim then do these
--                 Consider smaller page size
--	               For small HOT tables with frequent updates, increase PCTFREE
--		 	           PCTFREE will spread rows over more pages
--	                   Side effect - More space consumption (but this is small table anyway)
                
SELECT SUBSTR(TABNAME,1,16) AS NAME,
       SUBSTR(OBJTYPE,1,16) AS TYPE,
       PAGE_RECLAIMS_X AS "# OF X PAGE RECLAIM",
       PAGE_RECLAIMS_S AS "# OF S PAGE RECLAIM"
FROM TABLE( MON_GET_PAGE_ACCESS_INFO('DB2PSC',NULL, NULL) ) AS WAITMETRICS
ORDER BY NAME
;
