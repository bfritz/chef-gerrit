require 'spec_helper'

describe 'gerrit::_config' do

  let(:install_dir)      { '/var/gerrit' }
  let(:user)             { 'gerrit' }
    
  context 'proxy is enabled by default' do
    cached(:chef_run) do
      ChefSpec::Runner.new do |node|
        puts(described_recipe)
        node.set['gerrit']['install_dir'] = install_dir
        node.set['gerrit']['config']['auth']['registerEmailPrivateKey'] = "123"
        node.set['gerrit']['config']['auth']['restTokenPrivateKey'] = "123"
      end.converge(described_recipe)
    end
  
    it 'sets listenUrl to proxy-http by default' do
      expect(chef_run).to render_file("/var/gerrit/etc/gerrit.config").with_content('listenUrl = proxy-http://127.0.0.1:8080')
    end
    
    it 'sets listenUrl to proxy-http with ssl enabled' do
      chef_run.node.set['gerrit']['proxy']['ssl'] = true
      chef_run.converge(described_recipe) # The converge happens inside the test
      expect(chef_run).to render_file("/var/gerrit/etc/gerrit.config").with_content('listenUrl = proxy-https://127.0.0.1:8080')
    end
  end
  
  context 'proxy is disabled' do
    cached(:chef_run) do
      ChefSpec::Runner.new do |node|
        puts(described_recipe)
        node.set['gerrit']['install_dir'] = install_dir
        node.set['gerrit']['proxy']['enable'] = false
        node.set['gerrit']['config']['auth']['registerEmailPrivateKey'] = "123"
        node.set['gerrit']['config']['auth']['restTokenPrivateKey'] = "123"
      end.converge(described_recipe)
    end
    
    it 'sets listenUrl to http for proxy disabled' do
      chef_run.node.set['gerrit']['proxy']['enable'] = false
      chef_run.converge(described_recipe)
      expect(chef_run).to render_file("/var/gerrit/etc/gerrit.config").with_content('listenUrl = http://*:8080')
    end

  end

end
