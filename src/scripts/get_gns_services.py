import requests
import sys
import json


tokenfile = open("tokenfile", "r")
key = tokenfile.read()
tokenfile.close()

url = "https://prod-2.nsxservicemesh.vmware.com/tsm/v1alpha1/global-namespaces/rogerssc-gns-06/members"

payload={}
headers = {
  'accept': 'application/json',
  'csp-auth-token': key
}

response = requests.request("GET", url, headers=headers, data=payload)

print(json.dumps(response.json(), indent=4))
