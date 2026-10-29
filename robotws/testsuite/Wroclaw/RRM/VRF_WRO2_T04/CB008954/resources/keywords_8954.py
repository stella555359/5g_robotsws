from robot.api import logger
from testsuite.Wroclaw.RRM.resources.log.helper import LogHelper
from testsuite.Wroclaw.RRM.resources.log.log import blog
from testsuite.Wroclaw.RRM.resources.log.matchers import PcapMessageMatcher


bwp_values = {
    "Large": '216',
    "Medium": '106',
    "Small": '79'
}


def _find_all_messages(finder, messages_to_find):
    found_msgs = finder.find_all(messages_to_find, forget_matcher_on_hit=True)
    blog('messages_to_find:')
    msgs_to_find = [m.tag for m in messages_to_find]
    blog(msgs_to_find)
    missing_msgs = set(msgs_to_find) - set(found_msgs.keys())
    assert len(found_msgs) == len(messages_to_find), \
        "At least one message is missing! Missing messages: {}".format(','.join(missing_msgs))
    return found_msgs


def bwp_finder(pcap_file, filter, message_name_pattern, message_type_pattern):
    with LogHelper() as lh:
        finder = lh.add_pcap(pcap_file_path=pcap_file, shark_filter=filter, lua=None)
        return finder.find_all(PcapMessageMatcher(message_name_pattern, name_line_pattern=message_type_pattern))


def _common_finder(pcap_file, filter=None):
    with LogHelper() as lh:
        finder = lh.add_pcap(
            pcap_file_path=pcap_file, lua=None, shark_filter=filter,
            ts_output_data_file_path=None, clean_up_tmp_file=False
        )
    return finder


def find_bwp_values(pcap_file):
    expected_messages = bwp_finder(pcap_file, 'f1ap', 'UEContextModificationResponse', message_type_pattern='empty')
    discovered_bwp_profiles = []
    for frame in expected_messages:
        bwp_config_dedicated = frame.find('carrierBandwidth')
        for element in bwp_config_dedicated:
            discovered_bwp_profiles.append(element['val'])
    return discovered_bwp_profiles


def check_bwp(bwp, pcap_file):
    discovered_bwp_profiles = find_bwp_values(pcap_file)
    if bwp_values[bwp] in discovered_bwp_profiles:
        logger.info(f"__OK! carrierBandwidth value for {bwp} is equal {bwp_values[bwp]}")
        logger.console(f"__OK! carrierBandwidth value for {bwp} is equal {bwp_values[bwp]}")
        return True
    else:
        assert False, f"__NOK! carrierBandwidth value for {bwp} (correct value: {bwp_values[bwp]}) " \
                      f"is equal {list(set(discovered_bwp_profiles))}"


def assert_reestablishment_occured(pcap_file):
    expected_messages = [PcapMessageMatcher('rrcReestablishmentComplete', name_line_pattern='empty')]
    finder = _common_finder(pcap_file, 'f1ap')
    return _find_all_messages(finder, expected_messages)
