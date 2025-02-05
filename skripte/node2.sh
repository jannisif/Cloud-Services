#!/bin/bash
set -e
###############################################################################
# Set Konfigs
###############################################################################
# Hosts konfigurieren
echo "Konfiguriere /etc/hosts..."
cat <<EOF | sudo tee /etc/hosts
192.168.254.21 node1
192.168.254.22 node2
192.168.254.23 node3
EOF
# Paperless-ngx Configs
echo "Konfiguriere docker-compose.yml Paperless-ngx..."
cat <<EOF > docker-compose.yml
services:
  broker:
    image: docker.io/library/redis:7
    restart: unless-stopped
    volumes:
      - redisdata:/data

  db:
    image: docker.io/library/postgres:16
    restart: unless-stopped
    volumes:
      - /var/lib/postgresql/data
      #- /mnt/paperless/pgdata:/var/lib/postgresql/data
    environment:
      POSTGRES_DB: paperless
      POSTGRES_USER: paperless
      POSTGRES_PASSWORD: paperless

  webserver:
    image: ghcr.io/paperless-ngx/paperless-ngx:latest
    restart: unless-stopped
    depends_on:
      - db
      - broker
    ports:
      - "8000:8000"
      - "5555:5555"
    volumes:
      - /mnt/paperless/data:/usr/src/paperless/data
      - /mnt/paperless/media:/usr/src/paperless/media
      - ./export:/usr/src/paperless/export
      - ./consume:/usr/src/paperless/consume
      - /mnt/paperless/flowerconfig.py:/usr/src/paperless/src/paperless/flowerconfig.py:ro
    env_file: docker-compose.env
    environment:
      PAPERLESS_REDIS: redis://broker:6379
      PAPERLESS_DBHOST: db
      PAPERLESS_ENABLE_FLOWER: "true"
      PAPERLESS_ADMIN_USER: "james"
      PAPERLESS_ADMIN_PASSWORD: "bond"

volumes:
  redisdata:
  pgdata:

EOF
# Docker Compose ENV erstellen
echo "Konfiguriere docker-compose.env Paperless-ngx..."
cat <<EOF > docker-compose.env
###############################################################################
# Paperless-ngx settings                                                      #
###############################################################################

PAPERLESS_OCR_LANGUAGE=eng
PAPERLESS_TIME_ZONE=UTC
EOF
# .env Datei erstellen
echo "Konfiguriere .env Paperless-ngx..."
cat <<EOF > .env
COMPOSE_PROJECT_NAME=paperless
EOF
echo "Erstellung der Konfigurationen abgeschlossen."
###############################################################################
###############################################################################

# Verzeichnisse für GlusterFS erstellen
echo "Erstelle Verzeichnisse für GlusterFS..."
mkdir -p /data/brick

# GlusterFS installieren und starten
echo "Installiere GlusterFS..."
apt update && sudo apt install -y glusterfs-server
systemctl enable --now glusterd

gluster peer status
sleep 5

while ! gluster volume info gv0 &>/dev/null; do
    echo "Warte auf Volume gv0..."
    sleep 5
done

# GlusterFS-Volume mounten
echo "Mounten des GlusterFS-Volumes..."
mkdir -p /mnt/paperless
sudo mount -t glusterfs -o backupvolfile-server=node2 -o backup-volfile-servers=node1 node1:/gv0 /mnt/paperless

# Mounten in /etc/fstab
echo "Konfiguriere persistentes Mounten..."
echo "node1:/gv0 /mnt/paperless glusterfs defaults,_netdev,backup-volfile-servers=node2:node1 0 0" | tee -a /etc/fstab

# Test Mount OK
df -h | grep /mnt/paperless
touch /mnt/paperless/node3
ls /mnt/paperless


# Docker installieren
apt-get update
apt-get install -y curl apt-transport-https ca-certificates software-properties-common
curl -fsSL https://download.docker.com/linux/ubuntu/gpg | sudo gpg --dearmor -o /usr/share/keyrings/docker-archive-keyring.gpg
echo "deb [arch=$(dpkg --print-architecture) signed-by=/usr/share/keyrings/docker-archive-keyring.gpg] https://download.docker.com/linux/ubuntu $(lsb_release -cs) stable" | sudo tee /etc/apt/sources.list.d/docker.list > /dev/null
apt-get update
apt-get install -y docker-ce docker-ce-cli containerd.io
curl -L "https://github.com/docker/compose/releases/download/$(curl -s https://api.github.com/repos/docker/compose/releases/latest | grep tag_name | cut -d '"' -f 4)/docker-compose-$(uname -s)-$(uname -m)" -o /usr/local/bin/docker-compose
chmod +x /usr/local/bin/docker-compose

# Docker- und Compose-Versionen prüfen
docker --version
docker-compose --version
# Benötigte Rechte setzen
chmod -R 755 /mnt/paperless

# Docker-Compose Stack starten
docker-compose up -d

# Logs anzeigen
#docker-compose logs -f paperless

echo "Deploying erfolgreich abgeschlossen!"
