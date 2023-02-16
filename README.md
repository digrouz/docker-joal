[![auto-update](https://github.com/digrouz/docker-joal/actions/workflows/auto-update.yml/badge.svg)](https://github.com/digrouz/docker-joal/actions/workflows/auto-update.yml)
[![dockerhub](https://github.com/digrouz/docker-joal/actions/workflows/dockerhub.yml/badge.svg)](https://github.com/digrouz/docker-joal/actions/workflows/dockerhub.yml)
![Docker Pulls](https://img.shields.io/docker/pulls/digrouz/joal)

# docker-joal

Install Joal into a Linux Container

## Tags
Several tags are available:
* latest: see alpine
* alpine: [Dockerfile_alpine](https://github.com/digrouz/docker-joal/blob/master/Dockerfile_alpine)

## Description

An open source command line RatioMaster with an optional WebUI.

https://github.com/anthonyraymond/joal

## Usage
    docker create --name=joal  \
      -v <path to persistant data>:/config \
      -e UID=<UID default:12345> \
      -e GID=<GID default:12345> \
      -e AUTOUPGRADE=<0|1> \
      -e TZ=<timezone default:Europe/Brussels> \
      -e JOAL_PORT=<port default:1234> \
      -e JOAL_SECRET_OBFUSCATION_PATH=<string default:joaleeS8efie> \
      -e JOAL_SECRET_TOKEN=<string default:eikoogei8yohphaph6eiza3EraaChav2jee8lood9iegaing> \
      -p 1234:1234 \
      digrouz/joal

## Environment Variables

When you start the `joal` image, you can adjust the configuration of the `joal` instance by passing one or more environment variables on the `docker run` command line.

### `UID`

This variable is not mandatory and specifies the user id that will be set to run the application. It has default value `12345`.

### `GID`

This variable is not mandatory and specifies the group id that will be set to run the application. It has default value `12345`.

### `AUTOUPGRADE`

This variable is not mandatory and specifies if the container has to launch software update at startup or not. Valid values are `0` and `1`. It has default value `0`.

### `TZ`

This variable is not mandatory and specifies the timezone to be configured within the container. It has default value `Europe/Brussels`.

### `JOAL_PORT`

This variable is not mandatory and specifies on which port joal should listen. It has default value `1234`.

### `JOAL_SECRET_OBFUSCATION_PATH`

This variable is not mandatory but highly advised. Once joal is started head to: `http://localhost:port/SECRET_OBFUSCATION_PATH/ui/`. It has default value `joaleeS8efie`. This must contains only alphanumeric characters (no slash, backslash, or any other non-alphanum char)

### `JOAL_SECRET_TOKEN`

This variable is not mandatory but highly advised. secret token here (this is some kind of a password, choose a complicated one). It has default value `eikoogei8yohphaph6eiza3EraaChav2jee8lood9iegaing`

## Notes

* This container is built using [s6-overlay](https://github.com/just-containers/s6-overlay)
* The docker entrypoint can upgrade operating system at each startup. To enable this feature, just add `-e AUTOUPGRADE=1` at container creation.

## Issues

If you encounter an issue please open a ticket at [github](https://github.com/digrouz/docker-joal/issues)