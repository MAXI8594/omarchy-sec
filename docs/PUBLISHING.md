# 🚀 Publishing to Omarchy Plugin Marketplace

This plugin is 100% compliant with the official **Omarchy Quattro Plugin Development & Marketplace Standards**.

## 1. Local Validation (Already Verified ✓)

```bash
# Validate manifest and repository layout
omarchy plugin validate ~/.config/omarchy/plugins/io.github.maxi8594.omarchy-wazuh

# Test shell lifecycle routing
omarchy-shell shell summon "io.github.maxi8594.omarchy-wazuh" '{}'
omarchy-shell shell hide "io.github.maxi8594.omarchy-wazuh"
```

## 2. Publish to GitHub

1. Create a public repository on GitHub (e.g. `https://github.com/maxi8594/omarchy-wazuh-security` or `omarchy-plugin-wazuh`).
2. Push this repository:
   ```bash
   git init
   git add .
   git commit -m "feat: initial release of Omarchy Wazuh Security Suite"
   git branch -M main
   git remote add origin https://github.com/<your-username>/<repo-name>.git
   git push -u origin main
   ```

## 3. Submit to the Marketplace

Submit the plugin using the official Omarchy Marketplace Issue template:
👉 [**Submit Plugin to Omarchy Marketplace**](https://github.com/omacom/omarchy-plugin-marketplace/issues/new?template=submit-plugin.yml)

### Submission Form Fields:
* **Plugin ID:** `io.github.maxi8594.omarchy-wazuh`
* **Plugin Name:** `Wazuh Security & EDR`
* **Repository URL:** `https://github.com/<your-username>/<repo-name>`
* **Category:** `Security` / `System`
* **Kind:** `bar-widget`
* **Description:** Real-time Wazuh EDR & XDR security health monitoring, incident dispatcher with autonomous AI response, and quick SOC dashboard access.
