from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.common import get_cell_dist
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.admin_utils import AdminUtils
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log import blog
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.gnb_mirroring import L1L2
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.decorators import logged_keyword
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.log_analyzer.log_helper import log_finder
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.logs.tcpdump.tcpdump_smod import TcpdumpSmod
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.testline_preparation import get_sw_release_name
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.admin_api.DeltaStore import DeltaStore
from testsuite.Wroclaw.RRM.VRF_WRO2_T07.resources.tl_config import tl

l1l2 = L1L2()
tcpdump = TcpdumpSmod()
au = AdminUtils()
CONDITIONAL_RELEASE_4 = int('SBTS25R1'[4:].replace('R', ''))
mrbts_id = 55200  # for purpose of problem
nrbts_id = tl.gnbs[0].instance_id


@logged_keyword
def lock_unused_cells(cells_to_lock):
    blog("lock_unused_cells() is deprecated, use admin_utils' lock_cells() instead.")
    au.lock_cells(cells_to_lock)


@logged_keyword
def start_logging_bip(pcap_filename="default", smod_slave=False):
    l1l2.start_gnbmirroring(filename="CB012669_{}.pcap".format(pcap_filename))
    tcpdump.start_tcpdump_on_smod(filename="CB012669_{}.pcap".format(pcap_filename), smod_slave=smod_slave)


@logged_keyword
def stop_logging_bip(teardown=False):
    tcpdump.stop_tcpdump_and_download_logs_from_smod(teardown)
    if teardown:
        l1l2.output_filepath, l1l2.gnb_mirroring_path = l1l2.setup_paths("TEARDOWN")
    l1l2.stop_gnbmirroring_and_download_logs()


@logged_keyword
def check_bip_logs(pcap_file):
    bts_sw_release = int(get_sw_release_name()[4:8].replace('R', ''))
    if bts_sw_release > CONDITIONAL_RELEASE_4:
        frames = log_finder(pcap_file,
                            'dldata_pdschsendreql1sw',
                            'dldata_pdschsendreql1sw',
                            message_type_pattern='nr_l1dl_l2ps')
        list_of_dict = []
    else:
        frames = log_finder(pcap_file,
                            'dldata_pdschsendreq',
                            'dldata_pdschsendreq',
                            message_type_pattern='nr_l1dl_l2ps')
        list_of_dict = []

    for msg in frames:
        dict_for_single_cell = {'rnti': int(msg.find('rnti*').first()['val']),
                                'startPrb': int(msg.find('startPrb*').first()['val']),
                                'numOfPrb': int(msg.find('numOfPrb*').first()['val']),
                                'rbgSize': int(msg.find('rbgSize*').first()['val']),
                                'sfn': int(msg.find('sfn*').first()['val']),
                                'slot': int(msg.find('slot*').first()['val']),
                                'rbgSizeFirst': int(msg.find('rbgSizeFirst*').first()['val']),
                                'rat0Bitmap': bin(int(msg.find('rat0Bitmap*').first()['val']))[2:]}
        list_of_dict.append(dict_for_single_cell)
    return list_of_dict


def sort_by_cell_id(list_of_dict):
    dict_per_cell = {}
    for single_dict in list_of_dict:
        rnti = single_dict['rnti']
        if rnti not in dict_per_cell:
            dict_per_cell[rnti] = [single_dict]
        else:
            dict_per_cell[rnti].append(single_dict)
    return dict_per_cell


def analyse_bit_map(list_of_msg, value_of_parameter, number_of_rbg, number_of_prio_rbg):
    number_of_rbg, value_of_parameter = map(int, [number_of_rbg, value_of_parameter])
    number_of_msg_with_fully_allocated_prio, temp_counter = 0, 0

    for msg in list_of_msg:
        used_bits_only = str(msg['rat0Bitmap'])[:number_of_rbg]
        bits_without_deprio = str((used_bits_only[:-value_of_parameter]))
        bits_with_deprio = str((used_bits_only[-value_of_parameter:]))

        deprio_rbg_result = verify_deprio_rbg(bits_with_deprio, bits_without_deprio, number_of_prio_rbg)
        number_of_msg_with_fully_allocated_prio += deprio_rbg_result[1]
        temp_counter += deprio_rbg_result[2]

        verify_first_bit(bits_without_deprio)

    number_of_msg_with_deprio_used = len(list_of_msg) - temp_counter

    blog(number_of_msg_with_deprio_used,
         'all_selected_msg')
    blog(number_of_msg_with_fully_allocated_prio,
         "all selected msg with at least {} bits =1 in prio part when deprio is used".format(number_of_prio_rbg))

    return number_of_msg_with_deprio_used, number_of_msg_with_fully_allocated_prio


def verify_deprio_rbg(bits_with_deprio, bits_without_deprio, number_of_prio_rbg):
    bits_deprio = int('1' in bits_with_deprio)
    if bits_deprio:
        counter_of_expected = verify_prio_rbg_when_deprio_used(bits_without_deprio, number_of_prio_rbg)
        temp = 0
    else:
        verify_prio_rbg_when_deprio_not_used(bits_without_deprio, number_of_prio_rbg)
        counter_of_expected = 0
        temp = 1
    return bits_deprio, counter_of_expected, temp


def verify_prio_rbg_when_deprio_not_used(bits_without_deprio, number_of_prio_rbg):
    count_of_1 = bits_without_deprio.count('1')
    assert count_of_1 == int(number_of_prio_rbg), \
        blog("Not enough bits in prio part for selected msg when deprio part not used", count_of_1,
             "not equal", number_of_prio_rbg)


