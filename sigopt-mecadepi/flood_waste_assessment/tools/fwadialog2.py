from PyQt4 import QtCore, QtGui
from ui_fwa2 import Ui_Fwa_Dialog2
# create the dialog
class fwaDialog2(QtGui.QDialog):
  def __init__(self, parent):
    QtGui.QDialog.__init__(self, parent)
    self.ui = Ui_Fwa_Dialog2()
    self.ui.setupUi(self)

