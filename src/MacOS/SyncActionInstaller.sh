#!/bin/bash

reset_repository() {
  git reset
  git checkout .
  git clean -fdx
}

create_action() {
  mkdir -p .github/workflows
  cd .github/workflows

  echo -n "Enter the name of the API github key [default: API_KEY]: "
  read apiKeySecretName
  apiKeySecretName="${apiKeySecretName:-API_KEY}" 

  echo -n "Enter the name of the owner of the forked repo [default: IBM]: "
  read ownerName
  ownerName="${ownerName:-IBM}" 

  echo -n "Enter the branch you want to sync from source [default: main]: "
  read baseBranch
  baseBranch="${baseBranch:-main}" 

  echo -n "Enter the branch you want to sync to fork [default: main]: "
  read headBranch
  headBranch="${headBranch:-main}" 

  touch ibm_fork_sync.yml

  echo "# Repo of the action: https://github.com/IBM-Toolbox-Mexico-Public/fork-sync

name: AO IBM Fork Sync

on:
  push:
  schedule:
    - cron:  '59 23 * * 1-5' # Scheduled at 23:59 UTC every Monday and Friday
  workflow_dispatch:

jobs:
  sync:

    runs-on: ubuntu-latest

    steps:
      - uses: Toolbox-Mexico-CIO-Guadalajara-Public/open-source-fork-sync@v1.2 # Original repo: tgymnich/fork-sync@v1.2 (use if the action breaks)
        with:
          github_token: \${{ secrets.$apiKeySecretName }}
          owner: $ownerName # Repo original owner
          base: $baseBranch # Head to sync from
          head: $headBranch # Head to sync to" >> ibm_fork_sync.yml
}

commit_changes() { 
  git add .
  git commit -m "Added GitHub Sync action to repository."
  git push
}

open_actions_website() {
  open https://github.$(git config remote.origin.url | cut -f2 -d. | tr ':' /)/actions
}


if git status &>/dev/null; then
  echo "- [GitHub repository found] -"
  echo "- [Creating action] -"

  reset_repository
  create_action

  echo "- [Configuring GitHub Sync action] - "
  echo "- [GitHub Sync action created] -"
  echo "- [Pushing action to repo] -"

  commit_changes 
  
  echo "- [Actions created on remote] -"
  echo "- [Opening actions website] -"

  open_actions_website

  echo "- [Finished the installation] -"
  echo "- [Please enable the GitHub action workflows in the forked repo to use this action] -"
  
else
  echo
  echo "- [ERROR: Not in a git repository.] -"
  echo "- [Please run this installer in a valid GitHub repository] -"
  echo
fi
