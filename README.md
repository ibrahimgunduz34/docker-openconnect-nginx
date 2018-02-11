[preview]: https://raw.githubusercontent.com/MarkusMcNugen/docker-templates/master/qbittorrentvpn/Screenshot.png "qBittorrent Preview"

# OpenConnect VPN Server
OpenConnect server is an SSL VPN server. Its purpose is to be a secure, small, fast and configurable VPN server. It implements the OpenConnect SSL VPN protocol, and has also (currently experimental) compatibility with clients using the AnyConnect SSL VPN protocol. The OpenConnect protocol provides a dual TCP/UDP VPN channel, and uses the standard IETF security protocols to secure it.

[Homepage](https://ocserv.gitlab.io/www/platforms.html)<br>
[Documentation](https://ocserv.gitlab.io/www/manual.html)<br>
[Source](https://gitlab.com/ocserv/ocserv)

# Docker Features
* Base: Alpine 3.7
* Size: 23.1MB
* Modification of the listening port for more networking versatility
* Customizing the DNS servers used for queries over the VPN
* Supports tunneling all traffic over the VPN or tunneling only specific routes via split-include
* Config directory can be mounted to a host directory for persistance 
* Advanced manual configuration for power users

# Run container from Docker registry
The container is available from the Docker registry and this is the simplest way to get it.

## Basic Configuration:

```
$ docker run --privileged  -d \
              -v /your/config/path/:/config \
              -p 4443:4443 \
              -p 4443:4443/udp \
              markusmcnugen/markusmcnugen
```

## Intermediate Configuration:
```
$ docker run --privileged  -d \
              -v /your/config/path/:/config \
              -e "LISTEN_PORT=443" \
              -e "DNS_SERVERS=8.8.8.8,8.8.4.4" \
              -e "TUNNEL_MODE=split-include" \
              -e "TUNNEL_ROUTES=192.168.1.0/24" \
              -e "SPLIT_DNS_DOMAINS=example.com" \
              -p 4443:4443 \
              -p 4443:4443/udp \
              openconnect
```

## Advanced Configuration:
This container allows for advanced configurations for power users who know what they are doing by **mounting the /config volume to a host directory**. Users can then drop in their own certs and modify the configuration. The **POWER_USER** environmental variable is required for Some of these features involve setting up site to site VPN links, User Groups, TCP Proxy support

### Environment Variables
| Variable | Required | Function | Example |
|----------|----------|----------|----------|
|`LISTEN_PORT`| No | Listening port for VPN connections|`LISTEN_PORT=4443`|
|`DNS_SERVERS`| No | Comma delimited name servers |`DNS_SERVERS=8.8.8.8,8.8.4.4`|
|`TUNNEL_MODE`| No | Tunnel mode (all\|split-include) |`TUNNEL_MODE=split-include`|
|`TUNNEL_ROUTES`| No | Comma delimited tunnel routes (Accepts full subnet and CIDR notation) |`TUNNEL_ROUTES=192.168.1.0/24`|
|`SPLIT_DNS_DOMAINS`| No | Comma delimited dns domains |`SPLIT_DNS_DOMAINS=example.com`|
|`POWER_USER`| No | Allows for advanced manual configuration via host mounted /config volume |`POWER_USER=no`|

### Volumes
| Volume | Required | Function | Example |
|----------|----------|----------|----------|
| `config` | Yes | OpenConnect config files | `/your/config/path/:/config`|

### Ports
| Port | Proto | Required | Function | Example |
|----------|----------|----------|----------|----------|
| `4443` | TCP | Yes | OpenConnect server TCP listening port | `4443:4443/tcp`|
| `4443` | UDP | Yes | OpenConnect server UDP listening port | `4443:4443/udp`|

## How to use this OpenConnect Server Docker

## Issues
If you are having issues with this container please submit an issue on GitHub.
Please provide logs, docker version and other information that can simplify reproducing the issue.
Using the latest stable verison of Docker is always recommended. Support for older version is on a best-effort basis.

## Building the container yourself
To build this container, clone the repository and cd into it.

### Build it:
```
$ cd /repo/location/qbittorrentvpn
$ docker build -t qbittorrentvpn .
```
### Run it:
```
$ docker run --privileged  -d \
              -v /your/config/path/:/config \
              -e "LISTEN_PORT=443" \
              -e "DNS_SERVERS=8.8.8.8,8.8.4.4" \
              -e "TUNNEL_MODE=split-include" \
              -e "TUNNEL_ROUTES=192.168.1.0/24" \
              -e "SPLIT_DNS_DOMAINS=example.com" \
              -p 4443:4443 \
              -p 4443:4443/udp \
              openconnect
```

This will start a container as described in the "Run container from Docker registry" section.
