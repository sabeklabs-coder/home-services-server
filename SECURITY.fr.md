# Signaler une faille

🇬🇧 **[Read this in English](SECURITY.md)**

Merci de **ne pas** ouvrir d'issue publique pour une faille de
sécurité. Une issue est visible de tous, y compris de qui voudrait
s'en servir avant le correctif.

## Comment faire

Utilisez l'onglet **Security → Report a vulnerability** du dépôt
(GitHub Private Vulnerability Reporting). Le signalement reste privé
entre vous et le mainteneur.

Si cet onglet n'est pas disponible, ouvrez une **discussion privée**
en passant par le profil [@sabeklabs-coder](https://github.com/sabeklabs-coder).

## Ce qui aide

- la version de HSS (`hss version`) et l'architecture de la machine ;
- le service concerné, et ce qui est exposé : seulement le réseau
  local, ou aussi l'extérieur par le tunnel ;
- de quoi reproduire — une suite d'étapes vaut mieux qu'une
  description ;
- l'impact tel que vous le voyez.

**N'envoyez jamais de mot de passe, de clé privée ou de jeton**, même
pour illustrer. Dites qu'il y en a un, et où.

## Ce que vous pouvez attendre

| | |
|---|---|
| Accusé de réception | sous 7 jours |
| Première évaluation | sous 30 jours |
| Correctif | selon la gravité, annoncé dans le signalement |

HSS est maintenu par une seule personne, sur son temps libre. Ces
délais sont des engagements de bonne foi, pas un contrat de support.

## Divulgation

Le correctif part d'abord, l'explication ensuite. Une fois la version
corrigée publiée, le problème est décrit dans les notes de version, et
votre signalement est crédité si vous le souhaitez.

## Hors périmètre

- les failles des logiciels tiers que HSS installe — elles se
  signalent à leurs auteurs (Nextcloud, Traefik, AdGuard…) ;
- une installation que vous avez vous-même ouverte sur l'extérieur
  sans tunnel ni pare-feu ;
- l'absence d'une fonction de sécurité jamais annoncée.
