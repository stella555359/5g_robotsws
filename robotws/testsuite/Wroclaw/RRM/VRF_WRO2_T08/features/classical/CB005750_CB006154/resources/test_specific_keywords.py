import os.path
import re
from time import sleep

from robot.libraries.BuiltIn import BuiltIn
from six import ensure_str
from ta_attenuator import ta_attenuator
from taf.sw.qualcomm.license.interface import license
from taf.transport.ssh import ssh

from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.admin import Admin5G, AdminLTE
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.decorators import wait_until_function_succeeds
from testsuite.Wroclaw.RRM.resources.log.helper import LogHelper
from testsuite.Wroclaw.RRM.resources.log.log import blog
from testsuite.Wroclaw.RRM.resources.log.matchers import PcapMessageMatcher as PM

current_lua = None
_attenuator = ta_attenuator()
_builtin = BuiltIn()
_taf_ue = _builtin.get_library_instance("taf.ue")
_ssh = ssh()

tl = _builtin.get_variable_value("${tl}")
ue = tl.ues[0]
gnb_id = tl.gnbs[0].global_bts_id
enb_id = tl.enbs[0].global_bts_id
uepc_logs_path = "C:/Users/wro5grrm.NOKLAB/auto/logs/"

CONFIG = {
    'GNB_1_CELL_179': {
        'CELL_ID': '1',
        'min_att': '40dB',
        'att_levels': ['50dB', '65dB', '60dB'],
        '64QAM': {
            'UL': '50Mbits/sec',
            'DL': '460Mbits/sec'
        },
        '256QAM': {
            'UL': '50Mbits/sec',
            'DL': '580Mbits/sec'
        },
        'NRARFCN': {
            'lower': {
                '5G': '629366',
                'LTE': '629280'
            },
            'middle': {
                '5G': '636666',
                'LTE': '636576'
            },
            'higher': {
                '5G': '644000',
                'LTE': '643968'
            }
        }
    },
    'GNB_1_CELL_55': {
        'CELL_ID': '5',
        'min_att': '15dB',
        'att_levels': ['55dB', '70dB', '65dB'],
        '64QAM': {
            'UL': '50Mbits/sec',
            'DL': '360Mbits/sec'
        },
        '256QAM': {
            'UL': '50Mbits/sec',
            'DL': '460Mbits/sec'
        },
        'NRARFCN': {
            'lower': {
                '5G': '630336',
                'LTE': '630336'
            },
            'middle': {
                '5G': '637152',
                'LTE': '637152'
            },
            'higher': {
                '5G': '642600',
                'LTE': '642528'
            }
        }
    }
}


def get_5g_qxdm_and_qcat_license(username, password, ue_id):
    launcher = {'host': tl.ues[int(ue_id)].ue_pc_address,
                'path': "/cygdrive/c/QPM_LK1.5.1",
                'user': tl.ues[int(ue_id)].ue_pc_login,
                'password': tl.ues[int(ue_id)].ue_pc_password}
    lk = license()
    lk.setup(launcher=launcher)
    lk.login(username=username, password=password)
    lk.get_licence_qxdm_5g()
    lk.get_licence_qcat_5g()


def release_5g_qxdm_and_qcat_license(ue_id):
    launcher = {'host': tl.ues[int(ue_id)].ue_pc_address,
                'path': "/cygdrive/c/QPM_LK1.5.1",
                'user': tl.ues[int(ue_id)].ue_pc_login,
                'password': tl.ues[int(ue_id)].ue_pc_password}
    lk = license()
    lk.setup(launcher=launcher)
    lk.release_licence_qxdm_5g()
    lk.release_licence_qcat_5g()
    lk.logout()
    lk.teardown()


def initialize_attenuator():
    yaml_file = _builtin.get_variable_value("${ABSTRACT_LIB_CONFIG}")
    _attenuator.load_attenuation_config(yaml_file)
    cells = list(_attenuator.cells_pool.cells_registry.keys())
    _attenuator.require_attenuator_setup_of(cells)
    _attenuator.set_attenuation_for_all_cells('90dB')
    sleep(2)


def set_minimal_attenuation(cell_alias):
    _attenuator.set_attenuation(cell_alias, CONFIG[cell_alias]['min_att'])


