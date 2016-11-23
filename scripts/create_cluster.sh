#!/bin/bash

function init {
    rm -rf .tmp
    mkdir -p .tmp
}

function validateInput {
    count=$1
    re='^[0-9]+$'
    if ! [[ $count =~ $re ]] ; then
        echo "error: Not a number" >&2; exit 1
    fi
}

function createSpecs {
    local count=$1
    for ((c=1; c<=$count; c++ ))
    do
        cat ../templates/es_deployment_template.yaml | sed -e "s/\${nodenumber}/$c/" | sed -e "s/\${nodecount}/$count/" > .tmp/es_deployment_$c.yaml
    done
}

function createDeployments {
    local count=$1
    for ((c=1; c<=$count; c++ ))
    do
        kubectl apply -f .tmp/es_deployment_$c.yaml
    done
}

function createEsService {
    kubectl create -f ../services/eventstore.yaml
}

function addNginxConfig {
    kubectl create configmap nginx-es-frontend-conf --from-file=../nginx/frontend.conf
}

function createFrontendDeployment {
    kubectl create -f ../deployments/frontend-es.yaml
}

function createFrontendService {
    kubectl create -f ../services/frontend-es.yaml
}

function createDisks {
    local count=$1
    for ((c=1; c<=$count; c++ ))
    do
        if gcloud compute disks list esdisk-$c | grep esdisk-$c; then
            echo "creating disk: esdisk-$c" 
            gcloud compute disks create --size=10GB esdisk-$c
        else
            echo "disk already exists: esdisk-$c"
        fi
    done
}

function createEsCluster {
    local count=$1
    createSpecs $count
    createDeployments $count
    createEsService
}

function createFrontEnd {
    addNginxConfig
    createFrontendDeployment
    createFrontendService
}

init
validateInput $1 #sets the variable $count
createDisks $count
createEsCluster $count
createFrontEnd