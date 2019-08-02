#!/bin/bash

# set name cluster
PXC_NAME="pxc2"

# set ip address
PXC_NODE1="192.168.1.1"
PXC_NODE2="192.168.1.2"
PXC_NODE3="192.168.1.3"

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
wsrep_cluster_address=gcomm://${PXC_NODE1},${PXC_NODE2},${PXC_NODE3}
wsrep_provider=/usr/lib/libgalera_smm.so
datadir=/var/lib/mysql

wsrep_slave_threads=1
wsrep_cluster_name=pxc-cluster
wsrep_sst_method=xtrabackup-v2
wsrep_sst_auth=sstuser:passw0rd
wsrep_node_name=${PXC_NAME}
wsrep_node_address=${PXC_NODE2}

log_slave_updates

pxc_strict_mode=ENFORCING


default_storage_engine=InnoDB
innodb_autoinc_lock_mode=2
# innodb_buffer_pool_size=400M
# innodb_log_file_size=64M
EOF
echo "settings /etc/mysql/my.cnf success."
echo "------------------------------------------"

# start service mysql
echo "start service mysql"
/etc/init.d/mysql start
echo "start service mysql success."
echo "------------------------------------------"
