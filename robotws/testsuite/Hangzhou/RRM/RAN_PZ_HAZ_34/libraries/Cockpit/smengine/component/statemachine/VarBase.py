import platform

if platform.python_version() < '3':
    from StateMachineVariable import VariableInfo
else:
    from .StateMachineVariable import VariableInfo


class VarBase:
    # static parameters

    # methods
    def __init__(self, pName):
        self.name_ = pName
        self.counter_ = 0
        self.parent_ = None

    def setName(self, pName):
        self.name_ = pName

    def getName(self):
        return self.name_

    def getClassName(self):
        return "VarBase"

    def getDefaultVal(self):
        return ""

    def setCounter(self, pCounter):
        self.counter_ = pCounter

    def getCounter(self):
        return self.counter_

    def setParent(self, pParent):
        self.parent_ = pParent

    def getParent(self):
        return self.parent_

    def getVarScript(self):
        return ""

    def setValue(self, pValue):
        variableInfo = VariableInfo()
        variableInfo.variableName_ = self.name_
        variableInfo.value_ = pValue
        sm = self.parent_
        if sm is not None:
            variableInfo.stateMachineName_ = sm.getName()
            smPool = sm.getStateMachinePool()
            if smPool is not None:
                variableInfo.timestamp_ = smPool.getCurrentTimestamp()
                variableInfo.index_ = smPool.getCurrentIndex()
                smPool.getStateMachineVariable().add(variableInfo)

    def getValue(self):
        return None

    def getValueToStr(self):
        return ""

    def getKey(self):
        return None

    def isPresent(self):
        return True
