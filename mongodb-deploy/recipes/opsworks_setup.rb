node.normal[:mongod][:config][:bind_ip] = "0.0.0.0"
node.normal[:mongod][:config][:dbpath] = "/data/db"
include_recipe "mongodb-10gen::default"

