agg map "select lil.linkName link, lil.contractName contract, lp.purpose purpose, string_join(lil.circuitID, ', ') router_bundle_circuits, lil.state state, (CASE when purpose='transit' THEN 'YES' ELSE 'no' END) transit_connection from mle_link_id_list lil, rm_location_ports lp, rm_ecors e where lil.ecorID = e.ecor and e.ecor_name='$ECOR_NAME' and lil.circuitID = lp.circuit_id group by 1 order by 1"



agg map "select bandwidthEcorName ecor_name,linkID,linkName,contractName,state,router_bundle_circuits,total_router_bundle from (select * from mcm_regionecortable where bandwidthEcorName='$ECOR_NAME' group by bandwidthEcorId) a,   (select ecorid,linkID,linkName,contractName,state,string_join(circuitID, ', ') router_bundle_circuits,count(circuitID) total_router_bundle from mle_link_id_list group by ecorid,contractName) b, where a.bandwidthEcorId=b.ecorid"


agg map "(select lp.purpose purpose from rm_location_ports lp) union ((select bandwidthEcorName from (select * from mcm_regionecortable where bandwidthEcorName='$ECOR_NAME' group by bandwidthEcorId) a,   (select ecorid,linkID,linkName,contractName,state,string_join(circuitID, ', ') router_bundle_circuits,count(circuitID) total_router_bundle from mle_link_id_list group by ecorid,contractName) b, where a.bandwidthEcorId=b.ecorid) LIMIT 5"