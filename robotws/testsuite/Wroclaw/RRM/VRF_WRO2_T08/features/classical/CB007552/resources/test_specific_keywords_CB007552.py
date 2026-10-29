import os
from time import sleep

from robot.libraries.BuiltIn import BuiltIn
from robot.libraries.OperatingSystem import OperatingSystem
from ta_attenuator import ta_attenuator
from taf.transport.ssh import ssh
from taf.ue import ue
from ute_tshark.interface import ute_tshark

import test_variables_CB007552 as msgs
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.log_helper import LogHelper
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.matchers import PcapMessageMatcher as PM
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.admin import Admin5G
from testsuite.Wroclaw.RRM.VRF_WRO2_T08.resources.utility.cleaners import clear_admin_api_logs
from testsuite.Wroclaw.RRM.resources.log.log import blog

_attenuator = ta_attenuator()
_os = OperatingSystem()
_builtin = BuiltIn()
_ute_tshark = ute_tshark()
_ute_ue = ue()
_ssh = ssh()

tl = _builtin.get_variable_value("${tl}")
ue1 = tl.ues[1]
ssh_details = ue1.ssh_connection_details

CONFIGS = {
    "gNB50830": {
        "VM_IP": "10.44.178.46",
    },
    "gNB50829": {
        "VM_IP": "10.44.178.12",
    },
}

ues_info = {
    "UE_1": {"name": "MTK_NEW", "adb_id": "MTK_NEW"},
    "UE_2": {"name": "MTK_OLD", "adb_id": "MTK_OLD"},
    "UE_3": {"name": "NOKIA_1", "adb_id": "HZQN1876AAKA2000244"},
    "UE_4": {"name": "NOKIA_2", "adb_id": "HZQN1876BAKC2300370"}
}


def install_taf_syslog_on_remote():
    _ssh.connect_to(hostname=CONFIGS[list(CONFIGS)[1]]['VM_IP'], username='ute', password='ute')
    _ssh.send_command('pip install --upgrade pip', get_pty=True)
    _ssh.send_command('pip install taf.sw.syslog -U', get_pty=True)


def initialize_attenuator():
    yaml_file = _builtin.get_variable_value("${ABSTRACT_LIB_CONFIG}")
    _attenuator.load_attenuation_config(yaml_file)
    cells = list(_attenuator.cells_pool.cells_registry.keys())
    _attenuator.require_attenuator_setup_of(cells)
    _attenuator.set_attenuation_for_all_cells('90dB')
    sleep(2)


def release_attenuator():
    _attenuator.set_attenuation_for_all_cells('90dB')
    _attenuator.release_attenuator_cell(list(_attenuator.cells_pool.cells_registry.keys()))


def detach_ues_and_set_maximal_attenuation(*ues_in_test):
    for ue in ues_in_test:
        if ue == "None":
            continue
        blog("Detaching UE: {}".format(ue))
        try:
            _ute_ue.detach_ue(ue)
            sleep(5)
        except Exception as e:
            blog("Cannot detach due to {} - omitting procedure...".format(e))
    _attenuator.set_attenuation_for_all_cells('90dB')


def prepare_all_ues(*ues_in_test):
    for ue in ues_in_test:
        if ue == "None":
            continue
        _ute_ue.require_ue(ue, capabilities=ues_info.get(ue).get("name"))


def attach(ue, cell_alias, attenuation):
    _attenuator.set_attenuation(cell_alias=cell_alias, attenuation_value=attenuation)
    sleep(10)
    _ute_ue.attach_ue(ue)
    blog("{} attached!".format(ue))
    sleep(10)


def set_attenuation_for_cell(cell_alias, attenuation):
    _attenuator.set_attenuation(cell_alias=cell_alias, attenuation_value=attenuation)


def check_if_specific_testcase(specific_name):
    is_specific = False
    if isinstance(specific_name, list):
        if specific_name[0] in _builtin.get_variable_value('${TESTNAME}') or specific_name[1] in _builtin. \
                get_variable_value('${TESTNAME}'):
            is_specific = True
    else:
        if specific_name in _builtin.get_variable_value('${TESTNAME}'):
            is_specific = True
    return is_specific


def prepare_smod_logging():
    smod_ssh_conn = _builtin.get_variable_value('${tl.gnbs[0].cu.oam_ssh_connection_details}')
    _ssh.connect_to(hostname=smod_ssh_conn.addr, username=smod_ssh_conn.username, password=smod_ssh_conn.password)
    _ssh.send_command('cat /ffs/run/cp_runtime.ini')
    logging_level = _ssh.read_output()
    if "LoggingSeverity=trace" in logging_level:
        blog("Logging Level already set to Trace in cp_runtime")
        return True
    blog("Setting Logging Level in cp_runtime.ini file")
    _ssh.send_command('echo -e "[control]\nLoggingSeverity=trace" > /ffs/run/cp_runtime.ini')
    with Admin5G() as admin:
        admin.reset_site()


