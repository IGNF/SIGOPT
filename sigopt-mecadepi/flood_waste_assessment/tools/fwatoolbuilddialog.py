from PyQt4 import QtCore, QtGui
from ui_fwatoolbuild import Ui_Fwatoolbuild_Dialog
# create the dialog
class fwatoolbuildDialog(QtGui.QDialog):
  def __init__(self, parent):
    QtGui.QDialog.__init__(self, parent)
    self.ui = Ui_Fwatoolbuild_Dialog()
    self.ui.setupUi(self)
