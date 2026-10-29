import re
import time
import random
from taf.config.scf import scf
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils import AdminUtils
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config as tl
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.pm_counters as pm
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.gnb_mirroring import L1L2
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.attenuator import Attenuator
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.rue.attach_utils as rue_utils
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.log_helper import log_finder
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod import TcpdumpSmod
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.scf_tools.scf_manager import ScfManager
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.DeltaStore import DeltaStore
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation import get_sw_release_name
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_api import AdminApi
from json import dumps

taf_ue = rue_utils.get_library_instance('taf.ue')

l1l2 = L1L2()
tcpdump = TcpdumpSmod()
scf = scf()
atten = Attenuator(with_initialisation=False)
au = AdminUtils()
ds = DeltaStore()

mrbts_id = tl.tl.gnbs[0].instance_id
nrbts_id = tl.tl.gnbs[0].global_bts_id

pm_interval_8985 = 5
tput_dl_8985 = '250Mbits/sec'
tput_ul_8985 = '50Mbits/sec'
tput_dl_recovery_8985 = '50Mbits/sec'
tput_ul_recovery_8985 = '10Mbits/sec'
tput_protocol_8985 = 'tcp'

bts_prefix_from_tl = 'MRBTS-{}/NRBTS-{}'.format(str(mrbts_id), str(nrbts_id))


try:
    cb008985_subcell_1_attenuator_ports = tl.tl.gnbs[0].dus[0].rus[0].attenuation_ports[0:2]
    cb008985_subcell_2_attenuator_ports = tl.tl.gnbs[0].dus[0].rus[0].attenuation_ports[2:4]
    cb008985_subcell_3_attenuator_ports = tl.tl.gnbs[0].dus[0].rus[1].attenuation_ports[0:2]
    cb008985_subcell_4_attenuator_ports = tl.tl.gnbs[0].dus[0].rus[1].attenuation_ports[2:4]
    cb008985_subcell_5_attenuator_ports = tl.tl.gnbs[0].dus[0].rus[2].attenuation_ports[0:2]
    cb008985_subcell_6_attenuator_ports = tl.tl.gnbs[0].dus[0].rus[2].attenuation_ports[2:4]
    cb008985_ru_1_attenuator_ports = tl.tl.gnbs[0].dus[0].rus[0].attenuation_ports
    cb008985_ru_2_attenuator_ports = tl.tl.gnbs[0].dus[0].rus[1].attenuation_ports
    cb008985_ru_3_attenuator_ports = tl.tl.gnbs[0].dus[0].rus[2].attenuation_ports

except AttributeError:
    assert False, 'No attenuator ports configured for separate cells!'


@logged_keyword
def add_channelgroup_4_5_6():
    ds.initialise_delta_store()
    ds.add_managed_object_and_parameter_to_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-4'.format(mrbts_id))

    ds.add_managed_object_and_parameter_to_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-5'.format(mrbts_id))

    ds.add_managed_object_and_parameter_to_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-6'.format(mrbts_id))

    ds.add_managed_object_and_parameter_to_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-4/CHANNEL-1'.format(mrbts_id),
        antlDN='MRBTS-55100/EQM-1/APEQM-1/RMOD-3/ANTL-2', direction='TX')
    ds.add_managed_object_and_parameter_to_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-4/CHANNEL-2'.format(mrbts_id),
        antlDN='MRBTS-55100/EQM-1/APEQM-1/RMOD-3/ANTL-2', direction='RX')
    ds.add_managed_object_and_parameter_to_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-4/CHANNEL-3'.format(mrbts_id),
        antlDN='MRBTS-55100/EQM-1/APEQM-1/RMOD-3/ANTL-6', direction='TX')
    ds.add_managed_object_and_parameter_to_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-4/CHANNEL-4'.format(mrbts_id),
        antlDN='MRBTS-55100/EQM-1/APEQM-1/RMOD-3/ANTL-6', direction='RX')

    ds.add_managed_object_and_parameter_to_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-5/CHANNEL-1'.format(mrbts_id),
        antlDN='MRBTS-55100/EQM-1/APEQM-1/RMOD-4/ANTL-1', direction='TX')
    ds.add_managed_object_and_parameter_to_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-5/CHANNEL-2'.format(mrbts_id),
        antlDN='MRBTS-55100/EQM-1/APEQM-1/RMOD-4/ANTL-1', direction='RX')
    ds.add_managed_object_and_parameter_to_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-5/CHANNEL-3'.format(mrbts_id),
        antlDN='MRBTS-55100/EQM-1/APEQM-1/RMOD-4/ANTL-5', direction='TX')
    ds.add_managed_object_and_parameter_to_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-5/CHANNEL-4'.format(mrbts_id),
        antlDN='MRBTS-55100/EQM-1/APEQM-1/RMOD-4/ANTL-5', direction='RX')

    ds.add_managed_object_and_parameter_to_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-6/CHANNEL-1'.format(mrbts_id),
        antlDN='MRBTS-55100/EQM-1/APEQM-1/RMOD-4/ANTL-2', direction='TX')
    ds.add_managed_object_and_parameter_to_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-6/CHANNEL-2'.format(mrbts_id),
        antlDN='MRBTS-55100/EQM-1/APEQM-1/RMOD-4/ANTL-2', direction='RX')
    ds.add_managed_object_and_parameter_to_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-6/CHANNEL-3'.format(mrbts_id),
        antlDN='MRBTS-55100/EQM-1/APEQM-1/RMOD-4/ANTL-6', direction='TX')
    ds.add_managed_object_and_parameter_to_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-6/CHANNEL-4'.format(mrbts_id),
        antlDN='MRBTS-55100/EQM-1/APEQM-1/RMOD-4/ANTL-6', direction='RX')
    add_channelgroup_4_5_6_ds_file = ds.collect_delta_store()
    blog("Adding CHANNELGROUPS 4, 5 and 6...")
    ds.perform_delta_recommissioning(delta_file=add_channelgroup_4_5_6_ds_file)
    au.wait_for_all_cells_on_air_state()


