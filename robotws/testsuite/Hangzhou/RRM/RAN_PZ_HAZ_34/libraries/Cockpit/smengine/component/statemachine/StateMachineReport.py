from datetime import datetime


class ReportInfo:
    # static parameters

    # methods
    def __init__(self):
        self.index_ = -1
        self.timestamp_ = datetime(1970, 1, 1)
        self.stateMachineName_ = ""
        self.attribute_ = ""
        self.value_ = ""

    def serialize(self):
        ret = ""
        ret += self.timestamp_.strftime("%Y/%m/%d %H:%M:%S.%f")
        ret += ";"
        ret += str(self.index_)
        ret += ";"
        ret += self.stateMachineName_
        ret += ";"
        ret += self.attribute_
        ret += ";"
        ret += self.value_
        ret += ";"
        return ret


class StateInfo:
    # static parameters

    # methods
    def __init__(self):
        self.smName = ""
        self.currentState_ = ""
        self.dictStateCount_ = dict()
        self.finalSuccess_ = 0
        self.finalFailure_ = 0
        self.finalWarning_ = 0


class StateMachineReport:
    # static parameters

    # methods
    def __init__(self, pParent):
        self.dictReportInfoByIndex_ = dict()
        self.dictTimestampByIndex_ = dict()
        self.dictStateInfoByIndex_ = dict()
        self.stateMachinePool_ = pParent

    def clear(self):
        self.dictReportInfoByIndex_.clear()
        self.dictTimestampByIndex_.clear()
        self.dictStateInfoByIndex_.clear()

    def add(self, pReportInfo):
        # create index list & timestamp if necessary for report info index
        if pReportInfo.index_ not in self.dictReportInfoByIndex_:
            self.dictReportInfoByIndex_[pReportInfo.index_] = []
            self.dictTimestampByIndex_[
                pReportInfo.index_] = pReportInfo.timestamp_
        if pReportInfo.index_ not in self.dictStateInfoByIndex_:
            self.dictStateInfoByIndex_[pReportInfo.index_] = []
        # add element in list
        if self.stateMachinePool_ is not None:
            stateInfo = StateInfo()
            stateMachine = self.stateMachinePool_.getStateMachine(
                pReportInfo.stateMachineName_)
            if stateMachine is not None:
                stateInfo.smName = stateMachine.getName()
                if stateMachine.getCurrentState() is not None:
                    stateInfo.currentState_ = stateMachine.getCurrentState().getName()
                stateInfo.finalSuccess_ = stateMachine.finalSuccessCount()
                stateInfo.finalFailure_ = stateMachine.finalFailureCount()
                stateInfo.finalWarning_ = stateMachine.finalWarningCount()
                for state in stateMachine.getListState():
                    stateInfo.dictStateCount_[
                        state.getName()] = state.getCount()
            self.dictStateInfoByIndex_[pReportInfo.index_].append(stateInfo)
        self.dictReportInfoByIndex_[pReportInfo.index_].append(pReportInfo)

    def getReportInfo(self, pType, pFilename, pClear):
        reportInfoStr = ""
        if pType == "JSON":
            reportList = self.getReportInfoJson()
            for reportElement in reportList:
                reportInfoStr += reportElement
        else:
            reportInfoStr = self.getReportInfoTxt()
        if pFilename is not None:
            hfile = None
            if pClear:
                hfile = open(pFilename, "a")
            else:
                hfile = open(pFilename, "w+")
            hfile.write(reportInfoStr)
            hfile.close()
        return reportInfoStr

    def getReportInfoJsonList(self, pFilename, pClear):
        reportInfoJsonList = self.getReportInfoJson()
        if pFilename is not None:
            hfile = None
            if pClear:
                hfile = open(pFilename, "a")
            else:
                hfile = open(pFilename, "w+")
            for reportInfoStr in reportInfoJsonList:
                hfile.write(reportInfoStr)
            hfile.close()
        return reportInfoJsonList

    def getReportInfoTxt(self):
        reportInfoStr = ""
        for key in self.dictReportInfoByIndex_.keys():
            listReportInfo = self.dictReportInfoByIndex_[key]
            for reportInfo in listReportInfo:
                reportInfoStr += reportInfo.serialize()
                reportInfoStr += "\n"
        return reportInfoStr

    def getReportPart(self, pIndex, pSM, pDictSM):
        ret = ""
        if pSM in pDictSM:
            sizeAttribute = len(pDictSM[pSM])
            if sizeAttribute > 0:
                ret += "\t\t\t\t\"report\": {\n"
                # attribute
                for dictAttr in pDictSM[pSM].keys():
                    sizeValue = len(pDictSM[pSM][dictAttr])
                    ret += "\t\t\t\t\t\"" + dictAttr + "\": "
                    # value
                    for value in pDictSM[pSM][dictAttr]:
                        if isinstance(value, int) or isinstance(value, float):
                            ret += str(value)
                        else:
                            ret += "\"" + str(value) + "\""
                        if sizeValue > 1:
                            ret += ", "
                        sizeValue -= 1
                    # end value
                    if sizeAttribute > 1:
                        ret += ","
                    ret += "\n"
                    sizeAttribute -= 1
                ret += "\t\t\t\t}"
        return ret

    def getVariablePart(self, pIndex, pSM):
        ret = ""
        if self.stateMachinePool_ is not None and (
                pIndex in self.stateMachinePool_.getStateMachineVariable().getDictVariableInfoByIndex()):
            listVariableInfo = self.stateMachinePool_.getStateMachineVariable(
            ).getDictVariableInfoByIndex()[pIndex]
            listVariableInfoLocal = []
            for variableInfo in listVariableInfo:
                if variableInfo.stateMachineName_ == pSM:
                    listVariableInfoLocal.append(variableInfo)
            sizeVariable = len(listVariableInfoLocal)
            if sizeVariable > 0:
                ret += "\t\t\t\t\"variable\": {\n"
                for variable in listVariableInfoLocal:
                    ret += "\t\t\t\t\t\"" + variable.variableName_ + "\": "
                    if isinstance(variable.value_, str):
                        ret += "\"" + variable.value_ + "\""
                    elif isinstance(variable.value_, bool):
                        if variable.value_:
                            ret += "true"
                        else:
                            ret += "false"
                    else:
                        ret += str(variable.value_)
                    if sizeVariable > 1:
                        ret += ","
                    ret += "\n"
                    sizeVariable -= 1
                ret += "\t\t\t\t}"
        return ret

    def getStatePart(self, pIndex, pSM):
        ret = ""
        if pIndex in self.dictStateInfoByIndex_:
            listStateInfo = self.dictStateInfoByIndex_[pIndex]
            stateInfo = None
            for elem in reversed(listStateInfo):
                if elem.smName == pSM:
                    stateInfo = elem
                    break
            if stateInfo is not None:
                ret += "\t\t\t\t\"state\": {\n"
                ret += "\t\t\t\t\t\"current\": \"" + stateInfo.currentState_ + "\",\n"
                for state in stateInfo.dictStateCount_.keys():
                    ret += "\t\t\t\t\t\"" + state + "\": " + \
                        str(stateInfo.dictStateCount_[state]) + ",\n"
                ret += "\t\t\t\t\t\"FINAL_SUCCESS\": " + \
                    str(stateInfo.finalSuccess_) + ",\n"
                ret += "\t\t\t\t\t\"FINAL_FAILURE\": " + \
                    str(stateInfo.finalFailure_) + ",\n"
                ret += "\t\t\t\t\t\"FINAL_WARNING\": " + \
                    str(stateInfo.finalWarning_) + "\n"
                ret += "\t\t\t\t}"
        return ret

    def getSMPart(self, pIndex, pSM, pDictSM):
        ret = ""
        ret += "\t\t\t\"" + pSM + "\": {\n"
        # report
        reportPart = self.getReportPart(pIndex, pSM, pDictSM)
        # variable
        variablePart = self.getVariablePart(pIndex, pSM)
        # state
        statePart = self.getStatePart(pIndex, pSM)
        if len(reportPart) > 0:
            ret += reportPart
            if len(variablePart) > 0 or len(statePart) > 0:
                ret += ","
            ret += "\n"
        if len(variablePart) > 0:
            ret += variablePart
            if len(statePart) > 0:
                ret += ","
            ret += "\n"
        if len(statePart) > 0:
            ret += statePart
            ret += "\n"
        ret += "\t\t\t}"
        return ret

    def getReportInfoJson(self):
        listJsonReportInfo = []
        if self.stateMachinePool_ is not None:
            for index in self.dictReportInfoByIndex_.keys():  # FDEL
                # FDEL sortedkeys = self.dictReportInfoByIndex_.keys()
                # FDEL sortedkeys.sort()
                # FDEL for index in sortedkeys :
                reportInfoStr = ""
                listReportInfo = self.dictReportInfoByIndex_[index]
                # header : type & index
                reportInfoStr += "{\n"
                reportInfoStr += "\t\"_type\": \"sm\",\n"
                reportInfoStr += "\t\"_id\": " + str(index) + ",\n"
                # construct data dictionary
                dictSM = dict()
                for reportInfo in listReportInfo:
                    if reportInfo.stateMachineName_ not in dictSM:
                        dictSM[reportInfo.stateMachineName_] = dict()
                    if reportInfo.attribute_ not in dictSM[reportInfo.stateMachineName_]:
                        dictSM[reportInfo.stateMachineName_][reportInfo.attribute_] = []
                    dictSM[reportInfo.stateMachineName_][reportInfo.attribute_].append(
                        reportInfo.value_)
                # parse data dictionary
                sizeSM = len(dictSM)
                reportInfoStr += "\t\"body\": {\n"
                reportInfoStr += "\t\t\"smResult\": {\n"
                if index in self.dictTimestampByIndex_:
                    reportInfoStr += "\t\t\t\"timestamp\": " + str(
                        (self.dictTimestampByIndex_[index] - datetime(1970, 1, 1)).total_seconds())
                else:
                    reportInfoStr += "\t\t\t\"timestamp\": " + str(
                        (self.stateMachinePool_.getCurrentTimestamp() - datetime(1970, 1, 1)).total_seconds())
                if sizeSM > 0:
                    reportInfoStr += ",\n"
                else:
                    reportInfoStr += "\n"
                # state machine
                for sm in dictSM.keys():
                    reportInfoStr += self.getSMPart(index, sm, dictSM)
                    if sizeSM > 1:
                        reportInfoStr += ","
                    reportInfoStr += "\n"
                    sizeSM -= 1
                # end state machine
                reportInfoStr += "\t\t}\n"
                reportInfoStr += "\t}\n"
                reportInfoStr += "}\n"
                listJsonReportInfo.append(reportInfoStr)
        return listJsonReportInfo
