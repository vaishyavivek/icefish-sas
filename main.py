import sys
import os
from PySide2.QtWidgets import QApplication
from PySide2.QtCore import Qt, QCoreApplication, QObject, Slot, Signal, Property, QSettings
from PySide2.QtQml import QQmlApplicationEngine
from PySide2.QtSql import QSqlDatabase, QSqlQuery, QSqlQueryModel

from FaceDetect import FaceDetect
from FaceTrain import FaceTrain
from FaceTest import FaceTest
from QmlModel import SqlQueryModel
import csv

model = SqlQueryModel()

class DatabaseResolver(QObject):

    def __init__(self):
        super().__init__()
        self.ocount = 0

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
            query = QSqlQuery("SELECT COUNT(*) FROM Student JOIN "
                            "Attendance ON Student.id = Attendance.id "
                            "AND Attendance.date = (SELECT date('now')) "
                            "AND Attendance.lecture_no = 1")
            query.next()
            self.ocount = query.value(0)
            self.oCount_changed.emit()

        return self.statusCode

    # count for lecture 1 can be obtained here
    def _oCount(self):
        return self.ocount

    @Signal
    def oCount_changed(self):
        pass

    oCount = Property(int, _oCount, notify=oCount_changed)
    # ends count for lecture 1

    @Slot(int)
    def updateModel(self, lecture_no):
        updateSqlModel(lecture_no)


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

    @Slot(int)
    def startTest(self, lc):
        self.ft = FaceTest(lc)
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

    @Slot(str)
    def export(self, url):
        with open(url[7:], 'w', newline='') as handle:
            writer = csv.writer(handle)
            writer.writerow(['id', 'rollno', 'name'])
            for i in range(model.rowCount()):
                record = model.record(i)
                writer.writerow([record.value(0), record.value(1), record.value(2)])


def updateSqlModel(lecture_no):
    db = QSqlDatabase.addDatabase("QSQLITE")
    db.setDatabaseName("face.db")
    if db.open() is False:
        print("Failed opening db")

    query = "SELECT Student.id, rollno, name FROM Student JOIN "\
                "Attendance ON Student.id = Attendance.id "\
                "AND Attendance.date = (SELECT date('now')) "

    if lecture_no != 0:
        query += " AND Attendance.lecture_no = " + str(lecture_no)

    model.setQuery(query)


class PasswdManager(QObject):

    def __init__(self):
        super().__init__()
        passwd = os.open("passwd", os.O_RDONLY)
        self.passwd = os.read(passwd, 6).decode("utf-8")

    @Slot(str, result=bool)
    def checkPasswd(self, passwd):
        return self.passwd == passwd


if __name__ == '__main__':

    app = QApplication(sys.argv)

    QApplication.setAttribute(Qt.AA_EnableHighDpiScaling)
    QApplication.setStyle("material")
    QApplication.setOrganizationName("Icefish")
    QApplication.setOrganizationDomain("icefish.tech")
    QApplication.setApplicationName("Icefish SAS")
    QCoreApplication.setAttribute(Qt.AA_UseHighDpiPixmaps)

    engine = QQmlApplicationEngine()
    ctx = engine.rootContext()

    pwmng = PasswdManager()
    ctx.setContextProperty("pwd", pwmng)

    ctx.setContextProperty("cwd", os.getcwd())

    dbrsl = DatabaseResolver()
    ctx.setContextProperty("dbRsl", dbrsl)

    updateSqlModel(0)
    ctx.setContextProperty("sqlModel", model)
#    ctx.setContextProperty("oCount", oCount)

#    dbrsl.export()

    engine.load('view.qml')

    sys.exit(app.exec_())
