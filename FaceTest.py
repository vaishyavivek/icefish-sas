# This Python file uses the following encoding: utf-8
from PySide2.QtCore import QThread, Signal, QDate
from PySide2.QtSql import QSqlDatabase, QSqlQuery
import cv2, os


class FaceTest(QThread):
    inform = Signal(int, str)

    def __init__(self, lectureNo, parent=None):
        QThread.__init__(self, parent)
        # Path for face image database
        self.inform.emit(6, "Initialing training dataset for testing...")
        self.lectureNo = lectureNo

        if os.access("temp0.jpg", os.R_OK):
            os.remove("temp0.jpg")
        if os.access("temp1.jpg", os.R_OK):
            os.remove("temp1.jpg")

        self.path = 'dataset'
        self.recognizer = cv2.face.LBPHFaceRecognizer_create()
        self.recognizer.read('trainer.yml')
        self.detector = cv2.CascadeClassifier("haarcascade_frontalface_default.xml")

    def run(self):
        self.inform.emit(7, "Testing...")

        # Initialize and start realtime video capture
        cam = cv2.VideoCapture(0)
        # set video width
        cam.set(3, 640)
        # set video height
        cam.set(4, 480)

        # Define min window size to be recognized as a face
#        minW = 0.1*cam.get(3)
#        minH = 0.1*cam.get(4)
        i = 0
#        font = cv2.FONT_HERSHEY_SIMPLEX

        self.db = QSqlDatabase.addDatabase("QSQLITE")
        n = 0
        while True:
            ret, img = cam.read()
            cv2.imwrite("temp" + str(n) + ".jpg", img)
            gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
            faces = self.detector.detectMultiScale(gray, 1.4, 8)

            for(x, y, w, h) in faces:
                cv2.rectangle(img, (x, y), (x+w, y+h), (0, 255, 0), 2)
                id, confidence = self.recognizer.predict(gray[y:y+h, x:x+w])
#                print(id, confidence)

                # Check if confidence is less then 100 ==> "0" is perfect match
                if (confidence > 40):
                    self.db.setDatabaseName("face.db")
                    if not self.db.open():
                        self.inform.emit(99, "Critical Error: Database failed to open.")
                    else:
                        cDate = QDate().currentDate().toString('yyyy-MM-dd')
#                        query = QSqlQuery(self.db)
                        qstr = "SELECT * FROM Attendance WHERE id = " + str(id) + " AND date = '" + cDate + "' AND lecture_no = " + str(self.lectureNo)
                        query = QSqlQuery(qstr)
                        query.next()
                        if not query.value(0):
                            query.prepare("INSERT INTO Attendance (id, date, lecture_no)"
                                                "Values (:id, :date, :lectureNo)")
                            query.bindValue(":id", id)
                            query.bindValue(":date", str(cDate))
                            query.bindValue(":lectureNo", str(self.lectureNo))
                            query.exec_()
                            self.inform.emit(8, "Attendance marked for ID = " + str(id) + " for Lecture = " + str(self.lectureNo))
                        else:
                            self.inform.emit(8, "Attendance for ID = " + str(id) +" for Lecture = " + str(self.lectureNo) + " is already marked.")

                        i += 1
                        break
#                    self.db.close()
#                    count.append(id)


            if n == 0:
                n = 1
            else:
                n = 0
            if i > 0:
                break

        cam.release()
        cv2.destroyAllWindows()
