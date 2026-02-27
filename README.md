# OpenJabNab

[![Build & Publish Docker Image](https://github.com/ithild1/OpenJabNab/actions/workflows/docker-publish.yml/badge.svg)](https://github.com/ithild1/OpenJabNab/actions/workflows/docker-publish.yml)
[![Docker Hub](https://img.shields.io/docker/pulls/ithild1/openjabnab)](https://hub.docker.com/r/ithild1/openjabnab)
[![License: GPL](https://img.shields.io/badge/License-GPL-blue.svg)](COPYING)

---

*[English version below / Version anglaise ci-dessous](#english)*

---

## Français

Serveur privé open-source pour les lapins connectés **Nabaztag** et **Nabaztag/Tag**.
Ce fork modernise le projet original pour le faire fonctionner sur une infrastructure actuelle.

*Nabaztag est une marque déposée de Violet. OpenJabNab n'est pas affilié à Violet.*

### Ce que ce fork apporte

| Domaine | Changements |
|---------|-------------|
| 🐳 Docker | Image multi-stage (Ubuntu 18.04 + Qt4), conteneur unique avec nginx + php-fpm + supervisord |
| 🏗️ CI/CD | GitHub Actions : builds multi-architectures (`amd64`/`arm64`) publiés sur GHCR et Docker Hub |
| 🔧 C++11 | Remplacement de tous les `std::auto_ptr` dépréciés par `std::unique_ptr` dans le serveur et 8 plugins |
| 🐘 PHP 7 | Correction de `session_start()` incompatible avec PHP 7+ |
| 📋 Releases | Changelog et versionnement automatisés via Release Please |

Voir [CHANGELOG.md](CHANGELOG.md) pour le détail complet des modifications.

### Démarrage rapide — Docker

```bash
docker compose up -d
```

Puis configurez votre Nabaztag/Tag pour pointer vers `http://<votre-serveur>/vl` dans les réglages avancés du lapin, et redémarrez-le.

Ou via Docker Hub directement :

```bash
docker pull ithild1/openjabnab:latest
```

**Ports exposés :**

| Port | Rôle |
|------|------|
| `80` | Interface web & panneau d'administration (`/ojn_admin/`) |
| `5222` | XMPP — connexion des appareils |

Les données utilisateurs (comptes, lapins enregistrés) sont stockées dans un volume Docker nommé et persistent entre les redémarrages.

### Configuration

| Variable | Défaut | Description |
|----------|--------|-------------|
| `OJN_DOMAIN` | `localhost` | Nom d'hôte ou IP visible par le Nabaztag |
| `OJN_TTS` | `google` | Moteur de synthèse vocale : `google` ou `acapela` |
| `OJN_LOG_LEVEL` | `Warning` | Verbosité du serveur : `Debug`, `Warning` ou `Error` |

Exemple dans `docker-compose.yml` :

```yaml
environment:
  - OJN_DOMAIN=lapin.home.local
  - OJN_TTS=google
  - OJN_LOG_LEVEL=Warning
```

### Build manuel

> Nécessite **Ubuntu 18.04** — dernière LTS avec les paquets Qt4 disponibles dans les dépôts officiels.

```bash
# Installer les dépendances
sudo apt-get install build-essential libqt4-dev qt4-qmake

# Compiler le serveur C++ et les plugins
cd server && qmake -r && make -j$(nproc)
# Résultat : server/bin/openjabnab  server/bin/plugins/*.so  server/bin/libcommon.so

# Configurer
cp server/openjabnab.ini-dist server/bin/openjabnab.ini
# Éditer server/bin/openjabnab.ini — renseigner votre nom de domaine

# Déployer le wrapper PHP
# Copier le contenu de http-wrapper/ à la racine d'un domaine ou sous-domaine
```

### Plugins

Le serveur inclut 27+ plugins compilés en bibliothèques partagées :

| Plugin | Description |
|--------|-------------|
| `weather` | Météo |
| `airquality` | Qualité de l'air |
| `webradio` | Streaming radio web |
| `music` | Lecture de musique |
| `tts` | Synthèse vocale |
| `clock` | Annonce de l'heure |
| `gmail` | Notifications nouveaux e-mails |
| `memo` | Rappels |
| `jokes` | Blagues aléatoires |
| `surprise` | Lecture de MP3 aléatoire |
| `cinema` | Programmes cinéma |
| `tv` | Programmes TV |
| `ephemeride` | Éphéméride / calendrier |
| `ratp` | Info trafic RATP |
| `sleep` | Minuterie veille |
| `dice` | Lancer de dés |
| `ears` | Contrôle des oreilles |
| `taichi` | Animations taichi |
| … | et d'autres |

### Architecture

```
Appareil Nabaztag
      │
      ├── Port 5222 (XMPP) ──────────────────► openjabnab (serveur C++)
      │                                                ▲
      └── Port 80  (HTTP)  ──► nginx ──► openjabnab.php (proxy PHP) ──► :8080
                                     ├──► /ojn_admin/  (panneau admin PHP)
                                     └──► /ojn_local/  (fichiers statiques, cache TTS)
```

> **Note :** Le proxy PHP se connecte à `127.0.0.1:8080` — les deux services doivent être dans le même conteneur ou sur le même hôte.

### Licence

[GPL](COPYING) — voir le fichier COPYING pour les détails.
OpenJabNab utilise Qt Open Source Edition.
Nabaztag est une marque déposée de Violet.

---

<a name="english"></a>

## English

Open-source private server for **Nabaztag** and **Nabaztag/Tag** Wi-Fi connected rabbits.
This fork modernizes the original project to run on current infrastructure.

*Nabaztag is a trademark of Violet. OpenJabNab is not owned by or affiliated with Violet.*

### What this fork adds

| Area | Changes |
|------|---------|
| 🐳 Docker | Multi-stage Dockerfile (Ubuntu 18.04 + Qt4), single container with nginx + php-fpm + supervisord |
| 🏗️ CI/CD | GitHub Actions: multi-arch builds (`amd64`/`arm64`) pushed to GHCR and Docker Hub |
| 🔧 C++11 | Replaced all deprecated `std::auto_ptr` → `std::unique_ptr` across server and 8 plugins |
| 🐘 PHP 7 | Fixed `session_start()` API incompatible with PHP 7+ |
| 📋 Releases | Automated changelog and versioning via Release Please |

See [CHANGELOG.md](CHANGELOG.md) for the full list of changes.

### Quick Start — Docker

```bash
docker compose up -d
```

Then point your Nabaztag/Tag to `http://<your-server>/vl` in the device's advanced settings and restart it.

Or pull directly from Docker Hub:

```bash
docker pull ithild1/openjabnab:latest
```

**Exposed ports:**

| Port | Role |
|------|------|
| `80` | Web interface & admin panel (`/ojn_admin/`) |
| `5222` | XMPP — device connection |

User data (accounts, bunny registrations) is stored in a named Docker volume and persists across container restarts.

### Configuration

| Variable | Default | Description |
|----------|---------|-------------|
| `OJN_DOMAIN` | `localhost` | Hostname or IP visible to your Nabaztag device |
| `OJN_TTS` | `google` | Text-to-speech engine: `google` or `acapela` |
| `OJN_LOG_LEVEL` | `Warning` | Server verbosity: `Debug`, `Warning`, or `Error` |

Example `docker-compose.yml` override:

```yaml
environment:
  - OJN_DOMAIN=rabbit.home.local
  - OJN_TTS=google
  - OJN_LOG_LEVEL=Warning
```

### Manual Build

> Requires **Ubuntu 18.04** — the last LTS release with Qt4 packages in the official repos.

```bash
# Install dependencies
sudo apt-get install build-essential libqt4-dev qt4-qmake

# Build the C++ server and plugins
cd server && qmake -r && make -j$(nproc)
# Outputs: server/bin/openjabnab  server/bin/plugins/*.so  server/bin/libcommon.so

# Configure
cp server/openjabnab.ini-dist server/bin/openjabnab.ini
# Edit server/bin/openjabnab.ini — set your domain name

# Deploy the PHP wrapper
# Copy http-wrapper/ contents to the root of a (sub)domain
```

### Plugins

The server ships with 27+ plugins compiled as shared libraries:

| Plugin | Description |
|--------|-------------|
| `weather` | Weather forecast |
| `airquality` | Air quality index |
| `webradio` | Web radio streaming |
| `music` | Music playback |
| `tts` | Text-to-speech announcements |
| `clock` | Time announcements |
| `gmail` | Gmail new-mail notifications |
| `memo` | Reminders |
| `jokes` | Random jokes |
| `surprise` | Random MP3 playback |
| `cinema` | Cinema listings |
| `tv` | TV listings |
| `ephemeride` | Day name / calendar |
| `ratp` | Paris public transit info |
| `sleep` | Sleep timer |
| `dice` | Dice roller |
| `ears` | Ear movement control |
| `taichi` | Taichi animations |
| … | and more |

### Architecture

```
Nabaztag device
      │
      ├── Port 5222 (XMPP) ──────────────────► openjabnab (C++ server)
      │                                                ▲
      └── Port 80  (HTTP)  ──► nginx ──► openjabnab.php (PHP proxy) ──► :8080
                                     ├──► /ojn_admin/  (PHP admin panel)
                                     └──► /ojn_local/  (static files, TTS cache)
```

> **Note:** The PHP proxy connects to `127.0.0.1:8080` — both services must share the same host or container.

### License

[GPL](COPYING) — see COPYING for details.
OpenJabNab uses Qt Open Source Edition.
Nabaztag is a trademark of Violet.
