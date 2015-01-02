include_recipe 'deploy'

node[:deploy].each do |application, deploy|
  execute "stop supervisor" do
    command "service supervisor stop"
  end

  opsworks_deploy_dir do
    user deploy[:user]
    group deploy[:group]
    path deploy[:deploy_to]
  end

  opsworks_deploy do
    deploy_data deploy
    app application
  end

  opsworks_nodejs do
    deploy_data deploy
    app application
  end

  template 'supervisor site' do
    path ::File.join('/etc/supervisor/conf.d/', deploy[:environment][:dns_name] + '.conf')
    source 'supervisor.erb'
    owner 'root'
    group 'root'
    mode 0644
    backup false
    variables(:webapp_name => application)
  end

  execute "start supervisor" do
    command "service supervisor start"
  end

end