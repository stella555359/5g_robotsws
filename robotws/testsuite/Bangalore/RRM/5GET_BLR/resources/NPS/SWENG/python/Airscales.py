from __future__ import absolute_import
import re
import StringTool
import Enums
import Card
import Hosts
import Entity
from taf.transport.ssh import ssh
try:
    import robot.api.logger as logging
except ImportError:
    import logging

csn = ssh()


def getNodeId(connection):
    """
    Compute node ID by executing ownid command on a host
    """
    result = csn.execute("sh /usr/bin/ownnid", connection=connection)
    return result.split('\r\n')[0]


def getAdetOutput(connection, nodeId='0x1011'):
    """
    Execute AdetS command for a particular node ID and return result
    :param connection: alias of concerned host
    :param nodeId: Id of the node (for instance : "0x1011" )
    :return: multi line string
    """
    csn.force_reconnect(connection=connection)
    portOption = "-p 15004"
    csn.send_command(
        "export PYTHONPATH=/opt/hwmt/python;"
        " python3 /opt/hwmt/python/hwapi/AdetS.py -s {} -n {} ".format(portOption, nodeId),
        connection=connection, timeout=300)
    output = csn.read_output(connection=connection)
    # csn.send_command("cp /opt/hwmt/python/hwapi/AdetS.py.ori /opt/hwmt/python/hwapi/AdetS.py")
    return output


def getAirscaleStatus(connection, nodeId='0x1011', *args):
    """
    Compute table of status for a list of root node id
    Example : Calling getAirscaleStatus(HOST_GNB_SYS_M, nodeId='0x1011', ['0x10', '0x12']
    will retrun something like : [ {'0x10' : "ready", '0x12' : "uninitialized' ]
    :param connection: alias of concerned host
    :param nodeId: precise node ID for AdetS command
    :param args: list of expected root node id
    :return: table of dictionary
    """
    output = getAdetOutput(connection, nodeId)
    airscaleStatus = {}
    if (output is None) or (len(output) < 10):
        for nID in args:
            airscaleStatus[nID] = "NOT EXIST"
    else:
        for nID in args:
            status = "NOT EXIST"
            if 'moduleInfoValid is FALSE' in output:
                status = "moduleInfoValid is FALSE"
            else:
                output = re.sub('.*Storing.*\n', '', output)
                try:
                    status = re.search(r'{}\s*\S*\s*\S*'.format(nID), output).group(0).split()[2][:-3]
                except (AttributeError, KeyError):
                    logging.warn("status for {} is NOT exist!".format(nID))
                    status = "NOT EXIST"
            airscaleStatus[nID] = status
    StringTool.console("getAirscaleStatus:{}".format(airscaleStatus))
    return airscaleStatus


def checkAirscaleStatus(connection, nodeId='0x1011', *args):
    """
    Check that a list of root Node ID are all ready
    :param connection: alias of concerned host
    :param nodeId: precise node ID for AdetS command
    :param args: ist of expected root node id
    :return: empty string if all nodes are ready, error message (list of non ready nodes) otherwise
    """
    statusList = getAirscaleStatus(connection, nodeId, *args)
    errorStr = ""
    for subNodeId in statusList:
        if statusList[subNodeId] == 'moduleInfoValid is FALSE':
            errorStr = "moduleInfoValid is FALSE"
            break
        elif statusList[subNodeId] != "ready":
            errorStr = "{}NodeID={} STATUS={}, ".format(errorStr, subNodeId, statusList[subNodeId])
    return errorStr


