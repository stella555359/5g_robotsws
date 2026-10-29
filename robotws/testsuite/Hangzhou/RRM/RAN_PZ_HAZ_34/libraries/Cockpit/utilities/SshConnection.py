import paramiko
import time
import select
import socket
from taf.transport.ssh.proxy import ParaProxy
from ..Cockpit_Debug import debugWrite


class SshConnection:
    def __init__(self):
        self.end_cli = None
        pass

    def connect(self, tlInfo, swModule):
        self._tlInfo = tlInfo
        self._swModule = swModule
        firstHop = self._swModule
        secondHop = self._swModule
        if self._swModule in (
            "cncp-0",
            "uecp-0",
            "ueup-0",
            "rap01",
            "cpcl-0",
            "cpif-0",
            "cpnb-0",
            "cpue-0",
                "upue-0"):
            firstHop = "oam-0"
        # if self._swModule in ("asik",):
        # firstHop = "testPC"
        if self._swModule in ("fspj-1a", "ru"):
            firstHop = "oam-0"
            secondHop = "rap01"
        if self._swModule in ("fct-0a", "asik"):
            firstHop = "testPC"
        if self._swModule in ("abil", "fct-0b", "fct-4b", "asp-1a", "asp-1b", "aspa-1c"):
            firstHop = "testPC"
            secondHop = "fct-0a"

        proxy = None
        if (self._tlInfo["sshProxy"] is not None):
            # Connecting to MiddleMachine and executing netcat
            mid_cli = paramiko.SSHClient()
            mid_cli.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            debugWrite(
                "Connecting though " +
                self._tlInfo["sshProxy"]["hostname"])
            mid_cli.connect(hostname=self._tlInfo["sshProxy"]["hostname"],
                            username=self._tlInfo["sshProxy"]["username"],
                            password=self._tlInfo["sshProxy"]["password"])
            io_tupple = mid_cli.exec_command(
                'nc ' + self._tlInfo[firstHop]["hostname"] + ' 22')
            # Instantiate the 'masquerader' class
            proxy = ParaProxy(*io_tupple)

        proxy2 = proxy
        if (firstHop != secondHop):
            # Connecting to MiddleMachine and executing netcat
            mid_cli2 = paramiko.SSHClient()
            mid_cli2.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            debugWrite(
                "Connecting though " +
                self._tlInfo[firstHop]["hostname"])
            mid_cli2.connect(
                hostname=self._tlInfo[firstHop]["hostname"],
                username=self._tlInfo[firstHop]["username"],
                password=self._tlInfo[firstHop]["password"],
                sock=proxy)
            io_tupple2 = mid_cli2.exec_command(
                'nc ' + self._tlInfo[secondHop]["hostname"] + ' 22')
            # Instantiate the 'masquerader' class
            proxy2 = ParaProxy(*io_tupple2)

        proxy3 = proxy2
        if (secondHop != self._swModule):
            # Connecting to MiddleMachine and executing netcat
            mid_cli3 = paramiko.SSHClient()
            mid_cli3.set_missing_host_key_policy(paramiko.AutoAddPolicy())
            debugWrite(
                "Connecting though " +
                self._tlInfo[secondHop]["hostname"])
            mid_cli3.connect(hostname=self._tlInfo[secondHop]["hostname"],
                             username=self._tlInfo[secondHop]["username"],
                             password=self._tlInfo[secondHop]["password"],
                             sock=proxy2)
            io_tupple3 = mid_cli3.exec_command(
                'nc ' + self._tlInfo[self._swModule]["hostname"] + ' 22')
            # Instantiate the 'masquerader' class
            proxy3 = ParaProxy(*io_tupple3)

        # Connecting to AnotherMachine and executing... anything...
        self.end_cli = paramiko.SSHClient()
        self.end_cli.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        debugWrite("Connecting to " + self._tlInfo[self._swModule]["hostname"])
        self.end_cli.connect(hostname=self._tlInfo[self._swModule]["hostname"],
                             username=self._tlInfo[self._swModule]["username"],
                             password=self._tlInfo[self._swModule]["password"],
                             sock=proxy3)
        debugWrite("Connected to " + self._tlInfo[self._swModule]["hostname"])

    def fileList(self, sourceFolder):
        sftp = self.end_cli.open_sftp()
        returnValue = sftp.listdir(sourceFolder)
        sftp.close()
        return (returnValue)

    def downloadFile(self, sourceFile, destFile):
        sftp = self.end_cli.open_sftp()
        sftp.get(sourceFile, destFile)
        sftp.close()

    def uploadFile(self, sourceFile, destFile):
        sftp = self.end_cli.open_sftp()
        sftp.put(sourceFile, destFile)
        sftp.close()

    def executeAndWaitEnd(self, cmd, timeout=5):
        returnValue = ""
        debugWrite("executeAndWaitEnd: " + cmd)

        transport = self.end_cli.get_transport()
        channel = transport.open_session()
        channel.get_pty()
        channel.setblocking(1)
        channel.settimeout(1)

        channel.exec_command(cmd)

        while not channel.exit_status_ready() and timeout > 0:
            timeout -= 1
            debugWrite("executeAndWaitEnd sleeping")
            time.sleep(1)

        while channel.recv_ready():
            recvData = channel.recv(4096).decode(errors='ignore')
            returnValue += recvData
            # debugWrite("executeAndWaitEnd recv:", recvData)

        channel.close()

        return (returnValue)

    def exec_command(self, cmd):
        return (self.end_cli.exec_command(cmd))

    def get_transport(self):
        return (self.end_cli.get_transport())

    def open_sftp(self):
        return (self.end_cli.open_sftp())

    def close(self):
        self.end_cli.close()
        self.end_cli = None
