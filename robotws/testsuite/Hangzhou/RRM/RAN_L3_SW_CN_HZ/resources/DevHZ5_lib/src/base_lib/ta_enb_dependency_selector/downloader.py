# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Al-john Vizcarra
:contact: al-john.vizcarra@nokia.com
:maintainer: Michael Liclican, Al-john Vizcarra
:contact: michael.liclican@nokia.com, al-john.vizcarra@nokia.com
"""

from SSHLibrary import SSHClient
from SSHLibrary.abstractclient import SSHClientException
from robot.utils import timestr_to_secs
from .exception import FileDoesNotExist
import logging
import six


class Downloader(object):

    def __init__(self, **kwargs):
        self._config = self._extract_ssh_values(**kwargs)

    def execute_wget(self, src, dest):
        """
        :param string src:      URL of file to be downloaded.
        :param string dest:     Destination where to save the downloaded file.
        """
        cmd = "wget {} -O {}".format(src, dest)
        try:
            result = self._execute_ssh_commands(cmd)
        except (FileDoesNotExist, SSHClientException) as e:
            delete_empty_file_cmd = "rm -f {}".format(dest)
            self._execute_ssh_commands(delete_empty_file_cmd)
            raise e
        else:
            return result

    def execute_svn_export(self, src, dest, svn_user='ca_ute_test', svn_pass='utetest'):
        """
        :param string src:              URL of file to be downloaded.
        :param string dest:             Destination where to save the downloaded file.
        :param string svn_user:         Username valid for svn authentication. Default is 'ca_ute_test'.
        :param string svn_pass:         Password valid for svn authentication. Default is 'utetest'.
        """
        cmd = 'svn --username "{}" --password "{}" --force --non-interactive --trust-server-cert export "{}" \
        "{}"'.format(svn_user, svn_pass, src, dest)
        return self._execute_ssh_commands(cmd)

    def _execute_ssh_commands(self, cmd):
        ssh_client = SSHClient(host=self._config['host_ip'], port=self._config['ssh_port'],
                               prompt=self._config['ssh_prompt'], timeout=self._config['timeout'])
        self._log = logging.getLogger(__name__)
        if "look_for_keys" in six.get_function_code(ssh_client.login).co_varnames:
            ssh_client.login(username=self._config['ssh_username'], password=self._config['ssh_password'],
                             look_for_keys=True)
        else:
            ssh_client.login(username=self._config['ssh_username'], password=self._config['ssh_password'])
        result = ssh_client.execute_command(cmd)
        ssh_client.close()
        return self._check_result(result)

    def _check_result(self, result):
        if len(result) == 3 and result[2] != 0:
            if "svn: E170000" in result[1] or "ERROR 404: Not Found" in result[1]:
                raise FileDoesNotExist(result[1])
            raise SSHClientException(result[1])
        elif result:
            return result[0]
        else:
            return "The command has been executed, but it did not return a standard output message."

    def _extract_ssh_values(self, **kwargs):
        config = {'host_ip': kwargs.get('host_ip', '127.0.0.1'),
                  'ssh_username': kwargs.get('ssh_username', 'ute'),
                  'ssh_password': kwargs.get('ssh_password', 'ute'),
                  'ssh_port': kwargs.get('ssh_port', 22),
                  'ssh_prompt': kwargs.get('ssh_prompt', '$ '),
                  'timeout': self._convert_to_secs(kwargs.get('timeout', '900s'))}
        return config

    def _convert_to_secs(self, provided_time):
        return provided_time if provided_time is None else int(timestr_to_secs(provided_time))
