# minimal Docker image based on Alpine Linux with a complete package index
FROM arm64v8/alpine:3.14

# add new packages or upgrade packages to the running system
RUN \
    # update the index of available packages
    apk update \
    echo "**** install build packages ****" && \
    # add apps w/o cache
    apk add --no-cache \
    # apache utility programs for webservers
    apache2-utils \
    # distributed version control
    git \
    # TLS/crypto stack forked from OpenSSL
    libressl3.3-libssl \
    # runs the postrotate script each time it rotates a log
    logrotate \
    # CLI text editor
    nano \
    # web server
    nginx \
    # software library for applications that secure communications
    openssl \
    # general-purpose scripting language geared toward web development
    php8 \
    # return information about a file
    php8-fileinfo \
    # FastCGI process manager for PHP
    php8-fpm \
    # lightweight data-interchange format
    php8-json \
    # multibyte specific string functions
    php8-mbstring \
    # software library for applications that secure communications
    php8-openssl \
    # a process to store information, which can be used by multiple other pages
    php8-session \
    # easily manipulate and get XML data
    php8-simplexml \
    # text-based format for representing structured information
    php8-xml \
    # writes XML data to a stream, file, text reader, or string
    php8-xmlwriter \
    # data compression
    php8-zlib && \
  echo "**** configure nginx ****" && \
  echo 'fastcgi_param  HTTP_PROXY         ""; # https://httpoxy.org/' >> \
    /etc/nginx/fastcgi_params && \
  echo 'fastcgi_param  PATH_INFO          $fastcgi_path_info; # http://nginx.org/en/docs/http/ngx_http_fastcgi_module.html#fastcgi_split_path_info' >> \
    /etc/nginx/fastcgi_params && \
  echo 'fastcgi_param  SCRIPT_FILENAME    $document_root$fastcgi_script_name; # https://www.nginx.com/resources/wiki/start/topics/examples/phpfcgi/#connecting-nginx-to-php-fpm' >> \
    /etc/nginx/fastcgi_params && \
  rm -f /etc/nginx/http.d/default.conf && \
  echo "**** fix logrotate ****" && \
  sed -i "s#/var/log/messages {}.*# #g" /etc/logrotate.conf && \
  sed -i 's#/usr/sbin/logrotate /etc/logrotate.conf#/usr/sbin/logrotate /etc/logrotate.conf -s /config/log/logrotate.status#g' \
    /etc/periodic/daily/logrotate

# add local files
COPY root/ /

# ports and volumes
EXPOSE 80 443
VOLUME /config

# C standard library
ADD ./hello-world/target/aarch64-unknown-linux-musl/release/hello-world /usr/local/bin/hello-world
# Dockerfile directive or instruction that is used to specify the executable which should run when a container is started
ADD ./docker_entrypoint.sh /usr/local/bin/docker_entrypoint.sh
RUN chmod a+x /usr/local/bin/docker_entrypoint.sh
# check if a website is up or down
ADD ./check-web.sh /usr/local/bin/check-web.sh
RUN chmod +x /usr/local/bin/check-web.sh

WORKDIR /root

EXPOSE 80

ENTRYPOINT ["/usr/local/bin/docker_entrypoint.sh"]