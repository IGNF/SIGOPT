# -*- coding: utf-8 -*-

from PyQt4 import QtCore, QtGui

class Ui_Fwatoolbuild_Dialog2(object):
    def setupUi(self, Dialog):
        Dialog.setObjectName("Dialog")
        Dialog.resize(450, 400)
        font = QtGui.QFont()
        font.setWeight(75)
        font.setBold(True)
        Dialog.setFont(font)
        self.buttonBox = QtGui.QDialogButtonBox(Dialog)
        self.buttonBox.setGeometry(QtCore.QRect(30, 350, 341, 32))
        self.buttonBox.setOrientation(QtCore.Qt.Horizontal)
        self.buttonBox.setStandardButtons(QtGui.QDialogButtonBox.Cancel|QtGui.QDialogButtonBox.Ok)
        self.buttonBox.setObjectName("buttonBox")
        self.comboBox = QtGui.QComboBox(Dialog)
        self.comboBox.setGeometry(QtCore.QRect(250, 40, 151, 22))
        font = QtGui.QFont()
        font.setFamily("Calibri")
        self.comboBox.setFont(font)
        self.comboBox.setObjectName("comboBox")
        self.label = QtGui.QLabel(Dialog)
        self.label.setGeometry(QtCore.QRect(50, 40, 171, 20))
        font = QtGui.QFont()
        font.setFamily("Calibri")
        font.setPointSize(12)
        self.label.setFont(font)
        self.label.setObjectName("label")
        self.comboBox2 = QtGui.QComboBox(Dialog)
        self.comboBox2.setGeometry(QtCore.QRect(250, 90, 151, 22))
        self.comboBox2.setFont(font)
        self.comboBox2.setObjectName("comboBox2")
        self.label2 = QtGui.QLabel(Dialog)
        self.label2.setGeometry(QtCore.QRect(50, 90, 171, 20))
        self.label2.setFont(font)
        self.label2.setObjectName("label2")
        self.comboBox3 = QtGui.QComboBox(Dialog)
        self.comboBox3.setGeometry(QtCore.QRect(250, 140, 151, 22))
        self.comboBox3.setFont(font)
        self.comboBox3.setObjectName("comboBox3")
        self.label3 = QtGui.QLabel(Dialog)
        self.label3.setGeometry(QtCore.QRect(50, 140, 171, 20))
        self.label3.setFont(font)
        self.label3.setObjectName("label3")
        self.comboBox4 = QtGui.QComboBox(Dialog)
        self.comboBox4.setGeometry(QtCore.QRect(250, 190, 151, 22))
        self.comboBox4.setFont(font)
        self.comboBox4.setObjectName("comboBox4")
        self.label4 = QtGui.QLabel(Dialog)
        self.label4.setGeometry(QtCore.QRect(50, 190, 171, 20))
        self.label4.setFont(font)
        self.label4.setObjectName("label4")
        self.comboBox5 = QtGui.QComboBox(Dialog)
        self.comboBox5.setGeometry(QtCore.QRect(250, 240, 151, 22))
        self.comboBox5.setFont(font)
        self.comboBox5.setObjectName("comboBox5")
        self.label5 = QtGui.QLabel(Dialog)
        self.label5.setGeometry(QtCore.QRect(50, 240, 171, 20))
        self.label5.setFont(font)
        self.label5.setObjectName("label5")
        self.comboBox6 = QtGui.QComboBox(Dialog)
        self.comboBox6.setGeometry(QtCore.QRect(250, 290, 151, 22))
        self.comboBox6.setFont(font)
        self.comboBox6.setObjectName("comboBox6")
        self.label6 = QtGui.QLabel(Dialog)
        self.label6.setGeometry(QtCore.QRect(50, 290, 171, 20))
        self.label6.setFont(font)
        self.label6.setObjectName("label6")

        self.retranslateUi(Dialog)
        QtCore.QObject.connect(self.buttonBox, QtCore.SIGNAL("accepted()"), Dialog.accept)
        QtCore.QObject.connect(self.buttonBox, QtCore.SIGNAL("rejected()"), Dialog.reject)
        QtCore.QMetaObject.connectSlotsByName(Dialog)

    def retranslateUi(self, Dialog):
        Dialog.setWindowTitle(QtGui.QApplication.translate("Dialog", "Dialog", None, QtGui.QApplication.UnicodeUTF8))
        self.label.setText(QtGui.QApplication.translate("Dialog", "Champ identifiant BATI", None, QtGui.QApplication.UnicodeUTF8))
        self.label2.setText(QtGui.QApplication.translate("Dialog", "Champ hauteur BATI", None, QtGui.QApplication.UnicodeUTF8))
        self.label3.setText(QtGui.QApplication.translate("Dialog", "Champ identifiant IRIS", None, QtGui.QApplication.UnicodeUTF8))
        self.label4.setText(QtGui.QApplication.translate("Dialog", "Champ Iris LOGEMENT ", None, QtGui.QApplication.UnicodeUTF8))
        self.label5.setText(QtGui.QApplication.translate("Dialog", "Champ nbr appartement LOGEMENT ", None, QtGui.QApplication.UnicodeUTF8))
        self.label6.setText(QtGui.QApplication.translate("Dialog", "Champ nbr maison LOGEMENT ", None, QtGui.QApplication.UnicodeUTF8))

