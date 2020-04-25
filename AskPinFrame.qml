import QtQuick 2.14
import QtQuick.Controls 2.14

Rectangle {
    id: askPinFrame
    anchors.fill: parent
    color: "transparent"

    signal accepted()
    signal wrongPw()
    property string pinText

    Column {
        anchors.fill: parent
        spacing: 20
        anchors.margins: 20

        Text {
            id: pin
            width: parent.width
            height: 50
            padding: 10
            font.pixelSize: 30
            verticalAlignment: Text.AlignVCenter
            horizontalAlignment: Text.AlignHCenter

            Button {
                anchors.right: parent.right
                anchors.verticalCenter: parent.verticalCenter
                width: 25
                height: parent.height
                text: "←"
                flat: true
                onClicked: pin.text = pin.text.split('', pin.text.length - 1).join('')
            }

            Rectangle {
                id: statusIndicator
                color: "gray"
                height: 2
                radius: 2
                width: parent.width - 50
                anchors.horizontalCenter: parent.horizontalCenter
                anchors.bottom: parent.bottom
            }

            onTextChanged: {
                if(text !== "")
                    statusIndicator.color = "gray"
                pinText = text
            }
        }

        Grid {
            columns: 3
            rows: 4
            spacing: 10

            RoundButton {
                width: 50
                height: width
                text: "1"
                onClicked: pin.text += "1"
            }
            RoundButton {
                width: 50
                height: width
                text: "2"
                onClicked: pin.text += "2"
            }
            RoundButton {
                width: 50
                height: width
                text: "3"
                onClicked: pin.text += "3"
            }
            RoundButton {
                width: 50
                height: width
                text: "4"
                onClicked: pin.text += "4"
            }
            RoundButton {
                width: 50
                height: width
                text: "5"
                onClicked: pin.text += "5"
            }
            RoundButton {
                width: 50
                height: width
                text: "6"
                onClicked: pin.text += "6"
            }
            RoundButton {
                width: 50
                height: width
                text: "7"
                onClicked: pin.text += "7"
            }
            RoundButton {
                width: 50
                height: width
                text: "8"
                onClicked: pin.text += "8"
            }
            RoundButton {
                width: 50
                height: width
                text: "9"
                onClicked: pin.text += "9"
            }
            RoundButton {
                width: 50
                height: width
                text: "🗸"
                onClicked: askPinFrame.accepted()
            }
            RoundButton {
                width: 50
                height: width
                text: "0"
                onClicked: pin.text += "0"
            }
            RoundButton {
                width: 50
                height: width
                text: "⤬"
            }
        }
    }

    onWrongPw: {
        pin.text = ""
        statusIndicator.color = "red"
    }
}
