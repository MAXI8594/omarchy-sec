# Deploy Wazuh Docker in single node configuration

This deployment is defined in the `docker-compose.yml` file with one Wazuh manager containers, one Wazuh indexer containers, and one Wazuh dashboard container. It can be deployed by following these steps: 

1) Increase max_map_count on your host (Linux). This command must be run with root permissions:
```
$ sysctl -w vm.max_map_count=262144
```
2) Run the certificate creation script:
```
$ docker compose -f generate-indexer-certs.yml run --rm generator
```
3) Start the environment with docker compose:

- In the foregroud:
```
$ docker compose up
```
- In the background:
```
$ docker compose up -d
```

The environment takes about 1 minute to get up (depending on your Docker host) for the first time since Wazuh Indexer must be started for the first time and the indexes and index patterns must be generated.

## Credentials

`docker-compose.yml` reads `INDEXER_PASSWORD`, `API_PASSWORD` and `DASHBOARD_PASSWORD` from a `.env` file in this
directory (not committed — see `.env.example`). Running `../../setup.sh` from the repo root generates one with
random passwords on first run, and regenerates the matching bcrypt hashes for the `admin` and `kibanaserver`
users in `config/wazuh_indexer/internal_users.yml` so the indexer accepts them.

If you set `INDEXER_PASSWORD` or `DASHBOARD_PASSWORD` by hand instead, you must regenerate those two hashes
yourself, or the indexer will reject the new passwords:
```
$ docker run --rm --entrypoint /usr/share/wazuh-indexer/plugins/opensearch-security/tools/hash.sh \
    -e OPENSEARCH_JAVA_HOME=/usr/share/wazuh-indexer/jdk wazuh/wazuh-indexer:4.14.7 -p '<password>'
```
Paste the resulting hash into the `hash:` field for that user in `config/wazuh_indexer/internal_users.yml`.
`API_PASSWORD` has no such constraint — the manager sets the Wazuh API user's password itself on startup.

`config/wazuh_dashboard/wazuh.yml` is bind-mounted into the dashboard container, so Compose variable
interpolation does **not** apply to its contents — it needs the literal `API_PASSWORD` value written into its
`password:` field. `setup.sh` does this automatically; ships committed with the placeholder
`CHANGEME_RUN_SETUP_SH`, which is why the dashboard can't reach the manager API until you run it once.
