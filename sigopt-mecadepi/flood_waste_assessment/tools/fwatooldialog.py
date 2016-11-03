from PyQt4 import QtCore, QtGui
from ui_fwatool import Ui_Fwatool_Dialog
# create the dialog
class fwatoolDialog(QtGui.QDialog):
  def __init__(self, parent):
    QtGui.QDialog.__init__(self, parent)
    self.ui = Ui_Fwatool_Dialog()
    self.ui.setupUi(self)

