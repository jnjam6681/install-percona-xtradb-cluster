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
wsrep_provider=/usr/lib/libgalera_smm.so

wsrep_cluster_name=pxc-cluster
wsrep_cluster_address=gcomm://${PXC_NODE1},${PXC_NODE2},${PXC_NODE3}

wsrep_node_name=${PXC_NAME}
wsrep_node_address=${PXC_NODE2}

wsrep_sst_method=xtrabackup-v2
wsrep_sst_auth=sstuser:passw0rd

pxc_strict_mode=ENFORCING

binlog_format=ROW
default_storage_engine=InnoDB
innodb_autoinc_lock_mode=2
EOF
echo "settings /etc/mysql/my.cnf success."
echo "------------------------------------------"

# start service mysql
echo "start service mysql"
/etc/init.d/mysql start
echo "start service mysql success."
echo "------------------------------------------"
