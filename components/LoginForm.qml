import QtQuick 2.15
import QtQuick.Controls 2.15
import QtGraphicalEffects 1.15

Column {
    id: loginForm
    spacing: 20
    width: parent.width * 0.8
    opacity: 1

    property string username: usernameField.text
    property bool showError: false
    property bool isDarkMode: false

    // Propriétés de couleurs basées sur le thème
    property color inputBackgroundColor: isDarkMode ? "#1f1f1f" : "#dedede"
    property color inputTextColor: isDarkMode ? "#dedede" : "#1f1f1f"
    property color placeholderTextColor: isDarkMode ? "#AAAAAA" : "#666666"
    property color buttonColor: isDarkMode ? "#bb86fc" : "#2196f3"
    property color buttonHoverColor: isDarkMode ? "#3700b3" : "#1e88e5"
    property color buttonPressedColor: isDarkMode ? "#6200ea" : "#1a73e8"

    Behavior on opacity {
        NumberAnimation { duration: 250; easing.type: Easing.InOutQuad }
    }

    Component.onCompleted: {
        if (userModel.lastUser) {
            usernameField.text = userModel.lastUser
            passwordField.forceActiveFocus()
        }
    }

    // Style commun pour les champs de texte
    // Style commun pour les champs de texte
    component CustomTextField : TextField {
        height: 40
        width: parent.width
        color: inputTextColor
        font.pixelSize: 16
        
        property string placeholderTextCustom: ""  // Nouvelle propriété

        // Placeholder text personnalisé
        Text {
            text: parent.placeholderTextCustom
            color: placeholderTextColor
            visible: !parent.text && !parent.activeFocus
            font: parent.font
            padding: parent.padding
            leftPadding: parent.leftPadding
            verticalAlignment: parent.verticalAlignment
        }
        
        background: Rectangle {
            color: inputBackgroundColor
            radius: 8
        }
        leftPadding: 15
        selectByMouse: true
        selectionColor: Qt.rgba(0, 0, 0, 0.2)
    }

    CustomTextField {
        id: usernameField
        placeholderTextCustom: "Nom d'utilisateur"  // Utilise la nouvelle propriété
        onAccepted: passwordField.forceActiveFocus()
        onTextChanged: showError = false
    }

    CustomTextField {
        id: passwordField
        placeholderTextCustom: "Mot de passe"  // Utilise la nouvelle propriété
        echoMode: TextInput.Password
        onAccepted: loginForm.tryLogin()
        onTextChanged: showError = false

        Keys.onPressed: function(event) {
            if (event.key === Qt.Key_Return || event.key === Qt.Key_Enter) {
                event.accepted = true
                loginForm.tryLogin()
            }
        }
    }
    
    // Message d'erreur
    Text {
        id: errorText
        width: parent.width
        height: showError ? implicitHeight : 0
        text: "Identifiants incorrects"
        color: "#ff3333"
        font.pixelSize: 13
        horizontalAlignment: Text.AlignHCenter
        opacity: showError ? 1 : 0
        visible: opacity > 0
        
        Behavior on opacity {
            NumberAnimation { duration: 200 }
        }
    }
    
    Button {
        id: loginButton
        text: "Se connecter"
        width: parent.width
        height: 40
        enabled: !root.isAnimating
        
        background: Rectangle {
            color: parent.pressed ? buttonPressedColor : (mouseArea.containsMouse ? buttonHoverColor : buttonColor)
            radius: 8

            layer.enabled: true
            layer.effect: Glow {
                samples: 16
                color: "#88ffffff"
                radius: mouseArea.containsMouse ? 8 : 0
                
                Behavior on radius {
                    NumberAnimation { duration: 150 }
                }
            }
        }

        contentItem: Text {
            text: loginButton.text
            color: "white"
            font.pixelSize: 16
            font.bold: true
            horizontalAlignment: Text.AlignHCenter
            verticalAlignment: Text.AlignVCenter
        }

        MouseArea {
            id: mouseArea
            anchors.fill: parent
            hoverEnabled: true
            onClicked: loginForm.tryLogin()
        }
    }

    Timer {
        id: loginDelayTimer
        interval: 2000 // 2 secondes
        repeat: false
        onTriggered: {
            if (!root.isProduction) {
                // Simuler une connexion réussie en mode test
                return
            }

            // Vérifier les identifiants après le délai
            var success = sddm.login(usernameField.text, passwordField.text, sessionModel.lastIndex)
            if (!success) {
                // Afficher le message d'erreur et restaurer le formulaire
                showError = true
                loginForm.opacity = 1
                passwordField.text = ""
                passwordField.forceActiveFocus()
                root.isAnimating = false
            }
        }
    }

    function tryLogin() {
        if (root.isAnimating) return

        // Lancer l'animation de connexion
        showError = false
        loginForm.opacity = 0
        var clickPos = loginButton.mapToItem(loginContainer, width/2, height/2)
        root.startLoginAnimation(clickPos.x, clickPos.y)

        // Démarrer le Timer pour vérifier les identifiants après 2 secondes
        loginDelayTimer.start()
    }
}