from testsuite.Wroclaw.RRM.resources.log.helper import LogHelper
from testsuite.Wroclaw.RRM.resources.log.log import blog
from testsuite.Wroclaw.RRM.resources.log.matchers import PcapMessageMatcher as pm
from testsuite.Wroclaw.RRM.resources.etws_cmas.ngap_checkers import get_nr_cell_id
import random
from testsuite.Wroclaw.RRM.resources.preconditions_py import mrbts_id
from testsuite.Wroclaw.RRM.resources.etws_cmas.counters import counter_has_correct_value, wait_for_pm_counters_interval
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.counters import get_sum_of_n_last_pm_counters_values
DEFAULT_GNB_ID_LENGTH = 22


# ********************************* COUNTERS *******************************************
def NNGCB_PWS_CAN_RESP_SENT_counter_incremented_successfully(expected_value, wait_for_interval=True):
    return counter_has_correct_value('M55119C02005', expected_value, wait_for_interval=wait_for_interval)


def NNGCB_PWS_CAN_REQ_RECD_counter_incremented_successfully(expected_value, wait_for_interval=True):
    return counter_has_correct_value('M55119C02004', expected_value, wait_for_interval=wait_for_interval)


def NNGCB_PWS_REST_IND_SENT_counter_incremented_successfully(expected_value, wait_for_interval=True):
    if wait_for_interval:
        wait_for_pm_counters_interval()
    current_value = get_sum_of_n_last_pm_counters_values(['M55119C02006'], n=2)['M55119C02006']
    assert current_value == int(expected_value), \
        (f'NNGCB_PWS_REST_IND_SENT (M55119C02006) value is {current_value} which is different '
         f'than expected: {expected_value}')


def write_replace_warning_request(pcap_file, msg_id=4370, counter=1):
    return find_messages(pcap_file, msg_id, 'WriteReplaceWarningRequest', 'WriteReplaceWarningResponse', counter)


def pws_cancel_request(pcap_file, msg_id=4396):
    return find_messages(pcap_file, msg_id, 'PWSCancelRequest', 'PWSCancelResponse')


def find_messages(pcap_file, msg_id, req_name, resp_name, counter=1):
    with LogHelper() as lh:
        request = pm(req_name, name_line_pattern='empty').containing('MessageIdentifier', '*{}*'.format(msg_id))
        response = pm(resp_name, name_line_pattern='empty').containing('MessageIdentifier', '*{}*'.format(msg_id))
        messages_to_find = [request, response]
        finder = lh.add_pcap(pcap_file_path=pcap_file, lua=False, shark_filter='ngap',
                             ts_output_data_file_path=None, clean_up_tmp_file=False)
        msgs = finder.find_all(messages_to_find, forget_matcher_on_hit=True if counter == 1 else False)
        blog('found messages:')
        blog(msgs)
        if len(msgs) != len(messages_to_find)*counter:
            raise AssertionError("At least one message is missing!")
        return msgs


def call_finder_with_matcher(pcap_file, matcher, occurence):
    with LogHelper() as lh:
        finder = lh.add_pcap(
            pcap_file_path=pcap_file, lua=None, shark_filter='ngap',
            ts_output_data_file_path=None, clean_up_tmp_file=False)
        return finder.find_exactly(occurence, matcher)


def create_matcher(msg_type, cell_ids=[], msg_ids=[], serial_numbers=[]):
    matcher = pm(msg_type, name_line_pattern='empty')
    all_cell_ids = [get_nr_cell_id(mrbts_id, cell, nr_of_bits_g_node_b_id=DEFAULT_GNB_ID_LENGTH) for cell in (1, 2, 3)]
    expected_cell_ids = [get_nr_cell_id(mrbts_id, cell,
                                        nr_of_bits_g_node_b_id=DEFAULT_GNB_ID_LENGTH) for cell in cell_ids]

    for cell_id in list(set(all_cell_ids) - set(expected_cell_ids)):
        matcher.not_containing('*nRCellIdentity', '*{}*'.format(cell_id))

    for cell_id in expected_cell_ids:
        matcher.containing('*nRCellIdentity', '*{}*'.format(cell_id))

    for msg_id in msg_ids:
        print(type(msg_id))
        matcher.containing('MessageIdentifier*', '*{}*'.format(msg_id))

    for serial_number in serial_numbers:
        matcher.containing('SerialNumber*{}*'.format(serial_number))

    print(msg_type, expected_cell_ids, msg_ids, serial_numbers)
    return matcher


def check_messages_in_pcap_file(pcap_file_path, message_id, cell_id=100):
    write_replace_req_two_times(str(message_id), 'WriteReplaceWarningRequest', pcap_file_path)
    pws_restart_ind_present(pcap_file_path, cell_id=cell_id)
    write_replace_response_message_one_cell_add(str(message_id), 'WriteReplaceWarningResponse', pcap_file_path)


def check_if_all_cells_and_parameters_from_CBC_are_visible(pcap_file, alarm_id):
    message_to_id_mapping = {'PWSCancelRequest': '4396', 'PWSCancelResponse': '4396'}
    for msg_type in message_to_id_mapping:
        msg_id = message_to_id_mapping[msg_type]
        pws_restart_and_cancel_with_correct_values(msg_id, msg_type, pcap_file)
    write_replace_req_one_time(str(alarm_id), 'WriteReplaceWarningRequest', pcap_file)
    write_replace_with_good_msg_and_cell(str(alarm_id), 'WriteReplaceWarningResponse', pcap_file)


def pws_restart_and_cancel_with_correct_values(msg_id, msg_type, pcap_file):
    return call_finder_with_matcher(pcap_file, create_matcher(msg_type, [100],
                                                              [msg_id], ['96']), 1)


def write_replace_with_good_msg_and_cell(msg_id, msg_type, pcap_file):
    return call_finder_with_matcher(pcap_file, create_matcher(msg_type, [100], [msg_id], []), 1)


def pws_restart_ind_present(pcap_file, cell_id=1):
    return call_finder_with_matcher(pcap_file, create_matcher('PWSRestartIndication', [cell_id], [], []), 2)


def write_replace_response_message_one_cell_add(msg_id, msg_type, pcap_file):
    return call_finder_with_matcher(pcap_file, create_matcher(msg_type, [100], [msg_id], []), 1)


def write_replace_req_two_times(msg_id, msg_type, pcap_file):
    return call_finder_with_matcher(pcap_file, create_matcher(msg_type, [100], [msg_id], []), 2)


def write_replace_req_one_time(msg_id, msg_type, pcap_file):
    return call_finder_with_matcher(pcap_file, create_matcher(msg_type, [100], [msg_id], []), 1)


def random_alarm_number_and_name():
    cmas_alerts = {
        '4370': 'National',
        '4371': 'Extreme',
        '4373': 'Severe'
    }
    msg_id = random.choice(list(cmas_alerts.keys()))
    return int(msg_id), cmas_alerts[msg_id]
