#! /bin/bash
#Execute and Print Platform Operations Safety Check Requirements for Deconstruction
deconReport(){

  # Color settings
  red='\033[0;31m'
  green='\033[0;32m'
  yellow='\033[0;33m'
  blue='\033[0;34m'
  magenta='\033[0;35m'
  cyan='\033[0;36m'
  clear='\033[0m'
  
  #Set Required Variables; provided to CSD via Monocle
  if [[  -n $1 ]]; then TICKET=$1; else read -p "Enter the deconstruction ticket: " TICKET; fi
  if [[  -n $2 ]]; then TARGETS=${@:2}; else read -p "Enter the deconstruction targets: " -a TARGETS; fi

  #Role Safety Checks ; relative to all Deconstruction
  
  echo -e "\n\t\t${magenta}*********** $Running Decon Prechecks for given targets: $TARGETS **********${clear}\n"
  echo -e "\\t\tn${cyan}**This script is READ-ONLY; CSD is responsible to acknowledge its output **${clear}\n ";  
  echo -e "\n=======================================================================================\n"
  
  profiler $TICKET $TARGETS  #expanded; these are universal requirements of all deconstructions
  disallowCheck $TICKET $TARGETS    #calls the 'disallowCheck'; if OS (-i || -k) is blocked on target machine  
  netCheck $TICKET $TARGETS         #calls the 'netCheck' function to print and update the TICKET; this is internal function tothis procedure
  cacCheck $TICKET $TARGETS; #calls the 'cacCheck' function to print and update the TICKET; these checks are for the CAC role and are required for all deconstructions
  pCHCheck $TICKET $TARGETS; #calls 'pCHCheck'; determines if region is Protectec Cache -H; these checks are for the PCH role and are required for all deconstructions

  ### Determines if decon is Partial based on arr=${#TARGETS[@]} being an INTEGER than a Whole Number Value  ;;
  if [[ ${TARGETS[@]}  =~ '.' ]]; then printf "This is a Partial Deconstruction; Proceed to Monocle to continue \n" -t $TICKET; return ; fi

  #FULL Deconstruction Safety Checks
  echo -e "\n=======================================================================================\n"
  echo -e "\n\t${magenta}*********** Running FULL Region Prechecks for given targets: $TARGETS **********${clear}\n"

  camMonCheck $TICKET $TARGETS; #calls camMon fn; checks for secure monitored regions
  eSNCheck $TICKET $TARGETS; #calls eSNCheck; checks if region is part of role: ESN
  siteShieldCheck $TICKET $TARGETS; #calls 'siteShieldCheck'checks if region is part of role: siteShield
  mCHCheck $TICKET $TARGETS; #calls 'mChCheck' checks if region is part of Metro Cache -H
  edgeChecks $TICKET $TARGETS; #calls 'edgeChecks'; determines if region is ESSL/FF and runs the Maprules and SMLE Check

};

