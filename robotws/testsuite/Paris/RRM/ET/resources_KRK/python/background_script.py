# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Adrianna Pienkowska
:maintainer:  Adrianna Pienkowska
:contact: adrianna.pienkowska@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
:description: Class to start a script in the background and to stop it and all the processes spawed by it
:justification: Used mostly to start bip capture in the background, but can be used to start any script in
                the background.
"""
import multiprocessing
import psutil
import time
import os
from testsuite.Paris.RRM.ET.resources_KRK.python.utilities import logger_console


class BackgroundScript(object):

    def _child_process(self, fun_name, fun_arg):
        pid = multiprocessing.Process(target=fun_name, args=fun_arg)
        pid.start()

    def start_background_script(self, fun_name, fun_arg=tuple()):
        """
        It starts function in the background.

        :author: Adrianna Pienkowska
        :contact: adrianna.pienkowska@nokia.com
        :modified: 28.06.2021 by Adrianna Pienkowska
        :param script_name: (str) a name of a bip script to start
        :param fun_arg: (tupla) a tuple with arguments for the script to start in the background
        :returns: nothing
        """
        self._child_process(fun_name, fun_arg)

    def terminate_background_script(self, process_nr):
        """
        It terminates the script started in the background and its session.

        :author: Adrianna Pienkowska
        :contact: adrianna.pienkowska@nokia.com
        :modified: 10.10.2021 by Adrianna Pienkowska
        :returns: nothing
        """
        try:
            parent_pid = multiprocessing.active_children()[int(process_nr)-1]
        except IndexError as e:
            return

        children = self._get_childrens_pids(parent_pid.pid)
        for child in children:
            child.kill()
        parent_pid.terminate()
        self._sleep_wraper(5)
        try:
            multiprocessing.active_children()[int(process_nr)-1]
        except IndexError:
            self._terminate_multiprocessing_hanging_resources()

    def _terminate_multiprocessing_hanging_resources(self):
        for child in multiprocessing.active_children():
            child.terminate()

    def send_signal_to_processes(self, signal_to_send):
        """
        It sends signal to the background script and its session.

        :author: Adrianna Pienkowska
        :contact: adrianna.pienkowska@nokia.com
        :modified: 7.10.2021 by Adrianna Pienkowska
        :param signal_to_send: (signal) signal to send
        :returns: nothing
        """
        parent_pid = multiprocessing.active_children()[0]
        children = self._get_childrens_pids(parent_pid.pid)
        for child in children:
            child.send_signal(signal_to_send)
        self._sleep_wraper(5)
        self._terminate_multiprocessing_hanging_resources()

    def _get_childrens_pids(self, parent_pid):
        try:
            ps_parent = psutil.Process(parent_pid)
        except psutil.NoSuchProcess:
            logger_console('No parent process started')
            return None
        return ps_parent.children(recursive=True)

    def _sleep_wraper(self, t):
        logger_console('Wait for background process to join')
        time.sleep(t)
