import requests
import sys
import json


def delete_cluster(cluster_id):
  tokenfile = open("tokenfile", "r")
  key = tokenfile.read()
  tokenfile.close()
  url = "https://prod-2.nsxservicemesh.vmware.com/tsm/v1alpha1/clusters/" + cluster_id 
  payload={}

  headers = {
    'accept': 'application/json',
    'csp-auth-token': key,
    'Content-Type': 'application/json'
  }

  response = requests.request("DELETE", url, headers=headers, data=payload)
  print(response)
  print(json.dumps(response.json(), indent=10))

if __name__ == "__main__":
  if(len(sys.argv) > 1):
    delete_cluster(sys.argv[1])
  else:
    print("usage: python cluster_remove.py [cluster ID]")

