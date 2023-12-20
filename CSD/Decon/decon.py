#! /usr/bin/env python3

#Future CSD Global Vars Library

#import modules
import os
import re


#global variables 
ticketID = ""
targets = []


#regex patterns
ticket_pattern = re.compile('[a-z]-[a-z]-[a-z0-9]{7}', re.I)



#functions

#function to get ticket ID
get_ticketID = input("Enter the ticket ID: ")
if ticket_pattern.match(get_ticketID):
    pass
    ticketID = get_ticketID 
else:
    print("Invalid ticket ID detected. Please try again.")

#function to get targets
    
get_targets():
    targets = input("Enter the targets: ").split()
    print("Targets: ", targets)