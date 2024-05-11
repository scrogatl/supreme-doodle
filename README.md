# Automate Kubernetes Platform Operations ]

## This repository is not officially verified, tested or supported. ##

This repo is for my testing of kubernetes platforms

In the *src* folder is the source code for a simplified app to show services connecting to one another. 

### These are examples only and are NOT intended for any serious use! ###

----

## TO BE DELETED
### Add the wavefront proxy to collect the spans and send to AOA
This deploys a wavefront-proxy, Aria Operations for Apps integration, just for the acme-fitness application. The AOA integration for K8S is independent (multiple wavefront-proxy's installed is fine)
```
ytt -f wavefront.yaml -v workloadNamespace=<workloadNamespace> -v wavefrontURI=<wavefrontURI> -v wavefrontToken=<wavefrontToken> | kubectl apply -f-
```
