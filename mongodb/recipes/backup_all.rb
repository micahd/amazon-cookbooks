base_folder= "/home/ubuntu"
time_now = Time.now.strftime("%Y-%m-%d_%H-%M")
folder_name = "#{node[:file_prefix]}_dbs_backup-#{time_now}"
archive_name = "#{base_folder}/#{folder_name}.tar.gz"
bucket_name = "#{node[:bucket_name]}"

bash "dbs_backup" do
  user "ubuntu"
  cwd base_folder
  code <<-EOH
    mongodump -o ./#{folder_name}
    tar -czvf #{archive_name} ./#{folder_name}
    rm -rf #{folder_name}
  EOH
end

gem_package "aws-sdk" do
  action :install
end

ruby_block "upload-dump-archive-to-s3" do
  block do
    require "aws-sdk"

    s3 = AWS::S3.new(
          :access_key_id => "#{node[:access_key_id]}",
          :secret_access_key => "#{node[:secret_key]}")

    key = File.basename(archive_name)
    s3.buckets[bucket_name].objects[key].write(:file => archive_name)
  end
  action :run
end

log "Databases backup #{archive_name} successfully uploaded to S3 bucket #{bucket_name}" do
  level :info
end

bash "cleanup" do
  user "ubuntu"
  code <<-EOH
    rm -rf #{archive_name}
  EOH
end
