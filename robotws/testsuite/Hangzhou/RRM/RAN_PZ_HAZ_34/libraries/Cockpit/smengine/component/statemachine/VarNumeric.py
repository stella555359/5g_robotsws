import platform

if platform.python_version() < '3':
    from VarBase import VarBase
else:
    from .VarBase import VarBase


class VarNumeric(VarBase):
    # static parameters

    # methods
    def __init__(self, pName):
        VarBase.__init__(self, pName)
        self.val_ = 0.0
        self.defaultVal_ = 0.0

    def getClassName(self):
        return "VarNumeric"

    def setValue(self, pValue):
        self.val_ = float(pValue)
        VarBase.setValue(self, pValue)

    def getValue(self):
        return self.val_

    def setDefaultVal(self, pDefaultVal):
        self.defaultVal_ = pDefaultVal

    def getDefaultVal(self):
        return self.defaultVal_

    def getVarScript(self):
        varScript = self.name_ + " = " + str(self.val_)
        return varScript
