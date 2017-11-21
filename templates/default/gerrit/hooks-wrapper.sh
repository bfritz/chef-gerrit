#!/bin/bash

HOOK=$0
HOOK_NAME=$(basename $0)

for file in $HOOK.d/*; do
  if [[ -x "$file" ]]; then
    echo "Executing hook $HOOK_NAME file $file"
    $file --action $HOOK "$@"
  fi
done