profiler(){
  echo -e "\n${magenta}Profiling Targets: ${cyan} maint -d, malt, maka -p, and checking for cameramon roles${clear}\n";
  #calls the 'maint -d' function to print and update the TICKET
  echo -e "\t\t${yellow}[maint -d] Acknowledge ALL Suspension Requirements${clear}\n";
  maint -d ${TARGETS[@]} --tic $TICKET | tee $TICKET.tix;
  update-tix -f -a "Acknowledge Suspension Requirements" -t $TICKET --summary;
  echo -e "\n=======================================================================================\n"

  #check availability and phase target info
  echo -e "\t\t${yellow}[maka -p] Check for target availability (livecheck)${clear}\n";
  maka -p ${TARGETS[@]} | tee $TICKET.tix;  #livecheck of given targets
  update-tix -f -a "Availability of given targets for deconstruction" -t $TICKET;
  echo -e "\n=======================================================================================\n"

  #Prints tickets found by IP address
  echo -e "\t\t${yellow}[malt] - Acknowledge and link tickets found to deconstruction ticket${clear}\n";
  for ip in $(iptool -i ${TARGETS[@]}) ; do malt $ip; done | tee $TICKET.tix;
  update-tix -f -a "Match And LINK Open Ticket for given targets"  -t $TICKET;
  echo -e "\n=======================================================================================\n"

  #identifies any cameramon roles
  echo -e "\t\t${yellow}[cameramon] Checking for cameramon roles ${clear} \n";
  iptool ${TARGETS[@]}| grep -i cameramon | tee $TICKET.tix;
  update-tix -f -a '[CameraMon] Return to Procedure for details.' -t $TICKET --todo;
  echo -e "\n=======================================================================================\n"

  camMonCheck(){
    #determines network types and checks if camera monitoring check is applicable 
    line=$(agg mega 'select distinct network from  machinedetails where physregion='${TARGETS[@]}''| awk 'NR==3 {print $1}');
    case $line in
    "essl" | "crypto" | "nevada" | "quill" | "ness" | "volta")
      echo -e "${yellow}[Secure Camera Monitoring Region Check]${clear} \n";
      agg mega "select value camera_region, stanzaname monitored_region from stanzanotes_postinstall where name = 'camera_region' AND value = '${TARGETS[@]}'" | tee $TICKET.tix;
      line=$(awk 'NR==3 {print $1}' $TICKET.tix);

      case $line in
        ${TARGETS[@]})
          echo -e "\n${red}DO NOT PROCEED: Monitored Regions Found - if no tickets related to monitored_regions found Contact NIE/Requestor ${clear}"
          printf "DO NOT PROCEED Unless monitored regions have already undergone deconstruction \nConfirm tickets for affected regions have been submitted. Check with NIE/ Requestor for details \nhttps://www.nocc.akamai.com/essl_camera/index.cgi?region=$TARGETS \n" >> $TICKET.tix;
          update-tix -f -a '[CameraMon Region] DO NOT PROCEED Unless monitored regions have already undergone deconstruction' -t $TICKET --ack;
          ;;
        "")
          echo -e "\n${green} SAFE - Please Proceed${clear} \n";
          printf "[CameraMon REGION] SAFE - No regions found - Please Proceed \n Secure Camera Page: https://www.nocc.akamai.com/essl_camera/index.cgi?region=$TARGETS"  >> $TICKET.tix;
          update-tix -f -a "[CameraMon Region] SAFE - Please Proceed" -t $TICKET;
          ;;
        *)
          echo -e "\n${red}[CameraMon Region] DO NOT PROCEED; RETURN TO PROCEDURE${clear}\n";
          printf "Proceed to Secure Camera Page: \r https://www.nocc.akamai.com/essl_camera/index.cgi?region=$TARGETS \r"  >> $TICKET.tix
          update-tix -f -a '[CameraMon Region] Proceed to Secure Camera Page for verification: \r https://www.nocc.akamai.com/essl_camera/index.cgi?region=$TARGETS' -t $TICKET --ack;
          ;;
      esac
      [[ -f $TICKET.tix ]]; rm $TICKET.tix; 
    echo -e "\n=======================================================================================\n"
    esac
    };
  [[ -f $TICKET.tix ]]; rm $TICKET.tix; #removes the temp file

};

disallowCheck(){

  echo -e "\t\t${yellow}[Disallow Check]${clear} \n";
  erc ${TARGETS[@]} "grep -i disallow_osinstall /a/etc/netdeploy.conf" | tee $TICKET.tix;
  line=$(erc ${TARGETS[@]} "grep -i disallow /a/etc/netdeploy.conf" | grep DISALLOW_OSINSTALL=1 | tail -1 );

  case $line in
    "DISALLOW_OSINSTALL=1")
      echo -e "\n${red} OS Disallow found, request approval from r https://www.nocc.akamai.com/elist/?mode=home_liaisons ${clear} \n"
      update-tix -f -a '[DISALLOWED] Request Approval from Network Liason; DDC targets may procced [APPROVAL]' -t $TICKET --todo;
      ;;
    "")
      echo -e "\n${green}[Disallow Check]SAFE - Please Proceed${clear} \n";
      update-tix -f -a '[Disallow Check]SAFE - Please Proceed' -t $TICKET;
      ;;
    *)
      echo -e "\n${red}[Disallow Check] DO NOT PROCEED; RETURN TO PROCEDURE${clear} \n";
      update-tix -f -a '[Disallow Check]DO NOT PROCEED; RETURN TO PROCEDURE' -t $TICKET --ack;
      ;;
   esac
  echo -e "\n=======================================================================================\n"
  [[ -f $TICKET.tix ]]; rm $TICKET.tix;
};

