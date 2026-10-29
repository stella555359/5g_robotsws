import math
from robot.libraries.BuiltIn import BuiltIn
import re
import random
import time

ute_wtssim_instance = BuiltIn().get_library_instance('ute_wtssim')


def send_rrc_setup_cause_and_deregister(ue_id, cause):
    ute_wtssim_instance.execute_egate_command_and_wait_for_data(cmd='ue_nr_rrc_setup_param id={} establishment_cause={}'
                                                                .format(ue_id, cause),
                                                                pass_regexp='')
    ute_wtssim_instance.execute_egate_command_and_wait_for_data(cmd='ue_deregister id={} ue_deregister_type=switch_off'
                                                                .format(ue_id),
                                                                pass_regexp='')


def modify_rrc_setup_cause_and_drop_random_ues(ue_list, how_much_ues):
    cause_list = ['emergency', 'highPriorityAccess', 'mt-Access', 'mo-Signalling', 'mo-Data', 'mo-VoiceCall',
                  'mo-VideoCall', 'mo-SMS', 'mps-PriorityAccess', 'mcs-PriorityAccess']
    list_of_random_ues = random.sample(ue_list, how_much_ues)
    for ue_id in list_of_random_ues:
        cause = random.choice(cause_list)
        send_rrc_setup_cause_and_deregister(ue_id, cause)


def modify_rrc_setup_cause_and_drop_one_ue_for_every_cause():
    cause_list = ['emergency', 'highPriorityAccess', 'mt-Access', 'mo-Signalling', 'mo-Data', 'mo-VoiceCall',
                  'mo-VideoCall', 'mo-SMS', 'mps-PriorityAccess', 'mcs-PriorityAccess']
    list_of_ues = [1, 2, 3, 4, 5, 6, 7, 8, 9, 10]
    for i in range(0, len(list_of_ues)):
        cause = cause_list[i]
        ue_id = list_of_ues[i]
        send_rrc_setup_cause_and_deregister(ue_id, cause)
