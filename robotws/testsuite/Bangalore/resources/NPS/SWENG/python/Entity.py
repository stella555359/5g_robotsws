import StringTool
import Enums
import Oam


# ===============================================================================================
# Entity
# ===============================================================================================
class Entity(StringTool.ObjWithErrors):
    NB_CALL = 0
    TABLE_PREFIX = {True: "T", False: ""}

    def __init__(self, hw, unit, index, oamSSH, oamHTTP):
        super(Entity, self).__init__()
        self.hw = hw
        self.unit = unit
        self.index = index
        self.prefix = "{}{}_{}{}".format(Entity.TABLE_PREFIX[self.isGNB()], hw, unit, self.indexToStr())
        self.name = "{}{}_{}{}_{}".format(Entity.TABLE_PREFIX[self.isGNB()],
                                          hw, unit, self.indexToStr(False), type(self).__name__)
        self.oam = Oam.getOam(sshConnection=oamSSH, httpConnection=oamHTTP, hw=hw, unit=unit, index=index)
        if self.oam is not None:
            self.oam.setEntity(self)
        self.profil = None

    def __str__(self):
        return self.name

    def indexToStr(self, withParenthesis=True):
        if self.isGNB():
            if withParenthesis:
                return "[{}]".format(self.index)
            else:
                return "{}".format(self.index)
        return ""

    def getProfil(self):
        return None

    def isGNB(self):
        return self.hw == Enums.HW.GNB

    def isUnitCU(self):
        return self.unit == Enums.CU

    def isUnitDU(self):
        return self.unit == Enums.DU

    def separationLine(self):
        if Entity.NB_CALL != 0:
            StringTool.prefixDatedConsole("".ljust(154, "."))
        Entity.NB_CALL += 1

    def display(self):
        self.separationLine()
        StringTool.prefixDatedConsole("{:7}:{}".format(self.prefix, self.name))
        self.oam.displayVMs()