@logged_keyword
def remove_channelgroup_4_5_6():
    ds.initialise_delta_store()
    ds.delete_managed_object_from_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-4'.format(mrbts_id))

    ds.delete_managed_object_from_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-5'.format(mrbts_id))

    ds.delete_managed_object_from_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-6'.format(mrbts_id))

    remove_channelgroup_4_5_6_ds_file = ds.collect_delta_store()
    blog("Removing CHANNELGROUPS 4, 5 and 6...")
    ds.perform_delta_recommissioning(delta_file=remove_channelgroup_4_5_6_ds_file)
    au.wait_for_all_cells_on_air_state()


@logged_keyword
def transitioning_between_all_subcells_from_1_to_6():
    blog("Transitioning from subcell 2 to subcell 3...")
    transitioning_between_subcells(cb008985_subcell_2_attenuator_ports, cb008985_subcell_3_attenuator_ports)
    blog("Transitioning from subcell 3 to subcell 4...")
    transitioning_between_subcells(cb008985_subcell_3_attenuator_ports, cb008985_subcell_4_attenuator_ports)
    blog("Transitioning from subcell 4 to subcell 5...")
    transitioning_between_subcells(cb008985_subcell_4_attenuator_ports, cb008985_subcell_5_attenuator_ports)
    blog("Transitioning from subcell 5 to subcell 6...")
    transitioning_between_subcells(cb008985_subcell_5_attenuator_ports, cb008985_subcell_6_attenuator_ports)
    blog("Transitioning from subcell 6 to subcell 1...")
    transitioning_between_subcells(cb008985_subcell_6_attenuator_ports, cb008985_subcell_1_attenuator_ports)


@logged_keyword
def transitioning_between_all_subcells_from_6_to_1():
    blog("Transitioning from subcell 1 to subcell 6...")
    transitioning_between_subcells(cb008985_subcell_1_attenuator_ports, cb008985_subcell_6_attenuator_ports)
    blog("Transitioning from subcell 6 to subcell 5...")
    transitioning_between_subcells(cb008985_subcell_6_attenuator_ports, cb008985_subcell_5_attenuator_ports)
    blog("Transitioning from subcell 5 to subcell 4...")
    transitioning_between_subcells(cb008985_subcell_5_attenuator_ports, cb008985_subcell_4_attenuator_ports)
    blog("Transitioning from subcell 4 to subcell 3...")
    transitioning_between_subcells(cb008985_subcell_4_attenuator_ports, cb008985_subcell_3_attenuator_ports)
    blog("Transitioning from subcell 3 to subcell 2...")
    transitioning_between_subcells(cb008985_subcell_3_attenuator_ports, cb008985_subcell_2_attenuator_ports)


@logged_keyword
def transitioning_between_all_subcells_from_1_to_3():
    blog("Transitioning from subcell 1 to subcell 2...")
    transitioning_between_subcells(cb008985_subcell_1_attenuator_ports, cb008985_subcell_2_attenuator_ports)
    blog("Transitioning from subcell 2 to subcell 3...")
    transitioning_between_subcells(cb008985_subcell_2_attenuator_ports, cb008985_subcell_3_attenuator_ports)


@logged_keyword
def transitioning_between_all_subcells_from_3_to_1():
    blog("Transitioning from subcell 3 to subcell 2...")
    transitioning_between_subcells(cb008985_subcell_3_attenuator_ports, cb008985_subcell_2_attenuator_ports)
    blog("Transitioning from subcell 2 to subcell 1...")
    transitioning_between_subcells(cb008985_subcell_2_attenuator_ports, cb008985_subcell_1_attenuator_ports)


@logged_keyword
def transitioning_between_subcells(source_subcell_ports, destination_subcell_ports):
    atten.gradually_decrease_attenuation(
        init_value=90, step=15, interval=1, ports=destination_subcell_ports)
    atten.gradually_increase_attenuation(
        max_value=90, step=10, interval=1, ports=source_subcell_ports)


@logged_keyword
def suppress_only_one_subcell(suppressed_subcell=1, num_of_subcells=6):
    atten.initialise_attenuator()
    for subcell_number in range(1, num_of_subcells + 1):
        if subcell_number == int(suppressed_subcell):
            atten.set_attenuation(value_string=90, ports=globals()["cb008985_subcell_{}_attenuator_ports".
                                  format(subcell_number)])
        else:
            atten.set_attenuation(value_string=0, ports=globals()["cb008985_subcell_{}_attenuator_ports".
                                  format(subcell_number)])


@logged_keyword
def suppress_all_subcells_except_one(not_suppressed_subcell=1, num_of_subcells=6, attenuation_value=90):
    atten.initialise_attenuator()
    for subcell_number in range(1, num_of_subcells + 1):
        if subcell_number == int(not_suppressed_subcell):
            atten.set_attenuation(value_string=0,
                                  ports=globals()["cb008985_subcell_{}_attenuator_ports".format(subcell_number)])
        else:
            atten.set_attenuation(value_string=attenuation_value,
                                  ports=globals()["cb008985_subcell_{}_attenuator_ports".format(subcell_number)])


