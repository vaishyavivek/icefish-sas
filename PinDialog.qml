import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Dialogs 1.3

Dialog {
    id: pinDialog
    width: 210
    height: 340

    contentItem: AskPinFrame {
        id: askPinFrame
        onAccepted: {
            if (pwd.checkPasswd(pinText) === true) {
                lock = false
                lectureCount.value += 1
                pinDialog.visible = false
            }
            else
                wrongPw()
        }
    }
}
