# Test App for Various Technologies

## This repository is not officially verified, tested or supported. ##

This repo is for my testing of kubernetes platforms

In the *src* folder is the source code for a simplified app to show services connecting to one another. 

* Depends upon the "gitops-doodle-*" repos *
```
git clone https://github.com/scrogatl/gitops-doodle-loadgen.git
git clone https://github.com/scrogatl/gitops-doodle-frontend.git
git clone https://github.com/scrogatl/gitops-doodle-hello.git
git clone https://github.com/scrogatl/gitops-doodle-world.git
git clone https://github.com/scrogatl/gitops-doodle-world-ruby.git
git clone https://github.com/scrogatl/gitops-doodle-weather.git
```

* Quick way to build: Copy the docker-compose.yml from "supreme-doodle" repo" * 
```
docker compose build 
```


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
cp deploy/docker/docker-compoose.yml . 
docker compose up -d 
```

### These are examples only and are NOT intended for any serious use! ###