@logged_keyword
def set_attenuation_to_all_subcells(attenuation_value=0, num_of_subcells=6):
    atten.initialise_attenuator()
    for subcell_number in range(1, num_of_subcells + 1):
        atten.set_attenuation(value_string=attenuation_value, ports=globals()["cb008985_subcell_{}_attenuator_ports".
                              format(subcell_number)])


@logged_keyword
def suppress_all_subcells_except_random_one(num_of_subcells=6):
    random_subcell = random.randint(1, num_of_subcells)
    blog('Setting attenuation to 90dB to all subcells except subcell {}...'.format(random_subcell))
    suppress_all_subcells_except_one(not_suppressed_subcell=random_subcell, num_of_subcells=num_of_subcells)


@logged_keyword
def start_logging(pcap_filename="default", smod_slave=False):
    if pcap_filename == "default":
        l1l2.start_gnbmirroring()
        tcpdump.start_tcpdump_on_smod(smod_slave=smod_slave)
    else:
        l1l2.start_gnbmirroring(filename="CB008985_{}.pcap".format(pcap_filename))
        tcpdump.start_tcpdump_on_smod(filename="CB008985_{}.pcap".format(pcap_filename), smod_slave=smod_slave)


@logged_keyword
def stop_logging():
    tcpdump.stop_tcpdump_and_download_logs_from_smod()
    l1l2.stop_gnbmirroring_and_download_logs()


@logged_keyword
def attach_and_throughput_to_all_subcells_with_logs(sleep_after_attach=20, num_of_ues=1,
                                                    expected_tput_dl='200Mbits/sec', expected_tput_ul='20Mbits/sec',
                                                    deviation='10%', ue_caps='SA_VONR',
                                                    tput_duration='720s', num_of_subcells=6):
    try:
        rue_utils.require_ues(num_of_ues, capabilities=ue_caps)
        start_logging()
        rue_utils.attach_ues(num_of_ues)
        blog('Waiting {0}s after attach...'.format(sleep_after_attach))
        time.sleep(int(sleep_after_attach))
        blog("Starting UL data transfer...")
        rue_utils.start_ul_data_transfer_on_ues(duration=tput_duration, throughput=tput_ul_8985,
                                                protocol=tput_protocol_8985, parallel_streams=None,
                                                num_of_ues=num_of_ues, packet_size='1200', max_segment_size='1450')
        blog("Starting DL data transfer...")
        rue_utils.start_dl_data_transfer_on_ues(duration=tput_duration, throughput=tput_dl_8985,
                                                protocol=tput_protocol_8985, parallel_streams=None,
                                                num_of_ues=num_of_ues, packet_size='1200', max_segment_size='1450')
        blog('Data transfer started. Approx. {duration} till end...'.format(duration=tput_duration))
        data_transfer_establish_time = 20
        blog('Waiting {time}s for data transfer to be established...'.format(time=data_transfer_establish_time))
        time.sleep(data_transfer_establish_time)
        if int(num_of_subcells) == 6:
            transitioning_between_all_subcells_from_1_to_6()
            transitioning_between_all_subcells_from_6_to_1()
        elif int(num_of_subcells) == 3:
            transitioning_between_all_subcells_from_1_to_3()
            transitioning_between_all_subcells_from_3_to_1()
        else:
            raise ValueError("Incorrect number of subcells in num_of_subcells parameter!")
        blog('Checking if UL data transfer is alive...')
        rue_utils.check_ul_transfer_is_alive(num_of_ues=num_of_ues)
        blog('Checking if DL data transfer is alive...')
        rue_utils.check_dl_transfer_is_alive(num_of_ues=num_of_ues)
        blog('Waiting for DL data transfer to finish...')
        rue_utils.await_dl_data_transfer_finish(num_of_ues=num_of_ues)
        blog('Waiting for UL data transfer to finish...')
        rue_utils.await_ul_data_transfer_finish(num_of_ues=num_of_ues)
        blog('Data transfer finished.')
        dl_tput_min = str(
            float(expected_tput_dl[:3]) - float(expected_tput_dl[:3]) * float(deviation.strip('%')) / 100) + 'Mbits/sec'
        ul_tput_min = str(
            float(expected_tput_ul[:2]) - float(expected_tput_ul[:2]) * float(deviation.strip('%')) / 100) + 'Mbits/sec'
        blog('Veryfing if average UL throughput is higher than {}'.format(ul_tput_min))
        rue_utils.verify_average_ul_throughput(num_of_ues=num_of_ues, tput_min=ul_tput_min)
        blog('Veryfing if average DL throughput is higher than {}'.format(dl_tput_min))
        rue_utils.verify_average_dl_throughput(num_of_ues=num_of_ues, tput_min=dl_tput_min)
        stop_logging()
        blog('Detaching UEs (after test)...')
        rue_utils.detach_ues(num_of_ues)
    except BaseException as e:
        blog("Keyword failed due to: {}".format(e), level="ERROR")
        try:
            blog('Detaching UEs (teardown)...')
            rue_utils.detach_ues(1)
            stop_logging()
        except BaseException:
            pass
        raise


