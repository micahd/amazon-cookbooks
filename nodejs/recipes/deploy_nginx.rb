include_recipe 'deploy'

node[:deploy].each do |application, deploy|
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

  template 'nginx site' do
    path ::File.join('/etc/nginx/sites-enabled/', deploy[:environment][:dns_name])
    source 'site.erb'
    owner 'root'
    group 'root'
    mode 0644
    backup false
    variables(:webapp_name => application)
  end
end