def clear_admin_logs():
    clear_admin_api_logs()


def get_test_gnbs():
    is_inter_gnb = check_if_specific_testcase('Inter-gNB_handover')
    if is_inter_gnb:
        gnbs = _builtin.get_variable_value('${MULTI_NODE}')
    else:
        gnbs = _builtin.get_variable_value('${ONE_NODE}')
    used_gnbs = _enb_gnb_selection(CONFIGS, gnbs)
    return used_gnbs


def _enb_gnb_selection(dictionary, list_of_used_ids):
    if not isinstance(list_of_used_ids, list):
        list_of_used_ids = list(list_of_used_ids)
    used_bts = {bts: bts_info for bts, bts_info in dictionary.items() if bts in list_of_used_ids}
    return used_bts


def collect_scf_before_test():
    blog("Collecting backup SCF...")
    with Admin5G() as admin_api:
        admin_api.get_current_scf_file(_builtin.get_variable_value('${scf_path}'), 'backup_scf.xml')


def perform_scf_commissioning(scf_type):
    with Admin5G() as admin_api:
        branch = admin_api.get_sw_release_name()[-4:]
        scf_5g_file = _find_scf_file(branch, scf_type)
        blog("Performing gnb commissioning with file {}...".format(scf_5g_file))
        admin_api.perform_commissioning(scf_file=scf_5g_file, timeout=300)


def _find_scf_file(branch, scf_type):
    path_to_custom_config = _builtin.get_variable_value("${TL_CONFIG}")
    path_to_scf = '{}/{}'.format(path_to_custom_config, branch if branch != '24R3' else 'trunk')
    if scf_type.lower() == 'ca':
        scf_5g = [filename for filename in os.listdir(path_to_scf) if "CA" in filename]
    else:
        scf_5g = [filename for filename in os.listdir(path_to_scf) if "5g" in filename and "CA" not in filename]
    assert len(scf_5g) == 1, 'Error, found more than one SCF file'
    return '{}/{}'.format(path_to_scf, scf_5g[0])


def wait_for_cells_on_air():
    with Admin5G() as admin_api:
        cells = admin_api.get_cells_info(cell_type='nr')
        assert len(cells), "NR cells not detected"
        for cell in cells:
            assert cell['status'].get('operationalState').lower() == 'enabled', 'Not all cells are on air'


def reboot_ues_by_testcase(*ues_in_test):
    _ssh.connect_to(hostname=ssh_details.addr,
                    username=ssh_details.username,
                    password=ssh_details.password)
    for ue in ues_in_test:
        if ue == "None":
            continue
        _ssh.send_command(command='adb -s {} reboot'.format(ues_info.get(ue).get("adb_id")))
    sleep(90)


def verify_downlink_throughput_for_ca_check(dt_name, tput, cell, att, tput_min):
    blog("Start Data Transfer for CA")
    _attenuator.set_attenuation(cell, att)
    _ute_ue.start_data_transfer(dt_name=dt_name, ue_alias='UE_1', direction='dl',
                                duration='30s', throughput=tput, packet_size='1400')
    sleep(5)
    blog("Waiting For Data Transfer to be finished")
    _ute_ue.await_data_transfer_finish(dt_name=dt_name)
    blog("Verifying Avg tput for {}".format("UE_1"))
    _ute_ue.stop_data_transfer(dt_name=dt_name)
    sleep(10)
    _ute_ue.verify_average_throughput(dt_name=dt_name, tput_min=tput_min, omit='10')


@logged_keyword
def verify_scell_aggregation(mode):
    ca_filters = msgs.ca_filters[mode]
    filepath = "{}/{}_SCTP.pcap".format(_builtin.get_variable_value('${LOG_PATH}'),
                                        _builtin.get_variable_value('${TESTNAME}')) \
        if mode != "CNI" else "{}/{}_SCTP_CA.pcap".format(_builtin.get_variable_value('${LOG_PATH}'),
                                                          _builtin.get_variable_value('${TESTNAME}'))
    tshark_alias = 'ca_{}_pcap'.format(mode.lower())
    _ute_tshark.setup_tshark(interface='eno2', alias=tshark_alias)
    ca_aggr_1 = _ute_tshark.get_packets_count(packet_filter='{}'.format(ca_filters[0]),
                                              pcap_file_path=filepath,
                                              alias=tshark_alias)
    if mode.lower() == 'nsa':
        ca_aggr_2 = _ute_tshark.get_packets_count(packet_filter=ca_filters[1],
                                                  pcap_file_path=filepath,
                                                  alias=tshark_alias)
        assert ca_aggr_1 >= 1 and ca_aggr_2 >= 1, 'Wrong number of packets in {} - found {} and {}, ' \
                                                  'should be >= 1 for both'.format(filepath, ca_aggr_1, ca_aggr_2)
    elif mode.lower() == 'sa' or mode.lower() == 'cni':
        assert ca_aggr_1 >= 1, 'Wrong number of packets in {} - found {}, should be >= 1'.format(filepath, ca_aggr_1)


