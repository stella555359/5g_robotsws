# -*- coding: utf-8 -*-
"""
Keywords to help filtering lists of alarms
:copyright: Nokia Networks
:author: Amaand.li@nokia-sbell.com
:maintainer: Amaand.li@nokia-sbell.com
"""
import paramiko
import logging
import os
from collections import namedtuple
from robot.api import logger
from datetime import datetime
from contextlib import contextmanager
import zipfile
import xml.etree.ElementTree as ET
import subprocess

# import StringIO

SNAPSHOT_TIMEOUT = 25 * 60

output_ssh = namedtuple('output_ssh', 'stdout return_code')


@contextmanager
def chdir(path):
    cwd = os.getcwd()
    os.chdir(path)
    try:
        yield
    finally:
        os.chdir(cwd)


class DownloadFile(object):

    def __init__(self, ip, user, passwd, port, path_container, local_path):
        self.ip = ip
        self.user = user
        self.passwd = passwd
        self.port = port
        self.path_container = path_container
        self.local_path = local_path
        self.sftp = self.connect_sftp()

    def connect_sftp(self):
        transfer = paramiko.Transport(self.ip, self.port)
        transfer.connect(username=self.user, password=self.passwd)
        sftp = paramiko.SFTPClient.from_transport(transfer)
        return transfer

    def close(self, client):
        self.sftp.close()

    def download_file(self, remote_path, local_path):
        self.sftp.get(remote_path, local_path)


