from testsuite.Wroclaw.RRM.resources.log.helper import LogHelper
from testsuite.Wroclaw.RRM.resources.log.log import blog
from testsuite.Wroclaw.RRM.resources.log.matchers import PcapMessageMatcher as pm
from testsuite.Wroclaw.RRM.resources.preconditions_py import mrbts_id

import testsuite.Wroclaw.RRM.resources.etws_cmas.filters as filters


def gnb_responded_to_write_replace_warning_request(pcap_file, cell_id, msg_id=4352, etws_type=None,
                                                   serial_number=None, gnb_len=22):
    """
    :param pcap_file: pcap file location
    :param cell_id:
    :param msg_id:
    :param etws_type: primary or secondary (ETWS)
    :param serial_number: requested serial number
    :return:
    """
    finder = _common_finder(pcap_file)
    cell_id = get_nr_cell_id(mrbts_id, cell_id, nr_of_bits_g_node_b_id=gnb_len)
    request = pm(filters.WRWR_REQUEST, name_line_pattern='empty')
    response = pm(filters.WRWR_RESPONSE, name_line_pattern='empty') \
        .containing('MessageIdentifier', '*{}*'.format(msg_id)) \
        .containing('BroadcastCompletedAreaList*') \
        .containing('*nRCellIdentity', '*{}'.format(cell_id))

    if etws_type == 'primary':
        request = request.containing('*WarningType')
    elif etws_type == 'secondary':
        request = request.containing('*WarningMessageContents')
    elif etws_type and etws_type not in ('primary', 'secondary'):
        raise RuntimeError("Unknown ETWS type!")

    if serial_number:
        sn_pattern = 'SerialNumber*{}*'.format(serial_number)
        request = request.containing(sn_pattern)
        response = response.containing(sn_pattern)

    messages_to_find = [
       request,
       response
    ]
    return _find_all_messages(finder, messages_to_find)


def gnb_responded_without_broadcast_completed_area_list(pcap_file, msg_id=4352):
    finder = _common_finder(pcap_file)
    response = pm(filters.WRWR_RESPONSE, name_line_pattern='empty') \
        .containing('MessageIdentifier', '*{}*'.format(msg_id)) \
        .not_containing('*BroadcastCompletedAreaList*')

    messages_to_find = [
        pm(filters.WRWR_REQUEST, name_line_pattern='empty'),
        response
    ]
    return _find_all_messages(finder, messages_to_find)


def _find_all_messages(finder, messages_to_find):
    msgs = finder.find_all(messages_to_find, forget_matcher_on_hit=True)
    blog('found messages:')
    blog(msgs)
    assert len(msgs) == len(messages_to_find), "At least one message is missing!"
    return msgs


def _common_finder(pcap_file, filter='ngap'):
    with LogHelper() as lh:
        finder = lh.add_pcap(
            pcap_file_path=pcap_file, lua=None, shark_filter=filter,
            ts_output_data_file_path=None, clean_up_tmp_file=False
        )
    return finder


def pws_failure_indication_occured(pcap_file, cell_id, occurrence=2):
    return _expect_messages_with_occurence(pcap_file, cell_id, filters.PWS_FAILURE_INDICATION, occurrence)


def pws_restart_indication_occured(pcap_file, cell_id, occurrence=2):
    return _expect_messages_with_occurence(pcap_file, cell_id, filters.PWS_RESTART_INDICATION, occurrence)


def _expect_messages_with_occurence(pcap_file, cell_id, message, occurrence):
    finder = _common_finder(pcap_file)
    cell_id = get_nr_cell_id(mrbts_id, cell_id)
    msgs = finder.find_exactly(int(occurrence), pm(message, name_line_pattern='empty')
                               .containing('*nRCellIdentity', '*{}'.format(cell_id))
                               )
    blog(msgs)
    return msgs


def get_nr_cell_id(g_node_b_id, cell_id, nr_of_bits_g_node_b_id=32):
    return format(g_node_b_id << (36 - nr_of_bits_g_node_b_id) | int(cell_id), 'x')


def ue_released(pcap_file, filter='ngap', cause=None):
    finder = _common_finder(pcap_file, filter=filter)
    rel_command = pm('UEContextReleaseCommand', name_line_pattern='empty')
    if cause:
        rel_command = pm('UEContextReleaseCommand', name_line_pattern='empty') \
                      .containing('radioNetwork', f'{cause}*')
    expected_messages = [rel_command,
                         pm('UEContextReleaseComplete', name_line_pattern='empty')]
    return _find_all_messages(finder, expected_messages)


def ue_attached(pcap_file):
    finder = _common_finder(pcap_file)
    expected_messages = [pm('InitialContextSetupRequest', name_line_pattern='empty'),
                         pm('InitialContextSetupResponse', name_line_pattern='empty')]
    return _find_all_messages(finder, expected_messages)
