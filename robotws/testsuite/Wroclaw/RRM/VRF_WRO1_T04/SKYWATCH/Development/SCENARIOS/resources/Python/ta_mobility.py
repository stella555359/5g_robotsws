import math
from robot.libraries.BuiltIn import BuiltIn
import re
import random
import time

ute_wtssim_instance = BuiltIn().get_library_instance('ute_wtssim')


def set_ta_mobility_for_ue(ue_id, rach_ta, shr_ta):
    ute_wtssim_instance.execute_egate_command_and_wait_for_data(cmd='ue_ta id={} rach_ta={} shr_ta={}'
                                                                .format(ue_id, rach_ta, shr_ta),
                                                                pass_regexp='')
    return ue_id


def prepare_counter_list(counter):
    counter_list = []
    for i in range(1, 33):
        if i < 10:
            counter = counter[:-1] + str(i)
            counter_list.append(counter)
        else:
            counter = counter[:-2] + str(i)
            counter_list.append(counter)
    return counter_list
