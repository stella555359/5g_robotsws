import platform
from datetime import datetime

from ...utility.trace.Logger import Logger

if platform.python_version() < '3':
    from StateBase import StateBase
    from StateMachineDebug import DebugInfo
else:
    from .StateBase import StateBase
    from .StateMachineDebug import DebugInfo


class StateFinal(StateBase):
    # static parameters

    # methods
    def __init__(self, pParent=None):
        StateBase.__init__(self)
        self.type_ = "UNKNOWN"
        self.actionTextEntry_ = ""
        self.count_ = 0
        self.isFirstTimeEntry_ = True
        self.firstTimestampFrame_ = datetime(1970, 1, 1)

    def getCount(self):
        return self.count_

    def incCount(self):
        self.count_ += 1

    def setActionTextEntry(self, pActionText):
        if self.stateMachine_ is not None:
            self.actionTextEntry_ = self.stateMachine_.getTextAction(
                self.stateMachine_.getActionScript(pActionText))

    def getActionTextEntry(self):
        return self.actionTextEntry_

    def getFirstTimestampFrame(self):
        return self.firstTimestampFrame_

    def getType(self):
        return self.type_

    def setType(self, pType):
        self.type_ = pType

    def addDebug(self, pInfo):
        if self.stateMachine_ is not None:
            smPool = self.stateMachine_.getStateMachinePool()
            if smPool is not None and smPool.getStateMachineDebug() is not None:
                debugInfo = DebugInfo()
                debugInfo.severity_ = "INFO"
                debugInfo.info_ = pInfo
                debugInfo.stateMachineName_ = self.stateMachine_.getName()
                debugInfo.stateName_ = self.getName()
                debugInfo.timestamp_ = smPool.getCurrentTimestamp()
                debugInfo.index_ = smPool.getCurrentIndex()
                smPool.getStateMachineDebug().add(debugInfo)

    def onEntry(self, *args, **kwargs):
        Logger.logDEBUG(__file__, "onEntry")
        self.incCount()
        if self.stateMachine_ is not None:
            if self.isFirstTimeEntry_:
                self.firstTimestampFrame_ = self.stateMachine_.getEventTimestamp()
            self.stateMachine_.setCurrentState(self)
            self.stateMachine_.setIsTimeout(False)
            self.stateMachine_.incFinalCount(self)
            try:
                exec(self.stateMachine_.getLoggerScript())
            except Exception:
                Logger.logERROR(
                    __file__,
                    "Error on logger script : " +
                    self.stateMachine_.getLoggerScript())
                raise
            try:
                exec(self.actionTextEntry_)
            except Exception:
                Logger.logERROR(
                    __file__,
                    "Error on entry action : " +
                    self.actionTextEntry_)
                raise
            self.addDebug("OnEntry")

    def onExit(self, *args, **kwargs):
        Logger.logDEBUG(__file__, "onExit")
        if self.stateMachine_ is not None:
            self.stateMachine_.setPreviousState(self)
