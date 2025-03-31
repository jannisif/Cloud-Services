# Betriebshandbuch (BHB) - Paperless-ngx Cloud Services

## 1. Kurzbeschreibung
Paperless-ngx ist ein Dokumentenmangagementsystem, welches auf Docker aufsetzt und OpenSource ist. Dabei werden im Hintergrund mithilfe von GlusterFS und pgpool-2 die verschiedenen Instanzen synchron und konsistent gehalten. Eine zusätzliche Management-Instanz kümmert sich sowohl um das Monitoring mithilfe von Prometheus/Grafana als auch um das Backup mittels Borg. Perspektivisch planen wir, auch das Logging durch Loki umzusetzen.
Dieses Konstrukt wird mithilfe von Terraform auf OpenStack deployt und wird anhand Bash-Skripten konfiguriert. Dabei können die Paperless-NGX Instanzen zumindest manuell skaliert werden.


## 2. Beteiligte und Zuständigkeiten

| Name  | Vorname | E-Mail  | Zuständigkeit | Vertretung |
|-------|---------|---------|--------------|------------|
| Naik | Atharva Kishor | atharva-kishor.naik@informatik.hs-fulda.de | Doku BHB, Monitoring, Backup | Jannis Fingerhut |
| Fingerhut | Jannis | jannis.fingerhut@informatik.hs-fulda.de | Administration, Konfiguration, Doku BHB| Atharva Kishor Naik |


## 3. Architektur

![Architektur](DiagrammArchitektur.drawio.png)

Das aufgeführte System umfasst:
- OpenStack-Netzwerkumgebung mit Sicherheitsgruppen, einem Router und Floating IPs
- 3 Worker-Instanzen mit Paperless-ngx über Docker und GlusterFS für Hochverfügbarkeit
- 1 Management-Instanz für Backup und Monitoring


## 4. Bereitstellung der Server über Terraform

### Vorbereitung:
- Zugang(-sdaten) zu einer OpenStack-Instanz
- Terraform installiert
- Optional: VSCode mit HashiCorp Terraform Add-On

