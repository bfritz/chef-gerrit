#
# Cookbook Name:: gerrit
# Recipe:: _config
#
# Copyright 2014, TYPO3 Association
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#     http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#
# we need to explicitly include the ::default recipe as we need service[gerrit], otherwise we can't run chefspec on this recipe
include_recipe "gerrit::default"

# make sure that some of the needed attributes are predefined with Chef Solo
if Chef::Config[:solo]
  missing_attrs = %w[
    registerEmailPrivateKey
    restTokenPrivateKey
  ].select { |attr| node['gerrit']['config']['auth'][attr].nil? }.map { |attr| %Q{node['gerrit']['config']['auth']['#{attr}']} }

  unless missing_attrs.empty?
    Chef::Application.fatal! "You must set #{missing_attrs.join(', ')} in chef-solo mode."
  end
else
  # generate all passwords
  require 'securerandom'

  node.set_unless['gerrit']['config']['auth']['registerEmailPrivateKey'] = SecureRandom::base64(32)
  node.set_unless['gerrit']['config']['auth']['restTokenPrivateKey']   = SecureRandom::base64(32)
  node.save
end

template "#{node['gerrit']['install_dir']}/etc/secure.config" do
  source "gerrit/secure.config.erb"
  owner node['gerrit']['user']
  group node['gerrit']['group']
  mode 0600
  notifies :restart, "service[gerrit]"
end

template "#{node['gerrit']['install_dir']}/etc/gerrit.config" do
  source "gerrit/gerrit.config.erb"
  owner node['gerrit']['user']
  group node['gerrit']['group']
  mode 0644
  notifies :restart, "service[gerrit]"
end