#! /bin/bash

while IFS= read -r line; do
     echo "tanzu mission-control cluster  kubeconfig get ${line} -m w4-hs3-nimbus-tanzutmm -p w4-hs3-nimbus-tanzutmm > ${line}.yaml"
           tanzu mission-control cluster  kubeconfig get ${line} -m w4-hs3-nimbus-tanzutmm -p w4-hs3-nimbus-tanzutmm > ${line}.yaml
done < clusters.txt 



### older code

     # tmc cluster auth kubeconfig get ${line} -m w4-hs3-nimbus-tanzutmm -p w4-hs3-nimbus-tanzutmm > ${line}.yaml
     # tmc cluster namespace create -c  ${line} -m w4-hs3-nimbus-tanzutmm -p w4-hs3-nimbus-tanzutmm   -k rogerssc-wsp-01 -n tko-demo
     # tanzu mission-control cluster namespace create tko-demo --cluster-name  ${line} -m w4-hs3-nimbus-tanzutmm -p w4-hs3-nimbus-tanzutmm 

