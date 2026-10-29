import StringTool
import K8sNode
import Entity
import AirframeFiles
from taf.config.testline.connection_details import (
    OpenStackConnectionDetails,
    SshServiceDetails,
    HttpConnectionDetails)
from taf.config.testline.connection_details import K8SConnectionDetails
from taf.config.testline.cloud_hosting import MasterNode, K8S, ComputeNode


# =================================================================================================
# Airframe generic class
# =================================================================================================
class Airframe(Entity.Entity):
    pass


# =================================================================================================
# Open stack : vRAN 1.0
# =================================================================================================
class OpenStack(Airframe):
    pass


# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# Cloud RAN classes
# %%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%%
# =================================================================================================
# NAMING RULE for POD and CONTAINER
# =================================================================================================
class Name(object):
    def __init__(self, name, namespace):
        self.namespace = namespace
        self.name = name
        self.suffix = self.getSuffix()

    def __str__(self):
        return self.name

    def getSuffix(self):
        # Suffix is the part after <tl>-<ns>- if exits
        fields = self.name.split(f"{Container.SEPARATOR_NAME}{self.namespace}{Container.SEPARATOR_NAME}")
        if len(fields) == 2:
            return fields[1]
        return self.name

    def matches(self, name):
        if self.namespace in name:
            return name == self.name
        return name == self.suffix


# =================================================================================================
# CONTAINERS
# =================================================================================================
class Container(StringTool.ObjWithErrors):
    LEVEL = 2
    STATE_OK = ["Running"]
    STATE_WARN = ["Terminated"]
    SEPARATOR_NAME = "-"

    def __init__(self, pod, name, state):
        super(Container, self).__init__()
        self.pod = pod
        self.name = Name(name=name, namespace=self.pod.node.getNs())
        self.state = K8sNode.State(state, Container.STATE_OK, Container.STATE_WARN)
        self.addErrorUponState(self.state, f"Container {self.name} from pod {self.pod.name}")
        self.logs = AirframeFiles.Logs(self)

    def logsDiscover(self):
        if not self.logs.discovered:
            self.logs.discover()

    def getLog(self):
        self.logsDiscover()
        return self.logs.unzip()

    def __str__(self):
        return f"{self.name.name:84} State={self.state}"

    def display(self):
        StringTool.displayHeader(Container.LEVEL, self)

    def getCmd(self, cmd, withIT=True, execwithcaps=False):
        withItStr = ""
        execwithcapsStr = ""
        if withIT:
            withItStr = " -it"
        if execwithcaps:
            execwithcapsStr = " -- /usr/bin/execwithcaps -q"
        return f"-n {self.pod.node.getNs()} exec{withItStr} {self.pod.name} -c {self.name} {execwithcapsStr} -- {cmd}"

    def cmd(self, cmd, isSendCommand=False, debug=False, withIT=True, execwithcaps=False):
        fullCmd = self.getCmd(cmd=cmd, withIT=withIT, execwithcaps=execwithcaps)
        return self.pod.node.k8sCmd(cmd=fullCmd, isSendCommand=isSendCommand, debug=debug)

    def getSshStr(self):
        return self.pod.node.getSshStr()

    def getK8sStr(self):
        return self.pod.node.getK8sStr()

    def getSshCmd(self):
        return self.pod.node.getSshCmd()

    def getK8sCmd(self):
        return self.pod.node.getK8sCmd()

    def copyFile(self, sourcePath, destPath, debug=False):
        cmd = f"cp {self.pod.node.getNs()}/{self.pod.name}:{sourcePath} -c {self.name} {destPath}"
        self.pod.node.k8sCmd(cmd=cmd, debug=debug)

    def unzipFile(self, sourcePath, destPath, debug=False):
        cmd = f"/bin/gzip -c {sourcePath} |gunzip > {destPath}"
        self.cmd(cmd=cmd, debug=debug, withIT=False)

    def catFile(self, sourcePath, destPath, debug=False):
        cmd = f"/bin/cat {sourcePath} >> {destPath}"
        self.cmd(cmd=cmd, debug=debug, withIT=False)

    def downloadFile(self, remotePath, localPath):
        self.pod.node.downloadFile(remotePath=remotePath, localPath=localPath)

    @staticmethod
    def getContainers(pod):
        containers = []
        # From full pod description, we catch Container ID field which is the first field
        # Then, "-B 1" allows to catch previous line, meaning the line with Container name ('  <containerName>:')
        # Then, we grep on ":" to remove parasite lines
        (name, dummy, state) = ('NAME', 'Container ID', 'State')
        cmd = (f'describe pod -n {pod.node.getNs()} {pod.name} | '
               f'egrep "{dummy}|{state}" -B 1 | grep ":" | grep -v "{dummy}"')
        for dict in pod.node.getListAttrByObjFromK8sCmd(cmd=cmd, fieldNames=[state]):
            containers.append(Container(pod, dict[name], dict[state]))
        return containers


