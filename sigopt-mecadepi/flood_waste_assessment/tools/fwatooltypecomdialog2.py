from PyQt4 import QtCore, QtGui
from ui_fwatooltypecom2 import Ui_Fwatooltypecom_Dialog2
# create the dialog
class fwatooltypecomDialog2(QtGui.QDialog):
  def __init__(self, parent):
    QtGui.QDialog.__init__(self, parent)
    self.ui = Ui_Fwatooltypecom_Dialog2()
    self.ui.setupUi(self)