@logged_keyword
def perform_handover(ue_alias, cell_from, cell_to, tput_dl, tput_ul, tput_min_dl, tput_min_ul):
    _ute_ue.start_data_transfer(dt_name='dt_dl', ue_alias=ue_alias, direction='dl',
                                duration='60s', throughput=tput_dl, packet_size='1400')
    _ute_ue.start_data_transfer(dt_name='dt_ul', ue_alias=ue_alias, direction='ul',
                                duration='60s', throughput=tput_ul, packet_size='1400')
    sleep(20)
    _trigger_handover(cell_from, cell_to)
    _ute_ue.await_data_transfer_finish(dt_name='dt_dl')
    _ute_ue.await_data_transfer_finish(dt_name='dt_ul')
    blog("Verifying Avg tput for {}".format(ue_alias))
    blog(_ute_ue.get_average_throughput(dt_name='dt_dl', omit='10'))
    blog(_ute_ue.get_average_throughput(dt_name='dt_ul', omit='10'))
    _ute_ue.verify_average_throughput(dt_name='dt_dl', tput_min=tput_min_dl, omit='10')
    _ute_ue.verify_average_throughput(dt_name='dt_ul', tput_min=tput_min_ul, omit='10')


def _trigger_handover(cell_from, cell_to):
    _attenuator.set_attenuation(cell_to, '0dB')
    for i in range(0, 90, 2):
        _attenuator.set_attenuation(cell_from, '{}dB'.format(i))
        sleep(1)


@logged_keyword
def check_if_syslog_contains_messages(msg_type):
    msgs_to_apply = msgs.all_messages[msg_type]
    if isinstance(msgs_to_apply, list):
        for message in msgs_to_apply:
            status = _os.run('sudo cat {}/syslog_{}.log | grep -E "{}"'.format(
                _builtin.get_variable_value('${syslog_path}'), _builtin.get_variable_value("${ONE_NODE}")[0],
                message))
            assert status, "Syslog lacking message: {}".format(message)
    elif isinstance(msgs_to_apply, dict):
        for message in msgs_to_apply["source"]:
            status = _os.run('sudo cat {}/syslog_{}.log | grep -E "{}"'.format(
                _builtin.get_variable_value('${syslog_path}'), _builtin.get_variable_value("${MULTI_NODE}")[0],
                message))
            assert status, "Syslog lacking message: {}".format(message)
        for message in msgs_to_apply["target"]:
            status = _os.run('sudo cat {}/syslog_{}.log | grep -E "{}"'.format(
                _builtin.get_variable_value('${syslog_path}'), _builtin.get_variable_value("${MULTI_NODE}")[1],
                message))
            assert status, "Syslog lacking message: {}".format(message)


@logged_keyword
def verify_handover():
    filters_dict = msgs.inter_du_HO_filters
    pcap_alias = 'interHO_pcap'
    source_filepath = "{}/{}_SCTP.pcap".format(_builtin.get_variable_value('${LOG_PATH}'),
                                               _builtin.get_variable_value('${TESTNAME}'))
    target_filepath = '{}/{}_target_SCTP.pcap'.format(_builtin.get_variable_value('${LOG_PATH}'),
                                                      _builtin.get_variable_value('${TESTNAME}'))
    _ute_tshark.setup_tshark(interface='eno2', alias=pcap_alias)
    for element in filters_dict["source"]:
        packets = _ute_tshark.get_packets_count(packet_filter=element,
                                                pcap_file_path=source_filepath,
                                                alias=pcap_alias)
        assert packets == 1, '{} packets for filter: {} in {} - should be 1'.format(packets, element, source_filepath)
    for element in filters_dict["target"]:
        packets = _ute_tshark.get_packets_count(packet_filter=element,
                                                pcap_file_path=target_filepath,
                                                alias=pcap_alias)
        assert packets == 1, '{} packets for filter: {} in {} - should be 1'.format(packets, element, target_filepath)
    _ute_tshark.teardown_tshark(alias='interHO_pcap')


