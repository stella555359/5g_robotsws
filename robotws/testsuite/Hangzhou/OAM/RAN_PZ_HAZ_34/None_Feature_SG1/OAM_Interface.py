from taf.transport.ssh.connection import connect
import re
import time
from robot.api import logger
import os
from taf.fdsw.rc import rc
from taf.selenium.gnb.oam.coam.classical.pages.login_management import LogoutPage
from taf.ul.selenium.netact import netact
import copy
import paramiko


def ShellConnectAndInvokeShell(ip, username, password, port=22):
    asccon = connect(hostname=ip, username=username, password=password, port=22)
    ascch = asccon.invoke_shell()
    time.sleep(5)
    result = ascch.recv(1024)
    print(result)
    return asccon, ascch


def ShellExecuteCommand(ascch, cmd, timeout=60):
    ascch.send(cmd)
    time.sleep(int(timeout))
    result = ascch.recv(2048)
    return result


def ShellDisconnect(accon):
    accon.disconnect()


def search_node_folder(gnb_name, nodes):
    bts_index = int(gnb_name.split("-")[1])
    for node in nodes:
        if node.count("MRBTS") > 0:
            if node.count("...") == 0:
                continue
            scope = node.split("-")[1].split("...")
            print(scope[0], scope[1])
            min = int(scope[0])
            try:
                max = int(scope[1])
            except Exception:
                max = 100000
            print(bts_index, min, max)
            if bts_index >= min and bts_index <= max:
                return node
    return ""


def force_close_coam_webdriver():
    LogoutPage().close_browser()


class netact_extend(netact):

    def __init__(self):
        netact.__init__(self)

    def destory_netact(self):
        self._driver.quit()
        self.page_handle.clear()
        self.page_instance.clear()
        self.__init__()


class sshservice():

    def setup(self, host, username, password, port=22):
        self.host = host
        self.username = username
        self.password = password
        self.port = int(port)
        self.client = paramiko.SSHClient()
        self.client.set_missing_host_key_policy(paramiko.AutoAddPolicy())

    def __sftp_connect(self):
        transport = paramiko.Transport((self.host, self.port))
        transport.connect(username=self.username, password=self.password)
        self.sftp = paramiko.SFTPClient.from_transport(transport)

    def __sftp_disconnect(self):
        self.sftp.close()

    def __sftpservice(self, func, localpath, romotepath):
        if func == "put":
            self.sftp.put(localpath, romotepath)
        elif func == 'get':
            self.sftp.get(romotepath, localpath)

    def __client_connect(self):
        self.client.connect(
            hostname=self.host,
            port=self.port,
            username=self.username,
            password=self.password)

    def __client_disconnect(self):
        self.client.close()

    def __command(self, cmd):
        stdin, stdout, stderr = self.client.exec_command(cmd)
        return (stdout.read(), stderr.read())

    def upload_uzip(self, filename, localpath, remotepath):
        self.__client_connect()
        try:
            self.__command("mkdir {}".format(remotepath))
        except BaseException:
            pass
        self.__sftp_connect()
        localfile = "{}/{}".format(localpath, filename)
        remotefile = "{}/{}".format(remotepath, filename)
        self.__sftpservice('put', localfile, remotefile)
        self.__sftp_disconnect()
        self.__command(
            "unzip -o {}/{} -d {}/".format(remotepath, filename, remotepath))
        self.__command("rm -f {}/{}".format(remotepath, filename))
        self.__client_disconnect()

    def deleteNCF(self):
        self.__client_connect()
        try:
            self.__command("rm /ffs/fs1/config/NCF.xml")
        except BaseException:
            pass
        try:
            self.__command("rm /ffs/fs1/config/tmp_NCF.xml")
        except BaseException:
            pass
        try:
            self.__command("rm /ffs/fs2/config/NCF.xml")
        except BaseException:
            pass
        try:
            self.__command("rm /ffs/fs2/config/tmp_NCF.xml")
        except BaseException:
            pass
        self.__client_disconnect()