def release_attenuator():
    _attenuator.set_attenuation_for_all_cells('90dB')
    _attenuator.release_attenuator_cell(list(_attenuator.cells_pool.cells_registry.keys()))


def collect_bts_snapshot():
    with Admin5G() as admin_api:
        admin_api.get_snapshot(target_file_name='{}/{}_snapshot.zip'.format(
            _builtin.get_variable_value('${LOG_PATH}'), _builtin.get_variable_value('${test_name}')
        ))


def check_attach_sctp_msgs(path_to_pcap, lua=current_lua):
    attach_messages = get_attach_sctp_msgs(path_to_pcap, lua)
    assert attach_messages.get('SgNBAdditionRequest', False)
    assert attach_messages.get('SgNBAdditionRequestAcknowledge', False)
    assert attach_messages.get('SgNBReconfigurationComplete', False)
    assert attach_messages.get('SNStatusTransfer', False)


def get_attach_sctp_msgs(pcap, lua=current_lua):
    with LogHelper() as lh:
        finder = lh.add_pcap(
            pcap_file_path=pcap, lua=lua, shark_filter='',
            ts_output_data_file_path=None, clean_up_tmp_file=False
        )
        messages = finder.find_all([
            PM('SgNBAdditionRequest', name_line_pattern='empty'),
            PM('SgNBAdditionRequestAcknowledge', name_line_pattern='empty'),
            PM('SgNBReconfigurationComplete', name_line_pattern='empty'),
            PM('SNStatusTransfer', name_line_pattern='empty'),
        ], forget_matcher_on_hit=True)
    blog('found messages:')
    if messages:
        for msg in messages:
            blog(msg)
    return messages


def change_modulation(modulation_type, cell_alias):
    if modulation_type == '64QAM':
        change_256_qam('false', cell_alias)
    elif modulation_type == '256QAM':
        change_256_qam('true', cell_alias)
    else:
        raise
    blog("Modulation changed to {}".format(modulation_type))


def change_256_qam(value, cell_alias):
    dist_name = 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-{cell_id}'.format(
        mrbts_id=gnb_id,
        nrbts_id=gnb_id,
        cell_id=CONFIG[cell_alias]['CELL_ID'])
    parameters = [{'parameterName': 'actDl256Qam', 'operation': 'update', 'value': value}]
    with Admin5G() as admin_api:
        admin_api.perform_object_recommissioning(dist_name=dist_name,
                                                 parameter=parameters,
                                                 operation='update',
                                                 skip_parameter_relation_errors=False,
                                                 timeout=600)
    sleep(60)


def change_nrarfcn(level, cell_alias):
    if level.lower() == 'high':
        change_to_higher_nrarfcn(cell_alias)
    elif level.lower() == 'low':
        change_to_lower_nrarfcn(cell_alias)


def change_to_lower_nrarfcn(cell_alias):
    change_carrier_freq_nr_cell_on_lte(carrier_frequency=CONFIG[cell_alias]['NRARFCN']['lower']['LTE'])
    change_nrarfcn_value(nrarfcn_value=CONFIG[cell_alias]['NRARFCN']['lower']['5G'], cell_alias=cell_alias)


def change_to_middle_nrarfcn(cell_alias):
    change_carrier_freq_nr_cell_on_lte(carrier_frequency=CONFIG[cell_alias]['NRARFCN']['middle']['LTE'])
    change_nrarfcn_value(nrarfcn_value=CONFIG[cell_alias]['NRARFCN']['middle']['5G'], cell_alias=cell_alias)


def change_to_higher_nrarfcn(cell_alias):
    change_carrier_freq_nr_cell_on_lte(carrier_frequency=CONFIG[cell_alias]['NRARFCN']['higher']['LTE'])
    change_nrarfcn_value(nrarfcn_value=CONFIG[cell_alias]['NRARFCN']['higher']['5G'], cell_alias=cell_alias)


@logged_keyword
def change_nrarfcn_value(nrarfcn_value, cell_alias):
    dist_name = 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-{cell_id}'.format(
        mrbts_id=gnb_id,
        nrbts_id=gnb_id,
        cell_id=CONFIG[cell_alias]['CELL_ID'])
    with Admin5G() as admin_api:
        admin_api.perform_parameter_recommissioning(dist_name=dist_name,
                                                    parameter='nrarfcn',
                                                    value=nrarfcn_value,
                                                    operation='update',
                                                    skip_parameter_relation_errors=False,
                                                    timeout=600)
    blog("nrarfcn on gNB set to {}".format(nrarfcn_value), console=True)
    sleep(60)