### Bereitstellung und Konfiguration:
1. Klonen des [Github-Repository](https://github.com/jannisif/Cloud-Services)
2. Eintragen der eigenen Zugangsdaten zur OpenStack-Instanz
3. Anpassen der Skripte und Instanzen an persönliche Bedürfnisse/Präferenzen
	- insbesondere die `docker-compose.env`für Paperless-ngx
    - feste IP-Adressen für jede Instanz vergeben und im Script anpassen!
    - Sicherheitsgruppen erlauben nur notwendige Ports (z.B. `8000` für Paperless-NGX, `22` für SSH)
    - Updateintervall
    - Backupeinstellungen (in Kapitel 9 erläutert)
4. `terraform init` und `terraform apply` ausführen
5. Warten und die aufgerufenen IP-Adressen im Terminal in den Browser eingeben
6. Zugriff auf Instanzen für Fehleranalyse: Via SSH kann auf die Management-Instanz zugegriffen werden, der SSH-Key findet sich unter: VERZEICHNIS ANGEBEN
7. Zum Zerstören: `terraform destroy`.  ACHTUNG, hierbei werden alle Daten sowie nicht explizit extern gesicherte Backups gelöscht!

### Abhängigkeiten:
Es sollten die aktuellsten Versionen der jeweiligen Dienste verwendet werden können, da sie untereinander wenig komplexe Interaktionen besitzen. Weitere Infos in Kapitel Wartungsaufgaben!


## 5. Skalierung und Ausfallsicherheit
Wenn dauerhaft Leistung fehlt, sollte über zusätzliche oder stärkere/größere Paperless-ngx Instanzen nachgedacht werden. Diese können per Update der Terraform File bereitgestellt werden. Dazu müssen die Instanzen in `Instances.tf` modifiziert werden und in den Skripten vor allem die Synchronisationsprozesse bearbeitet werden.
Die Hochverfügbarkeit wird im aktuellen Zustand dateibasiert auf verteilten Instanzen via GlusterFS gewährleistet. GlusterFS läuft als Dienst im Hintergrund und synchronisiert die Daten (Dokumente) aller Instanzen. 
Leider fehlt bei uns die Implementierung von `pgpool-II`, welches auch die Datenbanken zwischen den Instanzen synchron halten würde. 

## 6. Monitoring / Überwachung / Logging

Das Monitoring-System basiert auf Prometheus, Node Exporter und Grafana, wobei Prometheus als zentrales Element kontinuierlich Werte von Paperless-ngx (über den entsprechenden Exporter) und von den Nodes (über Node Exporter) sammelt, um Systemzustände wie CPU-Auslastung, RAM-Verbrauch und Speichernutzung zu erfassen; diese Daten werden anschließend von Grafana in übersichtlichen Dashboards visualisiert, was es ermöglicht, die Performance und Stabilität des gesamten Systems zu überwachen und bei  Problemen Maßnahmen einzuleiten.


## 7. Wartungsaufgaben und Abhängigkeiten
Es sollten die aktuellsten Versionen der jeweiligen Dienste verwendet werden können, da sie untereinander wenig komplexe Interaktionen besitzen.
Jedoch kann es sein, dass in einer späteren Version z.B. sich ein bestimmtes Format zum Monitoring ändert, dort entweder eine ältere Version verwenden oder im Script anpassen. **Bitte daher vor Updates vor allem bei Paperless-ngx auf eventuelle Breaking Changes informieren!**
Die Updates werden per CronJob angelegt und können individuell angepasst werden. 
Konfigurierter Plan:
-  Einmal pro Woche: `apt update && apt upgrade -y`
-  Einmal pro Monat: `apt autoremove -y && apt clean`

Bitte auch die Funktionsfähigkeit des Backups prüfen mittels: `borg check --repository /backup/repo`


## 8. Fehlerbehebung

Wenn keine der 4 Instanzen erreichbar sein sollte, dann bitte zuerst die Logs im OpenStack prüfen unter DATA EINSETZEN …  . 
Wenn keine Paperless-ngx-Instanz erreichbar ist, bitte mit SSH einloggen (beschrieben in 4. Absatz Punkt 6) und mit dem Befehl `docker ps` prüfen, ob Container laufen. 

Wenn Logs prüfen mit: `journalctl -p 3 -xb` 
...
Work in Progress!
...
- **Langsame Services:** Prometheus-Metriken überprüfen und Maßnahmen ergreifen





## 9. Backup und Restore
Mittels Borg wird ein Backup erstellt und in DATA EINSETZEN gesichert. Es können(sollten) aber auch externe Backups gemacht werden, dieses Ziel bitte in die DATA EINsetzen eintragen. Außerdem wird mit dem Tool  `pg_dump` ein sauberes Abbild der Datenbank gemacht und ebenfalls in das Backup aufgenommen.

Vorkonfigurierter Plan:
- Stündlich inkrementelles Backup
- Täglich einmal volles Backup
- Alle Backups werden zwei Wochen aufbewahrt

Hinweis: bitte noch ein anderes Backup auf ein externes Ziel setzen, wenn die Dokumente (dauerhaft) erhalten bleiben sollen! Ebenfalls sollte ein Archivierungstool eingesetzt werden, dies ist vor allem bei Dokumenten unerlässlich, da z.B. gesetzliche Aufbewahrungsfristen einzuhalten sind.


## 10. Benutzergruppen
Paperless-NGX unterstützt SSO-Dienste und kann dementsprechend auch in größeren Firmen eingesetzt werden. Dies wird hier nicht umgesetzt. 
Standardmäßig wird über die Docker-compose ein Admin-Zugang für Paperless-NGX angelegt. Normale Endnutzer können manuell über den Admin-Zugang angelegt werden und den entsprechenden Rechten oder Gruppen zugeteilt werden. 
 Für den Zugriff auf den Grafana/Prometheus werden die DATEN EINSETZEN verwendet.
