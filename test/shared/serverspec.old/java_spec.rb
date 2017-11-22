# require 'spec_helper'

require 'serverspec'

include Serverspec::Helper::Exec
include Serverspec::Helper::DetectOS


describe 'java' do
  it 'installs OpenJDK Java 7' do
    expect(command 'java -version').to return_stdout /java version "1.7.*/
  end
end
