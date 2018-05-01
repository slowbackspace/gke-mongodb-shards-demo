#!/bin/bash
. /helpers/functions.sh
sleep 12
index=$(hostname | rev | cut -d- -f1 | rev) # ex. 0
base_hostname=$(hostname | rev | cut -d- -f2- | rev) # ex. mongod
if [[ "$index" == "0" ]]; then
    # first node (master)
    # initialize replica set
    mongo admin /set_vars.js /helpers/repSetInit.js
    # create user admin
    
    if [[ ! -z "$ADMIN_USERNAME" && ! -z "$ADMIN_PASSWORD" ]]; then
        # If the node is not a master it is probably because of pods update (in reverse order) due to changes in stateful's spec
        # In this case replication (including creation of the admin) was already set up before and running it again would fail because of missing auth params 
        sleep 10
        notAuth=$(mongo admin --eval "db.getUsers()" | grep "not auth") # not authorized error, admin user probably already exists
        if [[ -z "$notAuth" ]] ; then
            mongo admin --eval "db.isMaster(); if (db.isMaster().ismaster == true) {db.createUser({user: '${ADMIN_USERNAME}', pwd: '${ADMIN_PASSWORD}', roles: [ { role: 'root', db: 'admin' } ]}) };"
        fi
    fi
else
    # secondary nodes
    if [[ ! -z "$ADMIN_USERNAME" && ! -z "$ADMIN_PASSWORD" ]]; then
        mongo admin -u "$ADMIN_USERNAME" -p "$ADMIN_PASSWORD" --host $(buildURI) /set_vars.js /helpers/repSetAdd.js
    else
        mongo admin --host $(buildURI) /set_vars.js /helpers/repSetAdd.js
    fi

    if [[ "$ROLE" == "shard" ]]; then
        # add shard through mongos
        mongo config --authenticationDatabase admin --host ${K8S_MONGOS_SERVICE_URL} -u ${ADMIN_USERNAME} -p ${ADMIN_PASSWORD} --eval "a=db.shards.find({'_id': '${REPSET_NAME}'}).size(); if (a == 0) { sh.addShard('${REPSET_NAME}/${base_hostname}-0.${K8S_SERVICE_URL}:27017');}"
    fi
fi