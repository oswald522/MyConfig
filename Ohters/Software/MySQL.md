# Mysql And Mariadb 安装教程

## Mysql 安装教程

1. 下载相应的 mysql.zip 文件,[https://dev.mysql.com/downloads/mysql/](https://dev.mysql.com/downloads/mysql/),选择合适的操作系统下载文件
1. 配置文件,保存位置为 $PATH/my.ini$

```ini
[mysql]
# 设置 mysql 客户端默认字符集
default-character-set=utf8
[mysqld]
#设置 3306 端口
port = 3306
# 设置 mysql 的安装目录
basedir=C:\Program Files\mysql-5.7.23-winx64
# 设置 mysql 数据库的数据的存放目录
datadir=C:\Program Files\mysql-5.7.23-winx64\data
# 允许最大连接数
max_connections=200
# 服务端使用的字符集默认为 8 比特编码的 latin1 字符集
character-set-server=utf8
# 创建新表时将使用的默认存储引擎
default-storage-engine=INNODB
```

1. 运行以下命令进行安装
   管理员身份运行 cmd
   2）输入 cd C:\Program Files\mysql\mysql-5.7.27-winx64\bin
   3）输入 mysqld --initialize-insecure --user=mysql
   4）运行后，没有什么提示，但是会发现文件夹下多了个 data 文件夹，即为创建成功

```bash
mysqld --initialize-insecure --user=mysql
mysqld -install
mysqld -remove
net start mysql
mysql -u root -p
ALTER USER 'root'@'localhost' IDENTIFIED BY '123456';
flush privileges;
```

## docker 安装

1. docker 数据库命令操作

```yaml
version: "3"
services:
  mysql:
    image: mysql:latest
    container_name: "mysql_test"
    restart: always
    environment:
      MYSQL_ROOT_PASSWORD: "123456"
      MYSQL_PASSWORD: "123456"
      TZ: "Asia/Shanghai"
    volumes:
      - ./data:/var/lib/mysql
    ports:
      - "5506:3306"
    command: --default-authentication-plugin=mysql_native_password --character-set-server=utf8mb4 --collation-server=utf8mb4_unicode_ci
```

随后需要执行其他命令,`docker-compose up -d`,建立新的数据库`docker exec -it mysql_test mysql -uroot -p`输入配置文件当中定义的密码,建立新的数据库`CREATE DATABASE test_mysql;`

## Windowns 安装 MariaDB（超详细的免安装版配置教程）

1. 下载地址：<https://downloads.mariadb.org/mariadb/>
2. 配置文件,保存位置为 $PATH/my.ini$

```ini
[mysql]
# 设置 mysql 客户端默认字符集
default-character-set=utf8
[mysqld]
#设置 3306 端口
port = 3306
# 设置 mysql 的安装目录
basedir=C:\Program Files\mysql-5.7.23-winx64
# 设置 mysql 数据库的数据的存放目录
datadir=C:\Program Files\mysql-5.7.23-winx64\data
# 允许最大连接数
max_connections=200
# 服务端使用的字符集默认为 8 比特编码的 latin1 字符集
character-set-server=utf8
# 创建新表时将使用的默认存储引擎
default-storage-engine=INNODB
```

3. 运行以下命令进行安装

- 管理员身份运行 cmd
- 输入 cd C:\Program Files\mysql\mysql-5.7.27-winx64\bin
- 输入 `mysql_install_db.exe --datadir=D:\mariadb\data --service=MariaDB --password=123456`
- 启动服务
  - `net start MariaDB`
  - `mysqld --defaults-file=D:\mariadb\database\my.ini --standalone`

## 疑难杂症问题

### MySQL8.0.忘记密码解决报 ERROR 1045 (28000): Access denied for user 'root'@'localhost' (using password: YES)

1. 第一步：关闭服务 `net stop mysql` （管理员权限）
1. 进入到安装的 bin 目录 执行 ：`mysqld --console --skip-grant-tables --shared-memory`
1. 启动一个新的 cmd 窗口 执行 `mysql -uroot -p`
1. 修改密码

```shell
use mysql
update user set authentication_string='' where user='root' #如果这个字段有值，先置为空
flush privileges
ALTER user 'root'@'localhost' IDENTIFIED BY '123456' #修改root 密码
```

在 Ubuntu 安装与配置 MariaDB

gadflysu's Avatar 03/18/2019 database 11695 Views
Share the post

    1. 安装
    2. 安全配置
    3. 创建用户

MariaDB 是流行的关系型数据库管理系统 (RDBMS)，其著名用户有 Wikipedia、WordPress.com 和 Google。在 2009 年 Oracle 收购 Sun Microsystems 之后，后者旗下的开源数据库系统 MySQL 自然归属于（臭名昭著的）Oracle。为规避潜在的闭源风险，MySQL 的创始人 Michael Widenius 及原开发团队创建了一个保证开源的新分支——MariaDB。
安装

## MariaDB 可以从 Ubuntu 的官方软件源安装：

```shell
sudo apt install mariadb-server
sudo mysql_secure_installation
```

从前文的背景简述可知，MariaDB 兼容 MySQL，毕竟……/usr/bin/mariadb 就是 /usr/bin/mysql 的软链接。

要检查软件版本，执行：

> `➜ ~ mysql --version`

> `mysql Ver 15.1 Distrib 10.1.38-MariaDB, for debian-linux-gnu (x86_64) using readline 5.2`

本文将在上示环境和软件版本下进行。

MariaDB 服务：

```shell
sudo systemctl start mysql
sudo systemctl status mysql
```

安全配置:安装完成后建议首先用软件自带的一个脚本执行初始的安全配置：

1. 创建用户

```shell
sudo mysql -u root -p  #连接数据库
create user 'test'@'localhost' identified by 'lianxi'; #创建新用户
grant all privileges on *.* to 'test'@'localhost'; #赋予权限
mysql -u root -p #使用新用户连接数据库，不需要sudo
```
