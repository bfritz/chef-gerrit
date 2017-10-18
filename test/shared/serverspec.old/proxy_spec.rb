# require 'spec_helper'

require 'serverspec'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS

RSpec.configure do |c|
  c.before :all do
    c.os = backend(Serverspec::Commands::Base).check_os
  end
end

describe 'service apache2 httpd' do
  it 'should be enabled and running' do
    puts "OS: #{RSpec.configuration.os.to_s}"
    case RSpec.configuration.os[:family]
      when "Debian"
        @service_name = 'apache2'
      when "Ubuntu"
        @service_name = 'apache2'
      else
        @service_name = 'httpd'
    end
    expect(service @service_name).to be_running
    expect(service @service_name).to be_enabled
  end

  it 'should listen to port 80' do
    expect(port 80).to be_listening
  end

  it 'should answer to HTTP requests on port 80' do

    pending "not working within Docker - Apache2 has to be restarted once more"

    case RSpec.configuration.os[:family]
      when "Ubuntu"
        @cmd = 'echo "GET / HTTP/1.1" | nc localhost 80'
        expect(command @cmd).to return_stdout /Content-Length:.*/
      else
        @cmd = 'curl http://localhost'
        expect(command @cmd).to return_stdout /.*<title>Gerrit Code Review<\/title>.*/
    end
  end
end

describe 'gerrit.config' do
  it 'should set the correct listenUrl for proxy setup' do
    expect(file '/var/gerrit/review/etc/gerrit.config').to contain "listenUrl = proxy-http://127.0.0.1:8080"
  end
end