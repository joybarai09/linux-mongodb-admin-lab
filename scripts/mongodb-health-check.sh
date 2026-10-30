
#!/usr/bin/env bash
set -Eeuo pipefail

if ! command -v mongosh >/dev/null 2>&1; then
    echo "ERROR: mongosh is not installed."
    exit 1
fi

if [[ -z "${MONGODB_URI:-}" ]]; then
    echo "ERROR: Set MONGODB_URI first."
    exit 1
fi

echo "=================================="
echo " MongoDB Database Health Check"
echo "=================================="

mongosh "$MONGODB_URI" --quiet --eval '

const admin = db.getSiblingDB("admin");

print("\n1. MongoDB Connectivity");

const ping = admin.runCommand({ping: 1});
printjson(ping);

if (ping.ok !== 1) {
    print("MongoDB connection failed.");
    quit(1);
}

print("\n2. MongoDB Server Information");

const status = admin.runCommand({serverStatus: 1});

if (status.ok === 1) {
    printjson({
        version: status.version,
        uptime: status.uptime,
        connections: status.connections,
        opcounters: status.opcounters
    });
} else {
    print("Server status unavailable: " +
          (status.errmsg || status.codeName || "permission denied"));
}

print("\n3. Database Inventory");

const databases = admin.runCommand({
    listDatabases: 1,
    nameOnly: true
});

if (databases.ok === 1) {
    printjson(databases.databases);
} else {
    print("Database inventory unavailable.");
}

print("\n4. Replica Set Status");

const replica = admin.runCommand({
    replSetGetStatus: 1
});

if (replica.ok === 1) {
    replica.members.forEach(member => {
        printjson({
            name: member.name,
            state: member.stateStr,
            health: member.health
        });
    });
} else {
    print("Replica set unavailable or not configured.");
}

print("\nMongoDB health check completed.");
'
