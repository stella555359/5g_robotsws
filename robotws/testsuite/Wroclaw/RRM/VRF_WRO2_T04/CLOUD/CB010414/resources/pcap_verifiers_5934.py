from testsuite.Wroclaw.RRM.resources.log.helper import LogHelper
from testsuite.Wroclaw.RRM.resources.log.log import blog
from testsuite.Wroclaw.RRM.resources.log.matchers import PcapMessageMatcher as pm


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


def _common_finder(pcap_file, ts_filter=None):
    with LogHelper() as lh:
        finder = lh.add_pcap(
            pcap_file_path=pcap_file, lua=None, shark_filter=ts_filter,
            ts_output_data_file_path=None, clean_up_tmp_file=False
        )
    return finder


def _ngap_finder(pcap_file):
    return _common_finder(pcap_file, ts_filter='ngap')


def assert_a6_event_is_configured(pcap_file):
    expected_messages = [pm('eventTriggered', name_line_pattern='empty', tag='a6')
                         .containing('eventA6')]
    finder = _common_finder(pcap_file, 'f1ap')
    return _find_all_messages(finder, expected_messages)


def _expect_messages_with_occurrence(finder, messages, occurrence):
    for msg in messages:
        found_msgs = finder.find_exactly(int(occurrence), msg)
        blog(found_msgs)
