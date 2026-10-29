from time import sleep
from taf.config.scf import scf
from typing import List
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.classical.CB009333.resources.test_specific_keywords_9333 import \
    MRBTS_ID, SKIP_REL_ERR
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.common import get_cell_dist
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils import AdminUtils
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config as tl
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.test.test_file_helper import os
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.gnb_mirroring import L1L2
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.attenuator import Attenuator
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.rue.attach_utils as rue_utils
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword, wait_until_function_succeeds
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.log_helper import log_finder, LogHelper
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.matchers import TTIMessageMatcher
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod import TcpdumpSmod
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.DeltaStore import DeltaStore
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation import get_sw_release_name, get_bts_id
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation import \
    load_scf, wait_for_online_state, _validate_path
from socket import gethostname
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.robot_globals import robot_globals
from itertools import chain
import testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.pm_counters as pmc
from math import ceil
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.common import backup_current_scf as backup_scf
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tti import tti_streaming as tti_collector

taf_ue = rue_utils.get_library_instance('taf.ue')

l1l2 = L1L2()
tcpdump = TcpdumpSmod()
scf = scf()
atten = Attenuator(with_initialisation=True)
au = AdminUtils()
ds = DeltaStore()

mrbts_id = tl.tl.gnbs[0].instance_id
nrbts_id = tl.tl.gnbs[0].global_bts_id

pm_interval_8985 = 5
scf_timeout_wait = 600
tput_dl_8985 = '250Mbits/sec'
tput_ul_8985 = '50Mbits/sec'
tput_dl_recovery_8985 = '50Mbits/sec'
tput_ul_recovery_8985 = '10Mbits/sec'
tput_protocol_8985 = 'tcp'

bts_prefix_from_tl = 'MRBTS-{}/NRBTS-{}'.format(str(mrbts_id), str(nrbts_id))

ports = {"1st": [1, 3], "2nd": [2, 4], "3rd": [5, 7], "4th": [6, 8], "5th": [9, 11], "6th": [10, 12],
         "FDD/TDD": [13, 14]}


@logged_keyword
def create_attenuation_list(*args: str):
    return list(chain(
        *[scell_ports for scell, scell_ports in ports.items() if scell not in {*args}]
    ))


@logged_keyword
def change_scells_attenuation(scell_1: str, scell_2: str, range_data: List[int]):
    atten.set_attenuation(value_string=0, ports=ports[scell_2], attenuator_id=1)
    for a in range(0, range_data[0] + 1, range_data[1]):
        atten.set_attenuation(value_string=a, ports=ports[scell_1], attenuator_id=1)


@logged_keyword
def perform_handover(scell_1: str, scell_2: str, entry_attenuation: int, range_data: List[int], nsa: bool = False):
    atten.set_attenuation(value_string=90, ports=create_attenuation_list(scell_1, scell_2, "FDD/TDD" if nsa else ""),
                          attenuator_id=1)
    atten.set_attenuation(value_string=entry_attenuation, ports=ports[scell_1], attenuator_id=1)
    change_scells_attenuation(scell_1, scell_2, range_data)
    sleep(5)
    blog("Handover {} cell to {} cell done".format(scell_1, scell_2))


@logged_keyword
@wait_until_function_succeeds(retry_time_in_seconds=scf_timeout_wait, retry_interval_in_seconds=30)
def scf_commissioning(scf_file):
    au = AdminUtils()
    au.perform_commissioning(bts_id=MRBTS_ID, scf_file=scf_file, skip_parameter_relation_errors=SKIP_REL_ERR)
    au.wait_for_all_cells_on_air_state()
    sleep(60)


@logged_keyword
def resolve_custom_scf_path(testcase, config_dir):
    branch = get_sw_release_name()
    rat = ''
    try:
        rat = str(get_bts_id())[0]
    except Exception as e:
        blog("Error {} occured during getting bts id".format(e), level='ERROR')
        pass
    rat = rat if rat in ['4', '5'] else '5'
    file_name = '{}_{}_{}G_{}.xml'.format(gethostname().replace('-', '_'), branch, rat, testcase)
    filepath = "{config}/{branch}/{file}".format(config=config_dir, branch=branch, file=file_name)
    assert os.path.isfile(filepath), "FileNotFoundError: [Errno 2] No such file or directory: {}".format(filepath)
    blog(filepath)
    return filepath


