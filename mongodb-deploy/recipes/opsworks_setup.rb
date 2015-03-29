node.normal['mongodb']['data_dir'] = '/data/mongodb/db'
node.normal['mongodb']['log_dir'] = '/data/mongodb/log'
include_recipe "mongodb-10gen::default"

