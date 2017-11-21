gerrit_hook 'test' do
  event 'patchset-created'
  source 'patchset-created-hook.sh'
  variables(text: 'Hello World')
end
