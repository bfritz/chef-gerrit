control 'gerrit-2' do
  title 'Gerrit Proxy'
  desc '
    Check that no proxy is installed
  '

  describe port(80) do
    it { should_not be_listening }
  end

end