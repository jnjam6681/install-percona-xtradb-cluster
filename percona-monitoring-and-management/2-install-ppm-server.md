## Install PPM Server
#### clone dashboard
```
git clone https://github.com/percona/grafana-dashboards.git
```
#### setting volumes
```
volumes:
  - "/opt/prometheus/data"
  - "/opt/consul-data"
  - "/var/lib/mysql"
  - "/var/lib/grafana"
```
### start docker compose
```
docker-compose up -d
```
