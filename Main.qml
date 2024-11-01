import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15
import QtQuick.Window 2.15
import "components"

Rectangle {
    id: root
    width: Screen.width
    height: Screen.height
    color: "transparent"

    property bool isProduction: true
    property bool isAnimating: false
    property real scaleFactor: Math.min(width/1920, height/1080)
    property bool isDarkMode: config.isDarkMode // Définir le thème sombre ou clair

    // Image de fond
    Image {
        id: backgroundImage
        anchors.fill: parent
        source: config.background
        fillMode: Image.PreserveAspectCrop
    }

    Switch {
        id: darkModeSwitch
        anchors.right: parent.right
        anchors.top: parent.top
        anchors.margins: 20 * scaleFactor
        checked: loginForm.isDarkMode
        z: 1000
        onCheckedChanged: {
            loginForm.isDarkMode = checked
        }
    }

    // Container principal pour le login
    Rectangle {
        id: loginContainer
        width: parent.width * 0.15
        height: parent.height * 0.15
        color: "transparent"
        anchors.horizontalCenter: parent.horizontalCenter
        anchors.bottom: parent.bottom
        anchors.bottomMargin: parent.height * 0.15

        // Rectangle de fond avec flou
        Rectangle {
            anchors.fill: parent
            color: Qt.rgba(0, 0, 0, 0.3)
            radius: 20

            layer.enabled: true
            layer.effect: FastBlur {
                radius: 30
            }
        }

        // LoginForm
        LoginForm {
            id: loginForm
            anchors.centerIn: parent
            isDarkMode: root.isDarkMode
        }

        // Cercle d'animation
        Rectangle {
            id: clickCircle
            color: "black"
            width: 0
            height: 0
            radius: width / 2
            x: 0
            y: 0
            visible: false
            z: 1000

            Behavior on width {
                NumberAnimation {
                    duration: 500
                    easing.type: Easing.OutCubic
                }
            }
            Behavior on height {
                NumberAnimation {
                    duration: 500
                    easing.type: Easing.OutCubic
                }
            }
        }

        // Message de bienvenue
        Text {
            id: welcomeText
            text: "Welcome " + loginForm.username
            color: "white"
            font.pixelSize: 32
            anchors.centerIn: parent
            opacity: 0
            visible: false
            z: 1001

            Behavior on opacity {
                NumberAnimation { duration: 300 }
            }
        }
    }

    // Boutons d'alimentation
    PowerButtons {
        anchors.right: parent.right
        anchors.bottom: parent.bottom
        anchors.margins: 20 * scaleFactor
        z: 1000
    }

    function startLoginAnimation(clickX, clickY) {
        if (isAnimating) return;
        isAnimating = true;

        // Cache le formulaire
        loginForm.opacity = 0;

        // Position et animation du cercle
        clickCircle.x = clickX - (Math.max(root.width, root.height) * 1.25);
        clickCircle.y = clickY - (Math.max(root.width, root.height) * 1.25);
        clickCircle.visible = true;
        clickCircle.width = Math.max(root.width, root.height) * 2.5;
        clickCircle.height = clickCircle.width;

        // Message de bienvenue
        welcomeText.visible = true;
        welcomeText.opacity = 1;
    }
}