from testsuite.Wroclaw.RRM.resources.log.helper import LogHelper
from testsuite.Wroclaw.RRM.resources.log.matchers import PcapMessageMatcher as pm
from testsuite.Wroclaw.RRM.resources.log.log import blog

NSETAPX_OPTIONS = [('-o', 'ntrstr.defragment:TRUE'), ('-o', 'ntrstr.port:49148')]


def _common_finder(pcap_file, filter=None):
    with LogHelper() as lh:
        finder = lh.add_pcap(
            pcap_file_path=pcap_file, lua=None, shark_filter=filter,
            ts_output_data_file_path=None, clean_up_tmp_file=False,
            shark_options=NSETAPX_OPTIONS
        )
    return finder


def _find_all_messages(finder, messages_to_find):
    found_msgs = finder.find_all(messages_to_find, forget_matcher_on_hit=True)
    blog('messages_to_find:')
    msgs_to_find = [m.tag for m in messages_to_find]
    blog(msgs_to_find)
    missing_msgs = set(msgs_to_find) - set(found_msgs.keys())
    assert len(found_msgs) == len(messages_to_find), \
        "At least one message is missing! Missing messages: {}".format(','.join(sorted(missing_msgs)))
    return found_msgs


def trigger_verification(pcap_file, status='successfulOutcome'):
    expected_messages = [
        pm('*E-CIDMeasurementInitiationResponse*', name_line_pattern='empty')
        .containing(f"{status}*")]
    finder = _common_finder(pcap_file, filter='f1ap')
    return _find_all_messages(finder, expected_messages)
