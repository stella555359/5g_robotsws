import re
import time
from taf.config.scf import scf
import testsuite.Wroclaw.RRM.resources.scf_verification.dynamic_pdcch_setup as dyn_pdcch
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils import AdminUtils
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config as tl
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.pm_counters as pm
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.gnb_mirroring import L1L2
from testsuite.Wroclaw.RRM.resources.scf_verification.scf_verifier \
    import check_expected_parameters, setup_expected_parameters
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.attenuator import Attenuator
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.rue.attach_utils as rue_utils
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.log_helper import log_finder
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod import TcpdumpSmod

taf_ue = rue_utils.get_library_instance('taf.ue')

l1l2 = L1L2()
tcpdump = TcpdumpSmod()
scf = scf()
atten = Attenuator(with_initialisation=False)
au = AdminUtils()

cell_id = 3
pm_interval = 5
num_of_cells = 3
num_of_ues_attach = 1
num_of_ues_rlf_ho = 2

try:
    cell_1_attenuator_ports = tl.tl.gnbs[0].dus[0].rus[0].attenuation_ports
    cell_2_attenuator_ports = tl.tl.gnbs[0].dus[0].rus[1].attenuation_ports
    cell_3_attenuator_ports = tl.tl.gnbs[0].dus[0].rus[2].attenuation_ports
except AttributeError:
    assert False, 'No attenuator ports configured for separate cells!'

c_capabilities = 'REAL_UE_NSA'
ab_capabilities = 'SA_VONR'
mrbts_id = tl.tl.gnbs[0].instance_id
nrbts_id = tl.tl.gnbs[0].global_bts_id
cell_to_lock = [u'/MRBTS-1/RAT-1/RUNTIME_VIEW-1/MRBTS_R-1/NRBTS_R-' + str(nrbts_id) + '/NRCELL_R-3']

bts_prefix_from_tl = 'MRBTS-{}/NRBTS-{}'.format(str(mrbts_id), str(nrbts_id))

a1_params = {'actRedirect': 'true', 'actNrpmqapProfiles': 'true', 't310VoNR': '', 'n310VoNR': '',
             'maxGBRTrafficLimit': '', 'tRLFindForDUVoNR': '', 'actGBRAdmissionControl': 'off', 'actRohc': 'false',
             'actEnhancedVoNR': 'false',  'actVoNR': 'false', 'actNormVCfallback': 'true', 'actCDrx': 'false',
             'actCDrxVoNR': 'false', 'voiceFBmode': 'redirection', 'redirRAT': 'eutra', 'redirFreqeutra': '900',
             'actVoipPacketAggr': 'false', 'miNrCellAvailability': '5min', 'miNrCellUtilization': '5min',
             'miNrNGCC': '5min', 'miNrNgInterface': '5min', 'miNrNgUReport': '5min', 'miNrRachUsage': '5min'}

a3_raw_params = {'actVoNR': 'true', 'actNrpmqapProfiles': 'true', 'actIntraFreqHoSA': 'true', 'a3MeasEnabled': 'rsrp',
                 'a3HysteresisSsbRsrp': '0', 'a3OffsetSsbRsrp': '5', 'miNrCellAvailability': '5min',
                 'miNrCellUtilization': '5min', 'miNrNGCC': '5min', 'miNrNgInterface': '5min', 'miNrNgUReport': '5min'}

b1_params = {'actVoNR': 'true', 'actNrpmqapProfiles': 'true', 'actRedirect': 'true', 'a2MeasRedirectEnabled': 'rsrp',
             'a2HysteresisRedirectSsbRsrp': '0', 'a2ThresholdRedirectSsbRsrp': '60',
             'a2TimeToTriggerRedirectSsbRsrp': 'ms256', 'redirRAT': 'eutra', 'redirFreqeutra': '900',
             'miNrCellAvailability': '5min', 'miNrCellUtilization': '5min', 'miNrNGCC': '5min',
             'miNrNgInterface': '5min', 'miNrNgUReport': '5min', 'miNrRachUsage': '5min'}