@logged_keyword
def upload_scf(testcase, config_dir=None, skip_relation_errors=False):
    if config_dir is None:
        config_dir = _validate_path("{}/testsuite/Wroclaw/RRM/VRF_WRO2_T07/classical/CB009142/custom_scf".
                                    format(robot_globals.execdir()))
    load_scf(scf_path=resolve_custom_scf_path(testcase, config_dir), skip_relation_errors=skip_relation_errors)
    wait_for_online_state()


@logged_keyword
def lock_unused_cells(cells_to_lock):
    blog("lock_unused_cells() is deprecated, use admin_utils' lock_cells() instead.")
    au.lock_cells(cells_to_lock)


@logged_keyword
def start_logging(pcap_filename="default", smod_slave=False):
    if pcap_filename == "default":
        l1l2.start_gnbmirroring()
        tcpdump.start_tcpdump_on_smod(smod_slave=smod_slave)
    else:
        l1l2.start_gnbmirroring(filename="CB009142_{}.pcap".format(pcap_filename))
        tcpdump.start_tcpdump_on_smod(filename="CB009142_{}.pcap".format(pcap_filename), smod_slave=smod_slave)


@logged_keyword
def stop_logging(teardown=False):
    tcpdump.stop_tcpdump_and_download_logs_from_smod(teardown)
    if teardown:
        l1l2.output_filepath, l1l2.gnb_mirroring_path = l1l2.setup_paths("TEARDOWN")
    l1l2.stop_gnbmirroring_and_download_logs()


@logged_keyword
def check_number_of_transmitted_SSBs(pcap_file, scell_1):
    blog(scell_1)
    bts_sw_release = int(get_sw_release_name()[4:8].replace('R', ''))
    blog(bts_sw_release)
    if bts_sw_release >= 252:
        frames = log_finder(pcap_file,
                            'uldata_pucchreceiveresppsl1sw',
                            'UlData_PucchReceiveRespPsl1sw_t',
                            message_type_pattern='nr_l1ul_l2ps')
    else:
        frames = log_finder(pcap_file,
                            'uldata_pucchreceiverespps',
                            'UlData_PucchReceiveRespPs_t')
    list_of_all_found_numbers_sorted = get_list_of_frames(frames)
    next_supercell_id = (int(list_of_all_found_numbers_sorted[0]) + 1) % 7
    next_supercell_id += 0 if next_supercell_id else 1
    assert len(list_of_all_found_numbers_sorted) == 2, "Scell id not changed."
    blog("Correct supercell ids were found. SuperCell 1: {}, SuperCell 2: {}".
         format(list_of_all_found_numbers_sorted[0], list_of_all_found_numbers_sorted[1]))
    list_of_all_subcells = [list_of_all_found_numbers_sorted[0], list_of_all_found_numbers_sorted[1]]
    return list_of_all_subcells


@logged_keyword
def get_list_of_frames(frames):
    list_of_all_found_numbers = []
    for msg in frames:
        found_number = msg.find('subcellId*').first()['val']
        list_of_all_found_numbers.append(found_number)
    list_of_all_found_numbers_sorted = process_frames(list_of_all_found_numbers)
    blog('Sorted Super Cell IDs = {}'.format(list_of_all_found_numbers_sorted))
    blog('Length of sorted_set_of_found_subcells = {}'.format(len(list_of_all_found_numbers_sorted)))
    list_of_all_found_numbers_sorted = list(list_of_all_found_numbers_sorted)
    return list_of_all_found_numbers_sorted


@logged_keyword
def process_frames(list_of_all_found_numbers):
    list_of_all_found_numbers_sorted = sorted(set(list_of_all_found_numbers))
    if len(list_of_all_found_numbers_sorted) == 3:
        list_of_all_found_numbers_sorted.remove('0')
    if ['1', '6'] == list_of_all_found_numbers_sorted:
        list_of_all_found_numbers_sorted.reverse()
    return list_of_all_found_numbers_sorted


@logged_keyword
def nullify_supercell_attenuation(*scell: str):
    to_nullify = list(chain(*[ports[id] for id in list(ports.keys()) if id in scell]))
    atten.set_attenuation(value_string=0, ports=to_nullify, attenuator_id=1)
    atten.set_attenuation(value_string=90, ports=create_attenuation_list(*scell), attenuator_id=1)


