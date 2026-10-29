# -*- coding: utf-8 -*-
"""
:copyright: Nokia Networks
:author: Jacek Kozmic
:contact: jacek.kozmic@nokia.com
:team: I_5GSC_SW_ENG_KRK_VRF_GMS
:email: I_5GSC_SW_ENG_KRK_VRF_GMS <I_5GSC_SW_ENG_KRK_VRF@internal.nsn.com>
"""
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.background_script \
    import BackgroundScript
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.utilities import logger_console
from robot.libraries.BuiltIn import BuiltIn
from subprocess import Popen, PIPE
from datetime import datetime
import shlex
import time
import signal


class AaTraceScriptNoStarted(Exception):
    pass


def run_aatrace_script(script_path, node_list, msg_list):
    cmd = 'python {} --nodeList {} --msgList {}'.format(script_path, node_list, msg_list)
    cmd = shlex.split(cmd)
    process = Popen(cmd, stdout=PIPE, stderr=PIPE)
    stdout, stderr = process.communicate()
    if stderr:
        raise AaTraceScriptNoStarted(stderr)


def _prepare_aatrace_arguments(node_list, msg_list):
    if isinstance(node_list, list):
        node_list = ','.join(node_list)
    if isinstance(msg_list, list):
        msg_list = ','.join(msg_list)
    return node_list, msg_list


def start_aatrace_script(node_list, msg_list):
    path_aatrace = BuiltIn().get_variable_value("${AATRACE_SCRIPT_PATH}")
    node_list, msg_list = _prepare_aatrace_arguments(node_list, msg_list)
    BackgroundScript().start_background_script(run_aatrace_script, (path_aatrace, node_list, msg_list))
    logger_console('Wait for AaTrace script to start')
    time.sleep(15)


def stop_aatrace_script():
    path_aatrace = BuiltIn().get_variable_value("${AATRACE_SCRIPT_PATH}")
    pid_log = "{}/simpleAaTracePid.txt".format('/'.join(path_aatrace.split('/')[:-1]))
    logger_console('Turning off the script: CTRL+C')
    BackgroundScript().send_signal_to_processes(signal.SIGINT)
