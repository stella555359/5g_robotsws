import platform
import math

if platform.python_version() < '3':
    from KpiBase import KpiBase
else:
    from .KpiBase import KpiBase


class KpiComponentInfo(KpiBase):
    # static parameters

    # methods
    def __init__(self, pKpiParent=None):
        KpiBase.__init__(self, "", "", pKpiParent)
        self.count_ = 0
        self.countInfo_ = 0
        self.sum_ = 0.0
        self.last_ = None
        self.min_ = 0.0
        self.max_ = 0.0
        self.avg_ = 0.0
        self.isFirst_ = True
        self.listTimestamp_ = []
        self.listIndex_ = []
        self.listValue_ = []
        self.kpi_ = None
        if pKpiParent is not None and pKpiParent.getType() == "Kpi":
            self.kpi_ = pKpiParent

    def getType(self):
        return "KpiComponentInfo"

    def setValue(self, pValue, pTimestamp, pIndex, pDoublon):
        isDb = self.kpi_ is not None and (
            self.kpi_.getUnit() == "dB" or self.kpi_.getUnit() == "dBm")
        self.last_ = pValue
        if pValue < self.min_ or self.isFirst_:
            self.min_ = pValue
        if pValue > self.max_ or self.isFirst_:
            self.max_ = pValue
        if isDb:
            self.sum_ += pow(10, pValue / 10)
        else:
            self.sum_ += pValue
        if pDoublon is False:
            self.listValue_.append(pValue)
            self.listTimestamp_.append(pTimestamp)
            self.listIndex_.append(pIndex)
            self.count_ += 1
        if isDb:
            self.avg_ = 10 * math.log10(self.sum_ / self.count_)
        else:
            self.avg_ = self.sum_ / self.count_
        self.isFirst_ = False

    def setComponent(self, pComponent):
        KpiBase.setComponent(self, pComponent)
        self.setName(pComponent)
