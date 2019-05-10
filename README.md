# docker-joal

Install Joal into a Linux Container

## Description

An open source command line RatioMaster with an optional WebUI.

https://github.com/anthonyraymond/joal

## Usage
    docker create --name=joal  \
      -v /etc/localtime:/etc/localtime:ro \
      -v <path to persistant data>:/config \
      -e DOCKUID=<UID default:10030> \
      -e DOCKGID=<GID default:10030> \
      -e DOCKUPGRADE=<0|1> \
      -e DOCKPORT=<port default:1234> \
      -p 1234:1234 digrouz/joal


## Environment Variables

When you start the `joal` image, you can adjust the configuration of the `joal` instance by passing one or more environment variables on the `docker run` command line.

### `DOCKUID`

This variable is not mandatory and specifies the user id that will be set to run the application. It has default value `10030`.

### `DOCKGID`

This variable is not mandatory and specifies the group id that will be set to run the application. It has default value `10030`.

### `DOCKUPGRADE`

This variable is not mandatory and specifies if the container has to launch software update at startup or not. Valid values are `0` and `1`. It has default value `0`.

### `DOCKPORT`

This variable is not mandatory and specifies on which port joal should listen. It has default value `1234`.

### `DOCKSECRET_OBFUSCATION_PATH`

This variable is not mandatory but highly advised. Once joal is started head to: `http://localhost:port/SECRET_OBFUSCATION_PATH/ui/`. It has default value `joaleeS8efie`. This must contains only alphanumeric characters (no slash, backslash, or any other non-alphanum char)

### `DOCKSECRET_TOKEN`

This variable is not mandatory but highly advised. secret token here (this is some kind of a password, choose a complicated one). It has default value `eikoogei8yohphaph6eiza3EraaChav2jee8lood9iegaing`

## Notes

* The docker entrypoint can upgrade operating system at each startup. To enable this feature, just add `-e DOCKUPGRADE=1` at container creation.


