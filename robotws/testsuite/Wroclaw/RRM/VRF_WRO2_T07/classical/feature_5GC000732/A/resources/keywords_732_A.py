import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.rue.attach_utils as rue_utils
from taf.rfrl.bts.devices.du.pm_counters import GnbPmCounter

from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.btslog import stop_and_collect_btslog, \
    start_btslog_on_local_machine, teardown_btslog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
import testsuite.Wroclaw.RRM.resources.scf_verification.scf_verifier as scf_verifier
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.pm_counters import collect_counters as collect_counters_732_a
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod import TcpdumpSmod
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.attenuator import Attenuator
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl
from time import sleep
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.classical.feature_5GC000732.A.resources.test_specific_keywords import \
    analyse_732_A_1, analyse_PM_counters_732_A_3

scf_params_A_1 = {'t301': '400ms', 't311': '30000ms', 't304': 'ms2000', 't310': '2000ms',
                  'tWaitingRlRecover': '10000ms', 'timerRRCGuard': '6000', 'actGnbInitRlf': 'false',
                  'actUeInitRlf': 'true', 'rrcReestabTypeSA': 'sameGNB', 'actUlDftSOfdm': 'false'}

scf_params_A_3 = dict(scf_params_A_1, **{'miNrRRCC': '5min', 'miNrRRCD': '5min'})

REESTABLISHMENT_SLEEP_TIME = 2.7
PM_INTERVAL_IN_MINS = 5
WAIT_FOR_LOGS = 7.0

atten = Attenuator(with_initialisation=False)
tcpdump = TcpdumpSmod()


@logged_keyword
def TC_5GC000732_A_1_FDD_RLF_RRC_Connection_Reestablishment_Same_Serving_Cell_Valid_UE_Context():
    blog('Preparing SCF...')
    scf_verifier.setup_and_check_preconditions_in_scf(params_to_check=scf_params_A_1, bandwidth='20')
    blog('SCF prepared successfully.')

    sctp_logs, btslog = collect_logs_732_A_1(throughput='70Mbits/sec', protocol='udp', capabilities='REAL_UE_SA')
    analyse_732_A_1(sctp_logs, btslog)


@logged_keyword
def TC_5GC000732_A_3_FDD_RLF_RRC_Connection_Reestablishment_With_the_Same_Serving_Cell_Counters_Update():
    _, _, pi_dir = collect_logs_732_A_3(throughput='70Mbits/sec', protocol='udp', capabilities='REAL_UE_SA')
    analyse_PM_counters_732_A_3(pi_dir)


@logged_keyword
def TC_5GC000732_A_3_setup():
    blog('Preparing SCF...')
    scf_verifier.setup_and_check_preconditions_in_scf(params_to_check=scf_params_A_3)
    blog('SCF prepared successfully.')


@logged_keyword
def collect_logs_732_A_1(throughput, protocol, capabilities):
    blog('Start logs collection...')
    atten.initialise_attenuator()
    start_btslog_on_local_machine()
    tcpdump.start_tcpdump_on_smod(smod_slave=tl.smod_slave)
    rue_utils.require_ues(1, capabilities=capabilities)
    rue_utils.attach_ues(1)
    rue_utils.start_dl_data_transfer_on_ues(num_of_ues=1, duration='60s', throughput=throughput, protocol=protocol)
    atten.set_attenuation(value_string=90)
    sleep(REESTABLISHMENT_SLEEP_TIME)
    atten.set_attenuation(value_string=0)
    sleep(WAIT_FOR_LOGS)
    sctp_logs = tcpdump.stop_tcpdump_and_download_logs_from_smod()
    btslog_dir = stop_and_collect_btslog()
    blog('Logs collection finished.')

    return sctp_logs, btslog_dir


@logged_keyword
def collect_logs_732_A_3(throughput, protocol, capabilities):
    blog('Start logs collection...')
    gnb_counter = GnbPmCounter()
    gnb_counter.wait_for_next_pm_period(interval=PM_INTERVAL_IN_MINS)

    atten.initialise_attenuator()
    atten.set_attenuation(value_string=90, ports=tl.nr_cell_1_ports)

    start_btslog_on_local_machine()
    tcpdump.start_tcpdump_on_smod(smod_slave=tl.smod_slave)
    rue_utils.require_ues(1, capabilities=capabilities)
    rue_utils.attach_ues(1)
    rue_utils.start_dl_data_transfer_on_ues(num_of_ues=1, duration='60s', throughput=throughput, protocol=protocol)
    atten.set_attenuation(value_string=90, ports=tl.nr_cell_2_ports)
    sleep(REESTABLISHMENT_SLEEP_TIME)
    atten.set_attenuation(value_string=0, ports=tl.nr_cell_2_ports)
    sleep(WAIT_FOR_LOGS)

    sctp_logs = tcpdump.stop_tcpdump_and_download_logs_from_smod()
    btslog_dir = stop_and_collect_btslog()

    gnb_counter.wait_for_next_pm_period(interval=PM_INTERVAL_IN_MINS)
    pi_dir = collect_counters_732_a()
    blog('Logs collection finished.')

    return sctp_logs, btslog_dir, pi_dir


@logged_keyword
def TC_teardown_732_A():
    tcpdump.teardown_tcpdump_on_smod()
    teardown_btslog()
    rue_utils.detach_ues(1)
    atten.nullify_attenuation_on_all_ports()
    atten.release_attenuator()