b3_params = {'actVoNR': 'true', 'actNrpmqapProfiles': 'true', 'srbInactivityTimerSA': '60',
             'drbInactivityTimerSA': '60', 'activityNotificationLevelSA': 'ue', 'miNrCellAvailability': '5min',
             'miNrCellUtilization': '5min', 'miNrNGCC': '5min', 'miNrNgInterface': '5min', 'miNrNgUReport': '5min'}

b4_params = {'actVoNR': 'true', 'actNrpmqapProfiles': 'true', 'actgNBinitRLF': 'true', 'actUlDftSOfdm': 'false',
             'srbInactivityTimerSA': '600', 'drbInactivityTimerSA': '1200', 'tRlFindForDuVoNR': '2000ms',
             'miNrCellAvailability': '5min', 'miNrCellUtilization': '5min', 'miNrNGCC': '5min',
             'miNrNgInterface': '5min', 'miNrNgUReport': '5min'}

b5_raw_params = {'actVoNR': 'true', 'actNrpmqapProfiles': 'true', 'actIntraFreqHoSA': 'true', 'a3MeasEnabled': 'rsrp',
                 'a3HysteresisSsbRsrp': '0', 'a3OffsetSsbRsrp': '5', 'miNrCellAvailability': '5min',
                 'miNrCellUtilization': '5min', 'miNrNGCC': '5min', 'miNrNgInterface': '5min', 'miNrNgUReport': '5min'}

b7_raw_params = {'actVoNR': 'true', 'actInterRatHoSA': 'true', 'actInterRatHoDlDataForward': 'true',
                 'a3MeasEnabled': 'rsrp', 'a3HysteresisSsbRsrp': '0', 'a3OffsetSsbRsrp': '5',
                 'miNrCellAvailability': '5min', 'miNrCellUtilization': '5min', 'miNrNGCC': '5min',
                 'miNrNgInterface': '5min', 'miNrNgUReport': '5min', 'miNrRachUsage': '5min'}

c8_lte_scf_params_on = {'actB1ExtMeasNR': 'true', 'actDynTrigLteNrDualConnectivity': 'true',
                        'b1NrBeamReportQuantity': 'RSRP', 'b1NrBeamThreshRsrp': '26', 'b1NrMaxNumBeams': '1'}

lte_scf_params_off = {'actB1ExtMeasNR': 'false'}

c_default_raw_params = {'actIntraFreqInterGnbMobilityNSA3x': 'true', 'cbraPreamblesPerSsb': 'n56',
                        'totalNumberOfRAPreambles': '64', 'a3MeasEnabled': 'rsrp',
                        'a3HysteresisSsbRsrp': '4', 'a3OffsetSsbRsrp': '10', 'miNrCellAvailability': '5min',
                        'miNrCellUtilization': '5min', 'miNrNGCC': '5min', 'miNrNgInterface': '5min',
                        'miNrNgUReport': '5min', 'miNrRachUsage': '5min'}


def a3_b5_set_scf_params(number_of_cells, values_dict, bts_prefix=bts_prefix_from_tl):
    scf_params = {}
    for cell in range(1, number_of_cells + 1):
        scf_params['{}/NRCELL-{}/a3MeasEnabled'.format(bts_prefix, str(cell))] = \
            values_dict.get('a3MeasEnabled')
        scf_params['{}/NRCELL-{}/a3HysteresisSsbRsrp'.format(bts_prefix, str(cell))] = \
            values_dict.get('a3HysteresisSsbRsrp')
        scf_params['{}/NRCELL-{}/a3OffsetSsbRsrp'.format(bts_prefix, str(cell))] = \
            values_dict.get('a3OffsetSsbRsrp')
        scf_params['{}/NRCELL-{}/actVoNR'.format(bts_prefix, str(cell))] = \
            values_dict.get('actVoNR')
    return dict(scf_params, **values_dict)


