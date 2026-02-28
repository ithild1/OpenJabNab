# Guide de migration Docker

## v0.1.1 → v0.1.2 — Refonte des volumes de persistance

### Pourquoi cette migration ?

La version 0.1.x utilisait un seul volume (`ojn_data`) monté sur `/var/www/html/ojn_local`.
Ce dossier ne contient que le cache TTS, les assets plugins et le bootcode.

Les données critiques du serveur C++ — **comptes utilisateurs, lapins (bunnies) et ztamps** —
étaient stockées dans `/opt/openjabnab/bin/accounts|bunnies|ztamps` et **perdues à chaque
redémarrage du conteneur**.

La version 0.1.2 corrige cela avec deux volumes distincts :

| Volume | Chemin dans le conteneur | Contenu |
|--------|--------------------------|---------|
| `ojn_server_data` | `/opt/openjabnab/data` | Comptes, bunnies, ztamps, log serveur |
| `ojn_web_data` | `/var/www/html/ojn_local` | Cache TTS (MP3), assets plugins, bootcode |

---

### Scénario A — Nouveau déploiement (aucune donnée existante)

Rien à faire. Les volumes sont créés automatiquement au premier `docker compose up`.

```bash
docker compose up -d
```

---

### Scénario B — Migration depuis v0.1.x (volume `ojn_data` existant)

Le volume `ojn_data` ne contenait que des données web (`ojn_local/`) — aucune donnée
C++ n'y était sauvegardée. La migration consiste uniquement à renommer ce volume.

> **Note :** si votre conteneur v0.1.x tournait depuis peu et que vous n'aviez pas encore
> de comptes ou de lapins enregistrés, vous pouvez passer directement au Scénario A.

#### Étape 1 — Arrêter le conteneur existant

```bash
docker compose down
```

#### Étape 2 — Copier le contenu de l'ancien volume vers le nouveau

```bash
# Créer le nouveau volume
docker volume create ojn_web_data

# Copier les données (cache TTS, assets plugins, bootcode)
docker run --rm \
  -v ojn_data:/src \
  -v ojn_web_data:/dst \
  alpine sh -c "cp -a /src/. /dst/"
```

#### Étape 3 — Vérifier la copie (optionnel)

```bash
docker run --rm -v ojn_web_data:/data alpine ls /data
# Doit afficher : bootcode  plugins  tts
```

#### Étape 4 — Supprimer l'ancien volume

```bash
docker volume rm ojn_data
```

#### Étape 5 — Démarrer avec la nouvelle configuration

```bash
docker compose up -d
```

Le volume `ojn_server_data` est créé automatiquement et ses sous-dossiers
(`accounts/`, `bunnies/`, `ztamps/`) sont initialisés par l'entrypoint au premier démarrage.

---

### Vérification post-migration

```bash
# Les deux volumes doivent exister
docker volume ls | grep ojn

# Le conteneur doit être healthy
docker compose ps

# Vérifier les logs de démarrage
docker compose logs openjabnab | head -30
```

Vous devriez voir dans les logs :

```
[entrypoint] Generating openjabnab.ini for domain: ...
```

suivi du démarrage de supervisord, nginx, php-fpm et openjabnab sans erreur.
