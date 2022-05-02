#!/bin/bash

# sync main branch manually
if [ "$(git branch --show-current)" != "main" ]
then
    echo "Synching with main branch"
    git restore -s origin/main README.md docs .devcontainer .github
fi

git status