def b7_set_scf_params(number_of_cells, values_dict, bts_prefix=bts_prefix_from_tl):
    scf_params = {}
    for cell in range(number_of_cells):
        cell_str = str(cell + 1)
        scf_params[bts_prefix + '/NRCELL-' + cell_str + '/a3MeasEnabled'] = \
            values_dict.get('a3MeasEnabled')
        scf_params[bts_prefix + '/NRCELL-' + cell_str + '/a3HysteresisSsbRsrp'] = \
            values_dict.get('a3HysteresisSsbRsrp')
        scf_params[bts_prefix + '/NRCELL-' + cell_str + '/a3OffsetSsbRsrp'] = \
            values_dict.get('a3OffsetSsbRsrp')
        scf_params[bts_prefix + '/NRCELL-' + cell_str + '/actVoNR'] = \
            values_dict.get('actVoNR')
    return dict(scf_params, **values_dict)


def c_set_scf_params(number_of_cells, values_dict, bts_prefix=bts_prefix_from_tl):
    scf_params = {}
    for cell in range(1, number_of_cells + 1):
        scf_params['{}/NRCELL-{}/cbraPreamblesPerSsb'.format(bts_prefix, str(cell))] = \
            values_dict.get('cbraPreamblesPerSsb')
        scf_params['{}/NRCELL-{}/totalNumberOfRAPreambles'.format(bts_prefix, str(cell))] = \
            values_dict.get('totalNumberOfRAPreambles')
        scf_params['{}/NRCELL-{}/a3MeasEnabled'.format(bts_prefix, str(cell))] = \
            values_dict.get('a3MeasEnabled')
        scf_params['{}/NRCELL-{}/a3HysteresisSsbRsrp'.format(bts_prefix, str(cell))] = \
            values_dict.get('a3HysteresisSsbRsrp')
        scf_params['{}/NRCELL-{}/a3OffsetSsbRsrp'.format(bts_prefix, str(cell))] = \
            values_dict.get('a3OffsetSsbRsrp')
    return dict(scf_params, **values_dict)


a3_params = a3_b5_set_scf_params(num_of_cells, a3_raw_params)
b5_params = a3_b5_set_scf_params(num_of_cells, b5_raw_params)
b7_params = b7_set_scf_params(num_of_cells, b7_raw_params)
c_default_scf_params = c_set_scf_params(num_of_cells, c_default_raw_params)


def make_call_and_answer(call_alias='VC_1', calling_ue='UE_1', answering_ue='UE_2'):
    try:
        rue_utils.start_voice_call(vc_alias=call_alias, ue_alias=calling_ue, to=answering_ue)
        rue_utils.await_incoming_voice_call(vc_alias=call_alias, ue_alias=answering_ue, timeout='30s')
    except BaseException:
        blog("Call failed!", level='ERROR')
        raise


def make_3_call_attempts(num_of_ues):
    try:
        blog("Making first call attempt...")
        make_call_and_answer(call_alias='VC_1', calling_ue='UE_1', answering_ue='UE_2')
    except BaseException:
        time.sleep(15)
        rue_utils.detach_ues(num_of_ues)
        time.sleep(15)
        rue_utils.attach_ues(num_of_ues)
        time.sleep(20)
        try:
            blog("Making second call attempt...")
            make_call_and_answer(call_alias='VC_2', calling_ue='UE_2', answering_ue='UE_1')
        except BaseException:
            time.sleep(15)
            rue_utils.detach_ues(num_of_ues)
            time.sleep(15)
            rue_utils.attach_ues(num_of_ues)
            time.sleep(20)
            try:
                blog("Making third call attempt...")
                make_call_and_answer(call_alias='VC_3', calling_ue='UE_1', answering_ue='UE_2')
            except BaseException:
                blog("All 3 call attempts failed!", level='ERROR')
                raise