@logged_keyword
def change_attenuation(scell_1: str, scell_2: str, range_data: List[int], nsa: bool = False):
    atten.set_attenuation(value_string=90, ports=create_attenuation_list(scell_1, scell_2, "FDD/TDD" if nsa else ""),
                          attenuator_id=1)
    change_scells_attenuation(scell_1, scell_2, range_data)
    blog("Performed switch to {} SCELL".format(scell_2))


@logged_keyword
def check_5qi_setup(pcap_file):
    frames = log_finder(pcap_file, 'ngap', 'PDUSessionResourceModifyRequest')
    for msg in frames:
        found_5qi_msg = msg.find('fiveQI*').first()['val']
        blog(found_5qi_msg)
        if int(found_5qi_msg) == 1:
            blog('PDUSessionResourceModifyRequest with fiveQI = 1 param found.')
            return True
    assert False, 'PDUSessionResourceModifyRequest with fiveQI = 1 param NOT found!'


@logged_keyword
def get_and_verify_counters(counter_dir, counter_ids):
    value_dict = pmc.get_relevant_pm_counters(pi_dir=counter_dir, counter_ids=counter_ids)
    if not value_dict:
        raise KeyError('dict is empty, there is no such counters collected on bts')
    return value_dict


def verify_counter(counters, scell_numbers, counter, target_counter_values):
    values = [counters[counter][cell][-1] for cell in counters[counter] if int(cell) in
              scell_numbers]
    assert len(set(values)) == 1 and values[0] in target_counter_values, \
        "Not all values in {} counter are increased".format(counter)


@logged_keyword
def check_if_HO_counters_incremented(counters, target_counter_values=None):
    M55125C09014_numbers = [12, 13, 1]
    M55125C09015_numbers = [11, 12, 13]
    if not target_counter_values:
        target_counter_values = [1, 2, 3]
    verify_counter(counters, M55125C09014_numbers, "M55125C09014", target_counter_values)
    verify_counter(counters, M55125C09015_numbers, "M55125C09015", target_counter_values)


@logged_keyword
def check_if_HO_counters_incremented_A2_A3(counters, target_counter_values=None):
    M55114C00018_numbers = [12]
    M55114C00016_numbers = [12]
    if not target_counter_values:
        target_counter_values = [1]
    verify_counter(counters, M55114C00018_numbers, "M55114C00018", target_counter_values)
    verify_counter(counters, M55114C00016_numbers, "M55114C00016", target_counter_values)


@logged_keyword
def attenuation_6supercells():
    change_attenuation("1st", "2nd", [40, 10])
    stop_logging()
    sleep(10)
    scells_to_loop = list(ports.keys())[1:-2]
    for i, scell in enumerate(scells_to_loop):
        start_logging("1_A_" + str(i + 2))
        change_attenuation(scell, list(ports.keys())[i + 2], [60, 10])
        stop_logging()
        sleep(10)


@logged_keyword
def handover_cell(scell_0: str, scell_1: str, scell_2: str, tc_prefix: str, nsa: bool = False):
    handover_data = {"2nd_3rd": [0, [60, 5]], "4th_5th": [0, [60, 5]],
                     "6th_FDD/TDD": [0, [60, 5]]}
    log_number = list(handover_data.keys()).index(scell_1 + "_" + scell_2) * (2 if nsa else 1) + 1
    if log_number > 1:
        start_logging(tc_prefix + str(log_number))
    change_attenuation(scell_0, scell_1, [60, 10], nsa)
    sleep(5)
    stop_logging()
    verify_tput()
    sleep(10)
    if scell_2 != "FDD/TDD" or (scell_2 == "FDD/TDD" and not nsa):
        if nsa:
            start_logging(tc_prefix + str(log_number + 1))
        perform_handover(scell_1, scell_2, *handover_data[scell_1 + "_" + scell_2], nsa)
        if nsa:
            stop_logging()
    verify_tput()
    sleep(5)


@logged_keyword
def verify_tput():
    taf_ue.check_data_transfer_is_alive(dt_name="DT_DL")
    taf_ue.check_data_transfer_is_alive(dt_name="DT_UL")
    taf_ue.verify_average_throughput(dt_name="DT_DL", tput_min="1Mbits/sec")
    taf_ue.verify_average_throughput(dt_name="DT_UL", tput_min="1Mbits/sec")


