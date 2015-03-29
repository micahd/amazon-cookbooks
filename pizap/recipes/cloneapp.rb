template "/home/ubuntu/.ssh/chef_ssh_deploy_wrapper.sh" do
  source "chef_ssh_deploy_wrapper.sh.erb"
  owner 'ubuntu'
  mode 0770
end
template 'id_rsa' do
  path '/home/ubuntu/.ssh/id_rsa'
  source 'id_rsa.erb'
  owner 'ubuntu'
  group 'ubuntu'
  mode 0600
  backup false
end
Host github.com
  IdentityFile ~/.ssh/id_rsa
end
directory '/mnt/code' do
  user "ubuntu"
  group "ubuntu"
end

git "/mnt/code" do
  repository "git@github.com:pizap/production-web.git"
  user "ubuntu"
  group "ubuntu"
end