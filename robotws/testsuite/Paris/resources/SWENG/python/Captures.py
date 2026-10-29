import os
import time
from copy import deepcopy
import StringTool
import Connect
import Enums
import Airscales
import Container
import Airframes
import K8sNode
from ReadConfig import TLConfig
import re
from robot.libraries.BuiltIn import BuiltIn
import Airframes
import Topology

ABIP_PATH_CAPTURE = '/ffs/run/logs'
CONTAINER_NWMGMT_SUFFIX = "ctr-nwmgmt"
CONTAINER_L2RT_SUFFIX = "ctr-l2rt"


class Kind(Enums.MyEnum):
    CORE = 1
    CPRT = 2
    L1L2 = 3


# ===================================================================
# Class for Script Definition
# ===================================================================
class ScriptDef(object):
    DEF_REMOTE_PATH = "/ffs/run/config/scripts"
    ListScriptDef = []

    def __init__(self, title, names, cmd=None, remotePath=DEF_REMOTE_PATH,
                 host=None, commonMirrorScript=False):
        self.title = title
        self.host = host
        self.names = names
        self.remotePath = remotePath
        self.cmd = cmd
        if cmd is None:
            self.cmd = "{}/{}".format(remotePath, names[0])
        self.commonMirrorScript = commonMirrorScript

    @staticmethod
    def get(title):
        for script in ScriptDef.ListScriptDef:
            if title == script.title:
                return script
        return None

    @staticmethod
    def add(scriptDef):
        ScriptDef.ListScriptDef.append(scriptDef)
        return scriptDef

    @staticmethod
    def checkHosts():
        for scriptDef in ScriptDef.ListScriptDef:
            if scriptDef.host is None:
                error("Unexpected None host for ScriptDef with cmd [{}]".format(scriptDef.cmd))

    @staticmethod
    def initAll():
        # Mirroring for AP
        ScriptDef.add(ScriptDef(title="MIRROR_AP_FS", host=Connect.AP_DU().sys[0].M, names=["apMirroring.sh"]))
        ScriptDef.add(ScriptDef(title="MIRROR_AP_FS_LO", host=Connect.AP_DU().bb[0].M, names=["apMirroringLO.sh"]))
        ScriptDef.add(ScriptDef(title="MIRROR_AP_ASOE", host=Connect.AP_DU().sys[0].M, names=["apMirroringASOE.sh"]))
        ScriptDef.add(ScriptDef(title="MIRROR_AP_ASOH", host=Connect.AP_DU().sys[0].M, names=["apMirroringASOE.sh"]))
        if TLConfig.topo.isAic():
            return
        for idx in range(0, TLConfig.topo.getNbGNB()):
            gnb = Connect.TGNB_DU(idx)
            hostGnb = hostForFsMO = gnb.sys[0].M
            if gnb.getProfil() != "ASOE" and gnb.getProfil() != "ASOH":
                hostForFsMO = gnb.bb[0].M
            if gnb.getProfil() == "MP" or gnb.getProfil() == "LP":
                hostForFsLPMP = gnb.bb[0].M
            ScriptDef.add(ScriptDef(title="MIRROR_GNB{}_FS_MO".format(idx), host=hostForFsMO,
                                    names=["gnbMirroring_FS_ASIM.sh"]))
            if gnb.getProfil() == "MP" or gnb.getProfil() == "LP":
                ScriptDef.add(ScriptDef(title="MIRROR_GNB{}_FS_LP".format(idx), host=hostForFsLPMP,
                                        names=["gnbMirroring_FS_LP.sh"]))
            ScriptDef.add(ScriptDef(title="MIRROR_GNB{}_FS_DEFAULT".format(idx), host=hostGnb,
                                    names=["gnbMirroring.sh", "gnbMirroringConfig.sh"], commonMirrorScript=True))
            ScriptDef.add(ScriptDef(title="MIRROR_GNB{}_L1B_BO".format(idx), host=hostGnb,
                                    names=["gnbMirroring_L1B_BO.sh"]))
            ScriptDef.add(ScriptDef(title="MIRROR_GNB{}_L1B_LO".format(idx), host=hostGnb,
                                    names=["gnbMirroring_L1B_LO.sh"]))
            ScriptDef.add(ScriptDef(title="MIRROR_GNB{}_L1B_CLOUD".format(idx), host=hostGnb,
                                    names=["gnbMirroring_L1B_CLOUD.sh"]))
            ScriptDef.add(ScriptDef(title="MIRROR_GNB{}_FS_ASOE".format(idx), host=hostGnb,
                                    names=["gnbMirroring_FS_ASOE.sh"]))
            ScriptDef.add(ScriptDef(title="MIRROR_GNB{}_FS_ASOH".format(idx), host=hostGnb,
                                    names=["gnbMirroring_FS_ASOE.sh"]))
            ScriptDef.add(ScriptDef(title="MIRROR_GNB{}_L1B_CLASSICAL".format(idx),
                                    host=hostGnb, names=["gnbMirroring.sh"], commonMirrorScript=True))
            # For multi ABIL
            ScriptDef.add(ScriptDef(title="MIRROR_GNB{}_FS_BOO".format(idx), host=hostGnb,
                                    names=["gnbMirroring_FS_BOO.sh"]))
            ScriptDef.add(ScriptDef(title="MIRROR_GNB{}_L1B_BOO".format(idx), host=hostGnb,
                                    names=["gnbMirroring_L1B_BOO.sh"]))
            ScriptDef.add(ScriptDef(title="MIRROR_GNB{}_L1B_BOO_L2LO_L2HI".format(idx), host=hostGnb,
                                    names=["gnbMirroring_L1B_BOO_L2LO_L2HI.sh"]))