@logged_keyword
def start_data_transfer_in_both_directions(ue_alias, tput_dl, tput_ul, tput_min_dl, tput_min_ul):
    _ute_ue.start_data_transfer(dt_name='dt_dl', ue_alias=ue_alias, direction='dl',
                                duration='60s', throughput=tput_dl, packet_size='1400')
    _ute_ue.start_data_transfer(dt_name='dt_ul', ue_alias=ue_alias, direction='ul',
                                duration='60s', throughput=tput_ul, packet_size='1400')
    sleep(20)
    _ute_ue.await_data_transfer_finish(dt_name='dt_dl')
    _ute_ue.await_data_transfer_finish(dt_name='dt_ul')
    blog("Veryfying tput for {}".format(ue_alias))
    blog(_ute_ue.get_average_throughput(dt_name='dt_dl', omit='10'))
    blog(_ute_ue.get_average_throughput(dt_name='dt_ul', omit='10'))
    _ute_ue.verify_average_throughput(dt_name='dt_dl', tput_min=tput_min_dl, omit='10')
    _ute_ue.verify_average_throughput(dt_name='dt_ul', tput_min=tput_min_ul, omit='10')


def start_throughput_for_multi_ue_attach_check(bwp_type, tput_duration):
    bwp_type_dict = msgs.bwp_tput_params[bwp_type]
    for ue in bwp_type_dict.keys():
        _ute_ue.start_data_transfer(dt_name='{}_DL'.format(ue), ue_alias=ue, direction='dl', duration=tput_duration,
                                    throughput=bwp_type_dict[ue]['tput_dl'], packet_size='1400')
        _ute_ue.start_data_transfer(dt_name='{}_UL'.format(ue), ue_alias=ue, direction='ul', duration=tput_duration,
                                    throughput=bwp_type_dict[ue]['tput_ul'], packet_size='1400')
    sleep(10)


def verify_throughput_for_multi_ue_attach_check(bwp_type):
    bwp_type_dict = msgs.bwp_tput_params[bwp_type]
    for ue in bwp_type_dict.keys():
        _ute_ue.stop_data_transfer(dt_name='{}_DL'.format(ue))
        _ute_ue.stop_data_transfer(dt_name='{}_UL'.format(ue))
        blog("Veryfying tput for {}".format(ue))
        blog(_ute_ue.get_average_throughput(dt_name='{}_DL'.format(ue), omit='10', end='100'))
        blog(_ute_ue.get_average_throughput(dt_name='{}_UL'.format(ue), omit='10', end='100'))
        _ute_ue.verify_average_throughput(dt_name='{}_DL'.format(ue), tput_min=bwp_type_dict[ue]['min_tput_dl'],
                                          omit='10')
        _ute_ue.verify_average_throughput(dt_name='{}_UL'.format(ue), tput_min=bwp_type_dict[ue]['min_tput_ul'],
                                          omit='10')


def verify_multi_ue_attach_in_pcap(*args):
    _ute_tshark.setup_tshark(interface='any', alias='multi_ue_pcap')
    for arg in args:
        value = _ute_tshark.get_packets_count(packet_filter=arg,
                                              pcap_file_path="{}/{}_SCTP.pcap"
                                              .format(_builtin.get_variable_value('${LOG_PATH}'),
                                                      _builtin.get_variable_value('${TESTNAME}')),
                                              alias='multi_ue_pcap')
        assert value == 1, "{} packets for filter: {} - should be 1".format(value, arg)
    _ute_tshark.teardown_tshark(alias='multi_ue_pcap')


@logged_keyword
def verify_prb_allocation(mode, bwp_mode=None):
    filename = '{}/{}_SCTP.pcap'.format(_builtin.get_variable_value('${LOG_PATH}'),
                                        _builtin.get_variable_value('${TESTNAME}'))
    l1l2_filename = '{}/{}_bip.pcap'.format(_builtin.get_variable_value('${LOG_PATH}'),
                                            _builtin.get_variable_value('${TESTNAME}'))
    if mode.lower() == 'sa':
        variables = msgs.rnti_info[mode]
        high_rnti = get_n_rntis_for_bandwith(variables['n'], filename, variables['high_rnti']['bandwidth'])
        low_rnti = get_n_rntis_for_bandwith(variables['n'], filename, variables['low_rnti']['bandwidth'])
        _assert_all_prb_fine_for_both_rnti(l1l2_filename, high_rnti[0], low_rnti[0],
                                           variables['dl_thresholds'], variables['ul_thresholds'])
    elif mode.lower() == 'nsa':
        variables = msgs.rnti_info[mode][bwp_mode]
        high_rnti = get_n_rntis_for_bandwith(variables['n'], filename, variables['high_rnti']['bandwidth'],
                                             variables['high_rnti']['carrier_bandwidth'])
        if bwp_mode.lower() != 'small-small':
            low_rnti = get_n_rntis_for_bandwith(variables['n'], filename, variables['low_rnti']['bandwidth'],
                                                variables['low_rnti']['carrier_bandwidth'])
            _assert_all_prb_fine_for_both_rnti(l1l2_filename, high_rnti[0], low_rnti[0],
                                               variables['dl_thresholds'], variables['ul_thresholds'])
        elif bwp_mode.lower() == 'small-small':
            _assert_all_prb_fine_for_both_rnti(l1l2_filename, high_rnti[0], high_rnti[1],
                                               variables['dl_thresholds'], variables['ul_thresholds'])


