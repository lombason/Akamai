#! /usr/bin/env python3

#import modules
import os
import sys
import json
import argparse
import logging
import datetime
import time 
import re

#variables required for the script
TICKET= input("Enter the deconstruction ticket: ")
TARGETS= input("Enter the deconstruction targets: ")


#functions

#maint -d 
def maintD():
    #run 
    print("maint -d")
    print("deconstructing ticket: " + TICKET)
    pri



#Set Required Variables; provided to CSD via Monocle
echo -e "\n${red}THIS SCRIPT REQUIRES MFA IN ORDER TO RUN SUCCESSFULLY; DO NOT PROCEED WITHOUT ENTERING MFA${clear}\n";
if [[  -n $1 ]]; then TICKET=$1; else read -p "Enter the deconstruction ticket: " TICKET; fi
if [[  -n $2 ]]; then TARGETS=${@:2}; else read -p "Enter the deconstruction targets: " -a TARGETS; fi

#Role Safety Checks ; relative to all Deconstruction
echo -e "\n\t\t${magenta}*********** $Running Decon Prechecks for given targets: $TARGETS **********${clear}\n"
echo -e "\\t\t${cyan}**This script is READ-ONLY; CSD is responsible to acknowledge its output **${clear}\n ";  
echo -e "\n=======================================================================================\n"
netCheck $TICKET $TARGETS   #calls the 'netCheck' function to print and update the TICKET; this is internal function tothis procedure
profiler $TICKET $TARGETS  #expanded; these are universal requirements of all deconstructions
disallowCheck $TICKET $TARGETS    #calls the 'disallowCheck'; if OS (-i || -k) is blocked on target machine  
cacCheck $TICKET $TARGETS; #calls the 'cacCheck' function to print and update the TICKET; these checks are for the CAC role and are required for all deconstructions
pCHCheck $TICKET $TARGETS; #calls 'pCHCheck'; determines if region is Protectec Cache -H; these checks are for the PCH role and are required for all deconstructions

### Determines if decon is Partial based on arr=${#TARGETS[@]} being an INTEGER than a Whole Number Value  ;;
if [[ ${TARGETS[@]}  =~ '.' ]]; then printf "\n Script has determined this is a Partial Deconstruction; Please notify CSD if this is incorrect\n" -t $TICKET; return;  fi

#FULL Deconstruction Safety Checks
echo -e "\n=======================================================================================\n"
echo -e "\n\t${magenta}*********** Running FULL Region Prechecks for given targets: $TARGETS **********${clear}\n"

camMonCheck $TICKET $TARGETS; #calls camMon fn; checks for secure monitored regions
eSNCheck $TICKET $TARGETS; #calls eSNCheck; checks if region is part of role: ESN
siteShieldCheck $TICKET $TARGETS; #calls 'siteShieldCheck'checks if region is part of role: siteShield
mCHCheck $TICKET $TARGETS; #calls 'mChCheck' checks if region is part of Metro Cache -H
edgeChecks $TICKET $TARGETS; #calls 'edgeChecks'; determines if region is ESSL/FF and runs the Maprules and SMLE Check
