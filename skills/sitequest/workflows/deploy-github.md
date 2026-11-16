# Deploy from GitHub

Sitequest publishes GitHub Actions that deploy over the REST API with an API key, no SSH
keys to manage. Store the key as a repository secret (for example `SITEQUEST_API_KEY`);
never write it into the workflow file. The key needs `webspace:exec` or `vps:exec` and
should be limited to that one resource.

## Webspace

`Sitequest-Software/sitequest-deploy-webspace-action` uploads a build directory as a
tar.gz and swaps it atomically into the webspace.

```yaml
- uses: Sitequest-Software/sitequest-deploy-webspace-action@v1
  with:
    api-key: ${{ secrets.SITEQUEST_API_KEY }}
    webspace-id: <id from the dashboard URL or webspace_list>
    source: dist          # local build directory
    target: public_html   # under the webspace home
```

Docs: https://site.quest/en/docs/integrations/deploy-webspace/

## VPS

`Sitequest-Software/sitequest-deploy-vps-action` makes an atomic release: it extracts into
`<target-base>/releases/<run-id>/`, swaps the `current` symlink, can restart a systemd unit
and keeps the last releases for rollback.

```yaml
- uses: Sitequest-Software/sitequest-deploy-vps-action@v1
  with:
    api-key: ${{ secrets.SITEQUEST_API_KEY }}
    vps-id: <id from vps_list>
    source: dist
    target-base: /srv/myapp
    restart-service: myapp.service
```

Docs: https://site.quest/en/docs/integrations/deploy-vps/

## Run a command

`Sitequest-Software/sitequest-exec-action` runs a command on a VPS or webspace, for example
a migration after the deploy. Docs: https://site.quest/en/docs/integrations/exec/

## Setting it up for the user

1. Get the resource ID with `webspace_list` or `vps_list`.
2. Write the workflow into `.github/workflows/deploy.yml` of their repository.
3. Tell them to create a key with only the needed scope at https://site.quest/dashboard/api/
   and add it as the secret `SITEQUEST_API_KEY` under Settings → Secrets and variables →
   Actions.
