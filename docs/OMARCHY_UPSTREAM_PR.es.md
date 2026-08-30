# Propuesta Formal de Pull Request: Seguridad Mejorada y Telemetría EDR para Omarchy

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