netCheck(){     #DOES NOT PRINT TO TICKET - LOCAL USE ONLY
    nets=$(agg mega 'select distinct network from  machinedetails where physregion='${TARGETS[@]}''| awk 'NR==3 {print $1}');

  case $nets in
    "ddc")
      echo -e "\n${red}DDC Network; Special Instruction: https://www.nocc.akamai.com/alertproc/view.cgi?id=7057${clear} \n"
      update-tix -f -a 'DDC Network; Special Instruction: https://www.nocc.akamai.com/alertproc/view.cgi?id=7057' -t $TICKET --todo;
      ;;
    "brave")
      echo -e "\n${red}BRAVE Network; Special Instruction: https://www.nocc.akamai.com/doc/view.cgi?id=2289${clear} \n"
      update-tix -f -a 'BRAVE Network; Special Instruction: https://www.nocc.akamai.com/doc/view.cgi?id=2289' -t $TICKET --todo;
      ;;
    "cobra")
      echo -e "\n${red}COBRA Network; Special Instruction: https://www.nocc.akamai.com/doc/view.cgi?id=2513${clear} \n"
      update-tix -f -a 'COBRA Network; Special Instruction: https://www.nocc.akamai.com/doc/view.cgi?id=2513' -t $TICKET --todo;
      ;;
    "ness")
      echo -e "\n${red}NESS Network; Special Instruction: https://www.nocc.akamai.com/alertproc/view.cgi?id=4753${clear} \n"
      printf "SysOps escalation is required; Get all approvals before reassigning" >> $TICKET.tix;
      update-tix -f -a 'NESS Network; Special Instruction: https://www.nocc.akamai.com/alertproc/view.cgi?id=4753' -t $TICKET --todo;
      ;;
    "chive")
      echo -e "\n${red}CHIVE Network; Special Instruction: https://www.nocc.akamai.com/doc/view.cgi?id=3568${clear} \n"

      update-tix -f -a 'CHIVE Network; Special Instruction: https://www.nocc.akamai.com/doc/view.cgi?id=3568' -t $TICKET --needs-ack;
      ;;
    "essl" | "crypto" | "nevada" | "srip sport")
      echo -e "\n ${red}Scorch& Blacklist required for Secure network https://www.nocc.akamai.com/alertproc/view.cgi?id=4725${clear} \n"
      update-tix -f -a 'Scorch& Blacklist required for Secure network https://www.nocc.akamai.com/alertproc/view.cgi?id=4725' -t $TICKET --todo;
      ;;
    *)  
      echo -e "\nNo Special Network Instructions\n"
      ;;
  esac 
  echo -e "\n=======================================================================================\n"

};

cacCheck(){
  echo -e "${yellow}[CAC Region Check]${clear} \n";
  makodb  "SELECT regionid is_cac_region FROM MROBJ.MOM_RS_1997 where regionid in ($(iptool ${TARGETS[@]} -c | sed "s/([^)]*)//g" | tr ',' ' '| awk '{print $2}'| tail -1))" | tee $TICKET.tix;
  line=$(awk 'NR==3 {print $1}' $TICKET.tix);
  
  case $line in
    ${TARGETS[@]})
      echo -e "\n${red}[CAC Region] REQUEST APPROVALS: dl-map-specialist@akamai.com and CC NIE requester${clear} \n";
      printf "DO NOT PROCEED , send approval email to dl-map-specialist@akamai.com and CC NIE requester" >> $TICKET.tix

      update-tix -f -a '[CAC] REQUEST APPROVAL from dl-map-specialist@akamai.com;' -t $TICKET --summary;
     ;;
    "")
      echo -e "\n${green}SAFE - Please Proceed${clear} \n";
      update-tix -f -a '[CAC] SAFE - Please Proceed' -t $TICKET;
     ;;
    *)
      echo -e "\n${red}[CAC]DO NOT PROCEED; RETURN TO PROCEDURE${clear} \n";
      update-tix -f -a '[CAC]DO NOT PROCEED; RETURN TO PROCEDURE' -t $TICKET --ack;
     ;;
  esac
  echo -e "\n=======================================================================================\n"
  [[ -f $TICKET.tix ]]; rm $TICKET.tix;
};

