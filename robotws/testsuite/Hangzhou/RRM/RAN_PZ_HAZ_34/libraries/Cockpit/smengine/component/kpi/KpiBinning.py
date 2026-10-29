from datetime import datetime

from .KpiBase import KpiBase


class KpiBinning(KpiBase):
    # static parameters

    # methods
    def __init__(self, component, parent):
        KpiBase.__init__(self, component, "", parent)
        self.startTimestamp_ = datetime(1970, 1, 1)
        self.cum_ = 0.0
        self.size_ = 0
        self.isFirst_ = True
        self.index_ = 0

    def getType(self):
        return "KpiBinning"

    def reset(self, pResetAll):
        self.startTimestamp_ = datetime(1970, 1, 1)
        self.cum_ = 0.0
        self.size_ = 0
        self.isFirst_ = True

    def getIndex(self):
        return self.index_

    def resetIndex(self):
        self.index_ = 0

    def incrementIndex(self):
        self.index_ += 1

    def getCum(self):
        return self.cum_

    def incrementCum(self):
        self.cum_ += 1

    def getSize(self):
        return self.size_
