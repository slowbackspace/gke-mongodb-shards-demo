#!/bin/bash

function buildURI() {
    # builds connection URI in the format repsetname/host0-serviceURL:27017,host1-serviceURL::27017...
    index=$(hostname | rev | cut -d- -f1 | rev)
    base_hostname=$(hostname | rev | cut -d- -f2- | rev)

    connectionUri="${REPSET_NAME}/"
    for (( i=0; i<$index; i++ )) {
    connectionUri="${connectionUri}${base_hostname}-${i}.${K8S_SERVICE_URL}:27017,"
    }
    if [[ "$index" -eq 0 ]]; then
        connectionUri="${connectionUri}${base_hostname}-0.${K8S_SERVICE_URL}:27017,"
    fi

    connectionUri=${connectionUri::-1} # delete last comma
    echo "$connectionUri"
}

echo "var K8S_SERVICE_URL=\"${K8S_SERVICE_URL}\";" > /set_vars.js
echo "var REPSET_NAME=\"${REPSET_NAME}\";" >> /set_vars.js
echo "var ROLE=\"${ROLE}\";" >> /set_vars.js