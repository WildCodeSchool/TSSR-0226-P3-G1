## INSTALLATION DE ZABBIX ##

Pour installer Zabbix nous devons commencer par créer un stack LAMP sur notre PC Ubuntu 24.04:

#### Installer MariaDB ####

``sudo apt install mariadb-server mariadb-client -y``

- Pour le lancer au demarrage:

``sudo systemctl start mariadb``

``sudo systemctl enable mariadb``

- Pour vérifier que ça tourne

``sudo systemctl status mariadb``

- Pour sécuriser l'installation

#### Installation de repository ####

- ``wget https://repo.zabbix.com/zabbix/7.4/release/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.4+ubuntu26.04_all.deb``
- ``dpkg -i zabbix-release_latest_7.4+ubuntu26.04_all.deb `` 
- ``apt update   ``

Puis on installe les packets:

``apt install zabbix-server-mysql zabbix-frontend-php zabbix-apache-conf zabbix-sql-scripts zabbix-agent``

Puis on crée la database pour le serveur:
```
mysql -uroot -p

password

mysql> create database zabbix character set utf8mb4 collate utf8mb4_bin;

mysql> create user zabbix@localhost identified by 'password';

mysql> grant all privileges on zabbix.* to zabbix@localhost;

mysql> set global log_bin_trust_function_creators = 1;

mysql> quit;
```
Puis on édite le fichier /etc/zabbix/zabbix_server.conf:

DBPassword=password

On lance les modules apache2:
``
$ a2enmod proxy ; a2enmod proxy_fcgi 
``

Enfin on lance le serveur zabbix et ses agents:

```
systemctl restart zabbix-server zabbix-agent apache2 php8.5-fpm
systemctl enable zabbix-server zabbix-agent apache2 php8.5-fpm
```

On peut desormais lancer l'interface web de Zabbix sur l'adresse: http://172.16.17.17/zabbix 
