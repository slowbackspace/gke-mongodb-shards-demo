#!/bin/bash
ADMIN_USERNAME="admin"
ADMIN_PASSWORD="abc123"
SHARDS=3

# Deploy a MongoDB ConfigDB Service ("Config Server Replica Set") using a Kubernetes StatefulSet
echo "Deploying GKE StatefulSet & Service for MongoDB Config Server Replica Set"
sed -e 's/ADMIN_USERNAME_PLACEHOLDER/'$ADMIN_USERNAME'/g; s/ADMIN_PASSWORD_PLACEHOLDER/'$ADMIN_PASSWORD'/g;' ../kubernetes/mongodb-configdb-service.yaml > ../kubernetes/mongodb-configdb-service-generated.yaml
kubectl apply -f ../kubernetes/mongodb-configdb-service-generated.yaml

sleep 10

echo "Deploying GKE StatefulSet & Service for each MongoDB Shard Replica Set"

for (( i=1; i<=$SHARDS; i++ )) {
    sed -e 's/shardX/shard'$i'/g; s/ShardX/Shard'$i'/g; s/ADMIN_USERNAME_PLACEHOLDER/'$ADMIN_USERNAME'/g; s/ADMIN_PASSWORD_PLACEHOLDER/'$ADMIN_PASSWORD'/g;' ../kubernetes/mongodb-shardrs-template.yaml > "../kubernetes/mongodb-shard${i}-generated.yaml"
    kubectl apply -f "../kubernetes/mongodb-shard${i}-generated.yaml"
}
# Deploy some Mongos Routers using a Kubernetes Deployment
echo "Deploying GKE Deployment & Service for some Mongos Routers"
kubectl apply -f ../kubernetes/mongodb-mongos-deployment.yaml


# # Wait for each MongoDB Shard's Replica Set + the ConfigDB Replica Set to each have a primary ready
# echo "Waiting for all the MongoDB ConfigDB & Shards' Replica Sets to initialise..."
# kubectl exec mongod-configdb-0 -c mongod-configdb-container -- mongo --quiet --eval 'while (rs.status().hasOwnProperty("myState") && rs.status().myState != 1) { print("."); sleep(1000); };'
# kubectl exec mongod-shard1-0 -c mongod-shard1-container -- mongo --quiet --eval 'while (rs.status().hasOwnProperty("myState") && rs.status().myState != 1) { print("."); sleep(1000); };'
# kubectl exec mongod-shard2-0 -c mongod-shard2-container -- mongo --quiet --eval 'while (rs.status().hasOwnProperty("myState") && rs.status().myState != 1) { print("."); sleep(1000); };'
# kubectl exec mongod-shard3-0 -c mongod-shard3-container -- mongo --quiet --eval 'while (rs.status().hasOwnProperty("myState") && rs.status().myState != 1) { print("."); sleep(1000); };'
# sleep 2 # Just a little more sleep to ensure everything is ready!
# echo "...initialisation of the MongoDB Replica Sets completed"
# echo

# # Wait for the mongos to have started properly
# echo "Waiting for the first mongos to come up (`date`)..."
# echo " (IGNORE any reported not found & connection errors)"
# echo -n "  "
# until kubectl --v=0 exec $(kubectl get pod -l "tier=routers" -o jsonpath='{.items[0].metadata.name}') -c mongos-container -- mongo --quiet --eval 'db.getMongo()'; do
#     sleep 2
#     echo -n "  "
# done
# echo "...first mongos is now running (`date`)"
# echo

# # Add Shards to the Configdb
# echo "Configuring ConfigDB to be aware of the 3 Shards"
# for (( i=1; i<=$SHARDS; i++ )) {
#     kubectl exec $(kubectl get pod -l "tier=routers" -o jsonpath='{.items[0].metadata.name}') -c mongos-container -- mongo admin -u ${ADMIN_USERNAME} -p ${ADMIN_PASSWORD} --eval "sh.addShard('Shard${i}RepSet/mongod-shard${i}-0.mongodb-shard${i}-service.default.svc.cluster.local:27017');"

# }