# ===================================================================
# Class for Target for a capture
# ===================================================================
class CaptureTarget(object):
    def __init__(self, entity=None):
        self.entity = entity

    def check(self, capture):
        pass

    def update(self):
        pass

    def updateNodeFromName(self):
        pass

    def checkTcpdumpIsRunning(self, path, isRunning):
        time.sleep(1)
        output = self.isTcpdumpRunning(path)
        if isRunning:
            assert len(output) > 0, "Tcpdump command not running for {}".format(path)
        else:
            assert len(output) == 0, "Tcpdump command is still running for {}".format(path)

    def traceStart(self, target, cmd):
        StringTool.datedConsole("CAPTURE Start on {}:{}:CMD=[{}]".format(self.entity.prefix, target, cmd))

    def traceStop(self, target, path, cmd):
        StringTool.datedConsole("CAPTURE Stop on {}:{} ({}):CMD={}".format(self.entity.prefix, target, path, cmd))

    def getPsCmd(self, cmd, path):
        return "ps -ef --cols=255| grep '{}' | grep {} | grep -v grep".format(cmd, path)

    def getKillCmd(self, cmd, path):
        return "{} | awk '{}print $2 {}'".format(self.getPsCmd(cmd, path), "{", "}")


# ===================================================================
# Class for Target for a capture on a Classical TL
# ===================================================================
class TargetClassical(CaptureTarget):
    REMOTE_PATH = "/tmp"

    def __init__(self, entity=None, host=None, node=None):
        super(TargetClassical, self).__init__(entity)
        self.host = host
        self.node = node
        self.isNode = node is not None

    def __str__(self):
        hostStr = "Host="
        if self.host is not None:
            hostStr += self.host.alias
        nodeStr = ""
        if self.isNode:
            nodeStr = " Node={}".format(self.node)
        return "{}:{}{}".format(self.entity.prefix, hostStr, nodeStr)

    def getRemotePath(self):
        isMPLP = checkProfileMP_LP()
        if isMPLP:
            return ABIP_PATH_CAPTURE
        else:
            return TargetClassical.REMOTE_PATH

    def updateNodeFromName(self):
        if self.isNode:
            self.node = Container.getNodeFromCaptureNode(captureNode=self.node)
            self.host = self.node.host

    def setCaptureRootPath(self, captureRootPathCmd):
        isMPLP = checkProfileMP_LP()
        if isMPLP:
            return ABIP_PATH_CAPTURE
        elif self.isNode:
            return "{}/node_{}/{}".format(TargetClassical.REMOTE_PATH, self.node.id, captureRootPathCmd)
        else:
            return TargetClassical.REMOTE_PATH

    def removeFile(self, capture):
        self.host.cmd("rm -Rf {}".format(capture.getTcpdumpPath()))

    def check(self, capture):
        if self.host is None and not self.isNode:
            error("Unexpected None host for capture [{}]".format(capture.prefix))

    def isTcpdumpRunning(self, path):
        return self.host.cmd(self.getPsCmd("tcpdump", path))

    def startCapture(self, capture):
        cmd = "{}tcpdump -i {} -w {} {}"\
            .format(self.host.getSudoPrefix(), capture.interface, capture.getTcpdumpCmdPath(), capture.filter)
        if self.isNode:
            cmd = "lxc-attach -n {} -- {}".format(self.node.nodeId, cmd)
        cmd += " >/dev/null 2>&1"
        self.traceStart(self.host.alias, cmd)
        self.host.cmd(cmd, isSendCommand=True)

    def stopCapture(self, capture):
        cmd = "kill `{}`".format(self.getKillCmd("tcpdump", capture.getTcpdumpCmdPath()))
        self.traceStop(self.host.alias, capture.getTcpdumpCmdPath(), cmd)
        self.host.cmd(cmd)

    def getPcapFile(self, capture):
        self.host.downloadFile(remote_path=capture.getTcpdumpPath(), local_path=capture.path)


# ===================================================================
# Class for Target for a capture on a AIC TL
# This is the case when tcpdump is supported in container
# ===================================================================
class TargetAic(CaptureTarget):
    REMOTE_PATH = "tmp"  # Root Path on container
    LOCAL_PATH = "/tmp"  # Root Path on VM

    def __init__(self, entity=None, pod=None, container=None):
        super(TargetAic, self).__init__(entity)
        self.podSuffix = pod
        self.containerSuffix = container

    def __str__(self):
        return "{}:POD={} CONTAINER={}".format(self.entity, self.pod.name, self.container.name)

    def getRemotePath(self):
        return TargetAic.REMOTE_PATH

    def setCaptureRootPath(self, captureRootPathCmd):
        return TargetAic.REMOTE_PATH

    def update(self):
        self.captureNode = self.entity.mainNode
        self.pod = self.entity.getPod(name=self.podSuffix)
        assert self.pod is not None, \
            "TargetAic.update:No pod found for name={}".format(self.podSuffix)
        self.container = self.entity.getContainer(name=self.containerSuffix, podName=self.podSuffix)
        assert self.container is not None, \
            "TargetAic.update:No container found for name={} in pod {}".format(self.containerSuffix, self.podSuffix)

    def removeFile(self, capture):
        self.container.cmd("rm -Rf {}".format(capture.getTcpdumpPath()))

    def isTcpdumpRunning(self, path):
        return self.container.cmd(self.getPsCmd("tcpdump", path))

    def getStartCmd(self, capture):
        return "tcpdump -i {} -w {} {}".format(capture.interface, capture.getTcpdumpCmdPath(), capture.filter)

    def startCapture(self, capture):
        cmd = "{} >/dev/null 2>&1".format(self.getStartCmd(capture))
        self.traceStart(self, cmd)
        self.container.cmd(cmd=cmd, isSendCommand=True)

    def getCaptureStopCmd(self, capture):
        psCmd = self.container.getCmd(cmd=self.getKillCmd("tcpdump", capture.getTcpdumpCmdPath()))
        psCmd = K8sNode.K8sNode.cmdToK8sCmd(psCmd)
        psCmd = "kill -INT `{}`".format(psCmd)
        psCmd = self.container.getCmd(cmd=psCmd)
        cmd = K8sNode.K8sNode.cmdToK8sCmd(psCmd)
        StringTool.datedConsole("getCaptureStopCmd : cmd =[{}]".format(cmd))
        return cmd

    def getSshDetailsAndCaptureStopCmd(self, capture):
        sshDetails = self.container.getK8sCmd()
        captureStopCmd = self.getCaptureStopCmd(capture)
        # add escape char "\" before specific chars
        tmpCaptureStopCmd = captureStopCmd.replace("`", "\\`").replace("$", "\\$")
        StringTool.datedConsole("getSshDetailsAndCaptureStopCmd - sshDetails=[{}], captureStopCmd=[{}]".
                                format(sshDetails, tmpCaptureStopCmd))
        return ("{}  \"{}\"".format(sshDetails, tmpCaptureStopCmd))

    def stopCapture(self, capture):
        # psCmd = self.container.getCmd(cmd=self.getKillCmd("tcpdump", capture.getTcpdumpCmdPath()))
        # psCmd = K8sNode.K8sNode.cmdToK8sCmd(psCmd)
        cmd = "pkill -f '{}'".format(self.getStartCmd(capture).strip())
        self.traceStop(self, capture.getTcpdumpCmdPath(), cmd)
        self.container.cmd(cmd)

    def getPcapFile(self, capture):
        # First copy file from container to local directory inside vXu VM
        remotePath = "{}/{}".format(TargetAic.LOCAL_PATH, capture.getCaptureFileName())
        # self.container.copyFile(sourcePath=capture.getTcpdumpCmdPath(),
        #                         destPath=remotePath)
        # self.container.unzipFile(sourcePath=capture.getTcpdumpCmdPath(),
        #                          destPath=remotePath)
        self.container.catFile(sourcePath=capture.getTcpdumpCmdPath(),
                               destPath=remotePath)
        # Then, download from vXu VM TL VM
        self.container.downloadFile(remotePath=remotePath, localPath=capture.path)


