import sys
import importlib
import re
import OsTool
import StringTool
import EnvironmentManager
from robot.libraries.BuiltIn import BuiltIn
from taf.config.testline.connection_details import SshServiceDetails, HttpConnectionDetails
import Topology
import enum
import os
from taf.config.testline import Simulator

RELEASE_MAPPING_FILE = "ReleaseMapping.csv"
NOT_FOUND = "<NOT FOUND>"
NO_REL_STR = "NO_REL"
TLConfig = None
# if no init.py file is provided at robot command launch, we need to load a dummy one
NO_INIT_MODE = "DummyConfig"
REPO_NAME = "robotws"
AGENT_CTL_LOG_FILE = "/home/ute/testline_init_results/agent.log"
AGENT_SIM_LOG_FILE = "/home/ute/testline_init_results/logs/INFO_log.txt"
global tl


def add_wts_to_tl_variable(tl, edaemonPort='22222', egatePort='9880'):
    if os.path.exists(AGENT_CTL_LOG_FILE):
        # python object definition using type() to create a class dynamically
        tl.core = type("Core", (), {
            "default_ssh_connection_details": tl.test_pc.default_ssh_connection_details,
            # "default_ssh_connection_details": tl.test_pc[0].default_ssh_connection_details,
            "dir_path": "/opt/wts/latest",
            "cfg_filename": "basic_wts_step2.cfg",
            "port": "20000",
            "mme_ip": '',
            "edaemon_port": edaemonPort,
            "egate_port": egatePort
        })()
    elif os.path.exists(AGENT_SIM_LOG_FILE):
        # python object definition using type() to create a class dynamically
        tl.core = type("Core", (), {
            "default_ssh_connection_details": tl.test_pc.default_ssh_connection_details,
            # "default_ssh_connection_details": tl.test_pc[0].default_ssh_connection_details,
            "dir_path": "/opt/iphy/latest",
            "cfg_filename": "basic_wts_step2.cfg",
            "port": "20000",
            "mme_ip": '',
            "edaemon_port": edaemonPort,
            "egate_port": egatePort
        })()
    else:
        StringTool.datedConsole("ERROR: {} not found! ".format(AGENT_SIM_LOG_FILE))


def get_test_pctmp_attributes_as_list(test_pctmp):
    """
    Return a list of all attributes and their values for the given object.
    :param test_pctmp: The dynamically created object.
    :return: List of tuples (attribute, value).
    """
    return [(attr, getattr(test_pctmp, attr)) for attr in dir(test_pctmp) if not attr.startswith("__")]


def get_test_pctmp_attribute(test_pctmp, key):
    """
    Return the value of a specific attribute for the given key from the test_pctmp object.
    :param test_pctmp: The dynamically created object.
    :param key: The name of the attribute to retrieve.
    :return: The value of the attribute, or None if the attribute does not exist.
    """
    if hasattr(test_pctmp, key):
        return getattr(test_pctmp, key)
    else:
        StringTool.datedConsole(f"Attribute '{key}' not found in test_pctmp.")
        return None


