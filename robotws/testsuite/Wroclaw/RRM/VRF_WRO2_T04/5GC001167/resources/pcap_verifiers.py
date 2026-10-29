from testsuite.Wroclaw.RRM.resources.log.helper import LogHelper
from testsuite.Wroclaw.RRM.resources.log.log import blog
from testsuite.Wroclaw.RRM.resources.log.matchers import PcapMessageMatcher as pm
from testsuite.Wroclaw.RRM.VRF_WRO2_T04.resources.color_log import write_mixed_line


def _find_all_messages(finder, messages_to_find):
    found_msgs = finder.find_all(messages_to_find, forget_matcher_on_hit=True)
    blog('messages_to_find:')
    msgs_to_find = [m.tag for m in messages_to_find]
    blog(msgs_to_find)
    missing_msgs = set(msgs_to_find) - set(found_msgs.keys())
    assert len(found_msgs) == len(messages_to_find), \
        f"At least one message is missing! Missing messages: {','.join(missing_msgs)}"
    return found_msgs


def _messages_are_not_expected(finder, messages_to_find):
    found_msgs = finder.find_all(messages_to_find, forget_matcher_on_hit=True)
    assert not found_msgs, f'Messages are not expected: {found_msgs.keys()}'


def _common_finder(pcap_file, filter=None):
    with LogHelper() as lh:
        finder = lh.add_pcap(
            pcap_file_path=pcap_file, lua=None, shark_filter=filter,
            ts_output_data_file_path=None, clean_up_tmp_file=False
        )
    return finder


def _ngap_finder(pcap_file):
    return _common_finder(pcap_file, filter='ngap')


def get_nr_cell_id(g_node_b_id, cell_id, nr_of_bits_g_node_b_id=32):
    return format(g_node_b_id << (36 - nr_of_bits_g_node_b_id) | cell_id, 'x')


def ue_released(pcap_file, num_of_releases=1):
    finder = _ngap_finder(pcap_file)
    expected_messages = [pm('UEContextReleaseCommand', name_line_pattern='empty'),
                         pm('UEContextReleaseComplete', name_line_pattern='empty')]
    return _expect_messages_with_occurrence(finder, expected_messages, num_of_releases)


def ue_attached(pcap_file):
    finder = _ngap_finder(pcap_file)
    expected_messages = [pm('InitialContextSetupRequest', name_line_pattern='empty'),
                         pm('InitialContextSetupResponse', name_line_pattern='empty')]
    messages = _find_all_messages(finder, expected_messages)
    write_mixed_line("PDU SESSION: [", " OK ", "]")
    return messages


def scells_added(pcap_file, num_of_scells, scells_id='', index_start=1):
    finder = _common_finder(pcap_file, 'nr-rrc')
    if not scells_id:
        scells_id = ['*']
    if not isinstance(scells_id, (tuple, list)):
        scells_id = scells_id.split(',')
    scells_indexes = range(index_start, int(num_of_scells) + index_start)
    zipped = zip(scells_indexes, scells_id)
    expected_messages = [pm('UEContextModificationResponse', name_line_pattern='empty',
                            tag=f'Scell_addition_{physcell}')
                         .containing(f'sCellToAddModList*{num_of_scells}*')
                         .containing('physCellId', f'*{physcell}*')
                         .containing('sCellIndex', f'*{scell_index}*') for scell_index, physcell in zipped]
    return _find_all_messages(finder, expected_messages)


def scell_added(pcap_file, scell_id, scell_index):
    finder = _common_finder(pcap_file, 'nr-rrc')
    expected_messages = [pm('UEContextModificationResponse', name_line_pattern='empty',
                            tag=f'Scell_add_{scell_index}')
                         .containing('sCellToAddModList*1*')
                         .containing('physCellId', f'*{scell_id}*')
                         .containing('sCellIndex', f'*{scell_index}*')]
    return _find_all_messages(finder, expected_messages)


def ul_scell_configured(pcap_file, scell_id, scell_index=1):
    finder = _common_finder(pcap_file, 'nr-rrc')
    expected_messages = [pm('UEContextModificationRequest', name_line_pattern='empty')
                         .containing('SCell-ToBeSetupMod-List*')
                         .containing('sCellULConfigured', 'ul*')
                         .containing('sCellIndex', f'*{scell_index}*')]
    return _find_all_messages(finder, expected_messages)


