# Service on a VPS

For Docker, an app, a database, a VPN, a bot or anything that needs its own processes.

## 1. Host and size

`vps_get_pricing` lists the component prices per hostsystem and calculates the total for a
configuration. The hostsystems (as of November 2026; the current list and processors are on
https://site.quest/en/vps/):

| Hostsystem | Processor | Location |
|---|---|---|
| `de_epyc5` | AMD EPYC 9355P (Zen 5) | Frankfurt |
| `de_epyc` | AMD EPYC 7443P (Zen 3) | Frankfurt |
| `de_ryzen` | AMD Ryzen 9 7950X3D (up to 5.7 GHz) | Frankfurt |
| `nl_ryzen` | AMD Ryzen 7 5800X | Eygelshoven |
| `nl_xeon` | Intel Xeon E5-2697 v4 | Eygelshoven |

Choose with the user:

- **Location:** Frankfurt (NTT FRA1, traffic included per month, more bookable) or
  Eygelshoven (Skylink, unlimited traffic).
- **Processor:** high single-thread clock (AMD Ryzen) for game servers and anything that
  answers single requests on one core; many cores (AMD EPYC) for containers, CI and several
  services side by side; the Intel Xeon host for background jobs and staging where memory
  matters more than speed.
- **Size:** S (2 cores, 4 GB) for a small app, bot or VPN; M (4 cores, 8 GB) for several
  services or Docker; L and XL for databases next to the app and busy sites. Cores, RAM
  and NVMe can be raised later without reinstalling (`vps_upgrade`).

Show the gross price, get confirmation, `vps_create`, then poll `get_order_status`.

## 2. First look

`vps_get` for the OS, IPs and state. Debian is the default; Ubuntu, AlmaLinux and Windows
Server are available (`vps_reinstall_os` wipes the disk: backup first).

## 3. Set up

Run the setup with `vps_exec`. Follow the server's own defaults (own user per service,
systemd units, automatic security updates, secrets mode 600). For common apps there are
tested guides to follow step by step: https://site.quest/en/docs/tutorials/
(Docker, nginx, Let's Encrypt, WordPress, Nextcloud, n8n, WireGuard, CyberPanel).

## 4. Firewall

`vps_get_firewall` first. Allow SSH (or RDP on Windows) and every port the service uses
**before** enabling it with `vps_manage_firewall`. DDoS protection for layer 4 and 7 is
included per IPv4 address.

## 5. Domain

Point the domain at the server: `add_dns_record` with an A record to the IPv4 (and AAAA to
the IPv6). For mail sent from the server, set the PTR record in the dashboard (reverse DNS).

## 6. Backups

Every VPS has two backup slots included: `vps_create_backup` once the service runs, and
before every risky change.

## 7. Done

Verify: the service runs (`systemctl status`), the port answers from outside, the domain
resolves. Summarise what you set up and which ports are open.
