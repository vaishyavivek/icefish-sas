import QtQuick 2.2
import QtQuick.Dialogs 1.0

FileDialog {
    id: fileDialog
    title: "Please choose a file"
    folder: shortcuts.home
    selectExisting: false
    nameFilters: ["CSV Files (*.csv)"]

    onAccepted: {
        dbRsl.export(fileDialog.fileUrls)
    }

    onRejected: {
        fileDialog.close()
    }
}
