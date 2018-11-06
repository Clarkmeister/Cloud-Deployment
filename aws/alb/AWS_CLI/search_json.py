import json
import sys
#import ast

#print str(sys.argv[1])

#prompt the user for a file to import

filename = "resources.json"

#Read JSON data into the datastore variable
if filename:
    with open(filename, 'r') as f:
        datastore = json.load(f)

numInstances = len(datastore['Reservations'])

for x in range(numInstances):
   if datastore["Reservations"][x]["Instances"][0]["Tags"][0]["Value"] == "mjolnir build Test":
	  print datastore["Reservations"][x]["Instances"][0]["InstanceId"]
	