def get_n_rntis_for_bandwith(n, sctp_pcap_path, bandwidth, carrier_bandwidth=None):
    rnti_list = _get_rnti_list_for_bandwidth(sctp_pcap_path, bandwidth, carrier_bandwidth)
    assert len(rnti_list) == n, "Found {} rnti's, expected: {}".format(len(rnti_list), n)
    return rnti_list


def _get_rnti_list_for_bandwidth(sctp_pcap_path, bandwidth, carrier_bandwidth=None):
    if carrier_bandwidth is None:
        shark_filter = 'f1ap.procedureCode == 5 and nr-rrc.locationAndBandwidth == {}'.format(bandwidth)
    else:
        shark_filter = 'f1ap.procedureCode == 5 and nr-rrc.locationAndBandwidth == {} ' \
                       'and nr-rrc.carrierBandwidth == {}'.format(bandwidth, carrier_bandwidth)
    with LogHelper() as lh:
        finder = lh.add_pcap(
            pcap_file_path=sctp_pcap_path, lua=None, tshark_filter=shark_filter, clean_up_tmp_file=False)
    messages = finder.find_all([PM('UEContextSetupResponse', message_type_pattern='empty')])
    rnti_list = []
    for msg in messages['UEContextSetupResponse']:
        rnti_list.append(_get_rnti_from_uecontextsetupresponse(msg))
    return rnti_list


def _get_rnti_from_uecontextsetupresponse(msg):
    return msg.find('C-RNTI*')[0]['val']


def _assert_all_prb_fine_for_both_rnti(pcap_path, high_rnti, low_rnti, dl_thresholds=None, ul_thresholds=None):
    with LogHelper() as lh:
        finder = lh.add_pcap(
            pcap_file_path=pcap_path, lua=None, tshark_filter='dldata_pdschsendreq||uldata_puschreceivereq',
            clean_up_tmp_file=False
        )
    messages = finder.find_all([PM('dldata_pdschsendreq', message_type_pattern='empty'),
                                PM('uldata_puschreceivereq', message_type_pattern='empty')])
    _assert_all_prb_fine_for_both_rnti_in_downlink(messages['dldata_pdschsendreq'], high_rnti, low_rnti, dl_thresholds)
    _assert_all_prb_fine_for_both_rnti_in_uplink(messages['uldata_puschreceivereq'], high_rnti, low_rnti, ul_thresholds)


def _assert_all_prb_fine_for_both_rnti_in_downlink(messages, high_rnti, low_rnti, thresholds=None):
    if thresholds is None:
        thresholds = {'low': {'low_bound': 75, 'high_bound': 90, 'min_ratio': 0.9},
                      'high': {'low_bound': 75, 'high_bound': 90, 'min_ratio': 0.9}}
    data = {}
    for msg in messages:
        rnti, prb = _get_data_from_pdsch_send_req(msg)
        if not data.get(rnti, None):
            data[rnti] = []
            data[rnti].append(prb)
        else:
            data[rnti].append(prb)
    blog("Verifying downlink PRBs...")
    assert data.get(high_rnti, None), "Didn't found high profile rnti ({}) in BIP log".format(high_rnti)
    assert data.get(low_rnti, None), "Didn't found low profile rnti ({}) in BIP log".format(low_rnti)
    _assert_all_prbs_not_lower_than_threshold(data[high_rnti], thresholds['high']['low_bound'], True)
    _assert_all_prbs_not_lower_than_threshold(data[low_rnti], thresholds['low']['low_bound'], False)
    _assert_ratio_of_prbs_not_lower_than_threshold(data[high_rnti], thresholds['high']['high_bound'],
                                                   thresholds['high']['min_ratio'], True)
    _assert_ratio_of_prbs_not_lower_than_threshold(data[low_rnti], thresholds['low']['high_bound'],
                                                   thresholds['low']['min_ratio'], False)
    blog("Downlink PRBs are OK")


