import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.rue.attach_utils as rue_utils
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils import AdminUtils
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.btslog import stop_and_collect_btslog, \
    start_btslog_on_local_machine, teardown_btslog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
import testsuite.Wroclaw.RRM.resources.scf_verification.scf_verifier as scf_verifier
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod import TcpdumpSmod
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tti.tti_streaming as tti
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.attenuator import Attenuator
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.classical.feature_CB007781.A.resources.test_specific_keywords import \
    analyse_7781_logs
from time import sleep

scf_params_A_1 = {'actUlDftSOfdm': 'true',
                  'ulTransPrecodeOffSinrThresh': '160',
                  'ulTransPrecodeOnSinrThresh': '150',
                  'ulTransPrecodePi2Bpsk': 'true',
                  'actUlPtrs': 'true',
                  'ulDMRSAdditionalPosition': 'No additional DMRS',
                  'dlMimoMode': '2x2 Closed Loop Spatial Multiplexing'}
scf_params_A_2 = {'actUlDftSOfdm': 'true',
                  'ulTransPrecodeOffSinrThresh': '160',
                  'ulTransPrecodeOnSinrThresh': '150',
                  'ulTransPrecodePi2Bpsk': 'true',
                  'actUlPtrs': 'true',
                  'ulDMRSAdditionalPosition': 'No additional DMRS',
                  'dlMimoMode': '2x2 Open Loop Spatial Multiplexing'}
scf_params_A_3 = {'actUlDftSOfdm': 'true',
                  'ulTransPrecodeOffSinrThresh': '160',
                  'ulTransPrecodeOnSinrThresh': '150',
                  'ulTransPrecodePi2Bpsk': 'true',
                  'actUlPtrs': 'true',
                  'ulDMRSAdditionalPosition': 'One additional DMRS',
                  'dlMimoMode': '2x2 Closed Loop Spatial Multiplexing'}

atten = Attenuator(with_initialisation=False)
tcpdump = TcpdumpSmod()


@logged_keyword
def TC_CB007781_5G_A_1_Dynamic_Transform_Precoder_Switching_SA_UE_DCI_0_1_5MHz_UDP():
    scf_verifier.setup_and_check_preconditions_in_scf(params_to_check=scf_params_A_1, bandwidth='5')
    sctp_logs, tti_logs, _ = collect_logs_7781(throughput='40Mbits/sec', protocol='udp',
                                                          max_atten=27, capabilities='REAL_UE_SA')
    analyse_7781_logs(sctp_logs, tti_logs)


@logged_keyword
def TC_CB007781_5G_A_2_Dynamic_Transform_Precoder_Switching_NSA_UE_DCI_0_1_20MHz_SRB3_TCP_Open_Loop_MIMO():
    scf_verifier.setup_and_check_preconditions_in_scf(params_to_check=scf_params_A_2, bandwidth='20')
    sctp_logs, tti_logs, _ = collect_logs_7781(throughput='40Mbits/sec', protocol='tcp',
                                                          max_atten=27, capabilities='REAL_UE_NSA')
    analyse_7781_logs(sctp_logs, tti_logs)


@logged_keyword
def TC_CB007781_5G_A_3_Transform_Precoder_activation_16QAM_DMRS_Active_NSA_UE():
    scf_verifier.setup_and_check_preconditions_in_scf(params_to_check=scf_params_A_3, bandwidth='10')
    sctp_logs, tti_logs, _ = collect_logs_7781(throughput='40Mbits/sec', protocol='udp',
                                                          max_atten=27, capabilities='REAL_UE_NSA')
    analyse_7781_logs(sctp_logs, tti_logs)


@logged_keyword
def collect_logs_7781(throughput, protocol, max_atten, capabilities):
    au = AdminUtils()
    au.lock_all_cells_except_chosen_one(1)
    atten.initialise_attenuator()

    start_btslog_on_local_machine()
    tcpdump.start_tcpdump_on_smod(smod_slave=tl.smod_slave)

    rue_utils.require_ues(1, capabilities=capabilities)
    rue_utils.attach_ues(1)

    rue_utils.start_ul_data_transfer_on_ues(num_of_ues=1, duration='500s', throughput=throughput, protocol=protocol)
    tti.start_tti_traces_in_streaming_mode(collector_type='sbts')

    atten.gradually_increase_attenuation(init_value=0, max_value=27, step=3, interval=1)
    sleep(15)
    atten.gradually_decrease_attenuation(init_value=27, min_value=0, step=5, interval=0.1)
    atten.set_attenuation(value_string=0)
    sleep(15)

    tti_logs = tti.stop_tti_traces_in_streaming_mode()
    sctp_logs = tcpdump.stop_tcpdump_and_download_logs_from_smod()
    btslog_dir = stop_and_collect_btslog()

    return sctp_logs, tti_logs, btslog_dir


@logged_keyword
def TC_teardown():
    tti.teardown_tti_traces_in_streaming_mode()
    tcpdump.teardown_tcpdump_on_smod()
    teardown_btslog()
    rue_utils.detach_ues(1)
    atten.release_attenuator()
    au = AdminUtils()
    au.unlock_all_cells()


@logged_keyword
def suite_teardown():
    tti.teardown_tti_traces_in_streaming_mode()
    tcpdump.teardown_tcpdump_on_smod()
    atten.release_attenuator()
