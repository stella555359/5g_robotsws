import sys
from PyQt4 import QtCore

from threading import Thread, RLock

from .HandlerForQt import HandlerForQt
from .component.statemachine.StateMachinePool import StateMachinePool

from .utility.trace.Logger import Logger


class Worker(Thread):
    # This is the Qt event loop thread.
    # All Qt objects have to be created in this thread

    # Methods
    def __init__(self, pDebugMode):
        Thread.__init__(self)
        self.debugMode = pDebugMode
        self.stateMachinePool = None
        self.qtApp = None
        self.handlerForQt = None
        self.isStateMachineAdded = False
        self.retStateMachineAdded = False
        self.AreEventsProcessed = False
        self.lockAddStateMachine = RLock()
        self.lockProcessEvents = RLock()

    def __del__(self):
        # self.wait()
        None

    def run(self):
        # FOR ENABLE BREAKPOINT IN THREAD BEGIN
        # import pydevd
        # pydevd.connected = True
        # pydevd.settrace(suspend=False)
        # FOR ENABLE BREAKPOINT IN THREAD END

        self.qtApp = QtCore.QCoreApplication(sys.argv)
        self.handlerForQt = HandlerForQt(self.qtApp)
        self.stateMachinePool = StateMachinePool(self.debugMode, self.qtApp)

        self.handlerForQt.signalAddStateMachine.connect(
            self.slotAddStateMachine)
        self.handlerForQt.signalProcessEvents.connect(
            self.slotProcessEvents, QtCore.Qt.BlockingQueuedConnection)
        self.handlerForQt.signalQuit.connect(
            QtCore.QCoreApplication.quit,
            QtCore.Qt.BlockingQueuedConnection)
        print("Qt event loop thread started")
        sys.exit(self.qtApp.exec_())

    # Slots
    def slotAddStateMachine(self, pSmFile):
        with self.lockAddStateMachine:
            self.isStateMachineAdded = False
            self.retStateMachineAdded = self.stateMachinePool.addStateMachine(
                pSmFile)
            self.isStateMachineAdded = True
            Logger.logDEBUG(__file__, "addStateMachine done")

    def slotProcessEvents(self):
        with self.lockProcessEvents:
            self.AreEventsProcessed = False
            self.stateMachinePool.load()
            self.AreEventsProcessed = True
