import logging
from time import sleep
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.attenuator import Attenuator
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.rue.attach_utils import require_ues, attach_ues, detach_ues, \
    start_dl_data_transfer_on_ues, start_ul_data_transfer_on_ues, \
    check_dl_transfer_is_alive, check_ul_transfer_is_alive, \
    await_dl_data_transfer_finish, await_ul_data_transfer_finish, \
    verify_average_ul_throughput, verify_average_dl_throughput
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.gnb_mirroring import L1L2
from taf.rfrl.bts.devices.du.pm_counters import GnbPmCounter
from testsuite.Wroclaw.RRM.resources.log.log import blog
from testsuite.Wroclaw.RRM.resources.max_tput_counters import MaxTputCounters
from testsuite.Wroclaw.RRM.resources.scf_verification.scf_verifier import \
    setup_and_check_preconditions_in_scf
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_lte import TcpdumpLte
from report_to_rep import report_kpis_and_configuration_to_reporting_portal, get_throughput_from_pdcp_counters
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.robot_globals import robot_globals
from taf.rfrl.ue.logs.tput_logs_collecting import collect_logs_during_data_transfer, download_logs_from_gnb
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_api import AdminApi

l1l2 = L1L2()
tcpdump = TcpdumpLte()


@logged_keyword
def create_log_path():
    return '{}/{}/{}'.format(robot_globals.outputdir(),
                             robot_globals.suitename().replace(' ', '_'),
                             robot_globals.testname())


@logged_keyword
def max_tput_test_setup(used_cell_number, type_of_transfer):
    ports = []
    if used_cell_number == '1':
        ports = [19, 20]
    elif used_cell_number == '2':
        ports = [17, 18]
    elif used_cell_number == '3':
        ports = [21, 22, 23, 24]
    attenuator = Attenuator()
    attenuator.set_attenuation(value_string='90')
    attenuator.set_attenuation(value_string='0', ports=ports)
    attenuator.release_attenuator()
    if type_of_transfer == 'scg':
        setup_and_check_preconditions_in_scf(
            {
                'ulDataPath': 'ulOverNr',
                'dlDataSplitMode': 'dlOverF1U',
            })
    elif type_of_transfer == 'split':
        setup_and_check_preconditions_in_scf(
            {
                'ulDataPath': 'ulOverNr',
                'dlDataSplitMode': 'dlOverF1UX2U',
            })
    blog('Setup finished!')


@logged_keyword
def max_tput_test_teardown(number_of_ues=1):
    detach_ues(num_of_ues=number_of_ues)
    l1l2.teardown_gnbmirroring()
    tcpdump.teardown_tcpdump_on_lte()
    attenuator = Attenuator()
    attenuator.set_attenuation(value_string='0')
    attenuator.release_attenuator()


@logged_keyword
def reserve_ue(number_of_ues=1):
    require_ues(number_of_ues)
    detach_ues(number_of_ues)
    sleep(5)


@logged_keyword
def prepare_ues_for_call(number_of_ues=1):
    l1l2.start_gnbmirroring(filename='maxtput_attach_log.pcap')
    attach_ues(number_of_ues)
    sleep(20)
    l1l2.stop_gnbmirroring_and_download_logs()


@logged_keyword
def perform_bidirectional_tput(number_of_ues=1, duration='60s', tput_dl='69Mbits/sec',
                               tput_ul='16Mbits/sec', protocol='tcp',
                               parallel_streams_dl='1', parallel_streams_ul='1',
                               packet_size='1400', max_segment_size='1450'):
    start_dl_data_transfer_on_ues(num_of_ues=number_of_ues, duration=duration, throughput=tput_dl, protocol=protocol,
                                  parallel_streams=parallel_streams_dl, packet_size=packet_size,
                                  max_segment_size=max_segment_size)
    start_ul_data_transfer_on_ues(num_of_ues=number_of_ues, duration=duration, throughput=tput_ul, protocol=protocol,
                                  parallel_streams=parallel_streams_ul, max_segment_size=max_segment_size)
    blog('Bidirectional data transfer started. Approx. {duration} till end...'.format(duration=duration))
    data_transfer_establish_time = 20
    blog('Waiting {time}s for data transfer to be established'.format(time=data_transfer_establish_time))
    sleep(data_transfer_establish_time)
    collect_logs_during_data_transfer(direction='BOTH')  # Collecting information about MCS
    download_logs_from_gnb(sub_dir='data_transfer')
    l1l2.start_gnbmirroring()
    check_ul_transfer_is_alive(num_of_ues=number_of_ues)
    check_dl_transfer_is_alive(num_of_ues=number_of_ues)
    await_dl_data_transfer_finish(num_of_ues=number_of_ues)
    await_ul_data_transfer_finish(num_of_ues=number_of_ues)
    blog('Data transfer finished.')


