#!/bin/bash

function validateInput {
    count=$1
    re='^[0-9]+$'
    if ! [[ $count =~ $re ]] ; then
        echo "error: Not a number" >&2; exit 1
    fi
}

function createDisks {
    local count=$1
    for ((c=1; c<=$count; c++ ))
    do
        if ! gcloud compute disks list esdisk-$c | grep esdisk-$c; then
            gcloud compute disks create --size=100GB esdisk-$c
        fi
    done
}

validateInput $1 #sets the variable $count
createDisks $count
