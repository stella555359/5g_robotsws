from robot.api import logger
from ute_common_abstract_core.message import KeyFindingDict
from common.robot_managment import *


def check_number_of_swapped_ue_in_5_seconds_period(ues_list):
    total = 0
    swap_msg_timestamps = _get_all_ue_swapped_timestamps_sorted(ues_list)
    first_msg_time = swap_msg_timestamps.pop(0)
    for msg_time in swap_msg_timestamps:
        if msg_time - first_msg_time < 5:
            total += 1
    logger.info("{} UEs swapped in 5 seconds".format(total))
    return total


def _get_all_ue_swapped_timestamps_sorted(ues_list):
    swap_timestamps = []
    ca_managment_inst = robot_get_library_instance('ca_managment')
    for ue_alias in ues_list:
        try:
            ue_id = ca_managment_inst._get_owner_id_from_ue_alias(ue_alias)
            messages = ca_managment_inst.message_subscriber.get_parsed_messages_for_owner(ue_id)
            for msg in messages:
                if _message_contain_pcell_swap_messages(msg):
                    swap_timestamps.append(float(msg.occurrence_time))
                    break
        except AssertionError as e:
            logger.info(e)
            continue
    swap_timestamps.sort()
    assert len(swap_timestamps) > 0, 'No UE swapped'
    return swap_timestamps


def _message_contain_pcell_swap_messages(msg):
    msg_dict = KeyFindingDict(msg)
    expected_messages = ['sCellToReleaseList-r10', 'sCellToAddModList-r10', 'measIdToRemoveList']
    for exp_m in expected_messages:
        if exp_m not in msg_dict:
            return False
    return True
