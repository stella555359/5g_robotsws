from copy import deepcopy
import StringTool
import Connect
# import Enums
import enums
import Airscales
from ReadConfig import TLConfig
import re
from robot.libraries.BuiltIn import BuiltIn


class Kind(enums.MyEnum):
    CORE = 1
    CPRT = 2
    L1L2 = 3


# ===================================================================
# Class for Script Definition
# ===================================================================
class ScriptDef(object):
    DEF_REMOTE_PATH = "/ffs/run/config/scripts"
    ListScriptDef = []

    def __init__(self, names, cmd=None, remotePath=DEF_REMOTE_PATH, host=None, commonMirrorScript=False):
        self.host = host
        self.names = names
        self.remotePath = remotePath
        self.cmd = cmd
        if cmd is None:
            self.cmd = "{}/{}".format(remotePath, names[0])
        self.commonMirrorScript = commonMirrorScript

    @staticmethod
    def updateHosts():
        # Set all by default to Gnb Master
        for scriptDef in ScriptDef.ListScriptDef:
            scriptDef.host = Connect.GNB_DU().sys[0].M
        # Set specific AP scripts def
        MIRROR_AP_FS.host = Connect.AP_DU().sys[0].M
        MIRROR_AP_ASOE.host = Connect.AP_DU().sys[0].M

    @staticmethod
    def add(scriptDef):
        ScriptDef.ListScriptDef.append(scriptDef)
        return scriptDef

    @staticmethod
    def checkHosts():
        for scriptDef in ScriptDef.ListScriptDef:
            if scriptDef.host is None:
                error("Unexpected None host for ScriptDef with cmd [{}]".format(scriptDef.cmd))


# ===================================================================
# Class for Capture
# ===================================================================
class Capture(object):

    ListCapture = []

    def __init__(self, interface, prefix, host=None, node=None, scriptDef=None, filter=""):
        self.interface = interface
        self.prefix = prefix
        self.host = host
        self.node = node
        self.isNode = node is not None
        self.scriptDef = scriptDef
        self.isMirror = scriptDef is not None
        self.filter = filter
        self.withTN = False
        self.name = ""
        self.path = ""

    def __str__(self):
        hostStr = "Host="
        if self.host is not None:
            hostStr += "{:10}".format(self.host.alias)
        nodeStr = ""
        if self.isNode:
            nodeStr = " Node={}".format(self.node)
        scriptStr = ""
        if self.isMirror:
            scriptStr = " Script={}".format(self.scriptDef.names[0])
        filterStr = ""
        if len(self.filter) > 0:
            filterStr = " Filter={}".format(self.filter)
        return "{}Prefix={:40} IF={:10} {}{}{}{}".format(
            StringTool.PREFIX_DISPLAY, self.prefix, self.interface,
            hostStr, nodeStr, scriptStr, filterStr)

    @staticmethod
    def replaceRobotVar(filter):
        match = re.match(r".*\${(.*)}.*", filter)
        if match:
            exp = "${" + match.group(1) + "}"
            value = BuiltIn().get_variable_value(exp)
            filter = filter.replace(exp, value)
        return filter

    @staticmethod
    def updateHosts():
        # Set by default all Captures to Gnb Master
        for capture in Capture.ListCapture:
            capture.host = Connect.GNB_DU().sys[0].M
            capture.filter = Capture.replaceRobotVar(capture.filter)
        # Override with specific ones
        CAPTURE_CPRT_NODE.host = None
        CAPTURE_CORE_WTS_ETH3.host = Connect.HOST_EPCSIM
        apDUSysSlave = Connect.AP_DU().getSysSlaveHost()
        CAPTURE_CPRT_AP_SYS0_ETHA01.host = apDUSysSlave
        CAPTURE_L1L2_AP_L1B.host = apDUSysSlave
        CAPTURE_L1L2_AP_ASOE.host = apDUSysSlave
        CAPTURE_L1L2_AP_FS.host = Connect.AP_DU().bb[0].S

    @staticmethod
    def add(capture):
        Capture.ListCapture.append(capture)
        return capture

    @staticmethod
    def checkHosts():
        for capture in Capture.ListCapture:
            if capture.host is None and not capture.isNode:
                error("Unexpected None host for capture [{}]".format(capture.prefix))

    @staticmethod
    def displayAll():
        StringTool.printLineWithTitle("List of Captures")
        for capture in Capture.ListCapture:
            StringTool.datedConsole(capture)


