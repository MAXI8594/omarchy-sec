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
  readonly property string statusText: service ? service.statusText : "Cargando..."
  readonly property color statusColor: service ? service.statusColor : foreground

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
    contentWidth: panel.fittedContentWidth(Style.space(340))
    contentHeight: panel.fittedContentHeight(column.implicitHeight, Style.space(480))

    PanelKeyCatcher {
      id: keyCatcher
      anchors.fill: parent
      onCloseRequested: root.close()
      onTabRequested: function(direction) { root.switchPanel(direction) }

      Column {
        id: column
        width: parent.width
        spacing: Style.space(12)

        // ---- Encabezado ----
        PanelHero {
          width: parent.width
          title: "Wazuh XDR / EDR"
          foreground: root.statusColor
          fontFamily: root.fontFamily
          iconOpacity: root.isProtected ? 1.0 : 0.7
          iconComponent: Component {
            Item {
              width: Style.space(56)
              height: Style.space(56)
              OpticalGlyph {
                anchors.fill: parent
                text: ""
                fontFamily: root.fontFamily
                fontSize: Style.space(46)
                color: root.statusColor
              }
            }
          }
        }

        PanelSeparator { width: parent.width; foreground: root.foreground }

        // ---- Estado del Endpoint ----
        Rectangle {
          width: parent.width
          implicitHeight: endpointCol.implicitHeight + Style.space(16)
          radius: Style.radius(8)
          color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.06)
          border.color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.12)
          border.width: 1

          Column {
            id: endpointCol
            anchors.fill: parent
            anchors.margins: Style.space(10)
            spacing: Style.space(8)

            Row {
              width: parent.width
              spacing: Style.space(8)
              Text {
                text: ""
                font.family: root.fontFamily
                font.pixelSize: Style.space(14)
                color: root.foreground
              }
              Text {
                text: "Endpoint: omarchy-workstation"
                font.family: root.fontFamily
                font.pixelSize: Style.space(12)
                font.bold: true
                color: root.foreground
              }
            }

            Row {
              width: parent.width
              spacing: Style.space(8)
              Rectangle {
                width: Style.space(8)
                height: Style.space(8)
                radius: 4
                color: service && service.agentActive ? root.successColor : root.urgent
                anchors.verticalCenter: parent.verticalCenter
              }
              Text {
                text: "Agente local: " + (service && service.agentActive ? "Activo (Running)" : "Detenido")
                font.family: root.fontFamily
                font.pixelSize: Style.space(11)
                color: service && service.agentActive ? root.foreground : root.urgent
              }
            }

            Row {
              width: parent.width
              spacing: Style.space(8)
              Rectangle {
                width: Style.space(8)
                height: Style.space(8)
                radius: 4
                color: service && service.managerActive ? root.successColor : root.warningColor
                anchors.verticalCenter: parent.verticalCenter
              }
              Text {
                text: "SOC Manager: " + (service && service.managerActive ? "Conectado (:1514)" : "Desconectado")
                font.family: root.fontFamily
                font.pixelSize: Style.space(11)
                color: root.foreground
              }
            }

            Text {
              text: "Módulos: FIM • SCA • CVEs • MITRE ATT&CK"
              font.family: root.fontFamily
              font.pixelSize: Style.space(10)
              color: root.dim
            }
          }
        }

        // ---- Botón: Abrir Dashboard ----
        Rectangle {
          width: parent.width
          height: Style.space(38)
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
            Text {
              text: "󰖟"
              font.family: root.fontFamily
              font.pixelSize: Style.space(14)
              color: root.statusColor
              anchors.verticalCenter: parent.verticalCenter
            }
            Text {
              text: "Abrir SOC Dashboard (:9001)"
              font.family: root.fontFamily
              font.pixelSize: Style.space(12)
              font.bold: true
              color: root.statusColor
              anchors.verticalCenter: parent.verticalCenter
            }
          }
        }

        // ---- Botones Secundarios ----
        Row {
          width: parent.width
          spacing: Style.space(8)

          Rectangle {
            width: (parent.width - Style.space(8)) / 2
            height: Style.space(32)
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
              Text { text: ""; font.family: root.fontFamily; font.pixelSize: Style.space(11); color: root.foreground }
              Text { text: "Refrescar"; font.family: root.fontFamily; font.pixelSize: Style.space(11); color: root.foreground }
            }
          }

          Rectangle {
            width: (parent.width - Style.space(8)) / 2
            height: Style.space(32)
            radius: Style.radius(6)
            color: btnRestartArea.containsMouse ? Qt.rgba(root.urgent.r, root.urgent.g, root.urgent.b, 0.1) : "transparent"
            border.color: Qt.rgba(root.foreground.r, root.foreground.g, root.foreground.b, 0.2)
            border.width: 1

            MouseArea {
              id: btnRestartArea
              anchors.fill: parent
              hoverEnabled: true
              cursorShape: Qt.PointingHandCursor
              onClicked: {
                if (service) service.restartAgent()
              }
            }

            Row {
              anchors.centerIn: parent
              spacing: Style.space(4)
              Text { text: ""; font.family: root.fontFamily; font.pixelSize: Style.space(11); color: root.foreground }
              Text { text: "Reiniciar Agente"; font.family: root.fontFamily; font.pixelSize: Style.space(11); color: root.foreground }
            }
          }
        }
      }
    }
  }
}
