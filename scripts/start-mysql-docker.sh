#!bin/bash
# 创建好目录
mkdir -p /root/applications/mysql/conf/conf.d
mkdir -p /root/applications/mysql/logs
mkdir -p /root/applications/mysql/datas
mkdir -p /root/scripts/docker-compose
# 创建docker-compose文件
tee /root/scripts/docker-compose/mysql.yml <<-'EOF'
version: '3'
services:
    mysql:
        image: mysql:8.0.24
        ports:
            - "3306:3306"
        volumes:
            - "/root/applications/mysql/datas/:/var/lib/mysql/"
            - "/root/applications/mysql/conf/conf.d/:/etc/mysql/conf.d/"
            - "/root/applications/mysql/logs/:/var/log/mysql/"
        restart: always
        # 环境变量
        environment:
            - TZ=Asia/Shanghai # 设置时区
            # mysql密码
            - MYSQL_ROOT_PASSWORD=kLYSE*XbFAu3RN6l
        container_name: "mysql8"
EOF
# 创建基本配置文件
tee /root/applications/mysql/conf/conf.d/docker.cnf <<-'EOF'
[mysqld]
skip-host-cache
skip-name-resolve
}
EOF
tee /root/applications/mysql/conf/conf.d/mysql.cnf <<-'EOF'
# Copyright (c) 2015, 2021, Oracle and/or its affiliates.
#
# This program is free software; you can redistribute it and/or modify
# it under the terms of the GNU General Public License, version 2.0,
# as published by the Free Software Foundation.
#
# This program is also distributed with certain software (including
# but not limited to OpenSSL) that is licensed under separate terms,
# as designated in a particular file or component or in included license
# documentation.  The authors of MySQL hereby grant you an additional
# permission to link the program and your derivative works with the
# separately licensed software that they have included with MySQL.
#
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License, version 2.0, for more details.
#
# You should have received a copy of the GNU General Public License
# along with this program; if not, write to the Free Software
# Foundation, Inc., 51 Franklin St, Fifth Floor, Boston, MA 02110-1301  USA

#
# The MySQL  Client configuration file.
#
# For explanations see
# http://dev.mysql.com/doc/mysql/en/server-system-variables.html

[client]
default-character-set = utf8mb4
[mysql]
default-character-set = utf8mb4
[mysqld]
character-set-client-handshake = FALSE
character-set-server = utf8mb4
collation-server = utf8mb4_unicode_ci
init_connect='SET NAMES utf8mb4'
}
EOF
# 启动容器 -p mysql 指定启动标识-docker-compose的标识
docker-compose -f /root/scripts/docker-compose/mysql.yml -p mysql up -d
