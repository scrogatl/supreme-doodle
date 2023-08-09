# Automate Kubernetes Platform Operations with Terraform Provider for Tanzu Mission Control 

## This repository is not officially verified, tested or supported by VMware. ##

This repo is for my testing of terraform, Tanzu Mission Control, and Tanzu Service Mesh.

In the *src* folder is the source code for a simplified app to show services connecting to one another. With Tanzu Service Mesh they can run in separate clusters and still communicate.

The *deploy* folder has my examples for using the Terraform Provider for Tanzu Mission Control,  Python scripts for using the Tanzu Service Mesh API and a workload folder with yaml that will deploy code in the *src* folder (you have to compile, push to registry, etc...).

### These are examples only and are NOT intended for any serious use! ###

----

## Open Telemetry and Wavefront

### Install opentelemetry operator

Install the operator:
```
helm repo add open-telemetry https://open-telemetry.github.io/opentelemetry-helm-charts
helm repo update
helm install opentelemetry-operator open-telemetry/opentelemetry-operator
```
----

### Add the wavefront proxy to collect the spans and send to AOA
This deploys a wavefront-proxy, Aria Operations for Apps integration, just for the acme-fitness application. The AOA integration for K8S is independent (multiple wavefront-proxy's installed is fine)
```
ytt -f wavefront.yaml -v workloadNamespace=<workloadNamespace> -v wavefrontURI=<wavefrontURI> -v wavefrontToken=<wavefrontToken> | kubectl apply -f-
```
