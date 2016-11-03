from PyQt4 import QtCore, QtGui
from ui_fwa3 import Ui_Fwa_Dialog3
# create the dialog
class fwaDialog3(QtGui.QDialog):
  def __init__(self, parent):
    QtGui.QDialog.__init__(self, parent)
    self.ui = Ui_Fwa_Dialog3()
    self.ui.setupUi(self)