@logged_keyword
def ue_recover_after_subcell_switch_failure(sleep_after_attach=10, num_of_ues=1, sleep_after_failure=15,
                                            expected_tput_dl='50Mbits/sec', expected_tput_ul='10Mbits/sec',
                                            deviation='10%', ue_caps='SA_VONR', tput_duration='120s'):
    try:
        rue_utils.require_ues(num_of_ues, capabilities=ue_caps)
        start_logging()
        rue_utils.attach_ues(num_of_ues)
        blog('Waiting {0}s after attach...'.format(sleep_after_attach))
        time.sleep(int(sleep_after_attach))
        blog("Starting UL data transfer...")
        rue_utils.start_ul_data_transfer_on_ues(duration=tput_duration, throughput=tput_ul_recovery_8985,
                                                protocol=tput_protocol_8985, parallel_streams=None,
                                                num_of_ues=num_of_ues, packet_size='1200', max_segment_size='1450')
        blog("Starting DL data transfer...")
        rue_utils.start_dl_data_transfer_on_ues(duration=tput_duration, throughput=tput_dl_recovery_8985,
                                                protocol=tput_protocol_8985, parallel_streams=None,
                                                num_of_ues=num_of_ues, packet_size='1200', max_segment_size='1450')
        blog('Data transfer started. Approx. {duration} till end...'.format(duration=tput_duration))
        data_transfer_establish_time = 5
        blog('Waiting {time}s for data transfer to be established...'.format(time=data_transfer_establish_time))
        time.sleep(data_transfer_establish_time)
        blog("Setting 90dB attenuation to subcell 2 to simulate UE recover after subcell failure...")
        atten.set_attenuation(value_string=90,
                              ports=cb008985_subcell_4_attenuator_ports)
        atten.set_attenuation(value_string=0,
                              ports=cb008985_subcell_1_attenuator_ports)
        blog('Waiting {0}s after subcell 2 attenuation set to 90dB...'.format(sleep_after_failure))
        time.sleep(int(sleep_after_failure))
        stop_logging()
        blog('Checking if UL data transfer is alive...')
        rue_utils.check_ul_transfer_is_alive(num_of_ues=num_of_ues)
        blog('Checking if DL data transfer is alive...')
        rue_utils.check_dl_transfer_is_alive(num_of_ues=num_of_ues)
        blog('Waiting for DL data transfer to finish...')
        rue_utils.await_dl_data_transfer_finish(num_of_ues=num_of_ues)
        blog('Waiting for UL data transfer to finish...')
        rue_utils.await_ul_data_transfer_finish(num_of_ues=num_of_ues)
        blog('Data transfer finished.')
        dl_tput_min = str(
            float(expected_tput_dl[:2]) - float(expected_tput_dl[:2]) * float(deviation.strip('%')) / 100) + 'Mbits/sec'
        ul_tput_min = str(
            float(expected_tput_ul[:2]) - float(expected_tput_ul[:2]) * float(deviation.strip('%')) / 100) + 'Mbits/sec'
        blog('Veryfing if average UL throughput is higher than {}'.format(ul_tput_min))
        rue_utils.verify_average_ul_throughput(num_of_ues=num_of_ues, tput_min=ul_tput_min)
        blog('Veryfing if average DL throughput is higher than {}'.format(dl_tput_min))
        rue_utils.verify_average_dl_throughput(num_of_ues=num_of_ues, tput_min=dl_tput_min)
        blog('Detaching UEs (after test)...')
        rue_utils.detach_ues(num_of_ues)
        blog('Setting 0dB attenuation to all subcells... (after test)')
        set_attenuation_to_all_subcells()
    except BaseException as e:
        blog("Keyword failed due to: {}".format(e), level="ERROR")
        try:
            blog('Setting 0dB attenuation to all subcells... (teardown)')
            set_attenuation_to_all_subcells()
            blog('Detaching UEs (teardown)...')
            rue_utils.detach_ues(1)
            stop_logging()
        except BaseException:
            pass
        raise


@logged_keyword
def attach_and_throughput_with_logs(sleep_after_attach=20, num_of_ues=1,
                                    expected_tput_dl='200Mbits/sec', expected_tput_ul='20Mbits/sec',
                                    deviation='10%', ue_caps='SA_VONR', tput_duration='60s'):
    try:
        rue_utils.require_ues(num_of_ues, capabilities=ue_caps)
        start_logging()
        rue_utils.attach_ues(num_of_ues)
        blog('Waiting {0}s after attach...'.format(sleep_after_attach))
        time.sleep(int(sleep_after_attach))
        blog("Starting UL data transfer...")
        rue_utils.start_ul_data_transfer_on_ues(duration=tput_duration, throughput=tput_ul_8985,
                                                protocol=tput_protocol_8985, parallel_streams=None,
                                                num_of_ues=num_of_ues, packet_size='1200', max_segment_size='1450')
        blog("Starting DL data transfer...")
        rue_utils.start_dl_data_transfer_on_ues(duration=tput_duration, throughput=tput_dl_8985,
                                                protocol=tput_protocol_8985, parallel_streams=None,
                                                num_of_ues=num_of_ues, packet_size='1200', max_segment_size='1450')
        blog('Data transfer started. Approx. {duration} till end...'.format(duration=tput_duration))
        data_transfer_establish_time = 20
        blog('Waiting {time}s for data transfer to be established...'.format(time=data_transfer_establish_time))
        time.sleep(data_transfer_establish_time)
        blog('Checking if UL data transfer is alive...')
        rue_utils.check_ul_transfer_is_alive(num_of_ues=num_of_ues)
        blog('Checking if DL data transfer is alive...')
        rue_utils.check_dl_transfer_is_alive(num_of_ues=num_of_ues)
        blog('Waiting for DL data transfer to finish...')
        rue_utils.await_dl_data_transfer_finish(num_of_ues=num_of_ues)
        blog('Waiting for UL data transfer to finish...')
        rue_utils.await_ul_data_transfer_finish(num_of_ues=num_of_ues)
        blog('Data transfer finished.')
        dl_tput_min = str(
            float(expected_tput_dl[:3]) - float(expected_tput_dl[:3]) * float(deviation.strip('%')) / 100) + 'Mbits/sec'
        ul_tput_min = str(
            float(expected_tput_ul[:2]) - float(expected_tput_ul[:2]) * float(deviation.strip('%')) / 100) + 'Mbits/sec'
        blog('Veryfing if average UL throughput is higher than {}'.format(ul_tput_min))
        rue_utils.verify_average_ul_throughput(num_of_ues=num_of_ues, tput_min=ul_tput_min)
        blog('Veryfing if average DL throughput is higher than {}'.format(dl_tput_min))
        rue_utils.verify_average_dl_throughput(num_of_ues=num_of_ues, tput_min=dl_tput_min)
        stop_logging()
        blog('Detaching UEs (after test)...')
        rue_utils.detach_ues(num_of_ues)
    except BaseException as e:
        blog("Keyword failed due to: {}".format(e), level="ERROR")
        try:
            blog('Detaching UEs (teardown)...')
            rue_utils.detach_ues(1)
            stop_logging()
        except BaseException:
            pass
        raise


