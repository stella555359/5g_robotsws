import StringTool


class UErrcConfigChecking:

    def __init__(self, ue):
        StringTool.datedConsole("  Start analysis Prb for UE {}".format(ue))
        self._ue = ue
        self._listStartPrb12 = []
        self._listStartPrb13 = []
        self._tddChecklist = 4
        self._fddChecklist = 3

    def __str__(self):
        return "UE={} StartPrb12={} StartPrb13={}".format(self._ue, self._listStartPrb12, self._listStartPrb13)

    def Error(self, msg):
        StringTool.datedConsole("ERROR:{}".format(msg))

    def startPrbTddFDM(self, format2, nbOfPrb, startSymbolIndex, startPRB):
        startingSymbolIndex = int(startSymbolIndex)
        startPrbInt = int(startPRB)
        if int(format2) == 2 and int(nbOfPrb) == 16:
            prefix = "    UE={} Format2:{} nbOfPrb:{} startSymbolIndex:{} startPRB:{:3}".\
                format(self._ue, format2, nbOfPrb, startSymbolIndex, startPRB)
            if startingSymbolIndex == 12:
                self._listStartPrb12.append(startPrbInt)
                StringTool.datedConsole("{}:Adding {:3} for symbol 12".format(prefix, startPrbInt))
            elif startingSymbolIndex == 13:
                self._listStartPrb13.append(startPrbInt)
                StringTool.datedConsole("{}:Adding {:3} for symbol 13".format(prefix, startPrbInt))

    def checkList(self, name, list, technology):
        StringTool.datedConsole("    {}:{}".format(name, list))
        expectedLen = self._tddChecklist
        if technology == "FDD":
            expectedLen = self._fddChecklist
        if len(list) != expectedLen:
            self.Error("list {} has a cardinal of {} ({} expected)".format(name, len(list), expectedLen))
            return False
        for i in range(0, (expectedLen-1)):
            if ((list[i+1] - list[i]) % 16) != 0:
                self.Error("Element[{}]({})-Element[{}]({}) not 16".format(i+1, list[i+1], i, list[i]))
                return False
        return True

    def compareList(self, list1, list2):
        diff = set(list1).difference(set(list2))
        if len(diff) != 0:
            self.Error("StartPrb12 ({}) and StartPrb13 ({}) are different".format(list1, list2))
            return False
        else:
            StringTool.datedConsole("    StartPrb13 ({})is identical to StartPrb12".format(list2))
        return True

    def checkStartPrbTddFdm(self, technology):
        # Check on list 12
        chk1 = self.checkList("startPrb12", self._listStartPrb12, technology)
        # Compare list 12 and list 13
        chk2 = self.compareList(self._listStartPrb12, self._listStartPrb13)
        return chk1 and chk2


def newUErrcConfigChecking(ue):
    return UErrcConfigChecking(ue)


def addStartPrbTddFDM(UErrc, format2, nbOfPrb, startSymbolIndex, startPRB):
    UErrc.startPrbTddFDM(format2, nbOfPrb, startSymbolIndex, startPRB)


def checkStartPrbTddFdmForUE(UErrc, technology):
    return UErrc.checkStartPrbTddFdm(technology)


def TestStartPrbBetweenUEs(listUeRrc):
    for i in range(0, len(listUeRrc)-1):
        startPrb1 = listUeRrc[i]._listStartPrb12[0]
        startPrb2 = listUeRrc[i+1]._listStartPrb12[0]
        prefix = "UE[{}]:StartPrb12[0]={} UE[{}]:StartPrb12[0]={}".\
                 format(listUeRrc[i]._ue, startPrb1, listUeRrc[i+1]._ue, startPrb2)
        if ((startPrb2 - startPrb1) % 16) != 0:
            listUeRrc[i].Error("{}: Diff is not 16".format(prefix))
            return False
        else:
            StringTool.datedConsole("  Comparison between UEs:{}".format(prefix))
    return True


class pucchParameters:
    def __init__(self, maxPucchF2, pucchBw, maxPucchF2PerBw):
        self._maxPucchF2 = maxPucchF2
        self._pucchBw = pucchBw
        self._maxPucchF2PerBw = maxPucchF2PerBw

    def getMaxPucchF2(self):
        return self._maxPucchF2

    def getPucchBw(self):
        return self._pucchBw

    def getMaxPucchF2PerBw(self):
        return self._maxPucchF2PerBw
