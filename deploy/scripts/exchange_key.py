import requests
import json
import sys

keyfile = open("keyfile3", "r")
key = keyfile.read()
keyfile.close()

url = "https://console.cloud.vmware.com/csp/gateway/am/api/auth/api-tokens/authorize"

payload='refresh_token=' + key.strip('\n')
headers = {
  'Content-Type': 'application/x-www-form-urlencoded',
}
print(payload)

response = requests.request("POST", url, headers=headers, data=payload)

print(response.json()['access_token'])
tokenfile = open("tokenfile", "w")
tokenfile.write(response.json()['access_token'])
tokenfile.close
