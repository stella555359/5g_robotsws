import sys
import importlib
import re
import os
import robot
import OsTool
import StringTool
import GenerateReport
from robot.libraries.BuiltIn import BuiltIn
import Colors
from taf.config.testline.connection_details import SshServiceDetails, HttpConnectionDetails
from Version import SWENG_VERSION
from taf.config.testline import Simulator
import Topology

RELEASE_MAPPING_FILE = "ReleaseMapping.csv"
NOT_FOUND = "<NOT FOUND>"
NO_REL_STR = "NO_REL"
TLConfig = None
# if no init.py file is provided at robot command launch, we need to load a dummy one
NO_INIT_MODE = "DummyConfig"
REPO_NAME = "robotws5g"

global tl


def getConfigName():
    """
    Function to retrieve in list of loaded module the name of config module
    It should start with "<organisationCode>_<siteCode>_"
    For more details, see :
    https://confluence.int.net.nokia.com/pages/viewpage.action?spaceKey=UTE&title=00.+Official+UTE+Naming+Convention
    :return: name of config module
    """
    for key in list(sys.modules.keys()):
        match = re.match(r"^(\d)_(\d+)_", key)
        if match:
            return key.split(".")[0]
    # fake name for unit testing
    return NO_INIT_MODE


def toFormatLine(varname, name, val):
    return StringTool.getHeaderLine("CFG:{}.{}".format(varname, name), val)


# ============================================================================
# Var : variable (robot one or from __init__.py)
# ============================================================================
class Var(object):
    """
    Class to manipulate variables coming from robot command (-v ...)
    """
    ENB_BUILD_VAR = "ENB_BUILD"
    TOPO_VAR = "topo"
    AF_PATH_VAR = "AF_PATH"
    HIRE_A_SHERPA = "hire_a_sherpa"

    def __init__(self, name):
        self.name = name
        self._val = self.computeVal()

    def computeVal(self):
        val = NOT_FOUND
        try:
            robotName = "${"+"{}".format(self.name)+"}"
            val = BuiltIn().get_variable_value(robotName)
        except Exception as e:
            pass
        return val

    def set_val(self, new_val):
        self._val = new_val

    def get_val(self):
        return self._val

    def __str__(self):
        return self._val

    def toFullStr(self):
        return StringTool.getHeaderLine("VAR:{}".format(self.name), self._val)

    @staticmethod
    def printListVar(list):
        StringTool.printLineWithTitle("Variables from robot command")
        for var in list:
            StringTool.datedConsole(var.toFullStr())

    @staticmethod
    def getVarFromName(list, name):
        for var in list:
            if var.name == name:
                return var
        return None

    @staticmethod
    def checkMinimalSetting(list):
        afPath = Var.getVarFromName(list, Var.AF_PATH_VAR)._val
        enbBuild = Var.getVarFromName(list, Var.ENB_BUILD_VAR)._val
        if afPath is None and enbBuild is None and not OsTool.isDryRun():
            raise Exception("AF_PATH and ENB_BUILD arguments were empty. At least one of them is expected")


class DeployVar(Var):
    def __init__(self):
        super(DeployVar, self).__init__("deploy")
        if self._val is None or self._val == NOT_FOUND:
            self._val = "NSA"
        if self._val not in ["SA", "NSA", ""]:
            raise Exception("deploy argument should be one of : SA, NSA")


# ============================================================================
# Ue : User Equipement
# ============================================================================
class Ue(object):
    """
    Class to encapsulate some particular fields concerning a ue (extracted from tl.ues table)
    """
    def __init__(self, ue):
        self.ue_ref = ue
        self.type = type(ue).__name__
        self.isCloud = False
        if isinstance(ue, Simulator) or ue.airphone_cloud is None:
            self.oam_ssh_connection_details = ue.l1.common_units[0].lmp_connection
            self.oam_http_connection_details = SshServiceDetails(
                addr=self.oam_ssh_connection_details.addr,
                username="Nemuadmin", password="nemuuser")
        else:
            try:
                self.oam_ssh_connection_details = ue.airphone_cloud.oam_ssh_connection_details
                self.oam_http_connection_details = ue.airphone_cloud.oam_http_connection_details
                self.isCloud = (ue.l1.common_units[0].lmp_connection.addr !=
                                ue.airphone_cloud.oam_ssh_connection_details.addr)
            except Exception as e:
                pass


