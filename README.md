# OpenConnect VPN Server With Obfuscation

## Credits
* https://github.com/MarkusMcNugen/docker-openconnect

## How To Setup

* Build Dockerfile

```
$ docker build -t docker-openconnect-nginx:latest  -f Dockerfile .
``` 

* Create a volume to keep the configuration file and certificates permanent
```
$ docker volume create openconnect
```

* Run the server 
```
docker run --name openconnect --privileged  -d \
              -v openconnect:/config \
              -p 443:443 \
              -p 443:443/udp \
              -e SRV_CN=<your_server_public_ip> \
              -e LISTEN_PORT=4443 \
              docker-openconnect-nginx:latest
```

* Create a new user
```
$ docker exec -it openconnect sh
$ ocpasswd -c /config/ocpasswd
```

* Create a client certificate in the container
```
export vpn_user=your-user
export vpn_pass=your-vpn-pass 

openssl req -newkey rsa:2048 -nodes -keyout /config/certs/$vpn_user.key -x509 -days 1095 -out /config/certs/$vpn_user.crt -subj "/C=UA/ST=Kyiv/L=Kyiv/O=MyVPN/OU=IT/CN=$vpn_user"
```

* Generate client certificate
```
$ openssl pkcs12 -export -out /config/certs/$vpn_user.p12 -inkey /config/certs/$vpn_user.key -in /config/certs/$vpn_user.crt -certfile /config/certs/ca.pem -password pass:$vpn_pass
```

* In some cases, some devices like Android phones may not support latest certificate format. In oder to create the certificate in legacy format, extract the private key and certificates from a PKCS#12 file
```
$ openssl pkcs12 -nodes -in /config/certs/${vpn_user}.p12 -out /config/certs/${vpn_user}-legacy.pem -password pass:$vpn_pass
```

* Convert the file to PCKS#12 legacy format.
```
$ openssl pkcs12 -export -legacy -in /config/certs/${vpn_user}-legacy.pem -out /config/certs/${vpn_user}-legacy.p12 -password pass:$vpn_pass
```

* Copy the client certificates from the container to the host to transfer anywhere you can copy to your device.
```
$ docker cp openconnect:/config/certs/your-user-legacy.p12 .
$ docker cp openconnect:/config/certs/your-user.p12 .
```

* Connect to OpenConnect server using the certificate from the supported client applications. (I'll update this section for each platform)