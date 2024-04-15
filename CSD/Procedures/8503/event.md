<!-- FILEPATH: /Users/jlomba/Jason/Akamai/CSD/VR/proc/verify.html -->
### specificdatelimit
- If the request is to raise the limit to 1560 Gb during an event taking place from "2021-06-13 00:00 UTC To 2021-06-28 00:00 UTC", the *specificdatelimit* should look like:
- Most events require a modified loadlimit for an uninterrupted time period. Use *specificdatelimit* to set it up.
- Add **1** hour before the start time and **24h** to the end date/time! This is a buffer to account for unexpected extended events. Add it whether creating a new bucket or modifying an existing customer bucket, unless explicitly requested otherwise.
- **Syntax**: `specificdatelimit.$bucketname start_date start_time end_date end_time loadlimit`
- **Date format**: `MM/DD/YYYY` so that June 12, 2021 would be entered as 06/12/2021.

**Example Bucket:** raise the limit to 1560 Gb during an event taking place from "2021-06-13 00:00 UTC To 2021-06-28 00:00 UTC", the *specificdatelimit* should look like:

<details>

        specificlimit.microsoftddemea 06/12/2021 23:00 06/29/2021 00:00 1560Gb
</details>
<hr>
### specificlimit  
- If the request is to set different limits for different time frames within a day, then use *specificlimit* parameter instead of *specificdatelimit*.
- **Syntax**: `specificlimit.$bucketname weekdays start_time stop_time loadlimit`
- **Date format**: *specificlimit* only sees 24 hours, so the times need to be `00:00 to 23:59`.
    - Add multiple entries if needed.
    - **NOTE:** All weekdays are covered: MTWRFSD stands for Monday, Tuesday, Wednesday, Thursday, Friday, Saturday, Sunday
    - Here, we have split the time frame "2300-0600 UTC: 50 Tbps" into 2 entries because a date change is happening here and VR sees 24h clock when using *specificlimit*.
    - For example, if the ticket says microsoftddemea should have below limits:  
    
**Example Bucket:** 

<details>

        specificlimit.microsoftddemea MTWRFSD 00:00 05:59 50Tb
        specificlimit.microsoftddemea MTWRFSD 06:00 15:59 35Tb
        specificlimit.microsoftddemea MTWRFSD 16:00 22:59 33Tb
        specificlimit.microsoftddemea MTWRFSD 23:00 23:59 50Tb

</details>
<hr>
### Create a new event ticket
- Check if the requested bucket already exists or not.
- Make sure you have all the required details from the ticket `(bucket name, cpcodes, load limit, allowlist, service type, start date and time, end date and time in UTC)`
    - If anything is missing, check back with the requester.
- Take the lowest `specificlimit` or `specificdatelimit` limit value and set that as the loadlimit for the bucket.
    - Continue to REPAIR: Create/Modify Bucket and Push Changes to create the new bucket.  

**Example Bucket:** 

<details>
        
        bucketname skydeevents
        bucketdenytype.skydeevents threshold
        cpcodes.skydeevents 531185 947937
        loadlimit.skydeevents 700Gb
        specificdatelimit.skydeevents 12/29/2019 00:00 01/02/2020 23:59 700Gb
        denymethod.skydeevents haship
        bucketloadtype.skydeevents summed
        services.skydeevents W
        creationdate.skydeevents 03/13/2020
        allowlist.skydeevents VelvetRope-AllW

</details>
<hr>

### Add Event Limit added to an existing bucket  
- Make sure you have the following details: `bucketname, load limit for the event, start date and time, end date and time (in UTC)` 
- Continue to [REPAIR: Create/Modify Bucket and Push Changes](#push) to modify the existing bucket by adding specificdatelimit.

**Example Bucket:** Here, the load limit of the bucket `hululive` will be `8000Gb` from `06/02/2020 17:00 to 06/03/2020 07:00`, otherwise the load limit is `1000Gb`  

<details>

        bucketname hululive
        loadlimit.hululive 1000Gb
        denymethod.hululive haship
        bucketloadtype.hululive summed
        services.hululive W
        allowlist.hululive VelvetRope-AllW
        specificdatelimit.hululive 06/02/2020 17:00 06/03/2020 07:00 8000Gb
</details>
