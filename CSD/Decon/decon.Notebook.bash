#  ### calls the 'maint -d' function to print and update the TICKET
echo -e "\t\t${yellow}[maint -d] Acknowledge ALL Suspension Requirements${clear}\n";

maint -d ${TARGETS[@]} --tic $TICKET | tee $TICKET.tix;
update-tix -f -a "Acknowledge Suspension Requirements" -t $TICKET --summary;
  echo -e "\n=======================================================================================\n"
# ### ESSL - Scorch
erc $TARGETS stickystop mdtagent keyagent -r $TICKET --cassandra-ack stop_service_before_suspend@danger |(head ;tail) | tee $TICKET.tix; 
# ### ESSL - Scorch, if previous steps were successful, then run the following:
update-tix -f -a "scorching:stopping agents" -t $TICKET ; erc $TARGETS /a/sbin/keyagent_wipe |(head ;tail) | tee $TICKET.tix; update-tix -f -a "scorching:keyagent_wipe" -t $TICKET ; erc $TARGETS "rm -f mdtagent/var/persist/usr/local/akamai/etc/ghost/essl.data /a/etc/ghost/essl.data/esslindex.xml /a/etc/ghost/updates/essl.data/esslindex.xml"  |(head ;tail) | tee $TICKET.tix;  update-tix -f -a "scorching:agent files removed" -t $TICKET ; erc $TARGETS restart webghost issm  |(head ;tail) | tee $TICKET.tix && update-tix -f -a "scorching:keyagent_wipe" -t $TICKET  ; erc $TARGETS unstickystop mdtagent -r $TICKET  |(head ;tail) | tee $TICKET.tix && update-tix -f -a "scorching:restore mdtagent" -t $TICKET 
