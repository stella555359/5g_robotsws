# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Zbigniew Kulas
:contact: zbigniew.kulas@nokia.com
"""
import logging
import traceback
import sys
import six


from paramiko.ssh_exception import SSHException
from socket import timeout as socket_timeout

from SSHLibrary import SSHClient
from SSHLibrary.abstractclient import SSHClientException

from ute_common_util.timeout import Timeout
from ute_common_sshforwarder.forwarder import Forwarder


logger = logging.getLogger(__name__)


class SSHConnectionManager(object):
    """Class responsible for ssh connection management."""

    BANNER_ERR_MSG = 'Error reading SSH protocol banner'
    LOCALHOST = '127.0.0.1'

    def __init__(self, host, user, password, port, timeout, prompt, remote_host, retry_timeout=60, fallback_prompt=None,
                 private_key=None, **kwargs):
        self.user = user
        self.password = '' if private_key else password
        self.host = host
        self.port = port
        self.timeout = timeout
        self.prompt = prompt
        self.retry_timeout = retry_timeout
        self.private_key = private_key
        self.service_tunnel = None
        self.root_credentials = self._extract_root_credentials(kwargs)
        self.forwarder = self._configure_forwarder(remote_host, kwargs) if remote_host else None
        self.fallback_prompt = fallback_prompt
        self._client = None

    @property
    def client(self):
        """ Connection Manager Client (e.g. ssh, telnet). """

        return self._client

    def start(self, timeout=None):
        """ Starts connection manager. """
        timeout = timeout if timeout else self.retry_timeout
        self._client = self._prepare_ssh_connection()
        exception_msg = ''
        time = Timeout(timeout)
        while time.is_not_reached():
            try:
                return self._login()
            except (SSHClientException, SSHException, socket_timeout) as e:
                e_type, e_value, e_traceback = sys.exc_info() if six.PY3 else (None, None, None)
                exception_msg = str(e)
                if self._check_retry_condition(exception_msg):
                    Timeout(1).sleep_until_reached()
                    continue
                elif self._check_fallback_condition(exception_msg):
                    logger.warn("Logging in using fallback_prompt...")
                    return self._login_using_fallback_prompt()
                self.stop()
                break
        logger.debug("".join(traceback.format_exception(e_type, e_value, e_traceback, limit=2))) \
            if six.PY3 else logger.debug(traceback.format_exc())
        raise SSHClientException(exception_msg)

    def _check_retry_condition(self, exception_msg):
        conditions = (SSHConnectionManager.BANNER_ERR_MSG, "timed out", "No existing session")
        for condition in conditions:
            if condition in exception_msg:
                return True
        return False

    def _check_fallback_condition(self, exception_msg):
        return True if "No match found for '{}'".format(self.prompt) in \
                       exception_msg and self.fallback_prompt is not None else False

    def _login_using_fallback_prompt(self):
        self._client.close()
        self._client.config.prompt = self.fallback_prompt
        try:
            return self._login()
        except Exception:
            self.stop()
            raise SSHClientException("No match found for fallback_prompt '{}' "
                                     "in '{}' seconds.".format(self.fallback_prompt, self.timeout))

    def _login(self):
        if self.root_credentials:
            self.client.login_with_public_key(**self.root_credentials)
            return self.client
        if self.private_key:
            self.client.login_with_public_key(username=self.user, keyfile=self.private_key, password=self.password)
        else:
            self.client.login(self.user, self.password, look_for_keys=True)
        return self.client

    def stop(self):
        """Stops and cleans connection. """
        self._clean_ssh()
        self._clean_forwarder()
        self._clean_service_tunnel()

    def _configure_service_tunnel(self):
        if self.forwarder:
            tunnel_conn = {'host': SSHConnectionManager.LOCALHOST, 'port': self.forwarder.start(), 'prompt': ' >'}
        else:
            tunnel_conn = {'host': self.host, 'port': self.port, 'prompt': ' >'}
        tunnel_login = {'username': self.user, 'password': self.password, 'keyfile': self.private_key}
        return Forwarder(tunnel_conn, tunnel_login, SSHConnectionManager.LOCALHOST, 22)

    def _configure_forwarder(self, remote_host, kwargs):
        remote_ssh_user, remote_ssh_pass, remote_ssh_prompt, remote_ssh_port = \
            self._extract_remote_ssh_credentials(kwargs)
        remote_pc_conn = {'host': remote_host, 'prompt': remote_ssh_prompt}
        remote_pc_login = {'username': remote_ssh_user, 'password': remote_ssh_pass}
        return Forwarder(remote_pc_conn, remote_pc_login, self.host, self.port)

    def _prepare_ssh_connection(self):
        if self.root_credentials:
            self.service_tunnel = self._configure_service_tunnel()
            return SSHClient(host=SSHConnectionManager.LOCALHOST, port=self.service_tunnel.start(),
                             timeout=self.timeout, prompt=self.prompt)
        if self.forwarder:
            port = self.forwarder.start()
            return SSHClient(host=SSHConnectionManager.LOCALHOST, port=port, timeout=self.timeout, prompt=self.prompt)
        return SSHClient(host=self.host, port=self.port, timeout=self.timeout, prompt=self.prompt)

    def _clean_forwarder(self):
        if self.forwarder:
            self.forwarder.stop()

    def _clean_ssh(self):
        if self._client:
            self._client.close()
            self._client = None

    def _clean_service_tunnel(self):
        if self.service_tunnel:
            self.service_tunnel.stop()

    def _extract_remote_ssh_credentials(self, kwargs):
        return (kwargs.get('remote_ssh_user', 'ute'),
                kwargs.get('remote_ssh_pass', 'ute'),
                kwargs.get('remote_ssh_prompt', '$ '),
                kwargs.get('remote_ssh_port', 22))

    def _extract_root_credentials(self, kwargs):
        if kwargs.get('root_private_key'):
            return {'username': kwargs.get('root_username', 'toor4nsn'),
                    'password': kwargs.get('root_password', ''),
                    'keyfile': kwargs.get('root_private_key')}
        return None
