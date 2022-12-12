import requests
import json

tokenfile = open("tokenfile", "r")
key = tokenfile.read()
tokenfile.close()

url = "https://prod-2.nsxservicemesh.vmware.com/tsm/v1alpha2/project/default/global-namespaces/rogerssc-gns-06/traffic-routing-policies/"

payload={}
headers = {
  'accept': 'application/json',
  'csp-auth-token': key
}

response = requests.request("GET", url, headers=headers, data=payload)

print(json.dumps(response.json(), indent=4))
