import platform

if platform.python_version() < '3':
    from VarBase import VarBase
else:
    from .VarBase import VarBase


class VarString(VarBase):
    # static parameters

    # methods
    def __init__(self, pName):
        VarBase.__init__(self, pName)
        self.val_ = ""
        self.defaultVal_ = ""

    def getClassName(self):
        return "VarString"

    def setValue(self, pValue):
        self.val_ = str(pValue)
        VarBase.setValue(self, pValue)

    def getValue(self):
        return self.val_

    def setDefaultVal(self, pDefaultVal):
        self.defaultVal_ = pDefaultVal

    def getDefaultVal(self):
        return self.defaultVal_

    def getVarScript(self):
        varScript = self.name_ + " = \"" + self.val_ + "\""
        return varScript
