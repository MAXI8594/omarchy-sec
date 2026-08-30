# 🤖 Respuesta Autónoma a Incidentes con IA ("Call Agent")

## De Alertas Estáticas a Contención Activa

Los paneles de seguridad tradicionales muestran iconos estáticos que exigen un análisis manual complejo. **Omarchy Sec** conecta el motor EDR directamente con el **Agente de IA de Omarchy** (`claude`, `gemini`, `codex`, `agy`).

```
[Anomalía Detectada] ➔ [Consulta API Wazuh (:55000)] ➔ [Telemetría Viva] ➔ [Terminal de IA Abierta]
```

### Qué Recibe el Agente de IA:
1. **Resumen del Endpoint:** Sistema operativo, arquitectura, agentes conectados, estado de red.
2. **Historial de Alertas:** Eventos estructurados de `alerts.json` (nivel, regla, técnica MITRE, archivo o IP).
3. **Sockets de Red:** Estado de puertos escuchando (`ss -tuln`).
4. **Árbol de Procesos:** Procesos activos con alto consumo (`ps aux`).

### Acciones de Contención que puede Ejecutar el Agente:
* **Triage Forense:** Discriminar pruebas locales de desarrollo (falsos positivos) de ataques reales.
* **Terminación de Procesos:** Matar PIDs maliciosos o árboles de procesos sospechosos.
* **Aislamiento de Red:** Bloquear IPs atacantes con `ufw`.
* **Reversión de Archivos:** Restaurar archivos manipulados desde snapshots de Btrfs/Snapper.