pCHCheck(){
  echo -e "${yellow}[Protected Cache-H Region Check]${clear} \n" ;
  agg mega "select case when region IS NULL THEN '' Else 'YES' END is_this_pch_region from region_use_type where region_use_type='web-default-cache-h' and region=($(iptool ${TARGETS[@]} -c | sed "s/([^)]*)//g" | tr ',' ' '| awk '{print $2}'| tail -1))" | tee $TICKET.tix;
  line=$(awk 'NR==3 {print $1}' $TICKET.tix);

  case $line in
    ${TARGETS[@]})
      echo -e "\n${red}[Protected Cache-H] REQUEST APPROVAL from dl-web-pch-sme@akamai.com${clear} \n";
      printf "Escalation Path: https://www.nocc.akamai.com/elist/?g_id=2489 \r Confluence: https://collaborate.akamai.com/confluence/pages/viewpage.action?pageId=237637089 " >> $TICKET.tix ;
      update-tix -f -a 'Protected Cache-H] REQUEST APPROVAL from dl-web-pch-sme@akamai.com${clear} ' -t $TICKET --summary;
      ;;

    "")
      echo -e "\n${green}SAFE - Please Proceed${clear} \n";
      update-tix -f -a '[Protected Cache-H] SAFE - Please Proceed' -t $TICKET;
      ;;
    *)
      echo -e "\n[Protected Cache-H Region Check] RETURN TO PROCEDURE; Check failed to run";
      update-tix -f -a "[Protected Cache-H Region Check] RETURN TO PROCEDURE; Check failed to run" -t $TICKET --summary;
    ;;
  esac
  echo -e "\n=======================================================================================\n"
  #[[ -f $TICKET.tix ]]; rm $TICKET.tix;
};

camMonCheck(){
  #determines network types and checks if camera monitoring check is applicable 
  line=$(agg mega 'select distinct network from  machinedetails where physregion='${TARGETS[@]}''| awk 'NR==3 {print $1}');
  case $line in
  "essl" | "crypto" | "nevada" | "quill" | "ness" | "volta")
    echo -e "${yellow}[Secure Camera Monitoring Region Check]${clear} \n";
    agg mega "select value camera_region, stanzaname monitored_region from stanzanotes_postinstall where name = 'camera_region' AND value = '${TARGETS[@]}'" | tee $TICKET.tix;
    line=$(awk 'NR==3 {print $1}' $TICKET.tix);

    case $line in
      ${TARGETS[@]})
        echo -e "\n${red}DO NOT PROCEED: Monitored Regions Found - if no tickets related to monitored_regions found Contact NIE/Requestor ${clear}"
        printf "DO NOT PROCEED Unless monitored regions have already undergone deconstruction \nConfirm tickets for affected regions have been submitted. Check with NIE/ Requestor for details \nhttps://www.nocc.akamai.com/essl_camera/index.cgi?region=$TARGETS \n" >> $TICKET.tix;
        update-tix -f -a '[CameraMon Region] DO NOT PROCEED Unless monitored regions have already undergone deconstruction' -t $TICKET --ack;
        ;;
      "")
        echo -e "\n${green} SAFE - Please Proceed${clear} \n";
        printf "[CameraMon REGION] SAFE - Please Proceed \n https://www.nocc.akamai.com/essl_camera/index.cgi?region=$TARGETS"  >> $TICKET.tix;
        update-tix -f -a "[CameraMon Region] SAFE - Please Proceed" -t $TICKET;
        ;;
      *)
        echo -e "\n${red}[CameraMon Region] DO NOT PROCEED; RETURN TO PROCEDURE${clear}\n";
        printf "Proceed to Secure Camera Page: \r https://www.nocc.akamai.com/essl_camera/index.cgi?region=$TARGETS \r"  >> $TICKET.tix
        update-tix -f -a '[CameraMon Region] Proceed to Secure Camera Page for verification: \r https://www.nocc.akamai.com/essl_camera/index.cgi?region=$TARGETS' -t $TICKET --ack;
        ;;
    esac
   [[ -f $TICKET.tix ]]; rm $TICKET.tix; 
  echo -e "\n=======================================================================================\n"
  esac
};

