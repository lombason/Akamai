NOTE: There is now a script that can run the next four sections of the procedure. Refer to [INVESTIGATE: Running the script version](#script). 

1. Run the following query and record the output in the ticket:
 
        agg infra "select m.tablename from querymergedtables m, query2_static_config q where m.machineip=q.machineip and q.network='$NETWORK' and m.tablename='$TABLE_NAME' group by m.tablename;"
    
    *$TABLE_NAME and $NETWORK come from the request details*
    1. If the query returns a single row with the tablename, then proceed.
    1. If the query returns 0 rows (no result) then **escalate** to [Query2 SMEs](https://www.nocc.akamai.com/elist/?g_id=35) via email, stating that this is a prewarm request for a non-merged table that needs assistance from Query2 SMEs. Please CC the requester and include all information such as the information gathered in [Gather Data](#gatherdata), query output, etc. Proceed to next step after email escalation has been sent.

1. Check if the request has an AMS aggregator set in the list. The aggregator hostname will be in the format  **$NETWORK.$DOMAIN** 

    **EXAMPLE**: agg is essl.ams-staging.query.akadns.net.  $NETWORK is ESSL, DOMAIN is ams-staging.

    * If $DOMAIN starts with ams or is ams-staging, then it is an AMS aggregator. Currently, CSD does not take prewarming requests for AMS aggregators - you can reply back to the requestor with the following:


        >The process for AMS prewarms are automated. Emails are regularly sent to query-slap@akamai.com as Subject: Query2 prewarm changes for AMS. Query Ops is responsible for pushing these prewarms.
        
        > Confluence link: https://collaborate.akamai.com/confluence/display/DDC/Query2+How+to+Change+Prewarm+Tables


1. For other aggregators, run safety checks against the network aggregator. Check with the Tier3 over the webex channel if you are unable to identify the network.

    1. **Safety check 1:** **`Rows:`** should not exceed **`1500000`**: 
    
     **NOTE:** CSD will no longer need approval from the Query2 team on prewarming tables that are larger than 200k. Please only escalate for approvals for prewarm requests of tables that are over 1.5million rows in size on aggsets that are in the [Updated Lists](https://collaborate.akamai.com/confluence/pages/viewpage.action?spaceKey=DDC&title=Query2+hostname+to+aggset+mapping+2022)
        
            agg $NETWORK 'select COUNT(*) from $TABLE_NAME';

        * If you see the higher number, reply-all and send an email to query-help@akamai.com cc'in query-ops-esc@akamai.com for approval with the following output.


    1. **Safety check 2:** Run the following query and check to see if it **returns** any rows. 
    
            agg $NETWORK 'select viewname from _views where viewname = "$TABLE_NAME"';
            
        * If any rows are returned, then it’s a view and **can’t** be prewarmed.   Run the below query to get the tables that make up the view:
        
                agg $NETWORK "LIST TABLES SELECT * FROM $TABLE_NAME"

            
            * Reply-all to send an email to the **requester**, cc'in query-ops-esc@akamai.com & query-help@akamai.com saying it cannot be prewarmed and a new request needs to be opened by the requestor for prewarming the tables that make up the view.
        
    1. **Safety check 3:** Run the following query to check capitalization. Tablenames used for prewarming are case sensitive.  Use the exact tablenames returned by the query below:
    
            agg $NETWORK "LIST TABLES SELECT * FROM $TABLE_NAME"
    
1. Go to: [MITIGATE: Query2 Update Procedure section](#query2_update).
            