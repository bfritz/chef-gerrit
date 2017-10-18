####################################
# Cron-Job
####################################

directory "#{node['gerrit']['home']}/scripts" do
  owner node['gerrit']['user']
end

template "#{node['gerrit']['home']}/scripts/repack-repositories.sh" do
  source "scripts/repack-repositories.sh.erb"
  owner node['gerrit']['user']
  group node['gerrit']['group']
  mode 0744
end

cron "repack-repositories" do
  hour "2"
  minute "0"
  weekday "0"
  command "#{node['gerrit']['home']}/scripts/repack-repositories.sh"
  user node['gerrit']['user']
end