import re
import enum
import argparse
import StringTool
from ReadConfig import TLConfig
import Topology
from taf.config.testline.connection_details import (
    SshServiceDetails,
    OpenStackConnectionDetails,
    BmcConnectionDetails,
    HttpConnectionDetails,
)
from taf.transport.ssh import ssh


# ===============================================================================================
# Enum classes
# ===============================================================================================
class MyEnum(enum.Enum):
    def __str__(self):
        return self.name


class HW(MyEnum):
    GNB = 1
    AP = 2


class Unit(MyEnum):
    CU = 1
    DU = 2


# ===============================================================================================
# HOST
# ===============================================================================================
class Host(object):
    def __init__(self, alias, sshConnection, boardType=None, ip=None, sshId=None,
                 slot=None, proc=None, proxy=None, nodeId=None, card=None, kind=None, status=True):
        self.alias = alias
        self.sshConnection = sshConnection
        self.boardType = boardType
        self.ip = ip
        self.proxy = proxy
        self.hasProxy = proxy is not None
        self.sshId = sshId
        self.slot = slot
        self.proc = proc
        self.nodeId = nodeId
        self.card = card
        self.kind = kind
        self.status = status

    def __str__(self):
        if self.hasProxy:
            proxyStr = "Proxy={}".format(self.proxy.alias)
        else:
            proxyStr = "@={}".format(self.sshConnection.addr)
        return "Alias={:13} Kind={} Board={}  BSH(S:P)={}:{} SSH={:10} NodeId={:6} {:20} Status={}"\
            .format(self.alias, self.kind, self.boardType, self.slot, self.proc,
                    self.sshId, str(self.nodeId), proxyStr, self.status)

    def display(self, prefix=None):
        prefixStr = ""
        if prefix is not None:
            prefixStr = "{}.{:2}:".format(prefix, Card.ROLE_STR[int(self.proc)])
        StringTool.datedConsole("    {}{}".format(prefixStr, self))

    def setSshConnection(self, sshConnection):
        self.sshConnection = sshConnection

    def isReachable(self):
        try:
            csn = ssh()
            csn.connect_to(hostname=self.sshConnection.addr, username=self.sshConnection.username,
                           password=self.sshConnection.password, alias=self.alias)
            return True
        except Exception as e:
            return False

    def cmd(self, cmd):
        output = None
        try:
            csn = ssh()
            csn.connect_to(hostname=self.sshConnection.addr, username=self.sshConnection.username,
                           password=self.sshConnection.password, alias=self.alias)
            output = csn.execute(command=cmd, connection=self.alias)
            csn.disconnect(connection=self.alias)
        except Exception as e:
            StringTool.datedConsole("Unable to launch cmd [{}] on [{}]".format(cmd, self.sshConnection.addr))
        return output


# ===============================================================================================
# CARD
# ===============================================================================================
class Card(object):
    ROLE_STR = ["M", "S", "L1"]

    def __init__(self, name=None, master=None, slave=None, loner=None):
        self.name = name
        self.M = master
        self.S = slave
        self.L1 = loner

    def getVarName(self):
        if self.name[0] == "C":
            return "sys"
        return " bb"

    def addHost(self, host, prefixAlias):
        procNb = int(host.proc)
        host.alias = "{}_{}_{}".format(prefixAlias, self.name, Card.ROLE_STR[procNb])
        if procNb == 0:
            self.M = host
        elif procNb == 1:
            self.S = host
        elif procNb == 2:
            self.L1 = host

    def display(self, idx=None):
        StringTool.datedConsole("  Card:{}".format(self.name))
        prefix = None
        if idx is not None:
            prefix = "{}[{}]".format(self.getVarName(), idx)
        if self.M is not None:
            self.M.display(prefix=prefix)
        if self.S is not None:
            self.S.display(prefix=prefix)
        if self.L1 is not None:
            self.L1.display(prefix=prefix)


# ===============================================================================================
# Entity
# ===============================================================================================
class Entity(object):
    def __init__(self, hw, unit, oam):
        self.hw = hw
        self.unit = unit
        self.name = "{}_{}_{}".format(type(self).__name__, hw, unit)
        self.oam = oam
        if self.oam is not None:
            self.oam.setEntity(self)

    def __str__(self):
        return self.name

    def isGNB(self):
        return self.hw == HW.GNB

    def isUnitCU(self):
        return self.unit == Unit.CU

    def isUnitDU(self):
        return self.unit == Unit.DU


