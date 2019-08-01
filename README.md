## Install Percona XtraDB Cluster
#### Remove AppArmor if you previously had MySQL installed
```
sudo apt-get remove apparmor
```
#### Logging MySQL
```
tail -f /var/log/mysqld.log
```
#### Show status cluster
```
show status like 'wsrep%';
```
#### Get user in database
```
select user,host from mysql.user;
```
#### Remove Percona XtraDB Cluster
```
sudo apt -y remove percona-xtradb*
sudo apt -y purge percona-xtradb*
sudo apt-get -y remove apparmor
sudo apt-get -y autoremove
sudo apt-get autoclean
sudo apt-get remove dbconfig-mysql
rm /etc/apt/sources.list.d/percona-release.list
rm -rf /etc/mysql/my.cnf
rm -rf /var/lib/mysql
```
