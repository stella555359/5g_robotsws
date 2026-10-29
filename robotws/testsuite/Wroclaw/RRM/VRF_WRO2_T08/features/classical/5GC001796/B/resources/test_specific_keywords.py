from collections import defaultdict

import testsuite.Wroclaw.RRM.resources.rrm_fixture as fixture
import testsuite.Wroclaw.RRM.resources.scf_verification.scf_verifier as scfv
import testsuite.Wroclaw.RRM.resources.tti_verification.csv_verification as ttiv

slots_per_sfn = 10


def setup_default_olla_parameters():
    param_dict = {'chBwUl': '5MHz', 'chBwDl': '5MHz', 'type0CoresetConfigurationIndex': '0',
                  'actDl256Qam': 'true', 'dllaIniMcs': '3', 'ullaIniMcs': '0', 'actEnhancedLinkAdaptation': 'true',
                  'ullaDeltaSinrStepdown': '250', 'dllaDeltaCqiStepdown': '250', 'dllaBlerTarget': '10'}
    scfv.setup_and_check_preconditions_in_scf(param_dict)


def setup_default_olla_parameters_64qam():
    param_dict = {'chBwUl': '5MHz', 'chBwDl': '5MHz', 'type0CoresetConfigurationIndex': '0',
                  'actDl256Qam': 'false', 'dllaIniMcs': '3', 'ullaIniMcs': '0', 'actEnhancedLinkAdaptation': 'true',
                  'ullaDeltaSinrStepdown': '250', 'dllaDeltaCqiStepdown': '250', 'dllaBlerTarget': '10'}
    scfv.setup_and_check_preconditions_in_scf(param_dict)


def check_that_laIniDelta_is_updated_correctly(tti_filepath):
    lainidelta_msg, harq_msg, fdsched_msg, ladelta_msg = \
        _get_messages_needed_for_lainidelta_update_check(tti_filepath)
    fixture.log_message(message="laIniDelta:   {}\nFdSchedData:   {}\nHarqRxData:   {}\nLaDelta:   {}"
                        .format(lainidelta_msg, fdsched_msg, harq_msg, ladelta_msg))
    _assert_lainidelta_conditions(lainidelta_msg, harq_msg, fdsched_msg)


def _get_messages_needed_for_lainidelta_update_check(tti_filepath):
    lainidelta_msg = _get_lainidelta_msg(tti_filepath)
    ladelta_msg = _get_ladelta_message_related_to_lainidelta(tti_filepath, lainidelta_msg)
    harq_feedback = _get_harq_feedback_related_to_given_ladelta(tti_filepath, ladelta_msg)
    fdshed_msg = _get_fdscheddata_related_to_given_harq(tti_filepath, harq_feedback)
    return lainidelta_msg, harq_feedback, fdshed_msg, ladelta_msg


def _get_lainidelta_msg(tti_filepath):
    ini_data = ttiv.process_needed_messages(tti_filepath, ['laIniDelta'])
    assert len(ini_data) == 1, "No laIniDelta message found (or more than 1)." \
                               " Number of found messages: {}".format(len(ini_data))
    return ini_data[0]


def _get_harq_feedback_related_to_given_ladelta(tti_filepath, ladelta):
    harq_msg_name = 'dlHarqRxDataArray' if 'Cqi' in ladelta['message_name'] else 'ulHarqRxData'
    harq_data = ttiv.process_needed_messages(tti_filepath, [harq_msg_name])
    return _determine_nearest_neighbour_message(harq_data, ladelta)


def _get_fdscheddata_related_to_given_harq(tti_filepath, harq_msg):
    direction = harq_msg['message_name'][:2]
    fdsched_data = ttiv.process_needed_messages(tti_filepath, ['{}FdSchedData'.format(direction)])
    harq_process_ind = harq_msg['{}HarqProcessIndex'.format(direction)]
    harq_reference_slot_val = int(harq_msg['sfn']) * slots_per_sfn + int(harq_msg['slot'])
    candidates = []
    for msg in fdsched_data:
        distance = int(msg['K1']) if direction == 'dl' else 0
        if (int(msg['sfn']) * slots_per_sfn + int(msg['slot']) + distance) == harq_reference_slot_val \
                and msg['{}HarqProcessIndex'.format(direction)] == harq_process_ind:
            candidates.append(msg)
    return _determine_nearest_neighbour_message(candidates, harq_msg)


