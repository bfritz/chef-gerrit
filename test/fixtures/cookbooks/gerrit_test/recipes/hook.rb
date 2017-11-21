gerrit_hook 'test' do
  event 'patchset-created'
  source 'patchset-created-hook.sh'
end
