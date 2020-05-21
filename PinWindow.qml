import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Window 2.14

ApplicationWindow {
    id: pinDialogue
    title: "Enter Pin"
    visible: true
    width: 210
    height: 340
    x: Screen.width / 2 - width / 2
    y: Screen.height / 2 - height / 2

    Loader {
        id: mainLoader
    }

    AskPinFrame {
        id: askPinFrame
        onAccepted: {
            if (pwd.checkPasswd(pinText) === true) {
                pinDialogue.visible = false
                mainLoader.source = "view.qml"
                pinDialogue.destroy()
            }
            else
                wrongPw()
        }
    }

    Component.onCompleted: {
        setX(Screen.width / 2 - width / 2);
        setY(Screen.height / 2 - height / 2);
    }
}
