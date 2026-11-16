---
name: sitequest
description: Host websites, servers and domains on Sitequest (EU hosting, site.quest) through its MCP server. Picks between webspace and VPS, launches WordPress, TYPO3, Joomla, Drupal or a static site, points a domain with DNS and SSL, sets up services and game servers on a VPS, and deploys from GitHub.
when_to_use: The user mentions Sitequest or site.quest, or wants to host a website, CMS, app, game server or domain there, or asks what an API key for Sitequest needs.
---

# Sitequest hosting

Sitequest is a European hosting provider: VPS, webspaces (managed web hosting with a
one-click CMS), domains with DNS. Data centers: NTT FRA1 in Frankfurt (DE) and Skylink in
Eygelshoven (NL). Everything is managed through the `sitequest` MCP server of this plugin.

The server sends its own safety rules when it connects (confirmation with `confirm: true`,
backups before destructive steps, costs, lockout, DNS, secrets). Follow them; this skill does
not repeat them. It adds the product knowledge and the multi-step workflows.

## Pick the product

| The user wants | Product | Why |
|---|---|---|
| A website, blog, shop or company site with WordPress, TYPO3, Joomla or Drupal | Webspace | Installed and tuned for them, PHP 8.2–8.5, MariaDB 11, free SSL, unlimited traffic |
| A static site, SPA or the output of Astro, Hugo, Next export | Webspace (`STATIC`) | No server to maintain |
| To try it out without paying | Free webspace (`webspace_claim_free`) | 1 GB, 1 database, Sitequest subdomain only, no own domain |
| Docker, a Node/Python/Go app, a database, a VPN, a bot, a game server, Windows | VPS | Full root, any service |
| Only a domain, DNS or email records | Domain | `check_domain`, `register_domain`, DNS tools |

When in doubt for a website, start with a webspace: it is cheaper to run and needs no
server administration. Move to a VPS when the user needs their own processes or ports.

## Prices and sizes

Never quote prices from memory. Read them with `vps_get_pricing`, `get_domain_pricing` or
`check_domain`, and show the gross amount before you ask for confirmation. VPS and webspaces
come in ready-made sizes S, M, L, XL or as a custom configuration; resources can be raised
later without reinstalling or moving.

## The API key decides what you can do

Tools appear only when the user's API key has the scope for them. If a tool you need is
missing, do not work around it: tell the user which scope to add to the key at
https://site.quest/dashboard/api/. `provision` includes everything except `exec`; running
commands or writing files always needs `exec` explicitly.

| Job | Scopes |
|---|---|
| Look around, answer questions | `vps:read`, `webspace:read`, `domains:read` |
| New website with CMS and own domain | `webspace:provision`, `domains:provision` (new domain) or `domains:read` (existing) |
| Change PHP, reinstall CMS, link domains | `webspace:manage` |
| Edit files or run commands on a webspace | `webspace:exec` |
| New VPS and set up a service | `vps:provision`, `vps:exec` |
| Firewall, backups, power | `vps:manage` |
| DNS records, nameservers, DNSSEC | `domains:manage` |
| Upgrade a size | `vps:scale` or `webspace:scale` |

## Workflows

Read the one that matches the task before you start:

- [Website on a webspace](workflows/website.md): CMS or static site, own domain, SSL.
- [Service on a VPS](workflows/vps-service.md): order, first login, set up, firewall, DNS.
- [Game server](workflows/game-server.md): pick the host, size, ports, domain for players.
- [Domains and DNS](workflows/domains-dns.md): register, transfer, records, mail.
- [Deploy from GitHub](workflows/deploy-github.md): Actions for webspaces and VPS.

## Where to send the user

- Dashboard: https://site.quest/dashboard/
- Docs: https://site.quest/en/docs/ (German: /de/docs/)
- Step-by-step tutorials for apps and game servers: https://site.quest/en/docs/tutorials/
- Moving an existing site: https://site.quest/en/migration/ (free migration plan)
