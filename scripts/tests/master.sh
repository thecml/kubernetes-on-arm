#!/bin/bash
# TODO: make this test reliable

if [[ ! -f $(which kubectl) ]]; then
	echo "kubectl not in PATH"
	echo "Failing"
	exit
fi

kube-config info

time kube-config enable-master

SECS=0
while [[ $(curl -m 1 -sSIk https://10.0.0.1 | head -1 2>&1) != *"OK"* ]]; do sleep 1; ((SECS++)); done
#while [[ -z $(docker ps | grep "apiserver") ]]; do sleep 1; ((SECS++)); done

echo "Time before apiserver came up: $SECS"

docker ps

kube-config info

kubectl run my-nginx --image=luxas/nginx-test --replicas=3

SECS=0
while [[ $(kubectl get po | grep "my-nginx" | awk '{print $3}' | head -1) != "Running" ]]; do sleep 1; ((SECS++)); done

echo "Time before nginx came up: $SECS"

kubectl expose rc/my-nginx --port=80

sleep 2

SVCIP=$(kubectl get svc | grep my-nginx | awk '{print $2}')

if [[ $(curl -sSL $SVCIP) == "<p>WELCOME TO NGINX</p>" ]]; then
	echo "nginx service test passed"
	curl -sSL $SVCIP
fi

kube-config enable-addon dns

SECS=0
while [[ $(kubectl --namespace=kube-system get po | grep "kube-dns" | awk '{print $3}' | head -1) != "Running" ]]; do sleep 1; ((SECS++)); done
echo "Time before dns came up: $SECS"

sleep 5

if [[ $(curl -sSL my-nginx) == "<p>WELCOME TO NGINX</p>" ]]; then
	echo "nginx dns service test passed"
	curl -sSL my-nginx
fi

if [[ $(curl -sSLk https://kubernetes/api/v1/proxy/namespaces/default/services/my-nginx) == "<p>WELCOME TO NGINX</p>" ]]; then
	echo "nginx master proxy test passed"
	curl -sSLk https://kubernetes/api/v1/proxy/namespaces/default/services/my-nginx
fi


kube-config enable-addon registry

SECS=0
while [[ $(kubectl --namespace=kube-system get po | grep "registry" | awk '{print $3}' | head -1) != "Running" ]]; do sleep 1; ((SECS++)); done
echo "Seconds to come up for registry: $SECS"

SVCIP=$(kubectl get svc --all-namespaces | grep registry | awk '{print $3}')

if [[ $(curl -sSLI $SVCIP:5000 | head -1) == *"OK"* ]]; then
	echo "registry is up"
fi

docker tag luxas/nginx-test registry.kube-system:5000/nginx-pro
docker push registry.kube-system:5000/nginx-pro

ls -la /var/lib/registry 
du -sh /var/lib/registry

echo "one token: "
cat $(mount | grep /var/lib/kubelet | awk '{print $3}' | head -1)/token
echo
echo "one ca.crt"
cat $(mount | grep /var/lib/kubelet | awk '{print $3}' | head -1)/ca.crt
echo