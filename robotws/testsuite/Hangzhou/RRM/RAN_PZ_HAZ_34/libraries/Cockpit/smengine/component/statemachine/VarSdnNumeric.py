import platform

if platform.python_version() < '3':
    from VarBase import VarBase
else:
    from .VarBase import VarBase


class VarSdnNumeric(VarBase):
    # static parameters

    # methods
    def __init__(self, pName):
        VarBase.__init__(self, pName)
        self.sdn_ = ""
        self.defaultValue_ = ""

    def getClassName(self):
        return "VarSdnNumeric"

    def setSdn(self, pSdn):
        self.sdn_ = pSdn

    def getSdn(self):
        return self.sdn_

    def getValue(self):
        ret = None
        listSdn = self.sdn_.split(":")
        if len(listSdn) == 2:
            smName = listSdn[0]
            varName = listSdn[1]
            sm = self.getParent()
            if sm is not None:
                smPool = sm.getStateMachinePool()
                if smPool is not None:
                    smFound = smPool.getStateMachine(smName)
                    if smFound is not None:
                        varFound = smFound.getVar(varName)
                        if varFound is not None:
                            ret = varFound.getValue()
        return ret

    def setDefaultValue(self, pDefaultValue):
        self.defaultValue_ = pDefaultValue

    def getDefaultValue(self):
        return self.defaultValue_

    def getVarScript(self):
        varScript = self.name_ + " = "
        scriptToAdd = "None"
        listSdn = self.sdn_.split(":")
        if len(listSdn) == 2:
            smName = listSdn[0]
            varName = listSdn[1]
            sm = self.getParent()
            if sm is not None:
                smPool = sm.getStateMachinePool()
                if smPool is not None:
                    smFound = smPool.getStateMachine(smName)
                    if smFound is not None:
                        varFound = smFound.getVar(varName)
                        if varFound is not None:
                            scriptToAdd = str(varFound.getValue())
        varScript += scriptToAdd
        return varScript

    def isPresent(self):
        ret = False
        listSdn = self.sdn_.split(":")
        if len(listSdn) == 2:
            smName = listSdn[0]
            varName = listSdn[1]
            sm = self.getParent()
            if sm is not None:
                smPool = sm.getStateMachinePool()
                if smPool is not None:
                    smFound = smPool.getStateMachine(smName)
                    if smFound is not None:
                        ret = (smFound.getVar(varName) is not None)
        return ret
