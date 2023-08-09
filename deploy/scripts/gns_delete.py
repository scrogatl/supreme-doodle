import requests
import sys
import json

def delete_gns(id):
  tokenfile = open("tokenfile", "r")
  key = tokenfile.read()
  tokenfile.close()
  url = "https://prod-2.nsxservicemesh.vmware.com/tsm/v1alpha1/global-namespaces/" + id

  headers = {
    'accept': 'application/json',
    'csp-auth-token': key,
    'Content-Type': 'application/json'
  }

  response = requests.request("DELETE", url, headers=headers)
  print(url)
  print(response)
  print(response.status_code)
  if  response.ok != True  :
    print(json.dumps(response.json(), indent=10))


if __name__ == "__main__":
  if(len(sys.argv) > 1):
    delete_gns(sys.argv[1])
  else:
    print("usage: python gns_create [gns description]")