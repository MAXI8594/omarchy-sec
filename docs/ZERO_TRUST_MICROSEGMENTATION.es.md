# 🔒 Microsegmentación de Red y Modelo Zero Trust

## Arquitectura de Red y Principios de Salida Segura

Para garantizar que los equipos Omarchy reporten telemetría continua al SOC corporativo sin quedar expuestos en redes locales o públicas:

```
┌────────────────────────────────────────────────────────────────────────┐
│                     ARQUITECTURA DE RED ZERO TRUST                     │
├────────────────────────────────────────────────────────────────────────┤
│ 1. Ingress Bloqueado (ufw default deny incoming)                       │
│    Cero puertos de entrada abiertos en la estación de trabajo.         │
│                                                                        │
│ 2. Egress Saliente Exclusivo (Outbound TLS/Puerto 443)                 │
│    Conexión persistente cifrada (HTTPS/gRPC/WebSockets) a la nube.     │
│                                                                        │
│ 3. Inspección eBPF en Kernel (CONFIG_BPF=y)                            │
│    Desacoplado de auditd para evitar saturación del buffer del kernel. │
└────────────────────────────────────────────────────────────────────────┘
```

### Reglas de Microsegmentación:
* **Cero Puertos Entrantes:** Los agentes EDR modernos no requieren puertos escuchando; establecen sesiones salientes persistentes.
* **Telemetría Cifrada:** Syscalls, eventos de procesos y hashes FIM viajan por TLS 1.3.
* **Aislamiento en Loopback:** Los contenedores locales del SOC (Wazuh) están enlazados exclusivamente al loopback local (`127.0.0.1:9001`, `127.0.0.1:55000`).
