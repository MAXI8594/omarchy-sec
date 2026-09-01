# 🤖 Respuesta a Incidentes Asistida por IA ("Call Agent")

## Qué es automático y qué no

Los paneles de seguridad tradicionales muestran un icono estático de advertencia
y te dejan a vos la tarea de ir a leer logs. **Omarchy Sec** en cambio abre tu
agente de código (`omarchy-agent`) con el contexto del incidente ya cargado.

Conviene ser claro con el límite, porque "autónomo" promete de más:

* **Automático:** el disparo. `omarchy-sec-watcher` sigue el `alerts.json` del
  manager; con nivel ≥ 7 emite una notificación de escritorio, y con nivel ≥ 10
  además lanza `omarchy-sec-agent`, que abre una terminal con el prompt
  precargado.
* **No automático:** todo lo que viene después. La sesión del agente es
  interactiva y vos estás sentado adelante. No se mata ningún proceso, no se
  bloquea ninguna IP y no se restaura ningún archivo sin vos. El bloque
  `<active-response>` de Wazuh, que sí podría hacerlo solo, está comentado en
  `wazuh_manager.conf`.

```
[Alerta nivel >= 10 en alerts.json] ➔ [Consulta API Wazuh (:55000) + telemetría del host]
                                    ➔ [Prompt armado] ➔ [Terminal interactiva del agente]
```

## Qué contiene realmente el prompt

Textual, según `bin/omarchy-sec-agent`:

1. **Hostname, timestamp ISO-8601 y el sensor primario activo** (`.primary` de
   `omarchy-sec-detect`).
2. **La alerta que disparó todo**, cuando lo invoca el watcher: nivel, ID de
   regla, descripción, IP de origen, archivo afectado.
3. **Resumen de agentes de Wazuh** — `omarchy-sec-wazuh-api summary`, es decir
   los items del endpoint `/agents`.
4. **Las últimas 8 alertas** de `alerts.json`, proyectadas a nivel, ID de regla,
   descripción, timestamp, IP de origen y archivo. *No incluye ningún campo de
   técnica MITRE* — la proyección no extrae ninguno.
5. **Sockets en escucha** — las primeras 12 líneas de `ss -tuln`.
6. **Procesos top** — las primeras 8 líneas de `ps aux --sort=-%cpu`. Es un
   listado ordenado por CPU, no un árbol de procesos.

## Qué se le dice al agente que puede hacer

El prompt le entrega una lista de herramientas y una misión, nada más:

* `omarchy-sec-wazuh-api alerts [límite] [nivel_min]` — más historial de alertas
* `omarchy-sec-wazuh-api sca` — resultados de Security Configuration Assessment
* `omarchy-sec-wazuh-api fim` — cambios de integridad de archivos
* `omarchy-sec-wazuh-api query <endpoint>` — cualquier endpoint REST
* Herramientas de shell: `ps`, `lsof`, `journalctl`, `ss`, `kill`, `ufw`

Su misión es triar la alerta, decidir si es falso positivo o ataque real, y
**proponer o ejecutar** la contención en esa terminal — matar procesos con
`kill`, bloquear IPs con `ufw`. Son acciones del propio agente en tu shell, con
tu permiso, sujetas a tu password de sudo.

**La reversión con Btrfs / Snapper no es parte de esto.** Versiones anteriores
de esta página listaban el rollback de archivos como capacidad del agente; el
prompt nunca menciona snapshots y nada en el proyecto ejecuta uno. Recuperar un
archivo manipulado es un paso manual que hacés vos.

## Fallback

Si `omarchy-agent` falla (lo habitual es que se acabe la cuota), la terminal
queda abierta e imprime las alternativas para correr a mano (`agy --prompt`,
`gemini --yolo`). No se queda en silencio sin hacer nada.
