if node['gerrit']['config']['database']['type'].upcase == "MYSQL"
  include_recipe "gerrit::mysql"
elsif node['gerrit']['config']['database']['type'].upcase == "POSTGRESQL"
  include_recipe "gerrit::postgresql"
end