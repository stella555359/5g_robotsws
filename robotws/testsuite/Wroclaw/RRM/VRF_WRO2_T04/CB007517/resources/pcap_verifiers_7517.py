from testsuite.Wroclaw.RRM.resources.log.helper import LogHelper
from testsuite.Wroclaw.RRM.resources.log.log import blog
from testsuite.Wroclaw.RRM.resources.log.matchers import PcapMessageMatcher as pm
from taf.analyzer.pcap import pcap
from robot.api import logger

NSETAPX_OPTIONS = [('-o', 'ntrstr.defragment:TRUE'), ('-o', 'ntrstr.port:49151')]
INTER_FREQ_HO_FILTER = 'nsetapx.purpose == 2  || nr-rrc.reconfigurationWithSync_element && nr-rrc.c1'


def _find_all_messages(finder, messages_to_find):
    found_msgs = finder.find_all(messages_to_find, forget_matcher_on_hit=True)
    blog('messages_to_find:')
    msgs_to_find = [m.tag for m in messages_to_find]
    blog(msgs_to_find)
    missing_msgs = set(msgs_to_find) - set(found_msgs.keys())
    assert len(found_msgs) == len(messages_to_find), \
        "At least one message is missing! Missing messages: {}".format(','.join(sorted(missing_msgs)))
    return found_msgs


def _messages_are_not_expected(finder, messages_to_find):
    found_msgs = finder.find_all(messages_to_find, forget_matcher_on_hit=True)
    assert not found_msgs, 'Messages are not expected: {}'.format(found_msgs.keys())


def _common_finder(pcap_file, filter=None):
    with LogHelper() as lh:
        finder = lh.add_pcap(
            pcap_file_path=pcap_file, lua=None, shark_filter=filter,
            ts_output_data_file_path=None, clean_up_tmp_file=False,
            shark_options=NSETAPX_OPTIONS
        )
    return finder


def _ngap_finder(pcap_file):
    return _common_finder(pcap_file, filter='ngap')


def assert_reestablishment_not_occured(pcap_file):
    expected_messages = [pm('rrcReestablishmentRequest', name_line_pattern='empty')]
    finder = _common_finder(pcap_file, 'f1ap')
    return _messages_are_not_expected(finder, expected_messages)


def assert_a4_event_is_configured(pcap_file):
    expected_messages = [pm('eventTriggered', name_line_pattern='empty', tag='a4')
                         .containing('eventA4')]
    finder = _common_finder(pcap_file, 'f1ap')
    return _find_all_messages(finder, expected_messages)


def ue_handovered_after_a4_event(pcap_file, target_cell):
    assert_reestablishment_not_occured(pcap_file)
    expected_messages = [pm('UEContextModificationResponse', name_line_pattern='empty')
                         .containing('reconfigurationWithSync').containing('physCellId', '*{}*'.format(target_cell))]
    finder = _common_finder(pcap_file, filter='f1ap')
    return _find_all_messages(finder, expected_messages)


def ue_handovered_after_a4_event_pcmd(pcap_filepath, from_cell, target_cell):
    def unwrap_nested_list(nested_list):
        lst = list(dict.fromkeys(
            [item for sublist in nested_list for item in (sublist if isinstance(sublist, list) else [sublist])]))
        return lst[0] if len(lst) == 1 else lst

    p = pcap()
    p.setup(infile=pcap_filepath, display_filter=INTER_FREQ_HO_FILTER)
    physcell_id = unwrap_nested_list(
        p.get_field_value('nr-rrc.physCellId',
                          filter=f'nr-rrc.reconfigurationWithSync_element'))
    physcell_id = physcell_id if isinstance(physcell_id, str) else [i for i in physcell_id if i == target_cell][0]
    logger.info(f"\nTarget PhysCell ID: {physcell_id}", also_console=True)
    trigger = unwrap_nested_list(p.get_field_value('nsetapx.triggerType', fmt='showname'))
    logger.info(f"{trigger.capitalize()}", also_console=True)
    pci = unwrap_nested_list(p.get_field_value('nsetapx.pci',
                                               filter=f'nsetapx.pci == {from_cell} && nsetapx.pci == {target_cell}'))
    logger.info(f"PCI [source, target]: {pci}", also_console=True)
    assert all([target_cell == physcell_id,
                "triggerType: a4" in trigger,
                pci == [from_cell, target_cell]
                ])


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


def assert_reestablishment_occured(pcap_file):
    expected_messages = [pm('rrcReestablishmentRequest', name_line_pattern='empty')]
    finder = _common_finder(pcap_file, 'f1ap')
    return _find_all_messages(finder, expected_messages)


def verify_a1_and_a4_measurement(pcap_file, rsrp_a1=48, rsrp_a4=50):
    msgs = [
        pm('UEContextModificationRequest', name_line_pattern='empty', tag='a1')
        .containing("reportConfigToAddModList*")
        .containing("eventA1")
        .containing("a1-Threshold*rsrp*")
        .containing("rsrp", "*SS-RSRP*({})".format(rsrp_a1)),
        pm('UEContextModificationRequest', name_line_pattern='empty', tag='a4')
        .containing("reportConfigToAddModList*")
        .containing("eventA4")
        .containing("a4-Threshold*rsrp*")
        .containing("rsrp", "*SS-RSRP*({})".format(rsrp_a4))
    ]
    finder = _common_finder(pcap_file, 'nr-rrc || f1ap')
    return _find_all_messages(finder, msgs)


def expect_handover_failure(pcap_file, interface):
    """
    :param pcap_file: path to pcap
    :param interface: xn or ng
    """
    msgs = [
        pm('HandoverPreparationFailure', name_line_pattern='empty')
        .containing("radioNetwork", "*target-not-allowed*")
    ]
    finder = _common_finder(pcap_file, '{}ap'.format(interface))
    return _find_all_messages(finder, msgs)
