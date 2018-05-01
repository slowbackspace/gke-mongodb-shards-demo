hostname=getHostName();
var doc = {};
doc["host"] = hostname + "." + K8S_SERVICE_URL + ":27017";
doc["priority"] = 0;
doc["votes"] = 0; // https://docs.mongodb.com/manual/reference/method/rs.add/#behavior
rs.add(doc);
sleep(2000);
var cfg = rs.conf();
for(var i=0;i<cfg.members.length;i++){
    if (cfg.members[i].priority != 1) {
        cfg.members[i].priority = 1;
    
        // If the replica set already has 7 voting members, additional members must be non-voting members.
        if (i < 7) {
            cfg.members[i].votes = 1;
        }
        rs.reconfig(cfg);
    }
}