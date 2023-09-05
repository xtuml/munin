# 2023-08-31T14:49:30.835063Z 1
# jobName = ProtocolVerifier :
# jobId = cd0b900c-ca8a-4234-9c67-d44d62df6ba7 :
# eventType = AEO_PVJobStart :
# eventId = f919223d-6118-4aa0-a513-112654bdbf29 :
# previousEventIds =  :
# auditEventData = NotUsed

import json
import sys

# Loop through standard input parsing log file lines one at a time.
j = []
for line in sys.stdin:
    e = {}                                        # empty JSON object
    line = line.rstrip().split(' ',1)             # split out timestamp
    e['timestamp'] = line[0]
    line = line[1].split(' ',1)                   # split out log number (junk)
    line = line[1].split(':')                     # split remaining fields by :
    e['jobName'] = line[0].split()[2].strip()
    e['jobId'] = line[1].split()[2].strip()
    e['eventType'] = line[2].split()[2].strip()
    e['eventId'] = line[3].split()[2].strip()
    if len( line[4].split() ) >= 3:               # prevs are optional
       e['previousEventIds'] = []
       e['previousEventIds'].append(line[4].split(' ',3)[3].strip())
    #auditeventdata = line[5]
    e['applicationName'] = "PVapplication"
    j.append(e)
print( json.dumps(j, indent=4) )