@logged_keyword
def setup_and_check_preconditions_in_lte_scf(params_to_check=None,
                                             scf_file=None,
                                             skip_parameter_relation_errors=False,
                                             bandwidth=None):
    try:
        bts_host = tl.tl.lte_mplane.v4
    except AttributeError:
        assert False, 'No LTE mplane IP in testline init!'

    admin_utils = AdminUtils(bts_host=bts_host)

    current_scf_file = admin_utils.download_current_scf(file_name='backup_scf.xml')
    if not scf_file:
        scf_file = admin_utils.download_current_scf(file_name='new_scf.xml')
    scf.load_scf(scf_file)
    try:
        if bandwidth:
            dyn_pdcch.check_expected_pdcch_parameters(scf, bandwidth)
        if params_to_check:
            check_expected_parameters(params_to_check, scf)
    except AssertionError:
        if bandwidth:
            dyn_pdcch.setup_expected_pdcch_parameters(scf, bandwidth)
            dyn_pdcch.check_expected_pdcch_parameters(scf, bandwidth)

        if params_to_check:
            setup_expected_parameters(params_to_check, scf)
            check_expected_parameters(params_to_check, scf)
        scf.save_scf(scf_file)

        admin_utils.perform_commissioning(scf_file=scf_file,
                                          skip_parameter_relation_errors=skip_parameter_relation_errors)
        time.sleep(300)
    return current_scf_file


@logged_keyword
def start_logging(pcap_filename="default", smod_slave=True):
    if pcap_filename == "default":
        l1l2.start_gnbmirroring()
        tcpdump.start_tcpdump_on_smod(smod_slave=smod_slave)
    else:
        l1l2.start_gnbmirroring(filename="CB007564_CB008200_{}.pcap".format(pcap_filename))
        tcpdump.start_tcpdump_on_smod(filename="CB007564_CB008200_{}.pcap"
                                      .format(pcap_filename), smod_slave=smod_slave)


@logged_keyword
def stop_logging():
    tcpdump.stop_tcpdump_and_download_logs_from_smod()
    l1l2.stop_gnbmirroring_and_download_logs()


@logged_keyword
def call_with_logs(pcap_filename="default", capabilities=ab_capabilities):
    try:
        atten.initialise_attenuator()
        rue_utils.require_ues(num_of_ues_rlf_ho, capabilities=capabilities)
        rue_utils.change_network_mode('UE_1', 'NR_only')
        rue_utils.change_network_mode('UE_2', 'NR_only')
        time.sleep(30)
        rue_utils.attach_ues(num_of_ues_rlf_ho)
        rue_utils.change_network_mode('UE_1', 'NR_LTE')
        rue_utils.change_network_mode('UE_2', 'NR_LTE')
        time.sleep(30)
        start_logging(pcap_filename, smod_slave=False)
        rue_utils.start_voice_call(ue_alias='UE_2', to='UE_1')
        time.sleep(60)
        stop_logging()
        rue_utils.change_network_mode('UE_1', 'NR_only')
        rue_utils.change_network_mode('UE_2', 'NR_only')
        rue_utils.detach_ues(num_of_ues_rlf_ho)
    except BaseException:
        rue_utils.change_network_mode('UE_1', 'NR_only')
        rue_utils.change_network_mode('UE_2', 'NR_only')
        rue_utils.detach_ues(num_of_ues_rlf_ho)
        stop_logging()
        raise


@logged_keyword
def attach_with_logs(sleep_after_attach=0, capabilities=c_capabilities):
    try:
        start_logging()
        rue_utils.attach_ues(num_of_ues_attach)
        time.sleep(int(sleep_after_attach))
        stop_logging()
        rue_utils.detach_ues(num_of_ues_attach)
    except BaseException:
        stop_logging()
        rue_utils.detach_ues(num_of_ues_attach)
        raise


