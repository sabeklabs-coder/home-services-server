# HSS — Guide de l'utilisateur

Tout ce qu'il faut pour installer, faire tourner et déménager un
serveur HSS.

🇬🇧 **[Read this guide in English](../en/GUIDE.md)** · [← retour au README](../../README.fr.md)

---

## Sommaire

1. [Avant de commencer](#1-avant-de-commencer)
2. [Installation](#2-installation)
3. [Premier démarrage](#3-premier-démarrage)
4. [Votre domaine et l'accès distant](#4-votre-domaine-et-laccès-distant)
5. [Le stockage](#5-le-stockage)
6. [Ce qui est à vous, ce qui est à la machine](#6-ce-qui-est-à-vous-ce-qui-est-à-la-machine)
7. [Sauvegarder et restaurer](#7-sauvegarder-et-restaurer)
8. [Changer de machine](#8-changer-de-machine)
9. [Dépannage](#9-dépannage)
10. [Désinstaller](#10-désinstaller)

---

## 1. Avant de commencer

### Ce que HSS fait à la machine

HSS n'est pas une application qu'on ajoute à côté des autres. Il prend
la main sur la **configuration système** du serveur :

- il installe Docker et crée ses propres réseaux ;
- il pose une **adresse IP fixe**, et peut basculer la machine entre
  les modes LAN, routeur et point d'accès Wi-Fi ;
- il met **AdGuard Home et Unbound sur le port 53** — la machine
  devient un résolveur DNS ;
- il configure **UFW** et écrit des règles de pare-feu ;
- il peut créer ou importer un **pool ZFS** ;
- il active des services au démarrage.

Installez-le sur une **machine dédiée**. Pas sur votre poste de
travail, et pas sur un serveur qui fait déjà quelque chose qui compte.

### Ce qu'il vous faut

| | |
|---|---|
| Système | Debian 12+ / Armbian, ou Fedora Server 41+ |
| Architecture | `x86_64` (amd64) ou `aarch64` (arm64) |
| Mémoire | 4 Go au minimum ; 8 Go pour activer toutes les stacks |
| Disque | 40 Go pour le système et les images, plus vos données |
| Compte | un utilisateur ordinaire avec `sudo` — **pas** root |
| Réseau | une connexion sortante |

Un nom de domaine, un tunnel Cloudflare et un second disque sont tous
**facultatifs**. HSS fonctionne sur un réseau local sans aucun des
trois.

### Sauvegardez d'abord

HSS modifie la configuration réseau et DNS de la machine. Si vous
perdez l'accès distant en cours d'installation, il vous faudra un
clavier et un écran dessus. Prévoyez-le avant, pas après.

---

## 2. Installation

### L'installation en une ligne

```bash
curl -fsSL https://raw.githubusercontent.com/sabeklabs-coder/home-services-server/main/install.sh | bash
```

Lancez-la avec **votre propre compte**, celui qui a `sudo`. C'est ce
compte qui possédera le dossier du projet.

### Lire avant d'exécuter

Envoyer un script d'Internet directement dans un shell est une
habitude dont il vaut mieux se défaire. La même installation en deux
temps :

```bash
curl -fsSLO https://raw.githubusercontent.com/sabeklabs-coder/home-services-server/main/install.sh
less install.sh
bash install.sh
```

### Ce que fait `install.sh`, et rien de plus

1. il lit `uname -m` et le traduit en `amd64` ou `arm64` ;
2. il demande à GitHub la dernière version publiée ;
3. il télécharge `hss-<version>-<arch>-public.run` ;
4. il **vérifie son empreinte SHA-256** contre le `SHA256SUMS` publié
   avec la version — et refuse d'exécuter quoi que ce soit s'il n'y
   parvient pas ;
5. il passe la main à l'installateur, avec votre terminal rebranché.

Il n'écrit rien hors d'un dossier temporaire et n'appelle jamais
`sudo`. C'est l'installateur qui le fait, une fois que vous le voyez
arriver.

### Imposer vous-même l'empreinte

`SHA256SUMS` se trouve à côté du `.run`, dans la même version : qui
pourrait remplacer l'un pourrait remplacer l'autre. La vérification
attrape ce qui arrive vraiment souvent — un téléchargement tronqué, un
miroir en retard, un disque qui ment. Pour vous protéger d'un dépôt
compromis, prenez l'empreinte ailleurs et imposez-la :

```bash
HSS_SHA256=<empreinte> bash install.sh
```

### Ce que l'installateur demande

Le `.run` est une archive auto-extractible. Elle se déballe, puis
lance son propre `setup.sh`, qui est **interactif** : il demande avant
de changer quoi que ce soit d'important. Attendez-vous à des questions
sur le dossier cible, le mode réseau, le mode de stockage, et les
stacks que vous voulez.

Par défaut le projet s'installe dans **`~/hss`**. Pour le mettre
ailleurs :

```bash
NAS_INSTALL_DEST=/srv/hss ./hss-<version>-<arch>-public.run
```

---

## 3. Premier démarrage

### La commande `hss`

L'installateur place le gestionnaire dans votre `PATH` :

```bash
hss              # ouvre le menu
hss version      # quelle version est installée
hss doctor       # contrôle tout, ne change rien
```

`hss doctor` est la première à apprendre. Il inspecte l'installation
et dit ce qui va mal sans y toucher. Lancez-le après chaque changement
dont vous n'êtes pas sûr.

### Le menu

`hss` sans argument ouvre un menu. Les entrées dont vous aurez besoin
en premier :

| Entrée | Ce qu'elle fait |
|---|---|
| *Déploiement initial* | l'installation complète, la première fois |
| *Démarrer toutes les stacks* | monte toutes les stacks activées |
| *État des stacks* | ce qui tourne, ce qui ne tourne pas |
| *Arrêter toutes les stacks* | tout redescend |
| *Mode réseau (LAN/ROUTEUR/WLAN)* | change le mode réseau |
| *Pare-feu (règles, persistance)* | les règles de pare-feu |
| *Proxy inverse : NPM + Traefik* | le proxy inverse |
| *NAS : gestion disque (ZFS, SMART)* | les disques et ZFS |
| *Optimisation et nettoyage* | le nettoyage |

### Les commandes par stack et par service

```bash
hss status                       # l'état général
hss <stack> status               # une stack
hss <stack> logs                 # ses dernières lignes de journal
hss <service> restart            # un service
```

Les six dossiers de stack sont `stack-admin`, `stack-data-nas`,
`stack-home`, `stack-multimedia`, `stack-network-security` et
`stack-tunnel`.

### Les mots de passe

**HSS ne livre aucun mot de passe.** Ils seraient les mêmes chez tous
les utilisateurs, et publics, puisque le dépôt l'est. Au premier
démarrage, avant que les conteneurs qui en dépendent ne montent, HSS
tire les siens au hasard :

```bash
hss secrets etat     # quels secrets existent — aucune écriture
hss secrets gen      # remplit ce qui manque — n'écrase jamais
```

Les deux se lancent sans risque à tout moment. `gen` est idempotent :
il ne remplit qu'un vide.

### La configuration de départ

Certains services ne démarrent pas du tout sans une configuration qui
marche — Mosquitto a besoin d'un `mosquitto.conf`, go2rtc d'un
`go2rtc.yaml`, nginx d'une page d'accueil. HSS les livre sous forme de
modèles `*.example` et génère le fichier réel s'il manque :

```bash
hss socle etat       # quels fichiers de socle sont en place
hss socle gen        # crée ce qui manque — n'écrase jamais
```

Dès que vous avez modifié l'un de ces fichiers, il est à vous : rien
ne l'écrasera, et il part dans votre archive.

---

## 4. Votre domaine et l'accès distant

Tout ceci est **facultatif**. HSS tourne sur un réseau local sans
domaine et sans tunnel.

### Le domaine

Vous posez votre domaine une fois, dans la configuration, et HSS le
réécrit à travers les règles du proxy inverse :

```
scripts/manage-stacks-ma.config     →  deploy_domain=mondomaine.example
```

Les fichiers livrés par le projet portent `example.invalid`, un nom
que la RFC 2606 réserve et qui ne résout nulle part. Au premier
déploiement après que vous avez posé `deploy_domain`, HSS le remplace
partout où il sert, et retient ce qu'il a remplacé — ainsi le
changement suivant sait quoi chercher.

### Le tunnel

HSS gère un **tunnel Cloudflare**, qui publie des services sans ouvrir
un seul port entrant sur votre routeur. La carte des sous-domaines est
dans `scripts/tools/subdomain.list` ; le projet livre
`subdomain.list.example` comme modèle, parce que cette liste est la
carte de *votre* réseau exposé et qu'elle vous appartient.

**Le courrier ne passe jamais par le tunnel.** Un enregistrement MX
doit résoudre vers une adresse joignable en SMTP sur le port 25, et
Cloudflare ne relaie pas le SMTP.

### Tailscale et RustDesk

Les deux sont là pour l'administration distante : un réseau privé et
un bureau distant. Les deux demandent un compte chez leur fournisseur,
et les deux enregistrent cette machine comme un nœud — c'est
exactement pour cela que leur identité n'est jamais livrée dans
l'installateur et jamais restaurée depuis une archive.

---

## 5. Le stockage

HSS a trois modes de stockage, basculables :

| Mode | Où vivent les données |
|---|---|
| `local` | le disque système |
| pool ZFS | un jeu de données sur un pool existant |
| point de montage | `/media/Hss-Data` |

Votre dossier de données est marqué par un fichier `.hss-data` qui
porte un **uuid**. C'est cet uuid qui dit à HSS « ceci est mon dossier
de données, pas celui d'un autre » — et il est gardé dans votre
configuration portable, pour qu'un déménagement n'en fabrique pas un
neuf et n'adopte pas le mauvais dossier.

Le changement de mode se fait depuis le menu, entrée *NAS : gestion
disque (ZFS, SMART)*.

---

## 6. Ce qui est à vous, ce qui est à la machine

C'est la distinction sur laquelle repose toute la conception des
sauvegardes, et elle vaut deux minutes.

Une installation qui tourne accumule deux sortes d'état.

**Ce qui est à vous.** Vos fichiers, vos bases, vos mots de passe, vos
choix, la configuration que vous avez modifiée, les caméras que vous
avez ajoutées. Cela vous suit. Cela part dans l'archive.

**Ce qui est à la machine.** Son adresse IP, ses interfaces réseau, sa
distribution, ses disques, son identifiant d'hôte. Cela est
**ré-observé** à chaque installation, et **jamais restauré**.

> Restaurer l'état de la machine ailleurs poserait l'adresse de
> l'*ancienne* machine sur la nouvelle : une restauration qui a l'air
> réussie et qui casse en silence. C'est pourquoi les deux moitiés
> sont séparées à la source, au lieu d'être triées après coup.

Concrètement, dans le dossier du projet :

| | |
|---|---|
| `user/user.env`, `user/user.config` | **portable** — vous suit, se sauvegarde, se restaure |
| `user/machine.env` | **locale** — ré-observée à chaque déploiement, jamais restaurée |

---

## 7. Sauvegarder et restaurer

> ### 🚧 En développement
>
> L'archive et sa restauration ne sont **pas terminées**. Cette
> section décrit la conception en cours de construction, pour que vous
> sachiez à quoi vous attendre — pas une fonction utilisable
> aujourd'hui. Suivez le
> [dépôt](https://github.com/sabeklabs-coder/home-services-server)
> pour la version qui l'apportera.

### Une seule archive, pas plusieurs

Tout ce qui est à vous part dans un seul fichier : **`hss-user.tar`**.

Pas une archive par catégorie. Séparer « donnée » de « secret »
obligerait à juger chaque fichier un par un — et c'est précisément ce
jugement qui a un jour laissé passer un mot de passe en clair.

### Les bases sont vidées, pas copiées

Copier une base en fonctionnement n'est pas une sauvegarde : on
attrape un instantané incohérent. Les trois moteurs se vident par
dump, et un dump a en prime l'avantage de survivre à un changement de
version majeure.

### Les identifiants, et les services qui les détiennent

Une installation HSS détient des identifiants qui vivent **à
l'intérieur** des services — votre compte Nextcloud, l'administrateur
AdGuard, le coffre Vaultwarden, les comptes de courrier. Ils ne sont
pas dans un fichier de configuration : ils sont des lignes dans la
base du service lui-même.

L'archive les emporte, parce qu'elle emporte les dumps des bases qui
les portent. C'est aussi pourquoi un installateur public n'en livre
**rien** : une installation neuve démarre avec des services vides, et
c'est vous qui créez le premier compte.

### La restauration refuse une installation non vierge

Restaurer par-dessus une installation qui tourne mélangerait deux
états et n'en donnerait aucun. La restauration contrôle d'abord, et
refuse si l'installation n'est pas neuve.

---

## 8. Changer de machine

> ### 🚧 En développement — voir la section 7.

La séquence prévue :

1. Sur l'ancienne machine, construire l'archive. Les bases sont vidées
   **avant** que quoi que ce soit ne soit retiré.
2. Copier `hss-user.tar` en lieu sûr — pas sur la machine que vous
   allez remettre à zéro.
3. Installer HSS sur la nouvelle machine, avec le `.run` publié.
4. **Dès le début**, l'installateur demande si vous voulez restaurer
   vos données. Répondez oui et indiquez-lui `hss-user.tar`.
5. Le déploiement continue normalement et **ré-observe** tout ce qui
   appartient à la nouvelle machine : adresse, réseau, distribution,
   matériel.

Si la restauration échoue, l'installation continue comme une
installation neuve, plutôt que de s'arrêter à moitié.

---

## 9. Dépannage

### On commence toujours ici

```bash
hss doctor
```

Il ne change rien et nomme ce qui va mal. La plupart de ce qui suit
est un cas particulier de ce qu'il affiche.

### Un service ne démarre pas

```bash
hss <stack> logs
hss <stack> status
```

Les trois causes habituelles, par ordre de fréquence :

1. **Un secret manquant.** `hss secrets etat`, puis `hss secrets gen`.
2. **Un fichier de configuration manquant.** `hss socle etat`, puis
   `hss socle gen`.
3. **Le propriétaire d'un dossier.** Un conteneur écrit sous un uid
   précis, et un dossier que Docker a créé en `root:root` lui sera
   refusé — PostgreSQL est strict là-dessus. L'outil de permissions
   repose les propriétaires attendus.

### Le port 53 est pris

HSS met AdGuard Home et Unbound sur le port 53. Sur un système où
`systemd-resolved` écoute déjà dessus, le conflit doit être réglé
avant qu'AdGuard puisse monter. Le déploiement le signale par son nom.

### Plus de réseau après un changement de mode

Utilisez l'entrée de menu *Réparer le réseau (DNS / IP fixe)*. Si vous
avez perdu l'accès distant, il vous faut un clavier local — c'est pour
cela que la section 1 vous demande d'en prévoir un.

### Plus rien ne résout sur le réseau local

La machine est un résolveur DNS. Si sa propre résolution est cassée,
tout ce qui est derrière a l'air cassé aussi. Vérifiez le résolveur
avant d'accuser le service.

---

## 10. Désinstaller

Le gestionnaire a un chemin de nettoyage qui arrête les stacks,
supprime les conteneurs et les réseaux, et retire le lien `hss` de
`/usr/local/bin`.

**Il ne supprime pas vos données**, et c'est voulu. Votre dossier de
données et votre archive sont à vous ; un outil de nettoyage n'a pas à
décider qu'ils doivent disparaître.

La configuration système que HSS a écrite — IP fixe, règles de
pare-feu, DNS sur le port 53 — ne revient **pas** en arrière toute
seule. Si vous voulez retrouver la machine telle qu'elle était,
réinstallez le système. C'est plus rapide, et c'est la seule façon
d'en être sûr.

---

*Quelque chose de faux, ou de manquant, dans ce guide ? Ouvrez une
issue. Pour un problème de sécurité,
[SECURITY.fr.md](../../SECURITY.fr.md) à la place — pas une issue
publique.*