def _assert_all_prb_fine_for_both_rnti_in_uplink(messages, high_rnti, low_rnti, thresholds=None):
    if thresholds is None:
        thresholds = {'low': {'low_bound': 80, 'high_bound': 84, 'min_ratio': 0.9},
                      'high': {'low_bound': 80, 'high_bound': 84, 'min_ratio': 0.9}}
    data = {}
    for msg in messages:
        rntis, prbs = _get_data_from_pusch_receive_req(msg)
        assert len(rntis) == len(prbs), "Fatal Error: different number of rnti's and prb's"
        for rnti, prb in zip(rntis, prbs):
            if not data.get(rnti, None):
                data[rnti] = []
                data[rnti].append(prb)
            else:
                data[rnti].append(prb)
    blog("Verifying uplink PRBs...")
    assert data.get(high_rnti, None), "Didn't found high profile rnti ({}) in BIP log".format(high_rnti)
    assert data.get(low_rnti, None), "Didn't found low profile rnti ({}) in BIP log".format(low_rnti)
    _assert_all_prbs_not_lower_than_threshold(data[high_rnti], thresholds['high']['low_bound'], True)
    _assert_all_prbs_not_lower_than_threshold(data[low_rnti], thresholds['low']['low_bound'], False)
    _assert_ratio_of_prbs_not_lower_than_threshold(data[high_rnti], thresholds['high']['high_bound'],
                                                   thresholds['high']['min_ratio'], True)
    _assert_ratio_of_prbs_not_lower_than_threshold(data[low_rnti], thresholds['low']['high_bound'],
                                                   thresholds['low']['min_ratio'], False)
    blog("Uplink PRBs are OK")


def _assert_all_prbs_not_lower_than_threshold(rb_list, threshold, is_high):
    failed_rbs = []
    for rb in rb_list:
        if rb < threshold:
            failed_rbs.append(rb)
    assert not len(failed_rbs), "{} RNTI: Found PRB with value lower than {}" \
                                " ::::: {}".format("HIGH" if is_high else "LOW", threshold, failed_rbs)


def _assert_ratio_of_prbs_not_lower_than_threshold(rb_list, threshold, ratio, is_high):
    failed_rbs = []
    for rb in rb_list:
        if rb < threshold:
            failed_rbs.append(rb)
    failed_ratio = (len(failed_rbs) / float(len(rb_list))) * 100
    allowed_fails_ratio = (1 - ratio) * 100
    assert failed_ratio <= allowed_fails_ratio, \
        "{} RNTI: Ratio of PRBs lower than {} is equal to {}% which is higher than allowed ratio ({}%)" \
        "".format("HIGH" if is_high else "LOW", threshold, failed_ratio, allowed_fails_ratio)


def _get_data_from_pdsch_send_req(msg):
    rb = int(msg.find('numOfPrb*')[0]['val'])
    rnti = msg.find('rnti*')[0]['val']
    return rnti, rb


def _get_data_from_pusch_receive_req(msg):
    rbs = [int(rb['val']) for rb in msg.find('numOfPrb*')]
    rntis = [rnti['val'] for rnti in msg.find('rnti*')]
    return rntis, rbs


def deactivate_cni():
    activate_cni_for_proper_sw_release(deactivate=True)


@logged_keyword
def activate_cni_for_proper_sw_release(deactivate=False):
    cell_ids = ['0', '1']
    gnb_id = _builtin.get_variable_value('${tl.gnbs[0].global_bts_id}')
    with Admin5G() as admin_api:
        sw_release_name = admin_api.get_sw_release_name()
    if sw_release_name == 'SBTS22R1' or sw_release_name == 'SBTS22R2':
        _activate_cni(gnb_id, cell_ids, get_old_params_for_cni(deactivate=deactivate))
    else:
        if check_if_specific_testcase("CA"):
            _activate_cni(gnb_id, cell_ids, get_ca_params_for_cni(deactivate=deactivate))
        else:
            _activate_cni(gnb_id, cell_ids, get_new_params_for_cni(deactivate=deactivate))


def _activate_cni(gnb_id, cell_ids, parameters):
    if isinstance(parameters[0], list):
        for cell_id in cell_ids:
            with Admin5G() as admin_api:
                # admin_api.block_cell(dist_name='MRBTS-{}/NRBTS-{}/NRCELL-{}'.format(gnb_id, gnb_id, cell_id))
                admin_api.perform_object_recommissioning(dist_name='MRBTS-{}/NRBTS-{}/NRCELL-{}'.format(gnb_id, gnb_id,
                                                                                                        cell_id),
                                                         parameter=parameters[int(cell_id)],
                                                         operation='update',
                                                         skip_parameter_relation_errors=False)
                # admin_api.unblock_cell(dist_name='MRBTS-{}/NRBTS-{}/NRCELL-{}'.format(gnb_id, gnb_id, cell_id))
    else:
        for cell_id in cell_ids:
            with Admin5G() as admin_api:
                # admin_api.block_cell(dist_name='MRBTS-{}/NRBTS-{}/NRCELL-{}'.format(gnb_id, gnb_id, cell_id))
                admin_api.perform_object_recommissioning(dist_name='MRBTS-{}/NRBTS-{}/NRCELL-{}'.format(gnb_id, gnb_id,
                                                                                                        cell_id),
                                                         parameter=parameters,
                                                         operation='update',
                                                         skip_parameter_relation_errors=False)
                # admin_api.unblock_cell(dist_name='MRBTS-{}/NRBTS-{}/NRCELL-{}'.format(gnb_id, gnb_id, cell_id))


