import requests
import json

tokenfile = open("tokenfile", "r")
key = tokenfile.read()
tokenfile.close()

url = "https://prod-2.nsxservicemesh.vmware.com/tsm/v1alpha2/project/default/global-namespaces/rogerssc-gns-06/traffic-routing-policies/tm-policy-world-01"

payload = json.dumps({
  "description": "policy to split 50% of traffic between blue and green",
  "service": "hello",
  "traffic_policy": {
    "http": [
      {
        "targets": [
          {
            "service_version": "blue",
            "weight": 50
          },
          {
            "service_version": "green",
            "weight": 50
          }
        ]
      }
    ]
  }
})
headers = {
  'accept': 'application/json',
  'csp-auth-token': key,
  'Content-Type': 'application/json'
}

response = requests.request("PUT", url, headers=headers, data=payload)

print(response.status_code)
print(json.dumps(response.json(), indent=4))
