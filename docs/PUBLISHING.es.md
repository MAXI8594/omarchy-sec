# 🚀 Guía de Publicación en el Marketplace de Omarchy

Este plugin cumple al 100% con los estándares oficiales de desarrollo y publicación de plugins para el shell **Quattro de Omarchy**.

## 1. Validación Local (Verificado con Éxito ✓)

```bash
# Validar estructura y manifiesto con el CLI de Omarchy
omarchy plugin validate ~/.config/omarchy/plugins/io.github.maxi8594.omarchy-sec

# Probar el ciclo de vida (summon y hide)
omarchy-shell shell summon "io.github.maxi8594.omarchy-sec" '{}'
omarchy-shell shell hide "io.github.maxi8594.omarchy-sec"
```

## 2. Subir a GitHub

1. Creá un repositorio público en GitHub (ej. `https://github.com/maxi8594/omarchy-sec`).
2. Subí el código:
   ```bash
   cd /home/max/Projects/omarchy-sec
   git init
   git add .
   git commit -m "feat: lanzamiento inicial de Omarchy Sec"
   git branch -M main
   git remote add origin https://github.com/<tu-usuario>/<tu-repo>.git
   git push -u origin main
   ```

## 3. Registrar en el Marketplace Oficial

Abrí el formulario oficial de envío de plugins:
👉 [**Formulario de Envío en Omarchy Marketplace**](https://github.com/omacom/omarchy-plugin-marketplace/issues/new?template=submit-plugin.yml)

### Datos del Formulario:
* **Plugin ID:** `io.github.maxi8594.omarchy-sec`
* **Nombre:** `Wazuh Security & EDR`
* **Repository URL:** `https://github.com/<tu-usuario>/<tu-repo>`
* **Categoría:** `Security` / `System`
* **Tipo (Kind):** `bar-widget`
* **Descripción:** Monitoreo en tiempo real de Wazuh EDR & XDR, respuesta autónoma a incidentes con agentes de IA y acceso rápido al SOC Dashboard.