@logged_keyword
def call_with_logs(pcap_filename="default", num_of_ues=2, ue_caps="SA_VONR", sleep_after_attach=20):
    try:
        rue_utils.require_ues(num_of_ues, capabilities=ue_caps)
        rue_utils.attach_ues(num_of_ues)
        blog('Waiting {0}s after attach...'.format(sleep_after_attach))
        time.sleep(int(sleep_after_attach))
        start_logging(pcap_filename, smod_slave=False)
        blog("Starting voice call...")
        rue_utils.start_voice_call(ue_alias='UE_2', to='UE_1')
        blog("Waiting for incoming voice call...")
        rue_utils.await_incoming_voice_call(ue_alias='UE_1', timeout='30s')
        stop_logging()
        blog('Detaching UEs (after test)...')
        rue_utils.detach_ues(num_of_ues)
    except BaseException as e:
        blog("Call failed due to: {}".format(e), level="ERROR")
        try:
            blog('Detaching UEs (teardown)...')
            rue_utils.detach_ues(num_of_ues)
            stop_logging()
        except BaseException:
            pass
        raise


@logged_keyword
def tput_and_vonr_call_between_all_subcells_with_logs(pcap_filename="default", num_of_ues=2,
                                                      expected_tput_dl='100Mbits/sec', expected_tput_ul='12Mbits/sec',
                                                      deviation='10%', sleep_after_attach=20,
                                                      tput_duration='360s'):
    try:
        blog("Attaching UEs...")
        rue_utils.attach_ues(num_of_ues)
        blog('Waiting {0}s after attach...'.format(sleep_after_attach))
        time.sleep(int(sleep_after_attach))
        start_logging(pcap_filename, smod_slave=False)
        blog("Starting UL data transfer...")
        rue_utils.start_ul_data_transfer_on_ues(duration=tput_duration, throughput=tput_ul_8985,
                                                protocol=tput_protocol_8985, parallel_streams=None,
                                                num_of_ues=num_of_ues, packet_size='1200', max_segment_size='1450')
        blog("Starting DL data transfer...")
        rue_utils.start_dl_data_transfer_on_ues(duration=tput_duration, throughput=tput_dl_8985,
                                                protocol=tput_protocol_8985, parallel_streams=None,
                                                num_of_ues=num_of_ues, packet_size='1200', max_segment_size='1450')
        blog("Starting voice call...")
        rue_utils.start_voice_call(ue_alias='UE_2', to='UE_1')
        blog("Waiting for incoming voice call...")
        rue_utils.await_incoming_voice_call(ue_alias='UE_1', timeout='720s')
        stop_logging()
        transitioning_between_all_subcells_from_1_to_6()
        transitioning_between_all_subcells_from_6_to_1()
        blog('Checking if UL data transfer is alive...')
        rue_utils.check_ul_transfer_is_alive(num_of_ues=num_of_ues)
        blog('Checking if DL data transfer is alive...')
        rue_utils.check_dl_transfer_is_alive(num_of_ues=num_of_ues)
        blog("Stopping voice call...")
        rue_utils.stop_voice_call()
        blog('Waiting for DL data transfer to finish...')
        rue_utils.await_dl_data_transfer_finish(num_of_ues=num_of_ues)
        blog('Waiting for UL data transfer to finish...')
        rue_utils.await_ul_data_transfer_finish(num_of_ues=num_of_ues)
        blog('Data transfer finished.')
        dl_tput_min = str(
            float(expected_tput_dl[:3]) - float(expected_tput_dl[:3]) * float(deviation.strip('%')) / 100) + 'Mbits/sec'
        ul_tput_min = str(
            float(expected_tput_ul[:2]) - float(expected_tput_ul[:2]) * float(deviation.strip('%')) / 100) + 'Mbits/sec'
        blog('Veryfing if average UL throughput is higher than {}'.format(ul_tput_min))
        rue_utils.verify_average_ul_throughput(num_of_ues=num_of_ues, tput_min=ul_tput_min)
        blog('Veryfing if average DL throughput is higher than {}'.format(dl_tput_min))
        rue_utils.verify_average_dl_throughput(num_of_ues=num_of_ues, tput_min=dl_tput_min)
        blog("Detaching UEs...")
        rue_utils.detach_ues(num_of_ues)
    except BaseException as e:
        blog("Call failed due to: {}".format(e), level="ERROR")
        try:
            rue_utils.detach_ues(num_of_ues)
            stop_logging()
        except BaseException:
            pass
        raise


