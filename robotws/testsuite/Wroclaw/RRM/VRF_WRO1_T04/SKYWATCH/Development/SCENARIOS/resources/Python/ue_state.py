import math
from robot.libraries.BuiltIn import BuiltIn
import re
import random
import time
import ta5g_ue_mobility

ute_wtssim_instance = BuiltIn().get_library_instance('ute_wtssim')


def move_ue_to_idle_state():
    ute_wtssim_instance.execute_egate_command_and_wait_for_data(cmd='ue_im_entry id={} by=ue'
                                                                .format(ue_id),
                                                                pass_regexp='')


def stop_data_and_wait_for_inactive_state(ue_id, pdu_id):
    regexp = 'UE{}: Is INACTIVE'.format(ue_id)
    ute_wtssim_instance.execute_egate_command_and_wait_for_data(cmd='trf_data_stop ue={} pdu={}'
                                                                .format(ue_id, pdu_id),
                                                                pass_regexp=regexp, timeout=60)


def wait_for_ue_state(ue_id, expected_state):
    ue_state = _get_ue_state(ue_id)
    while ue_state != expected_state:
        ue_state = _get_ue_state(ue_id)
        sleep(1)