def get_l1_mode(tl_config):
    try:
        for idx, ue in enumerate(tl_config.ues):
            prefix = "ues[{}]".format(idx)
            ue_ssh_alias = "ue_ssh_alias_{}".format(idx)
            cmd = 'grep "<L1Bypass>" /ffs/run/simmode/iphy.xml'
            csn.connect_to(ue.oam_ssh_connection_details.addr,
                           username=ue.oam_ssh_connection_details.username,
                           password=ue.oam_ssh_connection_details.password,
                           alias=ue_ssh_alias,
                           timeout=3)
            logging.info("Retrieving L1Bypass property : {}".format(cmd))
            l1bypass_property = csn.execute(command=cmd, connection=ue_ssh_alias)
            csn.disconnect(connection=ue_ssh_alias)
            logging.info("L1Bypass property found : {}".format(l1bypass_property))
            tl_config.isL1BP = "true" in l1bypass_property
            # StringTool.datedConsole("Airphone......:{} TLConfig.isL1BP={}".
            #                         format(ue.oam_ssh_connection_details.addr, tl_config.isL1BP))
            # limit to first ue
            break
    except Exception as e:
        StringTool.console(e)


# ===============================================================================================
# Airscale and derivated
# ===============================================================================================
class Airscale(Entity.Entity):
    def __init__(self, hw, unit, index, oamSSH, oamHTTP, sysCardList=[], bbCardList=[]):
        super(Airscale, self).__init__(hw, unit, index, oamSSH, oamHTTP)
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
            newCard = Card.Card(name=proc.card)
            self.sys.append(newCard)
            return newCard
        else:
            for bb in self.bb:
                if bb.name == proc.card:
                    return bb
            newCard = Card.Card(name=proc.card)
            self.bb.append(newCard)
            return newCard

    def getMasterCard(self):
        if len(self.sys) > 0:
            return self.sys[0]
        return None

    def isSysSlave(self):
        if len(self.sys) > 0:
            return self.sys[0].S is not None
        return False

    def getSysMasterHost(self):
        master = self.getMasterCard()
        if master is not None:
            return master.M
        return None

    def getSysSlaveHost(self):
        master = self.getMasterCard()
        if master is not None:
            return master.S
        return None

    def getBBCard(self, index=0):
        if len(self.bb) > index:
            return self.bb[index]
        return None

    def getPrefixAlias(self):
        # return "{}_{}".format(self.hw, self.unit)
        return self.prefix.replace("[", "").replace("]", "")

    def getBBBoardType(self, index=0):
        if len(self.bb) > index:
            return self.bb[index].M.boardType
        return None

    def getSysBoardType(self, index=0):
        if len(self.sys) > index:
            return self.sys[index].M.boardType
        return None

    def getHostInListFromId(self, list, nodeId):
        for card in list:
            host = card.getHostFromId(nodeId)
            if host is not None:
                return host
        return None

    def getHostFromId(self, nodeId):
        host = self.getHostInListFromId(self.sys, nodeId)
        if host is None:
            host = self.getHostInListFromId(self.bb, nodeId)
        return host

    def getProfil(self):
        BB = ""
        for elem in self.bb:
            last = elem.M.boardType[-1]
            BB = BB + last
        return "{}{}".format(self.getSysBoardType()[-1], BB)

    def populateCards(self, procParser):
        self.sys = []
        self.bb = []
        # proxy = None
        proxy = procParser.rootHost
        for proc in procParser.procs:
            card = self.getCardFromName(proc)
            host = proc.getHost(procParser=procParser, proxy=proxy)
            card.addHost(host, self.getPrefixAlias())
            if proxy == procParser.rootHost:
                proxy = host
        self.updateEntryCards()

    def getActivePartition(self):
        part1 = StringTool.getStringFromCmdReturn(
            self.getSysMasterHost().cmd('uboot_env get active_partition | cut -d "=" -f2'))
        part2 = StringTool.getStringFromCmdReturn(
            self.getSysMasterHost().cmd("ls -al /ffs/ | grep run")).split("->")[1].strip()
        return "{} ({})".format(part1, part2)

    def finalizeSetting(self):
        # Take 4 first chars of host : 0x2022 => 0x20
        self.listNodeId = [self.sys[0].M.nodeId[0:4]]
        for bb in self.bb:
            self.listNodeId.append(bb.M.nodeId[0:4])
        # Update profil upon cards
        self.profil = self.getProfil()

    def check(self):
        isOK = True
        for idx, sys in enumerate(self.sys):
            isOK = isOK and sys.isOK()
        for idx, bb in enumerate(self.bb):
            isOK = isOK and bb.isOK()
        if not isOK:
            StringTool.prefixDatedConsole("WARNING:Airscale {} not ready".format(self))
        return isOK

    def display(self):
        self.separationLine()
        strName = "{} ({})".format(self.name, self.profil)
        StringTool.prefixDatedConsole("{:10}:{:24} Chassis={}  DomainId={}  Partition={}      ListNodeId={}".
                                      format(self.prefix, strName, self.slotNumber, self.domainId,
                                             self.getActivePartition(), self.listNodeId))
        for idx, sys in enumerate(self.sys):
            sys.display(idx=idx)
        for idx, bb in enumerate(self.bb):
            bb.display(idx=idx)
        return self.check()


