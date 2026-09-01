# Propuesta Formal de Pull Request: Seguridad Mejorada y Telemetría EDR para Omarchy

> **Estado: propuesta, no implementada.** Nada de esta página fue enviado ni
> aceptado por el upstream de Omarchy. Los tres items de abajo son bocetos de
> cómo podría verse un PR; no existe código para ellos en este repositorio. La
> versión completa y actual de este argumento — con las preguntas abiertas y los
> contraargumentos — está en [`PROPOSAL.es.md`](PROPOSAL.es.md).

## Resumen Ejecutivo

Esta propuesta presenta tres mejoras concretas para robustecer la postura de seguridad de Omarchy manteniendo intacta la filosofía de experiencia de desarrollo fluida y "opinionada" que caracteriza al proyecto de DHH:

1. **Nuevo Grupo CLI: `omarchy firewall`** — Interfaz declarativa e intuitiva para gestionar reglas de firewall UFW directamente desde el comando `omarchy`.
2. **Endurecimiento de SSH por Defecto** — Forzar autenticación exclusiva por llaves criptográficas (`PasswordAuthentication no`, `MaxAuthTries 3`) al configurar SSH mediante `omarchy setup security sshd`.
3. **Módulo de Telemetría EDR y Puente de Incidentes con IA** — Un widget nativo para Quickshell y un despachador que conecta eventos críticos de seguridad con el agente de IA por defecto para triage y contención en tiempo real.

---

## 1. Nuevo Grupo CLI: `omarchy firewall`

### Diagnóstico
Omarchy habilita UFW por defecto con política de denegación entrante, pero no cuenta con comandos de alto nivel para que los desarrolladores inspeccionen o habiliten puertos de prueba locales (ej. puertos de bases de datos, APIs de desarrollo).

### Comandos Propuestos
```bash
omarchy firewall status                     # Muestra puertos abiertos y estado visual
omarchy firewall allow <puerto> [--proto]   # Abre un puerto con comentario descriptivo
omarchy firewall deny <puerto>              # Revoca acceso a un puerto
omarchy firewall reset                      # Restaura la política por defecto de Omarchy
```

---

## 2. Endurecimiento de SSHD (`omarchy setup security sshd`)

### Diagnóstico
Al importar llaves públicas desde GitHub, el demonio OpenSSH puede mantener habilitada la autenticación por contraseña, dejando una superficie expuesta a ataques de fuerza bruta en redes locales.

### Solución Propuesta
Generar una configuración drop-in en `/etc/ssh/sshd_config.d/99-omarchy-hardened.conf`:
```text
PasswordAuthentication no
KbdInteractiveAuthentication no
PubkeyAuthentication yes
X11Forwarding no
MaxAuthTries 3
```

---

## 3. Módulo EDR y Respuesta a Incidentes con IA

### Diagnóstico
Las estaciones de trabajo de desarrollo ejecutan frecuentemente código de terceros (paquetes npm, pip, contenedores Docker). Omarchy cuenta con diagnóstico post-caída de procesos (`omarchy agent crash`), pero no con detección en tiempo de ejecución de actividades sospechosas (reverse shells, manipulación no autorizada de dotfiles en `~/.config/hypr/`).

### Solución Propuesta
* **Watcher en Tiempo Real:** Daemon ligero de usuario que procesa alertas de seguridad.
* **Respuesta Autónoma:** Ante eventos críticos, abre una terminal flotante ejecutando `omarchy-agent` con la telemetría del incidente para contención inmediata.
* **Widget de Barra:** Icono de escudo en Quickshell con indicador de estado (verde/amarillo/rojo).

---

## Compatibilidad y Riesgo

Las tres propuestas no tienen el mismo riesgo, así que una afirmación global
sería engañosa. Una por una:

| Propuesta | Alcance | Riesgo |
| :--- | :--- | :--- |
| 1. `omarchy firewall` | Un wrapper de CLI sobre `ufw`, que ya pide `sudo` para cambiar reglas. No agrega estado propio. | Bajo. Compatible hacia atrás; `ufw` se sigue pudiendo usar directo. |
| 2. Endurecimiento de SSHD | **No es user-space.** Escribe `/etc/ssh/sshd_config.d/99-omarchy-hardened.conf` y recarga `sshd`. | **Cambia un default de seguridad y te puede dejar afuera.** Poner `PasswordAuthentication no` en un host donde todavía no instalaste una llave pública funcional te saca la única vía de entrada por SSH. Necesita un chequeo previo de que exista una llave autorizada, una confirmación explícita y un rollback documentado — no un default silencioso. |
| 3. Telemetría EDR y puente de incidentes | User-space: un unit systemd de *usuario* y un plugin de Quickshell. | Bajo para Omarchy; el watcher necesita acceso al socket de Docker, que es una dependencia real que conviene declarar. |

O sea: las propuestas 1 y 3 son user-space y compatibles hacia atrás. La 2 no es
ninguna de las dos cosas, y las revisiones anteriores de esta página que
afirmaban "100% User-Space" y "Cero Cambios Disruptivos" para las tres estaban
equivocadas.
