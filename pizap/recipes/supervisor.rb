template 'super_setup' do
  path '/etc/supervisor/conf.d/pizap.conf'
  source 'supervisor.erb'
  owner 'root'
  group 'root'
  mode 0644
  backup false
end