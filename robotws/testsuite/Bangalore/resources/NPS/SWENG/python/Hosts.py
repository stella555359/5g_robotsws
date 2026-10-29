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
        return "Alias={:15} Kind={} Board={}  BSH(S:P)={}:{} SSH={:10} NodeId={:6} {:43} Status={}"\
            .format(self.alias, self.kind, self.boardType, self.slot, self.proc,
                    str(self.sshId), str(self.nodeId), self.getProxyStr(), self.status)

    def getProxyStr(self):
        proxyStr = ""
        if self.hasProxy:
            proxyStr += "Proxy={}".format(self.proxy.alias)
            if self.isRoot:
                proxyStr += "({}) ".format(self.proxy.sshConnection.addr)
        if self.isRoot:
            proxyStr += "@={}".format(self.sshConnection.addr)
        return proxyStr

    def shortName(self):
        return "{} (Alias={})".format(self.sshConnection.addr, self.alias)

    def display(self, prefix=None):
        prefixStr = ""
        if prefix is not None:
            prefixStr = "{}.{:2}:".format(prefix, Card.Card.ROLE_STR[int(self.proc)])
        StringTool.prefixDatedConsole("    {}{}".format(prefixStr, self))

    def setSshConnection(self, sshConnection):
        self.sshConnection = sshConnection

    def getSudoPrefix(self):
        if self.isSudo:
            return "sudo "
        return ""

    def isReachable(self):
        try:
            csn = ssh()
            csn.connect_to(hostname=self.sshConnection.addr, username=self.sshConnection.username,
                           password=self.sshConnection.password, alias=self.alias)
            return True
        except Exception as e:
            return False

    def getSshAddr(self):
        if self.isRoot or self.sshId is None:
            return self.sshConnection.addr
        return self.sshId

    def connect(self):
        csn = ssh()
        try:
            if self.proxy is None:
                # StringTool.datedConsole("SSH DEBUG - No proxy => Direct Connection to {} with log/pwd={}/{}"
                #                         .format(self.sshConnection.addr,
                #                                 self.sshConnection.username,
                #                                 self.sshConnection.password
                #                                 )
                #                         )
                csn.connect_to(hostname=self.sshConnection.addr, username=self.sshConnection.username,
                               password=self.sshConnection.password, alias=self.alias)
            else:
                proxyCsn = self.proxy.connect()
                sshAddr = self.getSshAddr()
                # StringTool.datedConsole("SSH DEBUG - Proxy => Proxy Connection to {} with log/pwd={}/{}"
                #                         .format(sshAddr,
                #                                 self.sshConnection.username,
                #                                 self.sshConnection.password,
                #                                 self.proxy.alias, self.alias
                #                                 )
                #                         )
                proxyCsn.connect_to(hostname=sshAddr, username=self.sshConnection.username,
                                    password=self.sshConnection.password, proxy=self.proxy.alias, alias=self.alias)
                # RDH: sept-2022
                # StringTool.datedConsole("SSH DEBUG - Proxy - Call proxyCsn.force_reconnect to:{}".format(self.alias))
                proxyCsn.force_reconnect(connection=self.alias)
        except Exception as e:
            StringTool.datedConsole("ERROR:Unable to connect on {} [addr={}]".format(self.shortName(), sshAddr))
            StringTool.datedConsole("SSH EXCEPTION={}".format(e))
        return csn

    def cmd(self, cmd, isSendCommand=False):
        # StringTool.datedConsole("CMD: HOST={} CMD={}".format(self.shortName(),cmd))
        output = None
        try:
            csn = self.connect()
            if isSendCommand:
                output = csn.send_command(command=cmd, connection=self.alias)
            else:
                # StringTool.datedConsole("  CMD:Start csn.execute(command={}, connection={})".format(cmd, self.alias))
                output = csn.execute(command=cmd, connection=self.alias)
                # StringTool.datedConsole("  CMD:End   csn.execute(command={}, connection={})".format(cmd, self.alias))
            csn.disconnect(connection=self.alias)
            # StringTool.datedConsole("HOST={} RES={}".format(self.shortName(),output))
        except Exception as e:
            StringTool.datedConsole("Unable to launch cmd [{}] on [{}]".format(cmd, self.sshConnection.addr))
        return output

    def downloadFile(self, remote_path, local_path):
        try:
            csn = self.connect()
            csn.download_file(remote_path=remote_path, local_path=local_path, connection=self.alias)
            csn.disconnect(connection=self.alias)
        except Exception as e:
            StringTool.datedConsole("Unable to download [{}] on [{}]".format(remote_path, self.sshConnection.addr))