@logged_keyword
def check_5qi_setup(pcap_file):
    frames = log_finder(pcap_file, 'ngap', 'PDUSessionResourceModifyRequest')
    for msg in frames:
        found_5qi_msg = msg.find('fiveQI*').first()['val']
        if int(found_5qi_msg) == 1:
            blog('PDUSessionResourceModifyRequest with fiveQI = 1 param found.')
            return True
    assert False, 'PDUSessionResourceModifyRequest with fiveQI = 1 param NOT found!'


def find_value_inside_brackets(string):
    return re.search(r'\((.*?)\)', string).group(1)


@logged_keyword
def check_beam_recovery_counters():
    pm_counters_path = pm.collect_counters()
    pm.check_counter_equals_x(pm_counters_path, 'M55305C09004', ['1'], 1)
    pm.check_counter_equals_x(pm_counters_path, 'M55305C10004', ['1'], 1)


@logged_keyword
def check_rntis(pcap_file):
    blog('Start RNTI extraction from F1AP logs...')
    frames = log_finder(pcap_file, 'f1ap', 'UEContextSetupResponse')
    attached_rntis = [str(ue.find('C-RNTI*').first()['val']) for ue in frames]
    blog('RNTI extraction finished. Attached RNTI: ' + str(attached_rntis))
    assert len(attached_rntis) == 1, 'There should be only one RNTI after recovery!'


def check_actSuperCell_feature_activation_param_value():
    with ScfManager() as Scf:
        feature_act_value = Scf.get_all_values_from_scf(dist_name='MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-1'.
                                                        format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
                                                        p_name='actSuperCell')
        return str(feature_act_value[0]).capitalize()


@logged_keyword
def supercell_deactivation():
    bts_sw_release = int(get_sw_release_name()[4:8].replace('R', ''))
    ds.initialise_delta_store()
    nrcell_object = 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-1'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id)
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-1'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        'actSuperCell', 'false')
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELLGRP-1'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        'numberOfTransmittedSsBlocks', '1 beam')
    ds.delete_managed_object_from_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2'.format(mrbts_id))
    ds.delete_managed_object_from_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-3'.format(mrbts_id))
    ds.delete_managed_object_from_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-4'.format(mrbts_id))
    ds.delete_managed_object_from_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-5'.format(mrbts_id))
    ds.delete_managed_object_from_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-6'.format(mrbts_id))
    super_cell_deactivation_ds_file = ds.collect_delta_store()
    blog('Delta store file (super_cell_deactivation_ds_file): {}'.format(super_cell_deactivation_ds_file))
    ds.perform_delta_recommissioning(delta_file=super_cell_deactivation_ds_file)
    au.wait_for_all_cells_on_air_state()