def get_old_params_for_cni(deactivate=False):
    parameters = [
        {"parameterName": "tmpActFeat1", "operation": "update", "value": "1024"},
    ]
    if deactivate:
        parameters = [
            {"parameterName": "tmpActFeat1", "operation": "delete"},
        ]
    return parameters


def get_new_params_for_cni(deactivate=False):
    parameters = [
        {"parameterName": "ueConnectionEstablishmentMode", "operation": "update", "value": "useInitialBwp"},
        {"parameterName": "cellBwpList", "operation": "update", "value":
            [{"bwpDN": "MRBTS-50830/NRBTS-50830/BWP_PROFILE-7", "cellBwpId": "0",
              "actPdcchCceFragmentControl": "false", "actUpperThrAckNackFiltering": "false",
              "actUpperThrAckNackHrFiltering": 'false', "pdcchResourcePreference": "peakRate"},
             {"bwpDN": "MRBTS-50830/NRBTS-50830/BWP_PROFILE-54", "cellBwpId": "1",
              "actPdcchCceFragmentControl": "false", "actUpperThrAckNackFiltering": "false",
              "actUpperThrAckNackHrFiltering": 'false', "pdcchResourcePreference": "peakRate"},
             {"bwpDN": "MRBTS-50830/NRBTS-50830/BWP_PROFILE-52", "cellBwpId": "2",
              "actPdcchCceFragmentControl": "false", "actUpperThrAckNackFiltering": "false",
              "actUpperThrAckNackHrFiltering": 'false', "pdcchResourcePreference": "peakRate"}]
         },
    ]
    if deactivate:
        parameters = [
            {"parameterName": "ueConnectionEstablishmentMode", "operation": "update", "value": "useDedicatedBwp"},
            {"parameterName": "cellBwpList", "operation": "update", "value":
                [{"bwpDN": "MRBTS-50830/NRBTS-50830/BWP_PROFILE-5", "cellBwpId": "0",
                  "actPdcchCceFragmentControl": "false", "actUpperThrAckNackFiltering": "false",
                  "actUpperThrAckNackHrFiltering": 'false', "pdcchResourcePreference": "peakRate"},
                 {"bwpDN": "MRBTS-50830/NRBTS-50830/BWP_PROFILE-54", "cellBwpId": "1",
                  "actPdcchCceFragmentControl": "false", "actUpperThrAckNackFiltering": "false",
                  "actUpperThrAckNackHrFiltering": 'false', "pdcchResourcePreference": "peakRate"},
                 {"bwpDN": "MRBTS-50830/NRBTS-50830/BWP_PROFILE-52", "cellBwpId": "2",
                  "actPdcchCceFragmentControl": "false", "actUpperThrAckNackFiltering": "false",
                  "actUpperThrAckNackHrFiltering": 'false', "pdcchResourcePreference": "peakRate"}]
             },
        ]
    return parameters


