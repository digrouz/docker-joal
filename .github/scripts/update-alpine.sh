#!/usr/bin/env bash

ALPINELINUX_URL="https://api.github.com/repos/alpinelinux/aports/git/refs/tags"

LAST_VERSION=$(curl -SsL https://api.github.com/repos/alpinelinux/aports/git/refs/tags | jq -c '.[] | select( .ref | contains("v3.") and (contains("rc") | not) and (contains("alpha") | not) and (contains("pre") | not))' | jq '.ref' -r| tail -1 | sed -e 's|refs/tags/v||')
echo $LAST_VERSION

sed -i -e "s|FROM alpine:.*|FROM alpine:${LAST_VERSION}|" Dockerfile*

if output=$(git status --porcelain) && [ -z "$output" ]; then
  # Working directory clean
  echo "No new version available!"
else
  # Uncommitted changes
  git commit -a -m "rebased to Alpine Linux  version: ${LAST_VERSION}"
  git push
fi
