from bs4 import BeautifulSoup
from robot.libraries.BuiltIn import BuiltIn
import re


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


def get_isCsirsRateMatching_and_numCsirsMappingRes(pdml_path):
    with open(pdml_path, 'r') as pdml_file:
        xml_tree = BeautifulSoup(pdml_file, 'xml')
        dldata_pdschgrant = xml_tree.find_all('proto', attrs={'name': '_5g_l1_dl_l2_ps_dldata_pdschgrant'})
        for data in dldata_pdschgrant:
            isCsirsRateMatching = (int(data.find('field', attrs={'name': re.
                                                 compile('DlData_PdschGrant.isCsirsRateMatching')}).get('show')))
            numCsirsMappingRes = (int(data.find('field', attrs={'name': re.
                                                compile('DlData_PdschGrant.numCsirsMappingRes')}).get('show')))
        return isCsirsRateMatching, numCsirsMappingRes


def get_rateMatchingOption_and_numRateMatchingRes(pdml_path):
    with open(pdml_path, 'r') as pdml_file:
        xml_tree = BeautifulSoup(pdml_file, 'xml')
        dldata_pdschgrant = xml_tree.find_all('proto', attrs={'name': 'nr_l1dl_l2ps_dldata_pdschgrantl1sw'})
        for data in dldata_pdschgrant:
            rateMatchingOption = (int(data.find('field', attrs={'name': re.
                                                compile('DlData_PdschGrantL1sw.rateMatchingOption')}).get('show')))
            numRateMatchingRes = (int(data.find('field', attrs={'name': re.
                                                compile('DlData_PdschGrantL1sw.numRateMatchingRes')}).get('show')))
        return rateMatchingOption, numRateMatchingRes


def get_ssburstoffloadreceiveresp_data(pdml_path):
    data_item = []
    with open(pdml_path, 'r') as pdml_file:
        xml_tree = BeautifulSoup(pdml_file, 'xml')
        ssburstoffloadreceiveresp = xml_tree.find_all('field', attrs={'show': 'data (DynamicVariableSizedArray)'})
        for i in range(240, 252):
            for data in ssburstoffloadreceiveresp:
                data_item.append(int(data.find('field', attrs={'showname': re.compile('data_item_'
                                                                                      + str(i))}).get('show')))
    return data_item


def get_avg_data_traffic_for_given_cc(ue_id, cc, direction, unit):
    ue_stats = get_ue_stats_for_given_cc(ue_id, cc, direction)
    pattern = re.compile(r'(\d*\.\d) ({})'.format(unit))
    avg_tput = pattern.findall(ue_stats)[-1][0]
    return float(avg_tput)


def get_ue_stats_for_given_cc(ue_id, cc, direction):
    stats_type = 'pdsch' if direction == 'dl' else 'pusch'
    return ute_wtssim_instance.execute_egate_command_and_wait_for_data(cmd='ue_stats_nr id={} type={} scell={}'
                                                                       .format(ue_id, stats_type, cc),
                                                                       pass_regexp='UE-{}: NR {} Throughput'
                                                                       .format(ue_id, stats_type.upper()))