# ===================================================================
# Script Definition
# ===================================================================
MIRROR_AP_FS = ScriptDef.add(ScriptDef(names=["apMirroring.sh"]))
MIRROR_GNB_FS_DEFAULT = \
    ScriptDef.add(ScriptDef(names=["gnbMirroring.sh", "gnbMirroringConfig.sh"], commonMirrorScript=True))
MIRROR_GNB_L1B_BO = ScriptDef.add(ScriptDef(names=["gnbMirroring_L1B_BO.sh"]))
MIRROR_GNB_L1B_LO = ScriptDef.add(ScriptDef(names=["gnbMirroring_L1B_LO.sh"]))
MIRROR_AP_ASOE = ScriptDef.add(ScriptDef(names=["apMirroringASOE.sh"]))
MIRROR_GNB_L1B_CLOUD = ScriptDef.add(ScriptDef(names=["gnbMirroring_L1B_CLOUD.sh"]))
# For multi ABIL
MIRROR_GNB_FS_BOO = ScriptDef.add(ScriptDef(names=["gnbMirroring_FS_BOO.sh"]))
MIRROR_GNB_L1B_BOO = ScriptDef.add(ScriptDef(names=["gnbMirroring_L1B_BOO.sh"]))
MIRROR_GNB_L1B_BOO_L2LO_L2HI = ScriptDef.add(ScriptDef(names=["gnbMirroring_L1B_BOO_L2LO_L2HI.sh"]))
# ===================================================================
# Capture Definition
# ===================================================================
# -----------------------------------
# CAPTURE for CORE
# -----------------------------------
CAPTURE_CORE_GNB_SYS0_FP0 = Capture.add(Capture(interface="fp0", prefix="CORE_GNB_SYS0_M_FP0"))
# Add of interface eth1 on WTS to support Cloud configuration
CAPTURE_CORE_WTS_ETH3 = Capture.add(Capture(interface="eth3", prefix="CORE_WTS_ETH3"))
# Add of interface BR1 to support ASIB
CAPTURE_CORE_GNB_SYS0_BR1 = Capture.add(Capture(interface="br1", prefix="CORE_GNB_SYS0_M_BR1"))
# Add of interface BR0 to support ASIL
CAPTURE_CORE_GNB_SYS0_BR0 = Capture.add(Capture(interface="br0", prefix="CORE_GNB_SYS0_M_BR0"))
# -----------------------------------
# CAPTURE for CPRT
# -----------------------------------
CAPTURE_CPRT_AP_SYS0_ETHA01 = Capture.add(Capture(interface="etha01", prefix="CPRT_AP_SYS0_S_ETHA01"))
CAPTURE_CPRT_NODE = Capture.add(Capture(interface="any", prefix="NODECPRT_GNB", node="CPRT"))
# -----------------------------------
# CAPTURE for BIP
# -----------------------------------
CAPTURE_L1L2_GNB_FS_KL = Capture.add(Capture(interface="pepbp1", prefix="L1L2_GNB_FS_KL",
                                             scriptDef=MIRROR_GNB_FS_DEFAULT))
CAPTURE_L1L2_GNB_FS_BL = Capture.add(Capture(interface="eths2", prefix="L1L2_GNB_FS_BL",
                                             scriptDef=MIRROR_GNB_FS_DEFAULT))
