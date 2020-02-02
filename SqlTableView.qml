import QtQuick 2.5
import QtQuick.Controls 1.4

TableView {
   id: tblView
   width: parent.width
   height: parent.height - 70
   model: sqlModel

   Component{
       id: columnComponent
       TableViewColumn{
           width: 50
       }
   }

   Component.onCompleted: {
       var roles = model.roleNameArray()
       for (var i=0; i<roles.length; i++) {
           var column = addColumn( Qt.createQmlObject(
                                      "import QtQuick.Controls 1.1; TableViewColumn {}",
                                      this) )
           column.role = roles[i]
           column.title = roles[i]
       }
   }
}