@logged_keyword
def attenuation_supercells_ncell(scell_1: str, scell_2: str, tc_prefix: str, number: str = "", nsa: bool = False):
    if scell_1[0] != "1":
        start_logging(tc_prefix + scell_1[0])
    if number != "":
        taf_ue.start_voice_call(vc_alias="VOICE_CALL", ue_alias="UE_1", to=number, duration="1000s")
    change_attenuation(scell_1, scell_2, [60, 10], nsa)
    sleep(5)
    if number != "":
        taf_ue.stop_voice_call(vc_alias="VOICE_CALL")
    stop_logging()
    sleep(5)


@logged_keyword
def attenuation_each_6scells(number: str):
    scells_to_loop = list(ports.keys())[:-1] + [list(ports.keys())[0]]
    for i, scell in enumerate(scells_to_loop[1:]):
        attenuation_supercells_ncell(scells_to_loop[i], scell, "1_B_", number)


@logged_keyword
def verify_5qi_in_files(pcap_file: str):
    for i in range(1, 7):
        check_5qi_setup(pcap_file.replace("index", str(i)))


@logged_keyword
def verify_ssb_messages(pcap_file: str, last_index=6):
    list_of_cell_2 = []
    for i in range(1, int(last_index) + 1):
        list_of_cell = check_number_of_transmitted_SSBs(pcap_file.replace("index", str(i)),
                                                        i if int(last_index) < 3 else 6 // int(last_index) *
                                                        (i - 1) + 1)
        list_of_cell_2.extend(list_of_cell)
    list_of_cell_2 = set(list_of_cell_2)
    blog("Cells ID's full", list_of_cell_2)
    list_of_cell_2 = len(list_of_cell_2)
    if last_index in ["5", "6", "3"]:
        assert list_of_cell_2 == 6, "list, of subcell switch is wrong"
        blog("6 subcells are present")
    if last_index == "2":
        assert list_of_cell_2 == 3, "list, of subcell switch is wrong"
        blog("3 subcells are present")


