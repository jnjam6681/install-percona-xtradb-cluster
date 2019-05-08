#!/bin/bash

# set name cluster
PXC_NAME="pxc1"

# add percona repository
echo "add percona repository"
wget https://repo.percona.com/apt/percona-release_latest.$(lsb_release -sc)_all.deb
sudo dpkg -i percona-release_latest.$(lsb_release -sc)_all.deb

# wget https://repo.percona.com/apt/percona-release_0.1-6.$(lsb_release -sc)_all.deb
# dpkg -i percona-release_0.1-6.$(lsb_release -sc)_all.deb

# install percona xtradb cluster
sudo apt-get update
sudo apt-get -y install percona-xtradb-cluster-57
sudo service mysql stop
echo "------------------------------------------"

# configure replication settings
echo "configure replication settings"
cat >> /etc/mysql/my.cnf << EOF
[mysqld]
server_id=1
binlog_format=ROW
log_bin=mysql-bin
wsrep_cluster_address=gcomm://
wsrep_provider=/usr/lib/libgalera_smm.so
datadir=/var/lib/mysql

wsrep_slave_threads=2
wsrep_cluster_name=pxc-cluster
wsrep_sst_method=xtrabackup-v2
wsrep_sst_auth=sstuser:passw0rd
wsrep_node_name=${PXC_NAME}

log_slave_updates

innodb_autoinc_lock_mode=2
innodb_buffer_pool_size=400M
innodb_log_file_size=64M
EOF
echo "settings /etc/mysql/my.cnf success."
echo "------------------------------------------"

# bootstrap the first node
echo "bootstrap the first node"
/etc/init.d/mysql bootstrap-pxc
echo "bootstrap the first node success."
echo "------------------------------------------"

# create replication user
echo "create replication user"
mysql -uroot -p -e "CREATE USER 'sstuser'@'localhost' IDENTIFIED BY 'passw0rd'"
mysql -uroot -p -e "GRANT RELOAD, LOCK TABLES, PROCESS, REPLICATION CLIENT ON *.* TO 'sstuser'@'localhost'"
mysql -uroot -p -e "FLUSH PRIVILEGES"
echo "create replication user success."
echo "------------------------------------------"