# ===============================================================================================
# Airscale and derivated
# ===============================================================================================
class Airscale(Entity):
    def __init__(self, hw, unit, oam, sysCardList=[], bbCardList=[]):
        super(Airscale, self).__init__(hw, unit, oam)
        self.sys = sysCardList
        self.bb = bbCardList
        self.updateEntryCards()

    def updateEntryCards(self):
        self.entryCard = []
        for sys in self.sys:
            self.entryCard.append(sys.M)

    def getCardFromName(self, proc):
        if proc.isSysCard():
            for sys in self.sys:
                if sys.name == proc.card:
                    return sys
            newCard = Card(name=proc.card)
            self.sys.append(newCard)
            return newCard
        else:
            for bb in self.bb:
                if bb.name == proc.card:
                    return bb
            newCard = Card(name=proc.card)
            self.bb.append(newCard)
            return newCard

    def getMasterCard(self):
        return self.sys[0]

    def getMasterHost(self):
        return self.getMasterCard().M

    def getPrefixAlias(self):
        return "{}_{}".format(self.hw, self.unit)

    def populateCards(self, procParser):
        self.sys = []
        self.bb = []
        proxy = None
        for proc in procParser.procs:
            card = self.getCardFromName(proc)
            host = proc.getHost(procParser=procParser, proxy=proxy)
            card.addHost(host, self.getPrefixAlias())
            if proxy is None:
                proxy = host
        self.updateEntryCards()

    def getActivePartition(self):
        part1 = StringTool.getStringFromCmdReturn(
            self.getMasterHost().cmd('uboot_env get active_partition | cut -d "=" -f2'))
        part2 = StringTool.getStringFromCmdReturn(
            self.getMasterHost().cmd("ls -al /ffs/ | grep run")).split("->")[1].strip()
        return "{} ({})".format(part1, part2)

    def display(self):
        StringTool.datedConsole("Airscale:{:22}   Chassis={}  DomainId={}  Partition={}".
                                format(self.name, self.slotNumber, self.domainId, self.getActivePartition()))
        for idx, sys in enumerate(self.sys):
            sys.display(idx=idx)
        for idx, bb in enumerate(self.bb):
            bb.display(idx=idx)


class AmiaRack(Airscale):
    pass


class AsoeRack(Airscale):
    def populateCards(self, procParser):
        super(AsoeRack, self).populateCards(procParser)
        self.addSlaveHost(slot="0", proc="1", nodeIdEnd="40")
        self.addSlaveHost(slot="0", proc="2", nodeIdEnd="50")

    def addSlaveHost(self, slot, proc, nodeIdEnd):
        masterHost = self.getMasterHost()
        masterCard = self.getMasterCard()
        nodeId = "{}{}".format(masterHost.nodeId[0:4], nodeIdEnd)
        alias, kind, status = ("tmp", "slave", "SwengAdd")
        host = Host(alias=alias, sshConnection=masterHost.sshConnection, boardType=masterHost.boardType, ip=None,
                    sshId=Proc.computeSshId(Proc.PREFIX_SSHID_SYS_HARD_CODED, self.domainId, slot, proc),
                    slot=slot, proc=proc, proxy=masterHost, nodeId=nodeId, card=masterCard.name,
                    kind=kind, status=status)
        masterCard.addHost(host, self.getPrefixAlias())


# ===============================================================================================
# Airsframe and derivated
# ===============================================================================================
class Airframe(Entity):
    pass


class AirframeOpenStack(Airframe):
    pass


class AirframeKubernetes(Airframe):
    pass


