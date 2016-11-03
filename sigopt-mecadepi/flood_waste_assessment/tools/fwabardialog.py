from PyQt4 import QtCore, QtGui
from ui_fwabar import Ui_Fwabar_Dialog
# create the dialog
class fwabarDialog(QtGui.QDialog):
  def __init__(self, parent):
    QtGui.QDialog.__init__(self, parent)
    self.ui = Ui_Fwabar_Dialog()
    self.ui.setupUi(self)