CAPTURE_L1L2_GNB_FS_LO = Capture.add(Capture(interface="nac_eth2", prefix="L1L2_GNB_FS_LO",
                                             scriptDef=MIRROR_GNB_FS_DEFAULT))
# FDD only
CAPTURE_L1L2_GNB_FS_BO = Capture.add(Capture(interface="eths3", prefix="L1L2_GNB_FS_BO",
                                             scriptDef=MIRROR_GNB_FS_DEFAULT))
CAPTURE_L1L2_GNB_FS_BN = Capture.add(Capture(interface="eths3", prefix="L1L2_GNB_FS_BN",
                                             scriptDef=MIRROR_GNB_FS_DEFAULT))
CAPTURE_L1L2_GNB_FS_BOO = Capture.add(Capture(interface="eths3", prefix="L1L2_GNB_FS_BOO",
                                              scriptDef=MIRROR_GNB_FS_BOO))

# TDD in l1 bypass due to restrictions
CAPTURE_L1L2_GNB_L1B_BOO = Capture.add(Capture(interface="eths2", prefix="L1L2_GNB_L1B_BOO",
                                               scriptDef=MIRROR_GNB_L1B_BOO))
CAPTURE_L1L2_GNB_L1B_BO = Capture.add(Capture(interface="eths2", prefix="L1L2_GNB_L1B_BO",
                                              scriptDef=MIRROR_GNB_L1B_BO,
                                              filter="\'${PREFIX_ETHER_BIP_MSG_TYPE_ASIB}<0xf000\'"))
CAPTURE_L1L2_GNB_L1B_LO = Capture.add(Capture(interface="nac_eth2", prefix="L1L2_GNB_L1B_LO",
                                              scriptDef=MIRROR_GNB_L1B_LO,
                                              filter="\'${PREFIX_ETHER_BIP_MSG_TYPE_ASIL}<0xf000\'"))
CAPTURE_L1L2_AP_FS = Capture.add(Capture(interface="ethbp1", prefix="L1L2_FS_AP", scriptDef=MIRROR_AP_FS))
CAPTURE_L1L2_AP_L1B = Capture.add(Capture(interface="etha01", prefix="L1L2_AP_L1B_LO"))
CAPTURE_L1L2_AP_ASOE = Capture.add(Capture(interface="etha01", prefix="L1L2_AP_ASOE",
                                           scriptDef=MIRROR_AP_ASOE))
CAPTURE_L1L2_GNB_L1B_CLOUD = Capture.add(Capture(interface="etha01", prefix="L2_GNB_CLOUD",
                                                 scriptDef=MIRROR_GNB_L1B_CLOUD))
# !!!! For all other L1Bypass configuration : but to be reworked, removed
MIRROR_GNB_L1B_CLASSICAL = ScriptDef.add(ScriptDef(names=["gnbMirroring.sh"], commonMirrorScript=True))
CAPTURE_L1L2_GNB_L1B_CLASSICAL = Capture.add(Capture(interface="etha01", prefix="L1L2_GNB_L1B_CLASSICAL",
                                                     scriptDef=MIRROR_GNB_L1B_CLASSICAL))
# Specific Captures
CAPTURE_L1L2_GNB_L1B_BOO_L2LO_L2HI = Capture.add(Capture(interface="eths2", prefix="L1L2_GNB_L1B_BOO_L2LO_L2HI",
                                                         scriptDef=MIRROR_GNB_L1B_BOO_L2LO_L2HI))


# ===================================================================
# Method to update Capture after setup
# ===================================================================

def error(msg):
    StringTool.datedConsole("ERROR:{}".format(msg))


def UpdateCapture():
    ScriptDef.updateHosts()
    ScriptDef.checkHosts()
    Capture.updateHosts()
    Capture.checkHosts()
    Capture.displayAll()


# ===================================================================
# Method to retrieve pertinent capture upon context
# ===================================================================
def traceAndCopy(kind, capture):
    StringTool.datedConsole("Selected {} capture:{}".format(kind, capture.prefix))
    return deepcopy(capture)


