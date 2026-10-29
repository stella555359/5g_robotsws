import platform
from datetime import datetime
import os
import xml.etree.ElementTree as ET

from ...utility.trace.Logger import Logger
from threading import Thread

if platform.python_version() < '3':
    from StateBase import StateBase
    from State import State
    from StateFinal import StateFinal
    from Transition import Transition

    from VarBoolean import VarBoolean
    from VarInteger import VarInteger
    from VarNumeric import VarNumeric
    from VarString import VarString

    from VarKeyBoolean import VarKeyBoolean
    from VarKeyInteger import VarKeyInteger
    from VarKeyNumeric import VarKeyNumeric
    from VarKeyString import VarKeyString

    from VarSdnBoolean import VarSdnBoolean
    from VarSdnInteger import VarSdnInteger
    from VarSdnNumeric import VarSdnNumeric
    from VarSdnString import VarSdnString

    from StateMachineReport import ReportInfo
    from StateMachineDebug import DebugInfo

    from StateLogger import StateLogger
    from Error import StateMachineError
else:
    from .StateBase import StateBase
    from .State import State
    from .StateFinal import StateFinal
    from .Transition import Transition

    from .VarBoolean import VarBoolean
    from .VarInteger import VarInteger
    from .VarNumeric import VarNumeric
    from .VarString import VarString

    from .VarKeyBoolean import VarKeyBoolean
    from .VarKeyInteger import VarKeyInteger
    from .VarKeyNumeric import VarKeyNumeric
    from .VarKeyString import VarKeyString

    from .VarSdnBoolean import VarSdnBoolean
    from .VarSdnInteger import VarSdnInteger
    from .VarSdnNumeric import VarSdnNumeric
    from .VarSdnString import VarSdnString

    from .StateMachineReport import ReportInfo
    from .StateMachineDebug import DebugInfo

    from .StateLogger import StateLogger
    from .Error import StateMachineError