class AmiaRack(Airscale):
    def getSysSlaveHost(self):
        mc = self.getMasterCard()
        if mc.M.boardType in ["ASIB", "ASIL", "ASIM"]:
            return mc.M
        return mc.S


class AsoeRack(Airscale):
    def getSysSlaveHost(self):
        return self.getMasterCard().M

    def getProfil(self):
        return "ASOE"

    def populateCards(self, procParser):
        super(AsoeRack, self).populateCards(procParser)
        self.addSlaveHost(slot="0", proc="1", nodeIdEnd="40")
        self.addSlaveHost(slot="0", proc="2", nodeIdEnd="50")

    def addSlaveHost(self, slot, proc, nodeIdEnd):
        masterHost = self.getSysMasterHost()
        masterCard = self.getMasterCard()
        nodeId = "{}{}".format(masterHost.nodeId[0:4], nodeIdEnd)
        alias, kind, status = ("tmp", "slave", "SwengAdd")
        host = Hosts.Host(alias=alias, sshConnection=masterHost.sshConnection, boardType=masterHost.boardType, ip=None,
                          sshId=Proc.computeSshId(Proc.PREFIX_SSHID_SYS_HARD_CODED, self.domainId, slot, proc),
                          slot=slot, proc=proc, proxy=masterHost, nodeId=nodeId, card=masterCard.name,
                          kind=kind, status=status)
        masterCard.addHost(host, self.getPrefixAlias())


class AsohRack(Airscale):
    def getSysSlaveHost(self):
        return self.getMasterCard().M

    def getProfil(self):
        return "ASOH"

    def populateCards(self, procParser):
        super(AsohRack, self).populateCards(procParser)
        self.addSlaveHost(slot="0", proc="1", nodeIdEnd="40")   # comment trouver les bonnes valeurs ?
        self.addSlaveHost(slot="0", proc="2", nodeIdEnd="50")   # comment trouver les bonnes valeurs ?

    def addSlaveHost(self, slot, proc, nodeIdEnd):
        masterHost = self.getSysMasterHost()
        masterCard = self.getMasterCard()
        nodeId = "{}{}".format(masterHost.nodeId[0:4], nodeIdEnd)
        alias, kind, status = ("tmp", "slave", "SwengAdd")
        host = Hosts.Host(alias=alias, sshConnection=masterHost.sshConnection, boardType=masterHost.boardType, ip=None,
                          sshId=Proc.computeSshId(Proc.PREFIX_SSHID_SYS_HARD_CODED, self.domainId, slot, proc),
                          slot=slot, proc=proc, proxy=masterHost, nodeId=nodeId, card=masterCard.name,
                          kind=kind, status=status)
        masterCard.addHost(host, self.getPrefixAlias())


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
        return Hosts.Host(alias=alias, sshConnection=procParser.sshConnection, boardType=self.board,
                          ip=None, sshId=self.sshId, slot=self.slot, proc=self.proc, proxy=proxy,
                          nodeId=self.nodeId, card=self.card, kind=self.kind, status=self.status)

    def isSysCard(self):
        return self.card[0] == "C"

    def getPrefix(self):
        if self.isSysCard():
            return Proc.PREFIX_SSHID_SYS
        return Proc.PREFIX_SSHID_BB

    def setSshId(self, domainId, slotNumber):
        self.sshId = Proc.computeSshId(prefix=self.getPrefix(), domainId=domainId,
                                       slot=Proc.getSlotUponChassis(self.slot, slotNumber),
                                       proc=self.proc)

    def __gt__(self, other):
        return self.slotProc > other.slotProc

    def __str__(self):
        return "Card:{} kind:{} Board:{} Slot:{} Proc:{} NodeId:{} SshId:{} Status:{}"\
            .format(self.card, self.kind, self.board, self.slot, self.proc, self.nodeId, self.sshId, self.status)

    @staticmethod
    def getSlotUponChassis(slot, chassis):
        return int(slot) + int(chassis)

    @staticmethod
    def getDomainStr(domainId):
        if len(domainId) == 0:
            return ""
        return "-{}".format(domainId)

    @staticmethod
    def computeSshId(prefix, domainId, slot, proc):
        return "{}{}-{}{}".format(prefix, Proc.getDomainStr(domainId), slot, chr(97+int(proc)))


