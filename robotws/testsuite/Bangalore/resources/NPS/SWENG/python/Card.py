import StringTool


# ===============================================================================================
# CARD
# ===============================================================================================
class Card(object):
    ROLE_STR = ["M", "S", "L1"]

    def __init__(self, name=None, master=None, slave=None, loner=None):
        self.name = name
        self.M = master
        self.S = slave
        self.L1 = loner

    def getVarName(self):
        if self.name[0] == "C":
            return "sys"
        return " bb"

    def addHost(self, host, prefixAlias):
        procNb = int(host.proc)
        host.alias = "{}_{}_{}".format(prefixAlias, self.name, Card.ROLE_STR[procNb])
        if procNb == 0:
            self.M = host
        elif procNb == 1:
            self.S = host
        elif procNb == 2:
            self.L1 = host

    def getHostFromId(self, nodeId):
        if self.M is not None and self.M.nodeId[0:5] in nodeId:
            return self.M
        if self.S is not None and self.S.nodeId[0:5] in nodeId:
            return self.S
        if self.L1 is not None and self.L1.nodeId[0:5] in nodeId:
            return self.L1
        return None

    def display(self, idx=None):
        StringTool.prefixDatedConsole("  Card:{}".format(self.name))
        prefix = None
        if idx is not None:
            prefix = "{}[{}]".format(self.getVarName(), idx)
        if self.M is not None:
            self.M.display(prefix=prefix)
        if self.S is not None:
            self.S.display(prefix=prefix)
        if self.L1 is not None:
            self.L1.display(prefix=prefix)

    def isOK(self):
        if self.M is not None and not self.M.status:
            return False
        if self.S is not None and not self.S.status:
            return False
        if self.L1 is not None and not self.L1.status:
            return False
        return True