@logged_keyword
def change_carrier_freq_nr_cell_on_lte(carrier_frequency):
    dist_name = 'MRBTS-{enb_id}/LNBTS-{enb_id}/NRDCDPR-0/ENDCDMEASCONF-0'.format(enb_id=enb_id)
    with AdminLTE() as admin_api:
        admin_api.perform_parameter_recommissioning(dist_name=dist_name,
                                                    parameter='carrierFreqNrCell',
                                                    value=carrier_frequency, operation='update',
                                                    skip_parameter_relation_errors=False,
                                                    timeout=600)
    blog("carrierFreqNrCell on eNB set to {}".format(carrier_frequency), console=True)


def get_mcs_average_for_attenuation_levels(cell_alias, modulation_type):
    ul_value = CONFIG[cell_alias][modulation_type]['UL']
    dl_value = CONFIG[cell_alias][modulation_type]['DL']
    attenuation_levels = CONFIG[cell_alias]['att_levels']
    blog("Starting data transfer...", console=True)
    _taf_ue.start_data_transfer(dt_name="DT_DL", ue_alias="UE_1",
                                direction="dl", throughput=dl_value, protocol="udp", packet=1400,  port="5020")
    _taf_ue.start_data_transfer(dt_name="DT_UL", ue_alias="UE_1",
                                direction="ul", throughput=ul_value, protocol="udp", packet=1400,  port="5022")
    sleep(15)
    mcs = []
    for att in attenuation_levels:
        mcs.append(get_avg_mcs_for_given_attenuation(cell_alias, att))
    blog("Stopping data transfer...", console=True)
    _taf_ue.stop_data_transfer("DT_DL")
    _taf_ue.stop_data_transfer("DT_UL")
    assert _compare_mcs_values(mcs[1], mcs[0]), "{} < {} is not satisfied".format(mcs[1], mcs[0])
    assert _compare_mcs_values(mcs[1], mcs[2]), "{} < {} is not satisfied".format(mcs[1], mcs[2])
    assert _compare_mcs_values(mcs[2], mcs[0]), "{} < {} is not satisfied".format(mcs[2], mcs[0])


def _compare_mcs_values(first_tuple, second_tuple):
    return first_tuple[0] < second_tuple[0] and first_tuple[1] < second_tuple[1]


def get_mcs_average_for_max_tput(cell_alias, modulation_type, deviation):
    ul_value = CONFIG[cell_alias][modulation_type]['UL']
    dl_value = CONFIG[cell_alias][modulation_type]['DL']
    attenuation = CONFIG[cell_alias]['min_att']
    _attenuator.set_attenuation(cell_alias, attenuation)
    blog("Starting data transfer...", console=True)
    _taf_ue.start_data_transfer(dt_name="DT_DL", ue_alias="UE_1",
                                direction="dl", throughput=dl_value, protocol="udp", packet=1400,  port="5020")
    _taf_ue.start_data_transfer(dt_name="DT_UL", ue_alias="UE_1",
                                direction="ul", throughput=ul_value, protocol="udp", packet=1400,  port="5022")
    sleep(15)
    mcs_average = get_avg_mcs_for_given_attenuation(cell_alias, attenuation)
    _taf_ue.verify_average_throughput(dt_name="DT_DL", tput_min="0Mbits/sec", tput_max="700Mbits/sec", omit=15)
    _taf_ue.verify_average_throughput(dt_name="DT_UL", tput_min="0Mbits/sec", tput_max="700Mbits/sec", omit=15)
    blog("Stopping data transfer...", console=True)
    _taf_ue.stop_data_transfer("DT_DL")
    _taf_ue.stop_data_transfer("DT_UL")
    return mcs_average


