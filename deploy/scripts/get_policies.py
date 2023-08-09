import requests
import json
import sys

def get_gns_policies(gnsID):
  tokenfile = open("tokenfile", "r")
  key = tokenfile.read()
  tokenfile.close()

  url = "https://prod-2.nsxservicemesh.vmware.com/tsm/v1alpha2/project/default/global-namespaces/" + gnsID + "/traffic-routing-policies/"

  payload={}
  headers = {
    'accept': 'application/json',
    'csp-auth-token': key
  }

  response = requests.request("GET", url, headers=headers, data=payload)

  print(url)
  print(json.dumps(response.json(), indent=4))

if __name__ == "__main__":
  if(len(sys.argv) > 1):
    get_gns_policies(sys.argv[1])
  else:
    print("usage: python get_policies.py [gns name]")