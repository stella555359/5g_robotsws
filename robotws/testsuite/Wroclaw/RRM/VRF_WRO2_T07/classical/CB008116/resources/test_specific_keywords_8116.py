import re
import time
from taf.config.scf import scf
from taf.sbts.oam.coam.admin import admin as coam
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config as tl
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.gnb_mirroring import L1L2
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.attenuator import Attenuator
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.rue.attach_utils as rue_utils
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils import AdminUtils
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.log_helper import log_finder
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod import TcpdumpSmod

taf_ue = rue_utils.get_library_instance('taf.ue')

l1l2 = L1L2()
tcpdump = TcpdumpSmod()
scf = scf()
atten = Attenuator(with_initialisation=False)
au = AdminUtils()
api = coam()

cell_id_8116 = 1
pm_interval_8116 = 5
num_of_cells_8116 = 3
num_of_ues_8116 = 1


tput_duration_8116 = '30s'
tput_dl_8116 = '50Mbits/sec'
tput_ul_8116 = '50Mbits/sec'
dl_tput_min_8116 = '35Mbits/sec'
ul_tput_min_8116 = '35Mbits/sec'
tput_protocol_8116 = 'tcp'
parallel_streams_ul_8116 = '1'
parallel_streams_dl_8116 = '1'
ue_capabilities_8116 = 'SA_INTEGRITY'


try:
    cell_1_attenuator_ports = tl.tl.gnbs[0].dus[0].rus[0].attenuation_ports
    cell_2_attenuator_ports = tl.tl.gnbs[0].dus[0].rus[1].attenuation_ports
    cell_3_attenuator_ports = tl.tl.gnbs[0].dus[0].rus[2].attenuation_ports
except AttributeError:
    assert False, 'No attenuator ports configured for separate cells!'

mrbts_id = tl.tl.gnbs[0].instance_id
nrbts_id = tl.tl.gnbs[0].global_bts_id

cell_to_lock_8116 = [u'/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-' + str(nrbts_id) + '/NRCELL_R-3']

bts_prefix_from_tl = 'MRBTS-{}/NRBTS-{}'.format(str(mrbts_id), str(nrbts_id))

aes_params = {'actUplaneIntegrityProtection': 'SA', 'nea0': '0',
              'nea1_128': '3', 'nea2_128': '4', 'nea3_128': '2'}
snow_params = {'actUplaneIntegrityProtection': 'SA', 'nea0': '0',
               'nea1_128': '4', 'nea2_128': '3', 'nea3_128': '2'}
zuc_params = {'actUplaneIntegrityProtection': 'SA', 'nea0': '0',
              'nea1_128': '3', 'nea2_128': '2', 'nea3_128': '4'}


@logged_keyword
def start_logging(smod_slave=True):
    l1l2.start_gnbmirroring()
    tcpdump.start_tcpdump_on_smod(smod_slave=smod_slave)


@logged_keyword
def stop_logging():
    tcpdump.stop_tcpdump_and_download_logs_from_smod()
    l1l2.stop_gnbmirroring_and_download_logs()


@logged_keyword
def start_dl_data_transfer_and_collect_l1l2(reserve_ue=True):
    try:
        atten.initialise_attenuator()
        # au.lock_cells(cell_to_lock_8116)
        if reserve_ue:
            rue_utils.require_ues(num_of_ues_8116, capabilities=ue_capabilities_8116)
        time.sleep(30)
        start_logging(smod_slave=False)
        time.sleep(10)
        rue_utils.attach_ues(num_of_ues_8116)
        time.sleep(5)
        stop_logging()
        rue_utils.start_dl_data_transfer_on_ues(duration=tput_duration_8116, throughput=tput_dl_8116,
                                                protocol=tput_protocol_8116, parallel_streams=parallel_streams_dl_8116,
                                                num_of_ues=num_of_ues_8116)
        rue_utils.start_ul_data_transfer_on_ues(duration=tput_duration_8116, throughput=tput_ul_8116,
                                                protocol=tput_protocol_8116, parallel_streams=parallel_streams_ul_8116,
                                                num_of_ues=num_of_ues_8116)
        time.sleep(5)
        rue_utils.check_dl_transfer_is_alive(num_of_ues=num_of_ues_8116)
        rue_utils.await_dl_data_transfer_finish(num_of_ues=num_of_ues_8116)
        rue_utils.verify_average_dl_throughput(num_of_ues=num_of_ues_8116, tput_min=dl_tput_min_8116)
        rue_utils.verify_average_ul_throughput(num_of_ues=num_of_ues_8116, tput_min=ul_tput_min_8116)
        # au.unlock_all_cells()
        rue_utils.detach_ues(num_of_ues_8116)
    except BaseException:
        try:
            # au.unlock_all_cells()
            rue_utils.detach_ues(num_of_ues_8116)
            stop_logging()
        except BaseException:
            pass
        raise


