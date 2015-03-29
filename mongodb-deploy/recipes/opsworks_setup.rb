node.default['mongodb']['dbpath'] = "/data/db"
node.normal['mongodb']['dbpath'] = "/data/db"
include_recipe "mongodb-10gen::default"

