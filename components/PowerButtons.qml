import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

Row {
    id: powerButtons
    spacing: 20

    property int buttonSize: 50

    // Style commun pour les boutons
    component PowerButton : Rectangle {
        width: buttonSize
        height: buttonSize
        radius: width / 2
        
        // Propriétés pour les couleurs
        property string iconSource: ""
        property string buttonAction: ""
        property string tooltipText: ""
        property color hoverColor: buttonAction === "shutdown" ? "#ff0000" : 
                                buttonAction === "reboot" ? "#f59e2c" : "#6cb518"
        
        // Couleur de base avec transition douce
        color: mouseArea.containsMouse ? hoverColor : Qt.rgba(255, 255, 255, 0.2)
        
        Behavior on color {
            ColorAnimation { duration: 150 }
        }

        // Effet de lueur
        layer.enabled: true
        layer.effect: Glow {
            samples: 16
            color: "#88ffffff"
            radius: mouseArea.containsMouse ? 8 : 0
            
            Behavior on radius {
                NumberAnimation { duration: 150 }
            }
        }

        Image {
            id: icon
            source: parent.iconSource
            anchors.centerIn: parent
            width: parent.width * 0.6
            height: parent.height * 0.6
            fillMode: Image.PreserveAspectFit
            
            ColorOverlay {
                anchors.fill: parent
                source: parent
                color: "white"
            }
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            
            ToolTip.visible: containsMouse
            ToolTip.text: parent.tooltipText
            ToolTip.delay: 500

            onEntered: parent.scale = 1.1
            onExited: parent.scale = 1.0
            onClicked: {
                if (root.isProduction) {
                    switch(parent.buttonAction) {
                        case "shutdown":
                            sddm.powerOff();
                            break;
                        case "reboot":
                            sddm.reboot();
                            break;
                        case "suspend":
                            sddm.suspend();
                            break;
                    }
                } else {
                    console.log("Mode test - Simulation:", parent.buttonAction)
                }
            }
        }

        Behavior on scale {
            NumberAnimation {
                duration: 150
                easing.type: Easing.OutQuad
            }
        }
    }
    PowerButton {
        iconSource: Qt.resolvedUrl("../assets/icons/power.svg")
        buttonAction: "shutdown"
        tooltipText: "Éteindre"
    }

    PowerButton {
        iconSource: Qt.resolvedUrl("../assets/icons/restart.svg")
        buttonAction: "reboot"
        tooltipText: "Redémarrer"
    }

    PowerButton {
        iconSource: Qt.resolvedUrl("../assets/icons/suspend.svg")
        buttonAction: "suspend"
        tooltipText: "Mettre en veille"
    }
}