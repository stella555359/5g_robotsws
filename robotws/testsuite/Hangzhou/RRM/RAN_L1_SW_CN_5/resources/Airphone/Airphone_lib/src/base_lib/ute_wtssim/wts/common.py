# -*- coding: utf-8 -*-

import time
from functools import partial
from ..exception import InvalidSSHClient


SOCKET_CHECK_CMD = ('python -c "import socket; '
                    's = socket.socket(socket.AF_INET, socket.SOCK_STREAM); '
                    's.setsockopt(socket.SOL_SOCKET, socket.SO_REUSEADDR, 1); '
                    's.bind((\'0.0.0.0\', {})); '
                    's.close()"')


class WtsSimCommon(object):
    def __init__(self, *args, **kwargs):
        self._tool_dir = "/opt/iphy/latest"
        self._started = False
        self._client = None
        self._port = None
        self._pid = None

    @property
    def port(self):
        return self._port

    @property
    def tool_dir(self):
        return self._tool_dir

    @tool_dir.setter
    def tool_dir(self, new_dir):
        if new_dir is not None and self._started is False:
            self._tool_dir = new_dir

    def _check_client(self):
        if not hasattr(self._client, 'execute_command'):
            raise InvalidSSHClient("Provided client object does not have the 'execute_command' method")

    def _is_tcp_port_free(self, tcp_port, timeout=240):
        stime = time.time()
        while time.time() - stime <= timeout:
            out, err, rc = self._client.execute_command(SOCKET_CHECK_CMD.format(tcp_port))
            if not rc:
                return True
            time.sleep(1)
        return False

    def _kill_process(self, process_cmd=None):
        kill_cmd = partial(self._kill_process_by_id, self._pid) if process_cmd is None \
            else partial(self._kill_process_by_regexp, process_cmd)
        kill_cmd()
        start = time.time()
        while time.time()-start < 5:
            if not self._process_exists():
                return True
            time.sleep(1)
        kill_cmd(force=True)

    def _kill_process_by_id(self, selector, force=False):
        force = '' if force is False else '-9 '
        self._client.execute_command(r"sudo kill {}{}".format(force, selector))

    def _kill_process_by_regexp(self, selector, force=False):
        force = '' if force is False else '-9 '
        self._client.execute_command(r"sudo pkill {}-f '{}'".format(force, selector))

    def _process_exists(self, process_cmd=None):
        cmd = 'ps -p {}'.format(self._pid) if process_cmd is None else 'ps -C "{}"'.format(process_cmd)
        out, err, rc = self._client.execute_command(cmd)
        return True if rc == 0 else False
