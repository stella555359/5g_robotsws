from robot.api import logger
import time
from robot.libraries.BuiltIn import BuiltIn
from ta5g_throughput.table_parser import TableParser
from ta5g_tshark import ta5g_tshark
ute_wtssim_instance = BuiltIn().get_library_instance('ute_wtssim')


# TEMPORARY SOLUTION - PRE-CHECK ON AP AS cell_stats_nr COMMAND NOT WORKING AS EXPECTED, UNTIL FIX IS DELIVERED,
# TRAFIC WILL BE CHECKED VIA THE COMMAND ue_stats_nr
# AFTER FIX DELIVERED CODE WITH cell_stats_nr WILL BE MOVED TO TA5G

"""

def assert_traffic_after_procedure(cell_id, enb, unit='kbps', traffic_stabilization=True, checked_traffic=0,
                                   margin=0.1):
    current_traffic = get_cell_dl_data_traffic(cell_id, enb, unit=unit, traffic_stabilization=traffic_stabilization)
    checked_traffic = int(checked_traffic)
    lower_limit = int(checked_traffic - margin*checked_traffic)
    upper_limit = int(checked_traffic + margin*checked_traffic)
    if current_traffic in range(lower_limit, upper_limit):
        pass
    else:
        raise Exception("Traffic before procedure was: {}, now it is: ".format(checked_traffic, current_traffic))


def get_cell_dl_data_traffic(cell_id, enb, unit='kbps', traffic_stabilization=True):
    if traffic_stabilization:
        time.sleep(10)
    raw_throughput_string = _get_cell_stats(cell_id, enb)
    ta5g_throughput_instance = TableParser()
    throughput_stats = ta5g_throughput_instance.parse_egate_table(raw_throughput_string)
    return int((throughput_stats[0]['DL Current Data Rate']).split(".")[0])


def _get_cell_stats(cell_id, enb):
    return ute_wtssim_instance.execute_egate_command_and_wait_for_data(cmd="cell_stats_nr enb={} id={} \
                                                                       type=throughput".format(enb, cell_id),
                                                                       pass_regexp="eNB-{}: Cell's THROUGHPUT info"
                                                                       .format(enb))

"""

# BELOW CODE WILL BE REMOVED
# TEMPORARY SOLUTION - PRE-CHECK ON AP AS cell_stats_nr COMMAND NOT WORKING AS EXPECTED, UNTIL FIX IS DELIVERED,
# TRAFIC WILL BE CHECKED VIA THE COMMAND ue_stats_nr


def assert_traffic_after_procedure(ue_id, traffic_stabilization=True, checked_traffic=0,
                                   margin=0.1):
    current_traffic = get_cell_dl_data_traffic(ue_id, traffic_stabilization=traffic_stabilization)
    checked_traffic = int(checked_traffic)
    lower_limit = int(checked_traffic - margin*checked_traffic)
    upper_limit = int(checked_traffic + margin*checked_traffic)
    if current_traffic in range(lower_limit, upper_limit):
        pass
    else:
        raise Exception("Traffic before procedure was: {}, now it is: ".format(checked_traffic, current_traffic))


def get_cell_dl_data_traffic(ue_id, traffic_stabilization=True):
    if traffic_stabilization:
        time.sleep(10)
    raw_throughput_string = _get_cell_stats(ue_id)
    ta5g_throughput_instance = TableParser()
    throughput_stats = ta5g_throughput_instance.parse_egate_table(raw_throughput_string)
    return int((throughput_stats[0]['Current']).split(".")[0])


def _get_cell_stats(ue_id):
    return ute_wtssim_instance.execute_egate_command_and_wait_for_data(cmd="ue_stats_nr id={}".format(ue_id),
                                                                       pass_regexp="UE-{}: NR PDSCH Throughput"
                                                                       .format(ue_id))


def check_if_message_rrc_reestablishment_complete_is_visible():
    tshark_instance = ta5g_tshark()
    try:
        tshark_instance.verify_tshark(alias='default_uu', packet_filter='nr-rrc.rrcReestablishmentComplete_element',
                                      pass_criteria='>=1')
    except Exception as e:
        logger.console("Message RRC_REESTABLISHMENT_COMPLETE is not visible in pcap")


def verify_rrcReestablishment():
    tshark_instance = ta5g_tshark()
    try:
        tshark_instance.verify_tshark(alias='default_tcpdump_alias', packet_filter='nr-rrc.rrcReestablishment_element',
                                      pass_criteria='>=1', pcap_file_path='deafult')
        return
    except Exception:
        pass
    try:
        tshark_instance.verify_tshark(alias='default_uu', packet_filter='nr-rrc.rrcReestablishment_element',
                                      pass_criteria='>=1')
    except Exception:
        raise Exception("rrcReestablishment_element is not visible in UU messages or Tcpdump Log")
