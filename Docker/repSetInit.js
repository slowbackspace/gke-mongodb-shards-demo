hostname=getHostName();
isConfigSvr = (ROLE == "configdb")? true: false;

if ((rs.status()["ok"] == 0) && (rs.status()["codeName"] == "NotYetInitialized")) {
    rs.initiate({"_id": REPSET_NAME, configsvr: isConfigSvr, version: 1, members: [{_id: 0, host: hostname + "." + K8S_SERVICE_URL + ":27017"}]});
    while ((rs.status().hasOwnProperty("myState") && rs.status().myState != 1)) {
        print(".");
        sleep(1000);
    }
}