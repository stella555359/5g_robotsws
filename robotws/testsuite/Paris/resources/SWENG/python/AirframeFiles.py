import re
import StringTool


# =================================================================================================
# General class for an Airframe file (out of a container) on a K8sNode
# =================================================================================================
class AirframeFile(object):
    def __init__(self, k8sNode, path, name):
        self.k8sNode = k8sNode
        self.path = path
        self.name = name
        self.setFullPath()

    def setFullPath(self):
        self.fullPath = f"{self.path}/{self.name}"

    def __str__(self):
        if len(self.name) > 0:
            return self.fullPath
        return ""

    def cmd(self, cmd, isSendCommand=False, debug=False):
        return self.k8sNode.sshCmd(cmd=cmd, isSendCommand=isSendCommand, debug=debug)

    def unzip(self):
        # switch case upon extension of the file. Do nothing otherwise
        # return a table of all unzipped files
        if self.name.endswith(AirframeZipFile.EXT):
            return AirframeZipFile(self.k8sNode, self.path, self.name).unzip()
        if self.name.endswith(AirframeXzFile.EXT):
            return AirframeXzFile(self.k8sNode, self.path, self.name).unzip()
        return [self]


# =================================================================================================
# Airframe file with .zip extension
# =================================================================================================
class AirframeZipFile(AirframeFile):
    EXT = ".zip"
    MARK = "-----"

    def unzip(self):
        # Unzip initial file
        self.cmd(f"cd {self.path};unzip {self.name}", isSendCommand=True)
        # Compute names of all unzipped files and create a AirframeFile for each
        output = self.cmd(f"cd {self.path};unzip -l {self.name}", isSendCommand=False)
        list = []
        lineMarker = False
        for line in output.split("\n"):
            if line.startswith(AirframeZipFile.MARK):
                lineMarker = not lineMarker
            elif lineMarker:
                # Catching only lines between first "-----" entre second "-----"
                # Taking last field as file name
                file = StringTool.getStringFromCmdReturn(line).split(" ")[-1]
                list.append(AirframeFile(self.k8sNode, self.path, file))
        # Return list of files contained in zip file
        return list


# =================================================================================================
# Airframe file with .xz extension
# =================================================================================================
class AirframeXzFile(AirframeFile):
    EXT = ".xz"

    def unzip(self):
        # Hypohtesis : a .xz , once unzipped, leads to a unique file (without .xz extension)
        self.cmd(f"cd {self.path};xz -d {self.name}", isSendCommand=True)
        # New extension is same as previous, but without .xz
        name = self.name.replace(AirframeXzFile.EXT, "")
        # Return list of files contained in zip file (here unique file)
        return [AirframeFile(self.k8sNode, name, self.path)]


# =================================================================================================
# Log file on Airframe n a K8sNode (out of any container)
# =================================================================================================
class LogFile(AirframeFile):
    def __init__(self, k8sNode, prefix, name, path):
        super(LogFile, self).__init__(k8sNode=k8sNode, path=path, name=name)
        self.prefix = prefix
        self.name = self.getName(name)
        self.setFullPath()

    def getName(self, name=""):
        # We search the name upon the prefix
        if len(name) == 0:
            output = self.cmd(f"ls {self.path} | grep {self.prefix}")
            if len(output) != 0:
                output = re.sub(' +', ' ', output)
                output = re.sub('\t', ' ', output)
                tab = output.split(" ")
                for str in tab:
                    if str.startswith(self.prefix):
                        name = StringTool.getStringFromCmdReturn(str)
        return name


# =================================================================================================
# LogFileContainer is a file inside a container
# =================================================================================================
class LogFileContainer(LogFile):
    def __init__(self, container, prefix, path="tmp"):
        self.container = container
        super(LogFileContainer, self).__init__(container.pod.node, prefix, "", path)

    def cmd(self, cmd):
        return self.container.cmd(cmd)

    def copyToLogDir(self):
        #  create the directory /tmp/LOGS/<container>
        dstPath = f"/tmp/LOGS/{self.container.name}"
        self.k8sNode.sshCmd(f"mkdir -p {dstPath}")
        # Transfert log file from container to /tmp/LOGS/<container>/
        self.container.copyFile(sourcePath=self.fullPath, destPath=f"{dstPath}/{self.name}")
        # Return new copied file as a log
        return LogFile(k8sNode=self.k8sNode, prefix=self.prefix, name=self.name, path=dstPath)

    def unzip(self):
        # Take the firt file contained in zip/xz file
        # We suppose all log file is containing only one file
        return self.copyToLogDir().unzip()[0]


# =================================================================================================
# Logs is a dictionary of all pertinent logs for a container
# =================================================================================================
class Logs(object):
    LOG_PREFIX_DEFAULT_NAME = "startup_DEFAULT"
    LOG_PREFIX_LINUX_NAME = "LINUX_startup"
    LOG_PREFIX_LIST = [LOG_PREFIX_DEFAULT_NAME, LOG_PREFIX_LINUX_NAME]

    def __init__(self, container):
        self.container = container
        self.logFiles = {}
        self.discovered = False

    def discover(self):
        if self.container.state.isOK():
            for prefix in Logs.LOG_PREFIX_LIST:
                self.logFiles[prefix] = LogFileContainer(self.container, prefix)
        self.discovered = True

    def display(self):
        header = (f"LOG for {self.container.pod.node.name}:"
                  f"POD={self.container.pod.name:50} Container={self.container.name:50}:")
        diag = ""
        if self.container.state.isOK():
            for prefix in Logs.LOG_PREFIX_LIST:
                diag += f"{self.logFiles[prefix]} "
            if len(diag) > 0:
                StringTool.datedConsole(f"{header}{diag}")

    def unzip(self):
        if self.container.state.isOK():
            for prefix in Logs.LOG_PREFIX_LIST:
                if len(self.logFiles[prefix].name) > 0:
                    return self.logFiles[prefix].unzip()