def _get_ladelta_message_related_to_lainidelta(tti_filepath, lainidelta):
    message_name = 'dlLaDeltaCqiArray' if 'CQI' in lainidelta['id'] else 'ulLaDeltaSinr'
    ladelta_data = ttiv.process_needed_messages(tti_filepath, [message_name])
    return _determine_nearest_neighbour_message(ladelta_data, lainidelta)


def _get_first_message_after_specified_one(tti_data, lainidelta):
    for msg in tti_data:
        if msg['line_number'] > lainidelta['line_number']:
            return msg


def _assert_lainidelta_conditions(lainidelta_msg, harq_msg, fdsched_msg):
    param = lainidelta_msg['id'].split('_')[-1].capitalize()
    direction = harq_msg['message_name'][:2].capitalize()
    mcs = int(fdsched_msg['rrm{}UsedMcs'.format(direction)])
    ptrs = 'PTRS_ON' if fdsched_msg['ptrsFlag{}ProposedMcs'.format(direction)] == 'PTRS_ON' else 'PTRS_OFF'

    assert lainidelta_msg['event'] == 'UPDATE' and not ((mcs > 27 and ptrs == 'PTRS_OFF') or
                                                        (mcs > 26 and ptrs == 'PTRS_ON')), \
        "Highest mcs used to update ini{}".format(param)