def copyCaptureCPRT(entity):
    return traceAndCopy(Kind.CPRT, CAPTURE_CPRT_NODE)


def copyCaptureL1L2(entity):
    kind = Kind.L1L2
    if entity is None:
        return None
    # AP Captures
    if entity.hw == enums.HW.AP:
        if TLConfig.isL1BP:
            return traceAndCopy(kind, CAPTURE_L1L2_AP_L1B)
        return traceAndCopy(kind, CAPTURE_L1L2_AP_FS)
    # GNB Captures
    else:
        # GNB ASOE
        if isinstance(entity, Airscales.AsoeRack):
            return traceAndCopy(kind, CAPTURE_L1L2_AP_ASOE)
        if TLConfig.isL1BP:
            # GNB L1PyPass
            if entity.profil == "BO" or entity.profil == "BOOO":
                # GNB L1BP BO
                return traceAndCopy(kind, CAPTURE_L1L2_GNB_L1B_BO)
            elif entity.profil == "LO" or entity.profil == "LOO" or entity.profil == "LOOO":
                # GNB L1BP LO
                return traceAndCopy(kind, CAPTURE_L1L2_GNB_L1B_LO)
            elif entity.profil == "BOO":
                # GNB L1BP BOO
                return traceAndCopy(kind, CAPTURE_L1L2_GNB_L1B_BOO)
            elif TLConfig.isGnbCloud:
                # GNB L1BP CLOUD
                return traceAndCopy(kind, CAPTURE_L1L2_GNB_L1B_CLOUD)
            # GNB L1BP CLASSICAL
            return traceAndCopy(kind, CAPTURE_L1L2_GNB_L1B_CLASSICAL)
        # GNB FS
        if entity.profil == "BN":
            # GNB FS BN
            return traceAndCopy(kind, CAPTURE_L1L2_GNB_FS_BN)
        elif entity.profil == "LO" or entity.profil == "LOO" or entity.profil == "LOOO":
            # GNB FS LO
            return traceAndCopy(kind, CAPTURE_L1L2_GNB_FS_LO)
        elif entity.profil == "BO" or entity.profil == "BOO" or entity.profil == "BOOO":
            # GNB FS BO
            return traceAndCopy(kind, CAPTURE_L1L2_GNB_FS_BO)
        elif entity.profil == "BL" or entity.profil == "BLL" or entity.profil == "BLLL":
            # GNB FS BL
            return traceAndCopy(kind, CAPTURE_L1L2_GNB_FS_BL)
        elif entity.profil == "KL" or entity.profil == "KLL" or entity.profil == "KLLL":
            # GNB FS KL
            return traceAndCopy(kind, CAPTURE_L1L2_GNB_FS_KL)
        # All other GNB FS cases
        return traceAndCopy(kind, CAPTURE_L1L2_GNB_FS_KL)


def copyCaptureCORE(entity):
    kind = Kind.CORE
    # No Capture for AP
    assert entity.hw == enums.HW.GNB, "No capture provided for AP for the moment"
    # GNB : Cloud
    if TLConfig.isGnbCloud:
        return traceAndCopy(kind, CAPTURE_CORE_WTS_ETH3)
    # GNB : Classical ASIB
    if entity.getSysBoardType() == "ASIB":
        return traceAndCopy(kind, CAPTURE_CORE_GNB_SYS0_BR1)
    # GNB : Classical ASOE or ASIL
    if isinstance(entity, Airscales.AsoeRack) or entity.getSysBoardType() == "ASIL":
        return traceAndCopy(kind, CAPTURE_CORE_GNB_SYS0_BR0)
    # GNB : Classical Other
    return traceAndCopy(kind, CAPTURE_CORE_GNB_SYS0_FP0)


def newCapture(interface, prefix, host=None, node=None, scriptDef=None, filter=""):
    return Capture(interface=interface, prefix=prefix, host=host, node=node, scriptDef=scriptDef, filter=filter)
