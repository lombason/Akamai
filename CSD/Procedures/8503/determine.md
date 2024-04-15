1. Upon determining approval, follow: [Making a VR Change with the UI](https://www.nocc.akamai.com/alertproc/view.cgi?id=8737#extreq) to push the changes.
2. If the change request has already been rejected, Do Not Proceed.

The following requests do not require Salesforce Capacity Requests:
- Add or remove CPcodes from existing bucket (except for a shadow bucket request)
- Reduce the load limit of a custom bucket
- IAT request to remove an associated customer bucket
- Change VR bucket names
- The request is from [Dave Hassler](https://contacts.akamai.com/index.cgi?username=dhassler) or one of his Capacity Planning team.

Proceed to [Verify the Change](#checks).

Bucket Load Limit Increases:
- Request to permanently increase a bucket's load limit (excluding shadow buckets)
- Request to temporarily increase a bucket's load limit due to an event (excluding shadow buckets)
    - If there is no Salesforce Capacity Request referenced in the ticket, ask the requester to provide one as per the [Capacity Request Guidelines](https://ac.akamai.com/docs/DOC-90173).
    - If the External Request does reference a capacity request:
        - Look for the section named “Approval Details”
        - If the CapReq references geo-specific CP Codes, create geo-specific VR buckets based on the approved limits.
        - If the CapReq is geo-specific (ie: the limit requested and approved in a single geo), create a geo-specific VR bucket.
        - If the CapReq DOES NOT reference geo-specific CP Codes, create a global VR bucket with the aggregate limits.

Proceed to [Verify the Change](#checks).

Event starting in < 24 hours: Emergency Event Requests:
- You should only be following this section if an external request has been filed for an event-related change and there is < 24 hours until the event starts.
- The requester should still provide the Salesforce Capacity Request in the external request, even if it is not approved yet.
- The request should come from someone on IAT (Accounts) or the appropriate SME team.
- If the requestor is from Akatec, ask them to get IAT involved.
- Follow [Event specific VR change using specificdatelimit](#event) to determine the format of limit update. From there, you will be directed to available capacity check and config update instructions.

Proceed to [Verify the Change](#checks).

Shadow/Reservation Bucket Changes:
- Request must be made from a member of [Shadow Bucket VR](https://www.nocc.akamai.com/elist/?g_id=2955).
- Please go directly to [Shadow/Reservation Bucket Changes via External Request](https://www.nocc.akamai.com/alertproc/view.cgi?id=8737#shadowres) and follow the procedure.

Service Letter 'C' Requests (all SRIP Requests):
- If the request is not from a member [SRIP Service Perf](https://www.nocc.akamai.com/elist/?g_id=253):
    1. Advise the requester that you are waiting for approval from SRIP Service Perf.
    2. Request approval from [SRIP Service Perf (perf-help-srip)](mailto:perf-help-srip@akamai.com).
        - IF SRIP Service Perf SMEs do not approve the change(s): Reject the request.
        - ELSE proceed to [Verify the Change](#checks).

Cloud Wrapper Requests:
- If the request is not from a member of [Cloud Wrapper SMEs](https://www.nocc.akamai.com/sme/?g_id=2803):
    1. Advise the requester that you are waiting for approval from Cloud Wrapper SMEs.
    2. Request approval from [Cloud Wrapper SMEs](https://www.nocc.akamai.com/sme/?g_id=2803).
        - IF Cloud Wrapper SMEs do not approve the change(s): Reject the request.
        - ELSE proceed to [Verify the Change](#checks).

MSL OriginShield Requests:
- If the request is not from a member of [MSL SMEs](https://www.nocc.akamai.com/elist/?g_id=3425):
    1. Advise the requester that you are waiting for approval from MSL SMEs.
    2. Request approval from [MSL SMEs](https://www.nocc.akamai.com/elist/?g_id=3425).
        - IF MSL SMEs do not approve the change(s): Reject the request.
        - ELSE Proceed to [VelvetRope MSL OriginShield](https://www.nocc.akamai.com/alertproc/view.cgi?id=9013#increase) | "Move cpcode to new bucket" section.

<style>
h3 {
    color: darkblue;
}

details {
    display: flex;
    padding-left: 1px;
    cursor: pointer;
    padding: 3px;
    width: fit-content;
}

details[open] {
    background-color: white;
    padding: 1px;
    color: black;
    display: flex;
    padding-left: 1px;
}

details[open] summary {
    display: flex;
    padding-left: 1px;
    cursor: pointer;
    padding: 3px;
    font-size: large;
}

summary {
    font-size: larger;
    color: #205493;
    background-color: #dce4ef;
}

.required {
    background-color: #e31c3d;
    display: flex;
    padding-left: 1px;
    cursor: pointer;
    padding: 3px;
    color: white;
}

.required[open] summary {
    background-color: #e31c3d;
    display: flex;
    padding-left: 1px;
    cursor: pointer;
    padding: 3px;
}

.allowed {
    background-color: #94bfa2;
    display: flex;
    padding-left: 1px;
    cursor: pointer;
    padding: 3px;
}

.allowed[open] summary {
    background-color: #94bfa2;
    display: flex;
    padding-left: 1px;
    cursor: pointer;
    padding: 3px;
}
</style>
