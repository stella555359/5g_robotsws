import testsuite.Wroclaw.RRM.resources.scf_verification.scf_verifier as scf_verifier
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod as tcp_dump
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.rue.attach_utils as ue_utils
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config as tl
import time
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.matchers import PcapMessageMatcher as PM
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.log_helper import LogHelper
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.attenuator import Attenuator
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_api import AdminApi
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils import AdminUtils
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation import get_sw_release_name

mrbts_id = tl.tl.gnbs[0].instance_id
nrbts_id = tl.tl.gnbs[0].global_bts_id
bts_prefix = 'MRBTS-' + str(mrbts_id) + "/NRBTS-" + str(nrbts_id)
conditional_release = int('SBTS23R4'[4:].replace('R', ''))
tcpdump = tcp_dump.TcpdumpSmod()
_utils = AdminUtils()
scf_objects_params_below_23R4 = [
    {'parameterName': 'cellBwpList', 'operation': 'update', 'value':
        [
            {'bwpDN': bts_prefix + '/BWP_PROFILE-35',
             'cellBwpId': 0},
            {'bwpDN': bts_prefix + '/BWP_PROFILE-37',
             'cellBwpId': 1},
            {'bwpDN': bts_prefix + '/BWP_PROFILE-74',
             'cellBwpId': 2},
        ]},
]
scf_objects_params_23R4 = [
    {'parameterName': 'cellBwpList', 'operation': 'update', 'value':
        [
            {'actPdcchCceFragmentControl': 'false', 'bwpDN': bts_prefix + '/BWP_PROFILE-35',
             'cellBwpId': 0, 'pdcchResourcePreference': 'peakRate'},
            {'actPdcchCceFragmentControl': 'false', 'bwpDN': bts_prefix + '/BWP_PROFILE-37',
             'cellBwpId': 1, 'pdcchResourcePreference': 'peakRate'},
            {'actPdcchCceFragmentControl': 'false', 'bwpDN': bts_prefix + '/BWP_PROFILE-74',
             'cellBwpId': 2, 'pdcchResourcePreference': 'peakRate'},
        ]},
]
scf_objects_params_above_23R4 = [
    {'parameterName': 'cellBwpList', 'operation': 'update', 'value':
        [
            {'actPdcchCceFragmentControl': 'false', 'bwpDN': bts_prefix + '/BWP_PROFILE-35',
             'cellBwpId': 0, 'pdcchResourcePreference': 'peakRate',
             'actUpperThrAckNackFiltering': 'false', 'actUpperThrAckNackHrFiltering': 'false'},
            {'actPdcchCceFragmentControl': 'false', 'bwpDN': bts_prefix + '/BWP_PROFILE-37',
             'cellBwpId': 1, 'pdcchResourcePreference': 'peakRate',
             'actUpperThrAckNackFiltering': 'false', 'actUpperThrAckNackHrFiltering': 'false'},
            {'actPdcchCceFragmentControl': 'false', 'bwpDN': bts_prefix + '/BWP_PROFILE-74',
             'cellBwpId': 2, 'pdcchResourcePreference': 'peakRate',
             'actUpperThrAckNackFiltering': 'false', 'actUpperThrAckNackHrFiltering': 'false'},
        ]},
]


def verify_bwp_for_specific_release():
    bts_sw_release = int(get_sw_release_name()[4:8].replace('R', ''))
    if bts_sw_release == conditional_release:
        verify_bwp_profiles(scf_objects_params_23R4)
    elif bts_sw_release < conditional_release:
        verify_bwp_profiles(scf_objects_params_below_23R4)
    else:
        verify_bwp_profiles(scf_objects_params_above_23R4)


def verify_feature_parameter():
    scf_verifier.setup_and_check_preconditions_in_scf(params_to_check={'actMultipleDedicatedBWPs': 'True'})


def verify_bwp_profiles(scf_params):
    blog('starting_bwp_verification')
    with AdminApi() as web_api:
        _dist_name = bts_prefix + '/NRCELL-'
        _num_of_cells = len(web_api.get_cells_info())
        for cell_id in range(_num_of_cells):
            web_api.perform_object_recommissioning(dist_name=_dist_name + str(cell_id + 1),
                                                   parameter=scf_params,
                                                   operation='update',
                                                   skip_parameter_relation_errors=True,
                                                   should_activate=True)


def attach_UEs(num_of_ues):
    tcpdump.start_tcpdump_on_smod(smod_slave=False)
    ue_utils.require_ues(num_of_ues)
    ue_utils.detach_ues(num_of_ues)
    ue_utils.attach_ues(num_of_ues)
    attach_logs = tcpdump.stop_tcpdump_and_download_logs_from_smod()
    return attach_logs


def detach_UEs(num_of_ues):
    ue_utils.detach_ues(num_of_ues)


