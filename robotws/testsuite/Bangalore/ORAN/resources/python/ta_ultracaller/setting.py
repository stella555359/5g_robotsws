import os
import paramiko
import time


class setting(object):
    def __init__(self):
        self._ssh = ""
        self._executor = ""

    def _is_env_variable_defined(self, variable_name):
        return variable_name in os.environ and os.environ[variable_name]

    def _exctact_env_variable_name(self):
        if self._is_env_variable_defined('ABSTRACT_LIB_CONFIG') and (
                self._is_env_variable_defined('TA_UE_CONFIG') or
                self._is_env_variable_defined('TA_UE_CONFIG')):
            err_msg = "Detected both 'ABSTRACT_LIB_CONFIG' and " \
                      "legacy 'TA/UTE_UE_CONFIG' environment variables. " + \
                      "Please define only one"
            raise Exception(err_msg)
        if self._is_env_variable_defined('ABSTRACT_LIB_CONFIG'):
            return 'ABSTRACT_LIB_CONFIG'
        if self._is_env_variable_defined('TA_UE_CONFIG'):
            return 'TA_UE_CONFIG'
        if self._is_env_variable_defined('UTE_UE_CONFIG'):
            return 'UTE_UE_CONFIG'
        return None

    def _get_config_from_environment_variable(self):
        variable_name = self._exctact_env_variable_name()
        if variable_name:
            config_path = os.environ[variable_name]
            return config_path
        else:
            raise Exception("config file is set to none, "
                            "please define the config path")

    def _ssh_connect(self, ip, username, password, cmd):
        self._ssh = paramiko.SSHClient()
        self._ssh.set_missing_host_key_policy(paramiko.AutoAddPolicy())
        self._ssh.connect(ip, username=username, password=password)
        self._executor = self._ssh.invoke_shell()
        out = self._executor.recv(9999)
        print(out)
        self._executor.send(cmd+"\n")
        while not self._executor.recv_ready():
            time.sleep(3)
        output = self._executor.recv(9999)
        print(output.decode('utf-8'))
        output = output.decode('utf-8')
        return output

    def _ssh_close(self):
        if self._ssh is not None:
            self._ssh.close()
        if self._executor is not None:
            self._executor.close()
