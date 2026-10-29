import time
import platform
from ...utility.trace.Logger import Logger

if platform.python_version() < '3':
    from KpiBase import KpiBase
    from Kpi import Kpi
    from KpiThread import KpiThread
else:
    from .KpiBase import KpiBase
    from .Kpi import Kpi
    from .KpiThread import KpiThread


class KpiContainer(KpiBase):
    # static parameters

    # methods
    def __init__(self, name, parent):
        KpiBase.__init__(self, name, "", parent)
        self.currentIndex_ = 0
        self.dictKpi = dict()
        self.dictCategory = dict()
        self.isInProcessing_ = False
        self.kpiThread_ = KpiThread(self)

    def getType(self):
        return "KpiContainer"

    def clear(self):
        for category in self.dictCategory.keys():
            self.dictCategory[category].clear()
        for kpi in self.dictKpi.keys():
            self.dictKpi[kpi].clear()

    def getCurrentIndex(self):
        return self.currentIndex_

    def setCurrentIndex(self, pCurrentIndex):
        self.currentIndex_ = pCurrentIndex

    def addKpi(self, pKpi):
        ret = False
        kpiName = pKpi.getName()
        if self.getKpi(kpiName) is None:
            self.dictKpi[kpiName] = pKpi
            self.dictKpi[kpiName].setParent(self)
            self.addChildren(self.dictKpi[kpiName])
            ret = True
        return ret

    def addKpiByName(self, pKpiName, pKpiShortName):
        kpi = self.getKpi(pKpiName)
        if kpi is None:
            kpi = Kpi(pKpiName, pKpiShortName, self)
            self.dictKpi[pKpiName] = kpi
            self.addChildren(self.dictKpi[pKpiName])
        return kpi

    def getKpi(self, pKpiName):
        kpi = None
        if pKpiName in self.dictKpi:
            kpi = self.dictKpi[pKpiName]
        return kpi

    def addCategory(self, pCategory):
        ret = False
        categoryName = pCategory.getName()
        if self.getCategory(categoryName) is None:
            self.dictCategory[categoryName] = pCategory
            self.dictCategory[categoryName].setParent(self)
            self.addChildren(self.dictCategory[categoryName])
            ret = True
        return ret

    def addCategoryByName(self, pCategoryName):
        category = self.getCategory(pCategoryName)
        if category is None:
            category = KpiContainer(pCategoryName, self)
            self.dictCategory[pCategoryName] = category
            self.addChildren(self.dictCategory[pCategoryName])
        return category

    def getCategory(self, pCategoryName):
        category = None
        if pCategoryName in self.dictCategory:
            category = self.dictCategory[pCategoryName]
        return category

    def getKpiResult(self, pType, pFilename, pClear):
        ret = ""
        if pType == "JSON":
            ret = self.getKpiResultJson(pClear)
        else:
            ret = self.getKpiResultTxt(pClear)
        if pFilename is not None:
            hfile = None
            if pClear:
                hfile = open(pFilename, "a")
            else:
                hfile = open(pFilename, "w+")
            hfile.write(ret)
            hfile.close()
        return ret

    def getKpiResultTxt(self, pClear):
        ret = ""
        # list initialization
        listData = []
        listTitle = ["timestamp", "index"]
        listData.append(listTitle)
        litsUnit = ["Unit", ""]
        listData.append(litsUnit)
        listMin = ["Min", ""]
        listData.append(listMin)
        listMax = ["Max", ""]
        listData.append(listMax)
        listAvg = ["Avg", ""]
        listData.append(listAvg)
        listSum = ["Sum", ""]
        listData.append(listSum)
        # create return string
        for listL in listData:
            for data in listL:
                ret += data + ";"
            ret += '\n'
        return ret

    def getKpiResultJson(self, pClear):
        ret = ""
        for category in self.dictCategory.keys():
            ret += self.dictCategory[category].getKpiResultJson(pClear)
        for kpi in self.dictKpi.keys():
            ret += self.dictKpi[kpi].getKpiResultJson(pClear)
        return ret

    def start(self):
        KpiBase.start(self)
        if self.isActivate():
            self.isInProcessing_ = True
            self.kpiThread_.start()

    def isActivate(self):
        isActivate = False
        for kpi in self.dictKpi.values():
            if kpi.isActivate():
                isActivate = True
                break
        if isActivate is False:
            for category in self.dictCategory.values():
                if category.isActivate():
                    isActivate = True
                    break
        return isActivate

    def activate(self, pActivate):
        for kpi in self.dictKpi.values():
            kpi.activate(pActivate)
        for category in self.dictCategory.values():
            category.activate(pActivate)

    def isInProcessing(self):
        isInProcessing = self.isInProcessing_
        if isInProcessing is False:
            for category in self.dictCategory.values():
                if category.isInProcessing():
                    isInProcessing = True
                    break
        return isInProcessing

    def processComponentConcurrent(self):
        Logger.logDEBUG(__file__, "processComponentConcurrent+")
        size = 0
        isData = False
        while self.isStarted_ or isData:
            size = 0
            isData = False
            for kpi in self.dictKpi.values():
                size += kpi.processComponentConcurrent()
            if size == 0:
                time.sleep(0.1)
            for kpi in self.dictKpi.values():
                if kpi.getSizeComponentToAdd() > 0:
                    isData = True
                    break
        self.isInProcessing_ = False
        Logger.logDEBUG(__file__, "processComponentConcurrent-")