# ===================================================================
# Class for Target for a capture on a AIC TL
# This is the case when tcpdump is NOT supported in container
# Then, we use a WA described in :
#   https://confluence.ext.net.nokia.com/pages/viewpage.action?pageId=1286391470
# ===================================================================
class TargetAicSecured(TargetAic):
    REMOTE_PATH = "./"   # Root Path with crictl user
    LOCAL_PATH = "/tmp"  # Final Root Path on VM

    def getRemotePath(self):
        return TargetAicSecured.REMOTE_PATH

    def setCaptureRootPath(self, captureRootPathCmd):
        return TargetAicSecured.REMOTE_PATH

    def removeFile(self, capture):
        self.entity.mainNode.sshCmd("rm -Rf {}".format(capture.getTcpdumpPath()))

    def isTcpdumpRunning(self, path):
        return self.captureNode.sshCmd(self.getPsCmd("tcpdump", path))

    def getWorker(self):
        cmd = "get pod {} -o yaml -n {} | grep nodeName | awk '{}print $2{}'"\
            .format(self.pod.name, self.entity.mainNode.getNs(), "{", "}")
        workerName = StringTool.getStringFromCmdReturn(self.entity.mainNode.k8sCmd(cmd=cmd))
        return self.entity.getNodeFromName(workerName)

    def startCapture(self, capture):
        if isinstance(self.entity, Airframes.K8sCU):
            self.captureNode = self.getWorker()
            assert self.captureNode is not None, "Unable to retrieve worker node for POD {}".format(self.pod.name)
        cmd = "sudo crictl ps | grep '{} ' | cut -d ' ' -f1".format(self.container.name)
        id1 = StringTool.getStringFromCmdReturn(self.captureNode.sshCmd(cmd=cmd))
        assert len(id1) > 0, "Unable to get ID for container {} ({})".format(self.container.name, cmd)
        cmd = "sudo crictl inspect --output yaml {} |grep 'pid:' | cut -d ':' -f2".format(id1)
        pid = int(self.captureNode.sshCmd(cmd=cmd).strip())
        cmd = "sudo nsenter -r -n -t {} tcpdump -i {} -s 0 -w {} {} >/dev/null 2>&1"\
            .format(pid, capture.interface, capture.getTcpdumpCmdPath(), capture.filter)
        self.traceStart(self, cmd)
        self.captureNode.sshCmd(cmd=cmd, isSendCommand=True)

    # ADT - add getCaptureStopCmd
    def getCaptureStopCmd(self, capture):
        cmd = "sudo kill -INT `{}`".format(self.getKillCmd("tcpdump", capture.getTcpdumpCmdPath()))
        StringTool.datedConsole("getCaptureStopCmd : cmd =[{}]".format(cmd))
        return cmd

    # ADT - add getSshDetailsAndCaptureStopCmd
    def getSshDetailsAndCaptureStopCmd(self, capture):
        sshDetails = self.captureNode.getSshCmd()
        captureStopCmd = self.getCaptureStopCmd(capture)
        # add escape char "\" before specific chars
        tmpCaptureStopCmd = captureStopCmd.replace("`", "\\`").replace("$", "\\$")
        StringTool.datedConsole("getSshDetailsAndCaptureStopCmd - sshDetails=[{}], captureStopCmd=[{}] ".
                                format(sshDetails, tmpCaptureStopCmd))
        return ("{}  \"{}\"".format(sshDetails, tmpCaptureStopCmd))

    def stopCapture(self, capture):
        cmd = "sudo kill -INT `{}`".format(self.getKillCmd("tcpdump", capture.getTcpdumpCmdPath()))
        self.traceStop(self, capture.getTcpdumpCmdPath(), cmd)
        self.captureNode.sshCmd(cmd)
        self.captureNode.sshCmd("sudo mv {} {}".format(capture.getTcpdumpCmdPath(), TargetAicSecured.LOCAL_PATH))

    def getPcapFile(self, capture):
        remotePath = "{}/{}".format(TargetAicSecured.LOCAL_PATH, capture.getCaptureFileName())
        self.captureNode.downloadFile(remotePath=remotePath, localPath=capture.path)