class StateMachine(Thread, StateBase):
    # static parameters

    # methods
    def __init__(self, pParent, event):
        Thread.__init__(self)
        StateBase.__init__(self)
        self.filename_ = ""
        self.isAutomaticRestart_ = False
        self.dictVar_ = dict()
        self.listState_ = []
        self.listName = {}
        self.actionTextBegin_ = ""
        self.actionTextEnd_ = ""
        self.eventTimestamp_ = datetime(1970, 1, 1)
        self.dictReplaceText = dict()
        self.previousState_ = None
        self.currentState_ = None
        self.finalSuccess_ = 0
        self.finalFailure_ = 0
        self.finalWarning_ = 0
        self.currentVarScript_ = ""
        self.isTimeout_ = False
        self.running_ = False
        self.initialState_ = None
        self.event_ = event
        self.event_.set()

    def initConnect(self):
        # replace text initialization
        self.dictReplaceText["smReport"] = "self.stateMachine_.report"
        self.dictReplaceText["smSetIsAutomaticRestart"] = "self.stateMachine_.setIsAutomaticRestart"
        self.dictReplaceText["smIsAutomaticRestart"] = "self.stateMachine_.isAutomaticRestart"
        self.dictReplaceText["smGetLogger"] = "self.stateMachine_.getLogger"
        self.dictReplaceText["smGetVarValue"] = "self.stateMachine_.getVarValue"
        self.dictReplaceText["smSetVarValue"] = "self.stateMachine_.setVarValue"
        self.dictReplaceText["smGetCurrentTimestampPc"] = "self.stateMachine_.getCurrentTimestampPc"
        self.dictReplaceText["smGetPreviousStateName"] = "self.stateMachine_.getPreviousStateName"
        self.dictReplaceText["smGetCurrentFrameNumber"] = "self.stateMachine_.getCurrentFrameNumber"
        # deprecated methods
        self.dictReplaceText["smGetSourceName"] = "self.stateMachine_.getSourceName"
        self.dictReplaceText["smGetCurrentFileName"] = "self.stateMachine_.getCurrentFileName"
        self.dictReplaceText["smGetCallInfo"] = "self.stateMachine_.getCallInfo"
        self.dictReplaceText["smGetCurrentTimestampPc"] = "self.stateMachine_.getCurrentTimestampPc"
        self.dictReplaceText["smGetCurrentTimestampPcMicroSec"] = "self.stateMachine_.getCurrentTimestampPcMicroSec"
        self.dictReplaceText["smGetCurrentFrameNumberInFile"] = "self.stateMachine_.getCurrentFrameNumberInFile"
        self.dictReplaceText["smGetCallId"] = "self.stateMachine_.getCallId"
        self.dictReplaceText["smInfo"] = "self.stateMachine_.info"
        self.dictReplaceText["smGetAppVersion"] = "self.stateMachine_.getAppVersion"
        self.dictReplaceText["smGetWorkspace"] = "self.stateMachine_.getWorkspace"
        self.dictReplaceText["smDecodeCurrentFrame"] = "self.stateMachine_.decodeCurrentFrame"
        self.dictReplaceText["smGetCurrentRawFrame"] = "self.stateMachine_.getCurrentRawFrame"
        self.dictReplaceText["smExportCall"] = "self.stateMachine_.exportCall"
        self.dictReplaceText["smExportSourceName"] = "self.stateMachine_.exportSourceName"
        self.dictReplaceText["smScheduleExportMessages"] = "self.stateMachine_.scheduleExportMessages"
        self.dictReplaceText["smPauseProcessing"] = "self.stateMachine_.pauseProcessing"
        self.dictReplaceText["smStopProcessing"] = "self.stateMachine_.stopProcessing"

    def isValid(self):
        return True

    def isAutomaticRestart(self):
        return self.isAutomaticRestart_

    def setIsAutomaticRestart(self, pIsAutomaticRestart):
        # unused
        self.isAutomaticRestart_ = pIsAutomaticRestart

    def getFilename(self):
        return self.filename_

    def setFilename(self, pFilename):
        self.filename_ = pFilename
        rootname, file_extension = os.path.splitext(pFilename)
        self.setName(os.path.basename(rootname))

    def getEventTimestamp(self):
        return self.eventTimestamp_

    def setEventTimestamp(self, pEventTimestamp):
        self.eventTimestamp_ = pEventTimestamp

    def setActionTextBegin(self, pText):
        self.actionTextBegin_ = self.getTextAction(self.getActionScript(pText))

    def getActionTextBegin(self):
        # not used
        return self.actionTextBegin_

    def setActionTextEnd(self, pText):
        self.actionTextEnd_ = self.getTextAction(self.getActionScript(pText))

    def getActionTextEnd(self):
        # not used
        return self.actionTextEnd_

    def setPreviousState(self, pPreviousState):
        self.previousState_ = pPreviousState

    def setCurrentState(self, pCurrentState):
        self.currentState_ = pCurrentState

    def getCurrentState(self):
        return self.currentState_

    def setIsTimeout(self, pIsTimeout):
        self.isTimeout_ = pIsTimeout

    def isTimeout(self):
        return self.isTimeout_

    def clearCurrentVarScript(self):
        self.currentVarScript_ = ""

    def incFinalCount(self, pFinalState):
        if pFinalState is not None:
            finalType = pFinalState.getType()
            if finalType == "SUCCESS":
                self.finalSuccess_ += 1
            elif finalType == "FAILURE":
                self.finalFailure_ += 1
            elif finalType == "WARNING":
                self.finalWarning_ += 1
            else:
                Logger.logERROR(__file__, "Bad final type : " + finalType)

    def finalSuccessCount(self):
        return self.finalSuccess_

    def finalFailureCount(self):
        return self.finalFailure_

    def finalWarningCount(self):
        return self.finalWarning_

    def getInputVariable(self):
        ret = ""
        for var in self.dictVar_.values():
            if ret != "":
                ret += "\n"
            ret += var.getName()
            ret += ";"
            ret += var.getClassName()
            ret += ";"
            ret += str(var.getDefaultVal())
            ret += ";"
        return ret

    def getVar(self, pName):
        ret = None
        if pName in self.dictVar_:
            ret = self.dictVar_[pName]
        return ret

    def addVar(self, pVarBase):
        var = self.getVar(pVarBase.getName())
        if var is None:
            self.dictVar_[pVarBase.getName()] = pVarBase

    def getState(self, pStateName):
        try:
            return self.listName[pStateName]
        except Exception:
            return None

    def getListState(self):
        return self.listState_

    def loadXml(self, pFilename):
        ret = True
        try:
            if os.path.isfile(pFilename):
                self.parseXml(pFilename)
                self.setFilename(pFilename)
            else:
                raise "Error: file does not exist"
        except Exception as e:
            if platform.python_version() < '3':
                Logger.logERROR(__file__, "loadXml error: " +
                                pFilename + "(" + e.message + ")")
            else:
                errorInfo = "loadXml error: {}({})".format(pFilename, e)
                Logger.logERROR(__file__, errorInfo)
            if self.stateMachinePool_ is not None:
                self.stateMachinePool_.setLastError(
                    StateMachineError.SM_FILE_ERROR)
            ret = False
        return ret

    def parseXml(self, pFilename):
        Logger.logDEBUG(__file__, "parseXml")
        tree = ET.parse(pFilename)
        root = tree.getroot()
        if root.tag == "scxml":
            self.setName(root.attrib.get("id", ""))
            if root.attrib.get("loop", "") == "true":
                self.isAutomaticRestart_ = True
            for child in root:
                if child.tag == "onenter":
                    self.setActionTextBegin(child.text)
                elif child.tag == "onexit":
                    self.setActionTextEnd(child.text)
                elif child.tag == "param":
                    self.parseParam(child)
                elif child.tag == "state":
                    self.parseState(child)
                elif child.tag == "initial":
                    self.parseStateInitial(child)
                elif child.tag == "final":
                    self.parseStateFinal(child)
        for state in self.listState_:
            state.update(self)

    def parseParam(self, pRoot):
        for child in pRoot:
            if child.tag == "varboolean":
                var = VarBoolean(child.attrib.get("id", ""))
                var.setDefaultVal(bool(child.attrib.get("value", "True")))
                var.setParent(self)
                self.addVar(var)
            elif child.tag == "varinteger":
                var = VarInteger(child.attrib.get("id", ""))
                var.setDefaultVal(int(child.attrib.get("value", "0")))
                var.setParent(self)
                self.addVar(var)
            elif child.tag == "varnumeric":
                var = VarNumeric(child.attrib.get("id", ""))
                var.setDefaultVal(int(child.attrib.get("value", "0")))
                var.setParent(self)
                self.addVar(var)
            elif child.tag == "varstring":
                var = VarString(child.attrib.get("id", ""))
                var.setDefaultVal(child.attrib.get("value", ""))
                var.setParent(self)
                self.addVar(var)
            elif child.tag == "varkeyboolean":
                var = VarKeyBoolean(child.attrib.get("id", ""))
                var.setDefaultRegex(child.attrib.get("value", ""))
                var.setParent(self)
                self.addVar(var)
            elif child.tag == "varkeyinteger":
                var = VarKeyInteger(child.attrib.get("id", ""))
                var.setDefaultRegex(child.attrib.get("value", ""))
                var.setParent(self)
                self.addVar(var)
            elif child.tag == "varkeynumeric":
                var = VarKeyNumeric(child.attrib.get("id", ""))
                var.setDefaultRegex(child.attrib.get("value", ""))
                var.setParent(self)
                self.addVar(var)
            elif child.tag == "varkeystring":
                var = VarKeyString(child.attrib.get("id", ""))
                var.setDefaultRegex(child.attrib.get("value", ""))
                var.setParent(self)
                self.addVar(var)
            elif child.tag == "varsdnboolean":
                var = VarSdnBoolean(child.attrib.get("id", ""))
                var.setSdn(child.attrib.get("value", ""))
                var.setParent(self)
                self.addVar(var)
            elif child.tag == "varsdninteger":
                var = VarSdnInteger(child.attrib.get("id", ""))
                var.setSdn(child.attrib.get("value", ""))
                var.setParent(self)
                self.addVar(var)
            elif child.tag == "varsdnnumeric":
                var = VarSdnNumeric(child.attrib.get("id", ""))
                var.setSdn(child.attrib.get("value", ""))
                var.setParent(self)
                self.addVar(var)
            elif child.tag == "varsdnstring":
                var = VarSdnString(child.attrib.get("id", ""))
                var.setSdn(child.attrib.get("value", ""))
                var.setParent(self)
                self.addVar(var)

    def parseState(self, pRoot):
        state = State()
        state.setStateMachine(self)
        state.setName(pRoot.attrib.get("id", ""))
        for child in pRoot:
            if child.tag == "onenter":
                state.setActionTextEntry(child.text)
            elif child.tag == "onexit":
                state.setActionTextExit(child.text)
            elif child.tag == "transition":
                self.parseTransition(child, state)
        self.listState_.append(state)
        self.listName[state.getName()] = state
        # self.addState(state)

    def parseStateInitial(self, pRoot):
        state = State()
        state.setStateMachine(self)
        state.setName(pRoot.attrib.get("id", ""))
        for child in pRoot:
            if child.tag == "onenter":
                state.setActionTextEntry(child.text)
            elif child.tag == "onexit":
                state.setActionTextExit(child.text)
            elif child.tag == "transition":
                self.parseTransition(child, state)
        self.listState_.append(state)
        self.listName[state.getName()] = state
        # self.addState(state)
        self.setInitialState(state)
        self.currentState_ = state

    def setInitialState(self, state):
        self.initialState_ = state

    def parseStateFinal(self, pRoot):
        state = StateFinal()
        state.setStateMachine(self)
        state.setName(pRoot.attrib.get("id", ""))
        state.setType(pRoot.attrib.get("type", "UNKNOWN"))
        for child in pRoot:
            if child.tag == "onenter":
                state.setActionTextEntry(child.text)
        self.listState_.append(state)
        self.listName[state.getName()] = state
        # self.addState(state)

    def parseTransition(self, pRoot, pState):
        transition = Transition()
        transition.setStateMachine(self)
        transition.setEventExpression(pRoot.attrib.get("event", ""))
        transition.setTarget(pRoot.attrib.get("target", ""))
        for child in pRoot:
            if child.tag == "onenter":
                transition.setActionTriggered(child.text)
        pState.addTransition(transition)

    def getVarScript(self):
        if self.currentVarScript_ == "":
            for var in self.dictVar_.values():
                if self.currentVarScript_ != "":
                    self.currentVarScript_ += "\n"
                self.currentVarScript_ += var.getVarScript()
        return self.currentVarScript_

    def getLoggerScript(self):
        loggerScript = ""
        if self.stateMachinePool_ is not None:
            loggerScript = self.stateMachinePool_.getLoggerScript()
        return loggerScript

    def getActionScript(self, pActionScript):
        Logger.logDEBUG(__file__, "Entry script : " + pActionScript)
        retActionScript = pActionScript
        # search and add logger
        self.createLogger(retActionScript)
        # search and replace state machine python method
        for text in self.dictReplaceText.keys():
            retActionScript = retActionScript.replace(
                text, self.dictReplaceText[text])
        # search and replace variable python method
        retActionScript = self.replaceVarScript(
            retActionScript, ".getValue(", "self.stateMachine_.getVarValue(")
        retActionScript = self.replaceVarScript(
            retActionScript,
            ".getAllValues(",
            "self.stateMachine_.getVarAllValues(")
        retActionScript = self.replaceVarScript(
            retActionScript, ".getText(", "self.stateMachine_.getVarText(")
        retActionScript = self.replaceVarScript(
            retActionScript,
            ".getAllTexts(",
            "self.stateMachine_.getVarAllTexts(")
        retActionScript = self.replaceVarScript(
            retActionScript, ".getAllDNs(", "self.stateMachine_.getVarAllDNs(")
        retActionScript = self.replaceVarScript(
            retActionScript, ".getKey(", "self.stateMachine_.getVarKey(")
        # search and replace kpi/var python setValue method
        retActionScript = self.replaceSetValueScript(retActionScript)
        # search and replace state python method
        retActionScript = self.replaceVarScript(
            retActionScript, ".isActive(", "self.stateMachine_.getStateIsActive(")
        retActionScript = self.replaceVarScript(
            retActionScript, ".getCounter(", "self.stateMachine_.getStateCounter(")
        retActionScript = self.replaceVarScript(
            retActionScript,
            ".getFrameNumber(",
            "self.stateMachine_.getStateFrameNumber(")
        retActionScript = self.replaceVarScript(
            retActionScript,
            ".getFirstTimestampFrame(",
            "self.stateMachine_.getStateFirstTimestampFrame(")
        retActionScript = self.replaceVarScript(
            retActionScript,
            ".getCurrentTimestampFrame(",
            "self.stateMachine_.getStateCurrentTimestampFrame(")
        retActionScript = self.replaceVarScript(
            retActionScript,
            ".getFirstTimestampFrameStr(",
            "self.stateMachine_.getStateFirstTimestampFrameStr(")
        retActionScript = self.replaceVarScript(
            retActionScript,
            ".getCurrentTimestampFrameStr(",
            "self.stateMachine_.getStateCurrentTimestampFrameStr(")
        retActionScript = self.replaceVarScript(
            retActionScript,
            ".getFirstTimestampFrameMicroSec(",
            "self.stateMachine_.getStateFirstTimestampFrameMicroSec(")
        retActionScript = self.replaceVarScript(
            retActionScript,
            ".getCurrentTimestampFrameMicroSec(",
            "self.stateMachine_.getStateCurrentTimestampFrameMicroSec(")
        Logger.logDEBUG(__file__, "Return script : " + retActionScript)
        return retActionScript

    def createLogger(self, pActionScript):
        index = pActionScript.find("smGetLogger")
        lenght = len(pActionScript)
        while index != -1:
            loggerVarName = ""
            loggerVarNameIndex = index
            while loggerVarNameIndex > 0 and pActionScript[loggerVarNameIndex] != "=":
                loggerVarNameIndex -= 1
            loggerVarNameIndex -= 1
            while loggerVarNameIndex > 0 and pActionScript[loggerVarNameIndex] == " ":
                loggerVarNameIndex -= 1
            while loggerVarNameIndex >= 0 and pActionScript[loggerVarNameIndex] not in (
                    '\n', ' ', '(', '\t', '#'):
                loggerVarName = pActionScript[loggerVarNameIndex] + \
                    loggerVarName
                loggerVarNameIndex -= 1
            filename = ""
            filenameIndex = index + len("smGetLogger") + 2
            while filenameIndex < lenght and pActionScript[filenameIndex] != "\"":
                filename = filename + pActionScript[filenameIndex]
                filenameIndex += 1
            stateLogger = self.getLogger(filename)
            stateLogger.setVarName(loggerVarName)
            index = filenameIndex
            index = pActionScript.find("smGetLogger", index)

    def replaceVarScript(self, pActionScript, pVarMethod, pNewVarMethod):
        retActionScript = pActionScript
        index = retActionScript.find(pVarMethod)
        while index != -1:
            varName = ""
            saveIndex = index
            charFound = True
            while index - 1 >= 0 and charFound:
                char = retActionScript[index - 1]
                charFound = char not in ('\n', ' ', '(', '\t', '#')
                if charFound:
                    varName = char + varName
                    index = index - 1
            retActionScript = retActionScript[:index] + \
                retActionScript[saveIndex + len(pVarMethod):]
            newText = pNewVarMethod + "\"" + varName + "\""
            if retActionScript[index] != ")":
                newText += ","
            retActionScript = retActionScript[:index] + \
                newText + retActionScript[index:]
            index += len(newText)
            index = retActionScript.find(pVarMethod, index)
        return retActionScript

    def replaceSetValueScript(self, pActionScript):
        retActionScript = pActionScript
        method = ".setValue("
        varMethod = "self.stateMachine_.setVarValue("
        kpiMethod = "self.stateMachine_.setKpiValue("
        index = retActionScript.find(method)
        while index != -1:
            varName = ""
            saveIndex = index
            charFound = True
            while index - 1 >= 0 and charFound:
                char = retActionScript[index - 1]
                charFound = char not in ('\n', ' ', '(', '\t', '#')
                if charFound:
                    varName = char + varName
                    index = index - 1
            retActionScript = retActionScript[:index] + \
                retActionScript[saveIndex + len(method):]
            virguleCount = retActionScript.count(
                ",", index, retActionScript.find(")", index))
            newText = ""
            if virguleCount > 0:
                newText = kpiMethod + "\"" + varName + "\","
            else:
                newText = varMethod + "\"" + varName + "\","
            retActionScript = retActionScript[:index] + \
                newText + retActionScript[index:]
            index += len(newText)
            index = retActionScript.find(method, index)
        return retActionScript

    def addDebug(self, pInfo):
        smPool = self.getStateMachinePool()
        if smPool is not None and smPool.getStateMachineDebug() is not None:
            debugInfo = DebugInfo()
            debugInfo.severity_ = "INFO"
            debugInfo.info_ = pInfo
            debugInfo.stateMachineName_ = self.getName()
            debugInfo.timestamp_ = smPool.getCurrentTimestamp()
            debugInfo.index_ = smPool.getCurrentIndex()
            smPool.getStateMachineDebug().add(debugInfo)

    def getTextAction(self, pTextAction):
        Logger.logDEBUG(__file__, "Entry text : " + pTextAction)
        textAction = pTextAction
        textResult = ""

        # print(textAction)
        index = textAction.find(".getField_")
        while index != -1:
            # retrieve variable name
            varName = ""
            saveIndex = index
            charFound = True
            while index - 1 >= 0 and charFound:
                char = textAction[index - 1]
                charFound = char not in (
                    '\n', ' ', '(', '\t', '#', ')', ',', '+', '-', '=')
                if charFound:
                    varName = char + varName
                    index = index - 1
            startIndex = index

            # retrieve string
            fieldString = ''
            index = saveIndex + 10
            charFound = True
            while index < len(textAction) and charFound:
                char = textAction[index]
                charFound = char not in (
                    '\n', ' ', '(', '\t', '#', ')', '+', '-', '=')
                if charFound:
                    fieldString = fieldString + char
                    index = index + 1
            endIndex = index
            textAction = textAction[0:startIndex] + 'self.getField("' + varName + '","' + self.decodeGetField(
                fieldString) + '")' + textAction[endIndex:]
            index = textAction.find(".getField_", endIndex)

        index = textAction.find(".isPresent()")
        StartIndex = 0
        while index != -1:
            # remove 'isPresent' text
            textAction = textAction[:index] + textAction[index + 12:]
            # retrieve variable name
            varName = ""
            charFound = True
            saveIndex = index
            while index - 1 >= 0 and charFound:
                char = textAction[index - 1]
                charFound = char not in ('\n', ' ', '(', '\t', '#')
                if charFound:
                    varName = char + varName
                    index = index - 1
            textAction = textAction[:index] + textAction[saveIndex:]

            textResult += textAction[StartIndex:index]
            textResult += "self.testForExec(\"" + varName + "\")"
            StartIndex = index
            index = textAction.find(".isPresent()")
        textResult += textAction[StartIndex:]

        Logger.logDEBUG(__file__, "Return text : " + textResult)
        return textResult

    def onBegin(self):
        Logger.logDEBUG(__file__, "onBegin")
        try:
            exec(self.getLoggerScript())
        except Exception:
            Logger.logERROR(
                __file__,
                "Error on logger script : " +
                self.getLoggerScript())
            raise
        try:
            exec(self.actionTextBegin_)
        except Exception:
            Logger.logERROR(
                __file__,
                "Error on begin action : " +
                self.actionTextBegin_)
            raise
        self.addDebug("OnEntry")

    def onEnd(self):
        cwd = os.getcwd()
        logDirectory = cwd + '/' + os.path.basename(self.filename_)[:-3]
        os.chdir(logDirectory)
        Logger.logDEBUG(__file__, "onEnd")
        try:
            exec(self.getLoggerScript())
        except Exception:
            Logger.logERROR(
                __file__,
                "Error on logger script : " +
                self.getLoggerScript())
            raise
        try:
            exec(self.actionTextEnd_)
        except Exception:
            Logger.logERROR(
                __file__,
                "Error on end action : " +
                self.actionTextEnd_)
            raise
        os.chdir(cwd)
        self.addDebug("OnExit")

    def startSM(self):
        Logger.logDEBUG(__file__, "start")
        if not self.running_:
            Logger.logINFO(
                __file__,
                "State Machine Started %s" % hex(
                    id(self)))
            self.running_ = True
            self.onBegin()
            self.currentState_ = self.initialState_
            self.currentState_.onEntry()
            self.running_ = True

    def stopSM(self):
        Logger.logDEBUG(__file__, "stop")
        if self.running_:
            Logger.logINFO(
                __file__,
                "State Machine Stopped %s" % hex(
                    id(self)))
            self.running_ = False
            self.onEnd()

    def isRunning(self):
        return self.running_

    def setEventList(self, eventListInformation):
        self.eventListInformation_ = eventListInformation

    def runProcess(self):
        try:
            if isinstance(self.currentState_, StateFinal):
                return
            self.event_.clear()
            for transition in self.currentState_.listTransition_:
                state = transition.getTarget()
                if state is not None and transition.eventTest():
                    if self.currentState_ == self.initialState_ and self.isAutomaticRestart():
                        self.stateMachinePool_.addStateMachineNextTime(
                            self.filename_)
                    self.currentState_.onExit()
                    transition.onTransition()
                    state.onEntry()
                    self.currentState_ = state
                    # print("%s_%s: %s"%(os.path.basename(self.filename_), hex(id(self)), self.currentState_.name_))
                    Logger.logINFO(
                        __file__, "%s_%s: %s" %
                        (os.path.basename(
                            self.filename_), hex(
                            id(self)), self.currentState_.name_))
                    if isinstance(self.currentState_, StateFinal):
                        self.stopSM()
                    break
            self.currentVarScript_ = ""
            self.event_.set()
        except Exception as e:
            pass

    def run(self):
        pass

    def reportInfo(self, pReportInfo):
        if self.stateMachinePool_ is not None:
            pReportInfo.index_ = self.stateMachinePool_.getCurrentIndex()
            pReportInfo.timestamp_ = self.stateMachinePool_.getCurrentTimestamp()
            self.stateMachinePool_.getStateMachineReport().add(pReportInfo)

    # Action methods
    def report(self, pAttributeName, pVariant, pProperty=""):
        reportInfo = ReportInfo()
        reportInfo.stateMachineName_ = self.getName()
        reportInfo.attribute_ = pAttributeName
        reportInfo.value_ = pVariant
        reportInfo.property_ = pProperty
        self.reportInfo(reportInfo)

    def getLogger(self, pFilename):
        if self.stateMachinePool_ is not None:
            return self.stateMachinePool_.getStateLogger(pFilename)
        stateLogger = StateLogger(pFilename)
        return stateLogger

    def getVarValue(self, pVarName, pVarType=""):
        ret = None
        var = self.getVar(pVarName)
        if var is not None:
            if pVarType == "":
                ret = var.getValue()
            elif pVarType == "STRING":
                ret = str(var.getValue())
            elif pVarType == "HEX":
                ret = str(hex(var.getValue()))
            elif pVarType == "DEC":
                ret = int(hex(var.getValue()))
        return ret

    def getVarKey(self, pVarName):
        ret = None
        var = self.getVar(pVarName)
        if var is not None:
            ret = var.getKey()
        return ret

    def setVarValue(self, pVarName, pValue):
        var = self.getVar(pVarName)
        if var is not None:
            var.setValue(pValue)

    def getVarText(self, pVarName):
        return self.getVarValue(pVarName, "STRING")

    def getPreviousStateName(self):
        ret = ""
        if self.previousState_ is not None:
            ret = self.previousState_.getName()
        return ret

    def getCurrentFrameNumber(self):
        ret = 0
        if self.stateMachinePool_ is not None:
            ret = self.stateMachinePool_.getCurrentIndex()
        return ret

    def setKpiValue(self, pKpiName, pComponent, pValue, pTimestamp):
        if self.stateMachinePool_ is not None:
            kpiContainer = self.stateMachinePool_.getKpiContainer()
            if kpiContainer is not None:
                kpi = kpiContainer.getKpi(pKpiName)
                if kpi is not None:
                    kpi.setValue(pComponent, pValue, pTimestamp)

    def getStateIsActive(self, pStateName):
        ret = False
        state = self.getState(pStateName)
        if state is not None and self.currentState_ is not None and state == self.currentState_:
            ret = True
        return ret

    def getStateCounter(self, pStateName):
        ret = 0
        state = self.getState(pStateName)
        if state is not None:
            ret = state.getCount()
        return ret

    def getStateFrameNumber(self, pStateName):
        return self.getCurrentFrameNumber()

    def getStateFirstTimestampFrame(self, pStateName):
        ret = datetime(1970, 1, 1)
        state = self.getState(pStateName)
        if state is not None:
            ret = state.getFirstTimestampFrame()
        return ret

    def getStateCurrentTimestampFrame(self, pStateName):
        ret = datetime(1970, 1, 1)
        if self.stateMachinePool_ is not None:
            ret = self.stateMachinePool_.getCurrentTimestamp()
        return ret

    def getStateFirstTimestampFrameStr(self, pStateName):
        ret = ""
        state = self.getState(pStateName)
        if state is not None:
            ret = state.getFirstTimestampFrame().strftime("%Y/%m/%d %H:%M:%S.%f")
        return ret

    def getStateCurrentTimestampFrameStr(self, pStateName):
        ret = ""
        if self.stateMachinePool_ is not None:
            ret = self.stateMachinePool_.getCurrentTimestamp().strftime("%Y/%m/%d %H:%M:%S.%f")
        return ret

    def getStateFirstTimestampFrameMicroSec(self, pStateName):
        ret = 0
        state = self.getState(pStateName)
        if state is not None:
            ret = (
                state.getFirstTimestampFrame() -
                datetime(
                    1970,
                    1,
                    1)).total_seconds()
        return ret

    def getStateCurrentTimestampFrameMicroSec(self, pStateName):
        ret = 0
        if self.stateMachinePool_ is not None:
            ret = (
                self.stateMachinePool_.getCurrentTimestamp() -
                datetime(
                    1970,
                    1,
                    1)).total_seconds()
        return ret

    # Deprecated action methods (C++ methods)
    def getSourceName(self):
        print("Deprecated method (smGetSourceName)")
        return ""

    def getCurrentFileName(self):
        print("Deprecated method (smGetCurrentFileName)")
        return ""

    def getCallInfo(self, pStringInfo):
        print("Deprecated method (smGetCallInfo)")
        return ""

    def getCurrentTimestampPc(self):
        print("Deprecated method (smGetCurrentTimestampPc)")
        return ""

    def getCurrentTimestampPcMicroSec(self):
        print("Deprecated method (smGetCurrentTimestampPcMicroSec)")
        return 0

    def getCurrentFrameNumberInFile(self):
        print("Deprecated method (smGetCurrentFrameNumberInFile)")
        return 0

    def getCallId(self):
        print("Deprecated method (smGetCallId)")
        return ""

    def info(self, pTextInfo):
        print("Deprecated method (smInfo)")

    def appVersion(self):
        print("Deprecated method (smAppVersion)")
        return ""

    def getWorkspace(self):
        print("Deprecated method (smGetWorkspace)")
        return ""

    def decodeCurrentFrame(self, pFormat="texttab"):
        print("Deprecated method (smDecodeCurrentFrame)")
        return ""

    def getCurrentRawFrame(self):
        print("Deprecated method (smGetCurrentRawFrame)")
        return ""

    def exportCall(self, pFormat="texttab", pFoldername=""):
        print("Deprecated method (smExportCall)")

    def exportSourceName(self, pFormat="texttab", pFilename=""):
        print("Deprecated method (smExportSourceName)")

    def scheduleExportMessages(self, pRange, pFormat="pcap", pFilename=""):
        print("Deprecated method (smScheduleExportMessages)")

    def pauseProcessing(self):
        print("Deprecated method (smPauseProcessing)")

    def stopProcessing(self):
        print("Deprecated method (smStopProcessing)")

    def getVarAllValues(self, pVarName):
        print("Deprecated method (getAllValues)")
        return []

    def getVarAllTexts(self, pVarName):
        print("Deprecated method (getAllTexts)")
        return []

    def getVarAllDNs(self, pVarName):
        print("Deprecated method (getAllDNs)")
        return []
