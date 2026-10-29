from testsuite.Wroclaw.RRM.resources.log.helper import LogHelper
from testsuite.Wroclaw.RRM.resources.log.log import blog
from testsuite.Wroclaw.RRM.resources.log.matchers import PcapMessageMatcher as pm
from variables_6733 import RSRP_THRESHOLDS

NSETAPX_OPTIONS = [('-o', 'ntrstr.defragment:TRUE'), ('-o', 'ntrstr.port:49148')]


def _find_all_messages(finder, messages_to_find):
    found_msgs = finder.find_all(messages_to_find, forget_matcher_on_hit=True)
    blog('messages_to_find:')
    msgs_to_find = [m.tag for m in messages_to_find]
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


def assert_a4_event_is_configured(pcap_file, thresholds=RSRP_THRESHOLDS):
    if isinstance(thresholds, str):
        thresholds = thresholds.split(',')
    expected_messages = [pm('eventTriggered', name_line_pattern='empty', tag=f'a4_{rsrp}')
                         .containing('eventA4*')
                         .containing('rsrp', f'*{rsrp}*')
                         .containing('timeToTrigger', 'ms40*') for rsrp in thresholds
                         ]
    finder = _common_finder(pcap_file, 'nr-rrc.reportConfig')
    return _find_all_messages(finder, expected_messages)


def find_meas_id_adds(pcap_file, expected_num_of_msg=None, expected_config_ids=None):
    msg = pm('measIdToAddModList*', name_line_pattern='empty', tag=f'measidtoaddmodlist')
    if expected_config_ids:
        expected_config_ids = expected_config_ids.split(',')
        for config_id in expected_config_ids:
            msg = msg.containing('MeasIdToAddMod').containing('reportConfigId', '*{}*'.format(config_id))

    finder = _common_finder(pcap_file, filter='nr-rrc.measIdToAddModList')
    if expected_num_of_msg is not None:
        return _expect_messages_with_occurrence(finder, messages=[msg], occurrence=expected_num_of_msg)
    found_msgs = _find_all_messages(finder, messages_to_find=[msg])
    return len(found_msgs), found_msgs


def find_meas_id_removes(pcap_file, expected_num_of_msg=None, expected_meas_ids=None):
    msg = pm('measIdToRemoveList*', name_line_pattern='empty', tag=f'measidtoremovelist')

    if expected_meas_ids:
        msg = pm(f'measIdToRemoveList*{expected_meas_ids}*', name_line_pattern='empty',
                 tag=f'measidtoremovelist_{expected_meas_ids}_items')\

    finder = _common_finder(pcap_file, filter='nr-rrc.measIdToRemoveList')
    if expected_num_of_msg is not None:
        return _expect_messages_with_occurrence(finder, messages=[msg], occurrence=expected_num_of_msg)
    found_msgs = _find_all_messages(finder, messages_to_find=[msg])
    return len(found_msgs), found_msgs


def ue_handovered_after_a4_event_pcmd(pcap_file, from_cell, target_cell):
    expected_messages = [
        pm('rrcReconfiguration*', name_line_pattern='empty')
        .containing('reconfigurationWithSync').containing('physCellId', '*{}*'.format(target_cell)),
        pm('recordingSessionReportList*', name_line_pattern='empty')
        .containing('triggerType', '*a4*')
        .containing('purpose', '*interFreqHo*')
        .containing('pci', ''.format(from_cell))
        .containing('pci', ''.format(target_cell))
        ]
    finder = _common_finder(pcap_file, filter='nsetapx')
    return _find_all_messages(finder, expected_messages)


def _expect_messages_with_occurrence(finder, messages, occurrence):
    for msg in messages:
        found_msgs = finder.find_exactly(int(occurrence), msg)
        blog(found_msgs)


def assert_buffer_monitoring_was_activated(pcap_file):
    buffer_monitoring = __find_buffer_monitoring_check(pcap_file)
    assert buffer_monitoring > 0


def assert_buffer_monitoring_was_not_activated(pcap_file):
    buffer_monitoring = __find_buffer_monitoring_check(pcap_file)
    assert buffer_monitoring == 0


def __find_buffer_monitoring_check(pcap_file):
    msg = pm('BufferMonitoringNotification', name_line_pattern='empty')\
            .containing('BufferMonitoring', 'activate-dl*')
    finder = _common_finder(pcap_file, filter='nokiaf1ap.BufferMonitoring == 0')
    messages = finder.find_all([msg])
    return len(messages)


def assert_buffer_criterion_was_activated(pcap_file):
    buffer_criterion = __find_buffer_criterion(pcap_file)
    assert buffer_criterion > 0


def assert_buffer_criterion_was_not_activated(pcap_file):
    buffer_criterion = __find_buffer_criterion(pcap_file)
    assert buffer_criterion == 0


def __find_buffer_criterion(pcap_file):
    msg = pm('BufferCriterionNotification', name_line_pattern='empty') \
        .containing('BufferCriterion', 'downlink*')
    finder = _common_finder(pcap_file, filter='nokiaf1ap.BufferCriterion == 0')
    return len(finder.find_all([msg]))


def assert_a4_meas_configs_are_visible(pcap_file, thresholds):
    assert_a4_event_is_configured(pcap_file, thresholds)
    assert find_meas_id_adds(pcap_file)


def assert_a4_meas_configs_are_not_visible(pcap_file):
    return find_meas_id_adds(pcap_file, expected_num_of_msg=0)
