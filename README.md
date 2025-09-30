# Test App for Various Technologies

## This repository is not officially verified, tested or supported. ##

This repo is for my testing of kubernetes platforms


### Deploy on K8S with Argo ###
```
argocd app create doodle-loadgen --repo https://github.com/scrogatl/gitops-doodle-loadgen.git --path . --dest-namespace supreme-doodle --dest-server https://kubernetes.default.svc 

argocd app create doodle-hello --repo https://github.com/scrogatl/gitops-doodle-hello.git --path helm-chart --dest-namespace supreme-doodle --dest-server https://kubernetes.default.svc --helm-set replicaCount=1 --sync-policy automated --revision main

argocd app create doodle-frontend --repo https://github.com/scrogatl/gitops-doodle-frontend.git --path helm-chart --dest-namespace supreme-doodle --dest-server https://kubernetes.default.svc --helm-set replicaCount=1  --sync-policy automated --revision main

argocd app create doodle-world-ruby --repo https://github.com/scrogatl/gitops-doodle-world-ruby.git --path helm-chart --dest-namespace supreme-doodle --dest-server https://kubernetes.default.svc --helm-set replicaCount=1 --sync-policy automated --revision main

argocd app create doodle-world  --repo https://github.com/scrogatl/gitops-doodle-world.git --path helm-chart --dest-namespace supreme-doodle --dest-server https://kubernetes.default.svc --helm-set replicaCount=1 --sync-policy automated --revision main
```

### Deploy on local Docker  ###
```
cd docker
docker compose up -d 
```

### Deploy on K8S
```
cd k8s
kubectl apply -f deployments/
kubectl apply -f services/

```


### Change the label: "app.kubernetes.io/name:"


Changes/appends '3040' to the label (for reporting into New Relic):

```
for FILE in deployments/*; do sed -r 's/(.*app.kubernetes.io\/name: doodle-.*)/\1-3040 /'  $FILE | k apply  -f -; done

for FILE in services/*; do sed -r 's/(.*app.kubernetes.io\/name: doodle-.*)/\1-3040 /'  $FILE | k apply  -f -; done

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

