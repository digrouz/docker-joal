#!/usr/bin/env bash

. /etc/profile
. /usr/local/bin/docker-entrypoint-functions.sh

MYUSER="${APPUSER}"
MYUID="${APPUID}"
MYGID="${APPGID}"
MYPORT="1234"
MYSECRET_OBFUSCATION_PATH="joaleeS8efie"
MYSECRET_TOKEN="eikoogei8yohphaph6eiza3EraaChav2jee8lood9iegaing"

AutoUpgrade
ConfigureUser

if [ -n  "${DOCKPORT}" ]; then
  MYPORT="${DOCKPORT}"
fi
if [ -n  "${DOCKSECRET_OBFUSCATION_PATH}" ]; then
  MYSECRET_OBFUSCATION_PATH="${DOCKSECRET_OBFUSCATION_PATH}"
fi
if [ -n  "${DOCKSECRET_TOKEN}" ]; then
  MYSECRET_TOKEN="${DOCKSECRET_TOKEN}"
fi

if [ "${1}" == 'joal' ]; then

  cd /joal

  DockLog "Creating and populating directory /config/torrents with upstream defaults"
  cp -r /joal/torrents /config/
  DockLog "Creating an populating directory /config/clients with upstream defaults"
  cp -r /joal/clients /config/

  if [ ! -e /config/config.json ]; then
    DockLog "Creating default config file /config/config.json"
    cp /joal/config.json /config/config.json
  fi

  DockLog "Fixing permissions on /config"
  chown -R ${MYUSER} /config

  RunDropletEntrypoint

  DockLog "Starting application: ${1}"
  exec su-exec "${MYUSER}" java -jar /joal/joal.jar \
	  --joal-conf=/config  \
          --spring.main.web-environment=true \
	  --server.port="${MYPORT}" \
	  --joal.ui.path.prefix="${MYSECRET_OBFUSCATION_PATH}" \
	  --joal.ui.secret-token="${MYSECRET_TOKEN}"
else
  DockLog "Lauching command: $@"
  exec "$@"
fi
