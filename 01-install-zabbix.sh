#!/bin/bash

# ---- 1. Depot officiel Zabbix 7.0 LTS pour Ubuntu 24.04 ----
wget -qO /tmp/zabbix.deb \
    https://repo.zabbix.com/zabbix/7.0/ubuntu/pool/main/z/zabbix-release/zabbix-release_latest_7.0+ubuntu24.04_all.deb
dpkg -i /tmp/zabbix.deb
apt-get update

# ---- 2. Installer les composants Zabbix ----
apt-get install -y \
    zabbix-server-mysql \
    zabbix-frontend-php \
    zabbix-apache-conf \
    zabbix-sql-scripts \
    zabbix-agent2

# ---- 3. Installer MariaDB ----
apt-get install -y mariadb-server
systemctl enable mariadb
systemctl start mariadb

# ---- 4. Creer la base de donnees Zabbix ----
mysql -uroot << 'SQL'
CREATE DATABASE zabbix CHARACTER SET utf8mb4 COLLATE utf8mb4_bin;
CREATE USER 'zabbix'@'localhost' IDENTIFIED BY 'BillU-Zabbix-2025!';
GRANT ALL PRIVILEGES ON zabbix.* TO 'zabbix'@'localhost';
SET GLOBAL log_bin_trust_function_creators = 1;
FLUSH PRIVILEGES;
SQL

echo "[OK] Base de donnees zabbix creee"

# ---- 5. Importer le schema Zabbix ----
echo "Import du schema (peut prendre 2-3 minutes)..."
zcat /usr/share/zabbix-sql-scripts/mysql/server.sql.gz | \
    mysql --default-character-set=utf8mb4 -uzabbix -p'BillU-Zabbix-2025!' zabbix

# Desactiver log_bin apres import
mysql -uroot -e "SET GLOBAL log_bin_trust_function_creators = 0;"

# ---- 6. Configurer Zabbix Server ----
sed -i 's/# DBPassword=/DBPassword=BillU-Zabbix-2025!/' /etc/zabbix/zabbix_server.conf

# ---- 7. Configurer PHP pour Zabbix ----
sed -i 's/# php_value date.timezone Europe\/Riga/php_value date.timezone Europe\/Paris/' \
    /etc/apache2/conf-enabled/zabbix.conf

# ---- 8. Demarrer tous les services ----
systemctl restart zabbix-server zabbix-agent2 apache2
systemctl enable  zabbix-server zabbix-agent2 apache2

echo ""
echo "==========================================="
echo " Zabbix installe"
echo "  Interface : http://172.16.100.22/zabbix"
echo "  Login     : Admin"
echo "  Mot passe : zabbix (a changer apres)"
echo "===========================================" 
