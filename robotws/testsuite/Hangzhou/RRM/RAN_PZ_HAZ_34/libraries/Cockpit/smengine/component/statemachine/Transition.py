import platform
from ...utility.trace.Logger import Logger

if platform.python_version() < '3':
    from StateBase import StateBase
    from StateMachineDebug import DebugInfo
else:
    from .StateBase import StateBase
    from .StateMachineDebug import DebugInfo


class Transition(StateBase):
    # static parameters

    # methods
    def __init__(self, pParent=None):
        StateBase.__init__(self)
        self.eventExpression_ = ""
        self.eventExpression2_ = ""
        self.actionTriggered_ = ""
        self.target_ = ""
        self.isPresentExpression_ = False

    def setEventExpression(self, pEventExpression):
        self.eventExpression_ = pEventExpression.replace('\n', ' ')

        index = self.eventExpression_.find(".getField_")
        while index != -1:
            # retrieve variable name
            varName = ""
            saveIndex = index
            charFound = True
            while index - 1 >= 0 and charFound:
                char = self.eventExpression_[index - 1]
                charFound = char not in (
                    '\n', ' ', '(', '\t', '#', ',', '+', '-', '=')
                if charFound:
                    varName = char + varName
                    index = index - 1
            startIndex = index

            # retrieve string
            fieldString = ''
            index = saveIndex + 10
            charFound = True
            while index < len(self.eventExpression_) and charFound:
                char = self.eventExpression_[index]
                charFound = char not in (
                    '\n', ' ', '(', '\t', '#', ',', ')', '+', '-', '=')
                if charFound:
                    fieldString = fieldString + char
                    index = index + 1
            endIndex = index
            self.eventExpression_ = self.eventExpression_[
                0:startIndex] + 'self.getField("' + varName + '","' + self.decodeGetField(
                fieldString) + '")' + self.eventExpression_[endIndex:]
            # print(self.eventExpression_)
            index = self.eventExpression_.find(".getField", endIndex)
        # print(self.eventExpression_)

        if self.eventExpression_.find(".isPresent") != -1:

            self.isPresentExpression_ = True
            index = self.eventExpression_.find(".isPresent")
            StartIndex = 0
            eventExpression = self.eventExpression_
            self.eventExpression2_ = ""
            while index != -1:
                # remove 'isPresent' text
                eventExpression = eventExpression[:index] + \
                    eventExpression[index + 10:]
                # retrieve variable name
                varName = ""
                saveIndex = index
                charFound = True
                while index - 1 >= 0 and charFound:
                    char = eventExpression[index - 1]
                    charFound = char not in ('\n', ' ', '(', '\t', '#')
                    if charFound:
                        varName = char + varName
                        index = index - 1
                eventExpression = eventExpression[:index] + \
                    eventExpression[saveIndex:]

                self.eventExpression2_ += eventExpression[StartIndex:index]
                self.eventExpression2_ += "self.testForExec(\"" + \
                    varName + "\")"
                StartIndex = index
                index = eventExpression.find(".isPresent")
                self.eventExpression2_ += eventExpression[StartIndex:]
                i = 1
        # print(self.eventExpression_)

    def getEventExpression(self):
        # not used
        return self.eventExpression_

    def setActionTriggered(self, pActionText):
        if self.stateMachine_ is not None:
            self.actionTriggered_ = self.stateMachine_.getTextAction(
                self.stateMachine_.getActionScript(pActionText))

    def getActionTriggered(self):
        # not used
        return self.actionTriggered_

    def setTarget(self, pTarget):
        self.target_ = pTarget

    def getTarget(self):
        return self.target_

    def isTimeoutCondition(self):
        return self.eventExpression_.find("_TIMEOUT_") != -1

    def addDebugEventTest(self, pOk):
        if self.stateMachine_ is not None:
            smPool = self.stateMachine_.getStateMachinePool()
            if smPool is not None and smPool.getStateMachineDebug() is not None:
                debugInfo = DebugInfo()
                debugInfo.severity_ = "INFO"
                debugInfo.timestamp_ = smPool.getCurrentTimestamp()
                debugInfo.index_ = smPool.getCurrentIndex()
                debugInfo.stateMachineName_ = self.stateMachine_.getName()
                if self.sourceState() is not None and self.targetState() is not None:
                    debugInfo.stateName_ = "[" + self.sourceState(
                    ).getName() + ">" + self.targetState().getName() + "]"
                if pOk:
                    debugInfo.info_ = "TRUE"
                else:
                    debugInfo.info_ = "FALSE"
                debugInfo.transition_ = self.eventExpression_
                smPool.getStateMachineDebug().add(debugInfo)

    def addDebugOnTransition(self):
        if self.stateMachine_ is not None:
            smPool = self.stateMachine_.getStateMachinePool()
            if smPool is not None and smPool.getStateMachineDebug() is not None:
                debugInfo = DebugInfo()
                debugInfo.severity_ = "INFO"
                debugInfo.info_ = "OnTransition"
                debugInfo.timestamp_ = smPool.getCurrentTimestamp()
                debugInfo.index_ = smPool.getCurrentIndex()
                debugInfo.stateMachineName_ = self.stateMachine_.getName()
                if self.sourceState() is not None and self.targetState() is not None:
                    debugInfo.stateName_ = "[" + self.sourceState(
                    ).getName() + ">" + self.targetState().getName() + "]"
                debugInfo.transition_ = self.eventExpression_
                smPool.getStateMachineDebug().add(debugInfo)

    def onTransition(self, *args, **kwargs):
        Logger.logDEBUG(__file__, "onTransition")
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
                exec(self.actionTriggered_)
            except Exception:
                Logger.logERROR(
                    __file__,
                    "Error on triggered action : " +
                    self.actionTriggered_)
                raise
            self.addDebugOnTransition()

    def eventTest(self):
        Logger.logDEBUG(__file__, "eventTest")
        ok = False
        if self.stateMachine_ is not None:
            if self.isPresentExpression_ is False:
                try:
                    exec(self.stateMachine_.getVarScript())
                    # print(self.stateMachine_.getVarScript())
                except Exception:
                    Logger.logERROR(
                        __file__,
                        "Error on var script : " +
                        self.stateMachine_.getVarScript())
                    raise
                try:
                    # print(self.eventExpression_)
                    ok = eval(self.eventExpression_)
                    # print(ok)
                except Exception as e:
                    ok = False
                    Logger.logERROR(
                        __file__,
                        "Error on transition evaluation : " +
                        self.eventExpression_)
                    Logger.logERROR(__file__, str(e))
                    raise
            else:

                try:
                    exec(self.stateMachine_.getVarScript())
                except Exception:
                    Logger.logERROR(
                        __file__,
                        "Error on var script : " +
                        self.stateMachine_.getVarScript())
                    raise
                try:
                    ok = eval(self.eventExpression2_)
                except Exception as e:
                    ok = False
                    Logger.logERROR(
                        __file__,
                        "Error on transition evaluation : " +
                        self.eventExpression2)
                    Logger.logERROR(__file__, str(e))
                    raise
            self.addDebugEventTest(ok)
        return ok
