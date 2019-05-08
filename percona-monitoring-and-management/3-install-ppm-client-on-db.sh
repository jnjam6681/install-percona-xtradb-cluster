#!/bin/bash

# set ip address pmm server
PMM_SERVER="192.168.1.10"

# set username password database
DB_USERNAME="root"
DB_PASSWORD="root"

# install pmm client
echo "install pmm client"
wget https://www.percona.com/downloads/pmm/1.17.1/binary/debian/$(lsb_release -sc)/x86_64/pmm-client_1.17.1-1.$(lsb_release -sc)_amd64.deb
sudo dpkg -i pmm-client_1.17.1-1.$(lsb_release -sc)_amd64.deb
echo "install success."
echo "------------------------------------------"

# config pmm client to pmm server
echo "configuration to pmm server"
pmm-admin config --server ${PMM_SERVER}
pmm-admin add mysql --user ${DB_USERNAME} --password ${DB_PASSWORD}
echo "setting success."
echo "------------------------------------------"

# add socket
echo "add socket"
pmm-admin add mysql --user ${DB_USERNAME} --password ${DB_PASSWORD} --socket=/var/run/mysqld/mysqld.sock
echo "add socket success."
echo "------------------------------------------"

# start metrics
echo "start matrics"
pmm-admin start linux:metrics
echo "success."
echo "------------------------------------------"

# list and check
echo "list and check"
pmm-admin list
pmm-admin check-network
echo "------------------------------------------"
