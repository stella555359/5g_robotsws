from datetime import datetime


class KpiBase:
    # static parameters

    # methods
    def __init__(self, pName, pShortName, pParent):
        self.isStarted_ = False
        self.name_ = pName
        self.fullName_ = ""
        self.shortName_ = pShortName
        if self.shortName_ == "":
            self.shortName_ = self.name_
        self.kdn_ = ""
        self.kpiParent_ = pParent
        self.listChildren_ = []
        self.listHideChildren_ = []
        self.deliveredSmPath_ = ""
        # For component element
        self.component_ = ""
        self.value_ = ""
        self.timestamp_ = datetime(1970, 1, 1)
        self.listIndex_ = []

    def getType(self):
        return ""

    def clear(self):
        del self.listChildren_[:]
        del self.listHideChildren_[:]
        del self.listIndex_[:]

    def getName(self):
        return self.name_

    def setName(self, pName):
        self.name_ = pName

    def getFullName(self):
        return self.fullName_

    def getKdn(self):
        return self.kdn_

    def getKpiParent(self):
        return self.kpiParent_

    def getListChildren(self):
        return self.listChildren_

    def getListHideChildren(self):
        return self.listHideChildren_

    def isStarted(self):
        return self.isStarted_

    def start(self):
        self.isStarted_ = True
        for children in self.listChildren_:
            children.start()
        for children in self.listHideChildren_:
            children.start()

    def stop(self):
        for children in self.listChildren_:
            children.stop()
        for children in self.listHideChildren_:
            children.stop()
        self.isStarted_ = False

    def getDeliveredSmPath(self):
        return self.deliveredSmPath_

    def setDeliveredSmPath(self, pPath):
        self.deliveredSmPath_ = pPath

    def getComponent(self):
        return self.component_

    def setComponent(self, pComponent):
        self.component_ = pComponent

    def getValue(self):
        return self.value_

    def setValue(self, pValue):
        self.value_ = pValue

    def getTimestamp(self):
        return self.timestamp_

    def setTimestamp(self, pTimestamp):
        self.timestamp_ = pTimestamp

    def getListIndex(self):
        return self.listIndex_

    def addIndex(self, pIndex):
        isFound = False
        for index in self.listIndex_:
            if index == pIndex:
                isFound = True
                break
        if isFound is False:
            self.listIndex_.append(pIndex)

    def addListIndex(self, pListIndex):
        for index in pListIndex:
            self.addIndex(index)

    def addChildren(self, pKpiBase):
        if len(self.listChildren_) == 0:
            self.listChildren_.append(pKpiBase)
        else:
            if pKpiBase.getType() == "KpiContainer":
                index = 0
                for kpiBase in self.listChildren_:
                    if kpiBase.getType() != "KpiContainer":
                        break
                    index += 1
                self.listChildren_.insert(index, pKpiBase)
            else:
                index = 0
                for kpiBase in self.listChildren_:
                    if kpiBase.getType() != "KpiContainer" and kpiBase.getName() >= pKpiBase.getName():
                        break
                    index += 1
                self.listChildren_.insert(index, pKpiBase)

    def addHideChildren(self, pKpiBase):
        self.listHideChildren_.append(pKpiBase)
