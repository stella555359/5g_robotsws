# -*- coding: utf-8 -*-
"""
:author: Sylwester Kulpa
:contact: sylwester.kulpa@nokia.com
:maintainer: I_TADEK_DEVS
:contact: I_TADEK_DEVS@internal.nsn.com
"""

import subprocess
import time

from .exceptions import ProcessNotRunning, ProcessStillRunning


class Process(object):
    """
    Wrapper class for subprocess.Popen
    """

    def __init__(self, *args, **kwargs):
        self._stdout = kwargs.get('stdout', subprocess.PIPE)
        self._stderr = kwargs.get('stderr', subprocess.PIPE)
        kwargs.setdefault('stdout', self._stdout)
        kwargs.setdefault('stderr', self._stderr)
        self._process = subprocess.Popen(*args, **kwargs)

    @property
    def pid(self):
        """

        :return:
        """
        return self._process.pid

    @property
    def running(self):
        """

        :return:
        """
        return self._is_process_running()

    @property
    def return_code(self):
        """

        :return:
        """
        return self._process.returncode

    @property
    def output(self):
        """

        :return: tuple of (stdout, stderr)
        """
        if self.running:
            raise ProcessStillRunning()
        return self._process.communicate()

    def terminate(self, timeout=0.1):
        """

        :return:
        """
        if not self.running:
            raise ProcessNotRunning()
        self._process.terminate()
        self._wait_for_stop(timeout)
        return not self.running

    def kill(self, timeout=0.1):
        """

        :return:
        """
        if not self.running:
            raise ProcessNotRunning()
        self._process.kill()
        self._wait_for_stop(timeout)
        return not self.running

    def send_signal(self, signal):
        """

        :param signal:
        :return:
        """
        self._process.send_signal(signal)

    def _is_process_running(self):
        return self._process.poll() is None

    def _wait_for_stop(self, timeout):
        max_time = time.time() + timeout
        while time.time() <= max_time and self._is_process_running():
            time.sleep(min(0.1, timeout))
