
    execute "python-software-properties" do
      command "apt-get install -y python-software-properties"
      action :run
    end

    execute "add nginx repo" do
      command "add-apt-repository ppa:nginx/stable"
      action :run
    end

    execute "update apt" do
      command "sudo apt-get update"
      action :run
    end

    execute "install nginx" do
      command "sudo apt-get -y install nginx"
      action :run
    end

    execute "install repo" do
      ignore_failure true
      command "add-apt-repository ppa:ondrej/php5-oldstable"
      action :run
    end

    execute "install aptupdate" do
      ignore_failure true
      command "apt-get update -y"
      action :run
    end

    execute "install php" do
      ignore_failure true
      command "apt-get install -y php5-fpm php5-cli php5-cgi php5-memcached php-apc php5-curl"
      action :run
    end

    template 'default' do
      path '/etc/nginx/sites-available/default'
      source 'default.conf.erb'
      owner 'root'
      group 'root'
      mode 0644
      backup false
    end

    execute "restart fpm" do
      ignore_failure true
      command "service php5-fpm restart"
      action :run
    end

    execute "restart nginx" do
      ignore_failure true
      command "service nginx restart"
      action :run
    end

directory '/mnt/ephemeral' do
  user "www-data"
  group "www-data"
end