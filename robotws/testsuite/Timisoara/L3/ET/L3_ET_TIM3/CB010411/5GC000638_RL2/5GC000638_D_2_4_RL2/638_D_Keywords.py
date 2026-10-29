from ta5g_tshark import ta5g_tshark
from ta5g_global_var import DEFAULT_NG_XN_TSHARK_ALIAS
import datetime as dt
from robot.errors import ExecutionFailed
import re


def get_list_of_timestamps_from_tshark_messages(packet_filter, pcap_file_path, output_pdml_filepath,
                                                alias=DEFAULT_NG_XN_TSHARK_ALIAS):
    """
    :param alias:
    :param packet_filter:
    :param output_pdml_filepath:
    :return:
    """
    times_of_messages = ta5g_tshark().get_attribute_values_from_tshark_messages(
        alias=alias,
        filter=packet_filter,
        pcap_file_path=pcap_file_path,
        output_pdml_filepath=output_pdml_filepath,
        element_xpath='.//packet',
        attribute_xpath='.//field[@name="timestamp"]',
        attribute='show')
    time_format = "%H:%M:%S.%f"
    times_of_messages = [dt.datetime.strptime(re.search(r'\d+:\d\d:\d\d\.\d\d\d\d\d\d', single_time).group(0),
                                              time_format) for single_time in times_of_messages]
    return times_of_messages


def check_if_all_time_differences_are_equal_ng_setup_resp_tmr(times_table, ng_setup_resp_tmr, delta_error=0.01):
    """
    :param times_table:
    :param ng_setup_resp_tmr: time in seconds
    :param delta_error:
    :return:
    """
    differences = [(times_table[i+1]-times_table[i]).total_seconds() for i in range(len(times_table)-1)]
    upper_limit = int(ng_setup_resp_tmr)+delta_error
    lower_limit = int(ng_setup_resp_tmr)-delta_error
    if all(lower_limit <= diff <= upper_limit for diff in differences):
        return True
    else:
        raise ExecutionFailed(
                message="Not all time differences in list {} "
                        "fit into interval  {}-{}s".format(differences, lower_limit, upper_limit),
                continue_on_failure=True,
            )