@logged_keyword
def rlf_with_logs(sleep_after_attach=0, capabilities=ab_capabilities):
    try:
        atten.initialise_attenuator()
        rue_utils.require_ues(num_of_ues_rlf_ho, capabilities=capabilities)
        rue_utils.attach_ues(num_of_ues_rlf_ho)
        time.sleep(int(sleep_after_attach))
        start_logging(smod_slave=False)
        make_3_call_attempts(num_of_ues_rlf_ho)
        atten.set_attenuation(value_string=90)
        time.sleep(200)
        stop_logging()
        atten.release_attenuator()
    except BaseException:
        rue_utils.detach_ues(num_of_ues_rlf_ho)
        stop_logging()
        atten.release_attenuator()
        raise


@logged_keyword
def ue_inactivity_with_logs(inactivity_time=80, capabilities=ab_capabilities):
    try:
        start_logging(smod_slave=False)
        rue_utils.require_ues(num_of_ues_attach, capabilities=capabilities)
        rue_utils.attach_ues(num_of_ues_attach)
        rue_utils.start_ul_data_transfer_on_ues(num_of_ues_attach, duration='15s',
                                                throughput='200Mbits/sec', parallel_streams=None,
                                                packet_size='1200', max_segment_size='1450')
        rue_utils.start_dl_data_transfer_on_ues(num_of_ues_attach, duration='15s',
                                                throughput='200Mbits/sec', parallel_streams=None,
                                                packet_size='1200', max_segment_size='1450')
        time.sleep(15)
        rue_utils.stop_ul_data_transfer_on_ues(num_of_ues_attach)
        rue_utils.stop_dl_data_transfer_on_ues(num_of_ues_attach)
        time.sleep(inactivity_time)
        stop_logging()
        rue_utils.detach_ues(num_of_ues_attach)
    except BaseException as e:
        try:
            rue_utils.detach_ues(num_of_ues_attach)
            stop_logging()
        except BaseException:
            pass
        raise e


@logged_keyword
def handover_with_logs(pcap_filename="default", sleep_after_attach=0, capabilities=ab_capabilities,
                       source_cell_attenator_ports=None, destination_cell_attenuator_ports=None, lte_ho=False):
    try:
        atten.initialise_attenuator()
        au.lock_cells(cell_to_lock)
        if not lte_ho:
            atten.set_attenuation(value_string=90, ports=destination_cell_attenuator_ports)
        rue_utils.require_ues(num_of_ues_rlf_ho, capabilities=capabilities)
        rue_utils.attach_ues(num_of_ues_rlf_ho)
        if lte_ho:
            rue_utils.change_network_mode('UE_1', 'NR_LTE')
            rue_utils.change_network_mode('UE_2', 'NR_LTE')
        time.sleep(int(sleep_after_attach))
        blog("Cell ID for UE_1 before HO: {}".format(str(taf_ue.get_ue_info('UE_1', 'CELL_ID'))))
        blog("Cell ID for UE_2 before HO: {}".format(str(taf_ue.get_ue_info('UE_2', 'CELL_ID'))))
        start_logging(pcap_filename, smod_slave=False)
        make_3_call_attempts(num_of_ues_rlf_ho)
        max_attenuation = 90
        if not lte_ho:
            atten.gradually_decrease_attenuation(
                init_value=max_attenuation, step=5, interval=1, ports=destination_cell_attenuator_ports)
        atten.gradually_increase_attenuation(
            max_value=max_attenuation, step=5, interval=1, ports=source_cell_attenator_ports)
        time.sleep(30)
        blog("Cell ID for UE_1 after HO: {}".format(str(taf_ue.get_ue_info('UE_1', 'CELL_ID'))))
        blog("Cell ID for UE_2 after HO: {}".format(str(taf_ue.get_ue_info('UE_2', 'CELL_ID'))))
        stop_logging()
        atten.set_attenuation(value_string=0, ports=source_cell_attenator_ports)
        if lte_ho:
            rue_utils.change_network_mode('UE_1', 'NR_only')
            rue_utils.change_network_mode('UE_2', 'NR_only')
        au.unlock_all_cells()
        rue_utils.detach_ues(num_of_ues_rlf_ho)
        atten.release_attenuator()
    except BaseException:
        au.unlock_all_cells()
        atten.set_attenuation(value_string=0, ports=source_cell_attenator_ports)
        if lte_ho:
            rue_utils.change_network_mode('UE_1', 'NR_only')
            rue_utils.change_network_mode('UE_2', 'NR_only')
        rue_utils.detach_ues(num_of_ues_rlf_ho)
        stop_logging()
        atten.release_attenuator()
        raise


