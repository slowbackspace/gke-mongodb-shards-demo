#!/bin/bash
numactl --interleave=all mongod --wiredTigerCacheSizeGB 0.25 --bind_ip 0.0.0.0 --replSet ${REPSET_NAME} --auth --clusterAuthMode keyFile --keyFile /etc/secrets-volume/internal-auth-mongodb-keyfile --setParameter authenticationMechanisms=SCRAM-SHA-1
  