@logged_keyword
def supercell_activation():
    bts_sw_release = int(get_sw_release_name()[4:8].replace('R', ''))
    ds.initialise_delta_store()
    nrcell_object = 'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-1'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id)
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-1'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        'actSuperCell', 'true')
    ds.add_managed_object_and_parameter_to_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2'.format(mrbts_id))
    ds.add_managed_object_and_parameter_to_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-3'.format(mrbts_id))
    ds.add_managed_object_and_parameter_to_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-4'.format(mrbts_id))
    ds.add_managed_object_and_parameter_to_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-5'.format(mrbts_id))
    ds.add_managed_object_and_parameter_to_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-6'.format(mrbts_id))
    ds.add_managed_object_and_parameter_to_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-1'.format(mrbts_id),
        antlDN='MRBTS-55100/EQM-1/APEQM-1/RMOD-2/ANTL-2', direction='TX')
    ds.add_managed_object_and_parameter_to_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-2'.format(mrbts_id),
        antlDN='MRBTS-55100/EQM-1/APEQM-1/RMOD-2/ANTL-2', direction='RX')
    ds.add_managed_object_and_parameter_to_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-3'.format(mrbts_id),
        antlDN='MRBTS-55100/EQM-1/APEQM-1/RMOD-2/ANTL-6', direction='TX')
    ds.add_managed_object_and_parameter_to_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-2/CHANNEL-4'.format(mrbts_id),
        antlDN='MRBTS-55100/EQM-1/APEQM-1/RMOD-2/ANTL-6', direction='RX')
    ds.add_managed_object_and_parameter_to_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-3/CHANNEL-1'.format(mrbts_id),
        antlDN='MRBTS-55100/EQM-1/APEQM-1/RMOD-3/ANTL-1', direction='TX')
    ds.add_managed_object_and_parameter_to_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-3/CHANNEL-2'.format(mrbts_id),
        antlDN='MRBTS-55100/EQM-1/APEQM-1/RMOD-3/ANTL-1', direction='RX')
    ds.add_managed_object_and_parameter_to_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-3/CHANNEL-3'.format(mrbts_id),
        antlDN='MRBTS-55100/EQM-1/APEQM-1/RMOD-3/ANTL-5', direction='TX')
    ds.add_managed_object_and_parameter_to_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-3/CHANNEL-4'.format(mrbts_id),
        antlDN='MRBTS-55100/EQM-1/APEQM-1/RMOD-3/ANTL-5', direction='RX')
    ds.add_managed_object_and_parameter_to_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-4/CHANNEL-1'.format(mrbts_id),
        antlDN='MRBTS-55100/EQM-1/APEQM-1/RMOD-3/ANTL-2', direction='TX')
    ds.add_managed_object_and_parameter_to_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-4/CHANNEL-2'.format(mrbts_id),
        antlDN='MRBTS-55100/EQM-1/APEQM-1/RMOD-3/ANTL-2', direction='RX')
    ds.add_managed_object_and_parameter_to_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-4/CHANNEL-3'.format(mrbts_id),
        antlDN='MRBTS-55100/EQM-1/APEQM-1/RMOD-3/ANTL-6', direction='TX')
    ds.add_managed_object_and_parameter_to_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-4/CHANNEL-4'.format(mrbts_id),
        antlDN='MRBTS-55100/EQM-1/APEQM-1/RMOD-3/ANTL-6', direction='RX')
    ds.add_managed_object_and_parameter_to_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-5/CHANNEL-1'.format(mrbts_id),
        antlDN='MRBTS-55100/EQM-1/APEQM-1/RMOD-4/ANTL-1', direction='TX')
    ds.add_managed_object_and_parameter_to_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-5/CHANNEL-2'.format(mrbts_id),
        antlDN='MRBTS-55100/EQM-1/APEQM-1/RMOD-4/ANTL-1', direction='RX')
    ds.add_managed_object_and_parameter_to_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-5/CHANNEL-3'.format(mrbts_id),
        antlDN='MRBTS-55100/EQM-1/APEQM-1/RMOD-4/ANTL-5', direction='TX')
    ds.add_managed_object_and_parameter_to_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-5/CHANNEL-4'.format(mrbts_id),
        antlDN='MRBTS-55100/EQM-1/APEQM-1/RMOD-4/ANTL-5', direction='RX')
    ds.add_managed_object_and_parameter_to_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-6/CHANNEL-1'.format(mrbts_id),
        antlDN='MRBTS-55100/EQM-1/APEQM-1/RMOD-4/ANTL-2', direction='TX')
    ds.add_managed_object_and_parameter_to_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-6/CHANNEL-2'.format(mrbts_id),
        antlDN='MRBTS-55100/EQM-1/APEQM-1/RMOD-4/ANTL-2', direction='RX')
    ds.add_managed_object_and_parameter_to_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-6/CHANNEL-3'.format(mrbts_id),
        antlDN='MRBTS-55100/EQM-1/APEQM-1/RMOD-4/ANTL-6', direction='TX')
    ds.add_managed_object_and_parameter_to_delta(
        'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-1/CHANNELGROUP-6/CHANNEL-4'.format(mrbts_id),
        antlDN='MRBTS-55100/EQM-1/APEQM-1/RMOD-4/ANTL-6', direction='RX')
    super_cell_activation_ds_file = ds.collect_delta_store()
    blog('Delta store file (super_cell_activation_ds_file): {}'.format(super_cell_activation_ds_file))
    ds.perform_delta_recommissioning(delta_file=super_cell_activation_ds_file)
    au.wait_for_all_cells_on_air_state()


@logged_keyword
def high_speed_cell_deactivation():
    ds.initialise_delta_store()
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-1'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        'actHighSpeedCell', 'false')
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-1'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        'prachConfigurationIndex', '12')
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-1'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        'ulDMRSAdditionalPosition', 'No additional DMRS')
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-1'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        'dlDMRSAdditionalPosition', 'No additional DMRS')
    ds.add_list_parameters_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-1'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id), 'ulPtrs',
        actUlPtrs='true',
        ulPtrsFreqDensityThresNrb0=1,
        ulPtrsFreqDensityThresNrb1=3)
    ds.add_list_parameters_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-1'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id), 'dlPtrs',
        actDlPtrs='false',
        dlPtrsFreqDensityThresNrb0=1,
        dlPtrsFreqDensityThresNrb1=3)

    highspeed_cell_deactivation_ds_file = ds.collect_delta_store()
    blog('Delta store file (highspeed_cell_deactivation_ds_file): {}'.format(highspeed_cell_deactivation_ds_file))
    ds.perform_delta_recommissioning(delta_file=highspeed_cell_deactivation_ds_file)
    au.wait_for_all_cells_on_air_state()


@logged_keyword
def highspeed_cell_activation():
    ds.initialise_delta_store()
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-1'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        'actHighSpeedCell', 'true')
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-1'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        'prachConfigurationIndex', '162')
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-1'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        'ulDMRSAdditionalPosition', 'Two additional DMRS')
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-1'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        'dlDMRSAdditionalPosition', 'Two additional DMRS')
    ds.add_list_parameters_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-1'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id), 'ulPtrs',
        actUlPtrs='false',
        ulPtrsFreqDensityThresNrb0=1,
        ulPtrsFreqDensityThresNrb1=3)
    ds.add_list_parameters_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-1'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id), 'dlPtrs',
        actDlPtrs='false',
        dlPtrsFreqDensityThresNrb0=1,
        dlPtrsFreqDensityThresNrb1=3)

    highspeed_cell_activation_ds_file = ds.collect_delta_store()
    blog('Delta store file (highspeed_cell_activation_ds_file): {}'.format(highspeed_cell_activation_ds_file))
    ds.perform_delta_recommissioning(delta_file=highspeed_cell_activation_ds_file)
    au.wait_for_all_cells_on_air_state()


