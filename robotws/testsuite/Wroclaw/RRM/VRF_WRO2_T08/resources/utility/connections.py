"""
Context Management classes for taf.transport.ssh library. Exposes connection-based api for ssh, while using
requested by taf alias-based api on the backend. Provides way to make a common connections useful in 5G RRM testing.
Connection details needed are read from testline's __init__.py and ue_conf.yaml files.

:copyright: Nokia
:author: adam.kropiwnicki@nokia.com
:maintainer: adam.kropiwnicki@nokia.com
"""


from taf.transport.ssh import ssh

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.testline_conf import TestlineConfiguration
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.wro_logger import logger

_tl = TestlineConfiguration()
_ssh = ssh()


class ConnectionManager(object):
    _singleton = None
    reinitialize = True

    def __new__(cls, *args, **kwargs):
        if cls._singleton is None:
            cls._singleton = super(ConnectionManager, cls).__new__(cls, *args, **kwargs)
        return cls._singleton

    def __init__(self):
        if ConnectionManager.reinitialize:
            self._recent_connections = {}
            ConnectionManager.reinitialize = False

    def lte_pc_connection(self, autoconnect=True, alias='lte_pc'):
        cn_details = _tl.get_lte_test_pc_connection_details()
        context = self._get_connection_context(hostname=cn_details['hostname'], username=cn_details['username'],
                                               password=cn_details['password'], alias=alias)
        if autoconnect:
            context.connect()
        return context

    def nr_pc_connection(self, autoconnect=True, alias='nr_pc'):
        cn_details = _tl.get_nr_test_pc_connection_details()
        context = self._get_connection_context(hostname=cn_details['hostname'], username=cn_details['username'],
                                               password=cn_details['password'], alias=alias)
        if autoconnect:
            context.connect()
        return context

    def lte_smod_connection(self, autoconnect=True, alias='lte_smod'):
        lte_pc_proxy = self.lte_pc_connection(autoconnect=True)
        cn_details = _tl.get_gnb_ssh_connection_details()
        context = self._get_connection_context(hostname=cn_details['hostname'], username=cn_details['username'],
                                               password=cn_details['password'], alias=alias, proxy=lte_pc_proxy)
        if autoconnect:
            context.connect()
        return context

    def nr_smod_connection(self, autoconnect=True, alias='nr_smod'):
        cn_details = _tl.get_gnb_ssh_connection_details()
        context = self._get_connection_context(hostname=cn_details['hostname'], username=cn_details['username'],
                                               password=cn_details['password'], alias=alias)
        if autoconnect:
            context.connect()
        return context

    def uepc_connection(self, autoconnect=True, alias='uepc'):
        connection_details = _tl.get_uepc_connection_details()
        context = self._get_connection_context(alias=alias, **connection_details)
        if autoconnect:
            context.connect()
        return context

    def make_connection(self, hostname, username, password, proxy=None, autoconnect=True, alias='custom'):
        context = self._get_connection_context(alias=alias, hostname=hostname, username=username, password=password,
                                               proxy=proxy)
        if autoconnect:
            context.connect()
        return context

    def _get_connection_context(self, hostname=None, username=None, password=None, alias='default', proxy=None):
        if self._recent_connections.get(alias, None) is not None:
            return self._recent_connections[alias]
        context = ConnectionContext(hostname, username, password, alias, proxy)
        self._recent_connections[alias] = context
        return context

    def teardown(self):
        for alias in self._recent_connections:
            context = self._get_connection_context(alias=alias)
            if context.is_connected():
                context.disconnect()
        self._recent_connections = {}

    def __enter__(self):
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.teardown()


class ConnectionContext:
    def __init__(self, hostname, username, password, alias, proxy=None):
        self.alias = alias
        self._hostname = hostname
        self._username = username
        self._password = password
        self._id_string = "{}@{}".format(self._username, self._hostname)
        self._proxy = proxy.alias if proxy is not None else proxy
        self._connection_attempted = False

    def __enter__(self):
        self.connect()
        return self

    def __exit__(self, exc_type, exc_val, exc_tb):
        self.disconnect()

    def connect(self):
        if self.is_connected():
            logger.info("{} already connected! Ignoring...".format(self._id_string))
            return
        _ssh.connect_to(hostname=self._hostname, username=self._username, password=self._password,
                        proxy=self._proxy, alias=self.alias)
        self._connection_attempted = True
        assert self.is_connected(), "Could not connect to {}".format(self._id_string)

    def disconnect(self):
        if self.is_connected():
            _ssh.disconnect(connection=_ssh.get_connection_by_alias(self.alias))
        else:
            logger.info("{} already disconnected! Ignoring...".format(self._id_string))
        self._connection_attempted = False

    def is_connected(self):
        if self._connection_attempted:
            return _ssh.get_connection_by_alias(self.alias).is_connected
        return False

    def details(self):
        return {'hostname': self._hostname, 'username': self._username, 'password': self._password,
                'proxy': self._proxy if self._proxy is None else self._proxy.details()}

    def send_command(self, cmd, timeout=10):
        logger.info("Sending command {} on {}, timeout = {}".format(cmd, self._id_string, timeout))
        _ssh.send_command(command=cmd, timeout=timeout, connection=self.alias)

    def execute_command(self, cmd, timeout=10):
        logger.info("Executing command {} on {}, timeout = {}".format(cmd, self._id_string, timeout))
        return _ssh.execute(command=cmd, connection=self.alias, timeout=timeout)

    def download_file(self, remote_path, local_path, timeout=30):
        logger.info("Downloading file {}:{} to {}, timeout = {}".format(self._id_string, remote_path, local_path,
                                                                        timeout))
        _ssh.download_file(remote_path=remote_path, local_path=local_path,
                           connection=self.alias, timeout=timeout)

    def upload_file(self, remote_path, local_path, timeout=30):
        logger.info("Uploading file {} to {}:{}, timeout = {}".format(local_path, self._id_string, remote_path,
                                                                      timeout))
        _ssh.upload_file(remote_path=remote_path, local_path=local_path,
                         connection=self.alias, timeout=timeout)

    def read_output_until(self, match, timeout=None):
        logger.info("Reading output until '{}' found (timeout = {})".format(match, timeout))
        _ssh.read_output_until(match=match, timeout=timeout, connection=self.alias)

    def read_output(self):
        _ssh.read_output(connection=self.alias)

    def assert_file_exists(self, remote_path, timeout=10):
        _ssh.assert_file_exists(remote_path=remote_path, connection=self.alias, timeout=timeout)
