base_folder= "/home/ubuntu"
time_now = Time.now.strftime("%Y-%m-%d_%H-%M")
db_name = "#{node[:db_name]}"
folder_name = "#{node[:file_prefix]}_db_backup-#{db_name}-#{time_now}"
archive_name = "#{folder_name}.tar.gz"
archive_path = "#{base_folder}/#{archive_name}"
bucket_name = "#{node[:bucket_name]}"

aws_sdk_gem_name = "aws-sdk-v1"

bash "dbs_backup" do
  user "ubuntu"
  cwd base_folder
  code <<-EOH
    mongodump -d #{db_name} -o ./#{folder_name}
    tar -czvf #{archive_path} ./#{folder_name}
    rm -rf #{folder_name}
  EOH
end

gem_package "#{aws_sdk_gem_name}" do
  action :install
end

ruby_block "upload-dump-archive-to-s3" do
  block do
    require "#{aws_sdk_gem_name}"

    s3 = AWS::S3.new(
          :access_key_id => "#{node[:access_key_id]}",
          :secret_access_key => "#{node[:secret_key]}")

    key = File.basename(archive_path)
    s3.buckets[bucket_name].objects[key].write(:file => archive_path)
  end
  action :run
end

log "logging" do
  message "Database #{db_name} backup named #{folder_name} successfully uploaded to S3 bucket #{bucket_name}"
  level :info
end

bash "cleanup" do
  user "ubuntu"
  code <<-EOH
    rm -rf #{archive_path}
  EOH
end
