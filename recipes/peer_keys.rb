#
# Cookbook Name:: gerrit
# Recipe:: peer_keys
#
# Copyright 2012, Steffen Gebert / TYPO3 Association
#
# This program is free software: you can redistribute it and/or modify
# it under the terms of the GNU General Public License as published by
# the Free Software Foundation, either version 3 of the License, or
# (at your option) any later version.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program.  If not, see <http://www.gnu.org/licenses/>.
#

# @todo: check wether this recipe might is obsolete?
# the recipe batch_admin.rb creates an ssh-key plus a user for gerrit that has admin privileges
# is this key/recipe still needed?

ssh_key_filename = "id_rsa-gerrit-code-review"
ssh_key = node['gerrit']['home'] + "/.ssh/" + ssh_key_filename
public_key = node['gerrit']['peer_keys']['public']
private_key = node['gerrit']['peer_keys']['private']

execute "generate private ssh key for 'Gerrit Code Review' user" do
  command "ssh-keygen -t rsa -q -f #{ssh_key} -P \"\" -C\"Gerrit Code Review@" + node['gerrit']['hostname'] + "\""
  user node['gerrit']['user']
  group node['gerrit']['group']
  creates ssh_key
  only_if { public_key.to_s == "" }
end

ruby_block "save keys to attributes" do
  only_if { public_key.to_s == "" }
  block do
    private_key = File.read(ssh_key)
    public_key = File.read(ssh_key + ".pub")
    node.set['gerrit']['peer_keys']['private'] = private_key
    node.set['gerrit']['peer_keys']['public'] = public_key
  end
end

file node['gerrit']['install_dir'] + "/etc/peer_keys" do
  content public_key.split(" ").slice(1)
  owner node['gerrit']['user']
  group node['gerrit']['user']
  only_if { public_key.to_s != "" }
end

file ssh_key do
  content node['gerrit']['peer_keys']['private']
  owner node['gerrit']['user']
  group node['gerrit']['group']
  mode 0600
  only_if { ssh_key != "" }
end

file ssh_key + ".pub" do
  content node['gerrit']['peer_keys']['public']
  owner node['gerrit']['user']
  group node['gerrit']['group']
  mode 0644
end