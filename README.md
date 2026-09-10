# meister-lernplattform-infra

Runtime-Infrastruktur fuer das selbst gehostete Moodle (Proxmox LXC 200,
`schachtlkiste`). Bind-Mount-Setup, damit direkt im Moodle-Quellcode
gearbeitet werden kann (eigene Plugins unter `html/local/`, `html/theme/`
etc.), ohne bei jeder Aenderung neu zu bauen.

## Setup (in der Proxmox-Browser-Konsole des Containers, kein SSH noetig)

```bash
git clone https://github.com/<dein-user>/meister-lernplattform-infra.git /opt/moodle
cd /opt/moodle
cp .env.example .env
nano .env              # echte Passwoerter eintragen
bash setup.sh           # klont Moodle-Core (LTS) nach html/
docker compose up -d --build
```

Danach im Browser: `http://192.168.0.170:8080/install.php` -- Moodle-
Installationsassistent (DB-Zugangsdaten aus `.env`, Admin-Account anlegen).

## Core-Updates

```bash
bash setup.sh   # macht in html/ ein git pull auf den LTS-Branch
```

## Struktur

- `Dockerfile` -- PHP 8.3 + Apache + Moodle-Extensions, kein Code drin
- `docker-compose.yml` -- MariaDB + Moodle, `html/` und `moodledata` als Volumes
- `setup.sh` -- klont/aktualisiert den Moodle-Core (eigener Clone, nicht Teil dieses Repos)
- `html/` -- Moodle-Core-Checkout (gitignored, eigene Update-Historie via `bash setup.sh`)
- `.env` -- Secrets (gitignored, siehe `.env.example`)

## Sicherheit -- offene TODOs

- Port 8080 ist aktuell auf allen Interfaces offen (noetig, weil nginx ein
  separater Container ist). Spaeter per Proxmox-Firewall auf die nginx-IP
  beschraenken.
- SSH-Zugriff wird bewusst erst am Ende des Gesamt-Setups fuer alle
  Container eingerichtet/gehaertet (siehe Proxmox-Infra-Notiz).
