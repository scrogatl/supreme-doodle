#! /bin/bash

while IFS= read -r line; do
    kubectx ${line} 
    kubectl-122 delete ns tko-demo
done < clusters.txt