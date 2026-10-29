import copy
import os
import StringTool
import OsTool
import Debug
from taf.transport.ssh import ssh
from taf.config.testline.connection_details import K8SConnectionDetails

REMOTE_CMD_EXEC_PATH = "/tools/Misc/ExecCmdOnRemoteSvr.py"


# =================================================================================================
# STATE : to manage state and perform diagnosis
# =================================================================================================
class State(object):
    def __init__(self, value, oks, warns=[]):
        self.value = value
        self.oks = oks
        self.warns = warns

    def isWarn(self):
        for warn in self.warns:
            if self.value == warn:
                return True
        return False

    def isKO(self):
        for ok in self.oks:
            if self.value == ok:
                return False
        if self.isWarn():
            return False
        return True

    def isOK(self):
        return not self.isKO() and not self.isWarn()

    def diagToStr(self):
        if self.isKO():
            return "KO  "
        elif self.isWarn():
            return "WARN"
        return "OK  "

    def __str__(self):
        return f"{self.diagToStr()} ({self.value})"

    def fullDiag(self, header):
        return f"{header:90}:State={self.value:10}"


# =================================================================================================
# K8sNode : to manage Kubernetes nodes and connection
# =================================================================================================
class K8sNode(StringTool.ObjWithErrors):
    LEVEL = 1
    STATE_OK = ["Ready"]
    MASTER_ROLE = "master"
    WORKER_ROLE = "worker"
    CMD = "CMD"
    RES = "RES"
    PREFIX = "kubectl"
    GLOBAL_DEBUG_CMD = Debug.DebugSettings.getSetting("K8sNode_DEBUG_CMD")
    GLOBAL_DEBUG_RES = Debug.DebugSettings.getSetting("K8sNode_DEBUG_RES")
    CAPTURE_SCRIPT_PATH = os.path.dirname(os.path.abspath(__file__))
    CAPTURE_SCRIPT_PATH = os.path.dirname(CAPTURE_SCRIPT_PATH) + REMOTE_CMD_EXEC_PATH

    def __init__(self, k8s, prefix, name=None):
        super(K8sNode, self).__init__()
        # prefix is used for aliases
        self.k8s = k8s
        self.name = name
        self.prefix = prefix
        if name is not None:
            self.prefix = f"{prefix}_{name}"
        self.aliasK8s = f"{self.prefix}_K8S"
        self.aliasSsh = f"{self.prefix}_SSH"
        # state and roles will be computed with 'get nodes' command
        self.state = None
        self.roles = None
        self.proxy = None

    def updateStatusAndRoles(self, state, roles, mainNode):
        self.isMaster = K8sNode.MASTER_ROLE in roles
        self.isWorker = K8sNode.WORKER_ROLE in roles
        self.state = State(state, K8sNode.STATE_OK)
        self.addErrorUponState(self.state, f"K8sNode {self.name}")
        # If node is worker ONLY, store the main node for connection by proxy
        if not self.isMaster:
            self.proxy = mainNode

    def __lt__(self, other):
        return self.k8s.master_node.ssh_connection_details.addr < other.k8s.master_node.ssh_connection_details.addr

    def getNs(self):
        return self.k8s.namespace

    def getK8s(self):
        return self.k8s.master_node.k8s_connection_details

    def getSsh(self):
        return self.k8s.master_node.ssh_connection_details

    def getAddrAndAliasFromConnection(self, connection):
        if isinstance(connection, K8SConnectionDetails):
            return (connection.ip_addr, self.aliasK8s)
        else:
            return (connection.addr, self.aliasSsh)

    def getK8sStr(self):
        return f"{self.getK8s().username}@{self.getK8s().ip_addr}:{self.getK8s().port}"

    def getSshStr(self):
        return f"{self.getSsh().username}@{self.getSsh().addr}"

    def getK8sCmd(self):
        return (f"{K8sNode.CAPTURE_SCRIPT_PATH} -destIp {self.getK8s().ip_addr} "
                f"-destLogin {self.getK8s().username} -destPassword {self.getK8s().password} -destCmd")

    def getSshCmd(self):
        if self.proxy is not None:
            proxyCon = self.proxy.getK8s()
            (proxyIp, proxyAlias) = self.proxy.getAddrAndAliasFromConnection(proxyCon)
            login = proxyCon.username
            password = proxyCon.password
            cmd = (f"{K8sNode.CAPTURE_SCRIPT_PATH} -proxyIp {proxyIp} -proxyLogin {login} "
                   f"-proxyPassword {password} -destIp {self.getSsh().addr} "
                   f"-destLogin {self.getSsh().username} -destPassword {self.getSsh().password} -destCmd")
        else:
            cmd = (f"{K8sNode.CAPTURE_SCRIPT_PATH} -destIp {self.getSsh().addr} "
                   f"-destLogin {self.getSsh().username} -destPassword {self.getSsh().password} -destCmd")
        return cmd

    def toRoleStr(self):
        roleStr = ""
        if self.isMaster:
            roleStr += "M"
        if self.isWorker:
            roleStr += "W"
        return roleStr

    def __str__(self):
        return (f"IP={self.k8s.master_node.ssh_connection_details.addr:16} Name={self.name:20} "
                f"NS={self.getNs():14} Role={self.toRoleStr():15} State={self.state}")

    def display(self):
        StringTool.displayHeader(K8sNode.LEVEL, self)
        # StringTool.displayHeader(K8sNode.LEVEL+1, "IP={:60} Pass={:15} Alias={}".format(
        #    self.getK8sStr(), self.getK8s().password, self.aliasK8s), title="K8S")
        # StringTool.displayHeader(K8sNode.LEVEL+1, "IP={:60} Pass={:15} Alias={}".format(
        #    self.getSshStr(), self.getSsh().password, self.aliasSsh), title="SSH")

    def displayAsMain(self):
        StringTool.displayHeader(K8sNode.LEVEL, f"Name={self.name}", title="MainNode")

    def debug(self, kind, str, debug=False):
        if debug or (K8sNode.GLOBAL_DEBUG_CMD and kind == K8sNode.CMD) \
                or (K8sNode.GLOBAL_DEBUG_RES and kind == K8sNode.RES):
            postfix = ""
            if kind == K8sNode.RES:
                postfix = "\n"
            StringTool.datedConsole(f"[{self.name}]SSH:{kind}={postfix}{str}")

    def connect(self, connection):
        csn = ssh()
        addr = alias = None
        try:
            (addr, alias) = self.getAddrAndAliasFromConnection(connection)
            if self.proxy is None:
                csn.connect_to(hostname=addr, username=connection.username, password=connection.password, alias=alias)
            else:
                proxyCon = self.proxy.getK8s()
                (proxyAddr, proxyAlias) = self.proxy.getAddrAndAliasFromConnection(proxyCon)
                csn.connect_to(hostname=proxyAddr, username=proxyCon.username,
                               password=proxyCon.password, alias=proxyAlias)
                csn.connect_to(hostname=addr, username=connection.username,
                               password=connection.password, proxy=proxyAlias, alias=alias)
        except Exception as e:
            StringTool.datedConsole(f"Unable to connect to {connection.username}@{addr} "
                                    f"({connection.password}) (alias={alias})")
        return csn, alias

    def cmd(self, connection, cmd, isSendCommand=False, debug=False):
        output = alias = None
        self.debug(K8sNode.CMD, cmd, debug)
        try:
            (csn, alias) = self.connect(connection)
            if isSendCommand:
                output = csn.send_command(command=cmd, connection=alias)
            else:
                output = csn.execute(command=cmd, connection=alias)
            csn.disconnect(connection=alias)
            self.debug(K8sNode.RES, output, debug)
        except Exception as e:
            StringTool.datedConsole(f"Unable to launch cmd [{cmd}] on [{alias}]")
        return output

    def downloadFile(self, remotePath, localPath, debug=False):
        if debug:
            StringTool.datedConsole(f"K8sNode:Download [{remotePath}] to [{localPath}]")
        try:
            (csn, alias) = self.connect(self.getSsh())
            csn.download_file(remote_path=remotePath, local_path=localPath, connection=alias)
            csn.disconnect(connection=alias)
        except Exception as e:
            StringTool.datedConsole(f"Unable to download [{remotePath}] on [{alias}]")

    @staticmethod
    def cmdToK8sCmd(cmd):
        return f"{K8sNode.PREFIX} {cmd}"

    def k8sCmd(self, cmd, isSendCommand=False, debug=False):
        return self.cmd(connection=self.getK8s(), cmd=K8sNode.cmdToK8sCmd(cmd),
                        isSendCommand=isSendCommand, debug=debug)

    def sshCmd(self, cmd, isSendCommand=False, debug=False):
        return self.cmd(connection=self.getSsh(), cmd=cmd, isSendCommand=isSendCommand, debug=debug)

    def getTableFromK8sCmd(self, cmd, fieldNames, debug=False):
        """
        launch a kubernetes command and parse the result to build a table of dictionary containing values
        for input field names
        Command is supposed to have a result formatted as a table with a header and fields tabulated
        :param cmd: kubernetes command to execute
        :param fieldNames: list of fields to retrieve
        :return: list of dictionary of fields
        """
        lines = self.k8sCmd(cmd, debug).split("\n")                # retrieves lines from command execution
        fields = StringTool.reduceSpaces(lines.pop(0)).split(" ")  # Extract fields from header (first line)
        mapPos = {}
        for fieldName in fieldNames:                               # associate position to each field
            mapPos[fieldName] = fields.index(fieldName)
        list = []
        for line in lines:                                         # parse all lines (header was pop previously)
            if len(line) == 0:                                     # ignore empty lines
                continue
            fields = StringTool.reduceSpaces(line).split(" ")      # get fields from current line
            dict = {}                                              # build dictionary of field for current line
            for fieldName in fieldNames:
                dict[fieldName] = fields[mapPos[fieldName]]        # add in dictionary value of field
            list.append(dict)                                      # add dictionary in list
        return list                                                # return the list of dictionaries

    def getListAttrByObjFromK8sCmd(self, cmd, fieldNames, debug=False):
        """
        Launch a kubernetes command and parse result to build a table of dictionary containing values
        Command is supposed to have a result as:
        ...
        <name>:
          <field>:<value>
          ...
        Example :
          ctr-cran1-nwmgmt:
            Container ID:   cri-o://48c03892a18495e19164a5a5bf19e6edfdb5979f6a880abc2ba666e2c83ad157
            Host Port:      <none>
            State:          Running
        The line with a key but no value is supposed to be mapped onto the <NAME> field
        """
        lines = self.k8sCmd(cmd, debug).split("\n")
        elts = []
        name = None
        for line in lines:
            (key, value) = StringTool.getKeyValueFromLine(line, ":")
            if value is None:
                if name is not None:
                    elts.append(dict)
                name = key
                dict = {}
                dict['NAME'] = name
            else:
                for fieldName in fieldNames:
                    if key == fieldName:
                        if name is not None:
                            dict[key] = value.strip()
        if name is not None:
            elts.append(dict)
        return elts

    def getListAttrFromK8sCmd(self, cmd, fieldNames, debug=False):
        """
        Launch a kubernetes command and parse result to build a table of dictionary containing values
        Command is supposed to have a result as:
          ...
          <field1>:<value1>
          <field2>:<value2>
          ...
          <field1>:<value3>
          <field2>:<value4>
        Example :
            HolderIdentity:  master0
            InternalIP:  10.84.144.131
            HolderIdentity:  master1
            InternalIP:  10.84.144.132
            ...
        """
        lines = self.k8sCmd(cmd, debug).split("\n")
        elts = []
        dict = {}
        for line in lines:
            (key, value) = StringTool.getKeyValueFromLine(line, ":")
            for fieldName in fieldNames:
                if key == fieldName:
                    dict[key] = value.strip()
                    if fieldName == fieldNames[-1]:
                        elts.append(dict)
                        dict = {}
        return elts


# =================================================================================================
# External services (out of classes)
# =================================================================================================
def getK8sWithAddr(k8sRef, ip):
    newK8s = copy.deepcopy(k8sRef)
    newK8s.master_node.k8s_connection_details.ip_addr = ip
    newK8s.master_node.ssh_connection_details.addr = ip
    return newK8s
