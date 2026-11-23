# Sitequest MCP Server

A remote [Model Context Protocol](https://modelcontextprotocol.io/) (MCP) server for managing VPS servers, webspaces, and domains on [Sitequest](https://site.quest). Lets AI assistants provision, monitor, and configure infrastructure through natural language.

## Features

- **VPS Management** -- List, create, monitor, power control, OS reinstall, resize
- **Webspace Hosting** -- Provision shared hosting, install a CMS (WordPress, Joomla, Drupal, TYPO3 or static), link domains, manage PHP versions and databases
- **SSH & File Operations** -- Execute commands, read/write files, manage SSH security on both VPS and webspaces (jailed)
- **Firewall & Backups** -- Configure firewall rules, create/restore/delete backups of VPS and webspaces, automatic backups on a schedule
- **Domain Management** -- Register, transfer, configure DNS records, WHOIS privacy, DNSSEC
- **Billing Integration** -- Provision resources with automatic payment via saved mandate
- **Sign-in or API key** -- Claude and ChatGPT connect by signing in (OAuth 2.1); other clients use an API key
- **Scope-Based Access** -- Fine-grained permissions per tool category, for API keys and connected apps alike

## Quickstart

### Claude and ChatGPT: sign in

No API key needed. Add `https://site.quest/mcp` as a custom connector, then sign in with your Sitequest account and choose what the app may do:

- **Claude** -- Settings → Connectors → Add custom connector.
- **ChatGPT** -- turn on Developer mode under Settings → Apps & Connectors → Advanced settings, then Create with authentication OAuth.

You manage connected apps in the dashboard under API / MCP. Step-by-step guide: [Connect Claude or ChatGPT](https://site.quest/en/docs/api/mcp/).

### 1. Get an API Key

Create an API key in the [Sitequest Dashboard](https://site.quest/dashboard/api/) with the scopes you need.

### 2. Connect Your Client

**Claude Code (plugin, recommended)** -- One install sets up the MCP server and the `sitequest` skill:

```bash
claude plugin marketplace add Sitequest-Software/sitequest-mcp
claude plugin install sitequest@sitequest
```

Or inside Claude Code: `/plugin marketplace add Sitequest-Software/sitequest-mcp`, then `/plugin install sitequest@sitequest`. Claude Code asks for your API key when the plugin is enabled and keeps it in secure storage.

The skill teaches Claude which product fits a task (webspace or VPS), which API key scopes a job needs, and the workflows for websites with a CMS and your domain, services and game servers on a VPS, domains and DNS, and deploys from GitHub. See [`skills/sitequest/`](skills/sitequest/).

**VS Code / GitHub Copilot** -- Create `.vscode/mcp.json` in your workspace:

```json
{
  "servers": {
    "sitequest": {
      "type": "http",
      "url": "https://site.quest/mcp",
      "headers": {
        "Authorization": "Bearer ${input:sitequest-api-key}"
      }
    }
  },
  "inputs": [
    {
      "id": "sitequest-api-key",
      "type": "promptString",
      "description": "Sitequest API key",
      "password": true
    }
  ]
}
```

**Claude Desktop** -- Add to `claude_desktop_config.json`:

```json
{
  "mcpServers": {
    "sitequest": {
      "type": "streamableHttp",
      "url": "https://site.quest/mcp",
      "headers": {
        "Authorization": "Bearer YOUR_API_KEY"
      }
    }
  }
}
```

**Cursor / Windsurf** -- Add to MCP settings:

```json
{
  "mcpServers": {
    "sitequest": {
      "url": "https://site.quest/mcp",
      "headers": {
        "Authorization": "Bearer YOUR_API_KEY"
      }
    }
  }
}
```

**Test with curl** -- Replace `YOUR_API_KEY` with a key from the dashboard:

```bash
curl -s https://site.quest/mcp \
  -H "Authorization: Bearer YOUR_API_KEY" \
  -H "Content-Type: application/json" \
  -H "Accept: application/json, text/event-stream" \
  -d '{"jsonrpc":"2.0","id":1,"method":"tools/call","params":{"name":"vps_list","arguments":{}}}'
```

Use `"method":"tools/list"` (without `params`) to see the tools your key can call.

## Endpoint

| | |
|---|---|
| **URL** | `POST https://site.quest/mcp` |
| **Transport** | Streamable HTTP (stateless) |
| **Protocol** | JSON-RPC 2.0 / MCP `2025-03-26` |
| **Auth** | OAuth 2.1 sign-in (discovery at `/.well-known/oauth-protected-resource/mcp`) or `Authorization: Bearer <api-key>` |

## Available Tools

The tools a client sees depend on the scopes of its API key. This list is checked against the server on every change.

### Pricing and availability (every key)

| Tool | Description |
|------|-------------|
| `domain_get_pricing` | Price list of all TLDs: registration and renewal (availability: domain_check) |
| `domain_check` | Check if a domain is available for registration |
| `vps_get_pricing` | Get VPS component sell prices grouped by hostsystem |

### VPS

| Tool | Scope | Description |
|------|-------|-------------|
| `vps_list` | `vps:read` | List all VPS instances accessible to the authenticated API key |
| `vps_get` | `vps:read` | Detailed VPS info: live status, configuration and subscription |
| `vps_get_monitoring` | `vps:read` | Get monitoring data for a VPS: CPU, memory, and ping history over time, plus downtime incident statistics |
| `vps_get_traffic` | `vps:read` | Network traffic this month: usage, limit, throttling and a daily log |
| `vps_list_backups` | `vps:read` | List all backups for a VPS |
| `vps_get_backup_schedule` | `vps:read` | Automatic backups of a VPS: on or off, frequency, time, how many are kept, next and last run |
| `vps_list_files` | `vps:files` | List directory contents on a VPS via SFTP |
| `vps_read_file` | `vps:files` | Read a file on a VPS via SFTP |
| `vps_power` | `vps:manage` | Execute a power action on a VPS: start, stop, or restart |
| `vps_mount_iso` | `vps:manage` | Mount or unmount an ISO image on a VPS |
| `vps_set_label` | `vps:manage` | Rename a VPS (changes the local display name only) |
| `vps_get_ssh_security` | `vps:manage` | SSH security settings: password login, banner, key exchange, ciphers, OpenSSH version |
| `vps_set_ssh_security` | `vps:manage` | Change SSH hardening: password login, banner, post-quantum key exchange, legacy ciphers and MACs |
| `vps_update_openssh` | `vps:manage` | Run the OS package manager to install the latest OpenSSH on the VM (apt/dnf/zypper) |
| `vps_rescue_password_auth` | `vps:manage` | Rescue: re-enable password login through the hypervisor when SSH is unreachable |
| `vps_list_ssh_keys` | `vps:manage` | List the SSH keys Sitequest manages for logging in to a VPS, as added with vps_upload_ssh_key or vps_generate_ssh_key |
| `vps_delete_ssh_key` | `vps:manage` | Delete an SSH key from a VPS |
| `vps_mkdir` | `vps:manage` | Create a directory on a VPS over SFTP |
| `vps_delete_path` | `vps:manage` | Delete a file or directory on a VPS via SSH |
| `vps_create_backup` | `vps:manage` | Create a new backup of a VPS |
| `vps_restore_backup` | `vps:manage` | Restore a backup on a VPS |
| `vps_delete_backup` | `vps:manage` | Delete a VPS backup for good and free its backup slot |
| `vps_set_backup_schedule` | `vps:manage` | Turn automatic backups on or off: daily or weekly, at which hour, how many are kept (requires `confirm`) |
| `vps_get_firewall` | `vps:manage` | Read the host firewall: tool, active state, default policies and rules |
| `vps_manage_firewall` | `vps:manage` | Change a VPS's host firewall over SSH |
| `vps_reset_password` | `vps:exec` | Generate a new root password (requires `confirm`) |
| `vps_exec` | `vps:exec` | Execute a one-shot SSH command on a VPS and return { stdout, stderr, exitCode } |
| `vps_generate_ssh_key` | `vps:exec` | Have Sitequest generate a new SSH key pair for a VPS and add its public key to the VPS's managed keys |
| `vps_upload_ssh_key` | `vps:exec` | Upload an existing SSH public key to a VPS |
| `vps_write_file` | `vps:exec` | Write content to a file on a VPS via SFTP |
| `vps_rename` | `vps:exec` | Rename or move a file/directory on a VPS via SSH |
| `vps_chmod` | `vps:exec` | Change file permissions on a VPS via SSH |
| `vps_upgrade` | `vps:scale` | Upgrade CPU, RAM, disk, backup slots or network speed (requires `confirm`) |
| `vps_cancel` | `vps:cancel` | Cancel a VPS subscription at the end of the current billing period |
| `vps_uncancel` | `vps:cancel` | Reactivate a cancelled VPS subscription before it expires |
| `vps_reinstall_os` | `vps:provision` | Reinstall the operating system (wipes the disk, requires `confirm`) |
| `vps_create` | `vps:provision` | Create a new VPS (charges the saved payment method, requires `confirm`) |

### Webspaces

Managed web hosting with isolated PHP/MariaDB sites. File and exec tools run as the unprivileged site user, jailed to the site's home directory: they cannot affect other sites on the same node.

| Tool | Scope | Description |
|------|-------|-------------|
| `webspace_list` | `webspace:read` | List all webspaces accessible by the API key |
| `webspace_get` | `webspace:read` | Detailed webspace info: linked domains and live disk usage |
| `webspace_get_ssh_info` | `webspace:read` | SSH connection details: host, port, username, host key fingerprint |
| `webspace_list_backups` | `webspace:read` | List the backups of a webspace, newest first, with its backup slots and the schedule of its automatic backups |
| `webspace_list_files` | `webspace:files` | List a directory inside a webspace as its unprivileged site user, jailed to the home directory |
| `webspace_read_file` | `webspace:files` | Read a file inside the webspace (jailed) |
| `webspace_set_php` | `webspace:manage` | Change the PHP version: 8.2, 8.3, 8.4 or 8.5 (requires `confirm`) |
| `webspace_set_label` | `webspace:manage` | Rename a webspace (changes the local display name only) |
| `webspace_install_cms` | `webspace:manage` | Install WordPress, Joomla, Drupal, TYPO3 or a static site (wipes the web root, requires `confirm`) |
| `webspace_link_domain` | `webspace:manage` | Link a domain from the account: DNS record, web server and Let's Encrypt certificate |
| `webspace_unlink_domain` | `webspace:manage` | Unlink a domain from a webspace by the WebspaceDomain link ID |
| `webspace_reset_db_password` | `webspace:manage` | Reset the MariaDB password for a webspace's database |
| `webspace_mkdir` | `webspace:manage` | Create a directory inside a webspace as its unprivileged site user, jailed to the home directory |
| `webspace_delete_path` | `webspace:manage` | Delete a file or directory inside a webspace (jailed) |
| `webspace_list_ssh_keys` | `webspace:manage` | List the SSH public keys in a webspace's ~/.ssh/authorized_keys, including the key the dashboard's web terminal uses |
| `webspace_delete_ssh_key` | `webspace:manage` | Remove an SSH key from a webspace's authorized_keys by its fingerprint id |
| `webspace_create_backup` | `webspace:manage` | Back up a webspace's files and databases to a separate backup server (requires `confirm`) |
| `webspace_restore_backup` | `webspace:manage` | Restore a backup of a webspace: everything, files only or database only (requires `confirm`) |
| `webspace_delete_backup` | `webspace:manage` | Delete a webspace backup for good and free its backup slot (requires `confirm`) |
| `webspace_set_backup_schedule` | `webspace:manage` | Turn automatic backups on or off: daily or weekly, at which hour, how many are kept (requires `confirm`) |
| `webspace_exec` | `webspace:exec` | Run a shell command as the webspace's unprivileged site user (jailed) |
| `webspace_write_file` | `webspace:exec` | Create or overwrite a file inside a webspace as its site user, jailed to the home directory |
| `webspace_rename` | `webspace:exec` | Rename or move a file or directory inside a webspace as its site user, jailed to the home directory |
| `webspace_chmod` | `webspace:exec` | Change the permission bits of one file or directory inside a webspace (not recursive), as its site user, jailed to the home directory |
| `webspace_add_ssh_key` | `webspace:exec` | Add an SSH public key to a webspace's ~/.ssh/authorized_keys, so its owner can log in over SSH and SFTP as the site user |
| `webspace_upgrade` | `webspace:scale` | Increase diskGb and/or databases on a paid webspace |
| `webspace_cancel` | `webspace:cancel` | Cancel a webspace subscription at the end of the current billing period |
| `webspace_uncancel` | `webspace:cancel` | Reactivate a cancelled webspace subscription before it expires |
| `webspace_create` | `webspace:provision` | Create a paid webspace (charges the saved payment method) |
| `webspace_claim_free` | `webspace:provision` | Claim the free webspace every account gets once: 1 GB storage, 1 database, 10 GB traffic, no own domain |
| `webspace_delete` | `webspace:provision` | Delete a free webspace permanently |

### Domains

| Tool | Scope | Description |
|------|-------|-------------|
| `domain_list` | `domains:read` | List all domains accessible to the authenticated API key |
| `domain_get` | `domains:read` | Detailed domain info: DNS records, nameservers, registrar data, subscription |
| `dns_list_records` | `domains:read` | List the DNS records of a domain's zone on Sitequest's nameservers: per record its recordId, type, name, value, TTL and priority |
| `dns_add_record` | `domains:manage` | Add a DNS record to a domain's zone on Sitequest's nameservers |
| `dns_edit_record` | `domains:manage` | Replace the value of one existing DNS record; its type, name and TTL stay |
| `dns_delete_record` | `domains:manage` | Delete a DNS record (requires `confirm`) |
| `domain_set_nameservers` | `domains:manage` | Replace all nameservers of a domain at the registry |
| `domain_set_transfer_lock` | `domains:manage` | Lock or unlock a domain against transfers to another registrar |
| `domain_set_whois_privacy` | `domains:manage` | Hide or show the owner's name, email and address in the public WHOIS and RDAP output of a domain; when hidden, a privacy contact is published instead |
| `domain_set_dnssec` | `domains:manage` | Turn DNSSEC on or off for a domain |
| `domain_get_authcode` | `domains:manage` | Get the auth code (transfer key) for a domain |
| `domain_cancel` | `domains:cancel` | Cancel a domain subscription at the end of the current billing period |
| `domain_uncancel` | `domains:cancel` | Reactivate a cancelled domain subscription before it expires |
| `domain_register` | `domains:provision` | Register a new domain (charges the saved payment method, requires `confirm`) |
| `domain_transfer` | `domains:provision` | Transfer a domain to Sitequest (auth code and `confirm` required) |

### Orders

| Tool | Scope | Description |
|------|-------|-------------|
| `order_get` | `vps:scale` or `webspace:scale` or `domains:provision` | Get the status of an order by its ID or token |
| `order_list` | `vps:scale` or `webspace:scale` or `domains:provision` | List this account's orders, newest first: new VPS, webspaces and domains, upgrades and transfers |

## Scopes

Scopes follow `resource:action`. Resources: `vps`, `webspace`, `domains`.

| Action | Allows | Includes |
|--------|--------|----------|
| `read` | List and view resources, status and metrics, backups and their schedule | |
| `files` | List and read files (including any secrets in them) | `read` |
| `manage` | Change settings: power, firewall, PHP, CMS, DNS, linked domains; create, restore and delete backups and set their schedule | `read`, `files` |
| `exec` | Run commands, write files, add SSH keys | `read`, `files` |
| `scale` | Upgrade resources (charges the payment method) | `read` |
| `cancel` | Cancel and reactivate subscriptions | `read` |
| `provision` | Create, reinstall, delete, register, transfer (charges the payment method) | everything except `exec` |

Domains support `read`, `manage`, `cancel` and `provision`. `exec` is never implied: only the wildcard `*` includes it. Keys can also be restricted to specific VPS, webspace or domain IDs, and a key never exceeds its owner's own access.

## Rate Limits

60 requests per minute per API key by default. Every response carries the rate limit headers:

- `X-RateLimit-Limit`
- `X-RateLimit-Remaining`
- `X-RateLimit-Reset`

## Safety

All destructive operations (reinstall OS, restore or delete backups, register/cancel domains, etc.) require an explicit `confirm: true` parameter. The server will not execute them without confirmation.

## Documentation

Full documentation: [site.quest/docs/api/mcp](https://site.quest/en/docs/api/mcp)

## License

MIT
