from datetime import datetime


class DebugInfo:
    # static parameters

    # methods
    def __init__(self):
        self.isInitial_ = False
        self.index_ = -1
        self.severity_ = ""
        self.timestamp_ = datetime(1970, 1, 1)
        self.stateMachineName_ = ""
        self.stateName_ = ""
        self.transition_ = ""
        self.info_ = ""

    def serialize(self):
        ret = ""
        ret += self.timestamp_.strftime("%Y/%m/%d %H:%M:%S.%f")
        ret += ";"
        ret += str(self.index_)
        ret += ";"
        ret += self.stateMachineName_
        ret += ";"
        if self.stateName_ != "":
            ret += self.stateName_
        elif self.transition_ != "":
            ret += self.transition_
        ret += ";"
        ret += self.info_
        ret += ";"
        return ret


class StateMachineDebug:
    # static parameters

    # methods
    def __init__(self):
        self.listDebugInfo_ = []

    def add(self, pDebugInfo):
        self.listDebugInfo_.append(pDebugInfo)

    def getDebugInfo(self, pFilename=None):
        debugInfoStr = ""
        for debugInfo in self.listDebugInfo_:
            debugInfoStr += debugInfo.serialize()
            debugInfoStr += "\n"
        if pFilename is not None:
            hfile = open(pFilename, "w+")
            hfile.write(debugInfoStr)
            hfile.close()
        return debugInfoStr
