from taf.transport.ssh import ssh
from bs4 import BeautifulSoup
from robot.libraries.BuiltIn import BuiltIn
import re


ute_wtssim_instance = BuiltIn().get_library_instance('ute_wtssim')


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


def execute_command_on_the_remote(cmd, hostname, username, password):
    """Wrapper for taf ssh library remote command execution.

    :param cmd: string of command to execute
    :param hostname: hostname of the remote
    :param username: username of the remote
    :param password: password of the remote
    :return: Tuple(exit_code, output)
    """
    ssh_instance = ssh()
    ssh_instance.connect_to(hostname=hostname, username=username, password=password)
    output = ssh_instance.execute(cmd)
    rc = ssh_instance.get_exit_status()
    ssh_instance.disconnect()
    return rc, output


def run_on_gnb(cmd, hostname="192.168.255.129", username="toor4nsn", password="oZPS0POrRieRtu"):
    """Execute command on gNB

    :param cmd: command
    :param hostname: bts hostname
    :param username: bts username
    :param password: bts password
    :return: Tuple(exit_code, output)
    """
    return execute_command_on_the_remote(cmd, hostname, username, password)


def get_csirs_num_and_start_prbs(pdml_path, trs):
    start_prb = []
    num_prb = []
    with open(pdml_path, 'r') as pdml_file:
        xml_tree = BeautifulSoup(pdml_file, 'xml')
        csirs_resources = xml_tree.find_all('proto', attrs={'name': '_5g_l1_dl_l2_ps_dldata_csirsresource_t'})
        for csirs in csirs_resources:
            trs_info = csirs.find('field', attrs={'name': re.compile('trsInfo')})
            if trs_info is not None and trs_info.get('show') == trs:
                start_prb.append(int(csirs.find('field', attrs={'name': re.compile('startPrb')}).get('show')))
                num_prb.append(int(csirs.find('field', attrs={'name': re.compile('numOfPrb')}).get('show')))
    return zip(start_prb, num_prb)


def verify_csi_rs_split(pdml_path):
    csirs_split_condition = set(get_csirs_num_and_start_prbs(pdml_path, trs='0')) == {(0, 48), (64, 96)}
    if csirs_split_condition:
        print("Check passed, CSI-RS for measurement split:\n1.startPrb: 0, numOfPrb: 48\n2.startPrb: 64, numOfPrb: 96")
    else:
        raise Exception("Check failed, incorrect CSI-RS for measurement split")


def verify_trs_split(pdml_path):
    trs_split_condition = set(get_csirs_num_and_start_prbs(pdml_path, trs='1')) == {(0, 50), (55, 105)}
    if trs_split_condition:
        print("Check passed, TRS split: \n1.startPrb: 0, numOfPrb: 50 \n2.startPrb: 55, numOfPrb: 105")
    else:
        raise Exception("Check failed, incorrect TRS split")


def verify_trs_split_52prb(pdml_path):
    trs_split_condition = set(get_csirs_num_and_start_prbs(pdml_path, trs='1')) == {(0, 50)}
    if trs_split_condition:
        print("Check passed, TRS split: \n1.startPrb: 0, numOfPrb: 50")
    else:
        raise Exception("Check failed, incorrect TRS split")
