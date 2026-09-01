# 🔒 Zero Trust Network Microsegmentation

## Two different network models

This page covers two deployments that must not be conflated:

* **A cloud-managed vendor sensor** (Falcon, MDE, SentinelOne, Cortex) — the
  agent holds an outbound session to the vendor cloud and needs no inbound port.
* **The local Wazuh stack in `docker/single-node/`** — a manager, indexer and
  dashboard running on the same workstation. This one **does** listen, on
  loopback.

```
┌────────────────────────────────────────────────────────────────────────┐
│                   ZERO TRUST NETWORK ARCHITECTURE                      │
├────────────────────────────────────────────────────────────────────────┤
│ 1. Ingress Strict Deny (ufw default deny incoming)                     │
│    Omarchy's default. No port is opened to the network for either      │
│    deployment.                                                         │
│                                                                        │
│ 2. Egress-Only Encrypted Stream (vendor sensors)                       │
│    Outbound TLS session to the vendor cloud. No inbound listener.      │
│                                                                        │
│ 3. Loopback-Only Listeners (local Wazuh stack)                         │
│    Six published ports, every one bound to 127.0.0.1.                  │
└────────────────────────────────────────────────────────────────────────┘
```

## What "no exposed ports" means here — precisely

The local stack **is** listening. `docker-compose.yml` publishes six ports, and
every one of them is bound to `127.0.0.1`:

| Port | Service | Purpose |
| :--- | :--- | :--- |
| `127.0.0.1:1514/tcp` | manager | Agent event forwarding |
| `127.0.0.1:1515/tcp` | manager | Agent enrollment (`authd`) |
| `127.0.0.1:514/udp` | manager | Syslog ingestion |
| `127.0.0.1:55000/tcp` | manager | REST API |
| `127.0.0.1:9200/tcp` | indexer | OpenSearch |
| `127.0.0.1:9001/tcp` | dashboard | SOC web console (→ container `5601`) |

So the accurate claim is **"no port is exposed to the network — every listener
is on loopback"**, not "zero open ports". A local process or any user on the
machine can still reach all six. This matters because the manager's `auth`
stanza sets `<use_password>no</use_password>`: enrollment on `:1515` is
unauthenticated, and loopback binding is the only thing containing it.

The declared use case is a single workstation enrolling itself — `setup.sh` runs
`agent-auth -m 127.0.0.1`. To enroll other hosts you must rebind those ports to
a LAN or VPN interface, at which point loopback stops protecting you and the
firewall and enrollment password become your responsibility.

## Encryption — what is actually configured

* **Vendor sensors → cloud:** outbound TLS. Version and cipher suite are the
  vendor's business; nothing in this repository can assert them.
* **Agent → manager (`:1514`):** Wazuh's own encrypted protocol
  (`<connection>secure</connection>`), **not** TLS.
* **Manager → indexer, dashboard → indexer:** TLS with mutual certificates
  (`FILEBEAT_SSL_VERIFICATION_MODE=full`, `config/wazuh_indexer_ssl_certs/`).
* **Indexer HTTP layer:** configured for **TLS 1.2 only** —
  `plugins.security.ssl.http.enabled_protocols: ["TLSv1.2"]` in
  `wazuh.indexer.yml`. Earlier revisions of this page claimed TLS 1.3; that was
  wrong.
* **Dashboard (`:9001`):** HTTPS with a self-signed certificate from the stack's
  own CA, which is why clients need `-k` / a browser exception.

## On eBPF

Omarchy Sec does not load eBPF probes of its own. `bin/omarchy-sec-detect`
*reports* whether an eBPF runtime is active by checking the `falco` and
`tetragon` systemd units, and commercial sensors bring their own eBPF
collectors. The relevance of `CONFIG_BPF=y` on a rolling-release kernel is that
it lets vendor sensors avoid DKMS kernel modules — a property of those sensors,
not a feature of this project.