def verify_attach_with_correct_bwp(attach_logs, carrier_bandwidths):
    verify_attached_bwp_profile(attach_logs, carrier_bandwidths)
    attached_cell = get_attached_cell_from_pcap(attach_logs)
    blog("Attached CELL: " + attached_cell)
    return attached_cell


def verify_attached_bwp_profile(log_file, carrier_bandwidths):
    with LogHelper() as lh:
        finder = lh.add_pcap(pcap_file_path=log_file, tshark_filter='x2ap')
        msg_bwp_1 = finder.find_next(PM('SgNBAdditionRequestAcknowledge', message_type_pattern='empty'))
        msg_bwp_2 = finder.find_next(PM('SgNBAdditionRequestAcknowledge', message_type_pattern='empty'))
        carrier_bandwidth_1 = msg_bwp_1.find('carrierBandwidth').first()['val']
        carrier_bandwidth_2 = msg_bwp_2.find('carrierBandwidth').first()['val']
        blog(carrier_bandwidth_1)
        blog(carrier_bandwidth_2)
        message = 'UE not attached to proper BWP Profile'
        assert int(carrier_bandwidth_1) in carrier_bandwidths, message + ". Bandwidths not 106 or 160"
        carrier_bandwidths.remove(int(carrier_bandwidth_1))
        assert_msg = '\n{0}\nExpected: {1}\nBut was: {2}'.format(message, carrier_bandwidths[0], carrier_bandwidth_2)
        assert int(carrier_bandwidth_2) in carrier_bandwidths, assert_msg


def start_and_verify_throughput(num_of_ues):
    ue_utils.start_ul_data_transfer_on_ues(num_of_ues, duration='250s')
    time.sleep(70)
    ue_utils.check_ul_transfer_is_alive(num_of_ues)
    ue_utils.verify_average_ul_throughput(num_of_ues, tput_min='50Mbits/sec')


def perform_double_handover(num_of_ues):
    attenuator = Attenuator()
    attenuator.nullify_attenuation_on_all_ports()
    tcpdump.start_tcpdump_on_smod(smod_slave=False)
    for attentuation_level in range(10, 60, 10):
        attenuator.set_attenuation(value_string=str(attentuation_level), ports=[5, 7])
        time.sleep(10)
    attenuator.release_attenuator()
    ho_logs = tcpdump.stop_tcpdump_and_download_logs_from_smod()
    with LogHelper() as lh:
        finder = lh.add_pcap(pcap_file_path=ho_logs, tshark_filter='x2ap and nr-rrc')
        # mr_msg = finder.find_exactly(num_of_ues, PM('measurementReport', message_type_pattern='empty'))
        ho_msg = finder.find_all(PM('SgNBModificationConfirm', message_type_pattern='empty'))
        assert len(ho_msg) >= 2, 'Not enough SgNBModificationConfirm messages has been found'
        rrc_reconfig_1 = ho_msg[0].find('rrcReconfigurationComplete')
        rrc_reconfig_2 = ho_msg[1].find('rrcReconfigurationComplete')
        assert rrc_reconfig_1, 'RRC Reconfiguration not found in pcap'
        assert rrc_reconfig_2, 'RRC Reconfiguration not found in pcap'


def get_attached_cell_from_pcap(pcap_path):
    nr_cell_id = get_primary_and_secondary_physcellids_from_attach_pcap(pcap_path)
    blog('Cell attached: {cell_id}'.format(cell_id=nr_cell_id))
    global_cell_id = find_global_cell_id_given_cell_nr_id(nr_cell_id)
    return str(global_cell_id)


def get_primary_and_secondary_physcellids_from_attach_pcap(pcap_path=None):
    with LogHelper() as lh:
        finder = lh.add_pcap(pcap_file_path=pcap_path)
        sgnb_add_req_ack = finder.find_all(PM('UEContextSetupRequest',
                                              message_type_pattern='empty'))[-1]
        phys_id_paths = sgnb_add_req_ack.find('*nRCellIdentity*')[0]['val']
    return int(phys_id_paths[:9], 16)


def find_global_cell_id_given_cell_nr_id(cell_nr_id):
    cells_info = _utils.get_subcells_info()
    cells_num = len(get_cells_list())
    cells = []
    for i in range(cells_num):
        cells.append(cells_info[u'NRCELLGRP-' + str(i)]['NRCELL-' + str(i + 1)]['NRCELL_L']['parameters'])
    for cell in cells:
        if cell['nrCellIdentity'] == cell_nr_id:
            return cell['lcrId']
    else:
        return -1


def get_cells_list():
    cells_list = []
    with AdminApi() as web_api:
        for cell in web_api.get_cells_info():
            cells_list.append(cell['globalCellId'])
    return cells_list
