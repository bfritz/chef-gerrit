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
require 'mixlib/shellout'
require 'json'

# this recipe creates an admin user for gerrit to be used by bot/cli tasks

batch_admin_username = node['gerrit']['batch_admin_user']['username']

ssh_key_filename = "id_rsa-#{batch_admin_username}"
ssh_key_file = node['gerrit']['home'] + "/.ssh/" + ssh_key_filename

war_path = "#{node['gerrit']['home']}/war/gerrit-#{node['gerrit']['version']}.war"
  
execute "generate private ssh key for 'Gerrit Code Review' user" do
  command "ssh-keygen -t rsa -q -f #{ssh_key_file} -C\"#{batch_admin_username}@#{node['gerrit']['hostname']}\""
  user node['gerrit']['user']
  group node['gerrit']['group']
  creates ssh_key_file
end

Chef::Recipe.send(:include, Gerrit::Helpers)
ruby_block "gerrit create batch_admin_user" do
  block do
    has_admin = ssh_can_connect?(batch_admin_username, "#{ssh_key_file}.pub", node['gerrit']['hostname'], 29418)
    
    unless has_admin then
      # add account
      test = run_gsql("SELECT * FROM account_external_ids WHERE external_id=\"username:#{batch_admin_username}\";")
      if test.length == 1
        account_id = test[0]['account_id']
      else
        most_recent_account = run_gsql("SELECT s from account_id ORDER BY s DESC LIMIT 1");
        if most_recent_account.length == 1
          account_id = next_account_id = most_recent_account[0]['s'].to_i + 10;
        else
          account_id = next_account_id = 1
        end
        puts "next account id: #{next_account_id}"
        run_gsql("INSERT INTO account_id(s) VALUES(#{next_account_id});")
        run_gsql("INSERT INTO accounts(full_name, account_id, registered_on) VALUES(\"Magic Bot User\", #{next_account_id}, \"#{Time.now.strftime("%Y-%m-%y %H:%M:%S")}\");")
        run_gsql("INSERT INTO account_external_ids(account_id,external_id) VALUES(\"#{next_account_id}\",\"username:#{batch_admin_username}\");")
      end
      # add account into magic admin group
      test = run_gsql("SELECT * FROM account_group_members WHERE account_id=#{account_id} AND group_id=1;")
      unless test.length == 1
        run_gsql("INSERT INTO account_group_members(account_id,group_id) VALUES(#{account_id},1);")
      end
      # delete all ssh keys of user and add current public key
      public_key_content = File.read("#{ssh_key_file}.pub")
      run_gsql("DELETE FROM account_ssh_keys WHERE account_id=#{account_id};")
      run_gsql("INSERT INTO account_ssh_keys(ssh_public_key,valid,account_id,seq) VALUES(\"#{public_key_content}\", \"Y\", #{account_id}, 1);")
    end
  end
  only_if do node['gerrit']['version'].to_f < 2.13 end
end