import platform

if platform.python_version() < '3':
    from VarBase import VarBase
else:
    from .VarBase import VarBase


class VarKeyString(VarBase):
    # static parameters

    # methods
    def __init__(self, pName):
        VarBase.__init__(self, pName)
        self.defaultRegex_ = ""
        self.regex_ = ""

    def getClassName(self):
        return "VarKeyString"

    def setDefaultRegex(self, pDefaultRegex):
        self.defaultRegex_ = pDefaultRegex
        if (self.defaultRegex_.find("[]") != -
                1) or (self.defaultRegex_.find("*") != -1):
            self.regex_ = self.defaultRegex_.replace("[]", "\\[[0-9]+\\]")
            self.regex_ = self.regex_.replace("*", ".*")
            if self.regex_.find(".*", 0, 2) == -1:
                self.regex_ = ".*" + self.regex_
            if self.regex_.find(".*", len(self.regex_) - 2) == -1:
                self.regex_ = self.regex_ + ".*"
        else:
            self.regex_ = pDefaultRegex

    def getDefaultRegex(self):
        return self.defaultRegex_

    def getValue(self):
        ret = None
        sm = self.getParent()
        if sm is not None:
            smPool = sm.getStateMachinePool()
            if smPool is not None:
                value = smPool.getEventValue(self.regex_)
                if value is not None:
                    ret = str(value)
        return ret

    def getKey(self):
        ret = None
        sm = self.getParent()
        if sm is not None:
            smPool = sm.getStateMachinePool()
            if smPool is not None:
                ret = smPool.getEventKey(self.regex_)
        return ret

    def getDefaultVal(self):
        return self.defaultRegex_

    def getVarScript(self):
        varScript = self.name_ + " = "
        scriptToAdd = "None"
        sm = self.getParent()
        if sm is not None:
            smPool = sm.getStateMachinePool()
            if smPool is not None:
                value = smPool.getEventValue(self.regex_)
                if value is not None:
                    scriptToAdd = '"' + \
                        value.replace('\\', '\\\\').replace('"', r'\"') + '"'
        varScript += scriptToAdd
        return varScript

    def isPresent(self):
        ret = False
        sm = self.getParent()
        if sm is not None:
            smPool = sm.getStateMachinePool()
            if smPool is not None:
                ret = smPool.eventIsPresent(self.regex_)
        return ret