@logged_keyword
def start_ul_data_transfer_and_collect_l1l2(reserve_ue=True):
    try:
        atten.initialise_attenuator()
        # au.lock_cells(cell_to_lock_8116)
        if reserve_ue:
            rue_utils.require_ues(num_of_ues_8116, capabilities=ue_capabilities_8116)
        time.sleep(30)
        start_logging(smod_slave=False)
        time.sleep(10)
        rue_utils.attach_ues(num_of_ues_8116)
        time.sleep(5)
        stop_logging()
        rue_utils.start_ul_data_transfer_on_ues(duration=tput_duration_8116, throughput=tput_ul_8116,
                                                protocol=tput_protocol_8116, parallel_streams=parallel_streams_ul_8116,
                                                num_of_ues=num_of_ues_8116)
        time.sleep(5)
        rue_utils.check_ul_transfer_is_alive(num_of_ues=num_of_ues_8116)
        rue_utils.await_ul_data_transfer_finish(num_of_ues=num_of_ues_8116)
        rue_utils.verify_average_ul_throughput(num_of_ues=num_of_ues_8116, tput_min=ul_tput_min_8116)
        # au.unlock_all_cells()
        rue_utils.detach_ues(num_of_ues_8116)
    except BaseException:
        try:
            # au.unlock_all_cells()
            rue_utils.detach_ues(num_of_ues_8116)
            stop_logging()
        except BaseException:
            pass
        raise


@logged_keyword
def check_msg_in_pcap_log(pcap_file, protocol_filter, msg_name, field_name, correct_value):
    msg_value = ""
    msg_found = False
    correct_value_found = False
    relevant_frames = log_finder(pcap_file, protocol_filter, msg_name)
    for frame in relevant_frames:
        try:
            msg_value = frame.find(field_name).first()['val']
        except BaseException:
            pass
        if msg_value:
            blog('{} found. Checking value...'.format(field_name))
            msg_found = True
            if msg_value == correct_value:
                blog("{0} = {1}. Correct value.".format(field_name, msg_value))
                correct_value_found = True
                break
    if not msg_found:
        assert False, '{} NOT found!'.format(field_name)
    if not correct_value_found:
        assert False, 'Incorrect {0} value: {1}. ' \
                      'Correct value: {2}'.format(field_name, msg_value, correct_value)


@logged_keyword
def check_maximum_ue_rate_in_pcap_log(pcap_file):
    check_msg_in_pcap_log(pcap_file,
                          protocol_filter='ngap',
                          msg_name='InitialContextSetupRequest',
                          field_name='maximumIntegrityProtectedDataRate-UL',
                          correct_value='maximum-UE-rate (1)')


@logged_keyword
def check_integrity_protection_indication_in_pcap_log(pcap_file):
    check_msg_in_pcap_log(pcap_file,
                          protocol_filter='ngap',
                          msg_name='InitialContextSetupRequest',
                          field_name='integrityProtectionIndication',
                          correct_value='required (0)')


@logged_keyword
def check_integrity_prot_algorithm_for_aes_in_pcap_log(pcap_file):
    check_msg_in_pcap_log(pcap_file,
                          protocol_filter='f1ap',
                          msg_name='securityModeCommand',
                          field_name='integrityProtAlgorithm',
                          correct_value='nia2 (2)')


@logged_keyword
def check_integrity_protection_algorithm_for_aes_in_pcap_log(pcap_file):
    check_msg_in_pcap_log(pcap_file,
                          protocol_filter='e1ap',
                          msg_name='BearerContextSetupRequest',
                          field_name='integrityProtectionAlgorithm',
                          correct_value='i-128-NIA2 (2)')


@logged_keyword
def check_integrity_protection_indication_in_bearer_context_setup_request(pcap_file):
    check_msg_in_pcap_log(pcap_file,
                          protocol_filter='e1ap',
                          msg_name='BearerContextSetupRequest',
                          field_name='integrityProtectionIndication',
                          correct_value='required (0)')
