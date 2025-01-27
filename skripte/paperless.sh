#!/bin/bash
###############################################################################
# Für sich alleine zum Testen
###############################################################################


# Docker Compose YML für Paperless-ngx
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
      - pgdata:/var/lib/postgresql/data
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
    volumes:
      - /mnt//data:/usr/src/paperless/data
      - /mnt//media:/usr/src/paperless/media
      - ./export:/usr/src/paperless/export
      - ./consume:/usr/src/paperless/consume
    env_file: docker-compose.env
    environment:
      PAPERLESS_REDIS: redis://broker:6379
      PAPERLESS_DBHOST: db

volumes:
  redisdata:
  pgdata:
EOF

# Docker Compose ENV
cat <<EOF > docker-compose.env
###############################################################################
# Paperless-ngx settings                                                      #
###############################################################################

PAPERLESS_OCR_LANGUAGE=eng
PAPERLESS_TIME_ZONE=UTC
EOF

# .env Datei erstellen
cat <<EOF > .env
COMPOSE_PROJECT_NAME=paperless
EOF

# Docker-Compose Stack starten
echo "Starte Paperless-ngx Docker-Stack..."
sudo docker-compose up -d

echo "Bereitstellung erfolgreich abgeschlossen!"
