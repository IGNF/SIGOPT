from PyQt4 import QtCore, QtGui
from ui_fwatooltypecom import Ui_Fwatooltypecom_Dialog
# create the dialog
class fwatooltypecomDialog(QtGui.QDialog):
  def __init__(self, parent):
    QtGui.QDialog.__init__(self, parent)
    self.ui = Ui_Fwatooltypecom_Dialog()
    self.ui.setupUi(self)