@logged_keyword
def get_avg_mcs_for_given_attenuation(cell_alias, attenuation):
    _attenuator.set_attenuation(cell_alias, attenuation)
    filename = "{}_{}_{}".format(cell_alias, _builtin.get_variable_value("${QAM}"), attenuation)
    qcat_file = start_qxdm_logging(10, filename)
    average_mcs = get_mcs_from_qcat_file(qcat_file)
    blog("UL MCS average for {}: {}".format(attenuation, average_mcs[0]))
    blog("DL MCS average for {}: {}".format(attenuation, average_mcs[1]))
    return average_mcs


@logged_keyword
def start_qxdm_logging(duration, filename):
    local_path = _builtin.get_variable_value("${OUTPUT_DIR}") + "/"
    file_path = "".join((uepc_logs_path, filename, ".hdf"))
    qxdm_location = "C:/Users/wro5grrm.NOKLAB/Desktop/QxdmCommand.py"
    qxdm_cmd = "{} -t {} -p {} -c {} -s {}".format(qxdm_location,
                                                   int(duration),
                                                   int(ue.com_port)+1,
                                                   "C:/Users/wro5grrm.NOKLAB/Desktop/Perf_capa_QXDM_conf.dmc",
                                                   file_path)
    qcat_cmd = "\"{}\" -txt {}".format("C:/Program Files (x86)/Qualcomm/QCAT 6.x/Bin/QCAT.exe", file_path)
    _ssh.connect_to(hostname=ue.ue_pc_address,
                    username=ue.ue_pc_login,
                    password=ue.ue_pc_password)
    _ssh.send_command(command="python {}".format(qxdm_cmd))
    _ssh.read_output()
    _ssh.assert_file_exists(file_path)
    _ssh.send_command(command=qcat_cmd)
    _ssh.read_output()
    txt_path = "".join((uepc_logs_path, filename, ".txt"))
    _ssh.assert_file_exists(txt_path)
    _ssh.download_file(remote_path=txt_path, local_path="".join((local_path, filename, ".txt")))
    _ssh.read_output()
    assert os.path.exists("".join((local_path, filename, ".txt")))
    return "".join((local_path, filename, ".txt"))


@logged_keyword
def get_mcs_from_qcat_file(qcat_file_path):
    mcs_ul_lst = []
    mcs_dl_lst = []
    avg_mcs = []
    blog("Calculating avgMcs for file: {}".format(qcat_file_path), console=False)
    with open(ensure_str(qcat_file_path), 'r', encoding='utf-8', errors='replace') as txt_file:
        txt = txt_file.read()
        mcs_ul_line = re.findall(r".*NR5GMAC.*UL since last.*MCS: \d*", txt)
        mcs_dl_line = re.findall(r".*NR5GMAC.*DL since last.*MCS: \d*", txt)
        for line in mcs_ul_line:
            mcs = re.search(r"MCS: (\d*)", line)
            mcs_ul_lst.append(int(mcs.group(1)))
        for line in mcs_dl_line:
            mcs = re.search(r"MCS: (\d*)", line)
            mcs_dl_lst.append(int(mcs.group(1)))
    avg_mcs.append(sum(mcs_ul_lst) / float(len(mcs_ul_lst)))
    avg_mcs.append(sum(mcs_dl_lst) / float(len(mcs_dl_lst)))
    blog("avgMCS for UL : {0} \navg MCS for DL: {1}".format(avg_mcs[0], avg_mcs[1]), console=False)
    return avg_mcs


@wait_until_function_succeeds(timeout=420, interval=10)
def verify_x2_link():
    with Admin5G() as admin_api:
        cells = admin_api.get_cells_info(cell_type='nr')
        assert len(cells), 'Cells not detected'
        for cell in cells:
            assert cell['status'].get('availabilityStatus') in ['Online', None, 'Degraded', 'degraded'], \
                blog('Not all cells are online\n', cell, console=False)


def delete_files_on_uepc():
    _ssh.connect_to(hostname=ue.ue_pc_address, username=ue.ue_pc_login, password=ue.ue_pc_password)
    _ssh.send_command(command='rm -f -v {}/*'.format(uepc_logs_path))
    _ssh.read_output()
    _ssh.disconnect()


def adb_reboot_ue():
    _ssh.connect_to(hostname=ue.ue_pc_address, username=ue.ue_pc_login, password=ue.ue_pc_password)
    _ssh.send_command(command='adb reboot')
    _ssh.disconnect()
    sleep(50)
