import sys
import os
from PySide2.QtWidgets import QApplication
from PySide2.QtCore import Qt, QCoreApplication, QObject, Slot, Signal
from PySide2.QtQml import QQmlApplicationEngine
from PySide2.QtSql import QSqlDatabase, QSqlQuery, QSqlQueryModel

from FaceDetect import FaceDetect
from FaceTrain import FaceTrain
from FaceTest import FaceTest
from QmlModel import SqlQueryModel
import csv

class DatabaseResolver(QObject):

    def __init__(self):
        super().__init__()

    # this signal is emitted to inform QML of changes received from Thread
    threadSignalReceived = Signal()

    # this slot parameters are received from Thread
    @Slot(int, str)
    def getThreadSignal(self, code, msg):
        self.statusCode = code
        self.statusMessage = msg
        self.threadSignalReceived.emit()

    # to modify qml conditions
    @Slot(result=int)
    def getStatusCode(self):
        if self.statusCode == 8:
            updateSqlModel()
        return self.statusCode

    # to display in status bar
    @Slot(result=str)
    def getStatusMessage(self):
        return self.statusMessage

    # this will be called from qml while adding a new student record
    @Slot(str, str, str, str, str, result=None)
    def registerStudent(self, id, rollno, name, stclass, section):

        self.db = QSqlDatabase.addDatabase("QSQLITE")
        self.db.setDatabaseName("face.db")
        if self.db.open() is False:
            print("Failed opening db")

        query = QSqlQuery(self.db)
        query.prepare("Insert Into Student (id, rollno, name, class, section)"
                      "Values (:id, :rollno, :name, :class, :section)")
        query.bindValue(":id", id)
        query.bindValue(":rollno", rollno)
        query.bindValue(":name", name)
        query.bindValue(":class", stclass)
        query.bindValue(":section", section)
        query.exec_()

        # take photos for training
        self.startCapture(id)
        self.db.close()

    # after registering in database, take the photos now
    def startCapture(self, id):
        self.fd = FaceDetect(id=id, sample=200)
        self.fd.inform.connect(self.getThreadSignal)
        self.fd.start()

    @Slot()
    def startTraining(self):
        self.ft = FaceTrain()
        self.ft.inform.connect(self.getThreadSignal)
        self.ft.start()

    @Slot()
    def startTest(self):
        self.ft = FaceTest()
        self.ft.inform.connect(self.getThreadSignal)
        self.ft.start()

    @Slot(QSqlQueryModel)
    def getResult(self, result):
        print(result)

    @Slot(str)
    def deregisterStudent(self, id):
        self.db = QSqlDatabase.addDatabase("QSQLITE")
        self.db.setDatabaseName("face.db")
        if self.db.open() is False:
            print("Failed opening db")
        query = QSqlQuery(self.db)
        query.prepare("DELETE FROM Student WHERE id = :id")
        query.bindValue(":id", int(id))
        query.exec_()

        path = 'dataset'
        imagePaths = [os.path.join(path, f) for f in os.listdir(path)]
        [os.remove(x) for x in imagePaths if ('/' + str(id) + ".") in x]
        self.getThreadSignal(9, "Requested Record removed completely. Kindly retrain.")

    @Slot()
    def export(self):
        with open('export.csv', 'w', newline='') as handle:
            writer = csv.writer(handle)
            writer.writerow(['id', 'rollno', 'name'])
            for i in range(model.rowCount()):
                record = model.record(i)
                writer.writerow([record.value(0), record.value(1), record.value(2)])


model = SqlQueryModel()

def updateSqlModel():
    db = QSqlDatabase.addDatabase("QSQLITE")
    db.setDatabaseName("face.db")
    if db.open() is False:
        print("Failed opening db")
    model.setQuery("SELECT Student.id, rollno, name FROM Student "
                "JOIN "
                "Attendance ON Student.id = Attendance.id "
                "AND Attendance.date = (SELECT date('now'))")


if __name__ == '__main__':

    app = QApplication(sys.argv)

    QApplication.setAttribute(Qt.AA_EnableHighDpiScaling)
    QCoreApplication.setAttribute(Qt.AA_UseHighDpiPixmaps)

    engine = QQmlApplicationEngine()
    ctx = engine.rootContext()

    ctx.setContextProperty("cwd", os.getcwd())

    dbrsl = DatabaseResolver()
    ctx.setContextProperty("dbRsl", dbrsl)

    updateSqlModel()
    ctx.setContextProperty("sqlModel", model)
#    dbrsl.export()

    engine.load('view.qml')

    sys.exit(app.exec_())
