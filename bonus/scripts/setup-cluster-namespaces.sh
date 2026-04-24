#!/bin/sh

k3d cluster create bonuscluster -p "8080:80@loadbalancer" -p "8888:8888@loadbalancer"

kubectl create namespace argocd
kubectl create namespace dev
kubectl apply -n argocd -f https://raw.githubusercontent.com/argoproj/argo-cd/stable/manifests/install.yaml

kubectl create namespace gitlab
