from PySide2.QtCore import QThread, Signal
import cv2, os


class FaceDetect(QThread):
    inform = Signal(int, str)

    def __init__(self, id, sample, parent=None):
        QThread.__init__(self, parent)
        self.id = id
        self.sample = sample

    def run(self):
        self.inform.emit(0, "Getting training dataset... |"
                        " Look at the camera for few seconds and say <b>CHEESE<b/>!")
        cam = cv2.VideoCapture(2)
        cam.set(3, 640)  # set video width
        cam.set(4, 480)  # set video height

        face_detector = cv2.CascadeClassifier('haarcascade_frontalface_default.xml')

        os.remove("temp0.jpg")
        os.remove("temp1.jpg")

        count = 0
        n = 0

        while(True):
            ret, img = cam.read()
            cv2.imwrite("temp" + str(n) + ".jpg", img)
            # img = cv2.flip(img, -1) # flip video image vertically
            gray = cv2.cvtColor(img, cv2.COLOR_BGR2GRAY)
            faces = face_detector.detectMultiScale(gray, 1.4, 8)

            for (x, y, w, h) in faces:
                cv2.rectangle(img, (x, y), (x+w, y+h), (255, 0, 0), 2)
                count += 1

                # Save the captured image into the datasets folder
                cv2.imwrite("dataset/" + str(self.id) + '.' + str(count) + ".jpg", gray[y:y+h,x:x+w])
                count += 1

            if n == 0:
                n = 1
            else:
                n = 0
            # Take 'sample' number of face sample and stop video
            if count >= self.sample:
                break
        self.inform.emit(1, "Training dataset captured. Thank you.")
