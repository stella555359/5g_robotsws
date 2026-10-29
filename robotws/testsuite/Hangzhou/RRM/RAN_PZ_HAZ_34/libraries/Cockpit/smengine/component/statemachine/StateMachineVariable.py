from datetime import datetime


class VariableInfo:
    # static parameters

    # methods
    def __init__(self):
        self.variableName_ = ""
        self.value_ = ""
        self.index_ = -1
        self.timestamp_ = datetime(1970, 1, 1)
        self.stateMachineName_ = ""

    def serialize(self):
        ret = ""
        ret += self.timestamp_.strftime("%Y/%m/%d %H:%M:%S.%f")
        ret += ";"
        ret += str(self.index_)
        ret += ";"
        ret += self.stateMachineName_
        ret += ";"
        ret += self.variableName_
        ret += ";"
        ret += str(self.value_)
        ret += ";"
        return ret


class StateMachineVariable:
    # static parameters

    # methods
    def __init__(self):
        self.dictVariableInfoByIndex_ = dict()

    def clear(self):
        self.dictVariableInfoByIndex_.clear()

    def add(self, pVariableInfo):
        # create index list & timestamp if necessary for report info index
        if pVariableInfo.index_ not in self.dictVariableInfoByIndex_:
            self.dictVariableInfoByIndex_[pVariableInfo.index_] = []
        # add element in list
        self.dictVariableInfoByIndex_[
            pVariableInfo.index_].append(pVariableInfo)

    def getVariableInfo(self):
        variableInfoStr = ""
        for key in self.dictVariableInfoByIndex_.keys():
            listVariableInfo = self.dictVariableInfoByIndex_[key]
            for variableInfo in listVariableInfo:
                variableInfoStr += variableInfo.serialize()
                variableInfoStr += "\n"
        return variableInfoStr

    def getDictVariableInfoByIndex(self):
        return self.dictVariableInfoByIndex_
