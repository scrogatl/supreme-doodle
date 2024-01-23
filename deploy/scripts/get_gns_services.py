import requests
import sys
import json

def get_gns_services(gnsID):
  tokenfile = open("tokenfile", "r")
  key = tokenfile.read()
  tokenfile.close()

  url = "https://prod-4-1.nsxservicemesh.vmware.com/tsm/v1alpha1/global-namespaces/" + gnsID + "/members"

  payload={}
  headers = {
    'accept': 'application/json',
    'csp-auth-token': key
  }

  response = requests.request("GET", url, headers=headers, data=payload)

  print(json.dumps(response.json(), indent=4))

if __name__ == "__main__":
  if(len(sys.argv) > 1):
    get_gns_services(sys.argv[1])
  else:
    print("usage: python get_gns_services.py [gns description]")