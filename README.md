# Betriebshandbuch (BHB) - Paperless-ngx Cloud Services

## 1. Kurzbeschreibung
Paperless-ngx ist ein Dokumentenmangagementsystem, welches auf Docker aufsetzt und OpenSource ist. Dabei werden im Hintergrund mithilfe von GlusterFS die verschiedenen Instanzen synchron und konsistent gehalten. Eine zusätzliche Management-Instanz kümmert sich sowohl um das Monitoring mithilfe von Prometheus/Grafana als auch um das Backup mittels Borg. Perspektivisch planen wir, auch das Logging durch Loki umzusetzen.
Dieses Konstrukt wird mithilfe von Terraform auf OpenStack deployt und wird anhand von Bash-Skripten konfiguriert. Dabei können die Paperless-ngx Instanzen zumindest manuell skaliert werden. 

Dieses BHB ist für neu einsteigende Administratoren geschrieben, welche Paperless-ngx einzusetzen planen.
Neben einem grundsätzlichen Verständnis von Docker und Linux sollte nach einer intensiven Auseinandersetzung mit dem folgenden Text die Basis für das grundlegende Verständnis und Bearbeitung der Umgebung vorhanden sein.

## 2. Beteiligte und Zuständigkeiten

| Name  | Vorname | E-Mail  | Zuständigkeit | Vertretung |
|-------|---------|---------|--------------|------------|
| Naik | Atharva Kishor | atharva-kishor.naik@informatik.hs-fulda.de | Doku BHB, Monitoring, Backup | Jannis Fingerhut |
| Fingerhut | Jannis | jannis.fingerhut@informatik.hs-fulda.de | Administration, Konfiguration, Doku BHB| Atharva Kishor Naik |


## 3. Architektur

![Architektur](DiagrammArchitektur.drawio.png)

Das aufgeführte System umfasst:
- OpenStack-Netzwerkumgebung mit Sicherheitsgruppen, einem Load Balancer und Floating IPs
- 3 Worker-Instanzen mit Paperless-ngx über Docker und GlusterFS für Hochverfügbarkeit
- 1 Management-Instanz für Backup und Monitoring


## 4. Bereitstellung der Server über Terraforn 

### Vorbereitung:
- Zugang(-sdaten) zu einer OpenStack-Instanz
- git, ssh und Terraform installiert
- Optional: VSCode mit HashiCorp Terraform Add-On

