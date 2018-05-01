#!/bin/bash

kubectl delete svc -l name=mongod-shard1
kubectl delete svc -l name=mongod-shard2
kubectl delete svc -l name=mongod-shard3
kubectl delete svc -l name=mongo-configdb

kubectl delete statefulsets mongod-shard1 
kubectl delete statefulsets mongod-shard2 
kubectl delete statefulsets mongod-shard3

kubectl delete statefulsets mongod-configdb

kubectl delete pvc -l name=mongod-shard1
kubectl delete pvc -l name=mongod-shard2
kubectl delete pvc -l name=mongod-shard3

kubectl delete pvc -l name=mongod-configdb
kubectl delete deployment mongos