def find_value_inside_brackets(string):
    return re.search(r'\((.*?)\)', string).group(1)


@logged_keyword
def check_event_rach_config_in_pcap_log(pcap_file):
    relevant_frames = log_finder(pcap_file, 'x2ap', 'SgNBAdditionRequestAcknowledge')
    for frame in relevant_frames:
        rach_config_dedicated = frame.find('rach-ConfigDedicated*').first()['val']
        if rach_config_dedicated:
            blog('rach-ConfigDedicated event found.')
            return True
    assert False, 'rach-ConfigDedicated event NOT found!'


def check_if_counter_incremented(counter_value_list, target_counter_value):
    return any(counter_value >= target_counter_value for counter_value in counter_value_list)


@logged_keyword
def verify_pm_counters(pm_counters_list, target_counter_value=1):
    pm_counters_path = pm.collect_counters()
    pm_counters = pm.get_relevant_pm_counters(pi_dir=pm_counters_path, counter_ids=pm_counters_list)
    blog('Test revelant counters:{}'.format(str(pm_counters)))
    if not pm_counters:
        raise Exception('PM counter dict is empty, there are no {} counters collected on BTS'.format(pm_counters_list))
    for counter in pm_counters.values():
        incremented = False
        for cell, counter_value_list in iter(counter.items()):
            incremented = check_if_counter_incremented(counter_value_list, target_counter_value)
            if incremented:
                break
        assert incremented, 'PM Counters not incremented'


@logged_keyword
def find_harqu_with_crc_ok(pcap_file, rntis):
    frames = log_finder(pcap_file, 'uldata_puschreceiverespharqu', 'UlData_PuschReceiveRespHarqU_t')
    for msg in frames:
        found_rnti = msg.find('rnti*').first()['val']
        if found_rnti in rntis:
            crc_of_harqu = msg.find('crc*').first()['val']
            if crc_of_harqu == 'OK (0)':
                blog('HarqU packet with CRC OK found.')
                return True
    assert False, 'CRC OK NOT found in HarqU packets for provided RNTI'


@logged_keyword
def check_prach_preamble_index(pcap_file, preamble_index):
    frames = log_finder(pcap_file, 'uldata_prachreceiveind', 'UlData_PrachReceiveInd_t')
    for msg in frames:
        try:
            found_prach_preamble_index = msg.find('prachPreambleIndex*').first()['val']
            if int(found_prach_preamble_index) == int(preamble_index):
                blog('Prach preamble index {} found.'.format(preamble_index))
                return True
        except IndexError:
            pass
    assert False, 'Prach preamble index {} NOT found!'.format(preamble_index)


@logged_keyword
def check_user_inactivity_in_ue_context(pcap_file):
    frames = log_finder(pcap_file, 'ngap', 'UEContextReleaseCommand')
    user_inactivity_id = 20
    for msg in frames:
        try:
            found_radio_network_msg = msg.find('radioNetwork*').first()['val']
            if int(find_value_inside_brackets(found_radio_network_msg)) == user_inactivity_id:
                blog('UEContextReleaseCommand with user_activity param found.')
                return True
        except IndexError:
            pass
    assert False, 'UEContextReleaseCommand with user_activity param NOT found!'