eSNCheck(){
  echo -e "${yellow}[ESN Region]${clear} \n";
  agg mega "select distinct region from region_use_type_union where region_use_type='staging' and region in (select physregion from machinedetails where machineip not in (select machineip from machinesvc where service='syntaxtest')) and region=${TARGETS[@]}" | tee $TICKET.tix;
  line=$(awk 'NR==3 {print $1}' $TICKET.tix)
  
  case $line in
    ${TARGETS[@]})
      echo -e "\n${red}[eSN] Send Notification to cc-infra@akamai.com, esn@akamai.com and tesingh@akamai.com${clear}";
      printf "Include the following statement in your email: \r This statement: The procedures for updating the ESN/SESN firewall rules notification lists on the Portal and notifying customers of the change are found at: https://www.nocc.akamai.com/doc/view.cgi?id=3097 " > $TICKET.tix
      update-tix -f -a '[ESN NOTIFICATION] Email notification cc-infra@akamai.com, esn@akamai.com and tesingh@akamai.com'  -t $TICKET --todo;
     ;;
    "")
      echo -e "\n${green} SAFE - Please Proceed${clear} \n";
      update-tix -f -a '[ESN] SAFE - Please Proceed' -t $TICKET;
     ;;
    *)
      echo -e "\n${red}[eSN]  DO NOT PROCEED; RETURN TO PROCEDURE${clear}\n";
      update-tix -f -a '[eSN Check] DO NOT PROCEED; RETURN TO PROCEDURE' -t $TICKET --ack;
     ;;
  esac
  echo -e "\n=======================================================================================\n"
  [[ -f $TICKET.tix ]]; rm $TICKET.tix;
};

siteShieldCheck(){
  echo -e "${yellow}[Siteshield Check]${clear} \n";
  makodb 'select region_id from mrom_special_regions a, mrom_special_regions_data b where a.special_region_id = b.id and region_set_id in (215,217,219,222) and region_id='${TARGETS[@]}'  group by region_id order by region_id' | tee $TICKET.tix;
  line=$(awk 'NR==3 {print $1}' $TICKET.tix);

    case $line in
      ${TARGETS[@]})
        echo -e "\n${red}[SiteShield] Send notification to siteshield-map-ops@akamai.com${clear} \n";
        update-tix -f -a '[SiteShield] SEND NOTIFICATION to siteshield-map-ops@akamai.com' -t $TICKET --todo;
        ;;
      "")
        echo -e "\n${green} SAFE - Please Proceed${clear} \n";
        update-tix -f -a '[SiteShield] SAFE - Please Proceed' -t $TICKET;
        ;;
      *)
        echo -e "\n${red}[SiteShield] DO NOT PROCEED; RETURN TO PROCEDURE${clear} \n" \n;
        update-tix -f -a '[SiteShield] DO NOT PROCEED; RETURN TO PROCEDURE' -t $TICKET --ack;
       ;;
    esac
  echo -e "\n=======================================================================================\n"
  echo
  [[ -f $TICKET.tix ]]; rm $TICKET.tix;
};

mCHCheck(){
  echo -e "${yellow}[Metro Cache-H]${clear} \n";
  agg map "SELECT region FROM rm_region_sets WHERE region_set = 'regionset_slow_deconstruction' AND region=${TARGETS[@]}" | tee $TICKET.tix;
  line=$(awk 'NR==3 {print $1}' $TICKET.tix);

  case $line in
    ${TARGETS[@]})
      echo   "${red}[Metro Cache-H] VERIFY DATE Requested Date must be 7 days following tickets Creation Date${clear} \n";
      printf "If the Deconstruction Date is within 7 days of ticket Creation Date; \r -Complete and Send email below to requestor \r -Set ticket Wake Up Date to 8 days following the Creation Date : \r
      Hi, \n
      Region $TARGETS scheduled for deconstruction is part of MCH (Metro Cache-H) and is serving important cache-h content. We have delayed region suspension to allowing 1 week to gracefully move the traffic away. If that delay with region suspension is not acceptable, please reply to this email and ask the NOCC team to set the suspension date in the ticket abstract according to your requirements." > $TICKET.tix;
      update-tix -f -a '[Metro Cache-H] Verify Dates; Actions contingent on Ticket Creation date  ' -t $TICKET --todo;
      ;;
    "")
      echo -e "\n${green} SAFE - Please Proceed${clear} \n";
      update-tix -f -a '[Metro Cache-H] SAFE - Please Proceed' -t $TICKET;
      ;;
    *)
      echo -e "\n${red}[Metro Cache-H]  DO NOT PROCEED; RETURN TO PROCEDURE${clear} \n\n";
      update-tix -f -a "[Metro Cache-H] DO NOT PROCEED; RETURN TO PROCEDURE" -t $TICKET --summary;
     ;;
    esac
    echo -e "\n=======================================================================================\n"

  [[ -f $TICKET.tix ]]; rm $TICKET.tix;
};

