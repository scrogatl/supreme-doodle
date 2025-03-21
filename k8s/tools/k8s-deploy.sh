#  envsubst < supreme-doodle/k8s/20-hello.yaml |  kubectl apply -f -
 for f in supreme-doodle/k8s/*; do
    if [ -f "$f" ]; then
        echo $f  
        envsubst < $f | kubectl apply -f -
    fi
done

