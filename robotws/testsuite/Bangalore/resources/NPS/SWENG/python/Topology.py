import enum
import os
import subprocess
import StringTool
from robot.libraries.BuiltIn import BuiltIn


# =================================================================================================
class Tag:
    def __init__(self, tag, name=None):
        self.tag = tag
        self.name = name
        if name is None:
            self.name = tag

    def __str__(self):
        return self.name

    def __eq__(self, other):
        return self.tag == other.tag

    def matches(self, str):
        return "_{}_".format(self.tag) in str or str.endswith("_{}".format(self.tag))


# =================================================================================================
class ChoiceOf:
    def __init__(self, listKw):
        self.tag = self.getTagFromList(listKw, self.getListTag())

    def __str__(self):
        return self.tag.name

    def getTagFromList(self, str, listTag):
        for tag in listTag:
            if tag.matches(str):
                return tag
        if len(tag.tag) == 0:
            return listTag[0]
        myStr = ','.join(x.tag for x in listTag)
        raise Exception("Unable to get {} in '{}'. Possible tags are : {}".format(type(self), str, myStr))
        return None

    def removeTag(self, str):
        return str.replace("_{}".format(self.tag.tag), "")

    def getTag(self):
        return self.tag.tag


# =================================================================================================
class Archi(ChoiceOf):
    CLASSICAL = "Classical"
    CLOUD_BTS = "CloudBTS"
    AIC_BTS = "AicBTS"
    TAG_ARCHI_CLASSICAL = Tag("5G", CLASSICAL)
    TAG_ARCHI_CLOUD_BTS = Tag("5GC", CLOUD_BTS)
    TAG_ARCHI_AIC_BTS = Tag("5GC_dR2.0", AIC_BTS)

    def getListTag(self):
        return [Tag("5G", Archi.CLASSICAL), Tag("5GC", Archi.CLOUD_BTS), Tag("5GD", Archi.AIC_BTS)]

    def isClassical(self):
        return self.tag == Archi.TAG_ARCHI_CLASSICAL

    def isCloudBts(self):
        return self.tag == Archi.TAG_ARCHI_CLOUD_BTS

    def isAic(self):
        return self.tag == Archi.TAG_ARCHI_AIC_BTS


# =================================================================================================
class GnbHw(ChoiceOf):
    def getListTag(self):
        return [Tag("BL", "ASIB/ABIL"), Tag("BLL", "ASIB/2ABIL"), Tag("BO", "ASIB/ABIO"),
                Tag("KL", "ASIK/ABIL"), Tag("BL", "ASIB/ABIL"), Tag("LO", "ASIL/ABIO"), Tag("O_E", "ASOE"),
                Tag("BOO", "ASIB/2ABIO"), Tag("LN", "ASIL/ABIN"), Tag("BN", "ASIB/ABIN"),
                Tag("MO", "ASIM/ABIO"), Tag("MP", "ASIM/ABIP"), Tag("LPP", "ASIL/2ABIP"), Tag("O_H", "ASOH")]


# =================================================================================================
class SimuHw(ChoiceOf):
    def getListTag(self):
        return [Tag("AP_KL", "Airphone ASIK/ABIL"), Tag("AP_BL", "Airphone ASIB/ABIL"),
                Tag("AP_LO", "Airphone ASIL/ABIO"), Tag("AP", "Airphone")]


# =================================================================================================
class Deployment(ChoiceOf):
    TAG_DEP_SA = Tag("SA", "Standalone")
    TAG_DEP_NSA = Tag("NSA", "Non-Standalone")
    TAG_DEP_SANSA = Tag("SANSA", "Standalone/Non-Standalone")

    def getListTag(self):
        return [Deployment.TAG_DEP_SA, Deployment.TAG_DEP_NSA, Deployment.TAG_DEP_SANSA]

    def isSANSA(self):
        return self.tag == Deployment.TAG_DEP_SANSA

    def isDeploySA(self):
        deploy = ""
        try:
            deploy = BuiltIn().get_variable_value("${deploy}")
        except Exception as e:
            deploy = "NSA"
        if self.tag == Deployment.TAG_DEP_SANSA:
            return deploy == Deployment.TAG_DEP_SA.tag
        return self.tag == Deployment.TAG_DEP_SA


