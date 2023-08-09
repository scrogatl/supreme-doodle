import requests
import sys
import json


def get_clusters():
  tokenfile = open("tokenfile", "r")
  key = tokenfile.read()
  tokenfile.close()
  url = "https://prod-4-1.nsxservicemesh.vmware.com/tsm/v1alpha1/clusters"
  payload={}
  headers = {
    'accept': 'application/json',
    'csp-auth-token': key,
    'Content-Type': 'application/json'
  }

  response = requests.request("GET", url, headers=headers, data=payload)
  print(response)
  print(json.dumps(response.json(), indent=10))


if __name__ == "__main__":
  get_clusters()
