# 🔒 Microsegmentación de Red y Modelo Zero Trust

## Dos modelos de red distintos

Esta página cubre dos despliegues que no hay que confundir:

* **Un sensor corporativo gestionado desde la nube** (Falcon, MDE, SentinelOne,
  Cortex) — el agente mantiene una sesión saliente hacia la nube del proveedor y
  no necesita ningún puerto entrante.
* **El stack local de Wazuh en `docker/single-node/`** — manager, indexer y
  dashboard corriendo en la misma estación de trabajo. Este **sí** escucha, en
  loopback.

```
┌────────────────────────────────────────────────────────────────────────┐
│                     ARQUITECTURA DE RED ZERO TRUST                     │
├────────────────────────────────────────────────────────────────────────┤
│ 1. Ingress Bloqueado (ufw default deny incoming)                       │
│    Es el default de Omarchy. Ningún puerto queda abierto hacia la red   │
│    en ninguno de los dos despliegues.                                  │
│                                                                        │
│ 2. Egress Saliente Exclusivo (sensores corporativos)                   │
│    Sesión TLS saliente hacia la nube del proveedor. Sin listener.      │
│                                                                        │
│ 3. Listeners Solo en Loopback (stack local de Wazuh)                   │
│    Seis puertos publicados, todos enlazados a 127.0.0.1.               │
└────────────────────────────────────────────────────────────────────────┘
```

## Qué significa "sin puertos expuestos" acá — con precisión

El stack local **sí** está escuchando. `docker-compose.yml` publica seis
puertos, y todos están enlazados a `127.0.0.1`:

| Puerto | Servicio | Función |
| :--- | :--- | :--- |
| `127.0.0.1:1514/tcp` | manager | Envío de eventos del agente |
| `127.0.0.1:1515/tcp` | manager | Registro de agentes (`authd`) |
| `127.0.0.1:514/udp` | manager | Ingesta de syslog |
| `127.0.0.1:55000/tcp` | manager | API REST |
| `127.0.0.1:9200/tcp` | indexer | OpenSearch |
| `127.0.0.1:9001/tcp` | dashboard | Consola web del SOC (→ `5601` del contenedor) |

Entonces la afirmación correcta es **"ningún puerto expuesto a la red: todos los
listeners están en loopback"**, no "cero puertos abiertos". Cualquier proceso
local, o cualquier usuario de la máquina, sigue alcanzando los seis. Esto
importa porque la sección `auth` del manager tiene
`<use_password>no</use_password>`: el registro de agentes en `:1515` no está
autenticado, y el binding a loopback es lo único que lo contiene.

El caso de uso declarado es una única estación registrándose a sí misma —
`setup.sh` corre `agent-auth -m 127.0.0.1`. Para registrar otros equipos hay que
reenlazar esos puertos a una interfaz LAN o VPN, y en ese momento el loopback
deja de protegerte: el firewall y la password de registro pasan a ser
responsabilidad tuya.

## Cifrado — lo que está realmente configurado

* **Sensores corporativos → nube:** TLS saliente. La versión y los cipher suites
  son cosa del proveedor; nada en este repositorio puede afirmarlos.
* **Agente → manager (`:1514`):** protocolo cifrado propio de Wazuh
  (`<connection>secure</connection>`), **no** TLS.
* **Manager → indexer, dashboard → indexer:** TLS con certificados mutuos
  (`FILEBEAT_SSL_VERIFICATION_MODE=full`, `config/wazuh_indexer_ssl_certs/`).
* **Capa HTTP del indexer:** configurada para **TLS 1.2 únicamente** —
  `plugins.security.ssl.http.enabled_protocols: ["TLSv1.2"]` en
  `wazuh.indexer.yml`. Revisiones anteriores de esta página afirmaban TLS 1.3;
  era falso.
* **Dashboard (`:9001`):** HTTPS con certificado autofirmado emitido por la CA
  del propio stack, por eso los clientes necesitan `-k` o una excepción en el
  navegador.

## Sobre eBPF

Omarchy Sec no carga sondas eBPF propias. `bin/omarchy-sec-detect` *reporta* si
hay un runtime eBPF activo consultando las units systemd `falco` y `tetragon`, y
los sensores comerciales traen sus propios colectores eBPF. Lo relevante de
`CONFIG_BPF=y` en un kernel rolling-release es que les permite a esos sensores
evitar módulos de kernel vía DKMS — una propiedad de ellos, no una función de
este proyecto.
