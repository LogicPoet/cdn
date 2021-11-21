#!bin/bash
# 创建好目录
mkdir -p /root/applications/openresty/conf/conf.d
mkdir -p /root/applications/openresty/logs
mkdir -p /root/applications/openresty/socket
mkdir -p /root/scripts/docker-compose
# 创建docker-compose文件
tee /root/scripts/docker-compose/openresty.yml <<-'EOF'
version: '3'
services:
    nginx:
        # 容器名称
        container_name: "openresty"
        image: openresty/openresty:1.19.9.1-3-alpine-fat
        # 端口映射
        ports:
            - "80:80"
        environment:
            - TZ=Asia/Shanghai
        restart: always
        # 数据卷
        volumes:
            # 映射主机./conf.d目录到容器/etc/nginx/conf.d目录
            - "/root/applications/openresty/conf/nginx.conf:/usr/local/openresty/nginx/conf/nginx.conf"
            - "/root/applications/openresty/conf/conf.d/:/etc/nginx/conf.d/"
            - "/root/applications/openresty/logs/:/var/log/nginx/"
            - "/root/applications/openresty/socket/:/usr/share/socket"
EOF
# 创建配置文件
tee /root/applications/openresty/conf/nginx.conf <<-'EOF'
# nginx.conf  --  docker-openresty
#
# This file is installed to:
#   `/usr/local/openresty/nginx/conf/nginx.conf`
# and is the file loaded by nginx at startup,
# unless the user specifies otherwise.
#
# It tracks the upstream OpenResty's `nginx.conf`, but removes the `server`
# section and adds this directive:
#     `include /etc/nginx/conf.d/*.conf;`
#
# The `docker-openresty` file `nginx.vh.default.conf` is copied to
# `/etc/nginx/conf.d/default.conf`.  It contains the `server section
# of the upstream `nginx.conf`.
#
# See https://github.com/openresty/docker-openresty/blob/master/README.md#nginx-config-files
#

#user  nobody;
#worker_processes 1;

# Enables the use of JIT for regular expressions to speed-up their processing.
pcre_jit on;



#error_log  logs/error.log;
#error_log  logs/error.log  notice;
#error_log  logs/error.log  info;

#pid        logs/nginx.pid;


events {
    worker_connections  1024;
}


http {
    include       mime.types;
    default_type  application/octet-stream;

    # Enables or disables the use of underscores in client request header fields.
    # When the use of underscores is disabled, request header fields whose names contain underscores are marked as invalid and become subject to the ignore_invalid_headers directive.
    # underscores_in_headers off;

    #log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
    #                  '$status $body_bytes_sent "$http_referer" '
    #                  '"$http_user_agent" "$http_x_forwarded_for"';

    #access_log  logs/access.log  main;

        # Log in JSON Format
        # log_format nginxlog_json escape=json '{ "timestamp": "$time_iso8601", '
        # '"remote_addr": "$remote_addr", '
        #  '"body_bytes_sent": $body_bytes_sent, '
        #  '"request_time": $request_time, '
        #  '"response_status": $status, '
        #  '"request": "$request", '
        #  '"request_method": "$request_method", '
        #  '"host": "$host",'
        #  '"upstream_addr": "$upstream_addr",'
        #  '"http_x_forwarded_for": "$http_x_forwarded_for",'
        #  '"http_referrer": "$http_referer", '
        #  '"http_user_agent": "$http_user_agent", '
        #  '"http_version": "$server_protocol", '
        #  '"nginx_access": true }';
        # access_log /dev/stdout nginxlog_json;

    # See Move default writable paths to a dedicated directory (#119)
    # https://github.com/openresty/docker-openresty/issues/119
    client_body_temp_path /var/run/openresty/nginx-client-body;
    proxy_temp_path       /var/run/openresty/nginx-proxy;
    fastcgi_temp_path     /var/run/openresty/nginx-fastcgi;
    uwsgi_temp_path       /var/run/openresty/nginx-uwsgi;
    scgi_temp_path        /var/run/openresty/nginx-scgi;

    sendfile        on;
    #tcp_nopush     on;

    #keepalive_timeout  0;
    keepalive_timeout  65;

    #gzip  on;

    include /etc/nginx/conf.d/*.conf;

    # Don't reveal OpenResty version to clients.
    # server_tokens off;
}
EOF
# 启动容器 -p openresty 指定启动标识-docker-compose的标识
docker-compose -f /root/scripts/docker-compose/openresty.yml -p openresty up -d
# 添加重启脚本
tee /root/scripts/docker-compose/restart-openresty.sh <<-'EOF'
#!bin/bash
docker-compose -f /root/scripts/docker-compose/openresty.yml -p openresty down
docker-compose -f /root/scripts/docker-compose/openresty.yml -p openresty up -d
EOF
