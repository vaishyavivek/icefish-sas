# This Python file uses the following encoding: utf-8
from PySide2.QtCore import QThread, Signal

import cv2
import numpy as np
from PIL import Image
import os


class FaceTrain(QThread):
    inform = Signal(int, str)

    def __init__(self, parent=None):
        QThread.__init__(self, parent)

    def run(self):
        # Path for face image database
        self.inform.emit(2, "Initializing Training Model for training...")
        self.path = 'dataset'
        self.recognizer = cv2.face.LBPHFaceRecognizer_create()
        self.detector = cv2.CascadeClassifier("haarcascade_frontalface_default.xml")

        self.inform.emit(3, "Fetching Dataset Images for training...")
        faces, ids = self.getImagesAndLabels(self.path, self.detector)

        self.inform.emit(4, "Training Started successfully and running...")
        self.recognizer.train(faces, np.array(ids))

        # Save the model into trainer/trainer.yml
        self.recognizer.write('trainer.yml')
#        self.inform.emit(len(np.unique(ids)))
        self.inform.emit(5, "Training Completed successfully.\nYou can test it now")

    # function to get the images and label data
    def getImagesAndLabels(self, path, detector):
        imagePaths = [os.path.join(path, f) for f in os.listdir(path)]
        faceSamples = []
        ids = []

        for imagePath in imagePaths:
            # convert it to grayscale
            PIL_img = Image.open(imagePath).convert('L')
            img_numpy = np.array(PIL_img, 'uint8')
            id = int(os.path.split(imagePath)[-1].split(".")[0])
            faces = detector.detectMultiScale(img_numpy)

            for (x, y, w, h) in faces:
                faceSamples.append(img_numpy[y:y+h, x:x+w])
                ids.append(id)
        return faceSamples, ids
