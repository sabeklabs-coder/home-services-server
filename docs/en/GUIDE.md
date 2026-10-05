# HSS — User guide

Everything you need to install, run and move a HSS server.

🇫🇷 **[Lire ce guide en français](../fr/GUIDE.md)** · [← back to the README](../../README.md)

> **Language note.** This guide is in English. The **interactive menus
> of HSS are French-only** for now. Where a menu entry matters, its
> French label is quoted, so you can find it on screen.

---

## Contents

1. [Before you start](#1-before-you-start)
2. [Installing](#2-installing)
3. [First start](#3-first-start)
4. [Your domain and remote access](#4-your-domain-and-remote-access)
5. [Storage](#5-storage)
6. [What is yours, what is the machine's](#6-what-is-yours-what-is-the-machines)
7. [Backing up and restoring](#7-backing-up-and-restoring)
8. [Moving to another machine](#8-moving-to-another-machine)
9. [Troubleshooting](#9-troubleshooting)
10. [Uninstalling](#10-uninstalling)

---

## 1. Before you start

### What HSS does to the machine

HSS is not an application you add next to your other software. It
takes over the server's **system configuration**:

- it installs Docker and creates its own networks;
- it sets a **fixed IP address**, and can switch the machine between
  LAN, router and Wi-Fi access-point modes;
- it puts **AdGuard Home and Unbound on port 53** — the machine
  becomes a DNS resolver;
- it configures **UFW** and writes firewall rules;
- it may create or import a **ZFS pool**;
- it enables services at boot.

Install it on a **dedicated machine**. Not on your desktop, and not on
a server that already does something you care about.

### Requirements

| | |
|---|---|
| System | Debian 12+ / Armbian, or Fedora Server 41+ |
| Architecture | `x86_64` (amd64) or `aarch64` (arm64) |
| Memory | 4 GB minimum; 8 GB to enable every stack |
| Disk | 40 GB for system and container images, plus your data |
| Account | an ordinary user with `sudo` — **not** root |
| Network | outbound connectivity |

A domain name, a Cloudflare tunnel and a second disk are all
**optional**. HSS works on a local network with none of them.

### Back up first

HSS changes the network and DNS configuration of the machine. If you
lose remote access mid-install, you will need a keyboard and a screen
on it. Plan for that before you start, not after.

---

## 2. Installing

### The one-line install

```bash
curl -fsSL https://raw.githubusercontent.com/sabeklabs-coder/home-services-server/main/install.sh | bash
```

Run it as **your own user**, the one with `sudo`. That account will own
the project directory.

### Read before you run

Piping a script from the internet into a shell is a habit worth
breaking. The same install in two steps:

```bash
curl -fsSLO https://raw.githubusercontent.com/sabeklabs-coder/home-services-server/main/install.sh
less install.sh
bash install.sh
```

### What `install.sh` does, and nothing more

1. reads `uname -m` and maps it to `amd64` or `arm64`;
2. asks GitHub for the latest release;
3. downloads `hss-<version>-<arch>-public.run`;
4. **verifies its SHA-256** against the `SHA256SUMS` published with the
   release — and refuses to run anything if it cannot;
5. hands control to the installer, with your terminal attached.

It writes nothing outside a temporary directory and never calls `sudo`.
The installer does that, once you can see it.

### Pinning the checksum yourself

`SHA256SUMS` sits next to the `.run` in the same release: whoever could
replace one could replace the other. The verification catches what
actually happens often — a truncated download, a stale mirror, a disk
that lies. For protection against a compromised repository, take the
checksum from somewhere else and pin it:

```bash
HSS_SHA256=<checksum> bash install.sh
```

### What the installer asks

The `.run` is a self-extracting archive. It unpacks itself, then runs
its own `setup.sh`, which is **interactive**: it asks before it
changes anything significant. Expect questions about the target
directory, the network mode, the storage mode, and which stacks you
want.

By default the project lands in **`~/hss`**. To put it elsewhere:

```bash
NAS_INSTALL_DEST=/srv/hss ./hss-<version>-<arch>-public.run
```

---

## 3. First start

### The `hss` command

The installer links the manager into your `PATH`:

```bash
hss              # open the menu
hss version      # which version is installed
hss doctor       # check everything, change nothing
```

`hss doctor` is the one to learn first. It inspects the installation
and reports what is wrong without touching it. Run it after every
change you do not fully trust.

### The menu

`hss` with no argument opens a menu. The entries you will use first:

| French label on screen | What it does |
|---|---|
| *Déploiement initial* | the full first-time setup |
| *Démarrer toutes les stacks* | bring every enabled stack up |
| *État des stacks* | what is running, what is not |
| *Arrêter toutes les stacks* | bring everything down |
| *Mode réseau (LAN/ROUTEUR/WLAN)* | switch network mode |
| *Pare-feu (règles, persistance)* | firewall rules |
| *Proxy inverse : NPM + Traefik* | reverse proxy |
| *NAS : gestion disque (ZFS, SMART)* | disks and ZFS |
| *Optimisation et nettoyage* | cleanup |

### Per-stack and per-service commands

```bash
hss status                       # overall state
hss <stack> status               # one stack
hss <stack> logs                 # its last log lines
hss <service> restart            # one service
```

The six stack directories are `stack-admin`, `stack-data-nas`,
`stack-home`, `stack-multimedia`, `stack-network-security` and
`stack-tunnel`.

### Passwords

**HSS ships no passwords.** They would be identical for every user,
and public, since the repository is. At the first start, before the
containers that need them come up, HSS draws its own at random:

```bash
hss secrets etat     # which secrets exist — no writes
hss secrets gen      # fill in what is missing — never overwrites
```

Both are safe to run at any time. `gen` is idempotent: it only ever
fills a blank.

### Starting configuration

Some services need a working configuration before they will start at
all — Mosquitto needs an `mosquitto.conf`, go2rtc a `go2rtc.yaml`,
nginx a landing page. HSS ships these as `*.example` templates and
generates the real file if it is missing:

```bash
hss socle etat       # which baseline files are in place
hss socle gen        # create what is missing — never overwrites
```

Once you have edited one of those files, it is yours: nothing will
overwrite it, and it goes into your archive.

---

## 4. Your domain and remote access

All of this is **optional**. HSS runs on a local network with no domain
and no tunnel.

### The domain

Set your domain once, in the configuration, and HSS rewrites it
through the reverse-proxy rules:

```
scripts/manage-stacks-ma.config     →  deploy_domain=yourdomain.example
```

The files shipped by the project carry `example.invalid`, a name
RFC 2606 reserves and that resolves nowhere. At the first deployment
after you set `deploy_domain`, HSS replaces it everywhere it is used,
and remembers what it replaced — so the next change knows what to look
for.

### The tunnel

HSS supports a **Cloudflare tunnel**, which publishes services without
opening a single inbound port on your router. The subdomain map lives
in `scripts/tools/subdomain.list`; the project ships
`subdomain.list.example` as a template, because that list is the map of
*your* exposed network and belongs to you.

**Mail does not go through the tunnel, ever.** An MX record must
resolve to an address reachable by SMTP on port 25, and Cloudflare does
not relay SMTP.

### Tailscale and RustDesk

Both are included for remote administration: a private network and a
remote desktop. Both need an account with their own provider, and both
register this machine as a node — which is exactly why their identity
is never shipped in the installer and never restored from an archive.

---

## 5. Storage

HSS has three storage modes, switchable:

| Mode | Where the data lives |
|---|---|
| `local` | the system disk |
| ZFS pool | a dataset on an existing pool |
| mount point | `/media/Hss-Data` |

Your data directory is marked by a `.hss-data` file holding a **uuid**.
That uuid is what tells HSS "this is my data directory, not someone
else's" — and it is kept in your portable configuration, so that a move
does not invent a new one and adopt the wrong folder.

Switch mode from the menu, under *NAS : gestion disque (ZFS, SMART)*.

---

## 6. What is yours, what is the machine's

This is the distinction the whole backup design rests on, and it is
worth two minutes.

A running installation accumulates two kinds of state.

**What is yours.** Your files, your databases, your passwords, your
choices, the configuration you edited, the cameras you added. This
follows you. It goes into the archive.

**What is the machine's.** Its IP address, its network interfaces, its
distribution, its disks, its host id. This is **observed again** at
every install, and **never restored**.

> Restoring the machine's state elsewhere would put the *old* machine's
> address on the new one: a restore that looks successful and breaks in
> silence. That is why the two halves are separated at the source
> rather than sorted out afterwards.

Concretely, in the project directory:

| | |
|---|---|
| `user/user.env`, `user/user.config` | **portable** — follows you, backed up, restored |
| `user/machine.env` | **local** — re-observed at each deploy, never restored |

---

## 7. Backing up and restoring

> ### 🚧 In development
>
> The archive and its restore path are **not finished**. This section
> describes the design that is being built, so you know what to
> expect — not a feature you can use today. Follow the
> [repository](https://github.com/sabeklabs-coder/home-services-server)
> for the release that brings it.

### One archive, not several

Everything that is yours goes into a single file: **`hss-user.tar`**.

Not one archive per category. Splitting "data" from "secrets" would
mean judging every file one by one — and that judgement is exactly what
once let a plaintext password through.

### Databases are dumped, not copied

Copying a running database is not a backup: you catch an inconsistent
snapshot. The three database engines are dumped, and a dump has the
side benefit of surviving a major version change.

### Credentials and the services that hold them

A HSS installation holds logins that live **inside** the services —
your Nextcloud account, the AdGuard administrator, the Vaultwarden
vault, the mail accounts. These are not in a configuration file; they
are rows in the service's own database.

The archive carries them, because it carries the database dumps that
hold them. Which is also why a public installer must ship **nothing**
of them: a fresh install starts with empty services, and you create the
first account yourself.

### Restore refuses a non-empty installation

Restoring over a running installation would merge two states and give
you neither. Restore checks first, and refuses if the installation is
not fresh.

---

## 8. Moving to another machine

> ### 🚧 In development — see section 7.

The intended sequence:

1. On the old machine, build the archive. The databases are dumped
   **before** anything is removed.
2. Copy `hss-user.tar` somewhere safe — not on the machine you are
   about to wipe.
3. Install HSS on the new machine with the published `.run`.
4. **At the very start**, the installer asks whether you want to
   restore your data. Answer yes and point it at `hss-user.tar`.
5. The deployment continues normally and **re-observes** everything
   that belongs to the new machine: address, network, distribution,
   hardware.

If the restore fails, the installation continues as a fresh one rather
than stopping half-way.

---

## 9. Troubleshooting

### Start here, always

```bash
hss doctor
```

It changes nothing and names what is wrong. Most of what follows is a
specific case of its output.

### A service will not start

```bash
hss <stack> logs
hss <stack> status
```

The three usual causes, in order of frequency:

1. **A missing secret.** `hss secrets etat`, then `hss secrets gen`.
2. **A missing configuration file.** `hss socle etat`, then
   `hss socle gen`.
3. **Directory ownership.** A container writes as a specific uid, and
   a directory Docker created as `root:root` will be refused —
   PostgreSQL is strict about this. The permissions tool reapplies the
   expected owners.

### Port 53 is taken

HSS puts AdGuard Home and Unbound on port 53. On a system where
`systemd-resolved` already listens there, the conflict has to be
resolved before AdGuard can come up. The deployment reports it by name.

### No network after a mode change

Use the *Réparer le réseau (DNS / IP fixe)* menu entry. If you have
lost remote access, you need a local keyboard — which is why section 1
asks you to plan for one.

### Nothing resolves on the local network

The machine is a DNS resolver. If its own resolution is broken,
everything downstream looks broken too. Check the resolver before
blaming the service.

---

## 10. Uninstalling

The manager includes a cleanup path that stops the stacks, removes the
containers and networks, and takes out the `hss` link in
`/usr/local/bin`.

**It does not remove your data**, and that is deliberate. Your data
directory and your archive are yours; a cleanup tool is not the place
to decide they should disappear.

The system configuration HSS wrote — fixed IP, firewall rules, DNS on
port 53 — does **not** revert on its own. If you want the machine back
as it was, reinstall the operating system. It is faster, and it is the
only way to be sure.

---

*Found something wrong, or missing, in this guide? Open an issue. For a
security problem, [SECURITY.md](../../SECURITY.md) instead — not a
public issue.*
