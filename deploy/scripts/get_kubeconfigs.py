import requests
import json
import base64

tokenfile = open("tokenfile", "r")
key = tokenfile.read()
tokenfile.close()

clusterName = "tko-terraform-tsm-06"
managementClusterName = "w4-hs3-nimbus-tanzutmm"
provisionerName = "w4-hs3-nimbus-tanzutmm"
orgId = "df467a16-b93a-4360-be75-ffe53d400e41"


url = "https://tanzutmm.tmc.cloud.vmware.com/v1alpha1/clusters/" + clusterName + "/kubeconfig"
url = url + "?orgId=" + orgId 
url = url + "&fullName.managementClusterName=" + managementClusterName
url = url + "&fullName.provisionerName=" + provisionerName

payload={}
headers = {
  'accept': '*/*',
  'authorization': "Bearer " + key
}

response = requests.request("GET", url, headers=headers, data=payload)
kubeconfig = response.json()["kubeconfig"]


print( base64.b64decode(kubeconfig).decode('utf-8') )
