#!/bin/bash

#####################################################################################
#                                                                                   #
#   + please enter you server before restart service                                #
#   + set ip addres under backend pxc-back and backend pxc-onenode-back             #
# backend pxc-back :                                                                #
#     server pxc2 192.168.1.2:3306 check port 9200 inter 12000 rise 3 fall 3        #
#                                                                                   #
# backend pxc-onenode-back :                                                        #
#     server pxc2 192.168.1.2:3306 check port 9200 inter 12000 rise 3 fall 3 backup #
#                                                                                   #
#####################################################################################

# install haproxy
sudo apt-get update
sudo apt-get -y install haproxy
echo "------------------------------------------"

# configure haproxy
echo "configure haproxy"
cat << EOF > /etc/haproxy/haproxy.cfg
global
        log /dev/log    local0
        log /dev/log    local1 notice
        chroot /var/lib/haproxy
#       stats socket /run/haproxy/admin.sock mode 660 level admin expose-fd listeners
        stats timeout 30s
        user haproxy
        group haproxy
        daemon
        # Default SSL material locations
        ca-base /etc/ssl/certs
        crt-base /etc/ssl/private
        # Default ciphers to use on SSL-enabled listening sockets.
        # For more information, see ciphers(1SSL). This list is from:
        #  https://hynek.me/articles/hardening-your-web-servers-ssl-ciphers/
        # An alternative list with additional directives can be obtained from
        #  https://mozilla.github.io/server-side-tls/ssl-config-generator/?server=haproxy
        ssl-default-bind-ciphers ECDH+AESGCM:DH+AESGCM:ECDH+AES256:DH+AES256:ECDH+AES128:DH+AES:RSA+AESGCM:RSA+AES:!aNULL:!MD5:!DSS
        ssl-default-bind-options no-sslv3
defaults
        log     global
        mode    http
        option  httplog
        option  tcplog
        option  dontlognull
        retries 3
        option  redispatch
        timeout connect 5000
        timeout client  50000
        timeout server  50000
        errorfile 400 /etc/haproxy/errors/400.http
        errorfile 403 /etc/haproxy/errors/403.http
        errorfile 408 /etc/haproxy/errors/408.http
        errorfile 500 /etc/haproxy/errors/500.http
        errorfile 502 /etc/haproxy/errors/502.http
        errorfile 503 /etc/haproxy/errors/503.http
        errorfile 504 /etc/haproxy/errors/504.http
frontend pxc-front
        bind *:3307
        mode tcp
        default_backend pxc-back
frontend stats-front
        bind *:80
        mode http
        default_backend stats-back
frontend pxc-onenode-front
        bind *:3306
        mode tcp
        default_backend pxc-onenode-back
backend pxc-back
        mode tcp
        balance leastconn
        option httpchk
        server pxc1 192.168.1.1:3306 check port 9200 inter 12000 rise 3 fall 3
        server pxc2 192.168.1.2:3306 check port 9200 inter 12000 rise 3 fall 3
backend stats-back
        mode http
        balance roundrobin
        stats uri /haproxy/stats
        stats auth pxcstats:secret
backend pxc-onenode-back
        mode tcp
        balance leastconn
        option httpchk
        server pxc1 192.168.1.1:3306 check port 9200 inter 12000 rise 3 fall 3
        server pxc2 192.168.1.2:3306 check port 9200 inter 12000 rise 3 fall 3 backup
EOF
echo "configure haproxy success."
echo "------------------------------------------"

# restart haproxy
echo "restart haproxy"
service haproxy restart
echo "------------------------------------------"