class ProcParser(object):
    def __init__(self, sshConnection, rootHost=None):
        host = Hosts.Host(alias="dummy", sshConnection=sshConnection, proxy=rootHost)
        self.rootHost = rootHost
        self.sshConnection = sshConnection
        self.procs = []
        self.slotNumber = getSlotNumber(host)
        self.domainId = getDomainId(host)
        for line in host.cmd("chk sysbsh").split("\n"):
            # StringTool.datedConsole("LINE={}".format(line))
            line = line.replace(".", "").replace("bsh -t 5", "").strip()
            line = ' '.join(line.split())
            if line.startswith("++"):
                sshId = re.match(r".*\[(.+?)\].*", line).group(1)
                Proc.PREFIX_SSHID_SYS = sshId.split("-")[0]
            if "- ctrll" in line or "- slave" in line:
                self.procs.append(Proc(line))
        self.procs.sort()
        domainIdForSsh = ""
        if self.procs[0].board != "ASIB":
            domainIdForSsh = self.domainId
        for proc in self.procs:
            proc.setSshId(domainIdForSsh, self.slotNumber)

    def display(self):
        for proc in self.procs:
            StringTool.datedConsole(proc)

    def getAirscale(self, hw=Enums.HW.GNB, unit=Enums.Unit.CU, index=0, oamSSH=None, oamHTTP=None):
        mainBoard = self.procs[0].board
        if mainBoard == "ASOE":
            airscale = AsoeRack(hw=hw, unit=unit, index=index, oamSSH=oamSSH, oamHTTP=oamHTTP)
        elif mainBoard == "ASOH":
            airscale = AsohRack(hw=hw, unit=unit, index=index, oamSSH=oamSSH, oamHTTP=oamHTTP)
        else:
            airscale = AmiaRack(hw=hw, unit=unit, index=index, oamSSH=oamSSH, oamHTTP=oamHTTP)
        airscale.domainId = self.domainId
        airscale.slotNumber = self.slotNumber
        return airscale


# ===============================================================================================
# Global functions
# ===============================================================================================
def getDomainId(host):
    return StringTool.getStringFromCmdReturn(
        host.cmd("ddal -s ddal_sysinfo_module_get_domain_id 0 | grep dmid | cut -d= -f2"))


def getSlotNumber(host):
    return host.cmd("cat /proc/device-tree/soc-identity/chassis-slot-number")[0]


def getAirscale(sshConnection, rootHost=None, hw=Enums.HW.GNB, unit=Enums.Unit.CU, index=0, oamSSH=None, oamHTTP=None):
    procParser = ProcParser(sshConnection=sshConnection, rootHost=rootHost)
    airscale = procParser.getAirscale(hw=hw, unit=unit, index=index, oamSSH=oamSSH, oamHTTP=oamHTTP)
    airscale.populateCards(procParser=procParser)
    airscale.finalizeSetting()
    return airscale
