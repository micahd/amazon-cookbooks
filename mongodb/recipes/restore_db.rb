bucket_name = "jaybird-mongodb-dump"
base_folder= "/home/ubuntu"
db_name = "#{node[:db_name]}"
prefix = "#{node[:file_prefix]}_db_backup-#{db_name}"

node.default[:archive_name] = ""
node.default[:folder_name] = ""

ruby_block "download_dump_archive_from_s3" do
  block do
    require "aws-sdk-v1"

    s3 = AWS::S3.new(
          :access_key_id => "#{node[:access_key_id]}",
          :secret_access_key => "#{node[:secret_key]}")

    bucket = s3.buckets[bucket_name]

    latest_backup_key = bucket.objects.with_prefix(prefix).max_by(&:last_modified).key
    file_name = "#{base_folder}/" + File.basename(latest_backup_key)
    File.open(file_name, 'wb') do |file|
      bucket.objects[latest_backup_key].read do |chunk|
        file.write(chunk)
      end
    end

    node.set[:archive_name] = File.basename(latest_backup_key)
    node.set[:folder_name] = File.basename(latest_backup_key, ".tar.gz")
  end
  notifies :create, "ruby_block[update_values]", :immediately
end

# idea from http://cpenniman.blogspot.com/2013/05/passing-values-from-one-chef-resource.html
ruby_block "update_values" do
  block do
    log_resource = resources("log[logging]")
    log_resource.message "Db backup #{node[:archive_name]} successfully downloaded from S3 bucket #{bucket_name}"

    bash_resource = resources("bash[delete_old_db_and_restore_new]")
    bash_resource.code <<-EOH
      tar -xvf #{node[:archive_name]}
      mongo #{db_name} --eval "db.dropDatabase()"
      mongorestore -d #{db_name} #{base_folder}/#{node[:folder_name]}/#{db_name}/

      rm -rf #{node[:archive_name]} #{base_folder}/#{node[:folder_name]}
    EOH
  end
  action :nothing
end

log "logging" do
  # will be owerriten
  message "some test message"
  level :info
end

bash "delete_old_db_and_restore_new" do
  user "ubuntu"
  cwd base_folder
  # will be owerriten
  code <<-EOH
    touch test.txt
  EOH
end
