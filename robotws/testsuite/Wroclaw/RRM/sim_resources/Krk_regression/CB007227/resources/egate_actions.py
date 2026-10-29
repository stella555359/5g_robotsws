"""
:copyright: Nokia Networks
:author: Justyna Balcerzak
:maintainer: Justyna Balcerzak
:contact: justyna.balcerzak@nokia.com
"""
from testsuite.Wroclaw.RRM.sim_resources.Krk_regression.MN_RAN_L2.resources.Python.utilities import logger_console
from robot.libraries.BuiltIn import BuiltIn
from time import sleep
import time


def run_egate_command(cmd, sec=2):
    BuiltIn().get_library_instance('ta5g_egate')._ute_wtssim_instance.execute_egate_command(cmd)
    sleep(sec)


def prepare_internal_traffic_generator(ue_id=1, pdu_id=1):
    logger_console("Set internal traffic generator as internal for SA")
    run_egate_command('set_pdu_param ue={} pdu={} trf_type=internal'.format(ue_id, pdu_id))


def start_traffic_stream(ue, dir, trf_id=2, *args, **kwargs):
    command = "trf_data_start ue={} dir={} trf_id={}".format(ue, dir, trf_id)
    for key, value in kwargs.items():
        command += " {}={}".format(key, value)
    run_egate_command(command, sec=2)
    return time.time()


def stop_traffic_stream(ue, trf_id, *args, **kwargs):
    command = "trf_data_stop ue={} trf_id={}".format(ue, trf_id)
    for key, value in kwargs.items():
        command += " {}={}".format(key, value)
    run_egate_command(command, sec=2)


def pdu_session_release(ue_id=1, pdu_id=1):
    logger_console("Release pdu sesssion")
    run_egate_command('ue_pdu_session_release pdu={} ue={}'.format(pdu_id, ue_id))


def deregister_given_ue(ue_id=1):
    logger_console("Deregister UE")
    run_egate_command('ue_deregister id={} ue_deregister_type=switch_off'.format(ue_id))


def detach_ue(ue, *args, **kwargs):
    logger_console("Deregister UE")
    command = "enb_ue_dc_release ue={}".format(ue)
    for key, value in kwargs.items():
        command += " {}={}".format(key, value)
    run_egate_command(command, sec=2)
