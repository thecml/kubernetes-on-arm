#!/bin/bash

########## GLOBALS ###########

OUTPUT_DETAILS=${OUTPUT_DETAILS:-1}



########## COLORS ############


declare -r RED="\033[0;31m"
declare -r GREEN="\033[0;32m"
declare -r YELLOW="\033[0;33m"

function echo_green {
  echo -e "${GREEN}$1"; tput sgr0
}

function echo_red {
  echo -e "${RED}$1"; tput sgr0
}

function echo_yellow {
  echo -e "${YELLOW}$1"; tput sgr0
}

# Example: updateline path_to_file value_to_search_for replace_that_line_with_this_content
# 
updateline(){
if [[ -z $(cat $1 | grep "$2") ]]; then
	echo -e "\n$3" >> $1
else
	sed -i "/$2/c\\$3" $1
fi
}


if [[ ! -f $(which kubectl 2>&1) ]]; then
	echo_red "kubectl not in PATH"
	echo_red "Failing"
	exit
fi

kube-config info

# Change dns settings before starting kubelet
updateline /etc/kubernetes/k8s.conf "DNS_DOMAIN" "DNS_DOMAIN=kubernetesonarm.com"
updateline /etc/kubernetes/k8s.conf "DNS_IP" "DNS_IP=10.0.0.110"

# Start Kubernetes
time kube-config enable-master

APISERVER_SECS=0
while [[ $(curl -m 1 -sSILk https://10.0.0.1 | head -1 2>&1) != *"OK"* ]]; do sleep 1; ((APISERVER_SECS++)); done
#while [[ -z $(docker ps | grep "apiserver") ]]; do sleep 1; ((SECS++)); done

echo_yellow "Seconds before apiserver came up: $APISERVER_SECS"

docker ps

kube-config info

kubectl run my-nginx --image=luxas/nginx-test --replicas=3

NGINX_SECS=0
while [[ $(kubectl get po | grep "my-nginx" | awk '{print $3}' | head -1) != "Running" ]]; do sleep 1; ((NGINX_SECS++)); done

echo_yellow "Seconds before nginx came up: $NGINX_SECS"

kubectl expose rc/my-nginx --port=80

sleep 2

SVCIP=$(kubectl get svc | grep my-nginx | awk '{print $2}')
SERVICE_WORKING=0

if [[ $(curl -sSL $SVCIP) == "<p>WELCOME TO NGINX</p>" ]]; then
	echo_green "nginx service test passed"
	SERVICE_WORKING=1
	curl -sSL $SVCIP
fi

kube-config enable-addon sleep

SLEEP_SECS=0
while [[ $(kubectl get po | grep "sleep" | awk '{print $3}' | head -1) != "Running" ]]; do sleep 1; ((SLEEP_SECS++)); done
echo_yellow "Seconds before the sleep addon came up: $SLEEP_SECS"

sleep 5

kube-config enable-addon dns

DNS_SECS=0
while [[ $(kubectl --namespace=kube-system get po | grep "kube-dns" | awk '{print $3}' | head -1) != "Running" ]]; do sleep 1; ((DNS_SECS++)); done
echo_yellow "Seconds before dns came up: $DNS_SECS"

sleep 15
DNS_HOST_WORKING=0
DNS_HOST_SEARCH_WORKING=0
DNS_POD_WORKING=0
APISERVER_PROXY=0

if [[ $(curl -sSL my-nginx.default.svc.kubernetesonarm.com) == "<p>WELCOME TO NGINX</p>" ]]; then
	echo_green "dns on host test passed"
	DNS_HOST_WORKING=1
	curl -sSL my-nginx.default.svc.kubernetesonarm.com
fi

if [[ $(curl -sSL my-nginx) == "<p>WELCOME TO NGINX</p>" ]]; then
	echo_green "dns shorthand names on host test passed"
	DNS_HOST_SEARCH_WORKING=1
	curl -sSL my-nginx
fi

# TODO: flaky
POD_RESPONSE=$(kubectl exec -it alpine-sleep -- curl -sSL my-nginx.default.svc.kubernetesonarm.com)

if [[ $POD_RESPONSE == "<p>WELCOME TO NGINX</p>" ]]; then
	echo_green "nginx dns in a pod test passed"
	DNS_POD_WORKING=1
fi

if [[ $(curl -sSLk https://10.0.0.1/api/v1/proxy/namespaces/default/services/my-nginx) == "<p>WELCOME TO NGINX</p>" ]]; then
	echo_green "nginx master proxy test passed"
	curl -sSLk https://10.0.0.1/api/v1/proxy/namespaces/default/services/my-nginx
	APISERVER_PROXY=1
fi

kube-config enable-addon registry

REGISTRY_SECS=0
while [[ $(kubectl --namespace=kube-system get po | grep "registry" | awk '{print $3}' | head -1) != "Running" ]]; do sleep 1; ((REGISTRY_SECS++)); done
echo_yellow "Seconds before registry came up: $REGISTRY_SECS"

sleep 8
REGISTRY_UP=0

if [[ $(curl -sSLI 10.0.0.20:5000 | head -1) == *"OK"* ]]; then
	REGISTRY_UP=1
	echo_green "registry is up"
fi

docker tag -f luxas/nginx-test 10.0.0.20:5000/nginx-two
time docker push 10.0.0.20:5000/nginx-two

ls -la /var/lib/registry 
echo_yellow "Size of the registry dir after push: $(du -sh /var/lib/registry | awk '{print $1}')"

echo_yellow "one token: "
cat $(mount | grep /var/lib/kubelet | awk '{print $3}' | head -1)/token
echo
echo_yellow "one ca.crt"
cat $(mount | grep /var/lib/kubelet | awk '{print $3}' | head -1)/ca.crt
echo


if [[ $OUTPUT_DETAILS == 1 ]]; then

	kubectl get rc,po,svc,ep,secrets,serviceaccounts,ev,hpa,ds --all-namespaces
	kubectl get no,ns,cs
	docker images
	docker ps
fi


echo_yellow "Summary:"
echo
echo "Seconds before apiserver came up: $APISERVER_SECS"
echo "Seconds before nginx came up: $NGINX_SECS"
echo "Seconds before dns came up: $DNS_SECS"
echo "Seconds before registry came up: $REGISTRY_SECS"
echo 
if [[ $SERVICE_WORKING == 1 ]]; then
	echo_green "Services in Kubernetes are working"
else
	echo_red "Services in Kubernetes aren't working"
fi
if [[ $DNS_HOST_WORKING == 1 ]]; then
	echo_green "DNS on host is working"
else
	echo_red "DNS on host isn't working"
fi
if [[ $DNS_HOST_SEARCH_WORKING == 1 ]]; then
	echo_green "DNS on host with shorthand search commands is working"
else
	echo_red "DNS on host with shorthand search commands isn't working"
fi
if [[ $DNS_POD_WORKING == 1 ]]; then
	echo_green "DNS in pods host is working"
else
	echo_red "DNS in pods isn't working"
fi
if [[ $APISERVER_PROXY == 1 ]]; then
	echo_green "The apiserver proxy is working"
else
	echo_red "The apiserver proxy isn't working"
fi
if [[ $SERVICE_WORKING == 1 ]]; then
	echo_green "The registry is up and running"
else
	echo_red "The registry isn't up"
fi