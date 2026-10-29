import platform
import re
from datetime import datetime
import time

import threading


from ...component.kpi.KpiContainer import KpiContainer

if platform.python_version() < '3':
    from StateBase import StateBase
    from StateMachine import StateMachine
    from StateMachineDebug import StateMachineDebug
    from StateMachineReport import StateMachineReport
    from StateMachineVariable import StateMachineVariable
    from StateLogger import StateLogger
    from Error import StateMachineError
else:
    from .StateBase import StateBase
    from .StateMachine import StateMachine
    from .StateMachineDebug import StateMachineDebug
    from .StateMachineReport import StateMachineReport
    from .StateMachineVariable import StateMachineVariable
    from .StateLogger import StateLogger
    from .Error import StateMachineError


class StateMachinePool(StateBase):
    # static parameters

    # methods
    def __init__(self, pDebugMode):
        StateBase.__init__(self)
        self.isStarted_ = False
        self.isFirstTime_ = True
        self.listStateMachine_ = []
        self.dictStateLogger_ = dict()
        if pDebugMode is True:
            self.stateMachineDebug_ = StateMachineDebug()
        else:
            self.stateMachineDebug_ = None
        self.stateMachineReport_ = StateMachineReport(self)
        self.stateMachineVariable_ = StateMachineVariable()
        self.dictEvent = dict()
        self.currentIndex_ = 1
        self.currentTimestamp_ = datetime(1970, 1, 1)
        self.loggerScript_ = ""
        self.stateMachineError_ = StateMachineError.NO_ERROR
        self.kpiContainer_ = KpiContainer("root", None)
        self.stateMachineToAdd_ = []

    def getLastError(self):
        return self.stateMachineError_

    def setLastError(self, pStateMachineError):
        self.stateMachineError_ = pStateMachineError

    def isStarted(self):
        return self.isStarted_

    def start(self):
        self.currentIndex_ = 1
        self.isFirstTime_ = True
        self.kpiContainer_.activate(True)
        self.kpiContainer_.start()
        for sm in self.listStateMachine_:
            sm.startSM()
        self.isStarted_ = True

    def stop(self):
        self.kpiContainer_.stop()
        for sm in self.listStateMachine_:
            sm.stopSM()
        while self.kpiContainer_.isInProcessing() is True:
            time.sleep(0.1)
        self.isStarted_ = False

    def processEvents(self):
        for sm in self.listStateMachine_:
            sm.setEventList(self.dictEvent)
            sm.runProcess()
        self.dictEvent = {}
        for sm in self.listStateMachine_:
            sm.event_.wait()
        self.incCurrentIndex()
        self.processStateMachineToAdd()

    def getCurrentIndex(self):
        return self.currentIndex_

    def incCurrentIndex(self):
        # unused
        self.currentIndex_ += 1

    def getCurrentTimestamp(self):
        return self.currentTimestamp_

    def setCurrentTimestamp(self, pCurrentTimestamp):
        self.currentTimestamp_ = pCurrentTimestamp
        for sm in self.listStateMachine_:
            sm.setEventTimestamp(pCurrentTimestamp)

    def getListStateMachine(self):
        return self.listStateMachine_

    def addStateMachineNextTime(self, pFilename):
        self.stateMachineToAdd_.append(pFilename)

    def processStateMachineToAdd(self):
        for element in self.stateMachineToAdd_:
            self.addStateMachine(element)
        self.stateMachineToAdd_ = []

    def addStateMachine(self, pFilename):
        ret = False
        event = threading.Event()
        stateMachine = StateMachine(self, event)
        stateMachine.setStateMachinePool(self)
        stateMachine.setStateMachine(stateMachine)
        stateMachine.initConnect()
        if stateMachine.loadXml(pFilename):
            if stateMachine.isValid() is True:
                stateMachine.startSM()
                self.listStateMachine_.append(stateMachine)
                ret = True
            else:
                self.stateMachineError_ = StateMachineError.SM_NOT_VALID
        return ret

    def findFilename(self, pFilename):
        index = 0
        isFound = False
        for sm in self.listStateMachine_:
            if sm.getFilename() == pFilename:
                isFound = True
                break
            else:
                index += 1
        if isFound is False:
            index = -1
        return index

    def addKpi(self, pKpiName, pKpiShortName, pSmFile):
        if self.kpiContainer_.getKpi(pKpiName) is None:
            kpi = self.kpiContainer_.addKpiByName(pKpiName, pKpiShortName)
            self.addStateMachine(pSmFile)
            kpi.addStateMachine(pSmFile)

    def getKpiResult(self, pType, pFilename, pClear):
        return self.kpiContainer_.getKpiResult(pType, pFilename, pClear)

    def addEvent(self, pEvent, pValue):
        ret = True
        if pEvent in self.dictEvent:
            self.stateMachineError_ = StateMachineError.EVENT_ALREADY_EXIST
            ret = False
        else:
            self.dictEvent[pEvent] = pValue
        return ret

    def getKpiContainer(self):
        return self.kpiContainer_

    def getStateMachineDebug(self):
        return self.stateMachineDebug_

    def getDebug(self):
        return self.stateMachineDebug_.getDebugInfo()

    def getEventInfo(self):
        ret = self.currentTimestamp_.strftime("%Y/%m/%d %H:%M:%S.%f")
        for key in self.dictEvent.keys():
            ret += "\n"
            ret += key
            ret += ";"
            ret += str(self.dictEvent[key])
            ret += ";"
            ret += str(type(self.dictEvent[key]))
            ret += ";"
        return ret

    def getStateMachineReport(self):
        return self.stateMachineReport_

    def getReport(self):
        return self.stateMachineReport_.getReportInfo()

    def getStateMachineVariable(self):
        return self.stateMachineVariable_

    def getVariable(self):
        return self.stateMachineVariable_.getVariableInfo()

    def getInputVariable(self):
        ret = "varname;vartype;varvalue;"
        for sm in self.listStateMachine_:
            smRet = sm.getInputVariable()
            if smRet != "":
                ret += "\n"
                ret += smRet
        return ret

    def getVarValue(self, pVar):
        listSdn = pVar.split(":")
        if len(listSdn) == 2:
            smName = listSdn[0]
            varName = listSdn[1]
            sm = self.getStateMachine(smName)
            if sm is not None:
                var = sm.getVar(varName)
                if var is not None:
                    value = var.getValue()
                    if value is not None:
                        return str(value)
        return ""

    def getCurrentState(self, pSmName):
        current_state = None
        sm = self.getStateMachine(pSmName)
        if sm is not None:
            current_state = sm.getCurrentState()
        return current_state

    def getStateMachine(self, pStateMachineName):
        ret = None
        for sm in self.listStateMachine_:
            if sm.getName() == pStateMachineName:
                ret = sm
                break
        return ret

    def getStateLogger(self, pFilename):
        ret = None
        if pFilename in self.dictStateLogger_:
            ret = self.dictStateLogger_[pFilename]
        else:
            stateLogger = StateLogger(pFilename)
            self.dictStateLogger_[pFilename] = stateLogger
            ret = stateLogger
        return ret

    def getLoggerScript(self):
        if self.loggerScript_ == "":
            for stateLogger in self.dictStateLogger_.values():
                if len(self.loggerScript_) != 0:
                    self.loggerScript_ += "\n"
                self.loggerScript_ += stateLogger.getVarName() + " = self.stateMachine_.getLogger(\"" + \
                    stateLogger.getFilename() + "\")"
        return self.loggerScript_

    def getEventValue(self, pRegex):
        ret = None
        if pRegex.find(".*") != -1:
            # Logger.logDEBUG(__file__, "getEventValue() REGEX = " + pRegex)
            pattern = re.compile(pRegex)
            for event in self.dictEvent.keys():
                if pattern.match(event):
                    ret = self.dictEvent[event]
                    break
        else:
            for event in self.dictEvent.keys():
                if event.rfind(pRegex) != -1:
                    ret = self.dictEvent[event]
                    break
        return ret

    def getEventKey(self, pRegex):
        ret = None
        if pRegex.find(".*") != -1:
            # Logger.logDEBUG(__file__, "getEventValue() REGEX = " + pRegex)
            pattern = re.compile(pRegex)
            for event in self.dictEvent.keys():
                if pattern.match(event):
                    ret = event
                    break
        else:
            for event in self.dictEvent.keys():
                if event.rfind(pRegex) != -1:
                    ret = event
                    break
        return ret

    def eventIsPresent(self, pEventName):
        ret = False
        if pEventName.find(".*") != -1:
            pattern = re.compile(pEventName)
            for event in self.dictEvent.keys():
                if pattern.match(event):
                    ret = True
                    break
        else:
            for event in self.dictEvent.keys():
                if event.rfind(pEventName) != -1:
                    ret = True
                    break
        return ret
