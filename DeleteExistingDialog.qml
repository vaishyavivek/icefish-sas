import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.3

Dialog {
    id: deleteExistingDialogue
    title: "Delete Existing Record"

    contentItem: Rectangle {
        implicitWidth: 400
        implicitHeight: 80

        Column {
            anchors.fill: parent
            anchors.margins: 10
            spacing: 10

            Row {
                spacing: 5
                Text {
                    text: qsTr("Id: ")
                    font.pointSize: 10
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    width: 50
                    height: 30
                }
                TextField {
                    id: stId
                    placeholderText: "Enter student Unique School Id here"
                    width: 300
                    height: 30
                }
            }

            Row {
                spacing: 20
                anchors.right: parent.right

                Button {
                    text: "Remove"
                    onClicked: {
                        dbRsl.deregisterStudent(stId.text)
                        deleteExistingDialogue.close()
                    }
                }

                Button {
                    text: "Cancel"
                    onClicked: addNewDialog.close()
                }
            }
        }
    }
}
