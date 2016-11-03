from PyQt4 import QtCore, QtGui
from ui_fwa import Ui_Fwa_Dialog
# create the dialog
class fwaDialog(QtGui.QDialog):
  def __init__(self, parent):
    QtGui.QDialog.__init__(self, parent)
    self.ui = Ui_Fwa_Dialog()
    self.ui.setupUi(self)