def _calculate_sfn_slot(start_sfn, start_slot, difference):
    reference_val = (int(start_sfn) * slots_per_sfn) + int(start_slot) + difference
    reference_val = reference_val if reference_val >= 0 else (1024 * slots_per_sfn) + reference_val
    end_sfn = (reference_val // slots_per_sfn) % 1024
    end_slot = reference_val % slots_per_sfn
    return str(end_sfn), str(end_slot)


def _find_msgs_by_slot(sfn, slot, tti_data):
    data = ttiv.filter_list_of_dicts('sfn', sfn, tti_data)
    data = ttiv.filter_list_of_dicts('slot', slot, data)
    assert len(data) > 0, "Did not found any message in sfn {}, slot {}".format(sfn, slot)
    return data


def _determine_nearest_neighbour_message(candidates, message, max_distance=200):
    best_candidate = None
    best_score = 999999
    for msg in candidates:
        score = message['line_number'] - msg['line_number']
        score = score if score >= 0 else 0 - score
        if score < best_score and score <= max_distance:
            best_score = score
            best_candidate = msg
    return best_candidate


def extract_used_mcs_table_in_initial_transmissions(tti_filepath, direction='dl'):
    data = ttiv.process_needed_messages_as_generator(tti_filepath, ['{}FdSchedData'.format(direction)])
    data = ttiv.filter_list_of_dicts_as_generator('txNumber', '1', data)
    return _extract_used_mcs_table_from_fdsched_data(data)


def _extract_used_mcs_table_from_fdsched_data(fdsched_data):
    mcs_table = defaultdict(int)
    for msg in fdsched_data:
        mcs_table[msg['rrm{}UsedMcs'.format(msg['message_name'][:2].capitalize())]] += 1
    return mcs_table


def extract_used_mcs_table_in_successful_transmissions(tti_filepath, direction='dl'):
    data = ttiv.process_needed_messages_as_generator(tti_filepath, ['{}FdSchedData'.format(direction)])
    data = _filter_fdsched_data_by_harq_feedback(tti_filepath, data, direction, 'ACK')
    return _extract_used_mcs_table_from_fdsched_data(data)


def _filter_fdsched_data_by_harq_feedback(tti_filepath, fdsched_data, direction, harq_feedback, harq_dtx=None):
    harq_message_name, harq_fb_method = ('dlHarqRxDataArray', 'ackNack') if direction == 'dl' else\
        ('ulHarqRxData', 'crcResult')
    harq_msges = ttiv.process_needed_messages(tti_filepath, [harq_message_name])
    filtered_list = []
    for msg in fdsched_data:
        harq_fb_msg = _find_harq_feedback_for_fdsched_message(harq_msges, msg, direction)
        if harq_fb_msg and (harq_fb_msg[harq_fb_method] == harq_feedback or
                            (harq_dtx and harq_fb_msg['dtx'] == harq_dtx)):
            filtered_list.append(msg)
            harq_msges.remove(harq_fb_msg)
        elif not harq_fb_msg:
            fixture.log_message(message="fdsched orphan = {}".format(msg['line_number']))
    return filtered_list


def _find_harq_feedback_for_fdsched_message(harq_msges, fdsched_msg, direction):
    distance = int(fdsched_msg['K1']) if direction == 'dl' else 0
    harq_sfn, harq_slot = _calculate_sfn_slot(fdsched_msg['sfn'], fdsched_msg['slot'], distance)
    data = ttiv.filter_list_of_dicts('sfn', str(harq_sfn), harq_msges)
    data = ttiv.filter_list_of_dicts('slot', harq_slot, data)
    data = ttiv.filter_list_of_dicts('{}HarqProcessIndex'.format(direction),
                                     fdsched_msg['{}HarqProcessIndex'.format(direction)], data)
    return _determine_nearest_neighbour_message(data, fdsched_msg)


def extract_used_mcs_table_in_successful_initial_transmissions(tti_filepath, direction='dl'):
    data = ttiv.process_needed_messages_as_generator(tti_filepath, ['{}FdSchedData'.format(direction)])
    data = ttiv.filter_list_of_dicts_as_generator('txNumber', '1', data)
    data = _filter_fdsched_data_by_harq_feedback(tti_filepath, data, direction, 'ACK')
    return _extract_used_mcs_table_from_fdsched_data(data)


def extract_used_dl_mcs_table_in_last_unsuccessful_retransmissions(tti_filepath, direction='dl'):
    max_tx = get_maxDlHarqTx_value()
    data = ttiv.process_needed_messages_as_generator(tti_filepath, ['{}FdSchedData'.format(direction)])
    data = ttiv.filter_list_of_dicts_as_generator('txNumber', max_tx, data)
    data = _filter_fdsched_data_by_harq_feedback(tti_filepath, data, direction, 'NACK', 'DTX')
    return _extract_used_mcs_table_from_fdsched_data(data)


def extract_tb_size_sum_for_each_used_mcs(tti_filepath, direction):
    data = ttiv.process_needed_messages_as_generator(tti_filepath, ['{}FdSchedData'.format(direction)])
    return _extract_tb_size_sum_for_each_used_mcs_from_fdsched_data(data)


def _extract_tb_size_sum_for_each_used_mcs_from_fdsched_data(fdsched_data):
    mcs_table = defaultdict(int)
    for msg in fdsched_data:
        mcs_table[msg['rrm{}UsedMcs'.format(msg['message_name'][:2].capitalize())]] += int(int(msg['tbSize']) / 8)
    return mcs_table


def extract_tb_size_sum_for_each_used_mcs_in_initial_transmissions(tti_filepath, direction):
    data = ttiv.process_needed_messages_as_generator(tti_filepath, ['{}FdSchedData'.format(direction)])
    data = ttiv.filter_list_of_dicts_as_generator('txNumber', '1', data)
    return _extract_tb_size_sum_for_each_used_mcs_from_fdsched_data(data)


def extract_cqi_report_table(tti_filepath):
    data = ttiv.process_needed_messages_as_generator(tti_filepath, ['csiSrReportData'])
    cqi_table = defaultdict(int)
    for msg in data:
        cqi_table[msg['cqi']] += 1
    return cqi_table


def extract_pusch_sinr_levels_table_for_given_rank(tti_filepath, rank):
    data = ttiv.process_needed_messages_as_generator(tti_filepath, ['ulPuschReceiveRespPsData'])
    data = ttiv.filter_list_of_dicts_as_generator('longTermRank', rank, data)
    data = ttiv.filter_list_of_dicts_as_generator('dtx', '0', data)
    sinr_table = defaultdict(int)
    for msg in data:
        sinr_table[_get_pusch_sinr_bin(msg['sinr_[{}]'.format(int(rank)-1)])] += 1
    return sinr_table


def _get_pusch_sinr_bin(sinr):
    sinr = int((float(sinr) + 12) // 2)
    if sinr < 1:
        return '1'
    if sinr > 25:
        return '25'
    return str(sinr)


def get_maxDlHarqTx_value():
    val = scfv.get_parameters_value_from_scf(['maxDlHarqTx'])
    return val[0][0]


def check_gathered_mcs_match_pm_counters(mcs_dict, pm_counters, cell_id='1'):
    _assert_common_prechecks_for_value_table_and_pm_counters(mcs_dict, pm_counters)
    counter_prefix = pm_counters.keys()[0][:-2]
    for mcs_type, mcs_count in mcs_dict.items():
        mcs_type = '0' + mcs_type if len(mcs_type) == 1 else mcs_type
        fixture.log_message(message="pm_counter_name = {}, pm_counter_val = {} \n mcs_count = {}"
                            .format(counter_prefix + mcs_type,
                                    pm_counters[counter_prefix + mcs_type][cell_id], mcs_count))
        assert _is_pm_counter_value_acceptable(int(pm_counters[counter_prefix + mcs_type][cell_id]), mcs_count), \
            "For MCS no. {} counter value was {} but TTI traces indicates {}"\
            .format(mcs_type, pm_counters[counter_prefix + mcs_type][cell_id], mcs_count)


def _is_pm_counter_value_acceptable(pm_counter_value, supposed_value, percent_margin_of_error=5, absolute_error=3):
    abs_error = abs(pm_counter_value - supposed_value)
    percent_error = abs_error * 100 / pm_counter_value if pm_counter_value > 0 else 'N/A'
    fixture.log_message(message="absolute error = {}\nPercentt error = {}\n Allowed margins: {}%, {}"
                        .format(abs_error, percent_error, percent_margin_of_error, absolute_error))
    if percent_error == 'N/A':
        return abs_error <= absolute_error
    return percent_error <= percent_margin_of_error or abs_error <= absolute_error


def check_gathered_cqi_match_pm_counters(cqi_dict, pm_counters, cell_id='1'):
    _assert_common_prechecks_for_value_table_and_pm_counters(cqi_dict, pm_counters)
    counter_prefix = pm_counters.keys()[0][:-2]
    for cqi_type, cqi_count in cqi_dict.items():
        fixture.log_message(message="pm_counter_name = {}, pm_counter_val = {} \n mcs_count = {}"
                            .format(counter_prefix + str(int(cqi_type) + 20),
                                    pm_counters[counter_prefix + str(int(cqi_type) + 20)][cell_id], cqi_count))
        assert _is_pm_counter_value_acceptable(int(pm_counters[counter_prefix + str(int(cqi_type) + 20)][cell_id]),
                                               cqi_count), \
            "For CQI no. {} counter value was {} but TTI traces indicates {}"\
            .format(cqi_type, int(pm_counters[counter_prefix + str(int(cqi_type) + 20)][cell_id]), cqi_count)


def check_gathered_dict_relations_match_pm_counters_relations(mcs_dict, pm_counters, cell_id='1'):
    def filter_out_irrelevant_counters(value_dict, pm_counters, cell_id):
        filtered_counters = []
        for key, val in pm_counters.items():
            counter_number = key[-2:] if key[-2] != '0' else key[-1]
            if counter_number in value_dict.keys() and val[cell_id] != 0:
                filtered_counters.append((counter_number, val[cell_id]))
        return filtered_counters

    _assert_common_prechecks_for_value_table_and_pm_counters(mcs_dict, pm_counters)
    filtered_counters = filter_out_irrelevant_counters(mcs_dict, pm_counters, cell_id)
    sorted_dict = sorted(mcs_dict.items(), key=lambda x: int(x[1]))
    sorted_counters = sorted(filtered_counters, key=lambda x: int(x[1]))
    fixture.log_message(message="sorted values = {}\n sorted counters = {}".format(sorted_dict, sorted_counters))
    assert len(sorted_dict) == len(sorted_counters), "Extracted values length doesnt match pm counters length"
    for ind in range(len(sorted_counters)):
        assert sorted_dict[ind][0] == sorted_counters[ind][0], "Counter sequence does not match sequence from TTI"


def _assert_common_prechecks_for_value_table_and_pm_counters(value_table, pm_counters):
    are_pm_counters_incremeted = _check_if_any_counter_actually_incremented(pm_counters)
    if not value_table.items() and are_pm_counters_incremeted:
        raise Exception("No values were gathered but counters have incremented")
    if value_table.items() and not are_pm_counters_incremeted:
        raise Exception("Counters have not incremented")


def _check_if_any_counter_actually_incremented(pm_counters):
    for _, val_dict in pm_counters.items():
        for _, pm_value in val_dict.items():
            if pm_value != 0:
                return True
    return False
