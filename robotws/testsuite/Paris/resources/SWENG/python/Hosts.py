import StringTool
import Card
from taf.transport.ssh import ssh
from robot.libraries.BuiltIn import BuiltIn
import traceback


# ===============================================================================================
# HOST
# ===============================================================================================
class Host(object):
    def __init__(self, alias, sshConnection=None, boardType=None, ip=None, sshId=None,
                 slot=None, proc=None, proxy=None, nodeId=None, card=None, kind=None,
                 isSudo=False, status=True):
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
        self.isSudo = isSudo
        self.status = status
        self.isRoot = self.proc == "0" and self.slot == "0"

    def __str__(self):
        return f"Alias={self.alias:15} Kind={self.kind} Board={self.boardType}  BSH(S:P)={self.slot}:{self.proc} " \
               f"SSH={str(self.sshId):10} NodeId={str(self.nodeId):6} {self.getProxyStr():43} Status={self.status}"

    def getProxyStr(self):
        proxyStr = ""
        if self.hasProxy:
            proxyStr += f"Proxy={self.proxy.alias}"
            if self.isRoot:
                if hasattr(self.proxy.sshConnection, 'addr'):
                    proxyStr += f"({self.proxy.sshConnection.addr}) "
                elif hasattr(self.proxy.sshConnection, 'hostname'):
                    proxyStr += f"({self.proxy.sshConnection.hostname}) "
                elif hasattr(self.proxy.sshConnection, 'params'):
                    proxyStr += f"({self.proxy.sshConnection.params['hostname']}) "
        if self.isRoot:
            if hasattr(self.sshConnection, 'addr'):
                proxyStr += f"@={self.sshConnection.addr}"
            elif hasattr(self.sshConnection, 'hostname'):
                proxyStr += f"@={self.sshConnection.hostname}"
            elif hasattr(self.sshConnection, 'params'):
                proxyStr += f"({self.sshConnection.params['hostname']}) "
        return proxyStr

    def shortName(self):
        if hasattr(self.sshConnection, 'addr'):
            shortName = f"{self.sshConnection.addr}"
        elif hasattr(self.sshConnection, 'hostname'):
            shortName = f"{self.sshConnection.hostname}"
        elif hasattr(self.sshConnection, 'params'):
            shortName = f"{self.sshConnection.params['hostname']}"
        return f"{shortName} (Alias={self.alias})"

    def display(self, prefix=None):
        prefixStr = ""
        if prefix is not None:
            prefixStr = f"{prefix}.{Card.Card.ROLE_STR[int(self.proc)]:2}:"
        StringTool.prefixDatedConsole(f"    {prefixStr}{self}")

    def setSshConnection(self, sshConnection):
        self.sshConnection = sshConnection

    def getSudoPrefix(self):
        if self.isSudo:
            return "sudo "
        return ""

    def isReachable(self):
        ipaddr, usname, pwd = self._get_connection_values()
        try:
            csn = ssh()
            csn.connect_to(hostname=ipaddr, username=usname, password=pwd, alias=self.alias)
            return True
        except Exception as e:
            return False

    def getSshAddr(self):
        if self.isRoot or self.sshId is None:
            if hasattr(self.sshConnection, 'addr'):
                ipaddr = self.sshConnection.addr
            elif hasattr(self.sshConnection, 'hostname'):
                ipaddr = self.sshConnection.hostname
            elif hasattr(self.sshConnection, 'params'):
                ipaddr = self.sshConnection.params['hostname']
            return ipaddr
        return self.sshId

    def connect(self):
        ipaddr, usname, pwd = self._get_connection_values()
        csn = ssh()
        sshAddr = self.getSshAddr()
        print(f"Connecting to [addr={ipaddr}]")
        try:
            if self.proxy is None:
                csn.connect_to(hostname=ipaddr, username=usname, password=pwd, alias=self.alias)
            else:
                proxyCsn = self.proxy.connect()
                proxyCsn.connect_to(hostname=sshAddr, username=usname,
                                    password=pwd, proxy=self.proxy.alias, alias=self.alias)
                proxyCsn.force_reconnect(connection=self.alias)
        except Exception as e:
            StringTool.datedConsole(f"ERROR:Unable to connect on {self.shortName()} [addr={sshAddr}]")
            StringTool.datedConsole(f"SSH EXCEPTION={e}")
        return csn

    def _get_connection_values(self):
        ipaddr = None
        usname = None
        pwd = None
        if hasattr(self.sshConnection, 'addr'):
            ipaddr = self.sshConnection.addr
        elif hasattr(self.sshConnection, 'hostname'):
            ipaddr = self.sshConnection.hostname
        elif hasattr(self.sshConnection, 'params'):
            ipaddr = self.sshConnection.params['hostname']
        if hasattr(self.sshConnection, 'username') and hasattr(self.sshConnection, 'password'):
            usname = self.sshConnection.username
            pwd = self.sshConnection.password
        elif hasattr(self.sshConnection, 'params'):
            usname = self.sshConnection.params['username']
            pwd = self.sshConnection.params['password']
        return ipaddr, usname, pwd

    def cmd(self, cmd, isSendCommand=False):
        output = None
        try:
            csn = self.connect()
            if isSendCommand:
                output = csn.send_command(command=cmd, connection=self.alias)
            else:
                output = csn.execute(command=cmd, connection=self.alias)
            csn.disconnect(connection=self.alias)
        except Exception as e:
            StringTool.datedConsole(f"Unable to launch cmd [{cmd}]: output={output}")
            StringTool.datedConsole(f"Stacktrace:\n{traceback.format_exc()}")
        return output

    def downloadFile(self, remote_path, local_path):
        try:
            csn = self.connect()
            csn.download_file(remote_path=remote_path, local_path=local_path, connection=self.alias)
            csn.disconnect(connection=self.alias)
            return True
        except Exception as e:
            StringTool.datedConsole(f"Unable to download [{remote_path}]")
            return False

    def uploadFile(self, local_path, remote_path):
        try:
            csn = self.connect()
            csn.upload_file(local_path=local_path, remote_path=remote_path, connection=self.alias)
            csn.disconnect(connection=self.alias)
            return True
        except Exception as e:
            StringTool.datedConsole(f"Unable to upload [{local_path}]")
            StringTool.datedConsole(f"Stacktrace:\n{traceback.format_exc()}")
            return False
