# Publishing the Sitequest MCP server

Where the server and the Claude Code plugin are listed, and how to update each listing.
Order matters: the official registry first, because PulseMCP and Glama pick it up from there,
and the awesome-remote-mcp-servers list requires the Glama connector.

## 1. Official MCP Registry

`server.json` in this repository is the registry entry (name `quest.site/sitequest-hosting`).
Keep `version` in step with the server card at https://site.quest/mcp/server-card.

The namespace `quest.site` is proven with a DNS TXT record on `site.quest`. Run in Git Bash
(it needs OpenSSL 3):

```bash
# once: key pair; keep key.pem private and out of every repository
openssl genpkey -algorithm Ed25519 -out key.pem
PUBLIC_KEY="$(openssl pkey -in key.pem -pubout -outform DER | tail -c 32 | base64)"
echo "v=MCPv1; k=ed25519; p=${PUBLIC_KEY}"
```

Add that value as a TXT record on the apex `site.quest` (next to the SPF record; do not change
it), wait until `nslookup -type=TXT site.quest 1.1.1.1` shows it, then:

```bash
# mcp-publisher: https://github.com/modelcontextprotocol/registry/releases (Windows: mcp-publisher.exe on PATH)
MCP_PRIVATE_KEY="$(openssl pkey -in key.pem -noout -text | sed -n '/priv:/,/pub:/p' | sed '1d;$d' | tr -d ' :\n')" \
  mcp-publisher login dns --domain site.quest
mcp-publisher validate
mcp-publisher publish          # within five minutes of the login
curl "https://registry.modelcontextprotocol.io/v0.1/servers?search=quest.site"
```

To publish a new version: raise `version` here and in the server card, log in, publish.

## 2. Glama connector

Glama lists connectors under their registry name. After step 1, check
https://glama.ai/mcp/connectors/quest.site/sitequest-hosting. If it does not appear within a
few days, add the server at https://glama.ai/mcp/connectors with the endpoint
`https://site.quest/mcp`.

## 3. awesome-remote-mcp-servers

https://github.com/punkpeye/awesome-remote-mcp-servers: star the repository first (required),
fork it and add this entry to "☁️ Cloud Platforms", in alphabetical order (between Roar AI
and Vercel at the time of writing). The badge only resolves once the Glama connector exists.

```markdown
- [Sitequest](https://site.quest/en/api-mcp/) `https://site.quest/mcp`
  [![Sitequest MCP connector](https://glama.ai/mcp/connectors/quest.site/sitequest-hosting/badges/score.svg)](https://glama.ai/mcp/connectors/quest.site/sitequest-hosting)
  🔑 - Manage VPS, webspaces with one-click CMS, domains and DNS in EU data centers in Frankfurt and the Netherlands.
```

The list's CI sends an MCP `initialize` without a key; the endpoint answers 401 with a
`WWW-Authenticate: Bearer` challenge, which is how an API-key server is recognized.

## 4. Claude plugin directory (Anthropic)

The plugin in this repository (`.claude-plugin/`) is installable from its own marketplace
already. For the directory: https://claude.ai/directory/manage (needs a paid claude.ai plan;
Team/Enterprise: an Owner submits). Run `claude plugin validate . --strict` first.

- **Name:** Sitequest Hosting
- **Short description:** Run websites, servers and domains on Sitequest's EU hosting from Claude.
- **Description:** The Sitequest MCP server plus a skill: Claude picks between webspace and
  VPS, sets up WordPress, TYPO3, Joomla, Drupal or a static site on your domain, runs services
  and game servers on a VPS, manages DNS and wires up GitHub deploys. Your API key's scopes
  decide what Claude may do; it shows prices and asks before anything that costs money or
  deletes data. Data centers in Frankfurt (DE) and Eygelshoven (NL).
- **Links:** https://site.quest/en/api-mcp/ · https://site.quest/en/docs/api/mcp/ ·
  https://site.quest/en/legal/privacy/

## 5. Others

- **PulseMCP:** submissions paused (checked November 2026); it imports from the official
  registry once it reopens.
- **mcpservers.org:** lists this repository already.
- **Smithery:** the publishing page for hosted servers could not be verified (November 2026).