# ===================================================================
# Class for Target for a capture on a AIC TL
# This is the case when we are using dpdk commands (for L1L2)
# and when no mirroring is done
# Then, we are using dpdk commands from end to end
# ===================================================================
class TargetAicDpdk(TargetAic):
    REMOTE_PATH = "tmp/dpdkdump"  # Root Path on container
    REMOTE_NAME = "l1bipl1"
    REMOTE_PROC = "dpdk-pdump"
    if TLConfig.isVranTl:
        REMOTE_NAME = "l1up"
    REMOTE_FILE = "{}.pcap".format(REMOTE_NAME)
    REMOTE_FULL_PATH = "{}/{}".format(REMOTE_PATH, REMOTE_FILE)

    def getRemotePath(self):
        return TargetAicDpdk.REMOTE_PATH

    def setCaptureRootPath(self, captureRootPathCmd):
        return TargetAicDpdk.REMOTE_PATH

    def removeFile(self, capture):
        self.container.cmd("rm -Rf {}".format(TargetAicDpdk.REMOTE_FULL_PATH))

    def isTcpdumpRunning(self, path):
        return self.container.cmd(self.getPsCmd("hal-cli", os.path.dirname(path)))

    def getPort(self):
        # cmd = 'hal-cli show port table | grep {} | cut -d " " -f1'.format(TargetAicDpdk.REMOTE_NAME)
        # try:
        #     output = self.container.cmd(cmd=cmd)
        #     port = int(output)
        # except Exception as e:
        #     StringTool.datedConsole("Unable to retrieve port from hal-cli command. Result was [{}]".format(output))
        # WA_port
        sport = '0'
        port = int(sport)
        return port

    def startCapture(self, capture):
        # WA_port
        portG = self.getPort()
        cmd = "hal-cli pdump port {} path {} >/dev/null 2>&1".format(portG, TargetAicDpdk.REMOTE_PATH)
        self.traceStart(self, cmd)
        self.container.cmd(cmd=cmd, isSendCommand=True)

    def getCaptureStopCmd(self, capture):
        psCmd = self.container.getCmd(cmd=self.getKillCmd("dpdk-pdump", TargetAicDpdk.REMOTE_PROC))
        psCmd = K8sNode.K8sNode.cmdToK8sCmd(psCmd)
        psCmd = "kill -INT `{}`".format(psCmd)
        psCmd = self.container.getCmd(cmd=psCmd)
        cmd = K8sNode.K8sNode.cmdToK8sCmd(psCmd)
        return cmd

    def getSshDetailsAndCaptureStopCmd(self, capture):
        sshDetails = self.container.getK8sCmd()
        captureStopCmd = self.getCaptureStopCmd(capture)
        # add escape char "\" before specific chars
        tmpCaptureStopCmd = captureStopCmd.replace("`", "\\`").replace("$", "\\$")
        StringTool.datedConsole("getSshDetailsAndCaptureStopCmd - sshDetails=[{}], captureStopCmd=[{}] ".
                                format(sshDetails, tmpCaptureStopCmd))
        return ("{}  \"{}\"".format(sshDetails, tmpCaptureStopCmd))

    def stopCapture(self, capture):
        psCmd = self.container.getCmd(cmd=self.getKillCmd("dpdk-pdump", TargetAicDpdk.REMOTE_PROC))
        psCmd = K8sNode.K8sNode.cmdToK8sCmd(psCmd)
        cmd = "kill -INT `{}`".format(psCmd)
        self.traceStop(self, TargetAicDpdk.REMOTE_FULL_PATH, cmd)
        self.container.cmd(cmd)

    def getPcapFile(self, capture):
        # First copy file from container to local directory inside vXu VM
        remotePath = "{}/{}".format(TargetAic.LOCAL_PATH, capture.getCaptureFileName())
        self.container.copyFile(sourcePath=TargetAicDpdk.REMOTE_FULL_PATH, destPath=remotePath)
        # Then, download from vXu VM TL VM
        self.container.downloadFile(remotePath=remotePath, localPath=capture.path)


