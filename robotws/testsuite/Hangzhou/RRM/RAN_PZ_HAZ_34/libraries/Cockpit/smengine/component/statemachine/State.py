import platform
from datetime import datetime

from ...utility.trace.Logger import Logger

if platform.python_version() < '3':
    from StateBase import StateBase
    from StateMachineDebug import DebugInfo
else:
    from .StateBase import StateBase
    from .StateMachineDebug import DebugInfo


class State(StateBase):
    # static parameters

    # methods
    def __init__(self, pParent=None):
        StateBase.__init__(self)
        self.actionTextEntry_ = ""
        self.actionTextExit_ = ""
        self.listTransition_ = []
        self.stateMachine_ = None
        self.count_ = 0
        self.hasTimeoutCondition_ = False
        self.isFirstTimeEntry_ = True
        self.firstTimestampFrame_ = datetime(1970, 1, 1)

    def getCount(self):
        return self.count_

    def incCount(self):
        self.count_ += 1

    def getFirstTimestampFrame(self):
        return self.firstTimestampFrame_

    def addTransition(self, pTransition):
        name = str(len(self.listTransition_))
        pTransition.setName(name)
        if pTransition.isTimeoutCondition():
            self.hasTimeoutCondition_ = True
            self.listTransition_.insert(0, pTransition)
        else:
            self.listTransition_.append(pTransition)

    def setActionTextEntry(self, pActionText):
        if self.stateMachine_ is not None:
            self.actionTextEntry_ = self.stateMachine_.getTextAction(
                self.stateMachine_.getActionScript(pActionText))

    def getActionTextEntry(self):
        # not used
        return self.actionTextEntry_

    def setActionTextExit(self, pActionText):
        if self.stateMachine_ is not None:
            self.actionTextExit_ = self.stateMachine_.getTextAction(
                self.stateMachine_.getActionScript(pActionText))

    def getActionTextExit(self):
        return self.actionTextExit

    def update(self, pStateMachine):
        for transition in self.listTransition_:
            state = pStateMachine.getState(transition.getTarget())
            if state is not None:
                transition.setTarget(state)
        self.stateMachine_ = pStateMachine

    def addDebug(self, pIsInitial, pInfo):
        if self.stateMachine_ is not None:
            smPool = self.stateMachine_.getStateMachinePool()
            if smPool is not None and smPool.getStateMachineDebug() is not None:
                debugInfo = DebugInfo()
                debugInfo.severity_ = "INFO"
                debugInfo.isInitial_ = pIsInitial
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
            self.stateMachine_.setIsTimeout(self.hasTimeoutCondition_)
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
            self.addDebug(False, "OnEntry")

    def onExit(self, *args, **kwargs):
        Logger.logDEBUG(__file__, "onExit")
        if self.stateMachine_ is not None:
            try:
                exec(self.stateMachine_.getLoggerScript())
            except Exception:
                Logger.logERROR(
                    __file__,
                    "Error on logger script : " +
                    self.stateMachine_.getLoggerScript())
                raise
            try:
                exec(self.actionTextExit_)
            except Exception:
                Logger.logERROR(
                    __file__,
                    "Error on exit action : " +
                    self.actionTextExit_)
                raise
            self.stateMachine_.setPreviousState(self)
            self.addDebug(False, "OnExit")
