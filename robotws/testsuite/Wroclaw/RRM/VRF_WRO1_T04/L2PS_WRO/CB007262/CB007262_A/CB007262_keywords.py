from robot.api import logger

from robot.libraries.BuiltIn import BuiltIn
import re
import io

ute_wtssim_instance = BuiltIn().get_library_instance('ute_wtssim')


def get_bearer_stats(ue_id, pdu, qfi, dir):
    return ute_wtssim_instance.execute_egate_command_and_wait_for_data(cmd='bearer_stats ue={} pdu={} qfi={} dir={}'
                                                                       .format(ue_id, pdu, qfi, dir),
                                                                       pass_regexp='UE {}, pdu {}, qfi {}: {} '
                                                                       'L3 stats for internal traffic'
                                                                       .format(ue_id, pdu, qfi, dir.upper()))


def get_avg_data_traffic_sa(ue_id, pdu, qfi, dir, unit):
    bearer_stats = get_bearer_stats(ue_id, pdu, qfi, dir)
    pattern = re.compile(r'(\d*\.\d) ({})'.format(unit))
    avg_tput = pattern.findall(bearer_stats)[2][0]
    return float(avg_tput)


def get_bearer_stats_nsa(ue_id, id, dir):
    return ute_wtssim_instance.execute_egate_command_and_wait_for_data(cmd='bearer_stats ue={} id={} dir={}'
                                                                       .format(ue_id, id, dir),
                                                                       pass_regexp='UE {}, bearer {}: {} '
                                                                       'L3 stats for internal traffic'
                                                                       .format(ue_id, id, dir.upper()))


def get_avg_data_traffic_nsa(ue_id, id, dir, unit):
    bearer_stats_nsa = get_bearer_stats_nsa(ue_id, id, dir)
    pattern = re.compile(r'(\d*\.\d) ({})'.format(unit))
    avg_tput = pattern.findall(bearer_stats_nsa)[2][0]
    return float(avg_tput)
