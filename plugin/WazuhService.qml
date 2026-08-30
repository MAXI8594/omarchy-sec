import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import "Model.js" as Model

Item {
  id: root

  property var settings: ({})

  property bool isProtected: false
  property string primarySensor: "Cargando..."
  property string primaryType: "none"
  property int activeSensorCount: 0
  property var sensorsData: ({})
  property string lastCheck: ""

  readonly property string dashboardUrl: String(setting("dashboardUrl", "https://localhost:9001"))
  readonly property int refreshIntervalSec: intSetting("refreshIntervalSec", 5, 2, 60)
  readonly property bool enableNotifications: setting("enableNotifications", true) === true

  readonly property string statusText: {
    if (root.isProtected) return root.primarySensor + " · Protegido"
    return "Desprotegido (Sin EDR Activo)"
  }

  readonly property color statusColor: {
    if (root.isProtected) return Color.success || "#22c55e"
    return Color.urgent || "#ef4444"
  }

  function setting(name, fallback) {
    var value = settings ? settings[name] : undefined
    return value === undefined || value === null ? fallback : value
  }

  function intSetting(name, fallback, min, max) {
    var n = parseInt(String(setting(name, fallback)), 10)
    if (!isFinite(n)) n = fallback
    if (n < min) n = min
    if (n > max) n = max
    return n
  }

  function openDashboard() {
    Quickshell.execDetached(["xdg-open", root.dashboardUrl])
  }

  function testIncident() {
    Quickshell.execDetached(["omarchy-security-incident", "12", "Prueba de Respuesta a Incidentes", "100201", "127.0.0.1", "/tmp/test.sh"])
  }

  function restartWazuhAgent() {
    Quickshell.execDetached(["pkexec", "systemctl", "restart", "wazuh-agent"])
    pollTimer.restart()
  }

  function refresh() {
    if (detectProcess.running) return
    detectProcess.command = ["omarchy-security-detect"]
    detectProcess.running = true
  }

  Process {
    id: detectProcess
    running: false
    command: []
    stdout: StdioCollector { id: detectStdout; waitForEnd: true }
    onExited: function(exitCode) {
      try {
        var raw = String(detectStdout.text || "").trim()
        if (!raw) return
        var data = JSON.parse(raw)
        root.isProtected = (data.status === "protected")
        root.primarySensor = data.primary || "Desconocido"
        root.primaryType = data.primaryType || "none"
        root.activeSensorCount = data.activeCount || 0
        root.sensorsData = data.sensors || {}
        root.lastCheck = Qt.formatTime(new Date(), "hh:mm:ss")
      } catch (err) {
        console.error("Error parsing security detect JSON:", err)
      }
    }
  }

  Timer {
    id: pollTimer
    interval: root.refreshIntervalSec * 1000
    repeat: true
    running: true
    triggeredOnStart: true
    onTriggered: root.refresh()
  }
}
