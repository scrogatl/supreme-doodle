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

argocd app create doodle-weather-java  --repo https://github.com/scrogatl/gitops-doodle-weather-java.git --path helm-chart --dest-namespace supreme-doodle --dest-server https://kubernetes.default.svc --helm-set replicaCount=1 --sync-policy automated --revision newrelic
```

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
The pods read the New Relic license key from a Secret named `nr-license-key` (key `license-key`):
```
kubectl create namespace supreme-doodle
kubectl -n supreme-doodle create secret generic nr-license-key --from-literal=license-key=<YOUR_LICENSE_KEY>
cd k8s
kubectl apply -f deployments/
kubectl apply -f services/
```

#### The source for these are in the ```gitops-doodle-``` repos: 

```
git clone https://github.com/scrogatl/gitops-doodle-loadgen.git
git clone https://github.com/scrogatl/gitops-doodle-frontend.git
git clone https://github.com/scrogatl/gitops-doodle-hello.git
git clone https://github.com/scrogatl/gitops-doodle-world.git
git clone https://github.com/scrogatl/gitops-doodle-world-ruby.git
git clone https://github.com/scrogatl/gitops-doodle-weather.git
git clone https://github.com/scrogatl/gitops-doodle-weather-java.git
```



### These are examples only and are NOT intended for any serious use! ###

