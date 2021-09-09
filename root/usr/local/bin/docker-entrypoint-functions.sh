#!/usr/bin/env bash

MYUSER="dockuser"
MYGID="100000"
MYUID="100000"

DetectOS(){
  if [ -e /etc/alpine-release ]; then
    OS="alpine"
  elif [ -e /etc/os-release ]; then
    if grep -q "NAME=\"Ubuntu\"" /etc/os-release ; then
      OS="ubuntu"
    elif grep -q "NAME=\"CentOS Linux\"" /etc/os-release ; then
      OS="rhel"
    elif grep -q "NAME=\"Rocky Linux\"" /etc/os-release ; then
      OS="rhel"
    fi
  fi
  echo $OS
}

AutoUpgrade(){
  local OS=$(DetectOS)
  local MYUPGRADE=0
  if [ "$(id -u)" = '0' ]; then
    if [ -n "${DOCKUPGRADE}" ]; then
      MYUPGRADE="${DOCKUPGRADE}"
    fi
    if [ "${MYUPGRADE}" == 1 ]; then
      DockLog "AutoUpgrade is enabled."
      if [ "${OS}" == "alpine" ]; then
        apk --no-cache upgrade
        rm -rf /var/cache/apk/*
      elif [ "${OS}" == "ubuntu" ]; then
        export DEBIAN_FRONTEND=noninteractive
        apt-get update
        apt-get -y --no-install-recommends dist-upgrade
        apt-get -y autoclean
        apt-get -y clean
        apt-get -y autoremove
        rm -rf /var/lib/apt/lists/*
      elif [ "${OS}" == "rhel" ]; then
        if [ -x "$(command -v dnf)" ]; then
          dnf upgrade -y
          dnf clean all
        elif [ -x "$(command -v yum)" ]; then
          yum upgrade -y
          yum clean all
        fi
        if [ -d /var/cache/yum ];then
          rm -rf /var/cache/yum/*
        fi
        if [ -d /var/cache/dnf ];then
          rm -rf /var/cache/dnf/*
        fi
      fi
    else
      DockLog "AutoUpgrade is not enabled."
    fi
  fi
}

# usage: file_env VAR [DEFAULT]
#    ie: file_env 'XYZ_DB_PASSWORD' 'example'
# (will allow for "$XYZ_DB_PASSWORD_FILE" to fill in the value of
#  "$XYZ_DB_PASSWORD" from a file, especially for Docker's secrets feature)
file_env() {
  local var="$1"
  local fileVar="${var}_FILE"
  local def="${2:-}"
  if [ "${!var:-}" ] && [ "${!fileVar:-}" ]; then
    echo >&2 "error: both $var and $fileVar are set (but are exclusive)"
    exit 1
  fi
  local val="$def"
  if [ "${!var:-}" ]; then
    val="${!var}"
  elif [ "${!fileVar:-}" ]; then
    val="$(< "${!fileVar}")"
  fi
  export "$var"="$val"
  unset "$fileVar"
}

ConfigureUser () {
  local OS=$(DetectOS)
  if [ "$(id -u)" = '0' ]; then
    # Managing user
    if [ -n "${DOCKUID}" ]; then
      MYUID="${DOCKUID}"
    fi
    # Managing group
    if [ -n "${DOCKGID}" ]; then
      MYGID="${DOCKGID}"
    fi
    local OLDHOME
    local OLDGID
    local OLDUID
    if grep -q "${MYUSER}" /etc/passwd; then
      OLDUID=$(id -u "${MYUSER}")
    fi
    if grep -q "${MYUSER}" /etc/group; then
      OLDGID=$(id -g "${MYUSER}")
    fi
    if [ -n "${OLDUID}" ] && [ "${MYUID}" != "${OLDUID}" ]; then
      OLDHOME=$(grep "$MYUSER" /etc/passwd | awk -F: '{print $6}')
      if [ "${OS}" == "alpine" ]; then
        deluser "${MYUSER}"
      else
        userdel "${MYUSER}"
      fi
      DockLog "Deleted user ${MYUSER}"
    fi
    if grep -q "${MYUSER}" /etc/group; then
      if [ "${MYGID}" != "${OLDGID}" ]; then
        if [ "${OS}" == "alpine" ]; then
          delgroup "${MYUSER}"
        else
          groupdel "${MYUSER}"
        fi
        DockLog "Deleted group ${MYUSER}"
      fi
    fi
    if ! grep -q "${MYUSER}" /etc/group; then
      if [ "${OS}" == "alpine" ]; then
        addgroup -S -g "${MYGID}" "${MYUSER}"
      else
        groupadd -r -g "${MYGID}" "${MYUSER}"
      fi
      DockLog "Created group ${MYUSER}"
    fi
    if ! grep -q "${MYUSER}" /etc/passwd; then
      if [ -z "${OLDHOME}" ]; then
        OLDHOME="/home/${MYUSER}"
        mkdir "${OLDHOME}"
        DockLog "Created home directory ${OLDHOME}"
      fi
      if [ "${OS}" == "alpine" ]; then
        adduser -S -D -H -s /sbin/nologin -G "${MYUSER}" -h "${OLDHOME}" -u "${MYUID}" "${MYUSER}"
      else
        useradd --system --shell /sbin/nologin --gid "${MYGID}" --home-dir "${OLDHOME}" --uid "${MYUID}" "${MYUSER}"
      fi
      DockLog "Created user ${MYUSER}"

    fi
    if [ -n "${OLDUID}" ] && [ "${MYUID}" != "${OLDUID}" ]; then
      DockLog "Fixing permissions for user ${MYUSER}"
      find / -user "${OLDUID}" -exec chown ${MYUSER} {} \; &> /dev/null
      if [ "${OLDHOME}" == "/home/${MYUSER}" ]; then
        chown -R "${MYUSER}" "${OLDHOME}"
        chmod -R u+rwx "${OLDHOME}"
      fi
      DockLog "... done!"
    fi
    if [ -n "${OLDGID}" ] && [ "${MYGID}" != "${OLDGID}" ]; then
      DockLog "Fixing permissions for group ${MYUSER}"
      find / -group "${OLDGID}" -exec chgrp ${MYUSER} {} \; &> /dev/null
      if [ "${OLDHOME}" == "/home/${MYUSER}" ]; then
        chown -R :"${MYUSER}" "${OLDHOME}"
        chmod -R go-rwx "${OLDHOME}"
      fi
      DockLog "... done!"
    fi
  fi
}

DockLog(){
  local OS=$(DetectOS)
  local MYDATE=$(date)
  if [ "${OS}" == "rhel" ] || [ "${OS}" == "alpine" ]; then
    echo "[${MYDATE}] ${1}"
  else
    logger "[${MYDATE}] ${1}"
  fi
}

RunDropletEntrypoint(){
  local OS=$(DetectOS)
  if [ $(find /docker-entrypoint.d -name "*.sh" | wc -l) -gt 0 ]; then
    DockLog "Executing all bash scripts from /docker-entrypoint.d"
    for bashdroplet in $(ls -1 /docker-entrypoint.d/*.sh); do
      DockLog "launching ${bashdroplet}"
      bash ${bashdroplet}
    done
  fi
  if [ $(find /docker-entrypoint.d -name "*.php" | wc -l) -gt 0 ]; then
    DockLog "Executing all php scripts from /docker-entrypoint.d"
    for phpdroplet in $(ls -1 /docker-entrypoint.d/*.php); do
      DockLog "launching ${phpdroplet}"
      php ${phpdroplet}
    done
  fi
}

PrepareEnvironment(){
  local OS=$(DetectOS)
  if [ -f ${1} ]; then
    grep -v "#" ${1} |
    while IFS=\= read -r name value; do
      if [ -n "${name}" ]; then
        echo "export ${name}=${value}" >> /etc/profile.d/docker-$(basename ${1}).sh
      fi
    done
    DockLog "Created environment file /etc/profile.d/docker-$(basename ${1}).sh"
  else
    DockLog "Given argument is not supported"
  fi
}
