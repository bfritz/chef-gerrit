control 'gerrit-1' do
  title 'Gerrit Setup'
  desc '
    Check that gerrit is installed and running
  '

  describe directory('/var/gerrit/review/etc') do
    it { should exist }
  end

  [8080, 29418].each do |listen_port|

    describe port(listen_port) do

      # this currently fails with inspec 1.6.0 when listening on 127.0.0.1
      # Could not parse 127.0.0.1:8080, bad URI(is not URI?): addr://[127.0.0.1]:8080
      skip
      # it { should be_listening }
      # its('protocols') { should include 'tcp6'}
    end
  end

  # port 8080 HTML
  describe command('wget --retry-connrefused --server-response --timeout 60 --output-document - http://localhost:8080') do
    its('exit_status') { should eq 0 }
    its('stdout') { should include '<title>Gerrit Code Review</title>' }
  end

end