edgeChecks(){            #DOES NOT PRINT TO TICKET - LOCAL USE ONLY
  line=$(agg mega 'select distinct network from  machinedetails where physregion='${TARGETS[@]}''| awk 'NR==3 {print $1}');

  case $line in
    "freeflow" | "essl" )
      mapRuleCheck $TICKET $TARGETS;  #calls 'mapRuleCheck' ; ESSL/FF check of Cache -H
      sMLEPrint $TICKET $TARGETS; #calls  'sMLECheck'; are targets part of softMLE
      ;;
    *)
      ;;
    esac
};

mapRuleCheck(){
  echo -e "${yellow}[MapRule CacheH Region Check]${clear} \n";
  makodb "select region, service, maprule, name, map_group, description from (select mr from MROBJ.MOM_MS_1089) a, (select mapruleid, region from mcm_regionpreferences where timestamp=(select max(timestamp) from mcm_regionpreferences) and (rp_tier=1 or preferencelevel=100) and region in (${TARGETS[@]}) ) b, (select mr, service, description from maprules) c, (select maprule, name, map_group from midgress_map_groups) d where a.mr=b.mapruleid and a.mr=c.mr and a.mr=d.maprule order by 1,3" | tee $TICKET.tix;
  line=$(awk 'NR==3 {print $1}' $TICKET.tix);
  case $line in
    $TARGETS)
      echo -e "\n${red}[Not a blocker for the CSD decon process] Check map-ops JIRA Queue for open tickets${clear} \n" ;
      printf '%s\n' " Go to : \r https://track.akamai.com/jira/issues/?jql=project\%20in%20%20(%22GSP%20MapTix%22%2C%20%22GSP%20Mapping%20Strategy%22)%20AND%20(%20summary%20~%20r"$TARGETS"%20or%20summary%20~%20"$TARGETS") \n

      -If no JIRA ticket found ; Notify the requestor to follow the Mapping Strategy Engagement Process from:
      https://collaborate.akamai.com/confluence/pages/viewpage.action?spaceKey=EPA&title=Engaging+with+Mapping+Strategy" >> $TICKET.tix;
      update-tix -f -a "[MapRule - CacheH]JIRA Escalation may be required; This check is NOT a blocker for deconstruction"  -t $TICKET --todo; 
     ;;
    "")
      echo -e "\n${green}SAFE - Please Proceed${clear} \n";
      update-tix -f -a "[MapRule - CacheH] SAFE - Please Proceed"  -t $TICKET;
      ;;
    *)
      echo -e "\n${red}[MapRule - CacheH] RETURN TO PROCEDURE; Check failed to run${clear} \n";
      update-tix -f -a "[MapRule - CacheH] RETURN TO PROCEDURE; Check failed to run" -t $TICKET --summary;
     ;;
    esac
  echo -e "\n=======================================================================================\n"
  [[ -f $TICKET.tix ]]; rm $TICKET.tix;
};

sMLEPrint(){
  echo -e "${yellow}[SMLE] Visit the URL: https://www.netarch.akamai.com/sql/lranchev/core_smle_region_check_in_ecor?region=$TARGETS  to determine if this is an SMLE Region and escalate accordingly${clear} \n";
  printf "Go to: \r https://www.netarch.akamai.com/sql/lranchev/core_smle_region_check_in_ecor?region=$TARGETS \r" > $TICKET.tix;
  update-tix -f -a "[SMLE] ACK this only upon receiving approvals" -t $TICKET --ack;
 
  echo -e "\n=======================================================================================\n"
  
  [[ -f $TICKET.tix ]]; rm $TICKET.tix;
};
