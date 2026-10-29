import re
import testsuite.Wroclaw.RRM.resources.rrm_fixture as fixture
from testsuite.Wroclaw.RRM.resources.pcap_verification.tsharkWithLuaVerifier import TSharkCommandAssembler, \
        get_parameter_value_from_command_output


@fixture.logged_keyword
def find_context_release_request(pcap_file=None):
    if not pcap_file:
        pcap_file = "{path}/{filename}.pcap".format(path=fixture.get_robot_variable("${LOG_PATH}"),
                                                    filename=fixture.get_robot_variable("${test_name}"))
    output = TSharkCommandAssembler().with_pcap_file(pcap_file).with_filter('ngap').build()
    cause = get_parameter_value_from_command_output(output, parameter='radioNetwork:')
    return cause


@fixture.logged_keyword
def get_value_from_active_cell(counter_value):
    return max(counter_value[0]) if isinstance(counter_value, tuple) else counter_value


def attach_validation(attach_result_output):
    ip_pattern = r'(?<=IPv4 Address: )[0-9,.]*'
    match = re.search(ip_pattern, attach_result_output, re.DOTALL)
    assert match, "validation pattern not found in the script output"
    return match.group()