# ============================================================================
# Config : encapsulation of all variables conrcerning configuration of a TL
# ============================================================================
class Config(object):
    def __init__(self):
        # List of attributes
        #   configName    : name of config dir          (ex:7_20_CLASS5GPSECETL18_l1bypass)
        #   cm            : reference to config module
        #   isGnbCloud    : is GNB a cloud              (ex:true)
        #   release       : Release string
        # Get name of config module (7_...) and import it
        self.configName = getConfigName()
        if len(self.configName) == 0:
            raise Exception("Unable to retrieve configuration module starting with {}".format(Config.PrefixModule))
        self.cm = importlib.import_module(self.configName)
        self.setTlVar()
        self.airphone = None
        self.isL1BP = False
        # Check config directory is containing an __init__.py
        # match = re.match(r".*from '.*/(\d*_\d*_.*)/__init__.py(c|)'>$", "{}".format(self.cm))
        # if not match and not OsTool.isDryRun():
        #    raise Exception("Unable to retrieve test line name from config module {}".format(self.cm))
        # Compute Archi attribute (isGnbCloud : TO BE DEPRECATED)
        self.isGnbCloud = self.isGnbCloudCheck()
        self.archi = self.getArchi()
        # Build and update airphone
        self.ues = []
        for ue in self.cm.tl.ues:
            self.ues.append(Ue(ue))

    def setTlVar(self):
        # If no init.py file is provided as robot argument, we need to remap the tl var from dummy file
        # on global tl variable
        global tl
        if self.configName == NO_INIT_MODE:
            tl = self.cm.tl

    def setRelease(self, enbBuild):
        """
        Set release structure upon GNB version load (x.yyy.zzz)
        :param version: GNB version load (x.yyy.zzz)
        """
        self.release = enbBuild

    def getTL(self):
        """
        Return a reference to tl variable from __init__.py module
        """
        try:
            return self.cm.tl
        except Exception as e:
            raise Exception("No variable named 'tl' was found in {}".format(self.cm))
        return None

    def isGnbCloudCheck(self):
        return "CloudBts" in "{}".format(type(self.getTL().gnbs[0]))

    def getArchi(self):
        if "CloudBts" in "{}".format(type(self.getTL().gnbs[0])):
            return Topology.Archi.CLOUD_BTS
        if "VDU" in "{}".format(type(self.getTL().gnbs[0].dus[0])):
            return Topology.Archi.AIC_BTS
        return Topology.Archi.CLASSICAL

    def isGnbClassical(self):
        return "ClassicalBts" in "{}".format(type(self.getTL().gnbs[0]))

    def printConfig(self, varname):
        """
        print all variables of a Config variable
        :param varname: external name of variable of Config type
        """
        StringTool.printLineWithTitle("TL Configuration")
        # StringTool.datedConsole(toFormatLine(varname, "cm", self.cm))
        # StringTool.datedConsole(toFormatLine(varname, "configName", self.configName))
        StringTool.datedConsole(toFormatLine(varname, "isL1BP", self.isL1BP))
        StringTool.datedConsole(toFormatLine(varname, "isUTE", self.isUTE))
        # StringTool.datedConsole(toFormatCfgLine(varname, "topo", self.topo))
        StringTool.datedConsole(toFormatLine(varname, "isGnbCloud", self.isGnbCloud))
        StringTool.datedConsole(toFormatLine(varname, "archi", self.archi))
        for idx, ue in enumerate(self.ues):
            prefix = "ues[{}]".format(idx)
            StringTool.datedConsole(toFormatLine(varname, prefix + ".type", ue.type))
            StringTool.datedConsole(toFormatLine(varname, prefix + ".isCloud", ue.isCloud))

    def setTopo(self, topo):
        self.topo = topo

    def setVMType(self):
        tl = self.getTL()
        self.isUTE = True
        try:
            if tl.core is not None:
                self.isUTE = False
        except Exception as e:
            pass
        return self.isUTE


def printAllTheImported():
    print("\nAll Imported Modules\n")
    for key in list(sys.modules.keys()):
        StringTool.datedConsole(str(key))


def main():
    # ================================================================
    # MAIN
    # ================================================================
    global TLConfig
    TLConfig = Config()
    # Standalone variables (from robot command)
    global ListVar
    ListVar = [
        Var(Var.ENB_BUILD_VAR),
        Var(Var.AF_PATH_VAR),
        Var(Var.TOPO_VAR),
        DeployVar(),
        Var(Var.HIRE_A_SHERPA)
        ]

    # Get version (from robot variable) and inject it in TLConfig to retrieve Release
    TLConfig.setRelease(Var.getVarFromName(ListVar, Var.ENB_BUILD_VAR)._val)
    Var.checkMinimalSetting(ListVar)

    # Get topo from robot variable
    TLConfig.setTopo(Var.getVarFromName(ListVar, Var.TOPO_VAR)._val)

    # Set Core if not defined
    TLConfig.setVMType()

    # Display
    if OsTool.isRobotCmd():
        GenerateReport.generateReport(TLConfig)
        Var.printListVar(ListVar)
    return TLConfig


if __name__ == "__main__" or not OsTool.check_imported("resources.sites.NPS.SWENG.python.ReadConfig"):
    TLConfig = main()
