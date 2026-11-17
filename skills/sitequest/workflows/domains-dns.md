# Domains and DNS

## New domain

`domain_check` for availability and the gross price per year, then confirm with the user and
`domain_register`. Poll `order_get`. WHOIS privacy and DNSSEC are available per
domain (`domain_set_whois_privacy`, `domain_set_dnssec`).

## Move a domain to Sitequest

Needed before a domain can be linked to a webspace.

1. At the current provider: unlock the domain and get the auth code (EPP code).
2. `domain_transfer` with the auth code; confirm the price with the user first.
3. Poll `order_get`. Transfers can take several days, depending on the TLD and the
   old provider.
4. When it is done, turn the transfer lock back on (`domain_set_transfer_lock`).

Moving a domain away: `domain_get_authcode`, and disable DNSSEC before the nameservers change.

## DNS records

- Read first: `dns_list_records`. Change only what the task needs.
- `dns_add_record`, `dns_edit_record`, `dns_delete_record` for A, AAAA, CNAME, MX, TXT, SRV,
  CAA, NS, TLSA and SSHFP.
- No CNAME at the apex or next to other records of the same name. One SPF TXT per name.
- Changes take up to the TTL to show everywhere: say so instead of retrying.

## Website and server

- Webspace: `webspace_link_domain` sets the A record and SSL itself; do not add it by hand.
- VPS: A record (and AAAA) to the server's addresses with `dns_add_record`.

## Mail records

For mail on the domain from another provider, add the MX, SPF (TXT), DKIM (TXT) and DMARC
(TXT on `_dmarc`) records exactly as that provider gives them. Merge SPF into one record.
