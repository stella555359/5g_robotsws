import platform
from datetime import datetime
from ...utility.trace.Logger import Logger

# if platform.python_version() < '3':
# from KpiBase import KpiBase
# from KpiComponent import KpiComponent
# from KpiComponentInfo import KpiComponentInfo
# else:
from .KpiBase import KpiBase
from .KpiComponent import KpiComponent
from .KpiComponentInfo import KpiComponentInfo

import os.path


class Kpi(KpiBase):
    # static parameters

    # methods
    def __init__(self, pName, pShortName, pParent):
        KpiBase.__init__(self, pName, pShortName, pParent)
        self.kpiAll_ = KpiBase("All", "", self)
        self.currentKpiComponentIndex = 1
        self.addHideChildren(self.kpiAll_)
        self.unit_ = ""
        self.isActivate_ = False
        self.listStateMachine_ = []
        self.listKpiBinningInfo_ = []
        self.listKpiComponentToAdd_ = []
        self.dictListHideChildren_ = dict()
        self.dictKpiComponentInfo_ = dict()
        self.listKpiProcessingInfo_ = []

    def getType(self):
        return "Kpi"

    def clear(self):
        self.kpiAll_.clear()

    def setUnit(self, pUnit):
        self.unit_ = pUnit

    def getUnit(self):
        return self.unit_

    def activate(self, pIsActivate):
        if pIsActivate:
            isFound = True
            for sm in self.listStateMachine_:
                filename = sm
                if self.deliveredSmPath_ != "":
                    filename = self.deliveredSmPath_ + "/" + sm
                    if os.path.isfile(filename) is False:
                        isFound = False
                        break
            if isFound:
                self.isActivate_ = True
            else:
                self.isActivate_ = False
        else:
            self.isActivate_ = pIsActivate

    def isActivate(self):
        return self.isActivate_

    def getListStateMachine(self):
        return self.listStateMachine_

    def addStateMachine(self, pSateMachine):
        isFound = False
        for sm in self.listStateMachine_:
            if sm == pSateMachine:
                isFound = True
                break
        if isFound is False:
            self.listStateMachine_.append(pSateMachine)

    def getDictKpiComponentInfo(self):
        return self.dictListHideChildren_

    def getSizeComponentToAdd(self):
        return len(self.listKpiComponentToAdd_)

    def getAllComponentByIndex(self, pIndex):
        ret = []
        for kpiComponent in self.kpiAll_.getListHideChildren():
            isFound = False
            for index in kpiComponent.getListIndex():
                if index == pIndex:
                    isFound = True
                    break
            if isFound:
                ret.append(kpiComponent)
        return ret

    def getKpiResultJson(self, pClear):
        ret = ""
        for kpiComponent in self.kpiAll_.getListHideChildren():
            ret += kpiComponent.getKpiResultJson()
        if pClear:
            self.kpiAll_.clear()
        return ret

    def addKpiComponent(self, pKpiComponent):
        # perhaps a listKpiComponentToAdd_ lock is necessary here
        self.listKpiComponentToAdd_.append(pKpiComponent)

    def setValue(self, pComponent, pValue, pTimestamp):
        if self.isActivate_:
            kpiComponent = None
            if isinstance(pTimestamp, str):
                if pTimestamp != "":
                    kpiComponent = KpiComponent(
                        pComponent,
                        pValue,
                        datetime.strptime(pTimestamp, "%Y/%m/%d %H:%M:%S.%f"),
                        self.kpiAll_,
                    )
                else:
                    kpiComponent = KpiComponent(
                        pComponent, pValue, datetime(1970, 1, 1), self.kpiAll_
                    )
            elif isinstance(pTimestamp, float) or isinstance(pTimestamp, int):
                kpiComponent = KpiComponent(
                    pComponent,
                    pValue,
                    datetime.utcfromtimestamp(pTimestamp),
                    self.kpiAll_,
                )
            elif isinstance(pTimestamp, datetime):
                kpiComponent = KpiComponent(
                    pComponent, pValue, pTimestamp, self.kpiAll_
                )
            kpiComponent.setKpi(self)
            if self.kpiParent_.getType() == "KpiContainer":
                kpiComponent.addIndex(self.kpiParent_.getCurrentIndex())
            else:
                kpiComponent.addIndex(0)
            self.addKpiComponent(kpiComponent)

    def searchInHideChildren(self, pKpiComponent):
        kpiComponent = None
        if pKpiComponent.getTimestamp() in self.dictListHideChildren_:
            listHideChildren = self.dictListHideChildren_[pKpiComponent.getTimestamp()]
            for children in listHideChildren:
                if children.getComponent() == pKpiComponent.getComponent():
                    kpiComponent = children
                    break
        return kpiComponent

    def addToListKpiAndBinningComponent(self, pKpiComponent, pAddToProcessinInfo=True):
        if pKpiComponent.getComponent() in self.dictKpiComponentInfo_:
            kpiComponentInfo = self.dictKpiComponentInfo_[pKpiComponent.getComponent()]
            if not isinstance(pKpiComponent.getValue(), str):
                kpiComponentInfo.setValue(
                    pKpiComponent.getValue(),
                    pKpiComponent.getTimestamp(),
                    pKpiComponent.getListIndex()[0],
                    pAddToProcessinInfo is False,
                )
        else:
            kpiComponentInfo = KpiComponentInfo(self)
            if not isinstance(pKpiComponent.getValue(), str):
                kpiComponentInfo.setValue(
                    pKpiComponent.getValue(),
                    pKpiComponent.getTimestamp(),
                    pKpiComponent.getListIndex()[0],
                    pAddToProcessinInfo is False,
                )
            kpiComponentInfo.setComponent(pKpiComponent.getComponent())
            self.dictKpiComponentInfo_[pKpiComponent.getComponent()] = kpiComponentInfo
            self.addChildren(kpiComponentInfo)

    def processComponentConcurrent(self):
        Logger.logDEBUG(__file__, "processComponentConcurrent+")
        ret = 0
        while ret <= 20 and len(self.listKpiComponentToAdd_) > 0:
            # perhaps a listKpiComponentToAdd_ lock is necessary here
            kpiComponent = self.listKpiComponentToAdd_.pop(0)
            if kpiComponent is not None and self.kpiAll_ is not None:
                kpiComponentFound = self.searchInHideChildren(kpiComponent)
                if kpiComponentFound is not None:
                    if kpiComponent.getValue() != kpiComponentFound.getValue():
                        kpiComponentFound.addToValue(kpiComponent.getValue())
                        kpiComponentFound.addIndex(kpiComponent.getIndex())
                        self.addToListKpiAndBinningComponent(kpiComponent, False)
                else:
                    if kpiComponent.getTimestamp() not in self.dictListHideChildren_:
                        self.dictListHideChildren_[kpiComponent.getTimestamp()] = []
                    self.dictListHideChildren_[kpiComponent.getTimestamp()].append(
                        kpiComponent
                    )
                    kpiComponent.id_ = self.currentKpiComponentIndex
                    self.currentKpiComponentIndex += 1
                    self.kpiAll_.addHideChildren(kpiComponent)
                    self.addToListKpiAndBinningComponent(kpiComponent)
            ret += 1
        Logger.logDEBUG(__file__, "processComponentConcurrent- (" + str(ret) + ")")
        return ret
