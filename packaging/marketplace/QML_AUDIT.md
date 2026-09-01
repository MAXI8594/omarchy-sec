# Auditoría adversarial del plugin QML — omarchy-sec

**Alcance:** `/home/max/Projects/omarchy-sec-plugin` @ `ec6cbd9` (solo lectura, sin modificar).
**Fecha:** 2026-09-01 · **Método:** lectura completa + verificación ejecutable de cada predicado.
**Archivos:** `WazuhService.qml` (387), `Panel.qml` (422), `BarWidget.qml` (81), `Model.js` (27), `manifest.json` (50).

Contrastado además contra el host real (`/usr/share/omarchy/shell`, omarchy 4.0.1-1, quickshell 0.3.1-1)
y contra el productor de los datos (`bin/omarchy-sec-detect` de este repo).

---

## ALTA

### A1 · La validación del helper corre una sola vez por sesión: instalar el paquete después de arrancar el shell no revive el widget nunca

`WazuhService.qml:200` — `Component.onCompleted: root.validateCandidate()` es el **único**
llamador de `validateCandidate()`. Si en ese instante `/usr/bin/omarchy-sec-detect` no existe
o no pasa la validación, `resolvedHelper` queda en `""` (`:122`) y ya no se vuelve a intentar.

`pollTimer` (`:379-386`) sigue disparando `refresh()` cada 30 s, y `refresh()` retorna en la
primera línea:

```qml
// WazuhService.qml:205-207
function refresh() {
  if (root.resolvedHelper === "") return
```

No hay reintento, no hay log en los ciclos siguientes, y no hay nada en la UI que diga
"reiniciá el shell". El tooltip sigue diciendo *"Estado desconocido · falta el paquete
omarchy-sec"* aunque el paquete ya esté instalado.

**Cómo lo vive el usuario:** instala el plugin desde el marketplace → ve gris → instala
`omarchy-sec` → **el widget sigue gris para siempre**. Es exactamente la secuencia que va a
hacer todo el mundo, y en ese orden.

**Evidencia** — el journal de esta máquina, congelado en ese estado desde las 17:04:

```
$ journalctl --user --since "-3 days" | grep -i 'omarchy-sec'
Sep 01 17:04:19 omarchy-shell[2649885]: WARN qml: omarchy-sec: /usr/bin/omarchy-sec-detect no pasa la validacion (regular, de root, no escribible por otros); estado desconocido
Sep 01 17:04:19 omarchy-shell[2649885]: WARN qml: omarchy-sec: /usr/bin/omarchy-sec no pasa la validacion; 'Call Agent' queda deshabilitado
```

Una línea, y después silencio absoluto. Han pasado ~14 minutos de polls que no hicieron nada
y no dejaron rastro.

```
$ ls -l /usr/bin/omarchy-sec-detect
ls: cannot access '/usr/bin/omarchy-sec-detect': No such file or directory
```

**Fix mínimo:** revalidar cuando `resolvedHelper === ""`, dentro del mismo `pollTimer` —
`validateCandidate()` cuesta 0 ms medidos (ver abajo), no hay razón para no reintentarlo.

---

### A2 · El texto dice "Protegido" y el color dice lo contrario: salen de dos campos distintos sin ningún cruce

`WazuhService.qml:36-53`. El **texto** se deriva sólo de `activeSensorCount`; el **color** se
deriva sólo de `isProtected`. `applyDetect` valida los dos campos por separado (`:278` valida
`status`, `:280-281` valida `activeCount`) y nunca comprueba que sean coherentes entre sí.

```qml
// :36-41  — statusText no consulta isProtected en ningún momento
readonly property string statusText: {
  if (!root.detectorAvailable) return "Estado desconocido · falta el paquete omarchy-sec"
  if (root.activeSensorCount > 1) return "Multi-EDR (" + root.activeSensorCount + " activos) · Protegido"
  if (root.activeSensorCount === 1) return root.primarySensor + " · Protegido"
  return "Desprotegido (Sin EDR Activo)"
}

// :49-53  — statusColor no consulta activeSensorCount en ningún momento
readonly property color statusColor: {
  if (!root.detectorAvailable) return Color.muted
  if (root.isProtected) return root.protectedColor
  return Color.urgent
}
```

Consecuencia directa, con payloads que **pasan enteros la validación de esquema**:

| JSON del helper | `statusText` | color |
|---|---|---|
| `{"status":"unprotected","activeCount":2}` | `Multi-EDR (2 activos) · Protegido` | **rojo** |
| `{"status":"protected","activeCount":0}` | `Desprotegido (Sin EDR Activo)` | **verde** |

