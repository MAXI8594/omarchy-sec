# 🧪 Pipeline de Calidad y Seguridad DevSecOps

Corren dos cosas, y no son el mismo conjunto de controles: `tests/run_tests.sh`
en local, a demanda, y `.github/workflows/security-ci.yml` en cada push y Pull
Request a `main`.

## Pipeline local — `tests/run_tests.sh`

| # | Control | Herramienta | ¿Hace fallar la corrida? |
| :--- | :--- | :--- | :--- |
| 1 | Análisis estático de shell | `shellcheck` sobre `bin/` y `scripts/` | Sí — se saltea si `shellcheck` no está instalado |
| 2 | Validación de plugin y manifiesto QML | `omarchy plugin validate` | Sí — se saltea si falta el CLI `omarchy` o un checkout del plugin |
| 3 | Escaneo de secretos | `gitleaks detect --no-git` | Sí — se saltea si `gitleaks` no está instalado |
| 4 | Misconfiguración de IaC | `trivy config docker/single-node --severity HIGH,CRITICAL --exit-code 1` | Sí — se saltea si `trivy` no está instalado |
| 5 | Prueba funcional del motor de detección | ejecuta `bin/omarchy-sec-detect` | Sí |
| 6 | Alcanzabilidad del dashboard del SOC | `curl` contra `https://localhost:9001` | Sí ante un HTTP inesperado; **se saltea** si el stack está apagado |

```bash
./tests/run_tests.sh
```

## Pipeline de CI — `.github/workflows/security-ci.yml`

Cuatro pasos en `ubuntu-latest`:

1. **ShellCheck** (`ludeeus/action-shellcheck`, `scandir: ./bin`)
2. **Gitleaks** (`gitleaks/gitleaks-action@v2`)
3. **Semgrep** (`p/security-audit`, `p/secrets`, `p/bash`)
4. **Trivy** en modo `config` contra `docker/single-node`

## Lo que este pipeline *no* hace

Dicho explícitamente, porque las etiquetas de arriba se leen de más con
facilidad:

- **No hay SCA.** Nada escanea dependencias ni imágenes de contenedor, en
  ninguno de los dos pipelines, a pesar de que el nombre del workflow de CI lo
  menciona. (Aparte: el stack de Wazuh en ejecución sí tiene
  `<vulnerability-detection>` habilitado contra el inventario de paquetes que
  recolecta — eso es una función del stack desplegado, no un control sobre el
  código de este repositorio.)
- **No se usa TruffleHog.** Solo corre Gitleaks. Versiones anteriores de esta
  página listaban ambos; era falso.
- **El control 6 es una sonda de alcanzabilidad, no DAST.** Pregunta si
  `https://localhost:9001` responde. No hace fuzzing, ni crawling, ni prueba la
  aplicación. La salida del script todavía lo rotula `DAST:` — leelo como "el
  dashboard está arriba".
- **Los controles 1–4 se saltean en silencio si la herramienta no está
  instalada.** Un skip no es ni un pase ni una falla, y la corrida igual sale
  con código 0: en una máquina pelada cuatro de los seis controles se evaporan y
  el pipeline reporta éxito. Es la brecha más grande que queda.
- **El control 5 verifica que el script corra, no que la máquina esté
  protegida.** `omarchy-sec-detect` sale 0 haya o no un sensor activo.
- **Semgrep corre solo en CI**, nunca en local; **`omarchy plugin validate`
  corre solo en local**, nunca en CI (el CLI de Omarchy no existe en un runner
  de GitHub); y **CI escanea solo `bin/`**, mientras que la corrida local
  también cubre `scripts/`.

Los controles que hoy realmente bloquean son ShellCheck, Gitleaks, Semgrep y —
cuando las herramientas están instaladas — Trivy y los dos controles
funcionales.
