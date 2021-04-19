#!/usr/bin/env bash

JOAL_URL="https://api.github.com/repos/anthonyraymond/joal/tags"

LAST_VERSION=$(curl -SsL ${JOAL_URL} | jq .[0].name -r )

sed -i -e "s|JOAL_VERSION='.*'|JOAL_VERSION='${LAST_VERSION}'|" Dockerfile*

if output=$(git status --porcelain) && [ -z "$output" ]; then
  # Working directory clean
  echo "No new version available!"
else 
  # Uncommitted changes
  git commit -a -m "update to version: ${LAST_VERSION}"
  git push
fi
