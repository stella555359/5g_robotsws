import StringTool
import re

LOG_NAME_L2RT_IPV6 = "ASP-124A_startup.log"


class Node:
    def __init__(self, name, host, id, nodeId=None, isContainer=True):
        self.name = name
        self.host = host
        self.id = id
        if nodeId is None:
            self.nodeId = id
        else:
            self.nodeId = nodeId
        self.isContainer = isContainer


# ==== NODE ===================================================================
def getNodeFromName(listNode, name):
    for node in listNode:
        if node.name == name:
            return node
    return None


def AddNodeToList(list, name, host, id, isContainer=True):
    node = Node(name, host, id, isContainer)
    list.append(node)
    return node


def NodesDisplay(listNode):
    StringTool.datedConsole("{}List of NODES:".format(StringTool.PREFIX_DISPLAY))
    for node in listNode:
        StringTool.datedConsole("{}  NODE:NAME={:10} HOST={:15} ID={:10} NodeId={}"
                                .format(StringTool.PREFIX_DISPLAY, node.name, node.host.alias, node.id, node.nodeId))


# ==== LOGS ===================================================================
def getLogFromName(listLog, name):
    for log in listLog:
        if log.name == name:
            return log
    return None


def AddLogDefToList(list, logDef):
    list.append(logDef)


def getNodeFromLogName(listNode, logName):
    nodeName = logName.split("_")[0]
    for node in listNode:
        if node.name == nodeName:
            return node
    return None


def LogsUpdateFromNode(listLog, listNode):
    for log in listLog:
        node = getNodeFromLogName(listNode, log.name)
        log.node = node
        # replace placeholders in log postfix
        # ADT - need to convert Id to upper case for L2RT log file
        log.postfix = log.postfix.replace("<NodeId>", "{}".format(node.nodeId.replace("0x", "").upper()))

        if log.name.startswith("L2RT") and not (log.isNodeUsed):
            log.postfix = LOG_NAME_L2RT_IPV6
        if not log.isNodeUsed:
            log.path = "{}/{}".format(log.prefix, log.postfix)
        if node is None:
            StringTool.datedConsole("ERROR:Unable to find node for LOG {}".format(log.name))

            return
        if log.isNodeUsed:
            log.path = "{}/node_{}{}".format(log.prefix, log.node.id, log.postfix)


def LogsDisplayDef(listLog):
    StringTool.datedConsole("{}List of LOGS definition:".format(StringTool.PREFIX_DISPLAY))
    for log in listLog:
        LogDisplayDef(log)


def LogDisplayDef(log):
    if log.node is None:
        str = "ERROR:No node found for this log"
    else:
        str = "NODE={:15} PATH={}".format(log.node.name, log.path)
    StringTool.datedConsole("{}  LOG :NAME={:10} {}"
                            .format(StringTool.PREFIX_DISPLAY, log.name, str))


# ===== CAPTURE ===============================================================
def getNodeFromCaptureNode(listNode, captureNode):
    if not isinstance(captureNode, str):
        return captureNode
    for node in listNode:
        if node.name == captureNode:
            return node
    return None


def getCaptureFromNodeName(listNode, nodeName):
    for node in listNode:
        if node.name == nodeName:
            return node.capture
    return None


# ===== NODE NAME ==============================================================
def getListNodeFromHost(str, host):
    ListNodeFromHost = []
    for line in str.split("\n"):
        match = re.match(r"l.* node_(0x[0-9a-fA-F]+) .*node_(\w*)$", line)
        if match:
            nodeId = match.group(1)
            id = match.group(2)
            name = re.sub(r"\d*$", "", id)
            node = Node(name=name, host=host, id=id, nodeId=nodeId, isContainer=True)
            ListNodeFromHost.append(node)
        else:
            # drwxr-xr-x 3 root root        60 Jun  4 22:21 node_0x124a
            match = re.match(r"d.* node_(0x[0-9a-fA-F]+)$", line)
            if match:
                nodeId = match.group(1)
                id = nodeId
                name = id
                node = Node(name=name, host=host, id=id, nodeId=nodeId, isContainer=False)
                ListNodeFromHost.append(node)
    return ListNodeFromHost


def getListNodeCloud(str, host):
    ListNodeFromHost = []
    for line in str.split("\n"):
        match = re.match(r"(.*-.*local).*", line)
        if match:
            id = match.group(1)
            match2 = re.match(r".*-(.*)-.*local", id)
            name = match2.group(1)
            node = Node(name=name, host=host, id=id, nodeId="N/A", isContainer=False)
            ListNodeFromHost.append(node)
    return ListNodeFromHost


# def getL2RTNameFromLs(str):
    # -rw-r--r--  1 root root    174589 Aug 27 21:03 ASP-124A_startup.zip
#    match = re.match(r".*ASP-(\d\d\d)A_startup.", str)
#    if match:
#        name = match.group(1)
#        return "ASP-{}A_startup.log".format(name)
#    return ""


# def addL2RTNode(str, host):
#    node = Node(name="L2PS", host=host, id="L2RT", nodeId="N/A", isContainer=False)
#    return node
