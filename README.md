# Sitequest MCP Server

A remote [Model Context Protocol](https://modelcontextprotocol.io/) (MCP) server for managing VPS servers, webspaces, and domains on [Sitequest](https://site.quest). Lets AI assistants provision, monitor, and configure infrastructure through natural language.

## Features

- **VPS Management** -- List, create, monitor, power control, OS reinstall, resize
- **Webspace Hosting** -- Provision shared hosting, install CMS (WordPress, Joomla, TYPO3), link domains, manage PHP versions and databases
- **SSH & File Operations** -- Execute commands, read/write files, manage SSH security on both VPS and webspaces (jailed)
- **Firewall & Backups** -- Configure firewall rules, create/restore/delete backups
- **Domain Management** -- Register, transfer, configure DNS records, WHOIS privacy, DNSSEC
- **Billing Integration** -- Provision resources with automatic payment via saved mandate
- **Scope-Based Access** -- Fine-grained API key permissions per tool category

## Quickstart

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

**Cursor** -- Add to MCP settings:

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

See [examples/](examples/) for more client configurations.

## Endpoint

| | |
|---|---|
| **URL** | `POST https://site.quest/mcp` |
| **Transport** | Streamable HTTP (stateless) |
| **Protocol** | JSON-RPC 2.0 / MCP `2025-03-26` |
| **Auth** | `Authorization: Bearer <api-key>` |

## Available Tools

### Pricing (no scope required)

| Tool | Description |
|------|-------------|
| `get_domain_pricing` | List TLD pricing or check a specific domain's price |
| `check_domain` | Check domain availability (single or batch, up to 20 TLDs) |
| `get_vps_pricing` | Get VPS component pricing per hostsystem |

### VPS

| Tool | Scope | Description |
|------|-------|-------------|
| `list_vms` | `vps:read` | List all VPS with status, specs, and usage metrics |
| `get_vm` | `vps:read` | Detailed VPS info with live config and status |
| `get_vm_monitoring` | `vps:read` | CPU/memory/ping history and downtime stats |
| `get_vm_traffic` | `vps:read` | Current-month bandwidth and daily traffic log |
| `vm_power` | `vps:manage` | Start, stop, or restart a VPS |
| `vm_reinstall_os` | `vps:manage` | Reinstall OS (destructive, requires `confirm`) |
| `vm_mount_iso` | `vps:manage` | Mount or unmount an ISO image |
| `vm_reset_password` | `vps:manage` | Generate new root password (requires `confirm`) |
| `rename_vm` | `vps:manage` | Update display name |
| `exec_command` | `vps:manage` | Execute a one-shot SSH command |
| `list_files` | `vps:manage` | List directory contents via SFTP |
| `read_file` | `vps:manage` | Read file content via SFTP (max 10 MB) |
| `write_file` | `vps:manage` | Write file content via SFTP (max 10 MB) |
| `ssh_security` | `vps:manage` | Get/set SSH security settings with rescue fallback |
| `list_backups` | `vps:manage` | List all backups for a VPS |
| `create_backup` | `vps:manage` | Create a new backup (requires `confirm`) |
| `restore_backup` | `vps:manage` | Restore from backup (destructive, requires `confirm`) |
| `delete_backup` | `vps:manage` | Delete a backup (requires `confirm`) |
| `get_firewall` | `vps:manage` | Get firewall status and rules |
| `manage_firewall` | `vps:manage` | Add/remove rules, enable/disable firewall |
| `create_vm` | `vps:provision` | Create new VPS (charges saved mandate, requires `confirm`) |
| `cancel_vm` | `vps:provision` | Cancel VPS subscription at end of billing period |
| `uncancel_vm` | `vps:provision` | Reactivate a cancelled VPS before expiry |
| `upgrade_vm` | `vps:provision` | Upgrade resources with pro-rated charge (requires `confirm`) |

### Webspaces

Shared web hosting with isolated PHP/MariaDB sites. SFTP and exec tools operate as the unprivileged site Linux user, jailed to the site's home directory -- they cannot affect other sites on the same node.

| Tool | Scope | Description |
|------|-------|-------------|
| `webspace_list` | `webspace:read` | List all webspaces with status, plan, CMS, and quota usage |
| `webspace_get` | `webspace:read` | Detailed webspace info including linked domains and live disk usage |
| `webspace_get_ssh_info` | `webspace:read` | SSH connection details (host, port, username, host key fingerprint) |
| `webspace_list_ssh_keys` | `webspace:read` | List SSH public keys in `authorized_keys` |
| `webspace_create` | `webspace:provision` | Provision a paid webspace (charges saved mandate) |
| `webspace_claim_free` | `webspace:provision` | Claim the one-shot free-tier webspace for the account |
| `webspace_upgrade` | `webspace:provision` | Increase disk and/or database count (no downgrades) |
| `webspace_delete` | `webspace:provision` | Delete a webspace permanently (requires `confirm`) |
| `webspace_set_label` | `webspace:manage` | Update the display name |
| `webspace_set_php` | `webspace:manage` | Change PHP version (8.1 -- 8.5, requires `confirm`) |
| `webspace_install_cms` | `webspace:manage` | Install/reinstall WordPress, Joomla, TYPO3, or static (wipes docroot, requires `confirm`) |
| `webspace_link_domain` | `webspace:manage` | Attach a user-owned domain and issue a Let's Encrypt cert |
| `webspace_unlink_domain` | `webspace:manage` | Detach a linked domain and remove its vhost (requires `confirm`) |
| `webspace_reset_db_password` | `webspace:manage` | Reset MariaDB password (returned once, requires `confirm`) |
| `webspace_exec` | `webspace:manage` | Run a one-shot SSH command in the jailed shell |
| `webspace_list_files` | `webspace:manage` | List directory contents via jailed SFTP |
| `webspace_read_file` | `webspace:manage` | Read a file via jailed SFTP (max 10 MB) |
| `webspace_write_file` | `webspace:manage` | Write a file via jailed SFTP (max 10 MB) |
| `webspace_mkdir` | `webspace:manage` | Create a directory in the jail |
| `webspace_rename` | `webspace:manage` | Rename / move within the jail |
| `webspace_delete_path` | `webspace:manage` | Delete a file or directory in the jail (requires `confirm`) |
| `webspace_chmod` | `webspace:manage` | Change permissions on a file/directory |
| `webspace_add_ssh_key` | `webspace:manage` | Add an authorized SSH public key |
| `webspace_delete_ssh_key` | `webspace:manage` | Remove an authorized SSH key by fingerprint (requires `confirm`) |

### Domains

| Tool | Scope | Description |
|------|-------|-------------|
| `list_domains` | `domains:read` | List all domains with status, DNS count, expiry |
| `get_domain` | `domains:read` | Detailed domain info with DNS records and registrar data |
| `list_dns_records` | `domains:read` | List DNS records for a domain |
| `add_dns_record` | `domains:manage` | Create a DNS record (A, AAAA, CNAME, MX, TXT, SRV, etc.) |
| `edit_dns_record` | `domains:manage` | Update an existing DNS record |
| `delete_dns_record` | `domains:manage` | Remove a DNS record (requires `confirm`) |
| `set_nameservers` | `domains:manage` | Update domain nameservers |
| `set_transfer_lock` | `domains:manage` | Enable or disable transfer lock |
| `set_whois_privacy` | `domains:manage` | Enable or disable WHOIS privacy |
| `set_dnssec` | `domains:manage` | Enable or disable DNSSEC |
| `get_authcode` | `domains:manage` | Retrieve domain auth code for transfer |
| `register_domain` | `domains:provision` | Register new domain (charges mandate, requires `confirm`) |
| `transfer_domain` | `domains:provision` | Transfer domain to Sitequest (requires auth code + `confirm`) |
| `cancel_domain` | `domains:provision` | Cancel domain at end of billing period |
| `uncancel_domain` | `domains:provision` | Reactivate a cancelled domain before expiry |

### Orders

| Tool | Scope | Description |
|------|-------|-------------|
| `get_order_status` | `vps:provision` or `domains:provision` | Track order by ID or token |

## Scopes

API keys use granular scopes to control access:

| Scope | Access |
|-------|--------|
| `vps:read` | View VPS instances and metrics |
| `vps:manage` | Power control, SSH, files, backups, firewall |
| `vps:provision` | Create, upgrade, cancel VPS |
| `domains:read` | View domains and DNS records |
| `domains:manage` | Edit DNS, nameservers, WHOIS, DNSSEC |
| `domains:provision` | Register, transfer, cancel domains |
| `webspace:read` | View webspaces, quotas, SSH connection info |
| `webspace:manage` | Manage PHP, CMS, domains, files (SFTP/exec), SSH keys |
| `webspace:provision` | Create, upgrade, delete webspaces |

Keys can also be restricted to specific VPS, webspace, or domain IDs for narrower access.

## Rate Limits

60 requests per minute per API key. Rate limit headers are included in every response:

- `X-RateLimit-Limit`
- `X-RateLimit-Remaining`
- `X-RateLimit-Reset`

## Safety

All destructive operations (reinstall OS, delete backups, register/cancel domains, etc.) require an explicit `confirm: true` parameter. The server will not execute them without confirmation.

## Documentation

Full documentation: [site.quest/docs/api/mcp](https://site.quest/en/docs/api/mcp)

## License

MIT
