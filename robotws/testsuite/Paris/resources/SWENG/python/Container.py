import StringTool
import re
import six
import Connect
from ReadConfig import TLConfig
import Captures
# import os                                             # RF5.0 Update
# from time import sleep                                # RF5.0 Update

# List of nodes, those that will be dynamically dicovered
LIST_NODE = []
# List of Associated logs
LIST_LOG = []


# ==================================================================================================================
class Log(object):
    def __init__(self, id, host, dir, name):
        self.host = host                        # Reference of host embeding this log
        self.id = id                            # Unique Identifier of the log
        self.dir = dir                          # path to reach it
        self.name = name                        # Full name with extension (can be : .log, .zip, .log.xz, ...)
        self.rootName = name.split(".")[0]      # name without extension
        self.path = self.getPath()              # Updated full path with dir and full name
        self.ext = self.getExt()

    def getExt(self):
        self.ext = self.name.replace(self.rootName+".", "")
        return self.ext

    def getPath(self):
        self.path = "{}/{}".format(self.dir, self.name)
        return self.path

    def getHostStr(self):
        return "Host={}".format(self.host.alias)

    def __gt__(self, other):
        return self.id > other.id

    def __str__(self):
        return "{:31} Id={:17} Root={:18} Ext={:7} Path={}".format(
            self.getHostStr(), self.id, self.rootName, self.ext, self.path)

    def updateName(self):
        cmd = "cd {};ls -1 {}.*".format(self.dir, self.rootName)
        self.name = StringTool.getStringFromCmdReturn(self.host.cmd(cmd))
        if len(self.name) == 0:
            raise Exception("ERROR:Updating name of log {}:no file found matching {} in {}"
                            .format(self.id, self.rootName, self.dir))
        self.getExt()
        return self.getPath()


# ==================================================================================================================
class NodeLog(Log):
    def __init__(self, id, node, dir, name):
        super(NodeLog, self).__init__(id, node.host, dir, name)
        self.node = node
        self.log = None

    def getHostStr(self):
        return "GNB={} Node={}".format(self.node.airscale.prefix, self.node.id)

    @staticmethod
    def DisplayAll(listLog):
        StringTool.datedConsole("{}List of LOGS:".format(StringTool.PREFIX_DISPLAY))
        for log in listLog:
            StringTool.datedConsole("{}  LOG :{}".format(StringTool.PREFIX_DISPLAY, log))

    @staticmethod
    def getLogFromFile(node, dir, file):
        file = StringTool.getStringFromCmdReturn(file)
        # File without startup in name : we drop
        if "startup" not in file:
            return None
        # File with "<nodeId>_startup." in their name : special case for basic log
        if "{}_startup.".format(node.nodeId[2:].upper()) in file:
            return NodeLog(id=node.id, node=node, dir=dir, name=file)
        # extra check : we should have "startup_...
        if not file.startswith("startup_"):
            return None
        # File with "startup_<something like id>." in their name : nominale case for basic log
        postFix = (file.replace("startup_", "").split(".")[0].upper())
        if postFix.replace("_", "") in node.id:
            return NodeLog(id=node.id, node=node, dir=dir, name=file)
        return None

    @staticmethod
    def Discovery(listNode):
        list = []
        for node in listNode:
            node.log = None
            dir = "/tmp/node_{}/tmp".format(node.id)
            output = node.host.cmd('cd {};ls -1'.format(dir))
            for line in output.split("\n"):
                log = NodeLog.getLogFromFile(node, dir, line)
                if log is not None:
                    list.append(log)
                    node.log = log
        list.sort()
        return list