La primera fila es el peor caso que pediste rastrear: **la palabra "Protegido" en pantalla sin
que `isProtected` sea true**. Aparece en el tooltip de la barra (`BarWidget.qml:60`) y en el
subtítulo del panel (`Panel.qml:97-99`).

**Alcanzabilidad:** con el helper que se envía hoy, no. `bin/omarchy-sec-detect:107-110` fija
`status=protected` si y sólo si `active_count >= 1`, así que los dos campos van sincronizados
por construcción. Pero `applyDetect` es explícitamente la frontera de confianza para la salida
del helper (comentario en `:266-268`: *"Nada de la salida del helper llega a una propiedad sin
pasar por aca"*) y ahí no se valida la invariante que sostiene todo el display. La coherencia
depende hoy de un script, no del validador.

**Fix mínimo:** derivar las dos cosas del mismo valor, o rechazar el payload en `applyDetect`
si `(data.status === "protected") !== (count >= 1)`.

---

## MEDIA

### M1 · El escapado de comillas de `refresh()` no escapa nada — produce una cadena que bash rechaza

`WazuhService.qml:225`:

```qml
var quoted = "'" + String(root.resolvedHelper).replace(/'/g, "'\''") + "'"
```

En JavaScript, `\'` dentro de un literal con comillas dobles es simplemente `'`. El literal
`"'\''"` es la cadena de **3 caracteres** `'''`, no el modismo shell de 4 caracteres `'\''`.

```
$ node /tmp/esc.js
replacement literal is: "'''" len 3
quoted = '/usr/bin/oma'''rchy-sec-detect'
correct = '/usr/bin/oma'\''rchy-sec-detect'

$ bash -c "echo '/usr/bin/oma'''rchy'"
bash: -c: line 1: unexpected EOF while looking for matching `''
```

**No es explotable hoy:** `resolvedHelper` sólo puede valer la constante
`/usr/bin/omarchy-sec-detect` (`:142`, asignada en `:166`), que no contiene comillas, así que
el `replace` nunca sustituye nada. Es una trampa latente: la función *parece* sanitizar y no
sanitiza. Si mañana la ruta se vuelve configurable, la primera comilla la rompe.

Forma correcta en QML/JS: `.replace(/'/g, "'\\''")`.

**Todo lo demás que se interpola en ese comando está limpio:** `Math.ceil(root.deadlineMs/1000)`
y `root.maxStdoutBytes` son `int` de propiedades readonly, y `scopeUnit` (`:223-224`) se compone
de `Date.now()` + `Math.floor(Math.random()*100000)`. No entra nada más.

---

### M2 · "Call Agent" se ve igual esté habilitado o no, y al hacer click no pasa nada

`Panel.qml:392-417` dibuja el botón sin consultar `service.agentValidated` en ningún lado —
ni `enabled`, ni `opacity`, ni el color del borde. Al hacer click:

```qml
// Panel.qml:405-408
onClicked: {
  if (service) service.callAgent()
  root.close()          // el panel se cierra igual
}
```

y `callAgent()` (`WazuhService.qml:107-114`) escribe una advertencia al journal y retorna.
El panel se cierra, no pasa nada, y el usuario no tiene forma de saber por qué.

En esta máquina `agentValidated` es `false` ahora mismo (ver el journal de A1), así que el
botón está en ese estado en este preciso momento.

---

### M3 · "Refrescar" es un no-op silencioso justo en el estado en que uno lo apretaría

`Panel.qml:381` → `service.refresh()` → retorna en `:207` (`resolvedHelper === ""`) o en
`:208` (`detectProcess.running`). Sin log, sin cambio visual, sin spinner. Misma clase que M2:
el único caso en que un usuario aprieta "Refrescar" es cuando el widget está gris, que es
exactamente el caso en que el botón no hace nada.

---

### M4 · El panel no tiene fila para dos de los siete sensores que el helper reporta — y uno de ellos cuenta como "protegido"

`bin/omarchy-sec-detect:141-148` emite `sensors.ebpf` y `sensors.auditd`, y `ebpf` **incrementa
`active_count`** (`:94-97`). `Panel.qml` sólo dibuja filas para `wazuh` (`:133`), `crowdstrike`
(`:178`), `cortex` (`:223`) y `defender` (`:268`).

Resultado en un host con sólo Falco/Tetragon: la barra queda **verde**, `statusText` dice
`Falco eBPF · Protegido`, y las cuatro filas del panel dicen "Inactivo / No detectado". El
usuario abre el panel para ver *qué* lo protege y no encuentra nada.

`sentinelone` tiene el mismo agujero: el helper lo emite (`:133-136`) y lo cuenta (`:82-86`),
pero no hay fila. El comentario de `Panel.qml:267` dice `// 4. Microsoft Defender / SentinelOne`
y la fila que sigue sólo lee `sensors.defender` (`:291`, `:300`, `:304`, `:307`).

---

### M5 · Arranca afirmando "Desprotegido" antes de haber medido nada

`WazuhService.qml:13` (`detectorAvailable: true`) + `:16` (`activeSensorCount: 0`) hacen que
`statusText` caiga en la última rama: **`"Desprotegido (Sin EDR Activo)"` en rojo**, desde la
creación del componente hasta que vuelve el primer detect.

Es la inversión exacta del principio que el propio código declara en `:348-349`:
*"Sin detector no sabemos nada. Reportar 'desprotegido' seria una falsa alarma en un widget de
seguridad: se marca como desconocido."* — la política es correcta en el manejo de errores y
está mal puesta en el estado inicial.

**Cuantificado, la ventana es corta** (no lo agrando más de lo que es):

```
helper: 0.070s, 0.068s, 0.068s
find  : 0.000s, 0.000s, 0.000s
ventana de arranque (2 find + 1 helper) ~= 0.07 s
```

~70-100 ms de flash rojo en cada arranque y en cada recarga del plugin. Se vuelve permanente
sólo si `validateProcess` nunca emitiera `onExited`. Fix de una palabra:
`property bool detectorAvailable: false`.

---

## BAJA · código muerto, referencias huérfanas y consistencia

### B1 · Propiedades y funciones declaradas que nadie lee

Barrido mecánico (`grep` de cada símbolo declarado contra todo el plugin):

| Símbolo | Declarado | Escrito | Leído |
|---|---|---|---|
| `lastCheck` | `WazuhService.qml:18` | `:317` | **nunca** |
| `primaryType` | `:15` | `:262`, `:314` | **nunca** |
| `knownTypes` | `:33-34` | — | sólo para validar `primaryType`, que nadie lee |
| `homeDir` | `:120` | — | **nunca** (resto del candidato `~/.local/bin` eliminado) |
| `enableNotifications` | `:22` | — | **nunca** |
| `Model.deriveStatus` | `Model.js:6-10` | — | **0 llamadores** |

Notas:

- **`enableNotifications` es visible para el usuario.** `manifest.json:42-47` lo publica como
  *"Notificaciones de escritorio"* con un toggle en la UI de settings. El plugin ofrece un
  ajuste que no hace absolutamente nada.
- **`lastCheck` es el que más duele que esté muerto.** Es un widget cuyo valor depende de que
  el dato sea fresco, calcula la hora del último chequeo, y no la muestra en ningún lado.
- **`Model.deriveStatus` ya divergió** de su reemplazo: devuelve
  `"Multi-EDR Protegido (n activos)"` mientras que `statusText` (`WazuhService.qml:38`) devuelve
  `"Multi-EDR (n activos) · Protegido"`. Es la misma clase de deriva que la regresión de
  `refresh()`, sólo que esta todavía no explotó porque nadie la llama.
- `import "Model.js" as Model` en `WazuhService.qml:5` y `BarWidget.qml:4`: ninguno de los dos
  archivos referencia `Model.` (verificado por grep). El único uso real es `Panel.qml:34`.

**Comentario obsoleto:** `WazuhService.qml:124-130` todavía describe el mecanismo anterior
("*se sondea la existencia del archivo*", "*leerlos para probar existencia es barato*", y la
nota `ponytail:` sobre binarios grandes). El código de abajo ya no lee ningún archivo: usa
`find`. El comentario describe una implementación que no existe.

### B2 · Dos vocabularios distintos para el mismo concepto

`Model.js:16-25` usa las claves `crowdstrike` y `ebpf`; `WazuhService.qml:33-34` (`knownTypes`)
usa `falcon` y `falco` para lo mismo. Hoy no se cruzan (`sensorName` sólo recibe
`selectedSensor`, que viene de las filas hardcodeadas del panel), pero son dos taxonomías
conviviendo en un plugin de cinco archivos.

### B3 · El guard de overflow es inalcanzable: el tope real lo pone el pipe, no el QML

`WazuhService.qml:332-340` compara `collected.length + data.length` contra `maxStdoutBytes`,
pero el comando ya trae `| /usr/bin/head -c 65536` (`:232`). `head` corta a 64 KiB y `collected`
acumula como mucho un `\n` por línea dentro de ese presupuesto, así que la suma nunca puede
superar el tope. La rama `overflowed = true` es código muerto.

Y cuando el helper *sí* se pasa, el camino real es otro:

```
$ bash -c "set -o pipefail; yes AAAA | /usr/bin/head -c 100 | wc -c"
100
rc=141
```

`head` cierra, el productor se come un SIGPIPE, `pipefail` propaga 141, y `onExited` toma la
rama `exitCode !== 0` de `:350` → `markUnknown()`. **El diseño es correcto y falla cerrado dos
veces**; el punto es que `overflowed`, el `abortDetect` dentro de `onRead` y los dos
`if (root.overflowed) return` (`:332`, `:345`) son ~10 líneas que aparentan ser el límite
load-bearing cuando el límite lo pone el shell.

### B4 · `cleanString` deja pasar los caracteres Unicode invisibles y de dirección

`WazuhService.qml:75` filtra `[\x00-\x1f\x7f]` y `[<>&]`, nada más:

```
== cleanString ==
  "A‮B"       -> "A‮B"      [RTL override U+202E]
  "A​B"       -> "A​B"      [zero width U+200B]
  "A B"       -> "A B"      [line separator U+2028]
  "A\tB"           -> "A B"           [tab]
  "<script>x&y"    -> "scriptxy"      [angle brackets + amp]
  "   "            -> "FALLBACK"      [whitespace only]
```

`primarySensor` sale de acá (`:313`) y va directo al tooltip de la barra
(`BarWidget.qml:60`) y al subtítulo del panel. Un U+202E permite invertir visualmente el nombre
del sensor mostrado.

No es alcanzable con el helper actual (`bin/omarchy-sec-detect:113-151` interpola sólo literales
hardcodeados en `primary`), pero `cleanString` existe precisamente para el caso en que el helper
sea otro, y un spoof de nombre en un indicador de seguridad es justo lo que esa función tiene
que frenar. Agregar `​-‏‪-‮⁦-⁩  ` al filtro es una línea.

### B5 · El rojo y el gris nunca llegan al glifo de la barra

`BarWidget.qml:57-59` pasa `active: service.isProtected` y `activeColor: service.statusColor`.
El host resuelve:

```qml
// /usr/share/omarchy/shell/Ui/WidgetButton.qml:80  (idéntico en Ui/BarIconButton.qml:36)
color: root.active && root.useActiveColor ? root.activeColor : root.foreground
```

Con `active === false` el `activeColor` se descarta: el glifo queda en `root.foreground`, el
color normal de la barra. O sea, el ícono es **verde cuando protege y color de barra en todos
los demás casos** — ni `Color.urgent` ni `Color.muted` lo tocan nunca.

Los estados siguen siendo distinguibles porque el punto de 6 px (`BarWidget.qml:69-80`) sí
bindea `service.statusColor` directo. Pero "desprotegido" y "estado desconocido" se diferencian
de "protegido" únicamente por un punto de 6 px en la esquina.

### B6 · `ipcTarget` declarado y muerto

`Panel.qml:11-12` fija `ipcTarget` y `manageIpc: false`. Eso **desactiva** el `IpcHandler` de
la clase base (`Ui/Panel.qml:48-49`, `enabled: root.manageIpc && root.ipcTarget !== ""`), y a
diferencia de los plugins de stock que hacen lo mismo — clock pone el handler en su
`BarWidget.qml:129`, dropbox declara el suyo en `Panel.qml:159` — este plugin **no declara
ningún `IpcHandler` en ninguna parte**. El target IPC publicado es inerte.

No rompe el routing de `summon/hide/toggle` del shell, que va por `Bar.findPanelWidget` sobre
`open`/`close`/`opened` del bar-widget (contrato que el plugin sí cumple). Pero o sobran las dos
líneas, o falta el handler.

### B7 · Dos instancias de `WazuhService` por shell — una por monitor

Todas las líneas del journal aparecen duplicadas, y la regresión de `refresh()` de esta mañana
nombró dos objetos distintos dentro del mismo PID de shell:

```
$ journalctl --user --since "-3 days" | grep -o "WazuhService_QMLTYPE_[0-9]*(0x[0-9a-f]*)" | sort -u
WazuhService_QMLTYPE_378(0x7f8a7853f280)
WazuhService_QMLTYPE_378(0x7f8a785ec480)
WazuhService_QMLTYPE_378(0x7fec708dbca0)
WazuhService_QMLTYPE_378(0x7fec7094dea0)

$ hyprctl monitors -j | ...
2 monitor(s): ['DP-1', 'HDMI-A-1']
```

La superficie de la barra se construye por monitor, así que el detector corre N veces por ciclo
en un setup de N monitores. Cada corrida son ~10 `systemctl is-active` + un `pgrep` + un
`docker ps` (70 ms medidos). Correcto pero duplicado; vale la nota porque escala con los
monitores y no con nada que el usuario pueda ver.

---

## Revisado y limpio

Verificado ejecutando, no por lectura. Nada que reportar en:

1. **`validationArgs` — todos los predicados de `find`** (`WazuhService.qml:147-155`). El fix de
   `-size -1048577c` es correcto: la unidad `c` cuenta bytes exactos y no redondea como hacía
   `-1M`.
   ```
   exact(1048576): 1     over(1048577): 0     exact con -size -1M: 0   ← el bug viejo
   ! -perm /022 sobre 0664: 0     sobre 0755: 1
   ```
   `-type f ! -type l` (`-type f` ya excluye symlinks porque `find` usa `lstat` por defecto),
   `-user root`, `-perm -u+x` y `-maxdepth 0` hacen lo que dicen.

2. **`safeUrl`** (`:86-92`). 18 vectores probados; no pasó ninguno peligroso y todos los
   aceptados son inofensivos como un único `argv` de `xdg-open` (`execDetached` con array, sin
   shell). Rechaza `file://`, `javascript:`, `data:`, `ftp://`, `https:///etc`, `https://`,
   prefijos con espacio (`x https://…`) y cualquier control char (incluido `\n`). Acepta
   `HTTPS://` en mayúsculas y hace `trim()` correctamente.

3. **El corte del scope de systemd** (`killDetectScope`, `:243-247`). Mata el árbol entero,
   sincrónico, verificado:
   ```
   -- descendants -- 3489927 /bin/bash -c set -o pipefail; ...
                     3489979 /usr/bin/timeout -k 2 10 /bin/bash -c sleep 300
   -- after systemctl --user stop <unit>.scope -- inactive, ambos PIDs desaparecidos
   systemd-run exit = 143
   ```
   El razonamiento del comentario `:211-216` sobre `setsid` es correcto y el reemplazo funciona.

4. **`set -o pipefail` + `timeout -k 2 10`** en el comando construido. Un fallo del helper llega
   como exit ≠ 0 a través de `head`: probado `/bin/false | head -c 65536` → `rc=1`.

5. **`applyDetect`, validación de esquema** (`:269-319`). Rechaza no-objetos, arrays, `null`, y
   `status` fuera de `{protected, unprotected}`; acota `activeCount` a `[0,99]`, las claves de
   `sensors` a 24 y los campos por sensor a 8; descarta valores que no sean string/number/bool.
   Las claves que consume `Panel.qml` (`wazuh.agent`, `crowdstrike.status`, `cortex.status`,
   `defender.status`) coinciden exactamente con las que emite el helper.

6. **Todos los caminos que ponen `isProtected = true`.** Hay exactamente uno: `:312`, dentro de
   `applyDetect`, con `nowProtected = (data.status === "protected")` y sólo después de que el
   payload pasó entero la validación. Lo bajan `markUnknown()` (`:259`, con 4 llamadores:
   validación fallida, deadline, overflow, exit ≠ 0 o salida vacía) y el propio `:312`. **No hay
   ningún camino que deje `isProtected` en true con datos viejos.** El único problema de display
   es A2, que es la palabra "Protegido" saliendo de otro campo.

7. **Máquina de estados, reseteo de `collected` y refrescos pisados.** `refresh()` limpia
   `collected` y `overflowed` (`:209-210`) antes de cada corrida, y el guard `detectProcess.running`
   (`:208`) impide que dos detects se solapen, así que `deadline.restart()` no puede reiniciarse
   sobre una corrida ajena. Si el deadline dispara mientras `validateAgent` sigue corriendo no
   pasa nada: no comparten estado. `validateAgent` no tiene deadline pero falla cerrado
   (`agentValidated` se queda en false). El único bloqueo posible es si `detectProcess.running`
   quedara pegado en true tras el SIGTERM — y aun ahí el estado visible es `markUnknown()`
   (gris), nunca verde.

8. **Contrato de ciclo de vida con el shell.** `opened`, `popoutSwitchClosing`, `open()`,
   `close()`, `togglePanel()`, `closeForPopoutSwitch()`, `injectPanel()`, `barIdentity` y el
   override de `switchPanel(direction)` coinciden literalmente con la convención de
   `plugins/panels/clock` y `plugins/panels/weather`. `bar.switchPanelFrom(owner, …)`
   (`plugins/bar/Bar.qml:435`) compara `slot.activeItem === owner`, y `barIdentity` resuelve al
   BarWidget, que es el `activeItem`. Correcto.

9. **Referencias a la API del host.** Existen todas: `PanelHero`, `OpticalGlyph`,
   `PanelSeparator`, `KeyboardPanel`, `PanelKeyCatcher`, `BarIconButton`, `Style.cornerRadius`
   (`Commons/Style.qml:31`), `Style.space` (`:219`), `Style.bar.statusSlot` (`:347`),
   `Color.muted` / `Color.urgent` (`Commons/Color.qml:22-23`). Los glifos `text: ""` no están
   vacíos: son PUA de Nerd Font (`ef 84 b2` = U+F112, verificado con hexdump).

10. **Ids y funciones huérfanas.** Barrido completo: sólo `Model.deriveStatus` tiene 0 llamadores
    (ver B1). `open()` y `closeForPopoutSwitch()` tienen 0 llamadores *dentro del plugin* pero son
    parte del contrato que invoca el host — no son código muerto. El id `pollTimer` no se
    referencia desde ningún lado, cosa que es normal.

11. **`textFormat: Text.PlainText`** está declarado en los 14 `Text` del panel. Verificado uno
    por uno; no hay ninguno sin él.

12. **`bin/omarchy-sec-detect` bajo `set -euo pipefail`.** Sospeché de la línea 96
    (`[ … ] && a=… && b=…` como comando de primer nivel, que suele matar un script con `set -e`)
    y **no es un bug**: bash ignora el fallo de un comando que no es el último de una lista `&&`.
    Probado con el script real y un `systemctl` falso que reporta wazuh+falco activos: sale JSON
    completo y `exit = 0`.

---

## Resumen ordenado

| # | Severidad | Archivo:línea | Qué |
|---|---|---|---|
| A1 | **Alta** | `WazuhService.qml:200`, `:207` | Valida una sola vez; instalar el paquete después no revive el widget |
| A2 | **Alta** | `WazuhService.qml:36-53` | `statusText` y `statusColor` salen de campos distintos: puede decir "Protegido" en rojo |
| M1 | Media | `WazuhService.qml:225` | `"'\''"` en JS es `'''`: el escapado shell no escapa (latente) |
| M2 | Media | `Panel.qml:392-417` | "Call Agent" no refleja `agentValidated`; click = no-op silencioso |
| M3 | Media | `Panel.qml:381` | "Refrescar" es no-op silencioso justo cuando el widget está gris |
| M4 | Media | `Panel.qml:133-310` | Faltan filas para `ebpf` (que cuenta como protegido) y `sentinelone` |
| M5 | Media | `WazuhService.qml:13` | Arranca en rojo "Desprotegido" ~70-100 ms antes de medir nada |
| B1 | Baja | varios | `lastCheck`, `primaryType`, `knownTypes`, `homeDir`, `enableNotifications`, `deriveStatus` muertos; comentario `:124-130` obsoleto |
| B2 | Baja | `Model.js` vs `WazuhService.qml:33` | `crowdstrike`/`ebpf` vs `falcon`/`falco` |
| B3 | Baja | `WazuhService.qml:332-340` | Guard de overflow inalcanzable (el tope lo pone `head -c` + `pipefail`) |
| B4 | Baja | `WazuhService.qml:75` | `cleanString` deja pasar U+202E / U+200B / U+2028 |
| B5 | Baja | `BarWidget.qml:57-59` | El rojo/gris nunca llega al glifo, sólo al punto de 6 px |
| B6 | Baja | `Panel.qml:11-12` | `ipcTarget` con `manageIpc:false` y ningún `IpcHandler` que lo tome |
| B7 | Baja | `BarWidget.qml:35` | Una instancia del servicio por monitor: el detector corre N veces por ciclo |

Ninguno de los hallazgos es una vulnerabilidad explotable. Los dos de severidad Alta son de
corrección funcional y ambos se arreglan en pocas líneas.
