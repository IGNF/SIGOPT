from PyQt4 import QtCore, QtGui
from ui_fwatoolbuild2 import Ui_Fwatoolbuild_Dialog2
# create the dialog
class fwatoolbuildDialog2(QtGui.QDialog):
  def __init__(self, parent):
    QtGui.QDialog.__init__(self, parent)
    self.ui = Ui_Fwatoolbuild_Dialog2()
    self.ui.setupUi(self)