# ===================================================================
# Class for Target for a capture on a AIC TL,
# This is the case when we are using dpdk commands (for L1L2)
# and when mirroring is activated
# Then, we are using tcpdump commands for capture, and filtering is allowed
# ===================================================================
class TargetAicDpdkMirror(TargetAicDpdk):
    REMOTE_PATH = "tmp/tcpdump"  # Root Path on container

    def getRemotePath(self):
        return TargetAicDpdkMirror.REMOTE_PATH

    def isTcpdumpRunning(self, path):
        return self.containerNwmgmt.cmd(cmd=self.getPsCmd("tcpdump", path))

    def update(self):
        super().update()
        self.containerNwmgmt = self.entity.getContainer(name=CONTAINER_NWMGMT_SUFFIX,
                                                        podName=self.podSuffix)
        assert self.containerNwmgmt is not None, \
            "TargetAicDpdkMirror.update:No container found for name={} in pod {}"\
            .format(CONTAINER_NWMGMT_SUFFIX, self.podSuffix)
        self.containerL2rt = self.entity.getContainer(name=CONTAINER_L2RT_SUFFIX,
                                                      podName=self.podSuffix)

    def startCapture(self, capture):
        port = self.getPort()
        # Set mirroring
        cmd = "hal-cli pdump mirror {} lo >/dev/null 2>&1".format(port)
        self.container.cmd(cmd=cmd, isSendCommand=True, execwithcaps=True)
        # Launch capture
        cmd = "tcpdump -i {} -w {} {}>/dev/null 2>&1".format(
            capture.interface, capture.getTcpdumpCmdPath(), capture.filter)
        self.traceStart(self, cmd)
        self.containerNwmgmt.cmd(cmd=cmd, isSendCommand=True, execwithcaps=True)

    def stopCapture(self, capture):
        # Stop tcpdump command
        psCmd = self.getKillCmd("tcpdump", capture.getTcpdumpCmdPath())
        self.traceStop(self, capture.getTcpdumpCmdPath(), psCmd)
        res = self.containerNwmgmt.cmd(cmd=psCmd)
        # Spliting result to launch as many pkill comand as pid,
        # since pkill command is not supporting several pid in line
        for pid in res.split("\n"):
            pid = pid.strip()
            if len(pid) > 0:
                # self.containerNwmgmt.cmd(cmd="pkill -TERM -s {}".format(pid))
                self.containerNwmgmt.cmd(cmd="sh -c 'kill -INT {}' ".format(pid))

        # NEW Stop mirroring command
        psCmd = "ps -ef --cols=255 | grep 'hal-cli' | grep pdump | grep -v grep | awk \'{print $2 }\'"
        res = self.containerL2rt.cmd(cmd=psCmd)
        for pid in res.split("\n"):
            pid = pid.strip()
            if len(pid) > 0:
                self.containerL2rt.cmd(cmd="sh -c 'kill -INT {}' ".format(pid))

        psCmd = "ps -ef --cols=255 | grep 'dpdk-pdump' | grep secondary | grep -v grep | awk \'{print $2 }\'"
        res = self.containerL2rt.cmd(cmd=psCmd)
        for pid in res.split("\n"):
            pid = pid.strip()
            if len(pid) > 0:
                self.containerL2rt.cmd(cmd="sh -c 'kill -INT {}' ".format(pid))

    def getPcapFile(self, capture):
        # First copy file from container to local directory inside vXu VM
        remotePath = "{}/{}".format(TargetAic.LOCAL_PATH, capture.getCaptureFileName())
        # self.containerNwmgmt.unzipFile(sourcePath=capture.getTcpdumpCmdPath(), destPath=remotePath)
        self.containerNwmgmt.catFile(sourcePath=capture.getTcpdumpCmdPath(), destPath=remotePath)
        # Then, download from vXu VM TL VM
        self.containerNwmgmt.downloadFile(remotePath=remotePath, localPath=capture.path)


# =====================================================================
# Class for Capture : generic concept of capture for Classical and AIC
# =====================================================================
class Capture(object):
    ListCapture = []
    CAPTURE_EXT = ".pcap"

    def __init__(self, interface, prefix, target, scriptDef=None, filter=""):
        self.useTafMirror = False
        self.interface = interface
        self.prefix = prefix
        self.target = target
        self.scriptDef = scriptDef
        self.isMirror = scriptDef is not None
        self.filter = filter
        self.withTN = False
        self.name = ""
        self.path = ""

    def __str__(self):
        scriptStr = ""
        if self.isMirror:
            scriptStr = " Script={}".format(self.scriptDef.names[0])
        filterStr = ""
        if len(self.filter) > 0:
            filterStr = " Filter={}".format(self.filter)
        return "{}Prefix={:40} IF={:10} {}{}{}".format(
            StringTool.PREFIX_DISPLAY, self.prefix, self.interface,
            self.target, scriptStr, filterStr)

    @staticmethod
    def get(prefix):
        for capture in Capture.ListCapture:
            if prefix == capture.prefix:
                return capture
        return None

    def setName(self):
        self.name = self.prefix
        if self.withTN == 'True':
            self.name += ".{}".format(StringTool.getFormattedName())

    def setRootPaths(self):
        self.CaptureRootPathCmd = self.target.getRemotePath()
        self.CaptureRootPath = self.target.setCaptureRootPath(self.target.getRemotePath())

    def getCaptureFileName(self):
        return "{}{}".format(self.name, Capture.CAPTURE_EXT)

    def getTcpdumpPath(self):
        return "{}/{}".format(self.CaptureRootPath, self.getCaptureFileName())

    def getTcpdumpCmdPath(self):
        return "{}/{}".format(self.CaptureRootPathCmd, self.getCaptureFileName())

    def start(self, check):
        self.setName()
        if self.useTafMirror:
            # we are using taf, no need to launch capture but we need the above setName
            return
        self.target.updateNodeFromName()
        self.setRootPaths()
        StringTool.console(":{}".format(self.target))
        self.target.removeFile(self)
        self.target.startCapture(self)
        if check:
            self.target.checkTcpdumpIsRunning(path=self.getTcpdumpCmdPath(), isRunning=True)

    def stop(self):
        self.target.stopCapture(self)
        self.target.checkTcpdumpIsRunning(path=self.getTcpdumpCmdPath(), isRunning=False)
        self.target.getPcapFile(self)

    @staticmethod
    def replaceRobotVar(filter):
        match = re.match(r".*\${(.*)}.*", filter)
        if match:
            exp = "${" + match.group(1) + "}"
            value = BuiltIn().get_variable_value(exp)
            filter = filter.replace(exp, value)
        return filter

    def getSshDetailsAndCaptureStopCmd(self):
        return self.target.getSshDetailsAndCaptureStopCmd(self)

    @staticmethod
    def update():
        # Update each capture (host, filter, ...) upon context
        for capture in Capture.ListCapture:
            capture.target.update()
            capture.filter = Capture.replaceRobotVar(capture.filter)

    @staticmethod
    def add(capture):
        Capture.ListCapture.append(capture)
        return capture

    @staticmethod
    def checkTargets():
        for capture in Capture.ListCapture:
            capture.target.check(capture)

    @staticmethod
    def displayAll():
        StringTool.printLineWithTitle("List of Captures")
        for capture in Capture.ListCapture:
            StringTool.datedConsole(capture)


