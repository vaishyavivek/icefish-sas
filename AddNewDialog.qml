import QtQuick 2.12
import QtQuick.Controls 2.12
import QtQuick.Dialogs 1.3

Dialog {
    id: addNewDialog
    title: "Add New Record"

    contentItem: Rectangle {
        implicitWidth: 400
        implicitHeight: 240

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
                spacing: 5
                Text {
                    text: qsTr("Roll no: ")
                    font.pointSize: 10
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    width: 50
                    height: 30
                }
                TextField {
                    id: stRollno
                    placeholderText: "Enter student Roll No here"
                    width: 300
                    height: 30
                }
            }

            Row {
                spacing: 5
                Text {
                    text: qsTr("Name: ")
                    font.pointSize: 10
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    width: 50
                    height: 30
                }
                TextField {
                    id: stName
                    placeholderText: "Enter student Full Name here"
                    width: 300
                    height: 30
                }
            }

            Row {
                spacing: 5
                Text {
                    text: qsTr("Class: ")
                    font.pointSize: 10
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    width: 50
                    height: 30
                }
                TextField {
                    id: stClass
                    placeholderText: "Enter student Class Details here"
                    width: 200
                    height: 30
                }
            }

            Row {
                spacing: 5
                Text {
                    text: qsTr("Section: ")
                    font.pointSize: 10
                    verticalAlignment: Text.AlignVCenter
                    horizontalAlignment: Text.AlignHCenter
                    width: 50
                    height: 30
                }
                ComboBox {
                    id: stSection
                    model: ["Select Student Section or Division", "A", "B", "C"]
                    width: 200
                    height: 30
                }
            }

            Row {
                spacing: 20
                anchors.right: parent.right

                Button {
                    text: "Take Images"
                    onClicked: {
                        dbRsl.registerStudent(stId.text, stRollno.text, stName.text, stClass.text, stSection.currentText)
                        addNewDialog.close()
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
