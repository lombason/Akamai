#### Before submitting the change, check for the following potential issues:

1. Verify if the bucketname already exists. Replace **$bucket_name** with the name of the bucket given.
    >agg map "select bucketname, serviceletter from velvetrope_bucket_limit where lower(bucketname) = lower('$bucket_name') group by 1"
    
    - If the query returns no rows, the bucket is new.
    - If the query returns any rows, then the bucket already exists.

2. If the request is an event specific load limit change ("Scheduled Event" under "Is this an event related change"), go to [Event specific VR change using specificdatelimit](#event).

3. If the request is to add keys, you will first determine the keytype: cpcodes or footprint provided
    >agg map " select distinct keytype from velvetrope_bucket_limit where bucketname = '$bucket_name'"</blockquote>
    
###"ketype=cpcode"
1. Check whether the given keys are already in the configuration using the query below. Replace **$cpcodeN** with the cpcode(s) from the request.
    >agg map "select distinct bucketname, cpcode from velvetrope_bucket_cpcodes where cpcode in ($cpcode1, $cpcode2,..) and bucketname not like 'shadow-%' and bucketname not like 'rsvp_%' order by cpcode"
    
    - Note: it is OK for a cpcode to be in both a *customer* bucket AND in a *shadow* bucket.
        - Inspect the returned buckets. If any overlaps or conflicts are present in the listed settings, ask the requester to verify the cpcodes, include the query result.
        - cpcodes that already exist in the configuration
        - services (such as S and W)
        - different geographic regions (such as VelvetRope-EU-W and VelvetRope-Asia-W)
        - limits measured in different units (such as bits and flits)
2. Confirm that these cpcodes correspond to the same customer as the existing bucket:
    >agg map "select cpcode, cpname, contentname, accountname from cpmap where cpcode in ($cpcode1, $cpcode2,..)"
     
###keytype:"footprint"
1. For keytype “footprint”, a key is "footprint" and not "cpcode". Replace **$footprintN** with the key(s) from request.
2. Verify the keys:
        >agg map "select fp_config_id, fp_config_name,  contract_id from cw_footprint_details where fp_config_id in  ($footprint1, $footprint2, ...)"
         
    - If the query returned no output for any of the keys, ask the requestor to confirm the keys are correct.

4. Proceed directly to [Create/Modify Bucket and Push Changes](#push).
