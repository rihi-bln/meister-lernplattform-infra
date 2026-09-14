# ⚡🎓 Meister-Lernplattform Elektrotechnik – FFO

Teilprojekt des Digitalisierungsprojekts fuer die Elektromeister-Ausbildung
(Energie- und Gebaeudetechnik) an der **Handwerkskammer Frankfurt (Oder)**.
Ziel: die Kursinhalte einer klassischen Meisterausbildung als quelloffene,
selbst gehostete Lernplattform abbilden 🛠️📚 – Moodle als Kurs- und
Kalender-Zentrale, Anki + Telegram-Bot fuers Lernen unterwegs, und
perspektivisch Paperless-ngx & Co. fuer die vollstaendige Digitalisierung
der Unterlagen.

Dieses Repo ist der Server-Unterbau: **selbst gehostetes Moodle**
(Proxmox LXC 200, `schachtlkiste`) per Bind-Mount-Setup, damit direkt im
Moodle-Quellcode gearbeitet werden kann (eigene Plugins unter
`html/local/`, `html/theme/` etc.), ohne bei jeder Aenderung neu zu bauen.

> Suchst du als Kursteilnehmer:in nur den Zugang zu Moodle, Kalender, Anki
> & Co.? Siehe [README-TEILNEHMENDE.md](./README-TEILNEHMENDE.md).

## Aktueller Stand

_Stand: 2026-09-14_

- ✅ Moodle laeuft: `http://192.168.0.170:8080` (nur im lokalen Netz
  erreichbar, keine oeffentliche IP).
- ✅ Externer Kalender in die Selfhosting-Umgebung eingebunden.
- ✅ Kurs "MA ELO 26V" angelegt, Fach-Struktur aus der Anki-Stapeluebersicht
  (74 Faecher) als Moodle-Abschnitte/Unterabschnitte aufgebaut, inkl. Bezug
  zum offiziellen ZVEH-Rahmenlehrplan (Block + Unterrichtsstunden je Fach,
  Ziel-Beschreibung je Themenfeld) -- Details und Skripte in
  [meister-moodle-content](https://github.com/rihi-bln/meister-moodle-content).
- 🚧 `format_flexsections`-Plugin wird integriert (siehe Struktur-Abschnitt
  unten), um die Fach-Struktur von 2 auf 3 echte Verschachtelungsebenen
  (Teil -> Bereich -> Fach) umzustellen -- Moodles Standard-Unterabschnitte
  erlauben nur eine Ebene.
- 🚧 Ordner-Skelett fuer Lerninhalte je Fach (Anki/Uebungen/Eigene
  Inhalte/Hoerbuch) im Repo `elektro-meister-anki` angelegt; die
  Moodle-seitigen Ordner-Aktivitaeten muessen manuell ergaenzt werden
  (Moodle-Webservice kann nur Unterabschnitte automatisiert erzeugen, siehe
  `ORDNER-VORLAGE.md` in meister-moodle-content).
- 🚧 Kurzer Wiki-Eintrag je Lernfeld mit Rahmenlehrplan-Zielbeschreibung --
  Test von `mod_wiki_new_page` als sauberere Alternative zur aktuellen
  Titel-Anhaengsel-Loesung steht aus.
- ⬜ Kalendereintraege fuer die Faecher uebernehmen/aufbereiten -- offen.
- ⬜ Backup-Routine fuer Moodle (DB + moodledata + html/) einrichten/pruefen
  -- offen.
- 🚧 nginx als Reverse Proxy vor Moodle -- noch offen (siehe TODOs unten).
- 🗓️ Geplant: Uebungsaufgaben- und Anki-Kartengenerierung per Claude API im
  bestehenden Telegram-Bot (`elektro-meister-anki/telegram-bot`), GIFT-Export
  fuer Moodle-Quizfragen, Paperless-ngx fuer digitalisierte Unterlagen.

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
- `setup.sh` -- klont/aktualisiert den Moodle-Core **und** Zusatz-Plugins (eigene Clones je Pfad unter `html/`, siehe `PLUGINS`-Liste im Skript), nicht Teil dieses Repos
- `html/` -- Moodle-Core-Checkout + Plugins (gitignored, eigene Update-Historie via `bash setup.sh`)
- `.env` -- Secrets (gitignored, siehe `.env.example`)

### Zusatz-Plugins (nicht im Moodle-Core enthalten)

| Plugin | Pfad | Zweck |
|---|---|---|
| [format_flexsections](https://github.com/marinaglancy/moodle-format_flexsections) | `html/course/format/flexsections` | Kursformat mit echter, beliebig tiefer Abschnitts-Verschachtelung (Teil -> Bereich -> Fach), loest die 1-Ebenen-Grenze von Moodles Standard-Unterabschnitten |

Neues Plugin hinzufuegen: Eintrag in der `PLUGINS`-Map in `setup.sh`, dann `bash setup.sh` und im Browser **Website-Administration -> Benachrichtigungen** aufrufen (installiert/aktualisiert Plugins in der DB).

## Oekosystem

Das Gesamtprojekt verteilt sich auf mehrere Repos:

| Repo | Zweck |
|---|---|
| `meister-lernplattform-infra` (dieses Repo) | Moodle-Server-Infrastruktur (Docker, DB) |
| [meister-moodle-content](https://github.com/rihi-bln/meister-moodle-content) | Kursstruktur nach Rahmenlehrplan, per Moodle-API eingespielt |
| `elektro-meister-anki` | Anki-Kartensammlung zur Meisterpruefung (Templates je Fach) + Telegram-Bot, der Fragen/Antworten aus dem Kurs-Chat einsammelt und als Kartenvorschlag aufbereitet |
| AnkiCollab-Plugin | Freigabe-Workflow, damit geprüfte Karten ins geteilte Deck gelangen |

Geplant, noch nicht Teil eines Repos: **Paperless-ngx** zur Digitalisierung
von Papierunterlagen/Skripten.

## Sicherheit -- offene TODOs

- Port 8080 ist aktuell auf allen Interfaces offen (noetig, weil nginx ein
  separater Container ist). Spaeter per Proxmox-Firewall auf die nginx-IP
  beschraenken.
- nginx als Reverse Proxy (TLS-Terminierung, ggf. Domain statt IP) ist
  noch nicht eingerichtet.
- SSH-Zugriff wird bewusst erst am Ende des Gesamt-Setups fuer alle
  Container eingerichtet/gehaertet (siehe Proxmox-Infra-Notiz).
