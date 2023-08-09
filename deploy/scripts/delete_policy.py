import requests
import json
import sys

tokenfile = open("tokenfile", "r")
key = tokenfile.read()
tokenfile.close()

def delete_policy(policyName, gnsID):
  url = "https://prod-2.nsxservicemesh.vmware.com/tsm/v1alpha2/project/default/global-namespaces/" + gnsID + "/traffic-routing-policies/" + policyName

  payload={}
  headers = {
    'accept': 'application/json',
    'csp-auth-token': key
  }

  response = requests.request("DELETE", url, headers=headers, data=payload)

  print(response.text)


if __name__ == "__main__":
  if(len(sys.argv) > 2):
    delete_policy(sys.argv[1], sys.argv[2])
  else:
    print("usage: python delete_policy [policy file name, gns name]")