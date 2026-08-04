# Test App for Various Technologies

## This repository is not officially verified, tested or supported. ##

This branch deploys `loadgen`, `frontend`, `hello`, and `world` as Azure
Function Apps instrumented with the New Relic Python agent, instead of
containers. There is no Docker Compose, Kubernetes, or Azure Container Apps
config here — see the `main` branch for those deployment paths.

### Deploy on Azure Functions (with New Relic) ###

See [azure-functions/README.md](azure-functions/README.md) for prerequisites,
the deploy script, and a local-testing script that runs all four via Azure
Functions Core Tools without touching Azure at all.

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