# =====================================================================
# Class for CapClassical: Capture for classical
# =====================================================================
class CapClassical(Capture):
    def __init__(self, interface, prefix, entity,
                 host=None, node=None, scriptDef=None, filter=""):
        super(CapClassical, self).__init__(interface=interface, prefix=prefix,
                                           target=TargetClassical(entity=entity, host=host, node=node),
                                           scriptDef=scriptDef, filter=filter)


# =====================================================================
# Class for CapAic: Capture for AIC
# =====================================================================
class CapAic(Capture):
    def __init__(self, interface, prefix, entity,
                 pod=None, container=None, scriptDef=None, filter="",
                 isDpdk=False, isMirror=False):
        if isDpdk and isMirror:
            target = TargetAicDpdkMirror(entity=entity, pod=pod, container=container)
        elif isDpdk and not isMirror:
            target = TargetAicDpdk(entity=entity, pod=pod, container=container)
        else:
            # target = TargetAicSecured(entity=entity, pod=pod, container=container)
            target = TargetAic(entity=entity, pod=pod, container=container)
        super(CapAic, self).__init__(interface=interface, prefix=prefix, target=target,
                                     scriptDef=scriptDef, filter=filter)


# ===================================================================
# Capture Definition
# ===================================================================
def initAllCaptures():
    ap = Connect.AP_DU()
    epcsim = Connect.HOST_EPCSIM
    apSysSlave = ap.getSysSlaveHost()
    # ===================================================
    # COMMON CAPTURES
    # ===================================================
    # ---------------------------------
    #     CAPTURE for CORE
    # ---------------------------------
    #     Add of interface eth1 on WTS to support Cloud configuration
    Capture.add(CapClassical(entity=ap, host=epcsim, interface="eth3", prefix="CORE_WTS_ETH3"))
    # ---------------------------------
    #     CAPTURE for CPRT
    # ---------------------------------
    # ---------------------------------
    #     CAPTURE for L1L2
    # ---------------------------------
    Capture.add(CapClassical(entity=ap, host=ap.bb[0].M, interface="nac_eth1", prefix="L1L2_AP_FS_LO",
                             scriptDef=ScriptDef.get("MIRROR_AP_FS_LO")))
    Capture.add(CapClassical(entity=ap, host=ap.bb[0].S, interface="ethbp1", prefix="L1L2_AP_FS",
                             scriptDef=ScriptDef.get("MIRROR_AP_FS")))
    Capture.add(CapClassical(entity=ap, host=apSysSlave, interface="etha01", prefix="L1L2_AP_L1B"))
    Capture.add(CapClassical(entity=ap, host=apSysSlave, interface="etha01", prefix="L1L2_AP_ASOE",
                             scriptDef=ScriptDef.get("MIRROR_AP_ASOE")))
    if not TLConfig.topo.isAic():
        # ===================================================
        # CAPTURES on GNB for CLASSICAL
        # ===================================================
        for idx in range(0, TLConfig.topo.getNbGNB()):
            gnb = Connect.TGNB_DU(idx)
            hostSysM = gnb.sys[0].M
            hostSysS = gnb.sys[0].S
            hostForFsMO = hostSysM
            hostForFsMP = hostSysM
            if gnb.getProfil() != "ASOE" and gnb.getProfil() != "ASOH":
                hostForFsMO = gnb.bb[0].M
            if gnb.getProfil() == "MP" or gnb.getProfil() == "LP":
                hostForFsMP = gnb.bb[0].M
            # ---------------------------------
            #     CAPTURE for CORE
            # ---------------------------------
            Capture.add(CapClassical(entity=gnb, host=hostSysM, interface="fp0",
                                     prefix="CORE_GNB{}_SYS0_M_FP0".format(idx)))
            # Add of interface BR1 to support ASIB
            Capture.add(CapClassical(entity=gnb, host=hostSysM, interface="br1",
                                     prefix="CORE_GNB{}_SYS0_M_BR1".format(idx)))
            # Add of interface BR0 to support ASIL
            Capture.add(CapClassical(entity=gnb, host=hostSysM, interface="br0",
                                     prefix="CORE_GNB{}_SYS0_M_BR0".format(idx)))
            # ---------------------------------
            #     CAPTURE for CPRT
            # ---------------------------------
            Capture.add(CapClassical(entity=gnb, host=None, interface="any",
                                     prefix="CPRT_NODE_GNB{}".format(idx), node="CPRT"))
            # ---------------------------------
            #     CAPTURE for L1L2
            # ---------------------------------
            mirrorDef = ScriptDef.get("MIRROR_GNB{}_FS_DEFAULT".format(idx))
            Capture.add(CapClassical(entity=gnb, host=hostSysM, interface="pepbp1",
                                     prefix="L1L2_GNB{}_FS_KL".format(idx), scriptDef=mirrorDef))
            Capture.add(CapClassical(entity=gnb, host=hostSysM, interface="eths2",
                                     prefix="L1L2_GNB{}_FS_BL".format(idx), scriptDef=mirrorDef))
            Capture.add(CapClassical(entity=gnb, host=hostSysM, interface="nac_eth2",
                                     prefix="L1L2_GNB{}_FS_LO".format(idx), scriptDef=mirrorDef))
            Capture.add(CapClassical(entity=gnb, host=hostSysM, interface="nac_eth2",
                                     prefix="L1L2_GNB{}_FS_LN".format(idx), scriptDef=mirrorDef))
            if gnb.getProfil() == "ASOE":
                Capture.add(CapClassical(entity=gnb, host=hostSysS, interface="etha01",
                                         prefix="L1L2_GNB{}_FS_ASOE".format(idx),
                                         scriptDef=ScriptDef.get("MIRROR_GNB{}_FS_ASOE".format(idx),)))
            if gnb.getProfil() == "ASOH":
                Capture.add(CapClassical(entity=gnb, host=hostSysS, interface="etha01",
                                         prefix="L1L2_GNB{}_FS_ASOH".format(idx),
                                         scriptDef=ScriptDef.get("MIRROR_GNB{}_FS_ASOH".format(idx),)))
            Capture.add(CapClassical(entity=gnb, host=hostForFsMO, interface="nac_eth5",
                                     prefix="L1L2_GNB{}_FS_MO".format(idx),
                                     scriptDef=ScriptDef.get("MIRROR_GNB{}_FS_MO".format(idx),)))
            Capture.add(CapClassical(entity=gnb, host=hostForFsMP, interface="etha01",
                                     prefix="L1L2_GNB{}_FS_LP".format(idx),
                                     scriptDef=ScriptDef.get("MIRROR_GNB{}_FS_LP".format(idx),)))
            # FDD only
            Capture.add(CapClassical(entity=gnb, host=hostSysM, interface="eths3",
                                     prefix="L1L2_GNB{}_FS_BO".format(idx), scriptDef=mirrorDef))
            Capture.add(CapClassical(entity=gnb, host=hostSysM, interface="eths3",
                                     prefix="L1L2_GNB{}_FS_BN".format(idx), scriptDef=mirrorDef))
            Capture.add(CapClassical(entity=gnb, host=hostSysM, interface="eths3",
                                     prefix="L1L2_GNB{}_FS_BOO".format(idx),
                                     scriptDef=ScriptDef.get("MIRROR_GNB{}_FS_BOO".format(idx))))
            # TDD in l1 bypass due to restrictions
            Capture.add(CapClassical(entity=gnb, host=hostSysM, interface="eths2",
                                     prefix="L1L2_GNB{}_L1B_BOO".format(idx),
                                     scriptDef=ScriptDef.get("MIRROR_GNB{}_L1B_BOO".format(idx))))
            Capture.add(CapClassical(entity=gnb, host=hostSysM, interface="eths2",
                                     prefix="L1L2_GNB{}_L1B_BO".format(idx),
                                     scriptDef=ScriptDef.get("MIRROR_GNB{}_L1B_BO".format(idx)),
                                     filter="\'${PREFIX_ETHER_BIP_MSG_TYPE_ASIB}<0xf000\'"))
            Capture.add(CapClassical(entity=gnb, host=hostSysM, interface="nac_eth2",
                                     prefix="L1L2_GNB{}_L1B_LO".format(idx),
                                     scriptDef=ScriptDef.get("MIRROR_GNB{}_L1B_LO".format(idx)),
                                     filter="\'${PREFIX_ETHER_BIP_MSG_TYPE_ASIL}<0xf000\'"))
            Capture.add(CapClassical(entity=gnb, host=hostSysM, interface="etha01",
                                     prefix="L1L2_GNB{}_CLOUD".format(idx),
                                     scriptDef=ScriptDef.get("MIRROR_GNB{}_L1B_CLOUD".format(idx))))
            # !!!! For all other L1Bypass configuration : but to be reworked, removed
            Capture.add(CapClassical(entity=gnb, host=hostSysM, interface="etha01",
                                     prefix="L1L2_GNB{}_L1B_CLASSICAL".format(idx),
                                     scriptDef=ScriptDef.get("MIRROR_GNB{}_L1B_CLASSICAL".format(idx))))
            # BHO :used in TESTS #
            Capture.add(CapClassical(entity=gnb, host=hostSysM, interface="eths2",
                                     prefix="L1L2_GNB{}_L1B_BOO_L2LO_L2HI".format(idx),
                                     scriptDef=ScriptDef.get("MIRROR_GNB{}_L1B_BOO_L2LO_L2HI".format(idx))))
    else:
        # ===================================================
        # CAPTURES on GNB for VRAN TL
        # ===================================================
        cu = Connect.TGNB_CU()
        du = Connect.TGNB_DU()
        # Default container for dpdk (legacy l1hi); override for vRAN
        container = "l1hi"
        if TLConfig.isVranTl:
            container = CONTAINER_L2RT_SUFFIX
        Capture.add(CapAic(entity=cu, interface="any", prefix="AIC_CORE_VCU", pod="ute-cpif-0",
                           container="ctr-nwmgmt"))
        Capture.add(CapAic(entity=du, interface="any", prefix="AIC_CPRT_VDU", pod="ute-cprt-0",
                           container="ctr-nwmgmt"))
        Capture.add(CapAic(entity=du, interface="any", prefix="AIC_L1L2_VDU", pod="ute-l2rt-a-0", container=container,
                           isDpdk=True, isMirror=False))
        Capture.add(CapAic(entity=du, interface="lo", prefix="AIC_L1L2_VDU_MIRROR", pod="ute-l2rt-a-0",
                           container=container, isDpdk=True, isMirror=True))


