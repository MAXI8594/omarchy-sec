# 🚀 Publicación en el Omarchy Plugin Marketplace

Esta guía cubre **uno** de los tres entregables del proyecto: el **widget de barra de
Quickshell**, que se envía al [Omarchy Plugin Marketplace](https://plugins.omarchy.org/).

| Entregable | Canal | ¿Cubierto acá? |
| :--- | :--- | :--- |
| Widget de barra — [`MAXI8594/omarchy-sec-plugin`](https://github.com/MAXI8594/omarchy-sec-plugin) | Issue de envío al marketplace | ✅ este documento |
| CLI `omarchy-sec` + servicio watcher — este repositorio | Paquete AUR ([Creating packages](https://wiki.archlinux.org/title/Creating_packages)) | ❌ ver `packaging/aur/` |
| Propuestas de config del sistema — [`OMARCHY_UPSTREAM_PR.es.md`](OMARCHY_UPSTREAM_PR.es.md) | RFC / documento de diseño en el Discord de Omarchy, `#omarchy-security` | ❌ sin paso de marketplace |

> **Por qué el widget está en un repositorio aparte.** El marketplace exige un
> repositorio público por plugin, y su escáner automático marca las capacidades
> `installer`, `service-management` y `package-manager` para revisión manual. Un script
> instalador y un unit de systemd conviviendo con el QML las dispararían en cada
> release, así que el repo del widget contiene QML, un manifiesto, un README y una
> licencia — nada más.

---

## 1. Requisitos del Repositorio

Todo lo de abajo se verifica contra el **commit exacto** que enviás.

| Requisito | Detalle | Estado |
| :--- | :--- | :--- |
| **Repositorio público de GitHub** | Uno por plugin. Se envía la **URL raíz** — sin barra final ni sufijo `/tree/main`. | ✅ `https://github.com/MAXI8594/omarchy-sec-plugin` |
| **`manifest.json` en la raíz del repo** | No en un subdirectorio. | ✅ |
| **`README` en la raíz del repo** | Debe documentar **instalación y remoción**. | ✅ |
| **Archivo de licencia en la raíz** | Además debe documentar las **dependencias externas** del plugin. | ✅ `LICENSE` |
| **Plugin ID globalmente único** | No puede estar dentro del namespace reservado `omarchy.*`. | ✅ `io.github.maxi8594.omarchy-sec` |
| **Imagen de preview** *(opcional)* | `preview.png`, `.jpg`, `.jpeg`, `.webp` o `.avif` en la raíz. Máximo **50 MB** y **40 megapixels**. | ✅ `preview.png` — 482×504, 0.24 MP, 183 KB |

---

## 2. Validar Localmente Antes de Enviar

El CLI de Omarchy valida una carpeta de plugin contra el esquema del manifiesto y sale
con código `0` cuando pasa:

```bash
git clone https://github.com/MAXI8594/omarchy-sec-plugin.git
omarchy plugin validate ./omarchy-sec-plugin
echo $?     # 0 = válido
```

**Cuando pasa, no imprime nada** — el validador es silencioso y sale con `0`. Mirá el código de salida, no la salida estándar.

Después verificá que los caminos de instalación y remoción documentados funcionen de
verdad en una máquina limpia:

```bash
omarchy plugin add https://github.com/MAXI8594/omarchy-sec-plugin.git --enable
omarchy plugin disable io.github.maxi8594.omarchy-sec
omarchy plugin remove  io.github.maxi8594.omarchy-sec
```

> ⚠️ **El shell cachea el QML compilado.** Hace hot-reload al cambiar archivos en `~/.config/omarchy/plugins/`, pero un cambio de QML no se aplica de verdad hasta correr:
> ```bash
> omarchy restart shell
> ```
> Probá contra un shell reiniciado antes de enviar, o vas a estar validando un build viejo de tu propio widget.

---

## 3. Escaneo Automático de Seguridad

El commit enviado se escanea automáticamente. Los hallazgos caen en dos categorías.

### 🚫 Hallazgos bloqueantes

Un envío que arrastre cualquiera de estos no avanza:

| Hallazgo | Qué lo dispara |
| :--- | :--- |
| `curl-pipe-shell` | Piping de un script descargado directo a una shell |
| `cargo-git-unpinned` | Dependencia git de `cargo` sin revisión fijada |
| `remote-git-execution-unpinned` | Ejecución de código de un remoto git sin pinnearlo |
| `sudoers-dangerous-passwordless-command` | Entrada de `sudoers` sin contraseña para un comando peligroso |
| `privileged-process-control-from-shared-temp` | Control de procesos privilegiados desde un directorio temporal compartido |

### ⚠️ Capacidades que fuerzan revisión manual

Estas **no** bloquean el envío, pero lo sacan del camino automático y lo mandan a una
cola de revisión humana:

`installer` · `package-manager` · `privilege` · `remote-build` ·
`bundled-executable-binary` · `service-management` · `sudoers-modification`

El repositorio del widget no declara ninguna — esa es exactamente la razón por la que el
CLI, el instalador y el unit de systemd se quedaron en
[`MAXI8594/omarchy-sec`](https://github.com/MAXI8594/omarchy-sec) y se distribuyen por AUR.

---

## 4. Abrir el Issue de Envío

👉 [**Enviar el plugin al Omarchy Marketplace**](https://github.com/omacom/omarchy-plugin-marketplace/issues/new?template=submit-plugin.yml)

El issue se parsea, no sólo se lee. Cuatro reglas importan:

1. El **título del issue tiene que empezar con `[Plugin]:`**.
2. Los **headings del template no se pueden reordenar ni omitir** — dejalos tal cual se generan.
3. La **categoría es case-sensitive** — usá el valor exactamente como lo escribe el desplegable del template.
4. **Todos los checkboxes tienen que estar tildados.**

### Valores para este envío

| Campo | Valor |
| :--- | :--- |
| **Plugin ID** | `io.github.maxi8594.omarchy-sec` |
| **Nombre** | `Omarchy Sec` |
| **Repository URL** | `https://github.com/MAXI8594/omarchy-sec-plugin` |
| **Kind** | `bar-widget` |
| **Descripción** | Estado de seguridad del endpoint en la barra: detecta Wazuh, CrowdStrike Falcon, Cortex XDR, SentinelOne, Microsoft Defender, Falco/Tetragon y auditd, y despacha incidentes al agente de IA de Omarchy. |
| **Categoría** | Tomar la grafía exacta del desplegable del template |

---

## 5. Resultado de la Revisión

Un listing nuevo no se publica automáticamente. Requiere una **aprobación explícita del
mantenedor** — la decisión `approved-and-verified` — antes de aparecer en el
marketplace. Hasta que esa decisión llegue, el plugin se instala únicamente desde su URL
de git:

```bash
omarchy plugin add https://github.com/MAXI8594/omarchy-sec-plugin.git --enable
```