@logged_keyword
def max_tput_test(cell_number='3', protocol='udp', type_of_transfer='split',
                  number_of_ues=1, duration='240s',
                  tput_dl='90Mbits/sec', tput_ul='13Mbits/sec',
                  deviation='10%', parallel_streams_dl='4', parallel_streams_ul='2'):
    max_tput_counters = MaxTputCounters()
    gnb_counter = GnbPmCounter()
    max_tput_test_setup(used_cell_number=cell_number, type_of_transfer=type_of_transfer)
    tcpdump.start_tcpdump_on_lte()
    reserve_ue(number_of_ues=number_of_ues)
    prepare_ues_for_call(number_of_ues=number_of_ues)
    gnb_counter.wait_for_next_pm_period(interval="5min")
    perform_bidirectional_tput(number_of_ues=number_of_ues,
                               duration=duration,
                               tput_dl=tput_dl,
                               tput_ul=tput_ul,
                               protocol=protocol,
                               parallel_streams_dl=parallel_streams_dl,
                               parallel_streams_ul=parallel_streams_ul)
    counter_collection_time = 60
    blog('Waiting {time}s for counters to be collected...'.format(time=counter_collection_time))
    sleep(counter_collection_time)
    pdcp_sdu_tput, pdcp_volume_tput = \
        get_throughput_from_pdcp_counters(duration=int(duration[:-1]), protocol=protocol)
    l1l2.stop_gnbmirroring_and_download_logs()
    tcpdump.stop_tcpdump_and_download_logs_from_lte()
    for ue in range(1, int(number_of_ues) + 1):
        log_path = create_log_path()
        report_kpis_and_configuration_to_reporting_portal(protocol=protocol, tput_dl=tput_dl, tput_ul=tput_ul,
                                                          deviation=deviation, ue_alias='UE_{}'.format(ue),
                                                          logs_dir='{}/data_transfer'.format(log_path),
                                                          cell_number=cell_number)
    dl_tput_min = str(float(tput_dl[:2]) - float(tput_dl[:2]) * float(deviation.strip('%')) / 100)
    ul_tput_min = str(float(tput_ul[:2]) - float(tput_ul[:2]) * float(deviation.strip('%')) / 100)
    verify_average_ul_throughput(num_of_ues=number_of_ues, tput_min=ul_tput_min + 'Mbits/sec')
    verify_average_dl_throughput(num_of_ues=number_of_ues, tput_min=dl_tput_min + 'Mbits/sec')
    assert pdcp_volume_tput > float(dl_tput_min), "TPUT DL data from PDCP SDU volume calculation is too low! " \
                                                  "Expected: {}, Actual: {}".format(dl_tput_min, pdcp_volume_tput)
    with AdminApi() as adminapi:
        max_tput_counters.collect_counters_after_test(admin_connection="default")
    # max_tput_counters.verify_M51301C1_counter(tput_duration=240, expected_tput=(90000/240))
    max_tput_counters.verify_M51301C5_counter(max_threshold=0)
    max_tput_counters.verify_M51352C1_counter(max_threshold=0)
    max_tput_counters.verify_M51352C9_counter(max_threshold=0)
    max_tput_counters.verify_M51363C7_counter(max_threshold=0)
