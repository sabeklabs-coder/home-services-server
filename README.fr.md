# HSS — Home Services Server

🇬🇧 **[Read this in English](README.md)**

Un serveur de services domestiques qui s'installe en une commande, sur
une machine que vous gardez chez vous.

HSS écrit la configuration, pose le réseau, le pare-feu, le DNS et le
stockage, puis démarre une trentaine de conteneurs Docker répartis en
six ensembles. Vos fichiers, vos caméras, votre domotique, votre
cloud, votre courrier : chez vous, sur votre matériel.

> ### État du projet — octobre 2026
>
> **Aucune version n'est encore publiée ici.** Ce dépôt est en place,
> l'installation par URL n'est pas encore active : le `.run` public est
> en préparation. Voir [Suivi](#suivi) plus bas.
>
> HSS tourne aujourd'hui sur deux machines de test, en x86_64 et en
> arm64. Le développement se fait dans un dépôt privé ; ce dépôt-ci ne
> reçoit que l'installateur, sa documentation et ses versions.

---

## Installation

```bash
curl -fsSL https://raw.githubusercontent.com/sabeklabs-coder/home-services-server/main/install.sh | bash
```

Le script détecte l'architecture, télécharge l'installateur
correspondant depuis la dernière version publiée, **vérifie son
empreinte SHA-256**, puis le lance.

Si vous préférez regarder avant d'exécuter — et c'est une bonne
habitude :

```bash
curl -fsSLO https://raw.githubusercontent.com/sabeklabs-coder/home-services-server/main/install.sh
less install.sh
bash install.sh
```

Le guide complet est dans **[docs/fr/GUIDE.md](docs/fr/GUIDE.md)**.

---

## Ce qu'il vous faut

| | |
|---|---|
| Système | Debian 12+ / Armbian, ou Fedora Server 41+ |
| Architecture | `x86_64` (amd64) ou `aarch64` (arm64) |
| Mémoire | 4 Go au minimum, 8 Go pour tout activer |
| Disque | 40 Go pour le système et les images, plus la place de vos données |
| Droits | un compte avec `sudo` |
| Réseau | une connexion sortante ; un nom de domaine et un tunnel sont facultatifs |

HSS **modifie la configuration système** de la machine : réseau,
pare-feu, DNS, stockage, services. Installez-le sur une machine dédiée,
pas sur votre poste de travail.

---

## Ce qu'il installe

Six ensembles, activables séparément.

| Ensemble | Services |
|---|---|
| **Administration** | Coolify, Uptime Kuma, ntfy, Vaultwarden |
| **Données / NAS** | Nextcloud, Syncthing, UrBackup, FileBrowser |
| **Maison** | Domoticz, Mosquitto, ESPHome, motionEye |
| **Multimédia** | Jellyfin, Tvheadend, go2rtc, SRS |
| **Réseau / sécurité** | Traefik, AdGuard Home, Unbound, Nginx Proxy Manager, WARP |
| **Accès distant** | Cloudflare Tunnel, Tailscale, RustDesk, serveur mail, nginx + PHP, SFTP |

HSS **ne redistribue aucun** de ces logiciels : il écrit leur
configuration et télécharge leurs images officielles au moment de
l'installation. Chacune reste sous la licence de ses auteurs.

---

## Vos données vous suivent

Une installation vivante accumule deux choses très différentes : ce que
**vous** avez créé, et ce que **la machine** a observé. HSS les
sépare.

- **Ce qui est à vous** — fichiers, bases, mots de passe, choix — part
  dans une archive unique, `hss-user.tar`, que vous emportez.
- **Ce qui est à la machine** — adresse IP, interfaces réseau,
  distribution, cartes — est **ré-observé** à chaque installation, et
  n'est jamais restauré. Restaurer l'adresse de l'ancienne machine
  ailleurs donnerait une restauration qui a l'air réussie et qui casse
  en silence.

Changer de machine, c'est donc : archiver, installer HSS sur la
nouvelle, répondre « oui » à la question de restauration.

Détails dans [docs/fr/GUIDE.md](docs/fr/GUIDE.md)
et [docs/fr/GUIDE.md](docs/fr/GUIDE.md).

---

## L'installateur est vierge

Le `.run` publié ici ne contient **aucune** donnée, **aucun** mot de
passe, **aucune** identité de machine. Ce n'est pas une promesse, c'est
une vérification : la construction lit un manifeste qui déclare, chemin
par chemin, ce qui appartient à l'utilisateur, et **s'arrête** si un
seul de ces chemins se retrouve dans ce qui serait livré.

Aucun mot de passe n'est livré non plus : ils seraient les mêmes chez
tous les utilisateurs, et publics puisque ce dépôt l'est. Chaque
installation tire les siens au hasard, avant le premier démarrage des
conteneurs qui en dépendent.

---

## Licence

**Usage personnel autorisé, modification et redistribution
interdites.** Voir [LICENSE.fr.txt](LICENSE.fr.txt) (anglais : [LICENSE](LICENSE)).

Ce n'est pas un logiciel libre : le code est visible, il n'est pas
réutilisable. Vous pouvez l'installer et l'utiliser chez vous, sans
frais et sans limite de durée.

---

## Sécurité

Une faille se signale en privé, pas dans une issue publique. La
procédure est dans [SECURITY.md](SECURITY.md).

---

## Suivi

Ce dépôt reçoit l'installateur et ses versions. Le développement, lui,
se fait ailleurs : les notes de session, les plans et l'historique
restent dans un dépôt privé.

Ce qui manque avant la première version publiée :

- [ ] l'archive `hss-user.tar` et sa restauration
- [ ] le profil de construction public, piloté par le manifeste
- [ ] la recette « un inconnu installe HSS », sur Fedora puis sur arm64
- [ ] la version `v3.3`, avec les `.run` et leurs empreintes SHA-256

---

*HSS est écrit et maintenu par une seule personne, pour son propre
réseau. Il est publié parce qu'il peut servir ailleurs — pas parce
qu'il est un produit.*
