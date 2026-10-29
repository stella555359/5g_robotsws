import platform
from datetime import datetime

if platform.python_version() < '3':
    from KpiBase import KpiBase
else:
    from .KpiBase import KpiBase


class KpiComponent(KpiBase):
    # static parameters

    # methods
    def __init__(self, pComponent, pValue, pTimestamp, pKpiParent=None):
        KpiBase.__init__(self, "", "", pKpiParent)
        self.kpi_ = None
        if pKpiParent.getType() == "Kpi":
            self.kpi_ = pKpiParent
        self.setComponent(pComponent)
        self.setTimestamp(pTimestamp)
        self.setValue(pValue)
        self.id_ = -1
        self.setName(pComponent + "(" + str(pValue) + "," +
                     pTimestamp.strftime("%Y/%m/%d %H:%M:%S.%f") + ")")

    def getType(self):
        return "KpiComponent"

    def setKpi(self, pKpi):
        if pKpi.getType() == "Kpi":
            self.kpi_ = pKpi

    def addToValue(self, pValue):
        self.setValue(self.getValue() + pValue)

    def getKpiResultJson(self):
        ret = ""
        if self.kpi_ is not None and self.kpi_.getKpiParent() is not None:
            ret += "{\n"
            ret += "\t\"_type\": \"" + self.kpi_.getName() + "\",\n"
            ret += "\t\"_id\": " + str(self.id_) + ",\n"
            ret += "\t\"body\" :{\n"
            ret += "\t\t\"kpi\" :{\n"
            ret += "\t\t\t\"timestamp\": " + \
                str((self.getTimestamp() - datetime(1970, 1, 1)).total_seconds()) + ",\n"
            ret += "\t\t\t\"category\": \"" + self.kpi_.getKpiParent().getName() + "\",\n"
            ret += "\t\t\t\"name\": \"" + self.kpi_.getName() + "\",\n"
            ret += "\t\t\t\"unit\": \"" + self.kpi_.getUnit() + "\",\n"
            ret += "\t\t\t\"component\": \"" + self.getComponent() + "\",\n"
            ret += "\t\t\t\"event\": " + str(self.getListIndex()[0]) + ",\n"
            ret += "\t\t\t\"value\": " + str(self.getValue()) + "\n"
            ret += "\t\t}\n"
            ret += "\t}\n"
            ret += "}\n"
        return ret
