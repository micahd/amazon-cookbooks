directory '/mnt/code' do
  user "ubuntu"
  group "ubuntu"
end
directory '/mnt/ephemeral' do
  user "ubuntu"
  group "ubuntu"
  mode "0777"
end
directory '/mnt/ephemeral/scripts' do
  user "ubuntu"
  group "ubuntu"
  mode "0777"
end
directory '/mnt/ephemeral/apns_cert' do
  user "tomcat7"
  group "tomcat7"
  mode "0777"
end
directory '/var/log/batchPush' do
  user "ubuntu"
  group "ubuntu"
  mode "0777"
end
template 'restart_tomcat_script' do
  path '/mnt/ephemeral/scripts/restart_tomcat.sh'
  source 'restart_tomcat.sh.erb'
  owner 'ubuntu'
  group 'ubuntu'
  mode 0777
  backup false
end
cron "restart_tomcat" do
  action :create
  minute "5"
  command "/mnt/ephemeral/scripts/restart_tomcat.sh"
end
template 'apns_cert' do
  path '/mnt/ephemeral/apns_cert/aps_production_key_export.p12'
  source 'aps_production_key_export.p12.erb'
  owner 'tomcat7'
  group 'tomcat7'
  mode 0600
  backup false
end