@logged_keyword
def check_number_of_transmitted_SSBs(expected_number, pcap_file):
    bts_sw_release = int(get_sw_release_name()[4:8].replace('R', ''))
    blog(bts_sw_release)
    if bts_sw_release == 241:
        frames = log_finder(pcap_file,
                            'dldata_ssblocksendreq',
                            'dldata_ssblocksendreq_t',
                            message_type_pattern='_5g_l1_dl_l2_ps')
    elif bts_sw_release >= 252:
        frames = log_finder(pcap_file,
                            'dldata_ssblocksendreql1sw',
                            'dldata_ssblocksendreql1sw_t',
                            message_type_pattern='nr_l1dl_l2ps')
    else:
        frames = log_finder(pcap_file,
                            'dldata_ssblocksendreq',
                            'dldata_ssblocksendreq_t',
                            message_type_pattern='nr_l1dl_l2ps')
    list_of_all_found_msgs = []
    for msg in frames:
        found_number = msg.find('subcellId*').first()['val']
        if int(found_number) < int(expected_number):
            list_of_all_found_msgs.append(found_number)
    sorted_set_of_found_subcells = sorted((set(list_of_all_found_msgs).intersection(list_of_all_found_msgs)))
    blog('sorted_set_of_found_subcells = {} '.format(sorted_set_of_found_subcells))
    blog('len of sorted_set_of_found_subcells = {} '.format(len(sorted_set_of_found_subcells)))
    if len(sorted_set_of_found_subcells) == int(expected_number):
        return True
    assert False, 'number of subcells found is different than expected'


@logged_keyword
def A_02_require_ue(num_of_ues=2, ue_caps='SA_VONR'):
    rue_utils.require_ues(num_of_ues, capabilities=ue_caps)


@logged_keyword
def A_02_attach_and_tput_with_logs(sleep_after_attach=20, num_of_ues=1,
                                   expected_tput_dl='225Mbits/sec', expected_tput_ul='28Mbits/sec',
                                   deviation='10%', tput_duration='60s', custom_dt_name=""):
    try:
        start_logging()
        rue_utils.attach_ues(num_of_ues)
        blog('Waiting {0}s after attach...'.format(sleep_after_attach))
        time.sleep(int(sleep_after_attach))
        blog("Starting UL data transfer...")
        rue_utils.start_ul_data_transfer_on_ues(duration=tput_duration, throughput=tput_ul_8985,
                                                protocol=tput_protocol_8985, parallel_streams=None,
                                                num_of_ues=num_of_ues, packet_size='1200',
                                                max_segment_size='1450', custom_dt_name=custom_dt_name)
        blog("Starting DL data transfer...")
        rue_utils.start_dl_data_transfer_on_ues(duration=tput_duration, throughput=tput_dl_8985,
                                                protocol=tput_protocol_8985, parallel_streams=None,
                                                num_of_ues=num_of_ues, packet_size='1200',
                                                max_segment_size='1450', custom_dt_name=custom_dt_name)
        blog('Data transfer started. Approx. {duration} till end...'.format(duration=tput_duration))
        data_transfer_establish_time = 20
        blog('Waiting {time}s for data transfer to be established...'.format(time=data_transfer_establish_time))
        time.sleep(data_transfer_establish_time)
        blog('Checking if UL data transfer is alive...')
        rue_utils.check_ul_transfer_is_alive(num_of_ues=num_of_ues, custom_dt_name=custom_dt_name)
        blog('Checking if DL data transfer is alive...')
        rue_utils.check_dl_transfer_is_alive(num_of_ues=num_of_ues, custom_dt_name=custom_dt_name)
        blog('Waiting for DL data transfer to finish...')
        rue_utils.await_dl_data_transfer_finish(num_of_ues=num_of_ues, custom_dt_name=custom_dt_name)
        blog('Waiting for UL data transfer to finish...')
        rue_utils.await_ul_data_transfer_finish(num_of_ues=num_of_ues, custom_dt_name=custom_dt_name)
        blog('Data transfer finished.')
        dl_tput_min = str(
            float(expected_tput_dl[:2]) - float(expected_tput_dl[:2]) * float(deviation.strip('%')) / 100) + 'Mbits/sec'
        ul_tput_min = str(
            float(expected_tput_ul[:2]) - float(expected_tput_ul[:2]) * float(deviation.strip('%')) / 100) + 'Mbits/sec'
        blog('Veryfing if average UL throughput is higher than {}'.format(ul_tput_min))
        rue_utils.verify_average_ul_throughput(num_of_ues=num_of_ues, tput_min=ul_tput_min,
                                               custom_dt_name=custom_dt_name)
        blog('Veryfing if average DL throughput is higher than {}'.format(dl_tput_min))
        rue_utils.verify_average_dl_throughput(num_of_ues=num_of_ues, tput_min=dl_tput_min,
                                               custom_dt_name=custom_dt_name)
        stop_logging()
        blog('Detaching UEs (after test)...')
        rue_utils.detach_ues(num_of_ues)
    except BaseException as e:
        blog("Keyword failed due to: {}".format(e), level="ERROR")
        try:
            blog('Detaching UEs (teardown)...')
            rue_utils.detach_ues(1)
            stop_logging()
        except BaseException:
            pass
        raise


@logged_keyword
def A_02_logs():
    start_logging()
    time.sleep(5)
    stop_logging()
