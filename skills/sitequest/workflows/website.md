# Website on a webspace

For WordPress, TYPO3, Joomla, Drupal or a static site. Ask once at the start: which CMS
(or static), which domain, and whether the user already has a webspace.

## 1. Webspace

- Existing: `webspace_list`, then `webspace_get` for the one the user names.
- Free trial: `webspace_claim_free`. It runs on its Sitequest subdomain and **cannot link
  an own domain**; say so before you start if the user wants one.
- New paid webspace: pick a size with the user (S is enough for a blog or company site,
  M for a shop or a media-heavy site), show the price, get confirmation, then
  `webspace_create`. Poll `order_get` until the order is done.

## 2. CMS

`webspace_install_cms` with `WORDPRESS`, `TYPO3`, `JOOMLA`, `DRUPAL` or `STATIC`.
It **wipes the web root and resets the database**: on a webspace that already has content,
take a backup first (see [Backups](#5-backups)) and wait until it is finished. Then confirm
with the user and install. Poll `webspace_get` (at least 10 s apart) until `cms` shows the
new CMS.

What the user gets: the current CMS version, its own MariaDB database, LiteSpeed Cache
active (not for static), an admin account with the email of their Sitequest account, and
sign-in to the CMS backend from the dashboard without a second password.

## 3. Domain

Linking needs a **paid webspace** and the domain **in the user's Sitequest account**.

- Domain still elsewhere: transfer it first (see [Domains and DNS](domains-dns.md)), or
  register a new one.
- Then `webspace_link_domain` with the domain, on the apex (`example.com`) or a
  subdomain (`www`, `blog`). Sitequest sets the A record, configures the web server and
  issues a free Let's Encrypt certificate for the domain and `www`.
- The certificate can lag until DNS has propagated. Check `webspace_get`; do not retry in a
  loop, tell the user it can take a few minutes.

## 4. PHP and files

- PHP version per webspace: `webspace_set_php` (8.2, 8.3, 8.4, 8.5). It restarts the
  webspace; check the CMS supports the version first, and take a backup on a live site.
- Files and commands: `webspace_list_files`, `webspace_read_file`, `webspace_write_file`,
  `webspace_exec` (runs as the site user inside its home directory; Git and WP-CLI are on
  board, Composer for TYPO3, Drush and Composer for Drupal).
- SSH for the user's own client: `webspace_get_ssh_info`, keys with `webspace_add_ssh_key`.

## 5. Backups

A backup holds the files and the databases of the webspace and is stored on a separate
backup server. Each one fills a backup slot: 1 on the free webspace, 2 on a paid one. More
slots are added in the dashboard (Resources area of the webspace), not through a tool.

- `webspace_list_backups` shows the backups, the slots (`slots`, `used`) and the schedule.
- `webspace_create_backup` starts one in the background. Poll `webspace_list_backups` (at
  least 10 s apart) until its status is `OK` before you go on with a risky change. With all
  slots taken it fails: ask the user which backup to delete (`webspace_delete_backup`).
- `webspace_restore_backup` brings back everything, the files only or the database only
  (`scope`). The state before the restore is saved by itself and can be restored in turn.
- For a site that is live, offer automatic backups: `webspace_set_backup_schedule`, daily
  or weekly at an hour the user picks. `keep` is how many automatic backups stay; leave one
  slot free for backups taken by hand.

## 6. Done

Open the domain over HTTPS and confirm the site answers. Summarise: webspace, CMS, domain,
certificate status, and where the admin account details are (dashboard, Admin Account).