class SSHExecutor(object):

    def __init__(self):
        self.ip = None
        self.via_ip = None
        self.user = 'toor4nsn'
        self.password = 'oZPS0POrRieRtu'
        self.via_user = 'toor4nsn'
        self.via_password = 'oZPS0POrRieRtu'

    def set_connection_parameters(self, ip, user=None, password=None,
                                  via_ip=None, via_user=None, via_password=None):
        """
        Set connection parameters for keyword Run Command
        | **Full description:**
        | Keyword Set Connection Parameters, set up ssh connection parameters before Run Command keyword.

        **Input Parameters:**

        +------------------+------+------------------------------+
        | Input Parameters | Man. | Description                  |
        +==================+======+==============================+
        | ip               | Yes  | ip destination host          |
        +------------------+------+------------------------------+
        | user             | No   | user name (default toor4nsn) |
        +------------------+------+------------------------------+
        | password         | No   | password  (default password) |
        +------------------+------+------------------------------+
        | via_ip           | No   | ip intermediary host         |
        +------------------+------+------------------------------+
        | via_user         | No   | user name (default toor4nsn) |
        +------------------+------+------------------------------+
        | via_password     | No   | password  (default password) |
        +------------------+------+------------------------------+

        **Example:**

        | Set up ssh connection parameters:
        .. code-block:: robotframework

            Set Connection Parameters  xxx.xxx.xxx.xxx  user=joey  password=sandwiches

        | Set up ssh connection parameters with server via another server:
        .. code-block:: robotframework

            Set Connection Parameters  xxx.xxx.xxx.xxx  user=joey  password=sandwiches  via_ip=yyy.yyy.yyy.yyy
            ...  via_user=rachel  via_password=shopping

        | Set up ssh connection parameters wit System Module:
        .. code-block:: robotframework

            Set Connection Parameters  192.168.255.129

        | Set up ssh connection parameters with Extension System Module via System Module:
        .. code-block:: robotframework

            Set Connection Parameters  192.168.255.3  via_ip=192.168.255.129

        | **Return value:**
        | None
        """

        self.ip = ip
        self.via_ip = via_ip or self.via_ip
        self.user = user or self.user
        self.password = password or self.password
        self.via_user = via_user or self.via_user
        self.via_password = via_password or self.via_password

    def run_command(self, cmd, ex_st=True):
        """
        Run command on remote
        | **Full description:**
        | Keyword Run Command, connect via ssh and execute command.
        | Before Run Command keyword you have to use Set Connection Parameters keywords,
        | to set up ssh connection parameters.

        **Input Parameters:**

        +------------------+------+------------------------------+
        | Input Parameters | Man. | Description                  |
        +==================+======+==============================+
        | cmd              | Yes  | Linux command to execute.    |
        +------------------+------+------------------------------+
        | ex_st            | No   | default True                 |
        +------------------+------+------------------------------+

        **Example:**

        | Set up ssh connection parameters and execute command
        .. code-block:: robotframework

            Set Connection Parameters  123.123.123.123  user=joey  password=sandwiches
            ${output}=  Run Command  pwd
            Log  ${output.stdout}  console=yes          # /home/joey (logged value)
            Log  ${output.exit_status}  console=yes     # 0 (logged value)

        | Set connection to ESM via MSM and execute command
        .. code-block:: robotframework

            Set Connection Parameters  192.168.255.119  via_ip=192.168.255.129
            ${output}=  Run Command  pwd
            Log  ${output.stdout}  console=yes          # /root (logged value)
            Log  ${output.exit_status}  console=yes     # 0 (logged value)

        | Set connection to host (123.123.123.123) via other_host (234.234.234.234) and execute command
        .. code-block:: robotframework

            Set Connection Parameters  123.123.123.123  user=joey  password=sandwiches  via_ip=234.234.234.234
            ...  via_user=rachel  via_password=shopping
            ${output}=  Run Command  pwd
            Log  ${output.stdout}  console=yes          # /home/joey (logged value)
            Log  ${output.exit_status}  console=yes     # 0 (logged value)

        | **Return value:**
        | Output tuple containing two parameters:
        | string output from Linux console, and exit status.
        """

        if self.via_ip and self.ip:
            logger.debug('[hran-ssh] Connection parameters: ip: {} via_ip: {}'.format(self.ip, self.via_ip))
            tunnel = paramiko.Transport((self.via_ip, 22))
            tunnel.start_client()

            try:
                tunnel.auth_password(self.via_user, self.via_password)
            except paramiko.ssh_exception.SSHException:
                # full_path = os.path.expanduser("/home/ute/.ssh/id_rsa")
                # f = open("/home/ute/.ssh/id_rsa")
                # s = f.read()
                # keyfile = StringIO.StringIO(s)
                full_path = os.path.expanduser("~/.ssh/id_rsa")
                rsa_key = paramiko.RSAKey.from_private_key_file(full_path)
                tunnel.auth_publickey(username=self.user, key=rsa_key)
                # rsa_key = paramiko.RSAKey.from_private_key_file(keyfile)
                # tunnel.auth_publickey(username=self.user, key=rsa_key)

            channel = tunnel.open_channel('direct-tcpip', (self.ip, 22), ('127.0.0.1', 0), timeout=1800)
            transport = paramiko.Transport(channel)
        elif self.ip:
            logger.debug('[hran-ssh] Connection parameters: ip: {}'.format(self.ip))
            transport = paramiko.Transport((self.ip, 22))
        else:
            raise IncorrectSetConnectionParameters

        transport.start_client()

        try:
            transport.auth_password(self.user, self.password)
        except paramiko.ssh_exception.SSHException:
            full_path = os.path.expanduser("~/.ssh/id_rsa")
            rsa_key = paramiko.RSAKey.from_private_key_file(full_path)
            transport.auth_publickey(username=self.user, key=rsa_key)

        channel_two = transport.open_session(timeout=1800)
        channel_two.set_combine_stderr(True)
        channel_two.exec_command(cmd)

        buf = b''
        while not channel_two.closed or channel_two.recv_ready():
            buf += channel_two.recv(4096)

        if ex_st:
            exit_status = channel_two.recv_exit_status()  # Blocks until command succeeds, or returns -1
        else:
            exit_status = None

        logger.debug('\n[sshexecutor] Command: {}\nOutput: {}\nReturn code: {}\n'.format(cmd, buf, str(exit_status)))
        result = output_ssh(stdout=str(buf.decode()), return_code=exit_status)
        transport.close()
        return result


