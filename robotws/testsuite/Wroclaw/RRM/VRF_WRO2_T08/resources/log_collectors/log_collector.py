"""
Base classes specifying log collector interface

:copyright: Nokia
:author: adam.kropiwnicki@nokia.com
:maintainer: adam.kropiwnicki@nokia.com
"""

import os
from abc import ABCMeta, abstractmethod
from time import sleep, time

from Pyro4 import Proxy, errors

from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.connections import ConnectionManager
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.testline_conf import TestlineConfiguration, \
    convert_windows_path_to_cygwin

_cm = ConnectionManager()


class LogCollector(object):
    __metaclass__ = ABCMeta

    def __init__(self, alias="log_collector"):
        self._log_extension = None
        self._log_postfix = None
        self.executor = None
        self.alias = alias

    @abstractmethod
    def setup(self):
        pass

    @abstractmethod
    def shutdown(self):
        raise NotImplementedError

    @abstractmethod
    def start_log_collecting(self):
        raise NotImplementedError

    @abstractmethod
    def stop_log_collecting(self):
        raise NotImplementedError

    @abstractmethod
    def download_log(self, filepath):
        raise NotImplementedError

    @abstractmethod
    def set_logging_filter(self, filtering):
        raise NotImplementedError

    def _prepare_log_name(self, log_prefix):
        if not log_prefix.endswith(self._log_extension):
            log_prefix += self._log_postfix + self._log_extension
        return log_prefix

    def set_executor(self, hostname, username, password, alias):
        if self.executor is not None:
            self.executor.disconnect()
        self.executor = _cm.make_connection(hostname=hostname, username=username, password=password,
                                            autoconnect=False, alias=alias)


class UeLogCollector(LogCollector):
    _server_script_name = 'server_script.py'
    _ue_app_id = 'undefined'
    _singleton = None

    def __new__(cls, *args, **kwargs):
        if cls._singleton is None:
            cls._singleton = super(UeLogCollector, cls).__new__(cls, *args, **kwargs)
        return cls._singleton

    def __init__(self, alias='ue_log_collector'):
        super(UeLogCollector, self).__init__(alias=alias)
        self.python = None
        self.host = None
        self.pyro_port = None
        self.executor = None
        self.diag_com = None
        self._server_uri = None
        self._server = None
        self._local_server_script = self._get_local_server_script_path()
        self._remote_dir = "C:/auto"
        self._remote_server_script = os.path.join(self._remote_dir, self._get_server_script_name())

    @classmethod
    def _get_local_server_script_path(cls):
        return os.path.join(os.path.dirname(os.path.abspath(__file__)), 'log_servers', cls._get_server_script_name())

    @classmethod
    def _get_server_script_name(cls):
        return cls._server_script_name

    @classmethod
    def _get_ue_app_id(cls):
        return cls._ue_app_id

    def _load_configuration(self, preset=None):
        if preset is None:
            preset = {}
        self.python = preset['python'] if 'python' in preset else \
            convert_windows_path_to_cygwin(TestlineConfiguration().get_python_path())
        self.host = TestlineConfiguration().get_uepc_connection_details()['hostname']
        self.pyro_port = int(preset['pyro_port'] if 'pyro_port' in preset else
                                                    (int(TestlineConfiguration().get_uepc_pyro_port()) + 1))
        self.executor = _cm.uepc_connection()
        self.diag_com = preset['com_port'] if 'com_port' in preset else TestlineConfiguration().get_diag_com()
        self._server_uri = "PYRO:{}_LOG_SERVER@{}:{}".format(self._get_ue_app_id(), self.host, self.pyro_port)
        self._server = Proxy(uri=self._server_uri)

    def is_server_running(self):
        try:
            output = self._server.greetings()
            assert "Hollywood" in output
        except errors.CommunicationError:
            return False
        except AssertionError:
            return False
        except AttributeError:
            return False
        return True

    def wait_until_server_running(self, timeout):
        timer = time() + timeout
        while time() < timer:
            if self.is_server_running():
                return True
            sleep(0.5)
        return False

    def _setup_remote_server(self, with_upload=True):
        if self.is_server_running():
            return
        cmd = "{} {} {} {}".format(self.python, self._remote_server_script, self.host, self.pyro_port)
        with self.executor:
            if with_upload:
                self._create_remote_directory()
                self._upload_server_script()
            self.executor.send_command(cmd=cmd, timeout=None)
        self.wait_until_server_running(timeout=10)

    def _create_remote_directory(self):
        dir_tree = os.path.join(self._remote_dir, 'logs')
        self.executor.execute_command("mkdir -p {}".format(dir_tree))

    def _upload_server_script(self):
        self.executor.upload_file(remote_path=self._remote_server_script, local_path=self._local_server_script)
        self.executor.assert_file_exists(remote_path=self._remote_server_script)

    @abstractmethod
    def shutdown(self):
        raise NotImplementedError

    @abstractmethod
    def start_log_collecting(self):
        raise NotImplementedError

    @abstractmethod
    def stop_log_collecting(self):
        raise NotImplementedError

    @abstractmethod
    def download_log(self, filepath):
        raise NotImplementedError

    @abstractmethod
    def set_logging_filter(self, filtering):
        raise NotImplementedError

    @abstractmethod
    def _connect_to_device(self):
        raise NotImplementedError