# =================================================================================================
# POD
# =================================================================================================
class Pod(StringTool.ObjWithErrors):
    LEVEL = 1
    STATE_OK = ["Running", "Completed"]
    SEPARATOR_NAME = "-"

    def __init__(self, node, name, ready, state):
        super(Pod, self).__init__()
        self.node = node
        self.name = Name(name=name, namespace=self.node.getNs())
        self.ready = ready
        self.state = K8sNode.State(state, Pod.STATE_OK)
        self.containers = Container.getContainers(self)
        self.addErrorUponState(self.state, f"POD {self.name}")
        self.aggregateErrors(self.containers)

    def getContainer(self, name):
        for container in self.containers:
            if container.name.matches(name):
                return container
        return None

    def __str__(self):
        return f"{self.name.name:63} Ready={self.ready:14} State={self.state}"

    def display(self):
        StringTool.displayHeader(Pod.LEVEL, self)
        for container in self.containers:
            container.display()

    @staticmethod
    def getPods(node):
        pods = []
        cmd = f"get pod -n {node.getNs()}"
        (name, ready, status) = ('NAME', 'READY', 'STATUS')
        for podDict in node.getTableFromK8sCmd(cmd, [name, ready, status]):
            pods.append(Pod(node, name=podDict[name], ready=podDict[ready], state=podDict[status]))
        return pods


# ===============================================================================================
# vRAN 2.0
# ===============================================================================================
class Kubernetes(Airframe):
    LEVEL = 1

    def __init__(self, hw, unit, index, oamSSH, oamHTTP, k8s):
        super(Kubernetes, self).__init__(hw, unit, index, oamSSH, oamHTTP)
        self.nodes = []
        self.pods = []
        self.mainNode = K8sNode.K8sNode(k8s=k8s, prefix=self.name)
        self.dynamicDiscovery()

    def dynamicDiscovery(self):
        self.createNodesList()                      # Create nodes
        self.nodesUpdateStatusAndRoles()            # Update Status and roles for each node
        # self.mainNode = self.getMainNode()          # Select the first node with status OK
        self.checkNamespace()                       # Check namespace is existing
        self.pods = Pod.getPods(self.mainNode)      # Get list of pods

    def createNodesList(self):
        # Launch a K8s command to have list of names and IP@ of all nodes,Then, building list of nodes
        (nameField, ipField) = ('HolderIdentity', 'InternalIP')
        fields = [nameField, ipField]
        cmd = f'describe node -n {self.mainNode.getNs()} | egrep "{nameField}|{ipField}"'
        dicts = self.mainNode.getListAttrFromK8sCmd(cmd, fields)
        for dict in dicts:
            k8s = K8sNode.getK8sWithAddr(k8sRef=self.mainNode.k8s, ip=dict[ipField])
            self.nodes.append(K8sNode.K8sNode(k8s=k8s, prefix=self.mainNode.prefix, name=dict[nameField]))
        self.nodes = sorted(self.nodes)

    def nodesUpdateStatusAndRoles(self):
        # Launch the 'get nodes' K8s command to get all status and roles for each node
        # Then, update each node with ocrresponding retrieved values
        (name, status, roles) = ('NAME', 'STATUS', 'ROLES')
        for dict in self.mainNode.getTableFromK8sCmd("get nodes", [name, status, roles]):
            for node in self.nodes:
                if dict[name] == node.name:
                    node.updateStatusAndRoles(dict[status], dict[roles], self.mainNode)

    def getMainNode(self):
        # Return the first node with status OK
        for node in self.nodes:
            if not node.state.isKO() and node.isMaster:
                return node

    def checkNamespace(self):
        res = self.mainNode.k8sCmd(f"get namespace | grep {self.mainNode.getNs()} | wc -l")
        nb = int(res.strip())
        # assert nb == 1, "Unable to find namespace {} on node {}".\
        #     format(self.mainNode.getNs(), self.mainNode.getK8s().ip_addr)

    def check(self):
        self.aggregateErrors(self.nodes)
        self.aggregateErrors(self.pods)
        self.displayErrors()
        # return len(self.errors) == 0
        return True

    def display(self):
        super(Airframe, self).display()
        for node in self.nodes:
            node.display()
        self.mainNode.displayAsMain()
        for pod in self.pods:
            pod.display()
        return self.check()

    # .... SERVICES .............................................................
    def getNodeFromName(self, name):
        for node in self.nodes:
            if node.name == name:
                return node
        return None

    def getPod(self, name):
        # Return a pod knowing its name (or suffix)
        for pod in self.pods:
            if pod.name.matches(name):
                return pod
        return None

    def getPodStatus(self, name):
        cmd = f"get pod -n {self.mainNode.getNs()} |grep -i {name}"
        res = self.mainNode.k8sCmd(cmd)
        return res

    def getContainer(self, name, podName=None):
        # Return a container knowing the pod and/or the name (or suffix)
        if podName is not None:
            pod = self.getPod(podName)
            if pod is not None:
                return pod.getContainer(name)
            return None
        for pod in self.pods:
            container = pod.getContainer(name)
            if container is not None:
                return container
        return None

    def getAndCheckContainer(self, podName, containerName):
        container = self.getContainer(name=containerName, podName=podName)
        assert container is not None, \
            f"getAndCheckContainer:No container found for container={containerName} pod={podName}"
        return container

    def cmd(self, podName, containerName, cmd, isSendCommand=False, debug=False):
        container = self.getAndCheckContainer(podName=podName, containerName=containerName)
        return container.cmd(cmd=cmd, isSendCommand=isSendCommand, debug=debug)

    def getAllLogs(self):
        for pod in self.pods:
            for container in pod.containers:
                container.logsDiscover()
                container.logs.display()
                container.logs.unzip()


# ===============================================================================================
# Kubernetes for CU
# ===============================================================================================
class K8sCU(Kubernetes):
    pass


# ===============================================================================================
# Kubernetes for DU
# ===============================================================================================
class K8sDU(Kubernetes):
    pass