@logged_keyword
def supercell_activation_9142(cni=None):
    antl_data = [['2', '6'], ['1', '5']]
    ds.initialise_delta_store()
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-11'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        'actSuperCell', 'true')
    for c_group_id in range(2, 7):
        ds.add_managed_object_and_parameter_to_delta(
            'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-{}'.format(mrbts_id, c_group_id))
        for channel_id in range(1, 5):
            ds.add_managed_object_and_parameter_to_delta(
                'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-{}/CHANNEL-{}'
                .format(mrbts_id, c_group_id, channel_id),
                antlDN='MRBTS-{}/EQM-1/APEQM-1/RMOD-{}/ANTL-{}'
                .format(mrbts_id, ceil(c_group_id / 2), antl_data[c_group_id % 2][(channel_id - 1) // 2]),
                direction='TX' if channel_id % 2 else 'RX')
    if cni == 'cni_test':
        ds.add_param_to_delta(
            'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-11'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
            'eirpControlPowerReductionFactorList', ['0', '0', '0', '0', '0', '0'])
    super_cell_activation_ds_file = ds.collect_delta_store()
    blog('Delta store file (super_cell_activation_ds_file): {}'.format(super_cell_activation_ds_file))
    ds.perform_delta_recommissioning(delta_file=super_cell_activation_ds_file)
    au.wait_for_all_cells_on_air_state()


@logged_keyword
def supercell_deactivation_9142(cni=None):
    ds.initialise_delta_store()
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-11'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        'actSuperCell', 'false')
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELLGRP-11'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        'numberOfTransmittedSsBlocks', '1 beam')
    for c_group_id in range(2, 7):
        ds.delete_managed_object_from_delta(
            'MRBTS-{}/MNL-1/MNLENT-1/CELLMAPPING-1/LCELNR-11/CHANNELGROUP-{}'.format(mrbts_id, c_group_id))
    if cni == 'cni_test':
        ds.add_param_to_delta('MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-11'.format(mrbts_id=mrbts_id,
                                                                                   nrbts_id=nrbts_id),
                              'eirpControlPowerReductionFactorList', ['0'])
    super_cell_deactivation_ds_file = ds.collect_delta_store()
    blog('Delta store file (super_cell_deactivation_ds_file): {}'.format(super_cell_deactivation_ds_file))
    ds.perform_delta_recommissioning(delta_file=super_cell_deactivation_ds_file)
    au.wait_for_all_cells_on_air_state()


@logged_keyword
def attenuation_3_scells():
    scells_to_loop = list(ports.keys())[:3] + [list(ports.keys())[4]]
    for i, scell in enumerate(scells_to_loop[1:]):
        attenuation_supercells_ncell(scells_to_loop[i], scell, "3_", nsa=True)
        verify_tput()
        sleep(10)


@logged_keyword
def attenuation_6supercells_with_TTI():
    path_list = []
    change_attenuation("1st", "2nd", [40, 10])
    path_list.append(stop_logging_TTI(csv_filename=os.path.join("TTI", "picapica_1st")))
    sleep(10)
    scells_to_loop = list(ports.keys())[1:-2]
    for i, scell in enumerate(scells_to_loop):
        start_logging_TTI("1_A_" + str(i + 2))
        change_attenuation(scell, list(ports.keys())[i + 2], [60, 10])
        path_list.append(stop_logging_TTI(csv_filename=os.path.join("TTI", "picapica_{}".format(scell))))
        sleep(10)
    return path_list


@logged_keyword
def check_cni_counters(cells, counters, target_counter_values=None, number_of_subcell='1', tput=None):
    cells = [int(cells)]
    target_counter_values = int(target_counter_values)

    for counter in counters:
        values = [counters[counter][cell][-1] for cell in counters[counter] if int(cell) in
                  cells]
        if counter[-3:-1] in ['10', '20', '50', '60', '70']:
            if int(counter[-1]) <= int(number_of_subcell):
                assert len(set(values)) == 1 and int(values[0]) > target_counter_values, \
                    blog("eirp counters for all subcells not incremented")
            else:
                assert len(set(values)) == 1 and int(values[0]) == 0, \
                    blog("eirp counters for higher segment than number of subells incremented")
        elif counter[-3:-1] in ['40']:
            if int(counter[-1]) < int(number_of_subcell):
                assert len(set(values)) == 1 and int(values[0]) > target_counter_values, \
                    blog("beam counters for all subcells not incremented")
            else:
                assert len(set(values)) == 1 and int(values[0]) == 0, \
                    blog("beam counters for higher segment than number of subcells incremented")
        elif counter[-3:-1] in ['30']:
            if tput:
                if int(counter[-1]) <= int(number_of_subcell):
                    assert len(set(values)) == 1 and int(values[0]) >= target_counter_values, \
                        blog("eirp tput counters for all subcells not visible")
                else:
                    assert len(set(values)) == 1 and int(values[0]) == 0, \
                        blog("eirp tput counters for higher segment than number of subcells incremented")
            else:
                assert len(set(values)) == 1 and int(values[0]) == 0, \
                    blog("eirp tput counters for all subcells incremented without tput")
        else:
            assert len(set(values)) == 1 and int(values[0]) > target_counter_values, \
                blog("counters per cell not incremented")


def verify_current_subcell(path_tti, rnti, expected_num_subcells):
    full_list = []
    cells = []
    for tti_logs in path_tti:
        with LogHelper() as lh:
            tti_finder = lh.add_tti(log_files=tti_logs)
            matcher = TTIMessageMatcher('dlFdSchedData').containing(key_pattern='rnti', val_pattern=rnti,
                                                                    regex_engine='re')
            event = tti_finder.find_all(matcher)
        cell, one_log_list = list(dict.fromkeys(msg['lcrId'] for msg in event)), \
            list(dict.fromkeys(msg['subcellId'] for msg in event))
        assert len(one_log_list) == 2, blog('num of subcells should be 2, but {}'.format(len(one_log_list)))
        full_list.extend(one_log_list)
        cells.extend(cell)
    subcells = list(dict.fromkeys(full_list))
    assert len(set(cells)) == 1, blog('more than 1 cell visible')
    assert len(subcells) == int(expected_num_subcells), blog('not all subcells switch visible,', len(subcells))
    blog('subcells:', subcells, 'cell:', set(cells))


@logged_keyword
def start_logging_TTI(pcap_filename="default", smod_slave=False):
    if pcap_filename == "default":
        tti_collector.start_tti_traces_in_streaming_mode(collector_type="sbts")
        tcpdump.start_tcpdump_on_smod(smod_slave=smod_slave)
    else:
        tti_collector.start_tti_traces_in_streaming_mode(collector_type="sbts")
        tcpdump.start_tcpdump_on_smod(filename="supercell_{}.pcap".format(pcap_filename), smod_slave=smod_slave)


@logged_keyword
def stop_logging_TTI(csv_filename, teardown=False):
    tcpdump.stop_tcpdump_and_download_logs_from_smod(teardown)
    if teardown:
        tti_collector.stop_tti_traces_in_streaming_mode(tti_collector_name="TTI", decoded_output_file="TEARDOWN_TTI")
    path = tti_collector.stop_tti_traces_in_streaming_mode(tti_collector_name="TTI", decoded_output_file=csv_filename)
    return path


def eirp_activation(cell):
    ds.initialise_delta_store()
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-11'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        'actEirpControl', 'true')
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-11'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        'antennaMechanicalDowntilt', '0')
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-11'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        'externalAntennaGain', '0')
    ds.add_param_to_delta(
        'MRBTS-{mrbts_id}/NRBTS-{nrbts_id}/NRCELL-11'.format(mrbts_id=mrbts_id, nrbts_id=nrbts_id),
        'eirpControlPowerReductionFactorList', ['0', '0', '0', '0', '0', '0'])
    ds.add_complex_item_to_delta(get_cell_dist(cell), 'eirpControl',
                                 minGuaranteedBudgetRatio=50,
                                 minGuaranteedBudgetRatioMode='actualEirpBudgetRatio',
                                 minSignificantNormalizedBeamGain='-20',
                                 numOfSegmentAzimuthEdges='0',
                                 numOfSegmentElevationEdges='0',
                                 schedulWeightFactorEnabled='false')
    eirp_activation_ds_file = ds.collect_delta_store()
    blog('Delta store file (super_cell_activation_ds_file): {}'.format(eirp_activation_ds_file))
    ds.perform_delta_recommissioning(delta_file=eirp_activation_ds_file)
    au.wait_for_all_cells_on_air_state()


def compare_different_power_reduction(cells, counters, subcell_higher, subcell_lower):
    value_higher = []
    value_lower = []
    cells = [int(cells)]
    for counter in counters:
        values = [counters[counter][cell][-1] for cell in counters[counter] if int(cell) in
                  cells]
        if counter[-3:-1] in ['10', '70']:
            if int(counter[-1]) == int(subcell_higher):
                value_higher.append([counters[counter][cell][-3] for cell in counters[counter] if int(cell) in cells])
            elif int(counter[-1]) == int(subcell_lower):
                value_lower.append([counters[counter][cell][-1] for cell in counters[counter] if int(cell) in cells])
        elif counter[-3:-1] in ['40']:
            if int(counter[-1]) == int(subcell_higher)-1:
                value_higher.append([counters[counter][cell][-3] for cell in counters[counter] if int(cell) in cells])
            elif int(counter[-1]) == int(subcell_lower)-1:
                value_lower.append([counters[counter][cell][-1] for cell in counters[counter] if int(cell) in cells])
        elif counter[-3:-1] in ['30']:
            if int(counter[-1]) == int(subcell_lower):
                assert ([counters[counter][cell][-1] for cell in counters[counter] if int(cell) in cells])[0] > 0, \
                    blog("Counters M55324C0030x not incremented fo subcell with power reduction factor configured")
        elif int(counter[-1]) == int(subcell_lower) - 1:
            value_lower.append([counters[counter][cell][-1] for cell in counters[counter] if int(cell) in cells])
    blog(value_lower, "LOWER", value_higher, "HIGHER")
    for single_lower, single_higher in zip(value_lower, value_higher):
        assert single_lower[0] < 0.7 * single_higher[0], \
            blog("not all expected counters are lower for subcell with power reduction factor configured")
        blog(single_lower[0], "LOWER", single_higher[0], "HIGHER")
    blog("Counters compared successfully")


def single_switch_or_ho_with_TTI(scell1='1st', scell2='2nd', switch_number='1'):
    start_logging_TTI("2_A_" + switch_number)
    path_list = []
    change_attenuation(scell1, scell2, [40, 10])
    path_list.append(stop_logging_TTI(csv_filename=os.path.join("TTI", "picapica_{}".format(scell1))))
    sleep(10)
    return path_list