class fdsw_oam_extend(rc):

    def __init__(self):
        self.checkkey = {
            "FDSW18A": {
                "IP_connectivity": [
                    "config.autoconnection",
                    "ipStatus"],
                "DHCP_Server_Connection": [
                    "config.autoconnection",
                    "dhcpStatus"],
                "Certificate_update": [
                    "config.autoconnection",
                    "certificateStatus"],
                "Connection_to_Identification_Entity": [
                    "config.autoconnection",
                    "identificationEntityConnectionStatus"],
                "Software_download": [
                    "software",
                    "status",
                    "softwareDownload"]
            },
            "FDSW19A": {
                "IP_connectivity": [
                    "config.autoconnection",
                    "pnpStatus",
                    "connection",
                    'steps',
                    0,
                    'statusDetails'],
                "DHCP_Server_Connection": [
                    "config.autoconnection",
                    "pnpStatus",
                    "connection",
                    'steps',
                    1,
                    'statusDetails'],
                "Certificate_update": [
                    "config.autoconnection",
                    "pnpStatus",
                    "connection",
                    'steps',
                    2,
                    'statusDetails'],
                "Connection_to_Identification_Entity": [
                    "config.autoconnection",
                    "pnpStatus",
                    "connection",
                    'steps',
                    3,
                    'statusDetails'],
                "Connection_to_SWM_Mediator": [
                    "config.autoconnection",
                    "pnpStatus",
                    "connection",
                    'steps',
                    4,
                    'statusDetails'],
                "Connection_Status": [
                    "config.autoconnection",
                    "pnpStatus",
                    "connection",
                    'status'],
                "Software_download": [
                    "config.autoconnection",
                    "pnpStatus",
                    "configuration",
                    'steps',
                    0,
                    'statusDetails'],
                "Software_update_progress": [
                    "config.autoconnection",
                    "pnpStatus",
                    "configuration",
                    'steps',
                    1,
                    'statusDetails'],
                "Software_activation": [
                    "config.autoconnection",
                    "pnpStatus",
                    "configuration",
                    'steps',
                    2,
                    'statusDetails'],
                "Software_status": [
                    "config.autoconnection",
                    "pnpStatus",
                    "configuration",
                    'status'],
                "source": [
                    "config.autoconnection",
                    "source"],
                "protocol": [
                    "config.autoconnection",
                    "pnpProtocolParameters",
                    "selectedProtocol"],
                "omsIpAddress": [
                    "config.autoconnection",
                    "managementPlaneParameters",
                    "omsIpAddress"],
                "secondsToRestart": [
                    "config.autoconnection",
                    "secondsToRestart"]}}
        self.params = {
            "certificateServerParameters": {
                "directory": "pkix/",
                "ipAddress": "10.57.167.7",
                "serverPort": "8080",
                "subjectName": "DC=cmp, O=nokia, OU=ivtrans, CN=IPsecTest",
            },
            "managementPlaneParameters": {
                "gateway": "10.57.247.81",
                "ipAddress": "10.57.247.84",
                "omsIpAddress": "10.32.180.32",
                "prefixLength": "28"
            }
        }

    def set_fdsw_conn_header(self, conn):
        conn._fdsw_interface._client.headers['Connection'] = "close"

    def _get_value_by_key(self, data, version, key):
        dictpath = self.checkkey[version][key]
        r_val = data
        for path in dictpath:
            r_val = r_val[path]
        return r_val

    def fetch_value_by_checkkey(self, conn, checkkeys):
        r = conn._fdsw_interface._client.send('fetch', {}, timeout=60)
        error = r.error
        loop = 0
        while loop < 5 and error is not None:
            conn._fdsw_interface._client.connect()
            time.sleep(30)
            r = conn._fdsw_interface._client.send('fetch', {}, timeout=60)
            error = r.error
            loop = loop + 1
        version = conn._fdsw_interface.VERSION_NAME
        print(version)
        if version != "FDSW18A":
            version = "FDSW19A"
        data = r.data
        r_val = []
        print(version)
        for ck in checkkeys:
            if ck in self.checkkey[version]:
                tmp = self._get_value_by_key(data, version, ck)
                r_val.append(tmp)
            else:
                r_val.append(None)
        return r_val

    # def check_version(self, conn, t_version):
    #     version = conn._fdsw_interface.VERSION_NAME
    #     if version == t_version.upper():
    #         return True
    #     else:
    #         return False

    def __form_set_parms(self, changes, version):
        parms = copy.deepcopy(self.params)
        for key in changes:
            path = self.checkkey[version][key]
            if path[0] == "config.autoconnection":
                parms[path[1]][path[2]] = changes[key]
        return parms

    def autoconnection_restore_defaults(self, conn, timeout=120):
        conn._fdsw_interface._client.send(
            "config.autoconnection.restoreDefaults", {}, timeout=timeout)

    def fetch_data_by_api(self, conn, timeout=60):
        res = conn._fdsw_interface._client.send('fetch', {}, timeout=timeout)
        return res.data

    def set_autoconnection_params(self, conn, set_params, timeout=60):
        r = conn._fdsw_interface._client.send(
            'config.autoconnection.tryUpdate', set_params, timeout=timeout)
        if r.data is not None:
            raise Exception("Parameter update failed!")

    def __match_changes(self, conn, params, protocol):
        res = self.fetch_data_by_api(conn)
        data = res["config.autoconnection"]
        set_params = {}
        set_params['current'] = {}
        set_params['current']["certificateServerParameters"] = data["certificateServerParameters"]
        set_params['current']["managementPlaneParameters"] = data["managementPlaneParameters"]
        set_params['candidate'] = {}
        for subp in params:
            for p in params[subp]:
                if params[subp][p] != data[subp][p]:
                    if subp not in set_params['candidate']:
                        set_params['candidate'][subp] = {}
                    set_params['candidate'][subp][p] = params[subp][p]
        if "pnpProtocolParameters" in data:
            set_params['current']["pnpProtocolParameters"] = data["pnpProtocolParameters"]
            set_params['candidate']["pnpProtocolParameters"] = {
                "selectedProtocol": protocol}
        return set_params

    # def set_autoconnection_changes(self, conn, changes, protocol='LEGACY'):
    #     version = conn._fdsw_interface.VERSION_NAME
    #     params = self.__form_set_parms(changes, version)
    #     set_params = self.__match_changes(conn, params, protocol)
    #     if set_params['candidate'] != {}:
    #         self.set_autoconnection_params(conn, set_params)

    def set_autoconnection_userparams(self, conn, params, protocol='LEGACY'):
        set_params = self.__match_changes(conn, params, protocol)
        if set_params['candidate'] != {}:
            self.set_autoconnection_params(conn, set_params)

    def check_autoconnection_userparams(self, conn):
        res = self.fetch_data_by_api(conn)
        data = res["config.autoconnection"]
        params = self.params
        for subp in params:
            for p in params[subp]:
                if params[subp][p] != data[subp][p]:
                    raise Exception(
                        "Parameter:" +
                        subp +
                        "-" +
                        p +
                        " set: " +
                        params[subp][p] +
                        " != get: " +
                        data[subp][p])

    def get_diagnostics(self, conn, timeout=60):
        try:
            res = conn._fdsw_interface._client.send(
                'diagnostics.pnp.download', {}, timeout=timeout)
            return res.data
        except Exception as error:
            return str(error)

    def match_keywords_in_diagnostics(self, conn, keywords):
        logs = self.get_diagnostics(conn)
        res = []
        for kw in keywords:
            finds = re.findall(kw, logs)
            res.append(len(finds))
        return res
