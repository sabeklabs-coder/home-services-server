# Reporting a vulnerability

Please do **not** open a public issue for a security problem. An issue
is visible to everyone, including anyone who would use it before the
fix lands.

🇫🇷 **[Lire ce document en français](SECURITY.fr.md)**

## How

Use the repository's **Security → Report a vulnerability** tab (GitHub
Private Vulnerability Reporting). The report stays between you and the
maintainer.

If that tab is unavailable, open a private discussion via
[@sabeklabs-coder](https://github.com/sabeklabs-coder).

## What helps

- the HSS version (`hss version`) and the machine's architecture;
- which service is affected, and what is exposed: the local network
  only, or also the outside through the tunnel;
- enough to reproduce — a sequence of steps beats a description;
- the impact as you see it.

**Never send a password, private key or token**, not even as an
illustration. Say that there is one, and where.

## What to expect

| | |
|---|---|
| Acknowledgement | within 7 days |
| First assessment | within 30 days |
| Fix | depending on severity, announced in the report |

HSS is maintained by one person, in their spare time. These are
good-faith commitments, not a support contract.

## Disclosure

The fix goes out first, the explanation second. Once the fixed release
is published, the problem is described in the release notes, and your
report is credited if you wish.

## Out of scope

- vulnerabilities in the third-party software HSS installs — report
  those to their authors (Nextcloud, Traefik, AdGuard…);
- an installation you have yourself exposed to the internet without a
  tunnel or a firewall;
- the absence of a security feature that was never announced.
