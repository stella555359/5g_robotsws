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
