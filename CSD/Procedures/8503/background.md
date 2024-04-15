### The VelvetRope system, using defined rules, monitors traffic load per cpcode

- The [Akamai Capacity Team](/sme/?g_id=151) keeps track of the overall network capacity and of traffic for each customer/event for each Akamai network.
- **Escalations should be directed to the appropriate SME lists.**
- 'Shadow Buckets' in Velvet Rope are used to group high volume customers and share overflow space.
- External requests are automatically rerouted to CSD_TRIAGE_QUEUE come into the NOCC_ASSIGN_QUEUE, and are then triaged by the CSD team.
- Most External Requests for Velvet Rope changes will have an associated Salesforce Capacity Request, commonly referred to as a “CapReq”.
    - ID provided in the request will resemble: `F-CPR-99999`
- The following procedure is for CSD to follow when receiving a request to make changes to the VR configuration `MappingCenter.1.VelvetRope.BucketLimit`.

<style>
code {
        background-color:#fad980;
        color:darkblue;
}
</style>