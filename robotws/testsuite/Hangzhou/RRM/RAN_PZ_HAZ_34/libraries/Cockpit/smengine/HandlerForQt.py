from PyQt4 import QtCore


class HandlerForQt(QtCore.QObject):
    # This class allows the sm_engine APIs, which need Qt objects creation,
    # to run functions in Qt event loop thread,
    # by emitting Qt signals when its methods are called by the APIs

    # Signals
    signalAddStateMachine = QtCore.pyqtSignal(str)
    signalProcessEvents = QtCore.pyqtSignal()
    signalQuit = QtCore.pyqtSignal()

    # Methods
    def __init__(self, parent=None):
        super(HandlerForQt, self).__init__(parent)

    def loadStateMachine(self, pSmFile):
        self.signalAddStateMachine.emit(pSmFile)
        return True

    def processEvents(self):
        self.signalProcessEvents.emit()
        return True

    def exit(self):
        self.signalQuit.emit()
        return True