# ==================================================================================================================
class Node:
    STATE_OK = 3
    NODE_STATES = {"1": "STOPPED", "2": "STARTING", "3": "RUNNING", "4": "FAILED"}

    def __init__(self, airscale, name, host, id, nodeId=None, state=0):
        self.airscale = airscale
        self.name = name
        self.host = host
        self.id = id
        self.state = int(state)
        if nodeId is None:
            self.nodeId = id
        else:
            self.nodeId = nodeId
        self.log = None

    def __str__(self):
        return "GNB={} Name={:11} Host={:15} Id={:14} NodeId={:10} STATE={} ({})"\
            .format(self.airscale.prefix, self.name, self.host.alias, self.id,
                    self.nodeId, self.state, self.stateStr())

    def __gt__(self, other):
        return self.id > other.id

    def stateStr(self):
        return Node.NODE_STATES.get("{}".format(self.state), "UNDEFINED")

    def isStateOK(self):
        return self.state == Node.STATE_OK

    @staticmethod
    def DisplayAll(airscale, list):
        StringTool.datedConsole("{}List of NODES:".format(StringTool.PREFIX_DISPLAY))
        for node in list:
            StringTool.datedConsole("{}  NODE:{}".format(StringTool.PREFIX_DISPLAY, node))

    @staticmethod
    def getListNodeCloud(str, host):
        ListNodeFromHost = []
        for line in str.split("\n"):
            match = re.match(r"(.*-.*local).*", line)
            if match:
                id = match.group(1)
                match2 = re.match(r".*-(.*)-.*local", id)
                name = match2.group(1)
                node = Node(name=name, host=host, id=id, nodeId="N/A")
                ListNodeFromHost.append(node)
        return ListNodeFromHost

    @staticmethod
    def NodesDiscoveryFromController(oam):
        output = oam.cmd('arp -a | grep ".local"')
        StringTool.datedConsole("ARP Result:{}".format(output))
        listNodeHost = Node.getListNodeCloud(str=output, host=oam)
        for node in listNodeHost:
            LIST_NODE.append(node)

    @staticmethod
    def CheckAll(list):
        for node in list:
            if not node.isStateOK() and not TLConfig.isGnbCloud:
                StringTool.datedConsole("ERROR:Node {} not in Running state (was {})"
                                        .format(node.id, node.stateStr()))
                raise Exception("ERROR: Bas state for node {}".format(node.id))

    @staticmethod
    def Discovery(airscale):
        list = []
        StringTool.printLineWithTitle(title="Nodes Discovery({})".format(airscale.prefix))
        output = airscale.getSysMasterHost().cmd("chk lxc")
        started = False
        for line in output.split("\n"):
            if "duration" in line:
                started = False
            if started:
                # - 0x2011 Id:0x2510 State:3 TRACECM00   ............................ i
                match = re.match(r"^- 0x([0-9a-fA-F]+) Id:0x([0-9a-fA-F]+) State:(\d) (\w+) .*$", line.strip())
                if match:
                    hostId = "0x" + match.group(1)
                    nodeId = "0x" + match.group(2)
                    state = match.group(3)
                    id = match.group(4)
                    name = re.sub(r"\d*$", "", id)
                    host = airscale.getHostFromId(hostId)
                    if host is None:
                        raise Exception("Node discovery:Unable to retrieve host for HostId={}".format(hostId))
                    list.append(Node(airscale=airscale, name=name, host=host, id=id, nodeId=nodeId, state=state))
            if "status of lxc containers" in line:
                started = True
        if TLConfig.isGnbCloud:
            Node.NodesDiscoveryFromController(Connect.TGNB_CU().oam)
        list.sort()
        for node in list:
            node.capture = Captures.newCapture(interface="any", node=node.name, prefix="NODE_{}_GNB".
                                               format(node.name))
        return list


# ===== INTERNAL SERVICES ===============================================================
def getControlledEltFromList(name, list, cardIndex, pattern):
    if len(list) == 0:
        return None
    if len(list) <= cardIndex:
        raise Exception("Unable to retrieve {} {} with card index {}".format(pattern, name, cardIndex))
    return list[cardIndex]


# ===== EXTERNAL SERVICES ===============================================================
def ResetNodesAndLog():
    global LIST_NODE
    global LIST_LOG
    LIST_NODE = []
    LIST_LOG = []


def NodesAndLogDiscovery(airscale):
    global LIST_NODE
    global LIST_LOG
    listNode = Node.Discovery(airscale)
    Node.DisplayAll(airscale, listNode)
    LIST_NODE += listNode
    Node.CheckAll(listNode)
    listLog = NodeLog.Discovery(listNode)
    NodeLog.DisplayAll(listLog)
    LIST_LOG += listLog


def NodesDiscovery(airscale):
    global LIST_NODE
    LIST_NODE = []
    listNode = Node.Discovery(airscale)
    Node.DisplayAll(airscale, listNode)
    LIST_NODE += listNode


def getNodeMatching(name, airscale, cardIndex=0, capacityIndex=0):
    list = []
    StringTool.datedConsole("Start getNodeMatching:name={}".format(name))
    for node in LIST_NODE:
        if (node.name == name) and (int(node.id[-1]) == capacityIndex) and (airscale == node.airscale):
            list.append(node)
    return getControlledEltFromList(name, list, cardIndex, pattern="NODE")


def getLogMatching(name, airscale, cardIndex=0, capacityIndex=0):
    list = []
    for log in LIST_LOG:
        if (log.node.name == name) and (int(log.id[-1]) == capacityIndex) and (airscale == log.node.airscale):
            list.append(log)
    return getControlledEltFromList(name, list, cardIndex, pattern="LOG for NODE")


def getNodeFromCaptureNode(captureNode):
    if not isinstance(captureNode, str) and not isinstance(captureNode, six.string_types):
        return captureNode
    for node in LIST_NODE:
        if node.name == captureNode:
            return node


def getNodeStateStr(node, id, nodeId):
    if node is not None and node.id == id and node.nodeId == nodeId:
        return node.stateStr()
    return None