def error(msg):
    StringTool.datedConsole("ERROR:{}".format(msg))


def UpdateCapture():
    # function used to update captures after setup
    ScriptDef.initAll()
    initAllCaptures()
    Capture.update()
    Capture.checkTargets()
    Capture.displayAll()


def traceAndCopy(kind, capture):
    return deepcopy(capture)


def copyCaptureCPRT(entity):
    kind = Kind.CPRT
    if isinstance(entity, Airframes.Kubernetes):
        return traceAndCopy(kind, Capture.get("AIC_CPRT_VDU"))
    return traceAndCopy(kind, Capture.get("CPRT_NODE_GNB{}".format(entity.index)))


def copyCaptureL1L2(entity, isMirror=False):
    kind = Kind.L1L2
    if entity is None:
        return None
    # AP Captures
    if entity.hw == Enums.HW.AP:
        if TLConfig.isL1BP:
            return traceAndCopy(kind, Capture.get("L1L2_AP_L1B"))
        if entity.profil == "LO":
            return traceAndCopy(kind, Capture.get("L1L2_AP_FS_LO"))
        else:
            return traceAndCopy(kind, Capture.get("L1L2_AP_FS"))
    # GNB Captures
    else:
        # GNB AIC
        if isinstance(entity, Airframes.Kubernetes):
            if isMirror:
                return traceAndCopy(kind, Capture.get("AIC_L1L2_VDU_MIRROR"))
            else:
                return traceAndCopy(kind, Capture.get("AIC_L1L2_VDU"))
        # GNB ASOE
        if isinstance(entity, Airscales.AsoeRack):
            if TLConfig.isL1BP:
                # GNB ASOE with L1 Bypass Airphone
                return traceAndCopy(kind, Capture.get("L1L2_AP_ASOE"))
            else:
                # GNB ASOE with Full Stack Airphone
                return traceAndCopy(kind, Capture.get("L1L2_GNB{}_FS_ASOE".format(entity.index)))
        if isinstance(entity, Airscales.AsohRack):
            return traceAndCopy(kind, Capture.get("L1L2_GNB{}_FS_ASOH".format(entity.index)))
        if TLConfig.isL1BP:
            # GNB L1PyPass
            if entity.profil == "BO" or entity.profil == "BOOO":
                # GNB L1BP BO
                return traceAndCopy(kind, Capture.get("L1L2_GNB{}_L1B_BO".format(entity.index)))
            elif entity.profil == "LO" or entity.profil == "LOO" or entity.profil == "LOOO":
                # GNB L1BP LO
                return traceAndCopy(kind, Capture.get("L1L2_GNB{}_L1B_LO".format(entity.index)))
            elif entity.profil == "BOO":
                # GNB L1BP BOO
                return traceAndCopy(kind, Capture.get("L1L2_GNB{}_L1B_BOO".format(entity.index)))
            elif TLConfig.isGnbCloud:
                # GNB L1BP CLOUD
                return traceAndCopy(kind, Capture.get("L1L2_GNB{}_L1B_CLOUD".format(entity.index)))
            # GNB L1BP CLASSICAL
            return traceAndCopy(kind, Capture.get("L1L2_GNB{}_L1B_CLASSICAL".format(entity.index)))
        # GNB FS
        if entity.profil == "BN":
            # GNB FS BN
            return traceAndCopy(kind, Capture.get("L1L2_GNB{}_FS_BN".format(entity.index)))
        elif entity.profil == "LO" or entity.profil == "LOO" or entity.profil == "LOOO":
            # GNB FS LO
            return traceAndCopy(kind, Capture.get("L1L2_GNB{}_FS_LO".format(entity.index)))
        elif entity.profil == "BO" or entity.profil == "BOO" or entity.profil == "BOOO":
            # GNB FS BO
            return traceAndCopy(kind, Capture.get("L1L2_GNB{}_FS_BO".format(entity.index)))
        elif entity.profil == "BL" or entity.profil == "BLL" or entity.profil == "BLLL":
            # GNB FS BL
            return traceAndCopy(kind, Capture.get("L1L2_GNB{}_FS_BL".format(entity.index)))
        elif entity.profil == "KL" or entity.profil == "KLL" or entity.profil == "KLLL":
            # GNB FS KL
            return traceAndCopy(kind, Capture.get("L1L2_GNB{}_FS_KL".format(entity.index)))
        elif entity.profil == "LN":
            # GNB FS LN
            return traceAndCopy(kind, Capture.get("L1L2_GNB{}_FS_LN".format(entity.index)))
        elif entity.profil == "MO":
            # GNB FS MO
            return traceAndCopy(kind, Capture.get("L1L2_GNB{}_FS_MO".format(entity.index)))
        elif entity.profil == "LP" or entity.profil == "MP":
            # GNB FS LP
            return traceAndCopy(kind, Capture.get("L1L2_GNB{}_FS_LP".format(entity.index)))
        # All other GNB FS cases
        return traceAndCopy(kind, Capture.get("L1L2_GNB{}_FS_KL".format(entity.index)))


