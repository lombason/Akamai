#! /usr/env/python3 
"""Functions to be used in this project; written in the order they are executed"""


#Libraries anticipated to be used in this project
import os
import re
import time 
import datetime

"""Functions to be used in this project; written in the order they are executed"""


#start timer to track script execution time ; will require a function to stop the timer and calculate the time elapsed at the end of the script
start_time = time.localtime()

#global variables 

#shorthand
invalid_entry = "Invalid entry. Please try again."
user_name = os.environ.get('USER')
success_message = "Success! Please continue with the deconstruction."



#get current date and time
now = datetime.datetime.now()
date = now.strftime("%Y-%m-%d")
time = now.strftime("%H:%M:%S")

#gets the ticket id from the user and verifies is valid
def get_ticket_ID():
    ticket_ID = input("Please enter the ticket ID: ")
    ticket_re = re.compile('B-[a-z]-[a-z0-9]{7}', re.IGNORECASE)
    if ticket_re.match(ticket_ID):
        print(success_message)
    else:
        print(invalid_entry)
        get_ticket_ID()
    return ticket_ID
    
#get the targets from the user
def get_targets():
    targets = input("Please enter the targets: ").split()
    ip_addr_re = re.compile(r'\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}')
    decon_re_match = re.match(ip_addr_re, targets[0])
    if decon_re_match:
        decon_type = 'partial'
    else:
        decon_type = 'full' 
    return targets, decon_type


#ask user for date ticket was created 
def get_date_created():
    decon_created_on = input("Please enter the date the ticket was created (YYYY-MM-DD): ")
    decon_created_on_re = re.compile(r'\d{4}-\d{2}-\d{2}')
    created_date_valid = re.match(decon_created_on_re, decon_created_on)
    if created_date_valid:
        pass
    else:
        get_date_created()
    return decon_created_on

#ask user for date decon is scheduled    
def get_date_scheduled():
    decon_actual = input("Please enter the date the decon was actually performed (YYYY-MM-DD): ")
    decon_actual_re = re.compile(r'\d{4}-\d{2}-\d{2}')
    actual_date_valid = re.match(decon_actual_re, decon_actual)
    if actual_date_valid:
        pass
    else:
        print(invalid_entry)
        get_date_scheduled()
    return decon_actual

#ALL DECONSTRUCTION PROCEDURAL CHECKS As Functions; required to perform the deconstruciton
def kahuna_check():
    decon_maint =os.system('maint -d 45836 --tic B-V-4XNCJDR')   
    #return maint_decon.stdout.decode('utf-8')
    #print(maint_decon.stdout.decode('utf-8'))



def get_target_status():
    livecheck = os.system('maka -p ${TARGETS[@]}')
    #return live_host.stdout.decode('utf-8')
    #print(live_host.stdout.decode('utf-8'))
    ## ADD CAMERAMON ROLES TO THIS


def get_open_tics():   ##add cameramon to this function
    open_tics = os.system('malt -t ${TARGETS[@]}')
    #return open_tics.stdout.decode('utf-8')
    #print(open_tics.stdout.decode('utf-8'))

    #def is_it_cameramon():
    #role_check = os.system('iptool ${TARGETS[@]}| grep -i cameramon ')
    #return role_check.stdout.decode('utf-8')
    #print(role_check.stdout.decode('utf-8'))

def check_disallow():
    disallow = os.system('erc $IP "grep reason /a/etc/netdeploy.conf; echo ''" ')
    #return disallow.stdout.decode('utf-8')
    #print(disallow.stdout.decode('utf-8'))

def is_it_CAC():
    cac_check= os.system('makodb  "SELECT regionid is_cac_region FROM MROBJ.MOM_RS_1997 where regionid in ($(iptool ${TARGETS[@]} -c | sed "s/([^)]*)//g" | tr ',' ' '| awk '{print $2}'| tail -1))"')
    #return cac_check.stdout.decode('utf-8')
    #print(cac_check.stdout.decode('utf-8'))