def scell_released(pcap_file, scell_index):
    finder = _common_finder(pcap_file, 'nr-rrc')
    expected_messages = [pm('UEContextModificationResponse', name_line_pattern='empty',
                            tag=f'Scell_release_{scell_index}')
                         .containing('sCellToReleaseList*1*')
                         .containing('SCellIndex', f'*{scell_index}*')]
    return _find_all_messages(finder, expected_messages)


def scell_swap_performed(pcap_file, scell_added_id, scell_added_index, scell_released_index):
    scell_released(pcap_file, scell_index=scell_released_index)
    scell_added(pcap_file, scell_id=scell_added_id, scell_index=scell_added_index)


def ue_attached_to_pcell_and_scells(pcap_file, num_of_scells=1, scells_id='', vonr=False):
    ue_attached(pcap_file)
    if int(num_of_scells) > 0:
        scells_added(pcap_file, num_of_scells=num_of_scells, scells_id=scells_id)
        write_mixed_line("SCELL ADDITION: [", " OK ", "]")
        write_mixed_line("SCELLS: [ ", f"{scells_id}", " ]")
    if vonr:
        assert_both_pdu_session_established(pcap_file)
        write_mixed_line("VONR SESSION: [", " OK ", "]")


def assert_reestablishment_not_occured(pcap_file):
    expected_messages = [pm('rrcReestablishmentRequest', name_line_pattern='empty')]
    finder = _common_finder(pcap_file, 'f1ap')
    return _messages_are_not_expected(finder, expected_messages)


def ue_handovered(pcap_file, target_cell):
    assert_reestablishment_not_occured(pcap_file)
    expected_messages = [pm('UEContextModificationResponse', name_line_pattern='empty')
                         .containing('reconfigurationWithSync').containing('physCellId', f'*{target_cell}*')]
    finder = _common_finder(pcap_file, filter='ngap || f1ap')
    return _find_all_messages(finder, expected_messages)


def _expect_messages_with_occurrence(finder, messages, occurrence):
    for msg in messages:
        found_msgs = finder.find_exactly(int(occurrence), msg)
        blog(found_msgs)


def ue_not_released(pcap_file):
    finder = _ngap_finder(pcap_file)
    unexpected_messages = [pm('UEContextReleaseCommand', name_line_pattern='empty'),
                           pm('UEContextReleaseComplete', name_line_pattern='empty')]
    msgs = finder.find_all(unexpected_messages)
    assert len(msgs) == 0, "Unexpected UE release!"


def assert_vonr_call_started_with_qos_1(pcap_file, occurrence, qos='1'):
    qos1_start = [
        pm('PDUSessionResourceModifyRequest*', name_line_pattern='empty', tag='VonrStartReq')
        .containing('QosFlowAddOrModifyRequestList*')
        .containing('qosFlowIdentifier*', qos),

        pm('PDUSessionResourceModifyResponse*', name_line_pattern='empty', tag='VonrStartResp')
        .containing('QosFlowAddOrModifyResponseItem*')
        .containing('qosFlowIdentifier*', qos)
    ]
    qos1_end = [
        pm('PDUSessionResourceModifyRequest*', name_line_pattern='empty', tag='VonrEndReq')
        .containing('QosFlowWithCauseItem*')
        .containing('qosFlowIdentifier*', qos),

        pm('PDUSessionResourceModifyResponse*', name_line_pattern='empty', tag='VonrEndResp')
        .containing('PDUSessionResourceModifyListModRes*')
        .containing('PDUSessionResourceModifyResponseTransfer*')
        .not_containing('qosFlowAddOrModifyResponseList*')
    ]
    finder = _ngap_finder(pcap_file)
    return _expect_messages_with_occurrence(finder, qos1_start + qos1_end, occurrence=occurrence)


def __pdu_list(qos_first, qos_second):
    pdu_list = [
        pm('InitialContextSetupResponse', name_line_pattern='empty')
        .containing('PDUSessionResourceSetupResponseTransfer')
        .containing('qosFlowIdentifier*', qos_first),
        pm('PDUSessionResourceSetupResponse', name_line_pattern='empty')
        .containing('qosFlowIdentifier*', qos_second)
    ]
    return pdu_list


def assert_both_pdu_session_established(pcap_file):
    finder = _common_finder(pcap_file)
    try:
        return _find_all_messages(finder, __pdu_list('5', '9'))
    except AssertionError:
        return _find_all_messages(finder, __pdu_list('9', '5'))
