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

* Run the server. **DO NOT FORGET TO REPLACE** `<your server public ip>` **text.**
```
docker run --name openconnect --privileged  -d \
              -v openconnect:/config \
              -p 443:443 \
              -p 443:443/udp \
              -e SRV_CN=<your server public ip> \
              -e LISTEN_PORT=4443 \
              docker-openconnect-nginx:latest
```

* Create a new user
```
$ docker exec -it openconnect sh
$ export vpn_user=your-vpn-user
$ export vpn_pass=your-vpn-pass 
$ ocpasswd -c /config/ocpasswd $vpn_user
```

* Create a client certificate in the container
```
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

* Copy the client certificates from the container to the host to transfer anywhere you can copy to your device. **DO NOT FORGET TO RUN THE COMMAND ON THE HOST MACHINE AND REPLACE your-vpn-user text with your username**
```
$ docker cp openconnect:/config/certs/your-vpn-user-legacy.p12 .
$ docker cp openconnect:/config/certs/your-vpn-user.p12 .
```

## Testing the connection
* Extract the client certificate from the PCKS#12 file.
```
$ openssl pkcs12 -in your-vpn-user.p12 -clcerts -nokeys -out your-vpn-user-client-cert.crt
```

* Extract the key from the PCKS#12 file.
```
$ openssl pkcs12 -in your-vpn-user.p12 -nocerts -out your-vpn-user-client-key.key
```

* Optionally, you can remove the pass phrase from the key to make the test easier without using password
```
$ openssl rsa -in your-vpn-user-client-key.key -out your-vpn-user-client-key.key
```

* Extract CA certificate
```
$ openssl pkcs12 -in your-vpn-user.p12 -cacerts -out your-vpn-user-ca-cert.crt
```

* Call the endpoint. **DO NOT FORGET TO REPLACE** `<your server public ip>` **text.**
```
$ curl -kv --cacert your-vpn-user-ca-cert.crt --cert your-vpn-user-client-cert.crt --key your-vpn-user-client-key.key -s https://<your server public ip>  2>&1 | grep -E 'HTTP/1.1 200 OK'
```

## How To Connect
* You can connect the service using platform specific client applications. I'll edit this part later in detail.