# ===============================================================================================
# Proc parser and Proc classes
# ===============================================================================================
class Proc(object):
    PREFIX_SSHID_SYS_HARD_CODED = "fct"
    PREFIX_SSHID_SYS = ""
    PREFIX_SSHID_BB = "fsp"

    def __init__(self, line):
        fields = line.split(" ")
        # - slave C1 ASIK [0x5021] lfs 0:1 ...................... ok
        # 0 1     2  3     4       5   6   ...
        self.kind = fields[1]
        self.card = fields[2]
        self.board = fields[3]
        self.nodeId = fields[4].replace("[", "").replace("]", "")
        self.slotProc = fields[6]
        self.slot, self.proc = self.slotProc.split(":")
        self.status = line.endswith("ok") or line.endswith(" i")

    def getHost(self, procParser, alias=None, proxy=None):
        return Host(alias=alias, sshConnection=procParser.sshConnection, boardType=self.board,
                    ip=None, sshId=self.sshId, slot=self.slot, proc=self.proc, proxy=proxy,
                    nodeId=self.nodeId, card=self.card, kind=self.kind, status=self.status)

    def isSysCard(self):
        return self.card[0] == "C"

    def getPrefix(self):
        if self.isSysCard():
            return Proc.PREFIX_SSHID_SYS
        return Proc.PREFIX_SSHID_BB

    def setSshId(self, domainId):
        self.sshId = Proc.computeSshId(self.getPrefix(), domainId, self.slot, self.proc)

    def __gt__(self, other):
        return self.slotProc > other.slotProc

    def __str__(self):
        return "Card:{} kind:{} Board:{} Slot:{} Proc:{} NodeId:{} SshId:{} Status:{}"\
            .format(self.card, self.kind, self.board, self.slot, self.proc, self.nodeId, self.sshId, self.status)

    @staticmethod
    def getDomainStr(domainId):
        if len(domainId) == 0:
            return ""
        return "-{}".format(domainId)

    @staticmethod
    def computeSshId(prefix, domainId, slot, proc):
        return "{}{}-{}{}".format(prefix, Proc.getDomainStr(domainId), slot, chr(97+int(proc)))


class ProcParser(object):
    def __init__(self, sshConnection):
        self.host = Host(alias="dummy", sshConnection=sshConnection)
        self.sshConnection = sshConnection
        self.procs = []
        for line in self.host.cmd("chk sysbsh").split("\n"):
            line = line.replace(".", "").replace("bsh -t 5", "").strip()
            line = ' '.join(line.split())
            if line.startswith("++"):
                sshId = re.match(r".*\[(.+?)\].*", line).group(1)
                Proc.PREFIX_SSHID_SYS = sshId.split("-")[0]
            if "- ctrll" in line or "- slave" in line:
                self.procs.append(Proc(line))
        self.procs.sort()
        self.domainId = getDomainId(self.host)
        domainIdForSsh = ""
        if self.procs[0].board != "ASIB":
            domainIdForSsh = self.domainId
        for proc in self.procs:
            proc.setSshId(domainIdForSsh)

    def display(self):
        for proc in self.procs:
            StringTool.datedConsole(proc)

    def getAirscale(self, hw=HW.GNB, unit=Unit.CU, oam=None):
        mainBoard = self.procs[0].board
        if mainBoard == "ASOE":
            airscale = AsoeRack(hw, unit, oam)
        else:
            airscale = AmiaRack(hw, unit, oam)
        airscale.domainId = self.domainId
        airscale.slotNumber = getSlotNumber(self.host)
        return airscale


# ===============================================================================================
# Global functions
# ===============================================================================================
def getAirscale(sshConnection, hw=HW.GNB, unit=Unit.CU, oam=None):
    procParser = ProcParser(sshConnection=sshConnection)
    airscale = procParser.getAirscale(hw=hw, unit=unit, oam=oam)
    airscale.populateCards(procParser)
    return airscale


def getDomainId(host):
    return StringTool.getStringFromCmdReturn(
        host.cmd("ddal -s ddal_sysinfo_module_get_domain_id 0 | grep dmid | cut -d= -f2"))


def getSlotNumber(host):
    return host.cmd("cat /proc/device-tree/soc-identity/chassis-slot-number")


# ===============================================================================================
# MAIN section
# ===============================================================================================
if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="", formatter_class=argparse.RawTextHelpFormatter)
    parser.add_argument("--ip",  help='IP adress', default="192.168.255.1")
    ip = parser.parse_args().ip
    StringTool.datedConsole("IP={}".format(ip))
    getAirscale(SshServiceDetails(addr=ip, username="toor4nsn", password="oZPS0POrRieRtu")).display()
