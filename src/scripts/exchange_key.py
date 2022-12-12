import requests
import json
import sys

keyfile = open("keyfile", "r")
key = keyfile.read()
keyfile.close()

url = "https://console.cloud.vmware.com/csp/gateway/am/api/auth/api-tokens/authorize"

payload='refresh_token=' + key.strip('\n')
headers = {
  'Content-Type': 'application/x-www-form-urlencoded',
  'Cookie': 'incap_ses_1552_1285675=IcezbZRW1WN2d+xTAdCJFXE/l2MAAAAAGbA9rx6ekVTzrUjpr1O1yw==; nlbi_1285675=FxtgRdSHNzJO9PYFuir6ugAAAABegjeMu2lLZF7Gw+nmoI9+'
}
print(payload)

response = requests.request("POST", url, headers=headers, data=payload)

print(response.json()['access_token'])
tokenfile = open("tokenfile", "w")
tokenfile.write(response.json()['access_token'])
tokenfile.close