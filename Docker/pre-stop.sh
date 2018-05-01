#!/bin/bash
. /helpers/functions.sh
mongo admin --host $(buildURI) -u ${ADMIN_USERNAME} -p ${ADMIN_PASSWORD} --eval "rs.remove(getHostName() + '.${K8S_SERVICE_URL}:27017')"


hosts_count=(getent hosts $K8S_SERVICE_URL| wc -l)
if [[ "$ROLE" == "shard" ]]; then
    if [[ "$hosts_count" -eq 1 ]]; then
        echo "last node"
        mongo admin --host ${K8S_MONGOS_SERVICE_URL} -u ${ADMIN_USERNAME} -p ${ADMIN_PASSWORD} --eval "db.adminCommand( { removeShard: '${REPSET_NAME}' })"
        mongo admin --host ${K8S_MONGOS_SERVICE_URL} -u ${ADMIN_USERNAME} -p ${ADMIN_PASSWORD} --eval "while (db.adminCommand( { removeShard: '${REPSET_NAME}' }).state == 'ongoing') { sleep(1000);print('still removing shard') }"

    fi
fi