@logged_keyword
def check_ue_context_release_command_redirection(pcap_file):
    frames = log_finder(pcap_file, 'ngap', 'UEContextReleaseCommand')
    redirection_id = 41
    for msg in frames:
        try:
            found_ue_context_release_command_redirection_msg = msg.find('radioNetwork*').first()['val']
            if int(find_value_inside_brackets(found_ue_context_release_command_redirection_msg)) == redirection_id:
                blog('UEContextReleaseCommand with redirection param found.')
                return True
        except IndexError:
            pass
    assert False, 'UEContextReleaseCommand with redirection param NOT found!'


@logged_keyword
def check_ue_context_release_command_complete(pcap_file):
    frames = log_finder(pcap_file, 'ngap', 'UEContextReleaseComplete')
    for msg in frames:
        try:
            found_ue_context_release_command_complete = msg.find('UEContextReleaseComplete*').first()['val']
            if found_ue_context_release_command_complete:
                blog('UEContextReleaseComplete found.')
                return True
        except IndexError:
            pass
    assert False, 'UEContextReleaseComplete NOT found!'


@logged_keyword
def check_ue_context_modification_with_rl_failure(pcap_file):
    frames = log_finder(pcap_file, 'f1ap', 'UEContextModificationRequired')
    rl_failure_id = 12
    for msg in frames:
        try:
            found_ue_context_modification_required_msg = msg.find('radioNetwork*').first()['val']
            if int(find_value_inside_brackets(found_ue_context_modification_required_msg)) == rl_failure_id:
                blog('UEContextReleaseCommand with rl-failure-others param found.')
                return True
        except IndexError:
            pass
    assert False, 'UEContextReleaseCommand with rl-failure-others param NOT found!'


@logged_keyword
def check_ue_context_release_request_with_radio_connection_with_ue_lost_cause(pcap_file):
    frames = log_finder(pcap_file, 'ngap', 'UEContextReleaseRequest')
    radio_connection_with_ue_lost_id = 21
    for msg in frames:
        try:
            found_ue_context_release_request_msg = msg.find('radioNetwork*').first()['val']
            if int(find_value_inside_brackets(found_ue_context_release_request_msg)) == \
                    radio_connection_with_ue_lost_id:
                blog('UEContextReleaseRequest with "radioNetwork: radio-connection-with-ue-lost" param found.')
                return True
        except IndexError:
            pass
    assert False, 'UEContextReleaseRequest with "radioNetwork: radio-connection-with-ue-lost" param NOT found!'


@logged_keyword
def check_5qi_setup(pcap_file):
    frames = log_finder(pcap_file, 'ngap', 'PDUSessionResourceModifyRequest')
    for msg in frames:
        try:
            found_5qi_msg = msg.find('fiveQI*').first()['val']
            if int(found_5qi_msg) == 1:
                blog('PDUSessionResourceModifyRequest with fiveQI = 1 param found.')
                return True
        except IndexError:
            pass
    assert False, 'PDUSessionResourceModifyRequest with fiveQI = 1 param NOT found!'


@logged_keyword
def check_ims_voice_eps_fallback(pcap_file):
    voice_eps_fallback_id = 36
    frames = log_finder(pcap_file, 'ngap', 'PDUSessionResourceModifyResponse')
    for msg in frames:
        found_ims_voice_eps_fallback_msg = msg.find('radioNetwork*').first()['val']
        if int(find_value_inside_brackets(found_ims_voice_eps_fallback_msg)) == voice_eps_fallback_id:
            blog('PDUSessionResourceModifyResponse with ims-voice-eps-fallback-or-rat-fallback-triggered param found.')
            return True
    assert False, \
        'PDUSessionResourceModifyResponse with ims-voice-eps-fallback-or-rat-fallback-triggered param NOT found!'