def is_it_protectedCache():
    pch_check = os.system('agg mega "select case when region IS NULL THEN '' Else 'YES' END is_this_pch_region from region_use_type where region_use_type='web-default-cache-h' and region=($(iptool ${TARGETS[@]} -c | sed "s/([^)]*)//g" | tr ',' ' '| awk '{print $2}'| tail -1))"')
    #return pch_check.stdout.decode('utf-8')
    #print(pch_check.stdout.decode('utf-8'))

def is_it_cameramon():
    role_check = os.system('iptool ${TARGETS[@]}| grep -i cameramon ')
    #return role_check.stdout.decode('utf-8')
    #print(role_check.stdout.decode('utf-8'))
                           
def is_it_ESN():
  role_check = os.system('agg mega "select distinct region from region_use_type_union where region_use_type='staging' and region in (select physregion from machinedetails where machineip not in (select machineip from machinesvc where service='syntaxtest')) and region=${TARGETS[@]}" ')
    #return role_check.stdout.decode('utf-8')
    #print(role_check.stdout.decode('utf-8'))
                         
def is_it_monitoring():
    role_check = os.system('agg mega 'select distinct network from  machinedetails where physregion='${TARGETS[@]}''| awk 'NR==3 {print $1}' ')
    #return role_check.stdout.decode('utf-8')
    #print(role_check.stdout.decode('utf-8'))
                                                                                                                                  

def is_it_siteShield():
    role_check = os.system('makodb 'select region_id from mrom_special_regions a, mrom_special_regions_data b where a.special_region_id = b.id and region_set_id in (215,217,219,222) and region_id='${TARGETS[@]}'  group by region_id order by region_id'')
    #return role_check.stdout.decode('utf-8')
    #print(role_check.stdout.decode('utf-8'))

def is_it_metroCache():
    role_check = os.system('agg map "SELECT region FROM rm_region_sets WHERE region_set = 'regionset_slow_deconstruction' AND region=${TARGETS[@]}"')
    #return role_check.stdout.decode('utf-8')
    #print(role_check.stdout.decode('utf-8'))

def check_for_maprule():
    maprule_check = os.system('makodb "select region, service, maprule, name, map_group, description from (select mr from MROBJ.MOM_MS_1089) a, (select mapruleid, region from mcm_regionpreferences where timestamp=(select max(timestamp) from mcm_regionpreferences) and (rp_tier=1 or preferencelevel=100) and region in (${TARGETS[@]}) ) b, (select mr, service, description from maprules) c, (select maprule, name, map_group from midgress_map_groups) d where a.mr=b.mapruleid and a.mr=c.mr and a.mr=d.maprule order by 1,3"')
    #return maprule_check.stdout.decode('utf-8')
    #print(maprule_check.stdout.decode('utf-8'))


def is_region_SMLE():
    role_check = os.system(' Visit the URL: https://www.netarch.akamai.com/sql/lranchev/core_smle_region_check_in_ecor?region=$TARGETS  ')
    #return role_check.stdout.decode('utf-8')
    #print(role_check.stdout.decode('utf-8'))

def akamai_network():
    role_check = os.system('agg mega 'select distinct network from  machinedetails where physregion='$(iptool ${TARGETS[@]} -c | sed "s/([^)]*)//g" | tr ',' ' '| awk '{print $2}'| tail -1)''| awk 'NR==3 {print $1}' ')
    #return role_check.stdout.decode('utf-8')
    #print(role_check.stdout.decode('utf-8'))   



ticket_ID=get_ticket_ID()
targets=get_targets()
get_date_scheduled()
get_date_created()
kahuna_check(ticket_ID, targets)

print(f'It is currently {time} (local) on {date}. {user_name}.upper() is performing a {decon_type} deconstruction in ticket {ticket_ID}')
print(f"Please confirm {ticket_ID} is a {decon_type} deconstruction ticket.")