# =================================================================================================
class L1(ChoiceOf):
    def getListTag(self):
        return [Tag("L1B", "L1ByPass"), Tag("FS", "Full-Stack")]


# =================================================================================================
class FH_Mode(ChoiceOf):
    def getListTag(self):
        return [Tag("CPRI"), Tag("ECPRI"), Tag("")]


# =================================================================================================
class RF_Mode(ChoiceOf):
    def getListTag(self):
        return [Tag("CMWV"), Tag("MMWV"), Tag("")]


# =================================================================================================
class Duplex(ChoiceOf):
    def getListTag(self):
        return [Tag("TDD"), Tag("FDD"), Tag("")]


# =================================================================================================
class Topology:
    TOPO_FILE_RELPATH = "testline_init_results/logs/INFO_log.txt"

    def __init__(self):
        self.gnbVersion = self.simuVersion = self.archi = self.gnbHw = self.simuHw = self.deployement = self.l1 = None
        self.FH_Mode = self.RF_Mode = self.duplex = None
        pass

    def set(self):
        self.isTopoFromVM = False
        self.topoStr = self.getTopoStr()
        if self.isTopoFromVM:
            self.readVersionFromVM()
        if len(self.topoStr) != 0:
            localTopoStr = self.topoStr
            self.archi = Archi(localTopoStr)
            # Searching for Simu HW BEFORE gnb HW since simu HW is not exclusive from
            # some occurences of gnb HW (ex: KL is included in AP_KL)
            self.simuHw = SimuHw(localTopoStr)
            localTopoStr = self.simuHw.removeTag(localTopoStr)
            self.gnbHw = GnbHw(localTopoStr)
            self.deployement = Deployment(localTopoStr)
            self.l1 = L1(localTopoStr)
            self.FH_Mode = FH_Mode(localTopoStr)
            self.RF_Mode = RF_Mode(localTopoStr)
            self.duplex = Duplex(localTopoStr)
        return self

    def __str__(self):
        return self.topoStr

    def getTopoStr(self):
        topoArg = BuiltIn().get_variable_value("${topo}")
        topoVM = self.readFieldFromTopoFile(field="LABEL:")
        if topoArg is None and topoVM is None:
            StringTool.datedConsole("WARNING:This is NOT a UTE VM (no {} file) AND topo argument were not set !"
                                    .format(Topology.TOPO_FILE_RELPATH))
            return ""
        if topoVM:
            self.isTopoFromVM = True
            return topoVM
        return topoArg

    def readFieldFromTopoFile(self, field):
        user = os.environ['USER']
        path = "/home/{}/{}".format(user, Topology.TOPO_FILE_RELPATH)
        if os.path.isfile(path):
            with open(path, "r") as f:
                while True:
                    line = f.readline()
                    if not line:
                        break
                    if field in line:
                        pos = line.index(field)+len(field)
                        return (line[pos:]).strip()
            f.close()
        return None

    def readVersionFromVM(self):
        self.gnbVersion = self.readFieldFromTopoFile(field="GNB BUILD:")
        self.simuVersion = self.readFieldFromTopoFile(field="AP BUILD:")

    def display(self):
        StringTool.printLineWithTitle("TOPOLOGY:[{}] (from VM:{})".format(self.topoStr, self.isTopoFromVM))
        StringTool.printHeaderLine("Archi", self.archi)
        StringTool.printHeaderLine("GnbHw", self.gnbHw)
        StringTool.printHeaderLine("SimuHw", self.simuHw)
        StringTool.printHeaderLine("Deployment", self.deployement)
        StringTool.printHeaderLine("L1", self.l1)
        StringTool.printHeaderLine("FH_Mode", self.FH_Mode)
        StringTool.printHeaderLine("RF_Mode", self.RF_Mode)
        StringTool.printHeaderLine("Duplex", self.duplex)
        StringTool.printHeaderLine("GNB Version", self.gnbVersion)
        StringTool.printHeaderLine("AP Version", self.simuVersion)

    def isSANSA(self):
        if self.deployement is None:
            return False
        return self.deployement.isSANSA()

    def isDeploySA(self):
        if self.deployement is None:
            return False
        return self.deployement.isDeploySA()

    def getSimuTag(self):
        if self.simuHw is None:
            return None
        return self.simuHw.getTag()
