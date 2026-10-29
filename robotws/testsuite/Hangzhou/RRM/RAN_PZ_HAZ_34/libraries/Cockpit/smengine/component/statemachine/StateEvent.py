from PyQt4 import QtCore


class StateEvent(QtCore.QEvent):
    # static parameters

    # methods
    def __init__(self, pType):
        QtCore.QEvent.__init__(self, pType)