def verify_first_bit(bits_without_deprio):
    assert (bits_without_deprio[0] == '1'), blog("Bottom RBG not used even with startPtb = 0")


def find_msg_to_further_verification(dict_per_cell, max_numofPrb, min_numofPrb, rnti):
    rnti, max_numofPrb, min_numofPrb = map(int, [rnti, max_numofPrb, min_numofPrb])
    return [single for single in dict_per_cell[rnti] if
            int(single['rat0Bitmap'], 2) > 0 and
            single['startPrb'] == 0 and
            max_numofPrb >= single['numOfPrb'] >= min_numofPrb and
            single['slot'] not in [5, 2]]


def verify_prio_rbg_when_deprio_used(bits_without_deprio, number_of_prio_rbg):
    count_of_1 = bits_without_deprio.count('1')
    return int(count_of_1 == int(number_of_prio_rbg))


def check_randomization(dict_per_cell, rnti, max_prb):
    rnti, max_prb = map(int, [rnti, max_prb])
    slot_list = []
    sfn_list = []
    prb = []
    bit_map = []
    randomization_counter, non_randomization_counter = 0, 0
    for single in dict_per_cell[rnti]:
        slot_list.append(int(single['slot']))
        sfn_list.append(int(single['sfn']))
        prb.append(int(single['numOfPrb']))
        bit_map.append(int(single['rat0Bitmap']))
    length = len(slot_list)
    for sfn in range(length - 1):
        if sfn_list[sfn] == sfn_list[sfn + 1] and prb[sfn] == prb[sfn + 1] and prb[sfn] < max_prb:
            if bit_map[sfn] != bit_map[sfn + 1]:
                randomization_counter += 1
            else:
                non_randomization_counter += 1
                continue
        else:
            continue
    assert randomization_counter / (non_randomization_counter + randomization_counter) >= 0.95, \
        blog("Randomization visible in ", randomization_counter, "NOT ENOUGH")
    blog("Randomization visible in ", randomization_counter, "CORRECT")


def feature_activation_669(cells_to_modify):
    ds = DeltaStore()
    ds.initialise_delta_store()
    bts_sw_release = int(get_sw_release_name()[4:8].replace('R', ''))
    for cell in cells_to_modify:
        cell = get_cell_dist(int(cell))
        ds.add_param_to_delta(cell, 'actDlRbgRandomization', 'enhanced')
        ds.add_param_to_delta(cell, 'numOfDeprioritizedDlRBGs', '5')
        ds.add_param_to_delta(cell, 'actPdschAtSsbSlots', 'false')
        ds.add_param_to_delta(cell, 'actPdschRmCsirsForTracking', 'false')
        if bts_sw_release >= CONDITIONAL_RELEASE_4:
            ds.add_param_to_delta(cell, 'actPdschAllocAroundSsb', 'false')
    ds.validate_scf()
    delta_669 = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta_file=delta_669)
    au.wait_for_all_cells_on_air_state()
    blog("Parameters set, test line on air")


def feature_deactivation_669(cells_to_modify):
    ds = DeltaStore()
    ds.initialise_delta_store()
    for cell in cells_to_modify:
        cell = get_cell_dist(int(cell))
        ds.add_param_to_delta(cell, 'numOfDeprioritizedDlRBGs', '0')
    ds.validate_scf()
    delta_669 = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta_file=delta_669)
    au.wait_for_all_cells_on_air_state()
    blog("Feature deactivated")


def feature_activation_669_pooling_off(cells_to_modify):
    feature_activation_669(cells_to_modify)
    eqm_object = f'MRBTS-{mrbts_id}/EQM-1/APEQM-1/CABINET-1'
    nrbts_object = f'MRBTS-{mrbts_id}/NRBTS-{mrbts_id}'
    ds = DeltaStore()
    ds.initialise_delta_store()
    blog("------------------Turning off pooling-------------------------")
    ds.add_param_to_delta(eqm_object + '/BBMOD-1',
                          'fddNrCellConfigTradeoff', 'max cells')
    ds.add_param_to_delta(eqm_object + '/BBMOD-2',
                          'fddNrCellConfigTradeoff', 'max cells')
    ds.validate_scf(skip_parameter_relation_errors=False)
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta, skip_parameter_relation_errors=False)
    ds = DeltaStore()
    ds.initialise_delta_store()
    ds.add_param_to_delta(nrbts_object,
                          'actSlowPrbPooling', 'false')
    ds.add_param_to_delta(nrbts_object,
                          'actSlowPrbPoolingFddFr1Enh', 'false')
    ds.add_param_to_delta(nrbts_object + '/NRDU-1',
                          'flexibleCAMode', 'ConfigurationIndependent')
    ds.validate_scf(skip_parameter_relation_errors=False)
    delta = ds.collect_delta_store()
    ds.perform_delta_recommissioning(delta, skip_parameter_relation_errors=False)
    blog("------------------feature activated and pooling turned off-------------------------")


def final_verification(all_msg_on, all_msg_off, msg_full_on, msg_full_off):
    assert msg_full_on == all_msg_on, blog("Feature on FAILED", msg_full_on, "not equal", all_msg_on)
    blog("Feature on PASSED", msg_full_on, "equal", all_msg_on)
    assert msg_full_off / all_msg_off < 0.60, blog("Feature off FAILED", msg_full_off, "more than 60% of", all_msg_off)
    blog("Feature off PASSED", msg_full_off, "less than 60% of", all_msg_off)
