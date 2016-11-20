#!/bin/bash

kubectl delete service frontend-es
kubectl delete service es
kubectl delete deployment frontend-es
kubectl delete deployment es-1
kubectl delete deployment es-2
kubectl delete deployment es-3
kubectl delete configmap nginx-es-frontend-conf