def add_wts_to_tl_variable_mwts(tl, edaemonPort='22222', egatePort='9880', index=0):
    """
    Update the function to handle multiple TestPc objects in tl.test_pcs (new) or tl.test_pc (old)
    and initialize tl.core[index].
    This is a specific version for MWTS (Multi WTS -Wireless Test System-) entities.
    """
    # Initialize tl.core[index] for all indices
    if not isinstance(tl.core, dict):
        tl.core = {0: tl.core}  # Convert tl.core to a dictionary if not already

    # Handle both new and old testline config formats
    if hasattr(tl, "test_pcs"):
        test_pc_obj = tl.test_pcs[index]
    else:
        test_pc_obj = tl.test_pc[index] if isinstance(tl.test_pc, list) else tl.test_pc

    if os.path.exists(AGENT_CTL_LOG_FILE):
        tmp_path = "/opt/wts/latest"
    elif os.path.exists(AGENT_SIM_LOG_FILE):
        tmp_path = "/opt/iphy/latest"
    else:
        StringTool.datedConsole(f"NO PATH FOUND on core: {AGENT_SIM_LOG_FILE} or {AGENT_CTL_LOG_FILE} not found!")
        return

    test_pctmp = type("Core", (), {
        "default_ssh_connection_details": test_pc_obj.default_ssh_connection_details,
        "dir_path": f"{tmp_path}",
        "cfg_filename": "basic_wts_step2.cfg",
        "port": "20000",
        "mme_ip": '',
        "edaemon_port": edaemonPort,
        "egate_port": egatePort,
        "egate_console": None
    })()
    # Log the value of test_pctmp to the console
    StringTool.datedConsole(f"test_pctmp created in add_wts_to_tl_variable_mwts:  -----> {test_pctmp}")
    tl.core[index] = test_pctmp


def getConfigName():
    """
    Function to retrieve in list of loaded module the name of config module
    It should start with "<organisationCode>_<siteCode>_"
    For more details, see :
    https://confluence.int.net.nokia.com/pages/viewpage.action?spaceKey=UTE&title=00.+Official+UTE+Naming+Convention
    :return: name of config module
    """
    for key in list(sys.modules.keys()):
        match = re.match(r"^(\d+)_(\d+)_", key)
        if match:
            # RDH Aug-2022: MR refused due to PEP8 E275 error in this line:
            # return(key.split(".")[0])
            return key.split(".")[0]
    # fake name for unit testing
    return NO_INIT_MODE


def toFormatLine(varname, name, val):
    return StringTool.getHeaderLine("CFG:{}.{}".format(varname, name), val)


# ============================================================================
# Var : variable (robot one or from __init__.py)
# ============================================================================
class MyEnum(enum.Enum):
    def __str__(self):
        return self.name


class Var(object):
    """
    Class to manipulate variables coming from robot command (-v ...)
    """
    ENB_BUILD_VAR = "ENB_BUILD"
    TOPO_VAR = "topo"
    AF_PATH_VAR = "AF_PATH"
    HIRE_A_SHERPA = "hire_a_sherpa"
    SOS_REPORT = "sosReport"
    NO_PYTHON_UPDATE = "NO_PYTHON_UPDATE"

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


class ESharkTool(MyEnum):
    LUA_SHARK = "LUA_SHARK"
    MC_SHARK = "MC_SHARK"

    @staticmethod
    def isInList(str):
        for tool in ESharkTool:
            if tool == str or tool.name == str:
                return True
        return False

    @staticmethod
    def list():
        return [tool.name for tool in ESharkTool]


class SharkToolVar(Var):
    SHARK_TOOL_VAR = "SharkTool"

    def __init__(self):
        super(SharkToolVar, self).__init__(SharkToolVar.SHARK_TOOL_VAR)
        if self._val is None or self._val == NOT_FOUND:
            # 02-Aug-2022: As LUA_SHARK is definitly removed, MC_SHARK becomes the default tool
            # self._val = ESharkTool.LUA_SHARK
            self._val = ESharkTool.MC_SHARK
            BuiltIn().set_suite_variable("${SharkTool}", self._val)
        if not ESharkTool.isInList(self._val):
            raise Exception("{} is not a valid SharkTool argument. Should be one of :{}"
                            .format(self._val, ESharkTool.list()))


