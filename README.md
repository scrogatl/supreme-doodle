# Test App for Various Technologies

## This repository is not officially verified, tested or supported. ##

This repo is for my testing of kubernetes platforms


## The Otel Branch
This branch has OTEL specific configs for Docker and K8S. The OTEL configs are generic and only point to New Relic's NRDOT collector. Change the endpoint and this config will work with other OTEL products.

The "your-custom-values.yaml" is configured to work with New Relic's Otel Distribution (nrdot).  

### Deploy on local Docker  ###
```
cd docker
docker compose up -d 
```

**For local build** 

Place docker-compose.yml in parent directory (above) the source repos and run
```
docker compose build 
```

### Deploy on K8S
```
cd k8s
kubectl apply -f deployments/
kubectl apply -f services/

```

### Deploy on Azure Container apps with New Relic agent

```
cd azure-container-apps
export NEW_RELIC_LICENSE_KEY=YOUR NEW RELIC LICENSE KEY
az group create --name supreme-doodle  --location eastus2 
az containerapp compose create -g supreme-doodle --environment supreme-doodle 
```
### Deploy on K8S with Argo ###
```
argocd app create doodle-loadgen --repo https://github.com/scrogatl/gitops-doodle-loadgen.git --path . --dest-namespace supreme-doodle --dest-server https://kubernetes.default.svc 

argocd app create doodle-hello --repo https://github.com/scrogatl/gitops-doodle-hello.git --path helm-chart --dest-namespace supreme-doodle --dest-server https://kubernetes.default.svc --helm-set replicaCount=1 --sync-policy automated --revision main

argocd app create doodle-frontend --repo https://github.com/scrogatl/gitops-doodle-frontend.git --path helm-chart --dest-namespace supreme-doodle --dest-server https://kubernetes.default.svc --helm-set replicaCount=1  --sync-policy automated --revision main

argocd app create doodle-world-ruby --repo https://github.com/scrogatl/gitops-doodle-world-ruby.git --path helm-chart --dest-namespace supreme-doodle --dest-server https://kubernetes.default.svc --helm-set replicaCount=1 --sync-policy automated --revision main

argocd app create doodle-world  --repo https://github.com/scrogatl/gitops-doodle-world.git --path helm-chart --dest-namespace supreme-doodle --dest-server https://kubernetes.default.svc --helm-set replicaCount=1 --sync-policy automated --revision main
```

### Change the label: "app.kubernetes.io/name:"


Changes/appends '3040' to the label (for reporting into New Relic):

```
for FILE in deployments/*; do sed -r 's/(.*app.kubernetes.io\/name: doodle-.*)/\1-3040 /'  $FILE | k apply  -f -; done

for FILE in services/*; do sed -r 's/(.*app.kubernetes.io\/name: doodle-.*)/\1-3040 /'  $FILE | k apply  -f -; done

```
### Missing CPU/Memory on the New Relic Kubernetes Clusters page (bare-metal/microk8s)

The OTel collector's `kubeletstats` receiver scrapes each node by hostname over
`:10250`. On bare-metal/microk8s clusters, cluster DNS (CoreDNS) typically has
no record for node hostnames, so every scrape fails and node CPU/Memory never
reaches New Relic. Check for this with:

```
kubectl logs -n newrelic -l app.kubernetes.io/component=daemonset | grep kubelet_stats
```

If you see `dial tcp: lookup <node> ... no such host`, apply the static DNS
entry (edit the IP/hostname in the file first if they differ, and add one line
per node for multi-node clusters):

```
kubectl apply -f k8s/coredns-node-hosts.yaml
```

CoreDNS reloads this live — no pod restarts needed.

### For the otel branch, create a secret with your New Relic ingest key like so:

```
kubectl create secret generic nr-license-key --from-literal=license-key=12345xyz
```


### doodle-world now has Prometheus metrics counter for requests

Must add annotation to have New Relic scrape prometheus metrics like so

``` 
POD=`k get pods -n supreme-doodle | grep -i world | grep -v  ruby | grep Running | awk '{print $1}' `; k annotate pods $POD -n supreme-doodle   newrelic.io/scrape="true" ```
```

#### The source for these are in the ```gitops-doodle-``` repos: 

```
git clone https://github.com/scrogatl/gitops-doodle-loadgen.git
git clone https://github.com/scrogatl/gitops-doodle-frontend.git
git clone https://github.com/scrogatl/gitops-doodle-hello.git
git clone https://github.com/scrogatl/gitops-doodle-world.git
git clone https://github.com/scrogatl/gitops-doodle-world-ruby.git
git clone https://github.com/scrogatl/gitops-doodle-weather.git
```



### These are examples only and are NOT intended for any serious use! ###

