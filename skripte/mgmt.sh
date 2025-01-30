#!/bin/bash

echo "Starting setup for Prometheus & Grafana monitoring..."

# Update package lists
apt update

# Install dependencies
apt install -y wget unzip curl

###############################################################################
# Install Prometheus
###############################################################################
echo "Installing Prometheus..."
wget https://github.com/prometheus/prometheus/releases/latest/download/prometheus-linux-amd64.tar.gz
tar xvf prometheus-linux-amd64.tar.gz
sudo mv prometheus-linux-amd64/prometheus /usr/local/bin/
sudo mv prometheus-linux-amd64/promtool /usr/local/bin/
sudo mkdir -p /etc/prometheus /var/lib/prometheus
sudo mv prometheus-linux-amd64/consoles /etc/prometheus
sudo mv prometheus-linux-amd64/console_libraries /etc/prometheus

# Create Prometheus config
cat <<EOF | sudo tee /etc/prometheus/prometheus.yml
global:
  scrape_interval: 15s

scrape_configs:

  # System Metrics from Node Exporter
  - job_name: 'node_exporter'
    static_configs:
      - targets: ['node1:9100', 'node2:9100', 'node3:9100']


  # PostgreSQL Metrics (Database Performance)
  - job_name: 'postgres_exporter'
    static_configs:
      - targets: ['node1:9187']  # PostgreSQL Exporter runs on port 9187
EOF

# Create a Prometheus systemd service
cat <<EOF | sudo tee /etc/systemd/system/prometheus.service
[Unit]
Description=Prometheus
Wants=network-online.target
After=network-online.target

[Service]
User=root
ExecStart=/usr/local/bin/prometheus --config.file=/etc/prometheus/prometheus.yml --storage.tsdb.path=/var/lib/prometheus/
Restart=always

[Install]
WantedBy=multi-user.target
EOF

# Enable and start Prometheus
sudo systemctl daemon-reload
sudo systemctl enable prometheus
sudo systemctl start prometheus
echo "Prometheus setup complete."

###############################################################################
# Install Grafana
###############################################################################
echo "Installing Grafana..."
sudo apt install -y grafana
sudo systemctl enable grafana-server
sudo systemctl start grafana-server
echo "Grafana setup complete."

###############################################################################
# Verify Services
###############################################################################
echo "Checking service status..."
sudo systemctl status prometheus --no-pager
sudo systemctl status grafana-server --no-pager

echo "Setup complete! Access Prometheus at http://<mgmt-instance-ip>:9090 and Grafana at http://<mgmt-instance-ip>:3000"




