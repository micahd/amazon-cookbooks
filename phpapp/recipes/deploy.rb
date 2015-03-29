node[:deploy].each do |application, deploy|
  
  # use opsworks ssh key management and load the key into the ec2 instance
  prepare_git_checkouts(
    :user => "root",
    :group => "root",
    :home => "/root/",
    :ssh_key => deploy[:scm][:ssh_key]
  ) if deploy[:scm][:scm_type].to_s == 'git'

  # clone the repo
  execute "cd /mnt && git clone #{deploy[:scm][:repository]} #{application}" do
    ignore_failure true
  end


  # use opsworks ssh key management and load the key into the ec2 instance. 
  # it's helpful to have the deploy key loaded into the root user

  # copy ssh key to root user
  execute "touch /root/.ssh/id_deploy" do
    ignore_failure true
  end
  
  ssh_key = deploy[:scm][:ssh_key]
  
  execute "copy ssh_key" do
    command "echo '#{ssh_key}' > /root/.ssh/id_deploy"
  end
  
  execute "chmod 0600 /root/.ssh/id_deploy" do
    ignore_failure true
  end

  # make sure the ssh key is loaded
  execute "eval `ssh-agent -s`"
  execute "ssh-agent bash -c 'ssh-add /root/.ssh/id_deploy'"


  # use simple git pull to deploy code changes
  execute "cd /mnt/#{application} && git clean -df && git reset --hard && git pull"

  
end