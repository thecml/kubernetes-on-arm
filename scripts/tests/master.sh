#!/bin/bash

kube-config info

TMPFILE=$(mktemp /tmp/k8s-up.XXXXXXX)
{ time kube-config enable-master }; 2>&1 > $TMPFILE > /dev/stdout 

SECS=0
while [[ -z $(docker ps | grep "apiserver") ]]; do sleep 1; ((SECS++)); done

echo "Time before apiserver came up: $SECS"

docker ps

kube-config info

time kubectl run my-nginx --image=luxas/nginx-test --replicas=3

SECS=0
while [[ $(kubectl get po | grep "my-nginx" | awk '{print $3}' | head -1) != "Running" ]]; do sleep 1; ((SECS++)); done

echo "Time before nginx came up: $SECS"

time kubectl expose rc/my-nginx --port=80

sleep 2

SVCIP=$(kubectl get svc | grep my-nginx | awk '{print $4}')

if [[ $(curl -sSL $SVCIP) == "<p>WELCOME TO NGINX</p>" ]]; then
	echo "nginx service test passed"
	curl $SVCIP
fi

time kube-config enable-addon dns

SECS=0
while [[ $(kubectl --namespace=kube-system get po | grep "kube-dns" | awk '{print $3}' | head -1) != "Running" ]]; do sleep 1; ((SECS++)); done
echo "Time before dns came up: $SECS"

#time kube-config enable-addon registry

#SECS=0
#while [[ $(kubectl --namespace=kube-system get po | grep "kube-dns" | awk '{print $3}' | head -1) != "Running" ]]; do sleep 1; ((SECS++)); done
#echo "Seconds to come up for dns: $SECS_TO_COME_UP"