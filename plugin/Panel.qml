import QtQuick
import Quickshell
import Quickshell.Io
import qs.Commons
import qs.Ui

Panel {
  id: root
  moduleName: "io.github.maxi8594.omarchy-wazuh"
  ipcTarget: "io.github.maxi8594.omarchy-wazuh"
  manageIpc: false

  property var anchorItem: null
  property var hostWidget: null
  property var service: null

  readonly property var barIdentity: hostWidget || root
  readonly property color foreground: bar ? bar.foreground : Color.foreground
  readonly property color urgent: bar ? bar.urgent : Color.urgent
  readonly property string fontFamily: bar ? bar.fontFamily : Style.font.family
  readonly property color dim: Qt.darker(foreground, 1.4)
  readonly property color successColor: "#22c55e"
  readonly property color warningColor: "#eab308"

  readonly property bool isProtected: service ? service.isProtected : false
  readonly property string primarySensor: service ? service.primarySensor : "Cargando..."
  readonly property color statusColor: service ? service.statusColor : foreground
  readonly property var sensors: service && service.sensorsData ? service.sensorsData : ({})

  function switchPanel(direction) {
    if (root.bar && typeof root.bar.switchPanelFrom === "function")
      return root.bar.switchPanelFrom(root.barIdentity, direction)
    return false
  }

  KeyboardPanel {
    id: panel
    anchorItem: root.anchorItem
    owner: root.barIdentity
    bar: root.bar
    open: root.opened
    focusTarget: keyCatcher
    contentWidth: panel.fittedContentWidth(Style.space(360))
    contentHeight: panel.fittedContentHeight(column.implicitHeight, Style.space(540))

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      Column {
        id: column
        width: parent.width
        spacing: Style.space(10)

        // ---- Encabezado Hero ----
        PanelHero {
          width: parent.width
          title: root.isProtected ? root.primarySensor : "Seguridad del Endpoint"
          foreground: root.statusColor
          fontFamily: root.fontFamily
          iconOpacity: root.isProtected ? 1.0 : 0.7
          iconComponent: Component {
            Item {
              width: Style.space(52)
              height: Style.space(52)
              OpticalGlyph {
                anchors.fill: parent
                text: ""
                fontFamily: root.fontFamily
                fontSize: Style.space(42)
                color: root.statusColor
              }
            }
          }
        }

        PanelSeparator { width: parent.width; foreground: root.foreground }

        // ---- Tarjeta de Sensores EDR / XDR ----
        Rectangle {
          width: parent.width
          implicitHeight: sensorCol.implicitHeight + Style.space(16)
          radius: Style.radius(8)
          color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.06)
          border.color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.12)
          border.width: 1

          Column {
            id: sensorCol
            anchors.fill: parent
            anchors.margins: Style.space(10)
            spacing: Style.space(6)

            Text {
              text: "Sensores y Protección Detectados:"
              font.family: root.fontFamily
              font.pixelSize: Style.space(11)
              font.bold: true
              color: root.foreground
            }

            // Wazuh EDR
            Row {
              width: parent.width
              spacing: Style.space(8)
              Rectangle {
                width: Style.space(8); height: Style.space(8); radius: 4
                color: (sensors.wazuh && sensors.wazuh.agent === "active") ? root.successColor : Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.2)
                anchors.verticalCenter: parent.verticalCenter
              }
              Text {
                text: "Wazuh Open XDR/EDR: " + (sensors.wazuh && sensors.wazuh.agent === "active" ? "Activo (Conectado)" : "Inactivo")
                font.family: root.fontFamily
                font.pixelSize: Style.space(10)
                color: (sensors.wazuh && sensors.wazuh.agent === "active") ? root.foreground : root.dim
              }
            }

            // CrowdStrike Falcon
            Row {
              width: parent.width
              spacing: Style.space(8)
              Rectangle {
                width: Style.space(8); height: Style.space(8); radius: 4
                color: (sensors.crowdstrike && sensors.crowdstrike.status === "active") ? root.successColor : Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.2)
                anchors.verticalCenter: parent.verticalCenter
              }
              Text {
                text: "CrowdStrike Falcon Sensor: " + (sensors.crowdstrike && sensors.crowdstrike.status === "active" ? "Activo" : "No detectado")
                font.family: root.fontFamily
                font.pixelSize: Style.space(10)
                color: (sensors.crowdstrike && sensors.crowdstrike.status === "active") ? root.foreground : root.dim
              }
            }

            // Palo Alto Cortex XDR
            Row {
              width: parent.width
              spacing: Style.space(8)
              Rectangle {
                width: Style.space(8); height: Style.space(8); radius: 4
                color: (sensors.cortex && sensors.cortex.status === "active") ? root.successColor : Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.2)
                anchors.verticalCenter: parent.verticalCenter
              }
              Text {
                text: "Palo Alto Cortex XDR: " + (sensors.cortex && sensors.cortex.status === "active" ? "Activo" : "No detectado")
                font.family: root.fontFamily
                font.pixelSize: Style.space(10)
                color: (sensors.cortex && sensors.cortex.status === "active") ? root.foreground : root.dim
              }
            }

            // Microsoft Defender / SentinelOne
            Row {
              width: parent.width
              spacing: Style.space(8)
              Rectangle {
                width: Style.space(8); height: Style.space(8); radius: 4
                color: (sensors.defender && sensors.defender.status === "active") || (sensors.sentinelone && sensors.sentinelone.status === "active") ? root.successColor : Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.2)
                anchors.verticalCenter: parent.verticalCenter
              }
              Text {
                text: "Defender / SentinelOne: " + (sensors.defender && sensors.defender.status === "active" ? "Defender Activo" : (sensors.sentinelone && sensors.sentinelone.status === "active" ? "S1 Activo" : "No detectado"))
                font.family: root.fontFamily
                font.pixelSize: Style.space(10)
                color: (sensors.defender && sensors.defender.status === "active") || (sensors.sentinelone && sensors.sentinelone.status === "active") ? root.foreground : root.dim
              }
            }
          }
        }

        // ---- Botón: Abrir Dashboard SOC ----
        Rectangle {
          width: parent.width
          height: Style.space(36)
          radius: Style.radius(6)
          color: btnDashArea.containsMouse ? Qt.rgba(root.statusColor.r, root.statusColor.g, root.statusColor.b, 0.2) : Qt.rgba(root.statusColor.r, root.statusColor.g, root.statusColor.b, 0.12)
          border.color: root.statusColor
          border.width: 1

          MouseArea {
            id: btnDashArea
            anchors.fill: parent
            hoverEnabled: true
            cursorShape: Qt.PointingHandCursor
            onClicked: {
              if (service) service.openDashboard()
              root.close()
            }
          }

          Row {
            anchors.centerIn: parent
            spacing: Style.space(8)
            Text { text: "󰖟"; font.family: root.fontFamily; font.pixelSize: Style.space(13); color: root.statusColor; anchors.verticalCenter: parent.verticalCenter }
            Text { text: "Abrir SOC Dashboard (:9001)"; font.family: root.fontFamily; font.pixelSize: Style.space(11); font.bold: true; color: root.statusColor; anchors.verticalCenter: parent.verticalCenter }
          }
        }

        // ---- Botones Secundarios ----
        Row {
          width: parent.width
          spacing: Style.space(8)

          Rectangle {
            width: (parent.width - Style.space(8)) / 2
            height: Style.space(30)
            radius: Style.radius(6)
            color: btnRefreshArea.containsMouse ? Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.1) : "transparent"
            border.color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.2)
            border.width: 1

            MouseArea {
              id: btnRefreshArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: if (service) service.refresh()
            }

            Row {
              anchors.centerIn: parent
              spacing: Style.space(4)
              Text { text: ""; font.family: root.fontFamily; font.pixelSize: Style.space(10); color: root.foreground }
              Text { text: "Refrescar"; font.family: root.fontFamily; font.pixelSize: Style.space(10); color: root.foreground }
            }
          }

          Rectangle {
            width: (parent.width - Style.space(8)) / 2
            height: Style.space(30)
            radius: Style.radius(6)
            color: btnTestArea.containsMouse ? Qt.rgba(root.warningColor.r, root.warningColor.g, root.warningColor.b, 0.15) : "transparent"
            border.color: Qt.rgba(root.warningColor.r, root.warningColor.g, root.warningColor.b, 0.4)
            border.width: 1

            MouseArea {
              id: btnTestArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                if (service) service.testIncident()
                root.close()
              }
            }

            Row {
              anchors.centerIn: parent
              spacing: Style.space(4)
              Text { text: "🤖"; font.family: root.fontFamily; font.pixelSize: Style.space(10); color: root.foreground }
              Text { text: "Test AI Responder"; font.family: root.fontFamily; font.pixelSize: Style.space(10); color: root.foreground }
            }
          }
        }
      }
    }
  }
}
