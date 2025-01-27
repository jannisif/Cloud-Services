#!/bin/bash
# init

#!/bin/bash

set -e

echo "### System Update und benötigte Pakete installieren ###"
  apt-get update
  apt-get install -y wget curl tar python3-pip docker.io

echo "### Prometheus installieren ###"
PROMETHEUS_VERSION="2.47.0"
cd /opt
wget https://github.com/prometheus/prometheus/releases/download/v${PROMETHEUS_VERSION}/prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz
tar -xvzf prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz
mv prometheus-${PROMETHEUS_VERSION}.linux-amd64 prometheus
rm prometheus-${PROMETHEUS_VERSION}.linux-amd64.tar.gz

echo "### Prometheus als Service einrichten ###"
cat <<EOF |   tee /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus Monitoring
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=root
ExecStart=/opt/prometheus/prometheus --config.file=/opt/prometheus/prometheus.yml --storage.tsdb.path=/opt/prometheus/data
Restart=always

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  systemctl enable prometheus

echo "### Prometheus Node Exporter installieren ###"
NODE_EXPORTER_VERSION="1.6.1"
cd /opt
wget https://github.com/prometheus/node_exporter/releases/download/v${NODE_EXPORTER_VERSION}/node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
tar -xvzf node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz
mv node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64 node_exporter
rm node_exporter-${NODE_EXPORTER_VERSION}.linux-amd64.tar.gz

echo "### Node Exporter als Service einrichten ###"
cat <<EOF |   tee /etc/systemd/system/node_exporter.service
[Unit]
Description=Prometheus Node Exporter
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=root
ExecStart=/opt/node_exporter/node_exporter
Restart=always

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  systemctl enable node_exporter

echo "### GlusterFS Prometheus Exporter installieren ###"
pip3 install glusterfs-prometheus-exporter

echo "### GlusterFS Exporter als Service einrichten ###"
cat <<EOF |   tee /etc/systemd/system/glusterfs_exporter.service
[Unit]
Description=GlusterFS Prometheus Exporter
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=root
ExecStart=/usr/local/bin/glusterfs-prometheus-exporter --port 24007
Restart=always

[Install]
WantedBy=multi-user.target
EOF

  systemctl daemon-reload
  systemctl enable glusterfs_exporter

echo "### Flower Monitoring installieren ###"
pip3 install flower

echo "### Docker Container für Paperless starten ###"
docker run -d --name paperless \
  -e PAPERLESS_ENABLE_FLOWER=1 \
  -p 8000:8000 \
  -p 5555:5555 \
  ghcr.io/paperless-ngx/paperless-ngx:latest

echo "### Prometheus-Konfiguration erstellen ###"
cat <<EOF |   tee /opt/prometheus/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:
  - job_name: "prometheus"
    static_configs:
      - targets: ["localhost:9090"]

  - job_name: "node_exporter"
    static_configs:
      - targets: ["localhost:9100"]

  - job_name: "glusterfs"
    static_configs:
      - targets: ["localhost:24007"]

  - job_name: "flower"
    static_configs:
      - targets: ["localhost:5555"]
EOF

echo "### Alertmanager installieren ###"
ALERTMANAGER_VERSION="0.26.0"
cd /opt
wget https://github.com/prometheus/alertmanager/releases/download/v${ALERTMANAGER_VERSION}/alertmanager-${ALERTMANAGER_VERSION}.linux-amd64.tar.gz
tar -xvzf alertmanager-${ALERTMANAGER_VERSION}.linux-amd64.tar.gz
mv alertmanager-${ALERTMANAGER_VERSION}.linux-amd64 alertmanager
rm alertmanager-${ALERTMANAGER_VERSION}.linux-amd64.tar.gz

echo "### Alertmanager-Konfiguration erstellen ###"
cat <<EOF |   tee /opt/alertmanager/alertmanager.yml
global:
  resolve_timeout: 5m
  smtp_smarthost: 'smtp.example.com:587'
  smtp_from: 'alertmanager@example.com'
  smtp_auth_username: 'username'
  smtp_auth_password: 'password'

route:
  receiver: 'email-alert'

receivers:
  - name: 'email-alert'
    email_configs:
      - to: 'your-email@example.com'
EOF

echo "### Alertmanager als Service einrichten ###"
cat <<EOF |   tee /etc/systemd/system/alertmanager.service
[Unit]
Description=Prometheus Alertmanager
Wants=network-online.target
After=network-online.target

[Service]
Type=simple
User=root
ExecStart=/opt/alertmanager/alertmanager --config.file=/opt/alertmanager/alertmanager.yml
Restart=always

[Install]
WantedBy=multi-user.target
EOF

systemctl daemon-reload
systemctl enable alertmanager

echo "### Prometheus mit Alertmanager verbinden ###"
  sed -i '/scrape_configs:/i \  alerting:\n    alertmanagers:\n      - static_configs:\n          - targets: ["localhost:9093"]\n' /opt/prometheus/prometheus.yml

echo "### Services starten ###"
systemctl start prometheus
systemctl start node_exporter
systemctl start glusterfs_exporter
systemctl start alertmanager

echo "### Fertig! Prometheus und Monitoring laufen. ###"
