#!bin/bash
# 创建好目录
mkdir -p /root/applications/nginx/conf/conf.d
mkdir -p /root/applications/nginx/logs
mkdir -p /root/applications/nginx/html
mkdir -p /root/applications/nginx/socket
mkdir -p /root/scripts/docker-compose
# 创建docker-compose文件
tee /root/scripts/docker-compose/nginx.yml <<-'EOF'
version: '3'
services:
    nginx:
        # 容器名称
        container_name: "nginx"
        image: nginx:1.20.0
        # 端口映射
        ports:
            - "80:80"
        environment:
            - TZ=Asia/Shanghai
        restart: always
        # 数据卷
        volumes:
            # 映射主机./conf.d目录到容器/etc/nginx/conf.d目录
            - "/root/applications/nginx/conf/conf.d/:/etc/nginx/conf.d/"
            - "/root/applications/nginx/conf/nginx.conf:/etc/nginx/nginx.conf"
            - "/root/applications/nginx/html/:/usr/share/nginx/html/"
            - "/root/applications/nginx/logs/:/var/log/nginx/"
            - "/root/applications/nginx/socket/:/usr/share/socket"
EOF
# 创建基本配置文件
tee /root/applications/nginx/conf/nginx.conf <<-'EOF'
user  nginx;
worker_processes  auto;

error_log  /var/log/nginx/error.log notice;
pid        /var/run/nginx.pid;

events {
    use                 epoll;
    worker_connections  1024;
}

http {
    server_tokens off;
    include       /etc/nginx/mime.types;
    default_type  application/octet-stream;

    log_format  main  '$remote_addr - $remote_user [$time_local] "$request" '
                      '$status $body_bytes_sent "$http_referer" '
                      '"$http_user_agent" "$http_x_forwarded_for"';

    access_log  /var/log/nginx/access.log  main;

    sendfile        on;
    #tcp_nopush     on;

    keepalive_timeout  65;

    gzip  on;

    include /etc/nginx/conf.d/*.conf;
}
EOF
# 启动容器 -p nginx 指定启动标识-docker-compose的标识
docker-compose -f /root/scripts/docker-compose/nginx.yml -p nginx up -d
# 添加重启脚本
tee /root/scripts/docker-compose/restart-nginx.sh <<-'EOF'
#!bin/bash
docker-compose -f /root/scripts/docker-compose/nginx.yml -p nginx down
docker-compose -f /root/scripts/docker-compose/nginx.yml -p nginx up -d
EOF