### Bereitstellung und Konfiguration:
1. Klonen des [Github-Repository](https://github.com/jannisif/Cloud-Services)
2. Eintragen der eigenen Zugangsdaten zur OpenStack-Instanz
3. Anpassen der Skripte und Instanzen an persönliche Bedürfnisse/Präferenzen
	- insbesondere die `docker-compose.env`für Paperless-ngx spezifische Einstellungen
    - feste IP-Adressen für jede Instanz vergeben und im Script anpassen!
    - Sicherheitsgruppen erlauben nur notwendige Ports (z.B. `8000` für Paperless-NGX, `22` für SSH)
    - Updateintervall
    - Backupeinstellungen (in Kapitel 9 erläutert)
4. `terraform init` und `terraform apply` ausführen
5. Mit `yes`bestätigen
6. Warten und die aufgerufenen IP-Adressen im Terminal in den Browser eingeben
7. Zugriff auf Instanzen für Fehleranalyse: Via SSH kann auf die Management-Instanz zugegriffen werden, der SSH-Key findet sich unter: /os-trusted-cas
8. Zum Zerstören: `terraform destroy`.  ACHTUNG, hierbei werden alle Daten sowie nicht explizit extern gesicherte Backups gelöscht!

### Abhängigkeiten:

Es werden folgende Dienste genutzt und es sollten die aktuellsten Versionen der jeweiligen Dienste verwendet werden können, da sie untereinander wenig komplexe Interaktionen besitzen. Getestet mit Version:
- [Docker](https://docs.docker.com) v2.34.0
	- [Paperless-ngx mit PostGres](https://docs.paperless-ngx.com) v2.14.7
- [GlusterFS](https://docs.gluster.org/en/latest/) v10
- [Grafana](https://grafana.com/docs/grafana/latest/) v11.6.0 mit [Prometheus](https://prometheus.io/docs/introduction/overview/) v3.3.0
- [pg_dump](https://www.postgresql.org/docs/current/app-pgdump.html)v17
- [Borg](https://borgbackup.readthedocs.io/en/stable/) v1.4

Weitere Infos in Kapitel Wartungsaufgaben!
Folgende Ports müssen für die Kommunikation erlaubt sein und werden in der `secgroup.tf`definiert:
- SSH: 22 (intern/extern)
- Paperless-ngx: 8000 (extern)
- Prometheus: 9090 (extern)
- Grafana: 3000 (extern)
- GlusterFS: 24007-24008 (intern)
- Node Exporter: 9100 (intern)


## 5. Skalierung und Ausfallsicherheit
Wenn konstant Leistung fehlt, sollte zunächst über stärkere/größere Paperless-ngx Instanzen nachgedacht werden. Diese können per Update der Terraform File bereitgestellt werden. Dazu müssen die Instanzen in `Instances.tf` modifiziert, Wenn die höchste Ausstattung nicht mehr ausreicht, muss die Anzahl der Instanzen geändert werden und in den Skripten vor allem die Synchronisationsprozesse bearbeitet werden.
Die Hochverfügbarkeit wird im aktuellen Zustand nur dateibasiert auf verteilten Instanzen via GlusterFS gewährleistet. GlusterFS läuft als Dienst im Hintergrund und synchronisiert die Daten (Dokumente) aller Instanzen. Leider fehlt bei uns aufgrund Problemen die Implementierung von [pgpool-II](https://github.com/pgpool/pgpool2), welches auch die Datenbanken zwischen den Instanzen sauber synchron halten würde. 


## 6. Monitoring / Überwachung / Logging

Das Monitoring wird hauptsächlich durch Prometheus, Grafana und den Node Exportern getragen. Prometheus sammelt als zentrales Element kontinuierlich Werte von Paperless-ngx (über einen Exporter) und von den Nodes (über Node Exporter), um Dokumenten-Statistiken und Systemzustände wie CPU-Auslastung, RAM-Verbrauch und Speichernutzung zu erfassen; diese Daten werden anschließend von Grafana aufbereitet und in übersichtlichen Dashboards visualisiert, was es ermöglicht, die Performance und den Zustand des gesamten Systems zu überwachen und bei Problemen Maßnahmen einzuleiten.
Prometheus ist erreichbar über die am Ende von `terraform apply` ausgegebene oder in OpenStack einsehbare `IP:9090`. Unter Targets sind die Nodes aufgelistet und der jeweilige Status dargestellt. Auch sind Alerts möglich, weitere Infos dazu finden sich in den Prometheus Docs. In Grafana können wahlweise Dashboards (einzelne Übersichtsseiten) individuell zusammengestellt werden oder vorgefertigte Blöcke genutzt werden.
In den Dokumentationen der einzelnen Diensten können spezifische Einstellungsmöglichkeiten eingesehen werden.

## 7. Wartungsaufgaben
**Bitte vor Updates und vor allem bei Paperless-ngx auf eventuelle Breaking Changes informieren!**
Es kann sein, dass in einer späteren Version z.B. sich ein bestimmtes Format zum Monitoring ändert, dort eine ältere Version im Script(Docker-compose) verwenden oder besser diese Änderung im Script anpassen.

Die Updates werden per CronJob angelegt und können individuell angepasst werden oder können manuell ausgeführt werden. 
 
Konfigurierter Plan:
-  Einmal pro Woche: `apt update && apt upgrade -y`
-  Einmal pro Monat: `apt autoremove -y && apt clean`

Bitte auch die Funktionsfähigkeit des Backups auf dem Management-Node prüfen mittels: `borg check --repository /backup/repo` 


## 8. Fehlerbehebung  

Falls keine der vier Instanzen unter den angegebenen IP-Adressen erreichbar sein sollte, bitte folgendermaßen vorgehen:
Zunächst sollten in OpenStack die Stati der Instanzen geprüft werden. Im nächsten Schritt sollten in OpenStack die Logs der einzelnen Instanzen eingesehen werden.
Wenn die Instanzen laufen und online sind, kann auf sie via SSH zugegriffen werden(siehe Abschnitt 4, Punkt 6 für SSH-Zugriff).
Mit dem Befehl `docker ps` prüfen, ob die relevanten Container überhaupt laufen. Falls ein Container nicht aktiv ist, kann mit `docker restart <container_id>` dieser neu gestartet werden. Wenn diese aktiv sind, kann mit `docker logs <container_id>`die Docker-Logs des Containers überprüft werden. 
Wenn die Instanz Probleme aufweist, kann man die Systemmeldungen mit `journalctl -p 3 -xb`aufrufen und diese prüfen nach Dienst-Logs.
Mit `systemctl restart <service>`können auch einzelne Systemdienste und GlusterFS neugestartet werden.
Wenn der Lord Balancer nicht funktioniert bzw immer nur eine Instanz aufgerufen wird, prüfe bitte ob dieser aktiv ist. 

Alles Services laufen, aber fühlen sich nicht schnell an? Dann die Prometheus Metriken analysieren und beobachten, wo das Problem liegt kann.
Wenn die Metriken keinen Aufschluss darüber geben, kann man mit verschiedenen Netzwerkzeugen weitere Nachforschungen anstellen. Passende Werkzeuge sind der `ping`, `netstat`, `curl` aber auch `PromQL` - für PostgreSQL. Diese müssen teilweise nachinstalliert werden, können aber helfen, das Problem einzugrenzen.


## 9. Backup und Restore
Mittels Borg wird ein Backup von einem Nodes erstellt und in Backup gesichert. Es können(sollten) aber auch externe Backups gemacht werden, dieses Ziel bitte in die `mgmt.sh` eintragen. Außerdem wird mit dem Tool  `pg_dump` ein sauberes Abbild der Datenbank gemacht und ebenfalls in das Backup aufgenommen.

Vorkonfigurierter Plan:
- Stündlich inkrementelles Backup
- Täglich einmal volles Backup
- Alle Backups werden zwei Wochen aufbewahrt

Hinweis: bitte noch ein anderes Backup auf ein externes Ziel setzen, wenn die Dokumente (dauerhaft) erhalten bleiben sollen! Ebenfalls sollte ein Archivierungstool eingesetzt werden, dies ist vor allem bei Dokumenten unerlässlich, da z.B. gesetzliche Aufbewahrungsfristen einzuhalten sind.


## 10. Benutzergruppen
Paperless-ngx unterstützt SSO-Dienste und kann dementsprechend auch in größeren Firmen eingesetzt werden. Dies wird hier nicht umgesetzt. 
Standardmäßig wird über die Docker-compose ein Admin-Zugang für Paperless-ngx angelegt. Normale Endnutzer können manuell über den Admin-Zugang angelegt werden und den entsprechenden Rechten oder Gruppen zugeteilt werden. 
 Für den Zugriff auf den Grafana/Prometheus werden die  Zugangsdaten `admin:admin` verwendet, welche natürlich sofort geändert werden sollten.


 ## Ausblick
 
Wie wir schon erwähnt haben, fehlt leider noch `pgpool-II` als essentieller Teil der Installation. Dies sorgt dafür, dass unser Service nicht ganz wie gewünscht läuft, da die Datenbanken zwischen den Paperless-ngx-Instanzen nicht synchron sind. Außerdem wollten wir S3-Speicher als Backup-Ziel einsetzen, dies hat aber ebenfalls nicht geklappt.
Ansonsten können natürlich detaillierte Verbesserungen, wie die Designs der Grafana-Dashboard in Configs mit in die Installation aufgenommen werden oder eine Modifikation der Paperless-ngx Seite, anhand der man erkennt, auf welchem Node man sich befindet. Ein gutes Beispiel ist die Horstl-Seite der HS Fulda, wo unten steht, auf welchem Node man sich gerade befindet. Dies kann zur Fehlerbehebung nützlich sein und auch für Wartungsarbeiten geeignet sein.
Das Thema Backup ist leider zu kurz gekommen, da müsste man alle Nodes sichern. Wir haben jetzt nur den Master Node gesichert.
Wir hätten gerne DNS eingesetzt, mit denen man nicht über schwer zu merkende IP-Adressen die Instanzen im Browser aufruft, sondern über einen einfachen Domain-Namen!

Zusammenfassend können wir sagen, dass wir viel gelernt haben bei diesem teils sehr steinigen Prozess. Vor allem haben wir bemerkt, wie man doch sehr unterschiedliche Services sinnvoll miteinander kombinieren kann. Und super ist: man kann dies bei sich auch im HomeLab anwenden!