class SSHSystemModuleOperations(object):

    def __init__(self):
        self.sm_ip = '192.168.255.129'
        self.esm_ip = '192.168.255.119'
        self.sm_user = 'toor4nsn'
        self.sm_pass = 'oZPS0POrRieRtu'
        self.ssh = None

    def _setup_connection(self, ip, user=None, password=None, via_ip=None, via_user=None, via_password=None):
        self.ssh = SSHExecutor()
        self.ssh.set_connection_parameters(ip, user=user, password=password,
                                           via_ip=via_ip, via_user=via_user, via_password=via_password)

    def collect_snapshot_via_ssh(self, path_container, sm_ip=None):
        """
        Collect snapshot

        .. warning::
            This keyword should be use only in case OAM collect snapshot functionality don't work.
            Collect snapshot only from MSM
        | **Full description:**
        | Keyword collect snapshot (YYYY_MM_DD_HH_MM_snapshot.zip)
        | Alternative way for collecting snapshot in case when OAM functionality
        | is not working, according to TAT-4836.

        **Input Parameters:**

        +------------------+------+----------------------------------------------+
        | Input Parameters | Man. | Description                                  |
        +==================+======+==============================================+
        | path_container   | Yes  | destination of downloaded file               |
        +------------------+------+----------------------------------------------+
        | sm_ip            |  No  | alternative SM IP (192.168.255.129 is default)|
        +------------------+------+----------------------------------------------+

        **Example:**

        .. code-block:: robotframework

            ${full_path_to_snapshot}=  Collect Snapshot Via Ssh  /home/ute/Download

        | **Return value:**
        | Path to zip file in local machine.
        | For example: /home/ute/Download/YYYY_MM_DD_HH_MM_snapshot.zip

        """
        snapshot_path = self._collect_snapshot_via_ssh(path_container, sm_ip=sm_ip)
        self._verify_snapshot_content(snapshot_path)

    def _collect_snapshot_via_ssh(self, path_container, sm_ip=None):
        if sm_ip is None:
            logging.debug("No sm_ip variable passed. Using default value: {}".format(self.sm_ip))
            sm_ip = self.sm_ip
        self._setup_connection(sm_ip)
        dt = datetime.now()
        name_snapshot = '{}_snapshot.zip'.format(dt.strftime("%Y_%m_%d_%H_%M"))
        logging.debug('Collecting snapshot started from {}'.format(sm_ip))
        self.ssh.run_command('nc localhost 15007 <<<"log -a -z /ffs/run/trs_data/db/{}" 2>/dev/null'.format(
            name_snapshot), ex_st=False)
        logging.debug('Sent snapshot command to BTS')
        with chdir(path_container):
            try:
                logging.debug('Downloading snapshot from {}'.format(sm_ip))
                remote_path = '/ffs/run/trs_data/db/' + name_snapshot
                local_path = os.path.join(path_container, name_snapshot)
                trans = self._download_file(sm_ip, self.sm_user, self.sm_pass, '22', remote_path, local_path)
                trans.close()
            finally:
                self.remove_file_from_smod('/ffs/run/trs_data/db/{}'.format(name_snapshot), sm_ip=sm_ip)

        return os.path.join(path_container, name_snapshot)

    def collect_snapshot_via_ssh_from_esm(self, path_container, esm_vm_ip):
        """
        Collect snapshot from esm

        .. warning::
            This keyword should be use only in case OAM collect snapshot functionality don't work.
            Collect snapshot only from ESM

        | **Author:** michal.kwasniewicz@nokia.com
        | **Maintainers:** szymon.skwirut@nokia.com
        | **Released with version:** 2.2.0

        | **Full description:**
        | Keyword collect snapshot (YYYY_MM_DD_HH_MM_snapshot.zip)
        | Alternative way for collecting snapshot in case when OAM functionality
        | is not working, according to TAT-4836 and TAT-13194

        **Input Parameters:**

        +------------------+------+--------------------------------+
        | Input Parameters | Man. | Description                    |
        +==================+======+================================+
        | path_container   | Yes  | destination of downloaded file |
        +------------------+------+--------------------------------+
        | esm_vm_ip        | Yes  | esm vm ip                      |
        +------------------+------+--------------------------------+

        **Example:**

        .. code-block:: robotframework

            ${full_path_to_snapshot}=  Collect Snapshot Via Ssh From  ESM  /home/ute/Download  123.123.123.123

        | **Return value:**
        | Path to zip file in local machine.
        | For example: /home/ute/Download/YYYY_MM_DD_HH_MM_snapshot.zip

        """
        snapshot_path = self._collect_snapshot_via_ssh_from_esm(path_container, esm_vm_ip)
        self._verify_snapshot_content(snapshot_path)

    def _collect_snapshot_via_ssh_from_esm(self, path_container, esm_vm_ip):
        self._setup_connection(self.esm_ip, via_ip=esm_vm_ip, via_user='ute', via_password='uteUTE!')
        dt = datetime.now()
        name_snapshot = '{}_snapshot.zip'.format(dt.strftime("%Y_%m_%d_%H_%M"))
        remote_file_path = "/ffs/run/trs_data/db/{}".format(name_snapshot)
        logging.debug('Collecting snapshot started')
        self.ssh.run_command('nc localhost 15007 <<<"log -a -z {}" 2>/dev/null'.format(remote_file_path),
                             ex_st=False)

        logging.debug('Sent snapshot command to BTS')

        try:
            logging.debug('Downloading snapshot')
            des_path = self._download_from_esm_via_vm(path_container, self.esm_ip, esm_vm_ip, remote_file_path)
            return des_path
        finally:
            self._setup_connection(self.esm_ip, via_ip=esm_vm_ip, via_user='ute', via_password='uteUTE!')
            self._execute_delete_file(remote_file_path, False)

    @staticmethod
    def _download_file(ip, user, password, port, file_path, local_path):
        ftp_obj = DownloadFile(ip, user, password, port, file_path, local_path)
        trans = ftp_obj.connect_sftp()
        print("sftp connected")
        ftp_obj.download_file(file_path, local_path)
        return trans

    def _setup_sm_connection(self, sm_ip):
        """
        Setup connection with master system module, if sm_ip == 192.168.255.7
        setup connection to extension system module via master system module.
        If extension system module is reachable via  IPv6 (eg. ASIL),
        connection will be established using alias (fct-4a).
        :param sm_ip:
        """
        if sm_ip == self.esm_ip:
            self._setup_connection(self.esm_ip, via_ip=self.sm_ip)
        elif sm_ip == "fct-4a":
            self._setup_connection(sm_ip, via_ip=self.sm_ip)
        else:
            self._setup_connection(sm_ip)

    def remove_file_from_smod(self, path, recursively=True, sm_ip=None):
        """
        Remove file from smod

        | **Author:** damian.skrzypczak@nokia.com
        | **Maintainers:** szymon.skwirut@nokia.com
        | **Released with version:** 1.1.0

        | **Full description:**
        | Deleting path(file or directory) from system module
        | by "rm" command(via ssh with previously set parameters).

        **Input Parameters:**

        +------------------+------+-----------------------------------------+
        | Input Parameters | Man. | Description                             |
        +==================+======+=========================================+
        | path             | Yes  | path to be removed                      |
        +------------------+------+-----------------------------------------+
        | recursively      | No   | "-r" flag for rm command (default True) |
        +------------------+------+-----------------------------------------+

        **Example:**

        | When we don't care if path is file or directory (empty or not)
        .. code-block:: robotframework

            Remove File From SMOD  /var/tmp/test_file.txt

        | When we don't want to delete path that is directory(empty or not)
        .. code-block:: robotframework

            Remove File From SMOD  /var/tmp/test_file.txt  recursively=False

        | **Return value:**
        | Bool value: True or False
        """
        if sm_ip is None:
            sm_ip = self.sm_ip
        self._setup_sm_connection(sm_ip)
        return self._execute_delete_file(path, recursively)

    def _execute_delete_file(self, path, recursively):
        parameter = "-r" if recursively else ""
        output = self.ssh.run_command("rm {0} {1}".format(parameter, path))
        if output.return_code == 0:
            logging.debug("file {} was deleted successfully".format(path))
            return True
        else:
            logging.debug("file {} wasn't deleted, Output from command: {}".format(path, output.stdout))
            return False

    def _verify_snapshot_content(self, snapshot_zip_path):
        snapshot_status = self._verify_snapshot(snapshot_zip_path)
        if snapshot_status != 'OK':
            logging.warning('{} file is {}'.format(snapshot_zip_path, snapshot_status))

    @staticmethod
    def _verify_snapshot(snapshot_zip_path):
        if not os.path.exists(snapshot_zip_path):
            return 'missing'
        try:
            with zipfile.ZipFile(snapshot_zip_path, 'r') as snapshot_zip:
                if snapshot_zip.testzip() is not None:
                    return 'corrupt'
                elif not snapshot_zip.infolist():
                    return 'empty'
        except (zipfile.BadZipfile, IOError):
            return 'not a valid zip file'
        return 'OK'

    def _download_from_esm_via_vm(self, destination, esm_ip, esm_vm_ip, source):
        """
        Download file or directory from esm via vm.

        :param destination: Where to download
        :param esm_ip: esm ip
        :param esm_vm_ip: esm vm ip
        :param source: Where is directory / file on esm
        :return: path to downloaded dir / file
        """
        dir_file_name = os.path.split(source)[1]
        self._setup_connection(ip=esm_vm_ip, user='ute', password='ute')
        command_template = 'sshpass -p {password} scp -r {user}@{ip}:{source_path} /tmp/'
        self._execute_and_validate(command_template.format(password=self.sm_pass, ip=esm_ip, user=self.sm_user,
                                                           source_path=source))
        try:
            self._execute_scp_command_locally(esm_vm_ip, 'ute', 'ute', '/tmp/{}'.format(dir_file_name), destination)
        finally:
            self._setup_connection(esm_vm_ip, user='ute', password='ute')
            self._execute_delete_file('/tmp/{}'.format(dir_file_name), recursively=True)
        logger.info('Successfully downloaded {source} from {esm_ip} to {destination}'.format(source=source,
                                                                                             esm_ip=esm_ip,
                                                                                             destination=destination),
                    also_console=True)
        return os.path.join(destination, dir_file_name)

    @staticmethod
    def _execute_scp_command_locally(ip, user, password, source, destination):
        """
        Method execute command: 'sshpass -p password scp -r user@ip:source destination' local

        :param ip: ip
        :param user: user
        :param password: password
        :param source: source
        :param destination: destination
        :return: None
        """
        host_data = '{user}@{ip}:{source}'.format(user=user, ip=ip, source=source)
        subprocess.call(['sshpass', '-p', password, 'scp', '-r', host_data, destination])

    def _execute_and_validate(self, command):
        return self.ssh.run_command(command)

    def get_targetbd_attribute_value_from_active_partition(self, attribute_name, ip=None, user=None, password=None,
                                                           via_ip=None, via_user=None, via_password=None):
        """
        This keyword gets targetBD value of attribute from active partition
        | **Full description:**
        | This keyword gets targetBD value of attribute

        **Input Parameters:**

        +------------------+------+------------------------------+
        | Input Parameters | Man. | Description                  |
        +==================+======+==============================+
        | attribute_name   | Yes  | name of targetBD attribute   |
        +------------------+------+------------------------------+
        | ip               | No   | ip destination host          |
        +------------------+------+------------------------------+
        | user             | No   | user name (default toor4nsn) |
        +------------------+------+------------------------------+
        | password         | No   | password  (default password) |
        +------------------+------+------------------------------+
        | via_ip           | No   | ip intermediary host         |
        +------------------+------+------------------------------+
        | via_user         | No   | user name (default toor4nsn) |
        +------------------+------+------------------------------+
        | via_password     | No   | password  (default password) |
        +------------------+------+------------------------------+

        **Example:**

        .. code-block:: robotframework

            Set Connection Parameters  ip=${SMOD1['TRS_IP']}   user=${SMOD1['USERNAME']}  password=${SMOD1['PASSWORD']}
        ${package_name}=  Get Targetbd Attribute Value From Active Partition  attribute_name=swReleaseVersionPackageName


        | **Return value:**
        | keyword will return None, if attribute is not found, otherwise value of attribute.
        """  # noqa

        cmd = "cat /ffs/run/TargetBD*.xml"
        self._set_up_connection_based_on_ip_presence(ip, password, user, via_ip, via_password, via_user)
        output = self._execute_and_validate(cmd)
        return self._parse_output_for_attribute_value(output, attribute_name)

    def get_targetbd_attribute_value_from_passive_partition(self, attribute_name, ip=None, user=None, password=None,
                                                            via_ip=None, via_user=None, via_password=None):
        """
        This keyword gets targetBD value of attribute from passive partition

        | **Author:** mnich@nokia.com
        | **Maintainer:** mnich@nokia.com
        | **Released with version:** 2.4.0

        | **Full description:**
        | This keyword gets targetBD value of attribute

        **Input Parameters:**

        +------------------+------+------------------------------+
        | Input Parameters | Man. | Description                  |
        +==================+======+==============================+
        | attribute_name   | Yes  | name of targetBD attribute   |
        +------------------+------+------------------------------+
        | ip               | No   | ip destination host          |
        +------------------+------+------------------------------+
        | user             | No   | user name (default toor4nsn) |
        +------------------+------+------------------------------+
        | password         | No   | password  (default password) |
        +------------------+------+------------------------------+
        | via_ip           | No   | ip intermediary host         |
        +------------------+------+------------------------------+
        | via_user         | No   | user name (default toor4nsn) |
        +------------------+------+------------------------------+
        | via_password     | No   | password  (default password) |
        +------------------+------+------------------------------+

        **Example:**

        .. code-block:: robotframework

          Set Connection Parameters  ip=${SMOD1['TRS_IP']}   user=${SMOD1['USERNAME']}  password=${SMOD1['PASSWORD']}
    ${package_name}=  Get Targetbd Attribute Value From Passive Partition  attribute_name=swReleaseVersionPackageName


        | **Return value:**
        | keyword will return None, if attribute is not found, otherwise value of attribute.
        """  # noqa

        cmd = "cat /ffs/stb/TargetBD*.xml"
        self._set_up_connection_based_on_ip_presence(ip, password, user, via_ip, via_password, via_user)
        output = self._execute_and_validate(cmd)
        return self._parse_output_for_attribute_value(output, attribute_name)

    def _set_up_connection_based_on_ip_presence(self, ip, password, user, via_ip, via_password, via_user):
        if ip:
            self._setup_connection(ip, user, password, via_ip, via_user, via_password)
        else:
            self._setup_connection(self.sm_ip, user, password, via_ip, via_user, via_password)

    @staticmethod
    def _parse_output_for_attribute_value(output, attribute_name):
        targetbd_content = ET.fromstring(output.stdout)
        return targetbd_content.attrib.get(attribute_name)


