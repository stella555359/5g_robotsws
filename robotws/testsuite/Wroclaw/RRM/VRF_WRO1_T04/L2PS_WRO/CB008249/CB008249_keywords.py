from bs4 import BeautifulSoup
from robot.libraries.BuiltIn import BuiltIn
import re

ute_wtssim_instance = BuiltIn().get_library_instance('ute_wtssim')


def verify_if_SRS_is_enabled(pdml_path):
    with open(pdml_path, 'r') as pdml_file:
        xml_tree = BeautifulSoup(pdml_file, 'xml')
    srs_enable_list = xml_tree.find_all('proto', attrs={'name': 'uldata_srsreceivereq'})
    if not srs_enable_list:
        raise Exception("Check failed - srs_enable_list is empty")
    for record in srs_enable_list:
        srs_info = record.find('field', attrs={'name': re.compile('srsBmEnable')}).get('show')
        if not srs_info:
            raise Exception("Check failed")


def verify_if_SRS_is_disabled(pdml_path):
    with open(pdml_path, 'r') as pdml_file:
        xml_tree = BeautifulSoup(pdml_file, 'xml')
    srs_enable_list = xml_tree.find_all('proto', attrs={'name': 'uldata_srsreceivereq'})
    if not srs_enable_list:
        pass
    for record in srs_enable_list:
        srs_info = record.find('field', attrs={'name': re.compile('srsBmEnable')}).get('show')
        if srs_info:
            raise Exception("Check failed")


def get_avg_data_traffic_nsa(ue_id, id, dir, unit):
    bearer_stats_nsa = get_bearer_stats_nsa(ue_id, id, dir)
    pattern = re.compile(r'(\d*\.\d) ({})'.format(unit))
    avg_tput = pattern.findall(bearer_stats_nsa)[2][0]
    return float(avg_tput)


def get_bearer_stats_nsa(ue_id, id, dir):
    return ute_wtssim_instance.execute_egate_command_and_wait_for_data(cmd='bearer_stats ue={} id={} dir={}'
                                                                       .format(ue_id, id, dir),
                                                                       pass_regexp='UE {}, bearer {}: {} '
                                                                       'L3 stats for internal traffic'
                                                                       .format(ue_id, id, dir.upper()))


def get_ue_stats_for_given_cc(ue_id, cc, direction):
    if direction == 'dl':
        stats_type = 'pdsch'
    else:
        stats_type = 'pusch'
    return ute_wtssim_instance.execute_egate_command_and_wait_for_data(cmd='ue_stats_nr id={} type={} scell={}'
                                                                       .format(ue_id, stats_type, cc),
                                                                       pass_regexp='UE-{}: NR {} Throughput'
                                                                       .format(ue_id, stats_type.upper()))


def get_avg_data_traffic_for_given_cc(ue_id, cc, direction, unit):
    ue_stats = get_ue_stats_for_given_cc(ue_id, cc, direction)
    pattern = re.compile(r'(\d*\.\d) ({})'.format(unit))
    avg_tput = pattern.findall(ue_stats)[-1][0]
    return float(avg_tput)
