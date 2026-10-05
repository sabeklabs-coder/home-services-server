# HSS — Home Services Server

A home server that installs itself in one command, on a machine you
keep in your own house.

HSS writes the configuration, sets up networking, firewall, DNS and
storage, then brings up around thirty Docker containers grouped into
six stacks. Your files, your cameras, your home automation, your
cloud, your mail — on your hardware, at your address.

🇫🇷 **[Lire ce document en français](README.fr.md)**

> ### Project status — October 2026
>
> **No release has been published here yet.** The repository is in
> place; URL installation is not live, because the public `.run` is
> still being prepared. See [What is left](#what-is-left) below.
>
> HSS runs today on two test machines, x86_64 and arm64. Development
> happens in a private repository; this one only ever receives the
> installer, its documentation and its releases.
>
> **Language:** the installer and the documentation are in English and
> French. The **interactive menus of HSS itself are French-only** for
> now. If you do not read French, you will manage a working server
> through French menus.

---

## Install

```bash
curl -fsSL https://raw.githubusercontent.com/sabeklabs-coder/home-services-server/main/install.sh | bash
```

The script detects your architecture, downloads the matching installer
from the latest release, **verifies its SHA-256 checksum**, and runs
it.

If you would rather read before you execute — and that is a good
habit:

```bash
curl -fsSLO https://raw.githubusercontent.com/sabeklabs-coder/home-services-server/main/install.sh
less install.sh
bash install.sh
```

The full guide is in **[docs/en/GUIDE.md](docs/en/GUIDE.md)**.

---

## What you need

| | |
|---|---|
| System | Debian 12+ / Armbian, or Fedora Server 41+ |
| Architecture | `x86_64` (amd64) or `aarch64` (arm64) |
| Memory | 4 GB minimum, 8 GB to enable everything |
| Disk | 40 GB for the system and images, plus room for your data |
| Privileges | an account with `sudo` |
| Network | outbound connectivity; a domain name and a tunnel are optional |

HSS **changes the system configuration** of the machine: network,
firewall, DNS, storage, services. Install it on a dedicated machine,
not on your working desktop.

---

## What it installs

Six stacks, each one optional.

| Stack | Services |
|---|---|
| **Admin** | Coolify, Uptime Kuma, ntfy, Vaultwarden |
| **Data / NAS** | Nextcloud, Syncthing, UrBackup, FileBrowser |
| **Home** | Domoticz, Mosquitto, ESPHome, motionEye |
| **Media** | Jellyfin, Tvheadend, go2rtc, SRS |
| **Network / security** | Traefik, AdGuard Home, Unbound, Nginx Proxy Manager, WARP |
| **Remote access** | Cloudflare Tunnel, Tailscale, RustDesk, mail server, nginx + PHP, SFTP |

HSS **redistributes none** of these. It writes their configuration and
pulls their official images at install time. Each one stays under its
own authors' licence.

---

## Your data follows you

A live installation accumulates two very different things: what **you**
created, and what **the machine** observed. HSS keeps them apart.

- **What is yours** — files, databases, passwords, choices — goes into
  a single archive, `hss-user.tar`, that you carry with you.
- **What belongs to the machine** — IP address, network interfaces,
  distribution, hardware — is **observed again** at every install, and
  never restored. Restoring the old machine's address somewhere else
  would give you a restore that looks successful and breaks silently.

So moving to a new machine is: archive, install HSS on the new box,
answer *yes* to the restore question.

Details in [docs/en/GUIDE.md](docs/en/GUIDE.md).

---

## The installer ships empty

The published `.run` contains **no** data, **no** password and **no**
machine identity. That is not a promise, it is a check: the build
reads a manifest that declares, path by path, what belongs to the
user, and **aborts** if a single one of those paths would ship.

No passwords are shipped either — they would be identical for every
user, and public since this repository is. Each installation draws its
own at random, before the first container that needs them starts.

---

## Licence

**Personal use allowed. Modification and redistribution are not.**
See [LICENSE](LICENSE) (French: [LICENSE.fr.txt](LICENSE.fr.txt)).

This is not free software: the source is visible, it is not reusable.
You may install and run it at home, at no cost and with no time limit.

---

## Security

Report a vulnerability privately, not in a public issue. The procedure
is in [SECURITY.md](SECURITY.md).

---

## What is left

This repository receives the installer and its releases. Development
happens elsewhere: session notes, plans and history stay private.

Before the first published release:

- [ ] the `hss-user.tar` archive and its restore path
- [ ] the public build profile, driven by the manifest
- [ ] the "a stranger installs HSS" acceptance run, on Fedora then on arm64
- [ ] release `v3.3`, with the `.run` files and their SHA-256 checksums

---

*HSS is written and maintained by one person, for their own network.
It is published because it may be useful elsewhere — not because it is
a product.*
