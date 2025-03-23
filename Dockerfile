FROM alpine:latest

MAINTAINER MarkusMcNugen
# Forked from TommyLau for unRAID

VOLUME /config

# Install dependencies
RUN buildDeps=" \
        curl \
        g++ \
        gawk \
        geoip \
        gnutls-dev \
        gpgme \
        krb5-dev \
        libc-dev \
        libev-dev \
        libnl3-dev \
        libproxy \
        libseccomp-dev \
        libtasn1 \
        linux-headers \
        linux-pam-dev \
        lz4-dev \
        make \
        oath-toolkit-liboath \
        oath-toolkit-libpskc \
        p11-kit \
        pcsc-lite-libs \
        protobuf-c \
        readline-dev \
        scanelf \
        stoken-dev \
        tar \
        tpm2-tss-esys \
        xz \
    "; \
    set -x \
    && apk add --update --virtual .build-deps $buildDeps \
    # The commented out line below grabs the most recent version of OC from the page which may be an unreleased version
    # && export OC_VERSION=$(curl --silent "https://ocserv.gitlab.io/www/changelog.html" 2>&1 | grep -m 1 'Version' | awk '/Version/ {print $2}') \
    # The line below grabs the 2nd most recent version of OC
    && export OC_VERSION=$(curl --silent "https://ocserv.gitlab.io/www/changelog.html" 2>&1 | grep -m 2 'Version' | tail -n 1 | awk '/Version/ {print $2}') \
    && curl -SL "ftp://ftp.infradead.org/pub/ocserv/ocserv-$OC_VERSION.tar.xz" -o ocserv.tar.xz \
    && mkdir -p /usr/src/ocserv \
    && tar -xf ocserv.tar.xz -C /usr/src/ocserv --strip-components=1 \
    && rm ocserv.tar.xz* \
    && cd /usr/src/ocserv \
    && ./configure \
    && make \
    && make install \
    && cd / \
    && rm -rf /usr/src/ocserv \
    && runDeps="$( \
            scanelf --needed --nobanner /usr/local/sbin/ocserv \
                | awk '{ gsub(/,/, "\nso:", $2); print "so:" $2 }' \
                | xargs -r apk info --installed \
                | sort -u \
            )" \
    && apk add --update --virtual .run-deps $runDeps gnutls-utils iptables \
    && apk del .build-deps \
    && rm -rf /var/cache/apk/* 
    
RUN apk add --update bash rsync ipcalc sipcalc ca-certificates rsyslog logrotate runit \
    && rm -rf /var/cache/apk/* 

RUN apk add nginx supervisor nginx-mod-stream openssl libseccomp lz4 lz4-dev

RUN echo -e "load_module '/usr/lib/nginx/modules/ngx_stream_module.so';\n\
worker_processes  1;\n\
events {\n\
    worker_connections  1024;\n\
}\n\
stream {\n\
    # map $ssl_preread_server_name $backend {\n\
    #     default ocserv_backend;\n\
    #     51.15.81.76 web_backend;\n\
    # }\n\
    upstream ocserv_backend {\n\
        server 127.0.0.1:4443;\n\
    }\n\
    upstream web_backend {\n\
        server 127.0.0.1:8443;\n\
    }\n\
    server {\n\
        listen 443 ssl;\n\
        ssl_preread on;\n\
        proxy_pass ocserv_backend;\n\
    }\n\
}" > /etc/nginx/nginx.conf


COPY nginx-supervisor.ini /etc/supervisor.d/nginx-supervisor.ini
COPY ocsrv-supervisor.ini /etc/supervisor.d/ocsrv-supervisor.ini
COPY create-user /config/create-user

RUN update-ca-certificates

ADD ocserv /etc/default/ocserv

WORKDIR /config

COPY docker-entrypoint.sh /entrypoint.sh
ENTRYPOINT ["/entrypoint.sh"]

EXPOSE 4443
EXPOSE 4443/udp

CMD ["/usr/bin/supervisord", "-n", "-c", "/etc/supervisord.conf"]
