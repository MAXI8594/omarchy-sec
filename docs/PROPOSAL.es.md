# RFC: Hardening de seguridad opcional y hooks de telemetría EDR para Omarchy

| | |
| :--- | :--- |
| **Estado** | Borrador — abierto a discusión |
| **Autor** | Maximiliano Olivera ([@MAXI8594](https://github.com/MAXI8594)) |
| **Discusión** | Discord de Omarchy, `#omarchy-security` |
| **Destino** | Omarchy 4.x |
| **Implementación de referencia** | [`MAXI8594/omarchy-sec`](https://github.com/MAXI8594/omarchy-sec) (fuera del árbol, MIT) |

Este documento existe porque un documento de diseño se puede diffear, citar por línea y discutir. Una versión anterior de este material circuló como PDF; el PDF queda en `docs/` como referencia, pero este archivo es la versión a revisar. Donde los dos difieran, manda este archivo.

**Si solo leés una sección, que sea esta:** las tres propuestas de la [§3](#3-propuestas) son independientes. No son un paquete. Rechazar una no afecta a las otras, y prefiero que entre una sola antes que discutir las tres juntas.

---

## Contenido

- [1. Resumen](#1--resumen)
  - [1.1 Qué se propone](#11-qué-se-propone)
  - [1.2 Qué NO se propone](#12-qué-no-se-propone)
- [2. Planteo del problema](#2--planteo-del-problema)
- [3. Propuestas](#3--propuestas)
  - [Propuesta A — Grupo CLI `omarchy firewall`](#-propuesta-a--grupo-cli-omarchy-firewall)
  - [Propuesta B — Drop-in de hardening del demonio SSH](#-propuesta-b--drop-in-de-hardening-del-demonio-ssh)
  - [Propuesta C — Hook opcional de telemetría EDR y puente de incidentes](#-propuesta-c--hook-opcional-de-telemetría-edr-y-puente-de-incidentes)
- [4. Qué existe ya fuera del árbol](#4--qué-existe-ya-fuera-del-árbol)
- [5. El pipeline DevSecOps de este repositorio](#5--el-pipeline-devsecops-de-este-repositorio)
  - [5.1 Pipeline local — `tests/run_tests.sh`](#51-pipeline-local--testsrun_testssh)
  - [5.2 Pipeline de CI — `.github/workflows/security-ci.yml`](#52-pipeline-de-ci--githubworkflowssecurity-ciyml)
- [6. Preguntas abiertas](#6--preguntas-abiertas)

---

## 1. 🧭 Resumen

### 1.1 Qué se propone

Tres agregados a Omarchy, ordenados de mayor a menor según cuánta confianza tengo en que corresponden upstream:

1. **[`omarchy firewall`](#propuesta-a--grupo-cli-omarchy-firewall)** — un grupo CLI chico que envuelve los comandos de UFW que un desarrollador realmente usa, para que abrir un puerto de desarrollo no implique bajar a la sintaxis cruda de `ufw`/`iptables`.
2. **[Hardening del demonio SSH](#propuesta-b--drop-in-de-hardening-del-demonio-ssh)** — un drop-in de sshd que deshabilita la autenticación por contraseña, aplicado como parte del flujo de configuración de SSH que ya instala las claves públicas.
3. **[Hook de telemetría EDR](#propuesta-c--hook-opcional-de-telemetría-edr-y-puente-de-incidentes)** — una receta opt-in y un widget de estado para usuarios cuya empresa exige un agente de endpoint, más un hook documentado para que una alerta de severidad alta pueda pasarle su contexto al agente de código local.

La Propuesta A es un envoltorio de conveniencia sobre un default que ya existe. La B cambia un default de seguridad. La C es opt-in y no agrega ningún camino de código para quien nunca la habilite. Deberían discutirse y aceptarse o rechazarse por separado.

### 1.2 Qué NO se propone

Aclaro el alcance negativo de forma explícita, porque la mayoría de las objeciones que espero son a cosas que no estoy pidiendo:

- **Ningún EDR viene incluido en Omarchy.** No se instala nada por defecto, nada llama a casa, no se avala a ningún proveedor. La Propuesta C es un hook más documentación; el sensor es el que la empresa del usuario ya le exige, instalado por el usuario.
- **Ningún demonio corriendo por defecto.** El watcher descrito en la Propuesta C es una unidad systemd de usuario que hay que habilitar explícitamente. Una instalación limpia de Omarchy después de este RFC tiene exactamente la misma lista de procesos que antes.
- **Ninguna telemetría hacia mí, hacia este repositorio ni hacia terceros.** No hay analítica, ni reporte de crashes, ni llamadas a casa en ninguna de las tres propuestas.
- **Ningún cambio a la estética ni a los defaults de flujo de trabajo de Omarchy.** No aparece ningún widget nuevo en la barra salvo que el usuario lo agregue.
- **Ningún módulo de kernel ni programa eBPF distribuido por Omarchy.** Los sensores de proveedor traen los suyos; Omarchy no.
- **Ningún hardening obligatorio.** La Propuesta B es la única que cambia un default, y [su camino de reversión](#b-costo-y-riesgo) es borrar un archivo.
- **Ninguna afirmación de que esto vuelve "segura" a una estación de trabajo.** Reduce dos clases específicas de exposición (SSH entrante sin autenticar; puntos ciegos en una máquina que ejecuta código no confiable) y no hace nada respecto del resto.

---

## 2. 🎯 Planteo del problema

Omarchy apunta a desarrolladores, y una estación de trabajo de desarrollo tiene un perfil de amenaza inusual comparada con un escritorio de propósito general:

**Ejecuta código no confiable de forma rutinaria.** `npm install`, `pip install`, `cargo build`, `paru -S` y `docker run` contra imágenes arbitrarias ejecutan código de terceros, parte de él con hooks de instalación, en la misma máquina que guarda las credenciales que vale la pena robar. Esto no es hipotético: el compromiso de registries de paquetes ya es una técnica estándar de cadena de suministro, y el payload normalmente corre en tiempo de instalación, antes de que se importe una sola línea.

**Las credenciales que tiene son de alto valor.** Claves SSH, credenciales de nube en `~/.aws` / `~/.config/gcloud`, contextos de Kubernetes, configuración de VPN, y un historial de shell que mapea la red interna del objetivo.

**Su configuración es una superficie de persistencia.** `~/.bashrc`, `~/.config/hypr/`, `~/.config/systemd/user/` y los archivos de init de shell son escribibles por el mismo usuario que corre `npm install`. Modificar uno de ellos es la persistencia más barata que existe y no produce ningún síntoma visible.

**El default actual ayuda en una sola dirección.** Omarchy habilita UFW con política de denegación entrante — bien, y es la razón por la que la Propuesta A es un envoltorio y no un default nuevo. Pero una política de denegación entrante no observa una reverse shell saliendo, un checksum modificado en un archivo de init de shell, ni un binario setuid nuevo. Esos son problemas de egreso y de integridad, no de ingreso.

*(La afirmación puntual de que Omarchy habilita UFW con `default deny incoming` de fábrica está tomada de la documentación de Omarchy y de mi propia instalación. Si es inexacta o cambió, el planteo de la Propuesta A hay que revisarlo — corríjanme en el hilo.)*

La brecha que este RFC ataca es acotada: **darle al usuario una forma directa de gestionar el firewall que ya tiene, cerrar el agujero de autenticación por contraseña en el mismo flujo SSH que Omarchy ya configura, y hacer posible — no obligatorio — correr un sensor de endpoint y llevar sus alertas a algún lado útil.**

---

## 3. 📬 Propuestas

Cada propuesta tiene su propio ancla de encabezado para poder enlazarla y discutirla por separado.

### 🔥 Propuesta A — Grupo CLI `omarchy firewall`

#### A. Qué cambia

Un grupo de comandos nuevo en el CLI de `omarchy` que envuelve UFW:

```bash
omarchy firewall status                       # reglas activas, formateadas para humanos
omarchy firewall allow <puerto> [--proto=tcp] # habilita un puerto, con comentario autogenerado
omarchy firewall deny <puerto>                # revoca esa habilitación
omarchy firewall reset                        # restaura la política por defecto de Omarchy
```

Sin cambio de política. La postura por defecto de UFW queda exactamente como la entrega Omarchy; esto solo le pone un frente descubrible a las cuatro operaciones que un desarrollador ejecuta.

#### A. Por qué

Abrir el puerto 3000 para un servidor de desarrollo hoy implica o acordarse de la sintaxis de `ufw` o, más habitualmente, deshabilitar el firewall entero porque eso es un comando y la solución correcta son tres. El modo de falla de un firewall incómodo de ajustar es un firewall apagado. Hacer que la acción acotada sea más fácil que la drástica es todo el punto.

El comportamiento de `--comment` importa más de lo que parece: las reglas agregadas así quedan autodocumentadas, así que `omarchy firewall status` seis meses después le dice al usuario *por qué* el 5432 está abierto, que es la diferencia entre un estado revisable y uno acumulado.

#### A. Costo y riesgo

- **Superficie de mantenimiento:** aproximadamente una función de shell por subcomando, más validación de argumentos. Poco, pero es código upstream que hay que mantener y duplica algo que `ufw` ya hace.
- **Riesgo de abstracción:** un envoltorio que cubre el 80% de los casos puede volver más difícil razonar sobre el 20% restante, porque el usuario deja de ver el conjunto de reglas real. Se mitiga haciendo que `status` imprima la salida real de `ufw status numbered` en vez de un formato inventado.
- **Nombre:** si Omarchy alguna vez migra de UFW a firewalld o a nftables plano, el nombre del comando sobrevive pero la implementación no. Discutiblemente es un argumento a favor del envoltorio, no en contra.
- **El contraargumento honesto:** `ufw allow 3000` ya es corto. Si la postura de los mantenedores es que el comando existente alcanza y que la superficie del CLI debe quedar chica, es una posición razonable y esta propuesta habría que descartarla. Es la menos importante de las tres.

#### A. Cómo se revierte

Se borra el grupo de comandos. No escribe estado propio; las reglas que el usuario haya creado siguen en la configuración de UFW y se gestionan con `ufw` como antes. Nada que migrar, nada que limpiar.

#### A. Estado

**No implementado.** No existe código para esto en el repositorio de referencia — es un boceto de diseño, deliberadamente, hasta que haya señal de que la forma interesa.

---

### 🔐 Propuesta B — Drop-in de hardening del demonio SSH

#### B. Qué cambia

Cuando el usuario corre el flujo de configuración de SSH que ya existe (el que descarga y autoriza claves públicas desde GitHub), escribir además `/etc/ssh/sshd_config.d/99-omarchy-hardened.conf`:

```text
PasswordAuthentication no
KbdInteractiveAuthentication no
PubkeyAuthentication yes
X11Forwarding no
MaxAuthTries 3
```

#### B. Por qué

El flujo de configuración ya deja establecida la autenticación por clave. Dejar la autenticación por contraseña habilitada después significa que el mecanismo más débil sigue disponible en todas las interfaces donde el demonio escucha — LAN, Tailscale, o una IP pública si la máquina alguna vez queda expuesta. Autenticación por contraseña que nadie piensa usar es exposición sin beneficio.

Aplicarlo en el momento en que se instalan las claves es la secuencia correcta: el usuario acaba de demostrar que tiene autenticación por clave funcionando, así que el modo de falla de apagar las contraseñas está en su punto más bajo.

#### B. Costo y riesgo

Esta es la propuesta con riesgo real, y prefiero ser directo en vez de venderla como una ganancia gratis:

- **El lockout es posible.** Si la instalación de claves falló parcialmente, o la única clave del usuario está en una máquina que en ese momento no tiene a mano, deshabilitar la autenticación por contraseña lo deja afuera del acceso remoto. El acceso físico o por consola sigue funcionando, pero "sigue funcionando" es un consuelo pobre a las 2 de la mañana en un servidor remoto.
- **Mitigación, y considero que es obligatoria, no opcional:** validar antes de escribir. Confirmar que hay al menos una clave en `authorized_keys`, correr `sshd -t` contra la configuración nueva, y negarse a escribir (o escribir y revertir de inmediato) si cualquiera de las dos verificaciones falla. Un prompt que muestre exactamente qué está por cambiar es barato y corresponde acá.
- **`X11Forwarding no` es un cambio de comportamiento, no solo de hardening.** Es el default correcto en un sistema Wayland/Hyprland, pero cualquiera que reenvíe X sobre SSH hacia esta máquina para una herramienta legacy lo va a ver romperse con un error poco útil. Esta línea es separable del resto y se puede sacar si genera resistencia.
- **`MaxAuthTries 3` interactúa con la autenticación por agente.** Un cliente que ofrece varias claves desde el agente puede agotar tres intentos antes de llegar a la correcta. `MaxAuthTries 6` es un compromiso defendible; no tengo una opinión fuerte sobre el número.
- **Contradice el encuadre de "solo espacio de usuario, sin cambios rompientes".** Escribir en `/etc/ssh/sshd_config.d/` no es ninguna de las dos cosas. Una versión anterior de este material afirmaba ambas; esa afirmación era incorrecta y queda retirada.

#### B. Cómo se revierte

```bash
sudo rm /etc/ssh/sshd_config.d/99-omarchy-hardened.conf
sudo systemctl reload sshd
```

Un solo archivo, en un directorio drop-in, con un prefijo numérico que hace explícita su precedencia. Nunca edita `sshd_config` en sí, así que el archivo de la distribución queda intacto y actualizable. Esa es la razón principal para preferir un drop-in sobre la edición in situ.

#### B. Estado

**No implementado.** El repositorio de referencia no contiene ninguna configuración de sshd; esto es una propuesta para el flujo de setup upstream.

---

### 🤖 Propuesta C — Hook opcional de telemetría EDR y puente de incidentes

#### C. Qué cambia

Tres piezas separables, todas opt-in:

1. **Una receta de setup** (`omarchy setup security edr` o similar) que ayude al usuario a poner en marcha un sensor de endpoint corporativo sobre Arch. En la práctica esto es guía de empaquetado — la mayoría de los proveedores entrega `.rpm` o `.deb` y nada más — más los pasos de enrolamiento por proveedor.
2. **Un widget de estado** para la barra que muestre si hay un sensor presente y corriendo. Solo lectura, sin acceso privilegiado; reporta estado de servicio.
3. **Un hook documentado** para que una alerta de severidad alta pueda abrir una terminal con el agente de código local, precargado con el contexto de la alerta: la regla que disparó, el árbol de procesos, los sockets en escucha y la ruta afectada. Después decide el desarrollador. No se mata, bloquea ni revierte nada automáticamente.

#### C. Por qué

Dos audiencias distintas, y conviene mantenerlas separadas:

**Usuarios bajo mandato corporativo.** Un desarrollador cuya empresa exige CrowdStrike, Defender o SentinelOne en cada endpoint hoy no puede usar Omarchy en el trabajo — no porque el sensor sea técnicamente incompatible, sino porque nadie escribió cómo llevar un sensor empaquetado como RPM a Arch y enrolarlo. Es un problema de documentación y empaquetado que cada persona que lo choca resuelve en privado y mal. Omarchy es el lugar natural para resolverlo una sola vez.

**Todos los demás.** La brecha identificada en la [§2](#2-planteo-del-problema) — cero visibilidad sobre egreso o integridad de archivos — existe independientemente del empleador. Wazuh es open source, autoalojable, y cierra una parte. Pero esta es la mitad más débil del argumento, y no lo voy a disimular: la mayoría de los usuarios individuales no va a correr un SIEM en su laptop, y una propuesta que asume que sí es una propuesta para otra audiencia.

La pieza de "pasarle la alerta al agente de código" es la parte que me parece genuinamente novedosa y también de la que menos seguro estoy que corresponda upstream. Una alerta que dice `T1059.004 — Unix Shell` no significa nada para la mayoría de los desarrolladores. La misma alerta, abierta en una terminal junto al árbol de procesos y la ruta involucrada, con un agente que puede explicarla, sí es accionable. Esa es la apuesta. Puede ser la apuesta equivocada.

#### C. Costo y riesgo

- **Los sensores de proveedor son código propietario cercano al kernel.** Falcon, Defender y SentinelOne entregan agentes binarios. Recomendarlos cae mal en una audiencia Arch/software libre, y con razón. La respuesta es que Omarchy no recomendaría nada — documentaría cómo correr lo que el usuario ya está obligado a correr, y el único camino open source (Wazuh) sería el único que efectivamente puede testear.
- **Fragilidad de rolling release.** Los sensores de proveedor apuntan a kernels LTS empresariales. En Arch, un salto de kernel puede dejar un sensor en modo de funcionalidad reducida sin aviso. Cualquier documentación que Omarchy publique tiene que decir esto fuerte, en vez de insinuar "soportado".
- **La carga de mantenimiento es el costo real.** Los procedimientos de enrolamiento de cinco proveedores cambian según el calendario de ellos, no el de Omarchy. Documentación que se pone vieja es peor que no tener documentación, porque falla con seguridad. Si esto entra, necesita un dueño, y ese dueño probablemente deba ser yo y no los mantenedores de Omarchy.
- **El stack de Wazuh en Docker escucha localmente.** Correr la opción autoalojada implica que la API del manager y el dashboard abren puertos en la estación de trabajo. En la implementación de referencia están enlazados solo a `127.0.0.1` (`127.0.0.1:9001`, `127.0.0.1:55000`, `127.0.0.1:1514`), pero "cero puertos en escucha" no es exacto para esa configuración y esa afirmación queda retirada.
- **El watcher de alertas necesita acceso al socket de Docker** en su forma actual, lo que equivale a root. Eso es un defecto de diseño de la implementación de referencia, no algo inherente — leer un archivo de log no lo requiere — y habría que corregirlo antes de proponer en serio algo de este estilo.
- **La respuesta automática está deliberadamente ausente.** El hook abre una terminal. No mata procesos ni agrega reglas de firewall por su cuenta. La contención autónoma en una máquina de desarrollo tarde o temprano va a matar el proceso de prueba del propio desarrollador en medio de una demo, y ese costo de confianza no se recupera.

#### C. Cómo se revierte

```bash
systemctl --user disable --now omarchy-sec-watcher.service
```

Se saca el widget de la barra; se saca la receta. Como nada está habilitado por defecto, "revertir" para la gran mayoría de los usuarios no significa nada, porque nunca se instaló nada. Los sensores de proveedor se remueven con sus propios desinstaladores, que es una propiedad de esos sensores y no algo que Omarchy deba intentar poseer.

#### C. Estado

**Parcialmente implementado fuera del árbol.** La detección de sensores, el watcher de alertas, el widget de barra y el puente al agente existen en el repositorio de referencia y están descritos en la [§4](#4-qué-existe-ya-fuera-del-árbol). Nada de eso está en Omarchy, y nada se propone incluir tal cual — lo que se pide upstream es el hook y la receta, no este código.

---

## 4. ⚙️ Qué existe ya fuera del árbol

```
   sensores en la maquina           vos                opcional
  ┌──────────────────┐        ┌───────────┐        ┌──────────────┐
  │ Wazuh · Falcon   │        │  la barra │        │ SOC / MDR    │
  │ Cortex · S1      │──┐  ┌─▶│  🛡️ verde │        │ corporativo  │
  │ Defender · Falco │  │  │  └───────────┘        └──────▲───────┘
  │ auditd           │  │  │                              │
  └──────────────────┘  │  │                        solo TLS saliente
                        ▼  │                              │
                  ┌───────────────┐                       │
                  │ omarchy-sec   │───────────────────────┘
                  │   -detect     │  (canal propio del agente del fabricante)
                  └───────┬───────┘
                          │  regla nivel >= 10
                          ▼
                  ┌───────────────┐
                  │ omarchy-agent │  triage, en tu terminal
                  └───────────────┘

  todos los puertos del stack self-hosted bindean 127.0.0.1 — nada en la LAN
```


Para quien quiera mirar código funcionando antes de decidir si los hooks valen la pena. Todo esto vive en [`MAXI8594/omarchy-sec`](https://github.com/MAXI8594/omarchy-sec) y lo instala el usuario, por separado de Omarchy.

| Componente | Qué hace realmente |
| :--- | :--- |
| `bin/omarchy-sec-detect` | Verifica si cada una de siete familias de sensores está corriendo (Wazuh, Falcon, Cortex, SentinelOne, Defender, Falco/Tetragon, auditd) mediante `systemctl is-active`, `pgrep` y presencia de archivos. Emite JSON. Reporta estado de servicio; no integra con las APIs de los proveedores. |
| `bin/omarchy-sec-watcher` | Unidad systemd de usuario. Hace tail de `alerts.json` desde el contenedor del manager de Wazuh, envía una notificación de escritorio con nivel de regla ≥ 7 e invoca el puente al agente con nivel ≥ 10. Hoy requiere acceso al socket de Docker — ver [C. Costo y riesgo](#c-costo-y-riesgo). |
| `bin/omarchy-sec-agent` | Arma el contexto en vivo (resumen de la API de Wazuh, alertas recientes, `ss -tuln`, `ps aux`) en un prompt y abre el agente de código local con eso. |
| `bin/omarchy-sec-wazuh-api` | Cliente REST fino para la API de Wazuh — autenticación JWT con token cacheado de vida corta, más consultas de `agents`, `sca`, `syscheck` y alertas. |
| `bin/omarchy-sec-onboard` | Asistente interactivo que imprime los pasos de extracción y enrolamiento por proveedor, y ejecuta el CLI del proveedor cuando se le pasa un token. |
| [`omarchy-sec-plugin`](https://github.com/MAXI8594/omarchy-sec-plugin) | Widget de barra Quickshell y panel emergente mostrando el estado de los sensores. Repositorio aparte, se instala con `omarchy plugin add`. Ejecuta `/usr/bin/omarchy-sec-detect` y rechaza cualquier otra ruta, revalidando antes de cada ejecución que sea un ejecutable propiedad de `root`, no symlink y no escribible por otros; cualquier otra cosa se muestra como `desconocido`. El detector corre dentro de un `systemd-run --user --scope` con nombre, bajo un `timeout` y un presupuesto de salida de 64 KiB. |
| `docker/single-node/` | Manager, indexer y dashboard de Wazuh, todos enlazados a `127.0.0.1`. |

La herramienta fuera del árbol además arrastraba una inyección de comandos hasta esta semana: el comando de triage interpolaba un prompt armado — que embebe la salida de `ps aux`, o sea el argv de procesos de otros usuarios — dentro de un string de shell entre comillas dobles. Cualquier usuario local con un proceso corriendo podía ejecutar código en el contexto de quien corriera el triage. Está arreglado y la reproducción está en el historial. Se declara acá porque una propuesta de hardening cuyo autor esconde sus propios hallazgos no vale nada.

Un tercer hallazgo, de la revisión del widget en el marketplace: validaba al detector por ruta y después lo ejecutaba, y una de las rutas que aceptaba era `~/.local/bin/omarchy-sec-detect` — un archivo que el propio usuario puede reescribir entre la validación y la ejecución (TOCTOU). El candidato se eliminó en vez de parchearse; queda `/usr/bin` como única ruta, tanto para el detector como para el binario del agente detrás de **Call Agent**, cada uno validado por separado. La consecuencia deliberada: instalar el CLI desde un checkout de git ya no alimenta al widget, que queda en `desconocido` hasta que el paquete deje los binarios en `/usr/bin`. Para un indicador de seguridad es la respuesta correcta, y es una aspereza para quien corra desde git.

Asperezas conocidas, declaradas acá en vez de que las descubra quien revise. El watcher necesita acceso al socket de Docker, ya mencionado. Y la más filosa, porque toca el [§2](#2--planteo-del-problema): el stack self-hosted **no** vigila dotfiles de fábrica. Su bloque `syscheck` cubre `/etc`, `/usr/bin`, `/usr/sbin`, `/bin`, `/sbin` y `/boot`; `$HOME` hay que agregarlo a mano en la config del agente. Así que la mitad de integridad del hueco que describo arriba es una que mi propia herramienta hoy cierra sólo en parte. Nada de lo propuesto upstream depende de ninguna de las dos.

---

## 5. 🧪 El pipeline DevSecOps de este repositorio

Esta sección describe lo que el pipeline **realmente ejecuta**, incluyendo lo que no detecta. Un resumen anterior de este material describía el pipeline como aprobado al 100% en SAST, IaC, secretos, SCA y DAST; eso no era exacto, y la versión exacta es la que sigue.

Corren dos cosas: `tests/run_tests.sh` localmente, y `.github/workflows/security-ci.yml` en cada push y pull request a `main`. Se solapan pero no son el mismo conjunto.

### 5.1 Pipeline local — `tests/run_tests.sh`

| # | Verificación | Herramienta | ¿Bloquea si falla? |
| :--- | :--- | :--- | :--- |
| 1 | Análisis estático de shell | `shellcheck` sobre `bin/` y `scripts/` | **Sí** — falla real, exit distinto de cero |
| 2 | Validación de plugin y manifiesto QML | `omarchy plugin validate` | **Sí**, cuando el CLI de `omarchy` está presente |
| 3 | Escaneo de secretos | `gitleaks detect --no-git` | **Sí** |
| 4 | Misconfiguración de IaC | `trivy config docker/single-node` | **No** — ver abajo |
| 5 | Smoke test del motor de detección | ejecuta `bin/omarchy-sec-detect` | **Sí**, pero ver abajo |
| 6 | Alcanzabilidad del dashboard | `curl` contra `https://localhost:9001` | **No** — ver abajo |

Dónde es más débil de lo que parece:

- **Las verificaciones 1 a 4 se saltean en silencio si la herramienta no está instalada.** Un skip no es ni aprobado ni fallido; la corrida igual termina con exit 0. En una máquina sin `shellcheck`, `gitleaks` y `trivy`, cuatro de las seis verificaciones se evaporan y el pipeline reporta éxito. Esta es la brecha más grande de todas.
- **La verificación 4 no puede fallar.** Trivy se invoca con `--exit-code 0`, así que una misconfiguración HIGH o CRITICAL se encuentra y después se ignora, con la salida descartada. Hoy es un escaneo informativo reportado como si fuera una compuerta.
- **La verificación 5 comprueba que el script corre, no que exista un sensor.** `omarchy-sec-detect` termina con exit 0 haya o no algo protegiendo la máquina.
- **La verificación 6 no puede fallar.** Las dos ramas del condicional imprimen PASS e incrementan el contador — si el dashboard es inalcanzable, la verificación reporta "listo para desplegar" y aprueba. Llamarla DAST es una exageración considerable; es una sonda de alcanzabilidad, como mucho.
- **TruffleHog se nombra en el texto de salida pero nunca se invoca.** Solo corre Gitleaks.
- **No hay SCA.** No existe escaneo de dependencias ni de imágenes de contenedor en ninguno de los dos pipelines, a pesar de que el nombre del workflow de CI lo menciona.

### 5.2 Pipeline de CI — `.github/workflows/security-ci.yml`

Cuatro pasos sobre `ubuntu-latest`: ShellCheck (`ludeeus/action-shellcheck`, `scandir: ./bin`), Gitleaks, Semgrep (`p/security-audit`, `p/secrets`, `p/bash`) y Trivy en modo `config` contra `docker/single-node`.

Diferencias con la corrida local que importan:

- **Semgrep corre solo en CI**, nunca localmente.
- **CI escanea únicamente `bin/`** — `scripts/` está cubierto localmente pero no en CI.
- **`omarchy plugin validate` nunca corre en CI**, porque el CLI de Omarchy no está disponible en un runner de GitHub. La validación de QML y del manifiesto es entonces solo local, y solo para quienes tengan Omarchy instalado.
- **Trivy tampoco bloquea en CI.** El exit code por defecto de la action es 0 y no se sobreescribe.

Así que las compuertas que hoy realmente hacen cumplir algo son ShellCheck, Gitleaks y Semgrep. Todo lo demás es informativo, y la lista honesta de arreglos es corta: poner un exit code distinto de cero en Trivy, hacer que la verificación 6 falle cuando la sonda falla o sacarla, hacer que una herramienta faltante sea falla dura en CI, y o bien cablear SCA de verdad o dejar de mencionarlo.

---

## 6. ❓ Preguntas abiertas

Dónde quiero el criterio de los mantenedores y de la comunidad de Omarchy, más o menos en el orden en que me importan las respuestas:

1. **¿El cambio de default de la Propuesta B es aceptable siquiera?** Deshabilitar la autenticación por contraseña es el único lugar donde este RFC toca un default de seguridad, y trae riesgo real de lockout. ¿Un cambio validado, con prompt y basado en drop-in es la forma correcta — o el hardening debería quedar enteramente opt-in, detrás de un comando aparte que el usuario tenga que ir a buscar?
2. **¿Un hook de EDR pertenece a Omarchy, o debería quedar como plugin de terceros para siempre?** El sistema de plugins hace que la Propuesta C funcione perfectamente fuera del árbol. El argumento a favor de subirla es la descubribilidad para usuarios corporativos; el argumento en contra es que Omarchy estaría avalando sensores propietarios al documentarlos. Me inclino por "documentar el hook, no avalar nada", pero esta es una decisión de los mantenedores sobre la identidad del proyecto, no una pregunta técnica.
3. **¿`omarchy firewall` justifica la superficie de CLI?** `ufw allow 3000` ya funciona. Si la respuesta es "el CLI se queda chico", la Propuesta A se descarta y no se pierde nada.
4. **¿Cuánto debería poder hacer el agente de código?** Este RFC se detiene deliberadamente en "abrir una terminal con el contexto cargado". ¿Incluso eso es demasiada automatización para tener corriendo en una máquina de desarrollo? ¿Una notificación de escritorio con un comando copiable es el techo correcto en su lugar?
5. **¿Cuál es el comportamiento correcto con un kernel rolling?** Si un salto del paquete `linux` deja en silencio a un sensor de proveedor en modo de funcionalidad reducida, ¿debería avisar algo? Un hook de pacman es posible, pero agrega toda una clase de mantenimiento que nadie pidió.
6. **¿Algo de esto debería ser problema de Omarchy?** El resultado más útil de este hilo puede ser "no — que siga siendo un plugin, y este es el único hook que aceptaríamos". Es un resultado perfectamente válido y vale la pena decirlo sin vueltas si es lo que piensan.

Comentarios, objeciones y rechazos lisos y llanos son todos útiles. Respuestas por propuesta son más útiles que un veredicto sobre el documento entero.
