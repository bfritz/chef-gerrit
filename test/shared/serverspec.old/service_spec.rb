# require 'spec_helper'

require 'serverspec'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS


describe 'service gerrit' do
  it 'should be enabled and running' do
    expect(service 'gerrit').to be_enabled
    expect(service 'gerrit').to be_running
  end

  it 'should listen to port 8080' do
    expect(port 8080).to be_listening
  end

  it 'should listen to port 29418' do
    expect(port 29418).to be_listening
  end
end
