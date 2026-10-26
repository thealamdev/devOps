#!/bin/bash
#update apt(application package tools)
apt update

#install mariadb, git & curl
apt install -y mariadb-server
apt install -y git
apt install -y curl

#configure database:

cat > configure-db.sql <<-EOF CREATE DATABASE ecomdb; CREATE USER 'ecomuser'@'localhost' IDENTIFIED BY 'ecompassword'; GRANT ALL PRIVILEGES ON *.* TO 'ecomuser'@'localhost'; FLUSH PRIVILEGES; EOF

# run database create command
mysql < configure-db.sql

#create database table & insert data
cat > db-load-script.sql <<-EOF
USE ecomdb;
CREATE TABLE products (id mediumint(8) unsigned NOT NULL auto_increment,Name varchar(255) default NULL,Price varchar(255) default NULL, ImageUrl varchar(255) default NULL,PRIMARY KEY (id)) AUTO_INCREMENT=1;

INSERT INTO products (Name,Price,ImageUrl) VALUES ("Apple","100","c-1.png"),("Orange","200","c-2.png"),("Lemon","300","c-3.png"),("Potato","50","c-5.png"),("Fish","90","c-6.png"),("Chicken","20","c-7.png"),("Beef","80","c-8.png"),("Apple","150","c-4.png");

EOF

# execute database command:
mysql < db-load-script.sql

# install php and apache server

apt  install -y apache2 php php-mysql

#start all services:

service mariadb start
service apache2 start

# remove current setup (of apache) default
rm -fr /var/www/html/
#install new project form git
git clone https://github.com/rajivsiddiqui/project-7-shell-script.git /var/www/html

# run the project
curl http://localhost