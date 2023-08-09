import requests
import json
import sys
from pathlib import Path

tokenfile = open("tokenfile", "r")
key = tokenfile.read()
tokenfile.close()

def put_policy(rawFileName, gnsID):
  woSuffix = Path(rawFileName).with_suffix('')
  fileName = str(woSuffix)
  
  url = "https://prod-2.nsxservicemesh.vmware.com/tsm/v1alpha2/project/default/global-namespaces/" + gnsID + "/traffic-routing-policies/" + fileName

  policyfile = open(rawFileName)
  policy = policyfile.read()
  headers = {
    'accept': 'application/json',
    'csp-auth-token': key,
    'Content-Type': 'application/json'
  }

  response = requests.request("PUT", url, headers=headers, data=policy)

  print(url)
  print(response.status_code)
  print(json.dumps(response.json(), indent=4))

if __name__ == "__main__":
  if(len(sys.argv) > 2):
    put_policy(sys.argv[1],sys.argv[2] )
  else:
    print("usage: python put_policy [policy file name] [gns name]")
