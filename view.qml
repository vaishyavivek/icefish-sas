import QtQuick 2.14
import QtQuick.Controls 2.14
import QtQuick.Window 2.14
import QtQuick.Controls.Material 2.12

ApplicationWindow {
    title: "Icefish Smart Attendance System"
    width: 1024
    height: 600
    visible: true
    Material.theme: Material.Light
    Material.accent: Material.Purple

    AddNewDialog{ id: addNewDialogue}
    DeleteExistingDialog{ id: deleteExistingDialogue}

    PinDialog { id: pinDialog}
    property bool lock: false

    menuBar: MenuBar {
        Menu {
            title: qsTr("&User")

            Action {
                text: qsTr("&Test")
                shortcut: StandardKey.Redo
                onTriggered: dbRsl.startTest()
            }

            Action {
                text: "Exit"
                shortcut: StandardKey.Quit
                onTriggered: Qt.quit()
            }
        }

        Menu {
            title: qsTr("&Administrator")
            Action {
                text: "Add New"
                shortcut: StandardKey.New
                onTriggered: addNewDialogue.open()
            }

            Action {
                text: "Delete Existing"
                shortcut: StandardKey.Delete
                onTriggered: deleteExistingDialogue.open()
            }

            Action {
                text: "Modify Existing"
                shortcut: StandardKey.Replace
            }

            Action {
                text: "Train"
                shortcut: StandardKey.Print
                onTriggered: dbRsl.startTraining()
            }
        }

        Menu {
            title: qsTr("&Help")
            Action { text: "Licenses" }
            Action { text: "About" }
        }
    }


    Row{
        anchors.fill: parent
        anchors.margins: 20
        spacing: 25

        Column{
            id: sidebar
            width: parent.width*0.1
            height: parent.height
            spacing: 10
            anchors.topMargin: 50
            anchors.margins: 10

            Rectangle {
                width: parent.width
                height: width*0.5
                color: "transparent"

                Timer{
                    interval: 1000
                    running: true
                    repeat: true
                    onTriggered: {
                        var d = new Date();
                        time.text = d.getHours().toString() + " : " + d.getMinutes().toString() + " : " + d.getSeconds().toString()
                    }
                }

                Text {
                    id: time
                    horizontalAlignment: Text.AlignHCenter
                    verticalAlignment: Text.AlignVCenter
                    anchors.fill: parent
                    font.pixelSize: 24
                }
            }

            Button{
                id: startBtn
                width: parent.width
                height: width*0.75
//                flat: true
                focus: true
                display: AbstractButton.TextUnderIcon
                icon.name: "media-record"
                icon.color: "red"
                text: "Start"
                onClicked: dbRsl.startTest(lectureCount.value)
            }

            SpinBox{
                id: lectureCount
                width: parent.width
                height: width*0.5
                from: 1
                to: 10
            }

            Button{
                id: lockBtn
                width: parent.width
                height: width*0.75
//                flat: true
                display: AbstractButton.TextUnderIcon
                icon.name: "lock"
                icon.color: "red"
                text: lock ? "UnLock" : "Lock"
                onClicked: {
                    if(lock)
                        pinDialog.open()
                    else
                        lock = true
                }
            }

            Button{
                id: mailBtn
                width: parent.width
                height: width*0.75
//                flat: true
                icon.name: "mail-send"
                icon.color: "blue"
                display: AbstractButton.TextUnderIcon
                text: "Send Mail"
                onClicked: dbRsl.export()
            }

            Button{
                id: exitBtn
                width: parent.width
                height: width*0.75
//                flat: true
                icon.name: "system-shutdown"
                display: AbstractButton.TextUnderIcon
                text: "Exit and \nShutdown"
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
                    radius: 5
                }

                SequentialAnimation {
                    id: videoAnimated
                    loops: Animation.Infinite
                    PropertyAnimation {
                        target: image
                        property: "source"
                        to: "file:///" + cwd + "/temp0.jpg"
                        duration: 200 //ms
                    }

                    PropertyAnimation {
                        target: image
                        property: "source"
                        to: "file:///" + cwd + "/temp1.jpg"
                        duration: 200
                    }
                }

                Connections{
                    target: dbRsl
                    onThreadSignalReceived: {
                        status.text = status.text + "\n-> " + dbRsl.getStatusMessage()
                        var code = dbRsl.getStatusCode()

                        if(code === 0 || code === 7){
                            videoAnimated.running = true
                            progress.opacity = 1
                        }
                        else if(code === 1 || code === 8){
                            videoAnimated.running = false
                            progress.opacity = 0
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

            ProgressBar {
                id: progress
                opacity: 0
                width: parent.width
                indeterminate: true
            }

            Rectangle{
                id: statusParentRect
                width: parent.width
                height: parent.height*0.4 - 20
                color: "transparent"
                clip: true

                ScrollView{
                    width: parent.width
//                    height: parent.height
                    clip: true
                    TextArea{
                        id: status
                        width: statusParentRect.width
                        padding: 20
                        text: qsTr("<p>Welcome to <b>Icefish SAS</b></p><p>Click on Start to begin attendance tracking.</p>")
                        textFormat: TextEdit.RichText
                        font.family: "Arial Black"
                        font.pointSize: 8
                        readOnly: true
                        background: Rectangle{
                            color: "transparent"
                            border.color: "gray"
                            border.width: 2
                            radius: 5
                        }
                    }
                }
            }
        }

        Column {
            id: indicatorBar
            width: parent.width*0.5 - 40
            height: parent.height
            spacing: 20

            Rectangle {
                width: parent.width
                height: width*0.2
                color: "transparent"

                Row {
                    anchors.fill: parent
                    spacing: 25

                    Rectangle {
                        id: ostRect
                        height: parent.height
                        width: height*1.2
                        color: "transparent"
                        border.color: "gray"
                        border.width: 2
                        radius: 5

                        Column {
                            anchors.fill: parent
                            anchors.margins: 5
                            spacing: 10
                            Text {
                                padding: 5
                                anchors.horizontalCenter: parent.horizontalCenter
                                font.pixelSize: 16
                                text: qsTr("Initial Count")
                            }
                            Text {
                                padding: 5
                                anchors.horizontalCenter: parent.horizontalCenter
                                font.pixelSize: 40
                                font.bold: true
                                text: dbRsl.oCount
                            }
                        }
                    }

                    Rectangle {
                        id: istRect
                        height: parent.height
                        width: height*1.2
                        color: "transparent"
                        border.color: "gray"
                        border.width: 2
                        radius: 5

                        Column {
                            anchors.fill: parent
                            anchors.margins: 5
                            spacing: 10
                            Text {
                                padding: 5
                                anchors.horizontalCenter: parent.horizontalCenter
                                font.pixelSize: 16
                                text: qsTr("Current Count")
                            }
                            Text {
                                padding: 5
                                anchors.horizontalCenter: parent.horizontalCenter
                                font.pixelSize: 40
                                font.bold: true
                                text: sqlTableView.rowCount
                            }
                        }
                    }

                    Rectangle {
                        width: parent.width - ostRect.width - istRect.width - 50
                        height: parent.height
                        color: "transparent"
                        border.color: "gray"
                        border.width: 2
                        radius: 5

                        Column {
                            anchors.fill: parent
                            anchors.margins: 10
                            spacing: 10

                            Text {
                                padding: 5
                                anchors.horizontalCenter: parent.horizontalCenter
                                font.pixelSize: 16
                                text: qsTr("Student Count for lecture")
                            }

                            ComboBox {
                                width: parent.width*0.8
                                anchors.horizontalCenter: parent.horizontalCenter
                                model: [1, 2, 3, 4, 5, 6, 7, 8, 9]
                                currentIndex: lectureCount.value - 1
                                onCurrentIndexChanged: dbRsl.updateModel(currentIndex + 1)
                            }
                        }
                    }
                }
            }

            SqlTableView{
                id: sqlTableView
            }
        }
    }

    Component.onCompleted: {
        setX(Screen.width / 2 - width / 2);
        setY(Screen.height / 2 - height / 2);
    }
}
