import math
from robot.libraries.BuiltIn import BuiltIn
import re
import random
import time

ute_wtssim_instance = BuiltIn().get_library_instance('ute_wtssim')


def send_rrcreestablish(ue_id, cause):
    ute_wtssim_instance.execute_egate_command_and_wait_for_data(cmd='ue_rrc_reestablish id={} cause={}'
                                                                .format(ue_id, cause),
                                                                pass_regexp='Reestablishment sucessfully completed')
    return ue_id


def send_rrc_setup_cause_and_deregister(ue_id, cause):
    ute_wtssim_instance.execute_egate_command_and_wait_for_data(cmd='ue_nr_rrc_setup_param id={} establishment_cause={}'
                                                                .format(ue_id, cause),
                                                                pass_regexp='')
    ute_wtssim_instance.execute_egate_command_and_wait_for_data(cmd='ue_deregister id={} ue_deregister_type=switch_off'
                                                                .format(ue_id),
                                                                pass_regexp='')


def move_ue_to_idle_state():
    ute_wtssim_instance.execute_egate_command_and_wait_for_data(cmd='ue_im_entry id={} by=ue'
                                                                .format(ue_id),
                                                                pass_regexp='')


def stop_data_and_wait_for_inactive_state(ue_id, pdu_id):
    ute_wtssim_instance.execute_egate_command_and_wait_for_data(cmd='trf_data_stop ue={} pdu={}'
                                                                .format(ue_id, pdu_id),
                                                                pass_regexp='UE{}: Is INACTIVE'.format(ue_id),
                                                                timeout=60)


def send_rrcresume(ue_id, pdu_id):
    regexp = 'UE-{} PDU SESSION ID-{} setup/reestablishment complete'.format(ue_id, pdu_id)
    ute_wtssim_instance.execute_egate_command_and_wait_for_data(cmd='ue_nr_rrc_resume id={}'
                                                                .format(ue_id),
                                                                pass_regexp=regexp)


def send_rrcreestablish_to_random_ues(ue_list):
    cause_list = ['reconfigurationFailure', 'handoverFailure', 'otherFailure', 'spare1']
    how_much_ues = random.randint(1, len(ue_list))
    list_of_random_ues = random.sample(ue_list, how_much_ues)
    print('Wylosowano {} UEkow: {}'.format(how_much_ues, list_of_random_ues))
    for ue in list_of_random_ues:
        cause = random.choice(cause_list)
        send_rrcreestablish(ue, cause)


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


def create_ues_list(ue_start, ue_stop):
    ue_list = []
    for item in range(ue_start, ue_stop+1):
        ue_list.append(item)
    return ue_list


def create_list_of_reestablished_ues(ue, ue_list):
    ue_list.append(ue)
    return ue_list


def calculate_NR_5101b(M55309C02001, M55308C02002, M55308C00009, M55308C00006):
    return ((8 * M55309C02001) / (M55308C02002 * M55308C00009 / M55308C00006))


def calculate_NR_5400b(M55124C00510, M55124C00511, M55124C00512, M55124C00515,
                       M55124C00503, M55124C00504, M55124C00505):
    return ((100 * (M55124C00510 + M55124C00511 + M55124C00512 + M55124C00515)) /
            (M55124C00503 + M55124C00504 + M55124C00505))