# ============================================================================
# Ue : User Equipment
# ============================================================================
class Ue(object):
    """
    Update the Ue class to handle multiple Airphone objects and their configurations.
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

        # Handle new fields in Airphone
        self.egate = getattr(ue, 'egate', None)
        # FTS checkup pas convaincu du besoin... cadre multi wts? a tester sans et a effacer
        # self.l2_ssh_connection_details = getattr(ue, 'l2_ssh_connection_details', None)
        # self.l3_ssh_connection_details = getattr(ue, 'l3_ssh_connection_details', None)


# ============================================================================
# Config : encapsulation of all variables concerning configuration of a TL
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
        self.isVranTl = self.isVranTl()
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

    def isVranTl(self):
        return "5GC_dRNIC" in "{}".format(self.cm.tl.tl_cloud_topology)

    def getArchi(self):
        # if "CloudBts" in "{}".format(type(self.getTL().gnbs[0])):
        #     return Topology.Archi.CLOUD_BTS
        if "VDU" in "{}".format(type(self.getTL().gnbs[0].dus[0])):
            return Topology.Archi.AIC_BTS
        # 2023.01.25 - VRAN NIC: lowercase used in __init__.py module - typo error or not - that's the question !
        if "vDU" in "{}".format(type(self.getTL().gnbs[0].dus[0])):
            return Topology.Archi.AIC_BTS
        return Topology.Archi.CLASSICAL

    def isGnbClassical(self):
        return "ClassicalBts" in "{}".format(type(self.getTL().gnbs[0]))

    def printConfig(self, varname="TLConfig"):
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
        StringTool.datedConsole(toFormatLine(varname, "isVranTl", self.isVranTl))
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

    def GetFhgwIp(self):
        try:
            fhgwIp = self.cm.FHGW_IP
        except Exception as e:
            fhgwIp = None
        return fhgwIp

    def GetFhgwUser(self):
        try:
            fhgwUser = self.cm.FHGW_User
        except Exception as e:
            fhgwUser = None
        return fhgwUser

    def GetFhgwPassword(self):
        try:
            fhgwPassword = self.cm.FHGW_Password
        except Exception as e:
            fhgwPassword = None
        return fhgwPassword

    def isVranTrunkRelease(self):
        """
        Check if the current build is a VRAN trunk load, currently branches = 22R3 and 22R4
        Function to be removed once current VRAN loads 22R3, 22R4 are not available anymore
        """
        print("isVranTrunkRelease: current load = {}".format(self.release))
        return (self.release.find("vDUCNF22R3") == -1) and (self.release.find("vDUCNF22R4") == -1)


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
        Var(Var.HIRE_A_SHERPA),
        Var(Var.SOS_REPORT),
        Var(Var.NO_PYTHON_UPDATE),
        SharkToolVar()
        ]

    # Get version (from robot variable) and inject it in TLConfig to retrieve Release
    TLConfig.setRelease(Var.getVarFromName(ListVar, Var.ENB_BUILD_VAR)._val)
    Var.checkMinimalSetting(ListVar)

    # Get topo from robot variable
    TLConfig.setTopo(Var.getVarFromName(ListVar, Var.TOPO_VAR)._val)

    # Set Core if not defined
    TLConfig.setVMType()

    # Get NO_PYTHON_UPDATE value and invert it for updateLibraries parameter
    # Default is True (update libraries), unless NO_PYTHON_UPDATE is set to True
    no_python_update_var = Var.getVarFromName(ListVar, Var.NO_PYTHON_UPDATE)
    no_python_update_val = no_python_update_var._val if no_python_update_var else NOT_FOUND

    # Convert Robot Framework ${true}/${false} to Python boolean
    # If NO_PYTHON_UPDATE is not found or is False/empty, then updateLibraries=True
    update_libraries = True
    if no_python_update_val and no_python_update_val != NOT_FOUND:
        if isinstance(no_python_update_val, bool):
            update_libraries = not no_python_update_val
        elif isinstance(no_python_update_val, str):
            # Handle Robot Framework string representations
            update_libraries = no_python_update_val.lower() not in ['true', '1', 'yes']

    # Display
    if OsTool.isRobotCmd():
        EnvironmentManager.reportTestEnvironment(TLConfig, updateLibraries=update_libraries)
        Var.printListVar(ListVar)
    return TLConfig


if __name__ == "__main__" or not OsTool.check_imported("resources.SWENG.python.ReadConfig"):
    TLConfig = main()
