# Betriebshandbuch (BHB) - Paperless NGX Cloud Services

## 1. Kurzbeschreibung
Paperless-NGX ist ein Dokumentenmangagementsystem, welches auf Docker aufsetzt und OpenSource ist. Dabei werden im Hintergrund mithilfe von GlusterFS und pgpool2  die verschiedenen Instanzen synchron und konsistent gehalten. Eine zusätzliche Management-Instanz kümmert sich sowohl um das Monitoring mithilfe von Prometheus/Grafana als auch um das Backup mittels Borg. Perspektivisch planen wir, auch das Logging durch Loki umzusetzen.
Dieses Konstrukt wird mithilfe von Terraform auf OpenStack deployt und wird anhand eines Shell-Skripts konfiguriert. Dabei sind die Paperless-NGX Instanzen zumindest manuell skalierbar.

## 2. Beteiligte und Zuständigkeiten

| Name  | Vorname | E-Mail  | Zuständigkeit | Vertretung |
|-------|---------|---------|--------------|------------|
| Naik | Atharva Kishor | atharva-kishor.naik@informatik.hs-fulda.de | Administration, Konfiguration  | Jannis Fingerhut |
| Fingerhut | Jannis | jannis.fingerhut@informatik.hs-fulda.de | Doku BHB, Monitoring, Backup  | Atharva Kishor Naik |


## 3. Architektur

![Architektur](DiagrammArchitektur.drawio.png)

Das System umfasst:
- OpenStack-Netzwerkumgebung mit definierten Sicherheitsgruppen und Floating IPs
- 3 Paperless NGX Instanzen inkl. GlusterFS und pgpool2 für Lastverteilung
- 1 Management-Instanz für Backup und Monitoring

## 4. Installation
- Bereitstellung der virtuelle Maschinen über Terraform
- Automatisierte Konfiguration mit Bash-Skripten ( `nodeX.sh`, `mgmt.sh`)

### Vorbereitung
- Zugang(-sdaten) zu einer OpenStack-Instanz
- Terraform installiert
- Optional: VSCode mit HashiCorp Terraform Add-On

### Aufsetzen/Installation:
1. Klonen des Github-Repository
2. Eintragen der Zugangsdaten
3. Anpassen der Skripte und Instanzen an persönliche Präferenzen
4. Terrafom init, terraform apply ausführen
5. Warten und 

## 5. Konfiguration
- Paperless NGX-Umgebungskonfiguration (über `docker-compose.env`).
- Netzwerkkonfiguration mit festen IPs in OpenStack(Notwendigkeit durch Skripte).
- Sicherheitsgruppen erlauben nur notwendige Ports (z.B. `8000` für Paperless-NGX, `22` für SSH).

## 6. Abhängigkeiten
- **Netzwerk:** OpenStack definiert Subnetze und Router.
- **Storage:** PostgreSQL-Datenbank speichert Dokumentendaten.
- **Server:** Virtuelle Maschinen laufen auf OpenStack.

## 7. Monitoring / Überwachung / Logging
- **Prometheus:** Sammelt Metriken von Paperless NGX und den Nodes.
- **Node Exporter:** Systemmetriken (CPU, RAM, Speicher).
- **Grafana:** Visualisierung der Daten mit Dashboards.
- **Logs:** Paperless-Logs befinden sich in `/var/log/paperless/`.

## 8. Wartungsaufgaben
- Wöchentliche Systemupdates (`apt update && apt upgrade -y`).
- Kontrolle der Container-Logs (`docker logs <container>`).
- Überwachung der Metriken und Alerts aus Prometheus.

## 9. Backup / Restore / Failover / Disaster Recovery
- Automatische Backups der PostgreSQL-Datenbank mittels `pg_dump`.
- Dokumenten-Backups auf externem Storage (`/mnt/backup/`).
- Test der Wiederherstellung alle 3 Monate.

## 10. Troubleshooting
- **Paperless NGX nicht erreichbar:** `docker ps` prüfen, ob Container laufen.
- **Hohe CPU-Auslastung:** Prometheus-Metriken überprüfen.
- **Netzwerkprobleme:** `ping nodeX` testen.

## 11. Authentifizierung, Autorisierung, Accounting, Identity Management
- Nutzerverwaltung erfolgt in Paperless NGX.
- Zugriffsschutz durch OpenStack-Sicherheitsgruppen.

## 12. Benutzergruppen und Benachrichtigung
- **Admins:** Vollzugriff auf das System.
- **Benutzer:** Zugriff auf das Paperless-Webinterface.

## 13. Skalierung und Ausfallsicherheit
- Zusätzliche Paperless NGX-Instanzen können per Terraform bereitgestellt werden.
- Hochverfügbarkeit durch verteilte Instanzen auf verschiedene Server.



Kurzbeschreibung
Beteiligte/inkl. Zuständigkeiten/Vertretung ;)
Architektur (Diagramm/Überblick)
Installation (grob)
Konfiguration (eher grob, nur wesentliche Details)
Abhängigkeiten: Netz, Storage, Server …
Monitoring/Überwachung/Logging/Reporting
Trouble Shooting
Wartungsaufgaben (Updates, Abrechnung, Speicherplatz bereitstellen …)
Authentifizierung, Autorisierung, Accounting, Identity Management, Neue Benutzer/Benutzer löschen
Benutzergruppen (z.B. für Benachrichtigung, spezielle Funktionen für PowerUser usw.)
Backup/Restore/Failover/Disaster Recovery/Archiv
Skalierung