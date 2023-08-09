import requests
import sys
import json

def create_gns(fileName):
  tokenfile = open("tokenfile", "r")
  key = tokenfile.read()
  tokenfile.close()
  gnsFile = open(fileName)
  gns = gnsFile.read()
  json_gns = json.loads(gns)
  id = json_gns["name"]
  url = "https://prod-2.nsxservicemesh.vmware.com/tsm/v1alpha1/global-namespaces/" + id
  # url = "https://prod-2.nsxservicemesh.vmware.com/tsm/v1alpha1/global-namespaces" 

  headers = {
    'accept': 'application/json',
    'csp-auth-token': key,
    'Content-Type': 'application/json'
  }

  response = requests.request("PUT", url, headers=headers, data=gns)
  print(url)
  print(response)
  print(json.dumps(response.json(), indent=10))


if __name__ == "__main__":
  if(len(sys.argv) > 1):
    create_gns(sys.argv[1])
  else:
    print("usage: python gns_create [gns description]")