import QtQuick.Controls 2.4 as Quick2
import QtQuick.Controls 1.4
import QtQuick 2.12

ApplicationWindow {
    title: "Sankalp Face Detection"
    visible: true
    width: 640
    height: 480

    AddNewDialogue{ id: addNewDialogue}
    DeleteExistingDialogue{ id: deleteExistingDialogue}

    menuBar: MenuBar {
        Menu {
            title: "User"

            MenuItem {
                text: "Test"
                shortcut: StandardKey.Redo
                onTriggered: dbRsl.startTest()
            }

            MenuItem {
                text: "Exit"
                shortcut: StandardKey.Quit
                onTriggered: Qt.quit()
            }
        }

        Menu {
            title: "Administrator"
            MenuItem {
                text: "Add New"
                shortcut: StandardKey.New
                onTriggered: addNewDialogue.open()
            }

            MenuItem {
                text: "Delete Existing"
                shortcut: StandardKey.Delete
                onTriggered: deleteExistingDialogue.open()
            }

            MenuItem {
                text: "Modify Existing"
                shortcut: StandardKey.Replace
            }

            MenuItem {
                text: "Train"
                shortcut: StandardKey.Print
                onTriggered: dbRsl.startTraining()
            }
        }

        Menu {
            title: "Help"
            MenuItem { text: "Licenses" }
            MenuItem { text: "About" }
        }
    }

    Row{
        anchors.fill: parent
        anchors.margins: 20
        spacing: 20

        Column{
            id: sidebar
            width: parent.width*0.1
            height: parent.height
            spacing: 10
            anchors.topMargin: 50
            anchors.margins: 10

            Quick2.Button{
                id: testBtn
                width: parent.width
                height: width*0.75
                flat: true
                focus: true
                icon.name: "media-record"
                text: "Test"
                onClicked: dbRsl.startTest()
            }

            Quick2.Button{
                id: mailBtn
                width: parent.width
                height: width*0.75
                flat: true
                focus: true
                icon.name: "mail-send"
                text: "Send Mail"
            }

            Quick2.Button{
                id: exitBtn
                width: parent.width
                height: width*0.75
                flat: true
                focus: true
                icon.name: "system-shutdown"
                text: "Exit and Shutdown"
                onClicked: Qt.quit()
            }
        }

        Column{
            width: parent.width*0.4
            height: parent.height
            spacing: 10

            Image {
                id: image
                width: parent.width
                height: parent.height*0.6 - 10
                asynchronous: true
                cache: false

                Rectangle {
                    id: borderRect
                    color: "transparent"
                    border.width: 2
                    border.color: "grey"
                    anchors.fill: parent
                    radius: 2
                }

                SequentialAnimation {
                    id: videoAnimated
                    loops: Animation.Infinite
                    PropertyAnimation {
                        target: image
                        property: "source"
                        to: "file:///" + cwd + "/temp0.jpg"
                        duration: 10 //ms
                    }

                    PropertyAnimation {
                        target: image
                        property: "source"
                        to: "file:///" + cwd + "/temp1.jpg"
                        duration: 10
                    }
                }

                Connections{
                    target: dbRsl
                    onThreadSignalReceived: {
                        status.text = status.text + "\n-> " + dbRsl.getStatusMessage()
                        var code = dbRsl.getStatusCode()

                        if(code === 0 || code === 7){
                            videoAnimated.running = true
                        }
                        else if(code === 1 || code === 8){
                            videoAnimated.running = false
                            image.source = ""
                        }
                        else if(code === 2){
                            progress.visible = true
                        }
                        else if(code === 5){
                            progress.visible = false
                        }
                    }
                }
            }


            Quick2.TextArea{
                id: status
                width: parent.width
                height: parent.height*0.4 - 20
                padding: 20
                text: qsTr("Welcome to Sankalp SAS")
                font.family: "Arial Black"
                font.pointSize: 10
                readOnly: true
                color: "white"
            }

            Quick2.ProgressBar {
                id: progress
                visible: false
                width: parent.width
                indeterminate: true
            }
        }

        Column {
            id: indicatorBar
            width: parent.width*0.5 - 40
            height: parent.height
            spacing: 10

            Quick2.TextArea {
                id: stCount
                width: parent.width
                height: 50
                font.pixelSize: 24
                verticalAlignment: Text.AlignVCenter
                text: "Student Count: " + sqlTableView.rowCount
            }

            SqlTableView{
                id: sqlTableView
            }
        }
    }
}