class IncorrectSetConnectionParameters(Exception):
    def __init__(self, msg=None):
        if not msg:
            msg = ('Connection parameters are incorrect.\n'
                   'Please use set_connection_parameters method first.\n'
                   'Ip parameter is equal none.')
        super(IncorrectSetConnectionParameters, self).__init__(msg)


class CommandFailed(Exception):
    def __init__(self, msg):
        super(CommandFailed, self).__init__(msg)


class PIDError(Exception):
    """Raised when PID of btssw was not correctly obtained"""


class RemoteCommandExecutor(object):
    def __init__(self, remote_host, **kwargs):
        self.remote_host = remote_host
        self.ssh_username = kwargs.get('remote_host_username', 'ute')
        self.ssh_password = kwargs.get('remote_host_password', 'ute')
        self.ssh_port = int(kwargs.get('remote_host_ssh_port', 22))

    def _create_connected_ssh_client(self):
        ssh_client = paramiko.SSHClient()
        ssh_client.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        ssh_client.connect(self.remote_host, self.ssh_port, self.ssh_username, self.ssh_password, timeout=30)
        return ssh_client

    def send_command(self, cmd, exit_prompt='$ '):
        ssh_client = self._create_connected_ssh_client()
        chan = ssh_client.get_transport().open_session()
        chan.exec_command(cmd)
        exit_status_ready = chan.exit_status_ready()
        new_response = chan.recv(8192)

        while not (exit_status_ready or new_response.endswith(('{}'.format(exit_prompt)).encode())):
            logging.debug(('{}'.format(new_response)))
            exit_status_ready = chan.exit_status_ready()
            new_response = chan.recv(8192)
        status = chan.recv_exit_status()
        ssh_client.close()
        return status

    def is_pingable(self, hostname):
        cmd = "ping -c 3 {}".format(hostname)
        return self.send_command(cmd) == 0

    def is_available(self, hostname, timeout):
        cmd = "ping -w {} {}".format(timeout, hostname)
        return self.send_command(cmd) == 0