def copyCaptureCORE(entity):
    kind = Kind.CORE
    # No Capture for AP
    assert entity.hw == Enums.HW.GNB, "No capture provided for AP for the moment"
    if isinstance(entity, Airframes.Kubernetes):
        return traceAndCopy(kind, Capture.get("AIC_CORE_VCU"))
    # GNB : Cloud
    if TLConfig.isGnbCloud:
        return traceAndCopy(kind, Capture.get("CORE_WTS_ETH3"))
    # GNB : Classical ASIB
    if entity.getSysBoardType() == "ASIB":
        return traceAndCopy(kind, Capture.get("CORE_GNB{}_SYS0_M_BR1".format(entity.index)))
    if entity.getSysBoardType() == "ASIM":
        return traceAndCopy(kind, Capture.get("CORE_GNB{}_SYS0_M_BR0".format(entity.index)))
    # GNB : Classical ASOE or ASIL
    if isinstance(entity, Airscales.AsoeRack) or isinstance(entity, Airscales.AsohRack) or \
       entity.getSysBoardType() == "ASIL":
        return traceAndCopy(kind, Capture.get("CORE_GNB{}_SYS0_M_BR0".format(entity.index)))
    # GNB : Classical Otherr
    return traceAndCopy(kind, Capture.get("CORE_GNB{}_SYS0_M_FP0".format(entity.index)))


def newCapture(interface, prefix, entity=None, host=None, node=None, scriptDef=None, filter=""):
    if entity is None:
        entity = Connect.TGNB_DU(0)
    return CapClassical(interface=interface, prefix=prefix, entity=entity, host=host,
                        node=node, scriptDef=scriptDef, filter=filter)


# For robot call
def captureGet(prefix):
    return Capture.get(prefix)


def checkProfileMP_LP(multiGnb=False):
    if not multiGnb:
        if not TLConfig.topo.isAic():
            gnb = Connect.TGNB_DU(0)
            if gnb.getProfil() == "MP" or gnb.getProfil() == "LP":
                return True
    return False