def get_ca_params_for_cni(deactivate=False):
    parameters = [
        [{"parameterName": "ueConnectionEstablishmentMode", "operation": "update", "value": "useInitialBwp"},
         {"parameterName": "cellBwpList", "operation": "update", "value":
             [{"bwpDN": "MRBTS-50830/NRBTS-50830/BWP_PROFILE-7", "cellBwpId": "0",
               "actPdcchCceFragmentControl": "false", "actUpperThrAckNackFiltering": "false",
               "actUpperThrAckNackHrFiltering": 'false', "pdcchResourcePreference": "peakRate"},
              {"bwpDN": "MRBTS-50830/NRBTS-50830/BWP_PROFILE-55", "cellBwpId": "1",
               "actPdcchCceFragmentControl": "false", "actUpperThrAckNackFiltering": "false",
               "actUpperThrAckNackHrFiltering": 'false', "pdcchResourcePreference": "peakRate"},
              {"bwpDN": "MRBTS-50830/NRBTS-50830/BWP_PROFILE-54", "cellBwpId": "2",
               "actPdcchCceFragmentControl": "false", "actUpperThrAckNackFiltering": "false",
               "actUpperThrAckNackHrFiltering": 'false', "pdcchResourcePreference": "peakRate"}]
          }],
        [{"parameterName": "ueConnectionEstablishmentMode", "operation": "update", "value": "useInitialBwp"},
         {"parameterName": "cellBwpList", "operation": "update", "value":
             [{"bwpDN": "MRBTS-50830/NRBTS-50830/BWP_PROFILE-7", "cellBwpId": "0",
               "actPdcchCceFragmentControl": "false", "actUpperThrAckNackFiltering": "false",
               "actUpperThrAckNackHrFiltering": 'false', "pdcchResourcePreference": "peakRate"},
              {"bwpDN": "MRBTS-50830/NRBTS-50830/BWP_PROFILE-57", "cellBwpId": "1",
               "actPdcchCceFragmentControl": "false", "actUpperThrAckNackFiltering": "false",
               "actUpperThrAckNackHrFiltering": 'false', "pdcchResourcePreference": "peakRate"},
              {"bwpDN": "MRBTS-50830/NRBTS-50830/BWP_PROFILE-54", "cellBwpId": "2",
               "actPdcchCceFragmentControl": "false", "actUpperThrAckNackFiltering": "false",
               "actUpperThrAckNackHrFiltering": 'false', "pdcchResourcePreference": "peakRate"}]
          }],
    ]
    if deactivate:
        parameters = [
            [{"parameterName": "ueConnectionEstablishmentMode", "operation": "update", "value": "useDedicatedBwp"},
             {"parameterName": "cellBwpList", "operation": "update", "value":
                 [{"bwpDN": "MRBTS-50830/NRBTS-50830/BWP_PROFILE-5", "cellBwpId": "0",
                   "actPdcchCceFragmentControl": "false", "actUpperThrAckNackFiltering": "false",
                   "actUpperThrAckNackHrFiltering": 'false', "pdcchResourcePreference": "peakRate"},
                  {"bwpDN": "MRBTS-50830/NRBTS-50830/BWP_PROFILE-55", "cellBwpId": "1",
                   "actPdcchCceFragmentControl": "false", "actUpperThrAckNackFiltering": "false",
                   "actUpperThrAckNackHrFiltering": 'false', "pdcchResourcePreference": "peakRate"},
                  {"bwpDN": "MRBTS-50830/NRBTS-50830/BWP_PROFILE-54", "cellBwpId": "2",
                   "actPdcchCceFragmentControl": "false", "actUpperThrAckNackFiltering": "false",
                   "actUpperThrAckNackHrFiltering": 'false', "pdcchResourcePreference": "peakRate"}]
              }],
            [{"parameterName": "ueConnectionEstablishmentMode", "operation": "update", "value": "useDedicatedBwp"},
             {"parameterName": "cellBwpList", "operation": "update", "value":
                 [{"bwpDN": "MRBTS-50830/NRBTS-50830/BWP_PROFILE-5", "cellBwpId": "0",
                   "actPdcchCceFragmentControl": "false", "actUpperThrAckNackFiltering": "false",
                   "actUpperThrAckNackHrFiltering": 'false', "pdcchResourcePreference": "peakRate"},
                  {"bwpDN": "MRBTS-50830/NRBTS-50830/BWP_PROFILE-57", "cellBwpId": "1",
                   "actPdcchCceFragmentControl": "false", "actUpperThrAckNackFiltering": "false",
                   "actUpperThrAckNackHrFiltering": 'false', "pdcchResourcePreference": "peakRate"},
                  {"bwpDN": "MRBTS-50830/NRBTS-50830/BWP_PROFILE-54", "cellBwpId": "2",
                   "actPdcchCceFragmentControl": "false", "actUpperThrAckNackFiltering": "false",
                   "actUpperThrAckNackHrFiltering": 'false', "pdcchResourcePreference": "peakRate"}]
              }],
        ]
    return parameters


def prepare_mtk_new(alias):
    suite_type = "NSA" if "NSA" in BuiltIn().get_variable_value("${SUITE_NAME}") else "SA"
    global default_apn
    default_apn = "5gwro1" if suite_type == "NSA" else "5gsawro"
    _ute_ue.disconnect_additional_pdn(alias, default_apn)
    _ute_ue.connect_additional_pdn(alias, default_apn)
    _attenuator.set_attenuation_for_all_cells('0dB')
    if suite_type == "NSA":
        _ute_ue.change_network_mode(alias, "NR/LTE")
    else:
        _ute_ue.change_network_mode(alias, "NR only")
    _attenuator.set_attenuation_for_all_cells('90dB')
