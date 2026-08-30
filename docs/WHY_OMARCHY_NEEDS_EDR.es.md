# 🎯 Por qué Omarchy Necesita EDR: El Modelo de Amenazas del Desarrollador

## La Realidad de Seguridad en las Estaciones de Trabajo

Las computadoras de los desarrolladores son el **objetivo de mayor valor** en las empresas de tecnología. A diferencia de un usuario promedio, la máquina de un desarrollador cuenta con:
1. **Acceso a Producción y Nube:** Llaves SSH con privilegios elevados, credenciales de AWS/GCP/Azure, tokens de Kubernetes y túneles VPN corporativos.
2. **Ejecución de Código de Terceros:** Ejecución diaria de `npm install`, `pip install`, `cargo build`, `gem install` y contenedores Docker con scripts automáticos de pre-instalación.
3. **Privilegios de Administración Local:** Acceso a `sudo` y archivos críticos de configuración.

```
┌────────────────────────────────────────────────────────────────────────┐
│                   VECTORES DE AMENAZA DEL DESARROLLADOR                │
├────────────────────────────────────────────────────────────────────────┤
│ 1. Paquetes Maliciosos (Typosquatting en npm/pip, envenenamiento)      │
│ 2. Reverse Shells desde APIs o contenedores de prueba                  │
│ 3. Manipulación de Dotfiles (~/.config/hypr, ~/.bashrc, ~/.ssh)        │
│ 4. Escalación de Privilegios no autorizada (abuso de sudo, setuid)     │
│ 5. Ransomware y Cifrado Masivo no Autorizado                           │
└────────────────────────────────────────────────────────────────────────┘
```

---

## Por qué un Firewall Básico No Alcanza

Omarchy Linux habilita UFW con política de denegación entrante por defecto (`ufw default deny incoming`). Aunque esto bloquea conexiones entrantes no solicitadas, **no protege contra:**
* Reverse shells salientes iniciadas por una dependencia maliciosa.
* Manipulación silenciosa de binarios del sistema o configuraciones de PAM.
* Inyección de procesos en memoria o demonios comprometidos.

## La Solución: EDR Nativo + Respuesta Autónoma con IA

Integrar un EDR como **Wazuh, CrowdStrike o Microsoft Defender** con **Omarchy Sec** cierra la brecha:
* **Telemetría Continua:** Visibilidad en tiempo real de árboles de procesos, syscalls e integridad de archivos.
* **Detección Instantánea:** Alertas ante sockets anómalos o ejecuciones sospechosas en `/tmp`.
* **Contención con IA:** El agente de IA local (`omarchy-sec agent`) recibe telemetría viva para aislar la amenaza y revertir archivos sin fricción.
