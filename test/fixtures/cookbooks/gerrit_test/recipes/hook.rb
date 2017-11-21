gerrit_hook 'test.sh' do
  event 'patchset-created'
  source 'patchset-created-hook.sh'
  variables(text: 'Hello World')
end
